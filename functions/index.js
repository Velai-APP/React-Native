const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");
const axios = require("axios");
const archiver = require("archiver");
const { PassThrough } = require("stream");
const {
  generateBrandIdentity,
} = require("./generate_brand_identity");

const { analyseEntrepreneurProfile } = require("./generate_ai_analysis");

if (!admin.apps.length) {
  admin.initializeApp();
}

const openAiApiKey = defineSecret("OPENAI_API_KEY");
const netlifyAccessToken = defineSecret("NETLIFY_ACCESS_TOKEN");

exports.startWebsiteGeneration = onCall(
  {
    region: "asia-south1",
    timeoutSeconds: 300,
    memory: "1GiB",
    secrets: [
      openAiApiKey,
      netlifyAccessToken,
    ],
  },
  async (request) => {
    try {
      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Please sign in before creating a website.",
        );
      }

      const data = request.data || {};

      const businessName = cleanText(data.businessName);
      const businessType = cleanText(data.businessType);
      const description = cleanText(data.description);
      const services = cleanText(data.services);
      const phone = cleanText(data.phone);
      const email = cleanText(data.email);
      const address = cleanText(data.address);
      const preferredSiteName = cleanText(data.preferredSiteName);
      const primaryColor = cleanText(data.primaryColor) || "#6C4DFF";
      const tone = cleanText(data.tone) || "Professional";
      const template = cleanText(data.template) || "Modern";
      const about = String(data.about || "").trim();
      const alternatePhone =
        String(data.alternatePhone || "").trim();
      const whatsapp = String(data.whatsapp || "").trim();
      const workingHours =
        String(data.workingHours || "").trim();
      const facebook = String(data.facebook || "").trim();
      const instagram = String(data.instagram || "").trim();
      const googleMaps = String(data.googleMaps || "").trim();
      const ctaText = String(data.ctaText || "").trim();

      if (!businessName || !businessType || !description) {
        throw new HttpsError(
          "invalid-argument",
          "Business name, business type and description are required.",
        );
      }

      const openai = new OpenAI({
        apiKey: openAiApiKey.value(),
      });

 const websitePrompt = `
Create a professional responsive business website.

BUSINESS DETAILS
Business name: ${businessName}
Business category: ${businessType}
Short description: ${description}
About business: ${about}
Products and services: ${services}

CONTACT INFORMATION
Primary phone: ${phone}
Alternate phone: ${alternatePhone}
WhatsApp: ${whatsapp}
Email: ${email}
Address: ${address}

BUSINESS INFORMATION
Working hours: ${workingHours}
Google Maps link: ${googleMaps}
Instagram: ${instagram}
Facebook: ${facebook}
Preferred call-to-action: ${ctaText}

DESIGN
Template: ${template}
Tone: ${tone}
Primary colour: ${primaryColor}

Create:
- Header with phone and email
- Hero section with call-to-action
- About section
- Services section
- WhatsApp contact button when available
- Contact section
- Clickable phone and email links
- Working-hours section
- Social-media links
- Google Maps button when supplied
- Responsive mobile design
- Footer with full contact details

Return valid JSON only:
{
  "indexHtml": "complete HTML",
  "styleCss": "complete CSS",
  "scriptJs": "complete JavaScript"
}
`;
      const aiResponse = await openai.responses.create({
        model: "gpt-5",
        input: websitePrompt,
      });

      const rawOutput = aiResponse.output_text;

      if (!rawOutput) {
        throw new HttpsError(
          "internal",
          "OpenAI did not return website content.",
        );
      }

      const websiteFiles = parseWebsiteJson(rawOutput);

      validateWebsiteFiles(websiteFiles);

      const zipBuffer = await createWebsiteZip({
        "index.html": websiteFiles.indexHtml,
        "style.css": websiteFiles.styleCss,
        "script.js": websiteFiles.scriptJs,
      });

      const site = await createNetlifySite({
        token: netlifyAccessToken.value(),
        requestedName: preferredSiteName || businessName,
      });

      const deploy = await deployZipToNetlify({
        token: netlifyAccessToken.value(),
        siteId: site.id,
        zipBuffer,
      });

      const liveUrl =
        deploy.ssl_url ||
        deploy.url ||
        site.ssl_url ||
        site.url;

      if (!liveUrl) {
        throw new HttpsError(
          "internal",
          "Netlify deployed the website but returned no website URL.",
        );
      }

      const websiteDocument = {
        userId: request.auth.uid,
        businessName,
        businessType,
        description,
        services,
        phone,
        email,
        address,
        preferredSiteName,
        primaryColor,
        tone,
        template,
        netlifySiteId: site.id,
        netlifySiteName: site.name,
        netlifyDeployId: deploy.id,
        netlifyUrl: liveUrl,
        customDomain: null,
        domainStatus: "not_connected",
        deploymentStatus: deploy.state || "uploaded",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      const documentReference = await admin
        .firestore()
        .collection("websites")
        .add(websiteDocument);

      return {
        success: true,
        websiteId: documentReference.id,
        siteId: site.id,
        siteName: site.name,
        url: liveUrl,
        status: deploy.state || "uploaded",
      };
    } catch (error) {
      console.error("Website generation failed:", error);

      if (error instanceof HttpsError) {
        throw error;
      }

      const message =
        error?.response?.data?.message ||
        error?.message ||
        "Website generation failed.";

      throw new HttpsError("internal", message);
    }
  },
);

