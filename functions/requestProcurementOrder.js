
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

exports.requestProcurementOrder = onCall(
  {
    region: "us-central1",
    enforceAppCheck: false,
  },
  async (request) => {
    // 1. Authenticate buyer
    const buyerUid = request.auth?.uid;

    if (!buyerUid) {
      throw new HttpsError(
        "unauthenticated",
        "Please sign in before requesting an order."
      );
    }

    const requestId = request.data?.requestId;
    const quotationId = request.data?.quotationId;

    if (
      typeof requestId !== "string" ||
      typeof quotationId !== "string" ||
      !/^[a-zA-Z0-9_-]{1,150}$/.test(requestId) ||
      !/^[a-zA-Z0-9_-]{1,150}$/.test(quotationId)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Valid requestId and quotationId are required."
      );
    }

    // 2. Firestore references
    const purchaseRef = db
      .collection("purchaseRequests")
      .doc(requestId);

    const quotationRef = db
      .collection("quotations")
      .doc(quotationId);

    // One order per purchase request
    const orderRef = db
      .collection("orders")
      .doc(requestId);

    try {
      // 3. Use an atomic transaction
      const result = await db.runTransaction(async (tx) => {
        const purchaseSnap = await tx.get(purchaseRef);
        const quotationSnap = await tx.get(quotationRef);
        const orderSnap = await tx.get(orderRef);

        // 4. Purchase request validation
        if (!purchaseSnap.exists) {
          throw new HttpsError(
            "not-found",
            "Purchase request not found."
          );
        }

        const purchase = purchaseSnap.data();

        if (purchase.buyerUid !== buyerUid) {
          throw new HttpsError(
            "permission-denied",
            "You do not own this purchase request."
          );
        }

        const validPurchaseStatuses = [
          "published",
          "rfq_sent",
          "open",
          "quoted",
          "quotes_received",
        ];

        if (
          !validPurchaseStatuses.includes(purchase.status)
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Purchase request must be published before ordering."
          );
        }

        // 5. Prevent duplicate orders
        if (orderSnap.exists) {
          throw new HttpsError(
            "already-exists",
            "An order already exists for this purchase request."
          );
        }

        // 6. Quotation validation
        if (!quotationSnap.exists) {
          throw new HttpsError(
            "not-found",
            "Selected quotation not found."
          );
        }

        const quotation = quotationSnap.data();

        if (
          quotation.requestId !== requestId ||
          quotation.buyerUid !== buyerUid ||
          quotation.status !== "submitted"
        ) {
          throw new HttpsError(
            "failed-precondition",
            "The quotation is not valid for this purchase request."
          );
        }

        const supplierId = quotation.supplierId;

        if (
          typeof supplierId !== "string" ||
          !supplierId ||
          supplierId === buyerUid
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Invalid supplier on the quotation."
          );
        }

        // 7. Confirm supplier was invited
        const invitedSuppliers =
          purchase.invitedSupplierIds || [];

        if (
          !Array.isArray(invitedSuppliers) ||
          !invitedSuppliers.includes(supplierId)
        ) {
          throw new HttpsError(
            "permission-denied",
            "The quotation supplier was not invited."
          );
        }

        // 8. Validate quotation amount
        const totalAmount = quotation.grandTotal;

        if (
          typeof totalAmount !== "number" ||
          !Number.isFinite(totalAmount) ||
          totalAmount <= 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation must have a valid grand total."
          );
        }

        // 9. Create the order
        tx.create(orderRef, {
          requestId,
          quotationId,
          buyerUid,
          supplierId,
          currency: "INR",
          totalAmount,
          status: "pending_supplier_acceptance",
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        return {
          orderId: orderRef.id,
          supplierId,
          totalAmount,
        };
      });

      console.log("Procurement order created", {
        orderId: result.orderId,
        buyerUid,
        supplierId: result.supplierId,
      });

      // 10. Respond to Flutter
      return {
        success: true,
        orderId: result.orderId,
        requestId,
        quotationId,
        supplierId: result.supplierId,
        totalAmount: result.totalAmount,
        status: "pending_supplier_acceptance",
        message: "Order request sent to supplier.",
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      console.error(
        "requestProcurementOrder failed:",
        error
      );

      throw new HttpsError(
        "internal",
        "Unable to create the order. Check function logs."
      );
    }
  }
);
