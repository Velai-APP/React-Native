
const { onCall, HttpsError } =
  require("firebase-functions/v2/https");

const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

exports.respondToProcurementOrder = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Please sign in."
      );
    }

    const { orderId, decision } = request.data || {};

    if (
      typeof orderId !== "string" ||
      !/^[A-Za-z0-9_-]{1,150}$/.test(orderId)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid orderId."
      );
    }

    if (decision !== "accept" && decision !== "reject") {
      throw new HttpsError(
        "invalid-argument",
        "Invalid decision."
      );
    }

    const orderRef = db.collection("orders").doc(orderId);

    const status = await db.runTransaction(async (tx) => {
      const orderSnap = await tx.get(orderRef);

      if (!orderSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Order not found."
        );
      }

      const order = orderSnap.data();

      if (order.supplierId !== uid) {
        throw new HttpsError(
          "permission-denied",
          "Not your order."
        );
      }

      if (order.status !== "pending_supplier_acceptance") {
        throw new HttpsError(
          "failed-precondition",
          "Order already processed."
        );
      }

      if (
        typeof order.quotationId !== "string" ||
        typeof order.requestId !== "string" ||
        typeof order.buyerUid !== "string" ||
        typeof order.totalAmount !== "number"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Order data is incomplete."
        );
      }

      const quotationRef = db
        .collection("quotations")
        .doc(order.quotationId);

      const quoteSnap = await tx.get(quotationRef);

      if (!quoteSnap.exists) {
        throw new HttpsError(
          "failed-precondition",
          "Quotation not found."
        );
      }

      const quote = quoteSnap.data();

      if (
        quote.status !== "submitted" ||
        quote.supplierId !== uid ||
        quote.buyerUid !== order.buyerUid ||
        quote.requestId !== order.requestId ||
        typeof quote.grandTotal !== "number" ||
        Math.abs(
          quote.grandTotal - order.totalAmount
        ) > 0.01
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Quotation and order do not match."
        );
      }

      const nextStatus = decision === "accept"
        ? "order_accepted"
        : "order_rejected";

      const now =
        admin.firestore.FieldValue.serverTimestamp();

      tx.update(orderRef, {
        status: nextStatus,
        supplierDecisionAt: now,
        updatedAt: now,
      });

      const auditRef = db.collection("auditLogs").doc();

      tx.create(auditRef, {
        entityType: "order",
        entityId: orderId,
        action: nextStatus,
        actorUid: uid,
        buyerUid: order.buyerUid,
        supplierId: uid,
        createdAt: now,
      });

      return nextStatus;
    });

    return { status };
  }
);
	