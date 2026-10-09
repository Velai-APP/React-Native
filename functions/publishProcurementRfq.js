
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

exports.publishProcurementRfq = onCall(
  {
    region: 'us-central1',
    enforceAppCheck: false,
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError('unauthenticated', 'Please sign in.');
    }

    const requestId = request.data?.requestId;

    if (
      typeof requestId !== 'string' ||
      !/^[a-zA-Z0-9_-]{1,150}$/.test(requestId)
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Valid requestId is required.'
      );
    }

    const db = getFirestore();
    const requestRef = db.collection('purchaseRequests').doc(requestId);

    const snap = await requestRef.get();

    if (!snap.exists) {
      throw new HttpsError('not-found', 'Purchase request not found.');
    }

    const rfq = snap.data();

    if (rfq.buyerUid !== uid) {
      throw new HttpsError(
        'permission-denied',
        'This is not your purchase request.'
      );
    }

    if (rfq.status !== 'draft') {
      throw new HttpsError(
        'failed-precondition',
        'Only draft requests can be published.'
      );
    }

    const selected = rfq.preferredSupplierIds;

    if (!Array.isArray(selected) || selected.length === 0) {
      throw new HttpsError(
        'failed-precondition',
        'Select at least one preferred supplier.'
      );
    }

    if (
      selected.length > 100 ||
      selected.some(
        id => typeof id !== 'string' || !id || id.includes('/')
      ) ||
      new Set(selected).size !== selected.length
    ) {
      throw new HttpsError(
        'invalid-argument',
        'Invalid supplier selection.'
      );
    }

    if (selected.includes(uid)) {
      throw new HttpsError(
        'failed-precondition',
        'You cannot invite your own supplier account.'
      );
    }

    const supplierRefs = selected.map(id =>
      db.collection('suppliers').doc(id)
    );

    const supplierDocs = await db.getAll(...supplierRefs);

    const rejected = supplierDocs.filter(
      d =>
        !d.exists ||
        d.get('isActive') !== true ||
        d.get('verificationStatus') !== 'approved'
    );

    if (rejected.length) {
      throw new HttpsError(
        'failed-precondition',
        'One or more suppliers are not approved and active.'
      );
    }

    const invitationRefs = selected.map(id =>
      db.collection('rfqInvitations').doc(`${requestId}_${id}`)
    );

    try {
      await db.runTransaction(async tx => {
        const [latest, ...all] = await Promise.all([
          tx.get(requestRef),
          ...supplierRefs.map(ref => tx.get(ref)),
          ...invitationRefs.map(ref => tx.get(ref)),
        ]);

        const latestData = latest.data();

        if (
          !latest.exists ||
          latestData.buyerUid !== uid ||
          latestData.status !== 'draft'
        ) {
          throw new HttpsError(
            'failed-precondition',
            'Request changed. Refresh and try again.'
          );
        }

        const currentSelected = latestData.preferredSupplierIds;

        if (
          !Array.isArray(currentSelected) ||
          currentSelected.length !== selected.length ||
          !selected.every(id => currentSelected.includes(id))
        ) {
          throw new HttpsError(
            'failed-precondition',
            'Supplier selection changed. Refresh and retry.'
          );
        }

        for (let i = 0; i < selected.length; i++) {
          const supplier = all[i];

          if (
            !supplier.exists ||
            supplier.get('isActive') !== true ||
            supplier.get('verificationStatus') !== 'approved'
          ) {
            throw new HttpsError(
              'failed-precondition',
              'A selected supplier is not approved or active.'
            );
          }

          if (all[selected.length + i].exists) {
            throw new HttpsError(
              'already-exists',
              'An invitation already exists.'
            );
          }
        }

        selected.forEach((id, i) => {
          tx.create(invitationRefs[i], {
            requestId: requestId,
            buyerUid: uid,
            supplierId: id,
            status: 'sent',
            invitedAt: FieldValue.serverTimestamp(),
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        });

        tx.update(requestRef, {
          status: 'published',
          invitedSupplierIds: selected,
          publishedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      if (error instanceof HttpsError) throw error;

      console.error('RFQ Publishing Error:', error);

      throw new HttpsError(
        'internal',
        'Could not publish RFQ. Check function logs.'
      );
    }

    return {
      success: true,
      requestId: requestId,
      invitedCount: selected.length,
    };
  }
);