function cleanText(value) {
  if (typeof value !== "string") {
    return "";
  }

  return value.trim().substring(0, 5000);
}

function parseWebsiteJson(rawOutput) {
  const cleanedOutput = rawOutput
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```$/i, "")
    .trim();

  try {
    return JSON.parse(cleanedOutput);
  } catch (error) {
    console.error("Invalid AI JSON:", cleanedOutput);
    throw new HttpsError(
      "internal",
      "The generated website format was invalid. Please generate again.",
    );
  }
}

function validateWebsiteFiles(files) {
  if (!files || typeof files !== "object") {
    throw new HttpsError(
      "internal",
      "No website files were generated.",
    );
  }

  if (
    typeof files.indexHtml !== "string" ||
    typeof files.styleCss !== "string" ||
    typeof files.scriptJs !== "string"
  ) {
    throw new HttpsError(
      "internal",
      "The generated website files are incomplete.",
    );
  }

  if (!files.indexHtml.toLowerCase().includes("<html")) {
    throw new HttpsError(
      "internal",
      "The generated HTML file is invalid.",
    );
  }
}

async function createWebsiteZip(files) {
  return new Promise((resolve, reject) => {
    const archive = archiver("zip", {
      zlib: {
        level: 9,
      },
    });

    const output = new PassThrough();
    const chunks = [];

    output.on("data", (chunk) => {
      chunks.push(chunk);
    });

    output.on("end", () => {
      resolve(Buffer.concat(chunks));
    });

    output.on("error", reject);
    archive.on("error", reject);

    archive.pipe(output);

    Object.entries(files).forEach(([fileName, content]) => {
      archive.append(content, {
        name: fileName,
      });
    });

    archive.finalize();
  });
}

async function createNetlifySite({
  token,
  requestedName,
}) {
  const safeSiteName = sanitizeSiteName(requestedName);

  try {
    const response = await axios.post(
      "https://api.netlify.com/api/v1/sites",
      safeSiteName
        ? {
            name: safeSiteName,
          }
        : {},
      {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        timeout: 60000,
      },
    );

    return response.data;
  } catch (error) {
    /*
     * The requested site name may already be taken.
     * Retry without specifying a name so Netlify generates one.
     */
    if (error.response?.status === 422) {
      const retryResponse = await axios.post(
        "https://api.netlify.com/api/v1/sites",
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
          timeout: 60000,
        },
      );

      return retryResponse.data;
    }

    throw error;
  }
}

async function deployZipToNetlify({
  token,
  siteId,
  zipBuffer,
}) {
  const response = await axios.post(
    `https://api.netlify.com/api/v1/sites/${siteId}/deploys`,
    zipBuffer,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/zip",
      },
      maxBodyLength: Infinity,
      maxContentLength: Infinity,
      timeout: 120000,
    },
  );

  return response.data;
}

function sanitizeSiteName(value) {
  if (!value) {
    return "";
  }

  return value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .substring(0, 63);
}


exports.generateBrandIdentity =
    generateBrandIdentity;

exports.analyseEntrepreneurProfile = analyseEntrepreneurProfile;


