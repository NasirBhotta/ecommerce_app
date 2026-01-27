const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");
const bodyParser = require("body-parser");
require("dotenv").config();

admin.initializeApp();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

// Middleware for raw body
exports.rawBody = functions.https.onRequest((req, res) => {
    bodyParser.raw({ type: 'application/json' })(req, res, () => { });
});

// ----------------------------
// Create Stripe Customer
// ----------------------------
exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
    try {
        const customer = await stripe.customers.create({
            email: data.email,
            name: data.name,
        });
        return { customerId: customer.id };
    } catch (error) {
        return { error: error.message };
    }
});

// ----------------------------
// Create SetupIntent (Add Card)
// ----------------------------
exports.createSetupIntent = functions.https.onCall(async (data, context) => {
    try {
        const setupIntent = await stripe.setupIntents.create({
            customer: data.customerId,
        });
        return { clientSecret: setupIntent.client_secret };
    } catch (error) {
        return { error: error.message };
    }
});

// ----------------------------
// Create PaymentIntent (Pay Using Card)
// ----------------------------
exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: data.amount, // in cents
            currency: 'usd',
            customer: data.customerId,
            payment_method: data.paymentMethodId,
            off_session: true,
            confirm: true,
        });
        return { clientSecret: paymentIntent.client_secret, status: paymentIntent.status };
    } catch (error) {
        return { error: error.message };
    }
});

// ----------------------------
// Simulate Withdrawals / Payouts
// ----------------------------
exports.createPayout = functions.https.onCall(async (data, context) => {
    try {
        // In production, use Stripe Connect for real payouts
        return { success: true, message: `Successfully withdrawn $${data.amount}` };
    } catch (error) {
        return { error: error.message };
    }
});

// ----------------------------
// Webhook Endpoint for Stripe Events
// ----------------------------
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
    const sig = req.headers['stripe-signature'];
    let event;

    try {
        event = stripe.webhooks.constructEvent(
            req.rawBody,
            sig,
            process.env.STRIPE_WEBHOOK_SECRET
        );
    } catch (err) {
        console.log('Webhook signature verification failed.', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle events
    switch (event.type) {
        case 'payment_intent.succeeded':
            const paymentIntent = event.data.object;
            console.log('Payment succeeded:', paymentIntent.id);
            // Update Firestore payment status
            break;

        case 'setup_intent.succeeded':
            const setupIntent = event.data.object;
            console.log('SetupIntent succeeded:', setupIntent.id);
            // Update Firestore: card added
            break;

        case 'payout.paid':
            console.log('Payout paid:', event.data.object.id);
            break;

        default:
            console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
});
