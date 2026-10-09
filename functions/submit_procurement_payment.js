
const { onCall, HttpsError } =
  require("firebase-functions/v2/https");

const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const storage = admin.storage();

exports.submitProcurementPayment = onCall(
  {
    region: "us-central1",
    maxInstances: 10,
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Please sign in."
      );
    }

    const {
      orderId,
      transactionReference,
      proofStoragePath,
    } = request.data || {};

    if (
      typeof orderId !== "string" ||
      !/^[A-Za-z0-9_-]{1,150}$/.test(orderId)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid order ID."
      );
    }

    if (
      typeof transactionReference !== "string" ||
      transactionReference.trim().length < 4 ||
      transactionReference.trim().length > 100
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Enter a valid transaction reference."
      );
    }

    const escapedUid = uid.replace(
      /[.*+?^${}()|[\]\\]/g,
      "\\$&"
    );

    const escapedOrder = orderId.replace(
      /[.*+?^${}()|[\]\\]/g,
      "\\$&"
    );

    const pathPattern = new RegExp(
      `^paymentProofs/${escapedUid}/` +
      `${escapedOrder}/[A-Za-z0-9_-]+\\.` +
      `(jpg|jpeg|png|pdf)$`
    );

    if (
      typeof proofStoragePath !== "string" ||
      !pathPattern.test(proofStoragePath)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid payment proof path."
      );
    }

    // Validate that the uploaded file exists.
    let metadata;

    try {
      const file = storage
        .bucket()
        .file(proofStoragePath);

      const result = await file.getMetadata();
      metadata = result[0];
    } catch (e) {
      throw new HttpsError(
        "failed-precondition",
        "Payment proof was not found."
      );
    }

    const allowedTypes = [
      "image/jpeg",
      "image/png",
      "application/pdf",
    ];

    if (
      !allowedTypes.includes(metadata.contentType) ||
      Number(metadata.size) <= 0 ||
      Number(metadata.size) > 8 * 1024 * 1024 ||
      metadata.metadata?.buyerUid !== uid ||
      metadata.metadata?.orderId !== orderId
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Uploaded payment proof is invalid."
      );
    }

    const orderRef = db.collection("orders").doc(orderId);
    const invoiceRef = db.collection("invoices").doc(orderId);
    const paymentRef = db.collection("payments").doc(orderId);

    return db.runTransaction(async (tx) => {
      const orderSnap = await tx.get(orderRef);
      const invoiceSnap = await tx.get(invoiceRef);
      const paymentSnap = await tx.get(paymentRef);

      if (!orderSnap.exists || !invoiceSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Order or invoice not found."
        );
      }

      const order = orderSnap.data();
      const invoice = invoiceSnap.data();

      if (
        order.buyerUid !== uid ||
        invoice.buyerUid !== uid ||
        order.supplierId !== invoice.supplierId ||
        invoice.orderId !== orderId
      ) {
        throw new HttpsError(
          "permission-denied",
          "You cannot submit payment for this order."
        );
      }

      if (paymentSnap.exists) {
        throw new HttpsError(
          "already-exists",
          "Payment proof was already submitted."
        );
      }

      if (
        order.status !== "invoice_issued" ||
        invoice.status !== "issued"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Invoice is not awaiting payment."
        );
      }

      const amount = Number(invoice.totalAmount);

      if (
        !Number.isFinite(amount) ||
        amount <= 0 ||
        Math.abs(
          amount - Number(order.totalAmount)
        ) > 0.01
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Order and invoice amounts do not match."
        );
      }

      const now =
        admin.firestore.FieldValue.serverTimestamp();

      tx.create(paymentRef, {
        orderId,
        invoiceId: invoiceRef.id,
        buyerUid: uid,
        supplierId: order.supplierId,

        transactionReference:
          transactionReference.trim(),

        proofStoragePath,

        amount,
        currency: "INR",
        verificationStatus: "pending",

        submittedAt: now,
        createdAt: now,
        updatedAt: now,
      });

      tx.update(orderRef, {
        status: "payment_submitted",
        paymentId: paymentRef.id,
        updatedAt: now,
      });

      tx.create(
        db.collection("auditLogs").doc(),
        {
          entityType: "payment",
          entityId: paymentRef.id,
          orderId,
          buyerUid: uid,
          supplierId: order.supplierId,
          actorUid: uid,
          action: "payment_submitted",
          createdAt: now,
        }
      );

      return {
        success: true,
        paymentId: paymentRef.id,
        status: "pending",
      };
    });
  }
);
