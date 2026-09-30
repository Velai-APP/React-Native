import {
  onRequest,
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

const GOOGLE_CLIENT_ID = defineSecret(
  "GOOGLE_WORKSPACE_CLIENT_ID"
);

const GOOGLE_CLIENT_SECRET = defineSecret(
  "GOOGLE_WORKSPACE_CLIENT_SECRET"
);

const REGION = "asia-south1";

export const googleWorkspaceOAuthCallback =
  onRequest(
    {
      region: REGION,

      secrets: [
        GOOGLE_CLIENT_ID,
        GOOGLE_CLIENT_SECRET,
      ],
    },

    async (req, res) => {
      try {
        // -------------------------------------------------
        // 1. Check OAuth errors
        // -------------------------------------------------

        const oauthError =
          req.query.error;

        if (oauthError) {
          console.error(
            "Google OAuth denied:",
            oauthError
          );

          res.status(400).send(
            "Google Workspace authorization was cancelled."
          );

          return;
        }

        // -------------------------------------------------
        // 2. Get code/state
        // -------------------------------------------------

        const rawCode =
          req.query.code;

        const rawState =
          req.query.state;

        const code =
          Array.isArray(rawCode)
            ? rawCode[0]
            : rawCode;

        const stateParam =
          Array.isArray(rawState)
            ? rawState[0]
            : rawState;

        if (
          typeof code !== "string" ||
          typeof stateParam !== "string"
        ) {
          res.status(400).send(
            "Missing authorization information."
          );

          return;
        }

        // -------------------------------------------------
        // 3. Parse state
        // -------------------------------------------------

        const stateParts =
          stateParam.split(".");

        if (stateParts.length !== 2) {
          res.status(400).send(
            "Invalid authorization state."
          );

          return;
        }

        const setupId =
          stateParts[0];

        const state =
          stateParts[1];

        if (!setupId || !state) {
          res.status(400).send(
            "Invalid authorization state."
          );

          return;
        }

        // -------------------------------------------------
        // 4. Load Firestore setup
        // -------------------------------------------------

        const db =
          getFirestore();

        const setupRef =
          db
            .collection(
              "businessEmailSetups"
            )
            .doc(setupId);

        const setupDoc =
          await setupRef.get();

        if (!setupDoc.exists) {
          res.status(404).send(
            "Email setup was not found."
          );

          return;
        }

        const setup =
          setupDoc.data();

        if (!setup) {
          res.status(404).send(
            "Email setup data was not found."
          );

          return;
        }

        // -------------------------------------------------
        // 5. Verify OAuth state
        // -------------------------------------------------

        if (
          setup.oauthState !== state
        ) {
          console.error(
            "OAuth state mismatch:",
            setupId
          );

          res.status(403).send(
            "Authorization state mismatch."
          );

          return;
        }

        // -------------------------------------------------
        // 6. Build EXACT callback URI
        // -------------------------------------------------

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

        // -------------------------------------------------
        // 7. OAuth client
        // -------------------------------------------------

        const oauth2Client =
          new google.auth.OAuth2(
            GOOGLE_CLIENT_ID.value(),
            GOOGLE_CLIENT_SECRET.value(),
            redirectUri
          );

        // -------------------------------------------------
        // 8. Exchange code for credentials
        // -------------------------------------------------

        const tokenResponse =
          await oauth2Client.getToken(
            code
          );

        const tokens =
          tokenResponse.tokens;

        oauth2Client.setCredentials(
          tokens
        );

        console.log(
          "Google token exchange completed:",
          {
            setupId,

            hasAccessToken:
              Boolean(
                tokens.access_token
              ),

            hasRefreshToken:
              Boolean(
                tokens.refresh_token
              ),
          }
        );

        // -------------------------------------------------
        // 9. Google Admin Directory
        // -------------------------------------------------

        const directory =
          google.admin({
            version: "directory_v1",
            auth: oauth2Client,
          });

        // -------------------------------------------------
        // 10. Verify Workspace domain
        // -------------------------------------------------

        const domainsResponse =
          await directory.domains.list({
            customer: "my_customer",
          });

        const domains =
          domainsResponse.data.domains ??
          [];

        const requestedDomain =
          String(setup.domain)
            .trim()
            .toLowerCase();

        const domainFound =
          domains.some(
            (domain) =>
              domain.domainName
                ?.trim()
                .toLowerCase() ===
              requestedDomain
          );

        if (!domainFound) {
          await setupRef.update({
            status:
              "google_domain_not_found",

            updatedAt:
              FieldValue.serverTimestamp(),
          });

          res.status(403).send(
            `The connected Google Workspace ` +
            `account does not manage ` +
            `${requestedDomain}.`
          );

          return;
        }

        // -------------------------------------------------
        // IMPORTANT
        // -------------------------------------------------
        //
        // We intentionally do NOT save refresh_token here
        // yet.
        //
        // Actual mailbox provisioning requires persistent
        // authorization. The refresh token must be stored
        // encrypted/server-side and must never be returned
        // to Flutter.
        //
        // -------------------------------------------------

        // -------------------------------------------------
        // 11. Mark connected
        // -------------------------------------------------

        await setupRef.update({
          status:
            "google_connected",

          oauthState:
            FieldValue.delete(),

          googleConnectedAt:
            FieldValue.serverTimestamp(),

          updatedAt:
            FieldValue.serverTimestamp(),
        });

        // -------------------------------------------------
        // 12. Success HTML
        // -------------------------------------------------

        res.status(200).send(`
<!doctype html>

<html>
<head>

<meta
  name="viewport"
  content="width=device-width, initial-scale=1"
/>

<title>
  Google Workspace Connected
</title>

</head>

<body
  style="
    margin:0;
    background:#f6f7fb;
    font-family:Arial,sans-serif;
  "
>

<div
  style="
    min-height:100vh;
    display:flex;
    align-items:center;
    justify-content:center;
    padding:24px;
    box-sizing:border-box;
  "
>

<div
  style="
    width:100%;
    max-width:480px;
    background:white;
    border-radius:28px;
    padding:44px 32px;
    text-align:center;
    box-sizing:border-box;
    box-shadow:
      0 18px 60px rgba(0,0,0,.08);
  "
>

<div
  style="
    width:72px;
    height:72px;
    margin:0 auto 22px;
    border-radius:50%;
    background:#eaf8ef;
    color:#218a55;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:38px;
    font-weight:bold;
  "
>
✓
</div>

<h2
  style="
    margin:0 0 12px;
    color:#171b2c;
  "
>
Google Workspace connected
</h2>

<p
  style="
    color:#717789;
    line-height:1.6;
  "
>
<strong>
${requestedDomain}
</strong>
has been successfully verified.
</p>

<p
  style="
    color:#717789;
    line-height:1.6;
  "
>
Return to Velai to continue setting up
your business email addresses.
</p>

</div>
</div>

</body>
</html>
        `);
      } catch (error) {
        console.error(
          "Google Workspace OAuth callback FAILED:",
          error
        );

        res.status(500).send(
          "Unable to connect Google Workspace."
        );
      }
    }
  );