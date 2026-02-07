const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const Stripe = require("stripe");
require("dotenv").config();

// Set global options
setGlobalOptions({
    region: "us-central1",
});

admin.initializeApp();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
const db = admin.firestore();

// ==========================================
// HELPER FUNCTIONS
// ==========================================

function requireAuth(request) {
    if (!request.auth) {
        throw new HttpsError(
            'unauthenticated',
            'User must be authenticated to perform this action.'
        );
    }
    return request.auth.uid;
}

function validateAmount(amount) {
    if (typeof amount !== 'number' || amount <= 0 || isNaN(amount)) {
        throw new HttpsError(
            'invalid-argument',
            'Amount must be a positive number.'
        );
    }
}

function validateRequired(data, fields) {
    const missing = fields.filter(field => !data[field]);
    if (missing.length > 0) {
        throw new HttpsError(
            'invalid-argument',
            `Missing required fields: ${missing.join(', ')}`
        );
    }
}

// ==========================================
// CREATE STRIPE CUSTOMER
// ==========================================
exports.createStripeCustomer = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['email', 'name']);

        const userDoc = await db.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data().stripeCustomerId) {
            return { customerId: userDoc.data().stripeCustomerId };
        }

        const customer = await stripe.customers.create({
            email: data.email,
            name: data.name,
            metadata: { firebaseUID: userId }
        });

        await db.collection('users').doc(userId).update({
            stripeCustomerId: customer.id
        });

        return { customerId: customer.id };
    } catch (error) {
        console.error('Error creating Stripe customer:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// CREATE SETUP INTENT (ADD CARD)
// ==========================================
exports.createSetupIntent = onCall({ consumeAppCheckToken: false }, async (request) => {
    requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['customerId']);

        const setupIntent = await stripe.setupIntents.create({
            customer: data.customerId,
            payment_method_types: ['card']
        });

        return { clientSecret: setupIntent.client_secret };
    } catch (error) {
        console.error('Error creating setup intent:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// CREATE PAYMENT INTENT (PaymentSheet)
// ==========================================
exports.createPaymentIntent = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['amount', 'customerId']);
        validateAmount(data.amount);

        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(data.amount * 100),
            currency: 'usd',
            customer: data.customerId,
            automatic_payment_methods: { enabled: true },
            metadata: {
                firebaseUID: userId,
                ...data.metadata
            }
        });

        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: data.customerId },
            { apiVersion: '2023-10-16' }
        );

        return {
            clientSecret: paymentIntent.client_secret,
            id: paymentIntent.id,
            customerId: data.customerId,
            ephemeralKey: ephemeralKey.secret
        };
    } catch (error) {
        console.error('Error creating payment intent:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// GET PAYMENT METHODS
// ==========================================
exports.getPaymentMethods = onCall({ consumeAppCheckToken: false }, async (request) => {
    requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['customerId']);

        const paymentMethods = await stripe.paymentMethods.list({
            customer: data.customerId,
            type: 'card'
        });

        return {
            paymentMethods: paymentMethods.data.map(pm => ({
                id: pm.id,
                brand: pm.card.brand,
                last4: pm.card.last4,
                expMonth: pm.card.exp_month,
                expYear: pm.card.exp_year
            }))
        };
    } catch (error) {
        console.error('Error fetching payment methods:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// DELETE PAYMENT METHOD
// ==========================================
exports.deletePaymentMethod = onCall({ consumeAppCheckToken: false }, async (request) => {
    requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['paymentMethodId']);

        await stripe.paymentMethods.detach(data.paymentMethodId);
        return { message: 'Payment method deleted successfully' };
    } catch (error) {
        console.error('Error deleting payment method:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// ADD BANK ACCOUNT
// ==========================================
exports.addBankAccount = onCall({ consumeAppCheckToken: false }, async (request) => {
    console.log('=== addBankAccount called ===');
    console.log('Auth present:', !!request.auth);
    console.log('Auth UID:', request.auth?.uid);

    const userId = requireAuth(request);
    const data = request.data;

    console.log('Authenticated user ID:', userId);
    console.log('Data received:', data);

    try {
        validateRequired(data, ['bankName', 'accountNumber', 'accountHolderName', 'routingNumber']);

        const accountsSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .get();

        const isPrimary = accountsSnapshot.empty;

        if (!isPrimary) {
            const batch = db.batch();
            accountsSnapshot.forEach(doc => {
                if (doc.data().isPrimary) {
                    batch.update(doc.ref, { isPrimary: false });
                }
            });
            await batch.commit();
        }

        const docRef = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .add({
                bankName: data.bankName,
                accountNumber: data.accountNumber.slice(-4),
                accountHolderName: data.accountHolderName,
                routingNumber: data.routingNumber,
                isPrimary: isPrimary,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });

        console.log('Bank account added successfully:', docRef.id);

        return {
            id: docRef.id,
            message: 'Bank account added successfully'
        };
    } catch (error) {
        console.error('Error adding bank account:', error);

        if (error instanceof HttpsError) {
            throw error;
        }

        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// DELETE BANK ACCOUNT
// ==========================================
exports.deleteBankAccount = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['accountId']);

        await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .doc(data.accountId)
            .delete();

        const remainingAccounts = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .get();

        if (!remainingAccounts.empty) {
            const hasPrimary = remainingAccounts.docs.some(
                doc => doc.data().isPrimary
            );

            if (!hasPrimary) {
                await remainingAccounts.docs[0].ref.update({
                    isPrimary: true
                });
            }
        }

        return { message: 'Bank account deleted successfully' };
    } catch (error) {
        console.error('Error deleting bank account:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// SET PRIMARY BANK ACCOUNT
// ==========================================
exports.setPrimaryBankAccount = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['accountId']);

        const batch = db.batch();

        const accountsSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .get();

        accountsSnapshot.forEach(doc => {
            batch.update(doc.ref, { isPrimary: doc.id === data.accountId });
        });

        await batch.commit();

        return { message: 'Primary account updated successfully' };
    } catch (error) {
        console.error('Error setting primary account:', error);
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// REQUEST WITHDRAWAL (PAYOUT)
// ==========================================
exports.requestWithdrawal = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['amount', 'bankAccountId']);
        validateAmount(data.amount);

        return await db.runTransaction(async (transaction) => {
            const ledgerSnapshot = await transaction.get(
                db.collection('users')
                    .doc(userId)
                    .collection('wallet_ledger')
                    .where('status', '==', 'completed')
            );

            let balance = 0;
            ledgerSnapshot.forEach(doc => {
                const ledgerData = doc.data();
                if (ledgerData.type === 'credit') {
                    balance += ledgerData.amount;
                } else if (ledgerData.type === 'debit') {
                    balance -= ledgerData.amount;
                }
            });

            if (data.amount > balance) {
                throw new HttpsError(
                    'failed-precondition',
                    `Insufficient balance. Available: $${balance.toFixed(2)}`
                );
            }

            const bankAccountDoc = await transaction.get(
                db.collection('users')
                    .doc(userId)
                    .collection('bank_accounts')
                    .doc(data.bankAccountId)
            );

            if (!bankAccountDoc.exists) {
                throw new HttpsError(
                    'not-found',
                    'Bank account not found.'
                );
            }

            const bankAccount = bankAccountDoc.data();

            const ledgerRef = db
                .collection('users')
                .doc(userId)
                .collection('wallet_ledger')
                .doc();

            transaction.set(ledgerRef, {
                type: 'debit',
                amount: data.amount,
                description: `Withdrawal to ${bankAccount.bankName} ****${bankAccount.accountNumber}`,
                status: 'pending',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                bankAccountId: data.bankAccountId
            });

            return {
                message: 'Withdrawal request submitted successfully',
                transactionId: ledgerRef.id,
                balance: balance - data.amount
            };
        }).then(async (result) => {
            await db
                .collection('users')
                .doc(userId)
                .collection('wallet_ledger')
                .doc(result.transactionId)
                .update({
                    status: 'completed',
                    processedAt: admin.firestore.FieldValue.serverTimestamp()
                });

            return result;
        });
    } catch (error) {
        console.error('Error processing withdrawal:', error);
        if (error instanceof HttpsError) {
            throw error;
        }
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// PAY WITH WALLET
// ==========================================
exports.payWithWallet = onCall({ consumeAppCheckToken: false }, async (request) => {
    const userId = requireAuth(request);
    const data = request.data;

    try {
        validateRequired(data, ['amount', 'orderId']);
        validateAmount(data.amount);

        return await db.runTransaction(async (transaction) => {
            // 1. Calculate current balance
            const ledgerSnapshot = await transaction.get(
                db.collection('users')
                    .doc(userId)
                    .collection('wallet_ledger')
                    .where('status', '==', 'completed')
            );

            let balance = 0;
            ledgerSnapshot.forEach(doc => {
                const ledgerData = doc.data();
                if (ledgerData.type === 'credit') {
                    balance += ledgerData.amount;
                } else if (ledgerData.type === 'debit') {
                    balance -= ledgerData.amount;
                }
            });

            // 2. Check sufficiency
            if (data.amount > balance) {
                throw new HttpsError(
                    'failed-precondition',
                    `Insufficient wallet balance. Available: $${balance.toFixed(2)}`
                );
            }

            // 3. Create debit transaction
            const ledgerRef = db
                .collection('users')
                .doc(userId)
                .collection('wallet_ledger')
                .doc();

            transaction.set(ledgerRef, {
                type: 'debit',
                amount: data.amount,
                description: `Payment for Order #${data.orderId}`,
                status: 'completed',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                orderId: data.orderId,
                referenceId: ledgerRef.id
            });

            return {
                success: true,
                transactionId: ledgerRef.id,
                remainingBalance: balance - data.amount
            };
        });
    } catch (error) {
        console.error('Error processing wallet payment:', error);
        if (error instanceof HttpsError) {
            throw error;
        }
        throw new HttpsError('internal', error.message);
    }
});

// ==========================================
// SEND PUSH NOTIFICATION ON CREATE (V2)
// ==========================================

exports.sendNotificationOnCreate = onDocumentCreated(
    "users/{userId}/notifications/{notificationId}",
    async (event) => {

        const snap = event.data;
        if (!snap) return;

        const data = snap.data();
        const userId = event.params.userId;

        try {

            const userDoc = await db.collection("users").doc(userId).get();
            const userData = userDoc.exists ? userDoc.data() : {};
            const settings = userData.notificationSettings || {};

            // Check master setting
            if (settings.pushNotifications === false) return;

            const type = data.type || "system";

            const typeSettingMap = {
                order: "orderUpdates",
                delivery: "orderUpdates",
                payment: "orderUpdates",
                promotion: "promotionalOffers",
                account: "accountActivity",
                app: "appUpdates",
                system: "appUpdates",
                new_arrival: "newArrivals",
            };

            const typeSetting = typeSettingMap[type];

            if (typeSetting && settings[typeSetting] === false) return;

            // Get FCM tokens
            const tokensSnapshot = await db
                .collection("users")
                .doc(userId)
                .collection("fcm_tokens")
                .get();

            if (tokensSnapshot.empty) return;

            const tokens = tokensSnapshot.docs.map((doc) => doc.id);

            // Prepare data payload
            const dataPayload = {};

            if (data.data && typeof data.data === "object") {
                Object.keys(data.data).forEach((key) => {
                    dataPayload[key] = String(data.data[key]);
                });
            }

            dataPayload.notificationId = event.params.notificationId;
            dataPayload.type = type;

            const message = {
                tokens,

                notification: {
                    title: data.title || "Notification",
                    body: data.body || "",
                },

                data: dataPayload,

                android: {
                    notification: {
                        channelId: "default",
                    },
                },

                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                        },
                    },
                },
            };

            const response =
                await admin.messaging().sendEachForMulticast(message);

            // Cleanup invalid tokens
            const invalidTokens = [];

            response.responses.forEach((result, index) => {
                if (result.error) {
                    const code = result.error.code;

                    if (
                        code === "messaging/registration-token-not-registered" ||
                        code === "messaging/invalid-registration-token"
                    ) {
                        invalidTokens.push(tokens[index]);
                    }
                }
            });

            if (invalidTokens.length > 0) {
                const batch = db.batch();

                invalidTokens.forEach((token) => {
                    const ref = db
                        .collection("users")
                        .doc(userId)
                        .collection("fcm_tokens")
                        .doc(token);

                    batch.delete(ref);
                });

                await batch.commit();
            }

            return;

        } catch (error) {
            console.error("Error sending notification:", error);
            return;
        }
    }
);


// ==========================================
// STRIPE WEBHOOK
// ==========================================
exports.stripeWebhook = onRequest(async (req, res) => {
    const sig = req.headers['stripe-signature'];
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    let event;

    try {
        event = stripe.webhooks.constructEvent(
            req.rawBody,
            sig,
            webhookSecret
        );
    } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    try {
        switch (event.type) {
            case 'payment_intent.succeeded':
                await handlePaymentSuccess(event.data.object);
                break;

            case 'payment_intent.payment_failed':
                await handlePaymentFailure(event.data.object);
                break;

            case 'setup_intent.succeeded':
                console.log('Card setup successful:', event.data.object.id);
                break;

            case 'payout.paid':
                console.log('Payout completed:', event.data.object.id);
                break;

            case 'payout.failed':
                await handlePayoutFailure(event.data.object);
                break;

            default:
                console.log(`Unhandled event type: ${event.type}`);
        }

        res.json({ received: true });
    } catch (error) {
        console.error('Error handling webhook:', error);
        res.status(500).json({ error: error.message });
    }
});

// ==========================================
// WEBHOOK HANDLERS
// ==========================================

async function handlePaymentSuccess(paymentIntent) {
    try {
        const userId = paymentIntent.metadata.firebaseUID;

        if (!userId) {
            console.error('No Firebase UID in payment intent metadata');
            return;
        }

        await db
            .collection('users')
            .doc(userId)
            .collection('wallet_ledger')
            .add({
                type: 'credit',
                amount: paymentIntent.amount / 100,
                description: 'Payment received',
                status: 'completed',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                paymentIntentId: paymentIntent.id
            });

        console.log('Payment credited to wallet:', paymentIntent.id);
    } catch (error) {
        console.error('Error handling payment success:', error);
    }
}

async function handlePaymentFailure(paymentIntent) {
    console.error('Payment failed:', paymentIntent.id);
}

async function handlePayoutFailure(payout) {
    console.error('Payout failed:', payout.id);

    const ledgerSnapshot = await db
        .collectionGroup('wallet_ledger')
        .where('status', '==', 'pending')
        .where('type', '==', 'debit')
        .get();

    const batch = db.batch();
    ledgerSnapshot.forEach(doc => {
        batch.update(doc.ref, {
            status: 'failed',
            failedAt: admin.firestore.FieldValue.serverTimestamp(),
            failureReason: payout.failure_message || 'Payout failed'
        });
    });
    await batch.commit();
}