exports.generateSop = onCall(
  {
    region: "asia-south1",
    secrets: [openAiApiKey],
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Please sign in before generating an SOP.",
      );
    }

    const data = request.data;

    const requiredFields = [
      "title",
      "company",
      "department",
      "purpose",
      "processDescription",
      "responsiblePersons",
      "frequency",
    ];

    for (const field of requiredFields) {
      if (
        !data[field] ||
        data[field].toString().trim().length === 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          `${field} is required.`,
        );
      }
    }

    const openai = new OpenAI({
      apiKey: openAiApiKey.value(),
    });

    const response = await openai.responses.create({
      model: "gpt-5-mini",

      input: [
        {
          role: "system",
          content: `
You are an expert Standard Operating Procedure writer.

Create a professional business SOP based strictly on the information supplied.

The SOP must be practical, implementation-ready, clear and suitable for use inside an Indian business organisation.

Do not invent laws, approvals, roles or business facts that were not provided.

Where suitable, improve the process structure and internal control wording.

Return ONLY valid JSON.

Use exactly this JSON structure:

{
  "sopTitle": "",
  "sopNumber": "",
  "version": "1.0",
  "department": "",
  "organisation": "",
  "purpose": "",
  "scope": "",
  "definitions": [],
  "responsibilities": [
    {
      "role": "",
      "responsibility": ""
    }
  ],
  "procedure": [
    {
      "stepNumber": "1",
      "title": "",
      "description": "",
      "responsibleRole": "",
      "control": ""
    }
  ],
  "internalControls": [],
  "documentsAndRecords": [],
  "exceptions": [],
  "escalationMatrix": [
    {
      "issue": "",
      "escalateTo": "",
      "timeline": ""
    }
  ],
  "frequency": "",
  "reviewFrequency": "",
  "preparedBy": "",
  "reviewedBy": "",
  "approvedBy": ""
}
          `,
        },
        {
          role: "user",
          content: `
Prepare an SOP using the following information.

SOP Title:
${data.title}

Organisation:
${data.company}

Department:
${data.department}

Purpose:
${data.purpose}

Existing Process:
${data.processDescription}

Responsible Persons:
${data.responsiblePersons}

Approval Flow:
${data.approvalFlow || "Not specified"}

Process Frequency:
${data.frequency}

Documents / Records:
${data.documents || "Not specified"}

Controls / Checks:
${data.controls || "Not specified"}

Additional Instructions:
${data.additionalInstructions || "None"}

Requirements:
- Keep the SOP practical and professional.
- Break the procedure into sequential numbered steps.
- Clearly state responsibility at each major step.
- Include maker-checker or approval controls only where supported by the supplied information.
- Include records and controls supplied by the user.
- Keep unsupported details blank or state "Not specified".
          `,
        },
      ],
    });

    const raw = response.output_text;

    if (!raw || raw.trim().length === 0) {
      throw new HttpsError(
        "internal",
        "AI returned an empty response.",
      );
    }

    try {
      const parsed = JSON.parse(raw);

      return {
        success: true,
        sop: parsed,
      };
    } catch (error) {
      console.error("Invalid JSON from OpenAI:", raw);

      throw new HttpsError(
        "internal",
        "Unable to process the generated SOP.",
      );
    }
  },
);

const {
  generateCompetitorAnalysis,
} = require("./generateCompetitorAnalysis");

exports.generateCompetitorAnalysis =
generateCompetitorAnalysis;


const businessEmail =
require("./generateBusinessEmails");
exports.generateBusinessEmails =
businessEmail.generateBusinessEmails;

const {
  startGoogleWorkspaceSetup,
} = require(
  "./businessEmail/google/startGoogleWorkspaceSetup.js"
);

const {
  googleWorkspaceOAuthCallback,
} = require(
  "./businessEmail/google/googleOAuthCallback.js"
);

const {
  provisionGoogleWorkspace,
} = require(
  "./businessEmail/google/provisionGoogleWorkspace.js"
);

const { respondToProcurementOrder } = require(
  "./respond_to_procurement_order.js"
);

const { issueProcurementInvoice } = require(
  "./issue_procurement_invoice.js"
);

const { submitProcurementPayment } = require(
  "./submit_procurement_payment.js"
);

const paymentVerification =
  require("./verify_procurement_payment");

const {publishProcurementRfq} = require(
  "./publishProcurementRfq.js"
);

const {requestProcurementOrder} = require(
  "./requestProcurementOrder.js"
);

const {submitProcurementFulfilment} = require(
  "./submitProcurementFulfilment.js"
);

const { confirmProcurementDelivery} = require(
  "./confirmProcurementDelivery.js"
);

exports.confirmProcurementDelivery =
  confirmProcurementDelivery;

exports.submitProcurementFulfilment = submitProcurementFulfilment;

exports.requestProcurementOrder =
  requestProcurementOrder;

exports.publishProcurementRfq =
  publishProcurementRfq;

exports.verifyProcurementPayment =
  paymentVerification.verifyProcurementPayment;

exports.getProcurementPaymentProof =
  paymentVerification.getProcurementPaymentProof;

exports.submitProcurementPayment =
  submitProcurementPayment;

exports.issueProcurementInvoice =
  issueProcurementInvoice;

exports.respondToProcurementOrder =
  respondToProcurementOrder;

exports.startGoogleWorkspaceSetup =
  startGoogleWorkspaceSetup;

exports.googleWorkspaceOAuthCallback =
  googleWorkspaceOAuthCallback;

exports.provisionGoogleWorkspace =
  provisionGoogleWorkspace;
