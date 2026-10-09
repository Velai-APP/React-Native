
'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

exports.confirmProcurementDelivery = onCall(
  { region: 'us-central1' },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        'unauthenticated',
        'Sign in as the buyer.'
      );
    }

    const d = request.data || {};
    const orderId = d.orderId;

    if (
      typeof orderId !== 'string' ||
      !orderId ||
      orderId.length > 150 ||
      orderId.includes('/')
    ) {
      throw new HttpsError(
        'invalid-argument',
        'A valid orderId is required.'
      );
    }

    if (
      !Number.isInteger(d.rating) ||
      d.rating < 1 ||
      d.rating > 5
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Rating must be a whole number between 1 and 5.'
      );
    }

    if (
      typeof d.feedback !== 'string' ||
      d.feedback.trim().length < 10 ||
      d.feedback.trim().length > 1000
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Feedback must be 10–1000 characters.'
      );
    }

    const orderRef = db.collection('orders').doc(orderId);

    const fulfilmentRef = db
      .collection('fulfilments')
      .doc(orderId);

    const reviewRef = db
      .collection('supplierReviews')
      .doc(orderId);

    return db.runTransaction(async (tx) => {
      const [orderSnap, fulfilmentSnap, reviewSnap] =
        await Promise.all([
          tx.get(orderRef),
          tx.get(fulfilmentRef),
          tx.get(reviewRef),
        ]);

      if (!orderSnap.exists) {
        throw new HttpsError(
          'not-found',
          'Order not found.'
        );
      }

      const order = orderSnap.data();

      if (order.buyerUid !== uid) {
        throw new HttpsError(
          'permission-denied',
          'Only the buyer of this order may confirm delivery.'
        );
      }

      if (
        !fulfilmentSnap.exists ||
        fulfilmentSnap.data().buyerUid !== uid ||
        fulfilmentSnap.data().supplierId !== order.supplierId
      ) {
        throw new HttpsError(
          'failed-precondition',
          'Shipment or service fulfilment has not been recorded.'
        );
      }

      if (order.status !== 'fulfilment_submitted') {
        throw new HttpsError(
          'failed-precondition',
          'Order must be dispatched before delivery confirmation.'
        );
      }

      if (reviewSnap.exists) {
        throw new HttpsError(
          'already-exists',
          'Review already submitted for this order.'
        );
      }

      const now = admin.firestore.FieldValue.serverTimestamp();

      // Save supplier rating and feedback.
      tx.create(reviewRef, {
        orderId,
        buyerUid: uid,
        supplierId: order.supplierId,
        rating: d.rating,
        feedback: d.feedback.trim(),
        createdAt: now,
        updatedAt: now,
      });

      // Confirm shipment delivery.
      tx.update(fulfilmentRef, {
        status: 'delivered',
        deliveredAt: now,
        confirmedBy: uid,
        updatedAt: now,
      });

      // Complete procurement order.
      tx.update(orderRef, {
        status: 'order_completed',
        deliveredAt: now,
        completedAt: now,
        updatedAt: now,
      });

      return {
        success: true,
        orderId,
        status: 'order_completed',
      };
    });
  }
);
