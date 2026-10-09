
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const timestamp = admin.firestore.FieldValue.serverTimestamp;

const nonEmpty = (v, max = 120) =>
  typeof v === 'string' &&
  v.trim().length > 0 &&
  v.trim().length <= max;

const optional = (v, max = 1000) =>
  v == null ||
  (typeof v === 'string' && v.length <= max);

const validDate = v =>
  typeof v === 'string' &&
  !Number.isNaN(Date.parse(v));

exports.submitProcurementFulfilment = onCall(
  {
    region: 'us-central1',
    enforceAppCheck: false,
  },
  async (request) => {
    // 1. Authenticate supplier
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        'unauthenticated',
        'Sign in to submit fulfilment.'
      );
    }

    const d = request.data || {};

    // 2. Validate order ID
    if (
      !nonEmpty(d.orderId, 150) ||
      d.orderId.includes('/')
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Valid orderId required.'
      );
    }

    // 3. Validate fulfilment type
    if (
      !['shipment', 'service'].includes(
        d.fulfilmentType
      )
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Unknown fulfilment type.'
      );
    }

    // 4. Validate dates
    if (
      !validDate(d.dispatchDate) ||
      (d.expectedDeliveryDate != null &&
        !validDate(d.expectedDeliveryDate))
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Invalid dispatch/completion dates.'
      );
    }

    if (
      d.expectedDeliveryDate &&
      Date.parse(d.expectedDeliveryDate) <
        Date.parse(d.dispatchDate)
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Delivery cannot precede dispatch.'
      );
    }

    // 5. Validate remarks
    if (
      !optional(d.notes) ||
      !optional(d.deliveryProofReference, 300)
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Notes or proof reference too long.'
      );
    }

    // 6. Validate shipment details
    if (
      d.fulfilmentType === 'shipment' &&
      (
        !nonEmpty(d.carrierName, 100) ||
        !nonEmpty(d.trackingNumber, 120)
      )
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Carrier and tracking number required.'
      );
    }

    // 7. Firestore references
    const orderRef = db
      .collection('orders')
      .doc(d.orderId);

    const fulfilmentRef = db
      .collection('fulfilments')
      .doc(d.orderId);

    // 8. Atomic Firestore transaction
    return await db.runTransaction(async (tx) => {
      const [orderSnap, existing] = await Promise.all([
        tx.get(orderRef),
        tx.get(fulfilmentRef),
      ]);

      if (!orderSnap.exists) {
        throw new HttpsError(
          'not-found',
          'Order not found.'
        );
      }

      const order = orderSnap.data();

      // 9. Only assigned supplier can dispatch
      if (order.supplierId !== uid) {
        throw new HttpsError(
          'permission-denied',
          'Not the assigned supplier.'
        );
      }

      // 10. Payment must be verified
      if (order.status !== 'payment_verified') {
        throw new HttpsError(
          'failed-precondition',
          'Supplier can submit fulfilment only after verified payment.'
        );
      }

      // 11. Prevent duplicate shipment
      if (existing.exists) {
        throw new HttpsError(
          'already-exists',
          'Fulfilment already submitted.'
        );
      }

      // 12. Create shipment or service record
      tx.create(fulfilmentRef, {
        orderId: d.orderId,
        buyerUid: order.buyerUid,
        supplierId: uid,

        fulfilmentType: d.fulfilmentType,

        carrierName:
          d.fulfilmentType === 'shipment'
            ? d.carrierName.trim()
            : '',

        trackingNumber:
          d.fulfilmentType === 'shipment'
            ? d.trackingNumber.trim()
            : '',

        dispatchDate:
          admin.firestore.Timestamp.fromDate(
            new Date(d.dispatchDate)
          ),

        expectedDeliveryDate:
          d.expectedDeliveryDate
            ? admin.firestore.Timestamp.fromDate(
                new Date(d.expectedDeliveryDate)
              )
            : null,

        deliveryProofReference:
          (d.deliveryProofReference || '').trim(),

        notes: (d.notes || '').trim(),

        status: 'submitted',

        createdAt: timestamp(),
        updatedAt: timestamp(),
      });

      // 13. Update order status
      tx.update(orderRef, {
        status: 'fulfilment_submitted',
        updatedAt: timestamp(),
      });

      // 14. Return success to Flutter
      return {
        success: true,
        orderId: d.orderId,
        status: 'fulfilment_submitted',
      };
    });
  }
);
