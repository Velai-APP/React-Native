import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  defineSecret,
} from "firebase-functions/params";

import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";

import {
  google,
} from "googleapis";

import crypto from "crypto";

const GOOGLE_CLIENT_ID = defineSecret(
  "GOOGLE_WORKSPACE_CLIENT_ID"
);

const GOOGLE_CLIENT_SECRET = defineSecret(
  "GOOGLE_WORKSPACE_CLIENT_SECRET"
);

const REGION = "asia-south1";

export const startGoogleWorkspaceSetup = onCall(
  {
    region: REGION,

    secrets: [
      GOOGLE_CLIENT_ID,
      GOOGLE_CLIENT_SECRET,
    ],
  },

  async (request) => {
    try {
      // ---------------------------------------------------
      // 1. Firebase Authentication
      // ---------------------------------------------------

      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Please sign in to Velai first."
        );
      }

      const uid = request.auth.uid;

      // ---------------------------------------------------
      // 2. Read request
      // ---------------------------------------------------

      const businessName =
        request.data?.businessName;

      const rawDomain =
        request.data?.domain;

      const provider =
        request.data?.provider;

      const emails =
        request.data?.emails;

      // ---------------------------------------------------
      // 3. Validate business name
      // ---------------------------------------------------

      if (
        typeof businessName !== "string" ||
        businessName.trim().length === 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Business name is required."
        );
      }

      // ---------------------------------------------------
      // 4. Validate domain
      // ---------------------------------------------------

      if (
        typeof rawDomain !== "string" ||
        rawDomain.trim().length === 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Domain is required."
        );
      }

      const domain = rawDomain
        .trim()
        .toLowerCase();

      // ---------------------------------------------------
      // 5. Validate provider
      // ---------------------------------------------------

      if (
        provider &&
        String(provider)
          .toLowerCase()
          .includes("google") === false
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Invalid email provider."
        );
      }

      // ---------------------------------------------------
      // 6. Validate emails
      // ---------------------------------------------------

      if (
        !Array.isArray(emails) ||
        emails.length === 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          "At least one email address is required."
        );
      }

      const allowedTypes = [
        "mailbox",
        "alias",
        "group",
      ];

      for (const item of emails) {
        if (
          !item ||
          typeof item.email !== "string" ||
          item.email.trim().length === 0
        ) {
          throw new HttpsError(
            "invalid-argument",
            "Invalid email configuration."
          );
        }

        if (!allowedTypes.includes(item.type)) {
          throw new HttpsError(
            "invalid-argument",
            `Invalid email type for ${item.email}.`
          );
        }
      }

      // ---------------------------------------------------
      // 7. Generate setup ID + OAuth state
      // ---------------------------------------------------

      const db = getFirestore();

      const setupRef = db
        .collection("businessEmailSetups")
        .doc();

      const setupId = setupRef.id;

      const oauthState =
        crypto.randomBytes(32).toString("hex");

      // ---------------------------------------------------
      // 8. Save setup
      // ---------------------------------------------------

      await setupRef.set({
        uid,

        businessName:
          businessName.trim(),

        domain,

        provider: "google",

        emails,

        status:
          "awaiting_google_authorization",

        oauthState,

        createdAt:
          FieldValue.serverTimestamp(),

        updatedAt:
          FieldValue.serverTimestamp(),
      });

      // ---------------------------------------------------
      // 9. Build OAuth callback URL
      // ---------------------------------------------------

      const projectId =
        process.env.GCLOUD_PROJECT ||
        process.env.GOOGLE_CLOUD_PROJECT;

      if (!projectId) {
        throw new Error(
          "Google Cloud project ID is unavailable."
        );
      }

      const redirectUri =
        `https://${REGION}-${projectId}` +
        ".cloudfunctions.net/" +
        "googleWorkspaceOAuthCallback";

      console.log(
        "Workspace OAuth redirect URI:",
        redirectUri
      );

      // ---------------------------------------------------
      // 10. Create OAuth client
      // ---------------------------------------------------

      const oauth2Client =
        new google.auth.OAuth2(
          GOOGLE_CLIENT_ID.value(),
          GOOGLE_CLIENT_SECRET.value(),
          redirectUri
        );

      // ---------------------------------------------------
      // 11. Generate authorization URL
      // ---------------------------------------------------

      const authorizationUrl =
        oauth2Client.generateAuthUrl({
          access_type: "offline",

          prompt: "consent",

          state:
            `${setupId}.${oauthState}`,

          scope: [
            "https://www.googleapis.com/auth/admin.directory.user",
            "https://www.googleapis.com/auth/admin.directory.group",
            "https://www.googleapis.com/auth/admin.directory.domain.readonly",
          ],
        });

      console.log(
        "Google Workspace setup created:",
        {
          setupId,
          uid,
          domain,
          emailCount: emails.length,
        }
      );

      // ---------------------------------------------------
      // 12. Return to Flutter
      // ---------------------------------------------------

      return {
        success: true,
        setupId,
        authorizationUrl,
      };
    } catch (error) {
      console.error(
        "startGoogleWorkspaceSetup FAILED:",
        error
      );

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        error instanceof Error
          ? error.message
          : "Unable to start Google Workspace setup."
      );
    }
  }
);