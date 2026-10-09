
const { onCall, HttpsError } =
  require("firebase-functions/v2/https");

const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function validateId(id) {
  return typeof id === "string" &&
    /^[A-Za-z0-9_-]{1,150}$/.test(id);
}

// SUPPLIER VERIFIES PAYMENT

exports.verifyProcurementPayment = onCall(
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

    const {
      paymentId,
      decision,
      reason,
    } = request.data || {};

    if (!validateId(paymentId)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid payment ID."
      );
    }

    if (!["verify", "dispute"].includes(decision)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid decision."
      );
    }

    if (
      decision === "dispute" &&
      (
        typeof reason !== "string" ||
        reason.trim().length < 5 ||
        reason.trim().length > 500
      )
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Provide a reason for the discrepancy."
      );
    }

    const paymentRef =
      db.collection("payments").doc(paymentId);

    return db.runTransaction(async (tx) => {
      const paymentSnap = await tx.get(paymentRef);

      if (!paymentSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Payment record not found."
        );
      }

      const payment = paymentSnap.data();

      if (payment.supplierId !== uid) {
        throw new HttpsError(
          "permission-denied",
          "You cannot verify another supplier's payment."
        );
      }

      if (payment.verificationStatus !== "pending") {
        throw new HttpsError(
          "failed-precondition",
          "Payment already reviewed."
        );
      }

      if (!validateId(payment.orderId)) {
        throw new HttpsError(
          "failed-precondition",
          "Invalid linked order."
        );
      }

      const orderRef = db
        .collection("orders")
        .doc(payment.orderId);

      const orderSnap = await tx.get(orderRef);

      if (!orderSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Linked order not found."
        );
      }

      const order = orderSnap.data();

      if (
        order.supplierId !== uid ||
        order.buyerUid !== payment.buyerUid ||
        order.paymentId !== paymentId ||
        order.status !== "payment_submitted" ||
        !Number.isFinite(payment.amount) ||
        !Number.isFinite(order.totalAmount) ||
        Math.abs(
          payment.amount - order.totalAmount
        ) > 0.01
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Order and payment do not match."
        );
      }

      const verified = decision === "verify";

      const nextPaymentStatus =
        verified ? "verified" : "disputed";

      const nextOrderStatus =
        verified ? "payment_verified" : "payment_issue";

      const now =
        admin.firestore.FieldValue.serverTimestamp();

      tx.update(paymentRef, {
        verificationStatus: nextPaymentStatus,
        verifiedBy: uid,
        verifiedAt: verified ? now : null,
        reviewedAt: now,
        disputeReason: verified ? "" : reason.trim(),
        updatedAt: now,
      });

      tx.update(orderRef, {
        status: nextOrderStatus,
        updatedAt: now,
      });

      tx.create(
        db.collection("auditLogs").doc(),
        {
          entityType: "payment",
          entityId: paymentId,
          orderId: payment.orderId,
          actorUid: uid,
          buyerUid: payment.buyerUid,
          supplierId: uid,
          action: verified
            ? "payment_verified"
            : "payment_disputed",
          createdAt: now,
        }
      );

      return {
        success: true,
        paymentStatus: nextPaymentStatus,
        orderStatus: nextOrderStatus,
      };
    });
  }
);

// SECURE PAYMENT PROOF VIEWING

exports.getProcurementPaymentProof = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    const uid = request.auth?.uid;
    const paymentId = request.data?.paymentId;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Please sign in."
      );
    }

    if (!validateId(paymentId)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid payment ID."
      );
    }

    const paymentSnap = await db
      .collection("payments")
      .doc(paymentId)
      .get();

    if (!paymentSnap.exists) {
      throw new HttpsError(
        "not-found",
        "Payment not found."
      );
    }

    const payment = paymentSnap.data();

    if (
      payment.supplierId !== uid &&
      payment.buyerUid !== uid
    ) {
      throw new HttpsError(
        "permission-denied",
        "Not authorized to view this receipt."
      );
    }

    const path = payment.proofStoragePath;

    if (
      typeof path !== "string" ||
      !path.startsWith(
        `paymentProofs/${payment.buyerUid}/${payment.orderId}/`
      ) ||
      path.includes("..") ||
      path.length > 500
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid stored payment proof."
      );
    }

    try {
      const file = admin.storage()
        .bucket()
        .file(path);

      const [exists] = await file.exists();

      if (!exists) {
        throw new HttpsError(
          "not-found",
          "Transaction slip not found."
        );
      }

      // Short-lived access to the private file.
      const [url] = await file.getSignedUrl({
        version: "v4",
        action: "read",
        expires: Date.now() + 5 * 60 * 1000,
      });

      return {
        url,
        expiresInSeconds: 300,
      };
    } catch (error) {
      if (error instanceof HttpsError) throw error;

      console.error(
        "Unable to sign payment proof URL",
        error
      );

      throw new HttpsError(
        "internal",
        "Unable to open payment proof."
      );
    }
  }
);
