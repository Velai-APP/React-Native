
const { onCall, HttpsError } =
  require("firebase-functions/v2/https");

const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const stamp = () =>
  admin.firestore.FieldValue.serverTimestamp();

const money = (n) =>
  Math.round((Number(n) + Number.EPSILON) * 100) / 100;

const validText = (v, max = 250) =>
  typeof v === "string" &&
  v.trim().length > 0 &&
  v.trim().length <= max;

const optionalText = (v, max = 250) =>
  typeof v === "string" && v.length <= max;

exports.issueProcurementInvoice = onCall(
  {
    region: "us-central1",
    maxInstances: 10,
  },
  async (req) => {
    const uid = req.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in first."
      );
    }

    const p = req.data || {};

    if (
      !validText(p.orderId, 150) ||
      p.orderId.includes("/")
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid order ID."
      );
    }

    // Validate invoice fields
    for (const k of [
      "invoiceNumber",
      "sellerName",
      "sellerAddress",
      "buyerName",
      "buyerAddress",
    ]) {
      if (
        !validText(
          p[k],
          k.endsWith("Address") ? 500 : 150
        )
      ) {
        throw new HttpsError(
          "invalid-argument",
          `Enter valid ${k}.`
        );
      }
    }

    for (const k of [
      "sellerGstin",
      "buyerGstin",
      "sellerTaxId",
      "paymentInstructions",
      "notes",
    ]) {
      if (
        !optionalText(
          p[k] ?? "",
          k === "paymentInstructions" ||
          k === "notes"
            ? 1000
            : 50
        )
      ) {
        throw new HttpsError(
          "invalid-argument",
          `Invalid ${k}.`
        );
      }
    }

    const orderRef = db
      .collection("orders")
      .doc(p.orderId);

    const invoiceRef = db
      .collection("invoices")
      .doc(p.orderId);

    // Secure Firestore transaction
    const result = await db.runTransaction(
      async (tx) => {
        const orderSnap = await tx.get(orderRef);
        const existingInvoice =
          await tx.get(invoiceRef);

        if (!orderSnap.exists) {
          throw new HttpsError(
            "not-found",
            "Order not found."
          );
        }

        const order = orderSnap.data();

        // Verify supplier
        if (order.supplierId !== uid) {
          throw new HttpsError(
            "permission-denied",
            "Only the selected supplier can issue this invoice."
          );
        }

        // Prevent duplicate invoices
        if (existingInvoice.exists) {
          if (
            existingInvoice.data().supplierId !== uid
          ) {
            throw new HttpsError(
              "permission-denied",
              "Not your invoice."
            );
          }

          return {
            invoiceId: invoiceRef.id,
            alreadyIssued: true,
          };
        }

        // Order must be accepted
        if (order.status !== "order_accepted") {
          throw new HttpsError(
            "failed-precondition",
            "Supplier must accept the order before invoicing."
          );
        }

        if (
          !validText(order.quotationId, 150) ||
          !validText(order.buyerUid, 150) ||
          !validText(order.requestId, 150)
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Order references are incomplete."
          );
        }

        // Fetch original supplier quotation
        const quoteSnap = await tx.get(
          db.collection("quotations")
            .doc(order.quotationId)
        );

        if (!quoteSnap.exists) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation missing."
          );
        }

        const q = quoteSnap.data();

        // Validate quotation ownership
        if (
          q.status !== "submitted" ||
          q.supplierId !== uid ||
          q.buyerUid !== order.buyerUid ||
          q.requestId !== order.requestId
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation does not match the accepted order."
          );
        }

        // Validate quotation line items
        if (
          !Array.isArray(q.lineItems) ||
          q.lineItems.length === 0 ||
          q.lineItems.length > 100
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation line items are invalid."
          );
        }

        const items = q.lineItems.map((l) => ({
          description: String(
            l.description || ""
          ),
          specifications: String(
            l.specifications || ""
          ),
          quantity: Number(l.quantity),
          unit: String(l.unit || "Nos"),
          unitPrice: money(l.unitPrice),
          amount: money(l.amount),
        }));

        if (
          items.some(
            (l) =>
              !validText(l.description, 500) ||
              !Number.isFinite(l.quantity) ||
              l.quantity <= 0 ||
              !Number.isFinite(l.unitPrice) ||
              l.unitPrice < 0 ||
              !Number.isFinite(l.amount) ||
              Math.abs(
                money(l.quantity * l.unitPrice) -
                  l.amount
              ) > 0.01
          )
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation has inconsistent item amounts."
          );
        }

        // Calculate totals
        const subtotal = money(
          items.reduce(
            (sum, item) => sum + item.amount,
            0
          )
        );

        const gstRate = Number(q.gstRate || 0);
        const freight = money(q.freight || 0);

        if (
          !Number.isFinite(gstRate) ||
          gstRate < 0 ||
          gstRate > 100 ||
          !Number.isFinite(freight) ||
          freight < 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Invalid quotation taxes or freight."
          );
        }

        const taxAmount = money(
          (subtotal * gstRate) / 100
        );

        const totalAmount = money(
          subtotal + taxAmount + freight
        );

        if (
          Math.abs(
            totalAmount - Number(q.grandTotal)
          ) > 0.02 ||
          Math.abs(
            totalAmount - Number(order.totalAmount)
          ) > 0.02
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Quotation and order totals disagree."
          );
        }

        // Create invoice
        tx.create(invoiceRef, {
          orderId: p.orderId,
          buyerUid: order.buyerUid,
          supplierId: uid,
          requestId: order.requestId,
          quotationId: order.quotationId,

          invoiceNumber: p.invoiceNumber.trim(),

          sellerName: p.sellerName.trim(),
          sellerAddress: p.sellerAddress.trim(),

          sellerGstin: (
            p.sellerGstin || ""
          ).trim().toUpperCase(),

          sellerTaxId: (
            p.sellerTaxId || ""
          ).trim(),

          buyerName: p.buyerName.trim(),
          buyerAddress: p.buyerAddress.trim(),

          buyerGstin: (
            p.buyerGstin || ""
          ).trim().toUpperCase(),

          paymentInstructions: (
            p.paymentInstructions || ""
          ).trim(),

          notes: (
            p.notes || ""
          ).trim(),

          lineItems: items,
          currency: "INR",

          subtotal,
          gstRate,
          taxAmount,
          freight,
          totalAmount,

          status: "issued",
          issuedAt: stamp(),
          createdAt: stamp(),
        });

        // Update order
        tx.update(orderRef, {
          status: "invoice_issued",
          invoiceId: invoiceRef.id,
          updatedAt: stamp(),
        });

        // Audit log
        tx.create(
          db.collection("auditLogs").doc(),
          {
            entityType: "invoice",
            entityId: invoiceRef.id,
            orderId: p.orderId,

            actorUid: uid,
            buyerUid: order.buyerUid,
            supplierId: uid,

            action: "invoice_issued",
            createdAt: stamp(),
          }
        );

        return {
          invoiceId: invoiceRef.id,
          alreadyIssued: false,
        };
      }
    );

    return result;
  }
);
