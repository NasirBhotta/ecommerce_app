const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");
require("dotenv").config();

admin.initializeApp();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
const db = admin.firestore();

// ==========================================
// HELPER FUNCTIONS
// ==========================================

/**
 * Verify user is authenticated
 */
function requireAuth(context) {
    if (!context.auth) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'User must be authenticated to perform this action.'
        );
    }
    return context.auth.uid;
}

/**
 * Validate amount is a positive number
 */
function validateAmount(amount) {
    if (typeof amount !== 'number' || amount <= 0 || isNaN(amount)) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'Amount must be a positive number.'
        );
    }
}

/**
 * Validate required fields exist
 */
function validateRequired(data, fields) {
    const missing = fields.filter(field => !data[field]);
    if (missing.length > 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            `Missing required fields: ${missing.join(', ')}`
        );
    }
}

/**
 * Calculate wallet balance from ledger
 */
async function getWalletBalance(userId) {
    const ledgerSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('wallet_ledger')
        .where('status', '==', 'completed')
        .get();

    let balance = 0;
    ledgerSnapshot.forEach(doc => {
        const data = doc.data();
        if (data.type === 'credit') {
            balance += data.amount;
        } else if (data.type === 'debit') {
            balance -= data.amount;
        }
    });

    return balance;
}

// ==========================================
// CREATE STRIPE CUSTOMER
// ==========================================
exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
    const userId = requireAuth(context);

    try {
        validateRequired(data, ['email', 'name']);

        // Check if customer already exists
        const userDoc = await db.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data().stripeCustomerId) {
            return { customerId: userDoc.data().stripeCustomerId };
        }

        // Create Stripe customer
        const customer = await stripe.customers.create({
            email: data.email,
            name: data.name,
            metadata: { firebaseUID: userId }
        });

        // Save to Firestore
        await db.collection('users').doc(userId).update({
            stripeCustomerId: customer.id
        });

        return { customerId: customer.id };
    } catch (error) {
        console.error('Error creating Stripe customer:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// CREATE SETUP INTENT (ADD CARD)
// ==========================================
exports.createSetupIntent = functions.https.onCall(async (data, context) => {
    requireAuth(context);

    try {
        validateRequired(data, ['customerId']);

        const setupIntent = await stripe.setupIntents.create({
            customer: data.customerId,
            payment_method_types: ['card']
        });

        return { clientSecret: setupIntent.client_secret };
    } catch (error) {
        console.error('Error creating setup intent:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// CREATE PAYMENT INTENT
// ==========================================
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    const userId = requireAuth(context);

    try {
        validateRequired(data, ['amount', 'customerId', 'paymentMethodId']);
        validateAmount(data.amount);

        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(data.amount * 100), // Convert to cents
            currency: 'usd',
            customer: data.customerId,
            payment_method: data.paymentMethodId,
            off_session: true,
            confirm: true,
            metadata: {
                firebaseUID: userId,
                ...data.metadata
            }
        });

        return {
            clientSecret: paymentIntent.client_secret,
            status: paymentIntent.status,
            id: paymentIntent.id
        };
    } catch (error) {
        console.error('Error creating payment intent:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// GET PAYMENT METHODS
// ==========================================
exports.getPaymentMethods = functions.https.onCall(async (data, context) => {
    requireAuth(context);

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
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// DELETE PAYMENT METHOD
// ==========================================
// ==========================================
// ADD BANK ACCOUNT
// ==========================================
exports.addBankAccount = functions.https.onCall(async (data, context) => {
    // Fixed logging - don't stringify context directly
    console.log('addBankAccount called');
    console.log('Auth UID:', context.auth?.uid);
    console.log('Auth Token:', context.auth?.token);
    console.log('Data received:', data);

    const userId = requireAuth(context);
    console.log('User ID:', userId);

    try {
        validateRequired(data, ['bankName', 'accountNumber', 'accountHolderName', 'routingNumber']);

        // Check if this is the first bank account
        const accountsSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .get();

        const isPrimary = accountsSnapshot.empty;

        // If not primary, unset other primary accounts if needed
        if (!isPrimary) {
            const batch = db.batch();
            accountsSnapshot.forEach(doc => {
                if (doc.data().isPrimary) {
                    batch.update(doc.ref, { isPrimary: false });
                }
            });
            await batch.commit();
        }

        // Add new bank account (store only last 4 digits)
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
        throw new functions.https.HttpsError('internal', error.message);
    }
});
// ==========================================
// DELETE BANK ACCOUNT
// ==========================================
exports.deleteBankAccount = functions.https.onCall(async (data, context) => {
    const userId = requireAuth(context);

    try {
        validateRequired(data, ['accountId']);

        // Delete from Firestore
        await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .doc(data.accountId)
            .delete();

        // If this was primary, make another account primary
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
                // Set first account as primary
                await remainingAccounts.docs[0].ref.update({
                    isPrimary: true
                });
            }
        }

        return { message: 'Bank account deleted successfully' };
    } catch (error) {
        console.error('Error deleting bank account:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// SET PRIMARY BANK ACCOUNT
// ==========================================
exports.setPrimaryBankAccount = functions.https.onCall(async (data, context) => {
    const userId = requireAuth(context);

    try {
        validateRequired(data, ['accountId']);

        // Use batch to update multiple documents atomically
        const batch = db.batch();

        // Get all bank accounts
        const accountsSnapshot = await db
            .collection('users')
            .doc(userId)
            .collection('bank_accounts')
            .get();

        // Set all to non-primary except the selected one
        accountsSnapshot.forEach(doc => {
            batch.update(doc.ref, { isPrimary: doc.id === data.accountId });
        });

        await batch.commit();

        return { message: 'Primary account updated successfully' };
    } catch (error) {
        console.error('Error setting primary account:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// REQUEST WITHDRAWAL (PAYOUT)
// ==========================================
exports.requestWithdrawal = functions.https.onCall(async (data, context) => {
    const userId = requireAuth(context);

    try {
        validateRequired(data, ['amount', 'bankAccountId']);
        validateAmount(data.amount);

        // Use Firestore transaction for atomic balance check and withdrawal
        return await db.runTransaction(async (transaction) => {
            // Check wallet balance
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
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    `Insufficient balance. Available: $${balance.toFixed(2)}`
                );
            }

            // Get bank account details
            const bankAccountDoc = await transaction.get(
                db.collection('users')
                    .doc(userId)
                    .collection('bank_accounts')
                    .doc(data.bankAccountId)
            );

            if (!bankAccountDoc.exists) {
                throw new functions.https.HttpsError(
                    'not-found',
                    'Bank account not found.'
                );
            }

            const bankAccount = bankAccountDoc.data();

            // Create withdrawal entry in ledger
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
            // After transaction succeeds, update status to completed
            // In production, you would create a Stripe payout here
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
        if (error.code) {
            throw error; // Re-throw HttpsError
        }
        throw new functions.https.HttpsError('internal', error.message);
    }
});

// ==========================================
// STRIPE WEBHOOK
// ==========================================
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
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

    // Handle different event types
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

        // Add credit to wallet ledger
        await db
            .collection('users')
            .doc(userId)
            .collection('wallet_ledger')
            .add({
                type: 'credit',
                amount: paymentIntent.amount / 100, // Convert from cents
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
    // Implement notification logic
}

async function handlePayoutFailure(payout) {
    console.error('Payout failed:', payout.id);

    // Find and mark ledger entries as failed
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