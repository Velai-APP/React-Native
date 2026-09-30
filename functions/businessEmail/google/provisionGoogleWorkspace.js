import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";

const REGION =
  "asia-south1";

export const provisionGoogleWorkspace =
  onCall(
    {
      region: REGION,
    },

    async (request) => {
      try {
        // -------------------------------------------------
        // 1. Authentication
        // -------------------------------------------------

        if (!request.auth) {
          throw new HttpsError(
            "unauthenticated",
            "Please sign in first."
          );
        }

        const uid =
          request.auth.uid;

        const setupId =
          request.data?.setupId;

        // -------------------------------------------------
        // 2. Validate setupId
        // -------------------------------------------------

        if (
          typeof setupId !== "string" ||
          setupId.trim().length === 0
        ) {
          throw new HttpsError(
            "invalid-argument",
            "setupId is required."
          );
        }

        // -------------------------------------------------
        // 3. Load setup
        // -------------------------------------------------

        const db =
          getFirestore();

        const setupRef =
          db
            .collection(
              "businessEmailSetups"
            )
            .doc(setupId);

        const snapshot =
          await setupRef.get();

        if (!snapshot.exists) {
          throw new HttpsError(
            "not-found",
            "Email setup not found."
          );
        }

        const setup =
          snapshot.data();

        if (!setup) {
          throw new HttpsError(
            "not-found",
            "Email setup data not found."
          );
        }

        // -------------------------------------------------
        // 4. Ownership
        // -------------------------------------------------

        if (setup.uid !== uid) {
          throw new HttpsError(
            "permission-denied",
            "You cannot access this email setup."
          );
        }

        // -------------------------------------------------
        // 5. Provider
        // -------------------------------------------------

        if (
          setup.provider !== "google"
        ) {
          throw new HttpsError(
            "failed-precondition",
            "This is not a Google Workspace setup."
          );
        }

        // -------------------------------------------------
        // 6. Connection status
        // -------------------------------------------------

        if (
          setup.status !==
          "google_connected"
        ) {
          throw new HttpsError(
            "failed-precondition",
            "Google Workspace has not been connected yet."
          );
        }

        // -------------------------------------------------
        // 7. Email configuration
        // -------------------------------------------------

        const emails =
          setup.emails ?? [];

        if (
          !Array.isArray(emails) ||
          emails.length === 0
        ) {
          throw new HttpsError(
            "failed-precondition",
            "No email addresses were configured."
          );
        }

        const mailboxes =
          emails.filter(
            (item) =>
              item.type === "mailbox"
          );

        const aliases =
          emails.filter(
            (item) =>
              item.type === "alias"
          );

        const groups =
          emails.filter(
            (item) =>
              item.type === "group"
          );

        console.log(
          "Workspace provisioning started:",
          {
            setupId,
            uid,
            domain:
              setup.domain,

            mailboxCount:
              mailboxes.length,

            aliasCount:
              aliases.length,

            groupCount:
              groups.length,
          }
        );

        // -------------------------------------------------
        // 8. Mark provisioning
        // -------------------------------------------------

        await setupRef.update({
          status:
            "provisioning",

          provisioningStartedAt:
            FieldValue.serverTimestamp(),

          updatedAt:
            FieldValue.serverTimestamp(),
        });

        // -------------------------------------------------
        // IMPORTANT
        // -------------------------------------------------
        //
        // This function DOES NOT create Google users yet.
        //
        // We need encrypted refresh-token persistence
        // before calling Directory API here.
        //
        // -------------------------------------------------

        return {
          success: true,

          setupId,

          domain:
            setup.domain,

          counts: {
            mailboxes:
              mailboxes.length,

            aliases:
              aliases.length,

            groups:
              groups.length,
          },

          status:
            "provisioning",
        };
      } catch (error) {
        console.error(
          "provisionGoogleWorkspace FAILED:",
          error
        );

        if (
          error instanceof HttpsError
        ) {
          throw error;
        }

        throw new HttpsError(
          "internal",
          error instanceof Error
            ? error.message
            : "Unable to provision Google Workspace."
        );
      }
    }
  );