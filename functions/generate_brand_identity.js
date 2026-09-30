const admin = require("firebase-admin");


const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");

const {
  defineSecret,
} = require("firebase-functions/params");

const logger = require("firebase-functions/logger");

const OpenAI = require("openai");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

const openAiApiKey = defineSecret("OPENAI_API_KEY");

/**
 * Firebase callable function used by LogoGenerationScreen.
 *
 * Flutter function name:
 * generateBrandIdentity
 *
 * Region:
 * asia-south1
 */
const generateBrandIdentity = onCall(
  {
    region: "asia-south1",
    timeoutSeconds: 540,
    memory: "1GiB",
    secrets: [openAiApiKey],
    enforceAppCheck: false,
    cors: true,
    maxInstances: 10,
  },
  async (request) => {
    const startedAt = Date.now();

    try {
      // ---------------------------------------------------------
      // 1. Authentication
      // ---------------------------------------------------------

      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Please sign in before generating a brand identity.",
        );
      }

      const userId = request.auth.uid;
      const data = request.data || {};

      // ---------------------------------------------------------
      // 2. Read and validate Flutter data
      // ---------------------------------------------------------

      const brandBrief = normalizeBrandBrief(data);

      validateBrandBrief(brandBrief);

      logger.info("Starting brand generation", {
        userId,
        businessName: brandBrief.businessName,
        industry: brandBrief.industry,
      });

      // ---------------------------------------------------------
      // 3. Create project before calling OpenAI
      // ---------------------------------------------------------

      const projectReference =
          db.collection("brandProjects").doc();

      const projectId = projectReference.id;

      await projectReference.set({
        userId,
        projectId,

        businessName: brandBrief.businessName,
        industry: brandBrief.industry,
        businessDescription:
            brandBrief.businessDescription,
        targetAudience: brandBrief.targetAudience,
        originalTagline: brandBrief.tagline,
        website: brandBrief.website,
        isExistingBusiness:
            brandBrief.isExistingBusiness,

        personalities: brandBrief.personalities,
        brandValues: brandBrief.brandValues,
        brandVoice: brandBrief.brandVoice,
        audienceFeeling:
            brandBrief.audienceFeeling,

        logoStyle: brandBrief.logoStyle,
        logoType: brandBrief.logoType,
        colorDirection:
            brandBrief.colorDirection,
        symbolPreference:
            brandBrief.symbolPreference,
        fontStyle: brandBrief.fontStyle,

        status: "generating",
        generationStage: "brand_strategy",

        createdAt:
            admin.firestore.FieldValue.serverTimestamp(),
        updatedAt:
            admin.firestore.FieldValue.serverTimestamp(),
      });

      // ---------------------------------------------------------
      // 4. Initialize OpenAI
      // ---------------------------------------------------------

      const openai = new OpenAI({
        apiKey: openAiApiKey.value(),
      });

      // ---------------------------------------------------------
      // 5. Generate structured brand strategy
      // ---------------------------------------------------------

      const brandStrategy =
          await generateBrandStrategy({
            openai,
            brandBrief,
          });

      await projectReference.set(
        {
          generationStage: "logo_generation",
          brandStrategy,
          updatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
        },
        {
          merge: true,
        },
      );

      // ---------------------------------------------------------
      // 6. Generate four distinct concepts
      // ---------------------------------------------------------

      const promptDirections =
          buildLogoPromptDirections({
            brandBrief,
            brandStrategy,
          });

      /*
       * Sequential generation is deliberately used here.
       * It reduces simultaneous memory use and makes error
       * tracking simpler.
       */
      const logoConcepts = [];

      for (
        let index = 0;
        index < promptDirections.length;
        index += 1
      ) {
        const direction = promptDirections[index];

        await projectReference.set(
          {
            generationStage:
                `generating_logo_${index + 1}`,
            updatedAt:
                admin.firestore.FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        const concept = await generateAndStoreLogo({
          openai,
          projectId,
          userId,
          index,
          direction,
          brandBrief,
        });

        logoConcepts.push(concept);

        await projectReference
            .collection("logos")
            .doc(concept.id)
            .set({
              ...concept,
              userId,
              projectId,
              selected: false,
              createdAt:
                  admin.firestore.FieldValue
                      .serverTimestamp(),
            });
      }

      // ---------------------------------------------------------
      // 7. Save completed project
      // ---------------------------------------------------------

      await projectReference.set(
        {
          status: "completed",
          generationStage: "completed",

          tagline: brandStrategy.tagline,
          brandStrategy,
          logoConcepts,

          generatedLogoCount: logoConcepts.length,

          generationDurationMilliseconds:
              Date.now() - startedAt,

          completedAt:
              admin.firestore.FieldValue.serverTimestamp(),
          updatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
        },
        {
          merge: true,
        },
      );

      logger.info("Brand generation completed", {
        userId,
        projectId,
        logoCount: logoConcepts.length,
        durationMilliseconds:
            Date.now() - startedAt,
      });

      // ---------------------------------------------------------
      // 8. Return the exact response expected by Flutter
      // ---------------------------------------------------------

      return {
        success: true,
        projectId,

        tagline: brandStrategy.tagline,

        brandStrategy: {
          brandSummary:
              brandStrategy.brandSummary,

          tagline: brandStrategy.tagline,

          missionStatement:
              brandStrategy.missionStatement,

          positioningStatement:
              brandStrategy.positioningStatement,

          toneOfVoice:
              brandStrategy.toneOfVoice,

          primaryColor:
              brandStrategy.primaryColor,

          secondaryColor:
              brandStrategy.secondaryColor,

          accentColor:
              brandStrategy.accentColor,

          backgroundColor:
              brandStrategy.backgroundColor,

          headingFont:
              brandStrategy.headingFont,

          bodyFont:
              brandStrategy.bodyFont,

          typographyReason:
              brandStrategy.typographyReason,

          logoRationale:
              brandStrategy.logoRationale,

          keywords:
              brandStrategy.keywords,
          visitingCardStyle:
    brandStrategy.visitingCardStyle,

visitingCardFrontPrompt:
    brandStrategy.visitingCardFrontPrompt,

visitingCardBackPrompt:
    brandStrategy.visitingCardBackPrompt, 
        },

        logoConcepts,
      };
    } catch (error) {
      logger.error(
        "generateBrandIdentity failed",
        {
          error:
              error instanceof Error
                  ? error.message
                  : String(error),

          stack:
              error instanceof Error
                  ? error.stack
                  : null,
        },
      );

      if (error instanceof HttpsError) {
        throw error;
      }

      if (
        error &&
        typeof error === "object" &&
        error.status === 429
      ) {
        throw new HttpsError(
          "resource-exhausted",
          "The AI generation service is busy. Please try again shortly.",
        );
      }

      if (
        error &&
        typeof error === "object" &&
        error.status === 401
      ) {
        throw new HttpsError(
          "internal",
          "The OpenAI API key is missing or invalid.",
        );
      }

      if (
        error &&
        typeof error === "object" &&
        (
          error.code === "content_policy_violation" ||
          error.code === "moderation_blocked"
        )
      ) {
        throw new HttpsError(
          "invalid-argument",
          "The submitted brand information could not be used for image generation.",
        );
      }

      throw new HttpsError(
        "internal",
        error instanceof Error
            ? error.message
            : "Unable to generate the brand identity.",
      );
    }
  },
);

/**
 * Convert client data into a safe, predictable object.
 */
function normalizeBrandBrief(data) {
  return {
    businessName:
        cleanString(data.businessName, 80),

    industry:
        cleanString(data.industry, 100),

    businessDescription:
        cleanString(
          data.businessDescription,
          1200,
        ),

    targetAudience:
        cleanString(data.targetAudience, 600),

    tagline:
        cleanString(data.tagline, 140),

    website:
        cleanString(data.website, 300),

    isExistingBusiness:
        data.isExistingBusiness === true,

    personalities:
        cleanStringArray(
          data.personalities,
          6,
          40,
        ),

    brandValues:
        cleanStringArray(
          data.brandValues,
          6,
          40,
        ),

    brandVoice:
        cleanString(data.brandVoice, 80),

    audienceFeeling:
        cleanString(data.audienceFeeling, 80),

    logoStyle:
        cleanString(data.logoStyle, 80),

    logoType:
        cleanString(data.logoType, 80),

    colorDirection:
        cleanString(data.colorDirection, 100),

    symbolPreference:
        cleanString(data.symbolPreference, 100),

    fontStyle:
        cleanString(data.fontStyle, 100),
  };
}

function validateBrandBrief(brief) {
  const requiredFields = [
    ["businessName", brief.businessName],
    ["industry", brief.industry],
    [
      "businessDescription",
      brief.businessDescription,
    ],
    ["targetAudience", brief.targetAudience],
    ["brandVoice", brief.brandVoice],
    ["audienceFeeling", brief.audienceFeeling],
    ["logoStyle", brief.logoStyle],
    ["logoType", brief.logoType],
    ["colorDirection", brief.colorDirection],
    [
      "symbolPreference",
      brief.symbolPreference,
    ],
    ["fontStyle", brief.fontStyle],
  ];

  for (const [fieldName, value] of requiredFields) {
    if (!value) {
      throw new HttpsError(
        "invalid-argument",
        `${fieldName} is required.`,
      );
    }
  }

  if (brief.businessName.length < 2) {
    throw new HttpsError(
      "invalid-argument",
      "The business name is too short.",
    );
  }

  if (brief.businessDescription.length < 20) {
    throw new HttpsError(
      "invalid-argument",
      "Please provide a more detailed business description.",
    );
  }

  if (brief.personalities.length < 2) {
    throw new HttpsError(
      "invalid-argument",
      "Select at least two brand personality traits.",
    );
  }

  if (brief.brandValues.length < 2) {
    throw new HttpsError(
      "invalid-argument",
      "Select at least two brand values.",
    );
  }
}

/**
 * Generate strategy as schema-constrained JSON.
 */
async function generateBrandStrategy({
  openai,
  brandBrief,
}) {
  const response = await openai.responses.create({
    model: "gpt-5-mini",

instructions: `
You are a senior brand strategist.

Create a commercially usable brand strategy for a real
business. Keep the output clear, practical and concise.

Do not claim trademark availability.
Do not claim legal ownership.
Do not imitate or mention existing brand logos.
Do not use copyrighted characters.
Return only the requested structured output.

Also create a professional visiting-card design direction
that belongs to the same visual identity.

The visiting card must use the same colour palette,
typographic character, brand personality and logo direction.

Create separate design instructions for:

1. Front of visiting card
2. Back of visiting card

The visiting card must feel like an extension of the brand,
not an unrelated template.

Do not invent a person's name, phone number, email address,
physical address or other contact details.

Use placeholders where personal contact information
would normally appear.


VISITING CARD OUTPUT REQUIREMENTS

For visitingCardStyle:

Describe the overall visual system, layout philosophy,
spacing, colour usage and typography.

The description should explain how the visiting card
extends the overall brand identity.


For visitingCardFrontPrompt:

- Create a brand-led front side.
- Feature the logo prominently.
- Include the exact business name.
- Include the tagline only when appropriate.
- Use generous negative space.
- Keep the composition premium and uncluttered.
- Do not include contact information.
- Maintain the same colours, typography and visual
  character as the overall brand identity.


For visitingCardBackPrompt:

- Create a clean professional information layout.
- Reserve areas for PERSON NAME, DESIGNATION, PHONE,
  EMAIL, WEBSITE and ADDRESS.
- Use placeholders only.
- Never invent personal information.
- Maintain excellent readability.
- Use the same colours, typography and visual language
  as the brand identity.


The visiting card should be:

- premium
- modern
- commercially usable
- print-friendly
- flat artwork
- cleanly aligned
- typography-led
- restrained in colour
- free from unnecessary decoration


Do not create:

- fake QR codes
- fake contact details
- hands holding cards
- desk scenes
- photographic backgrounds
- 3D mockups
- perspective mockups


IMPORTANT:

visitingCardStyle must describe the overall design system.

visitingCardFrontPrompt must contain complete instructions
that can later be passed to an image/design generation
system to create the FRONT of the visiting card.

visitingCardBackPrompt must contain complete instructions
that can later be passed to an image/design generation
system to create the BACK of the visiting card.

The front and back must clearly belong to the same
brand identity.
`,

    input: `
BUSINESS NAME:
${brandBrief.businessName}

INDUSTRY:
${brandBrief.industry}

BUSINESS DESCRIPTION:
${brandBrief.businessDescription}

TARGET AUDIENCE:
${brandBrief.targetAudience}

EXISTING TAGLINE:
${brandBrief.tagline || "No existing tagline"}

BUSINESS STATUS:
${
  brandBrief.isExistingBusiness
      ? "Existing business"
      : "New business"
}

BRAND PERSONALITY:
${brandBrief.personalities.join(", ")}

CORE VALUES:
${brandBrief.brandValues.join(", ")}

BRAND VOICE:
${brandBrief.brandVoice}

DESIRED AUDIENCE FEELING:
${brandBrief.audienceFeeling}

VISUAL STYLE:
${brandBrief.logoStyle}

LOGO TYPE:
${brandBrief.logoType}

COLOUR DIRECTION:
${brandBrief.colorDirection}

SYMBOL PREFERENCE:
${brandBrief.symbolPreference}

TYPOGRAPHY PREFERENCE:
${brandBrief.fontStyle}
`,

    text: {
      format: {
        type: "json_schema",
        name: "brand_strategy",
        strict: true,

        schema: {
          type: "object",
          additionalProperties: false,

          properties: {
            brandSummary: {
              type: "string",
            },

            tagline: {
              type: "string",
            },

            missionStatement: {
              type: "string",
            },

            positioningStatement: {
              type: "string",
            },

            toneOfVoice: {
              type: "string",
            },

            primaryColor: {
              type: "string",
              pattern:
                  "^#[0-9A-Fa-f]{6}$",
            },

            secondaryColor: {
              type: "string",
              pattern:
                  "^#[0-9A-Fa-f]{6}$",
            },

            accentColor: {
              type: "string",
              pattern:
                  "^#[0-9A-Fa-f]{6}$",
            },

            backgroundColor: {
              type: "string",
              pattern:
                  "^#[0-9A-Fa-f]{6}$",
            },

            headingFont: {
              type: "string",
            },

            bodyFont: {
              type: "string",
            },

            typographyReason: {
              type: "string",
            },

            logoRationale: {
              type: "string",
            },
            visitingCardStyle: {
  type: "string",
},

visitingCardFrontPrompt: {
  type: "string",
},

visitingCardBackPrompt: {
  type: "string",
},

            keywords: {
              type: "array",
              minItems: 5,
              maxItems: 12,
              items: {
                type: "string",
              },
            },
          },

          required: [
            "brandSummary",
            "tagline",
            "missionStatement",
            "positioningStatement",
            "toneOfVoice",
            "primaryColor",
            "secondaryColor",
            "accentColor",
            "backgroundColor",
            "headingFont",
            "bodyFont",
            "typographyReason",
            "logoRationale",
             "visitingCardStyle",
  "visitingCardFrontPrompt",
  "visitingCardBackPrompt",
            "keywords",
          ],
        },
      },
    },

    max_output_tokens: 4000,
  });

  if (!response.output_text) {
    throw new Error(
      "OpenAI did not return a brand strategy.",
    );
  }

let strategy;

const rawOutput = response.output_text;

logger.info("OPENAI BRAND STRATEGY RESPONSE", {
  hasOutputText: Boolean(rawOutput),
  outputLength:
    typeof rawOutput === "string"
      ? rawOutput.length
      : 0,

  outputText: rawOutput || "NO OUTPUT TEXT",

  responseStatus: response.status || null,

  incompleteDetails:
    response.incomplete_details || null,
});

if (!rawOutput || !rawOutput.trim()) {
  throw new Error(
    "OpenAI returned no brand strategy text.",
  );
}

try {
  strategy = JSON.parse(rawOutput);
} catch (error) {
  logger.error("BRAND STRATEGY JSON PARSE FAILED", {
    parseError:
      error instanceof Error
        ? error.message
        : String(error),

    rawOutput,
  });

  throw new Error(
    `Brand strategy JSON parsing failed: ${
      error instanceof Error
        ? error.message
        : String(error)
    }`,
  );
}

  return {
    ...strategy,

    primaryColor:
        normalizeHex(
          strategy.primaryColor,
          "#1E3A8A",
        ),

    secondaryColor:
        normalizeHex(
          strategy.secondaryColor,
          "#2563EB",
        ),

    accentColor:
        normalizeHex(
          strategy.accentColor,
          "#F59E0B",
        ),

    backgroundColor:
        normalizeHex(
          strategy.backgroundColor,
          "#F8FAFC",
        ),
  };
}

/**
 * Build four genuinely different directions.
 */
function buildLogoPromptDirections({
  brandBrief,
  brandStrategy,
}) {
  const baseInformation = `
Business name: "${brandBrief.businessName}"
Industry: ${brandBrief.industry}
Business: ${brandBrief.businessDescription}
Target audience: ${brandBrief.targetAudience}
Personality: ${brandBrief.personalities.join(", ")}
Values: ${brandBrief.brandValues.join(", ")}
Brand voice: ${brandBrief.brandVoice}
Desired emotion: ${brandBrief.audienceFeeling}
Requested style: ${brandBrief.logoStyle}
Requested logo type: ${brandBrief.logoType}
Symbol preference: ${brandBrief.symbolPreference}
Typography direction: ${brandBrief.fontStyle}
Primary colour: ${brandStrategy.primaryColor}
Secondary colour: ${brandStrategy.secondaryColor}
Accent colour: ${brandStrategy.accentColor}
`;

  return [
    {
      name: "Signature Symbol",
      description:
          "A distinctive symbol-led identity designed for recognition.",

      prompt: `
${baseInformation}

Create a polished combination-mark logo.

Direction:
Design a distinctive, simple symbol that communicates
the central business idea without using generic clip art.

Pair the symbol with the exact business name:
"${brandBrief.businessName}"

The symbol must remain recognizable at app-icon size.
Use restrained geometry and balanced negative space.
`,
    },

    {
      name: "Modern Wordmark",
      description:
          "A typography-led concept focused on the business name.",

      prompt: `
${baseInformation}

Create a refined wordmark-led logo.

Direction:
Make the exact business name
"${brandBrief.businessName}"
the central visual element.

Use intelligent custom letter relationships,
subtle typographic modification and excellent spacing.

Do not add an unrelated large icon.
A tiny integrated detail is acceptable.
`,
    },

    {
      name: "Abstract Momentum",
      description:
          "An abstract concept representing progress and transformation.",

      prompt: `
${baseInformation}

Create an abstract modern logo.

Direction:
Develop a unique geometric symbol representing
progress, connection, capability or transformation.

Avoid obvious arrows, globes, light bulbs,
rockets and generic technology circuits.

Pair it with the exact business name:
"${brandBrief.businessName}"
`,
    },

    {
      name: "Trusted Emblem",
      description:
          "A structured identity communicating credibility and authority.",

      prompt: `
${baseInformation}

Create a contemporary emblem or structured badge.

Direction:
Communicate trust, stability and professional authority
without appearing old-fashioned.

Use a clean modern enclosure or monogram structure.

Include the exact business name:
"${brandBrief.businessName}"
`,
    },
  ];
}

/**
 * Generate one image, upload it and return its metadata.
 */
async function generateAndStoreLogo({
  openai,
  projectId,
  userId,
  index,
  direction,
  brandBrief,
}) {
const finalPrompt = `
${direction.prompt}

MANDATORY OUTPUT REQUIREMENTS:

Create one professional logo concept only.

Use a square 1:1 composition.

Place the logo on a plain solid white background.

No mockup.
No business card.
No wall sign.
No paper texture.
No stationery.
No hands.
No device screen.
No presentation board.
No photograph.
No decorative scene.
No watermark.
No stock icon appearance.
No trademark symbols.

The exact business name must be readable and spelled:
"${brandBrief.businessName}"

Keep the design centred with generous empty space.
Use clean edges, strong negative space,
professional proportions and a vector-like finish.
`;

  const imageResult =
      await openai.images.generate({
        model: "gpt-image-2",
        prompt: finalPrompt,

        size: "1024x1024",
        quality: "medium",
        output_format: "png",
        moderation: "auto",
      });

  const imageBase64 =
      imageResult.data &&
      imageResult.data[0] &&
      imageResult.data[0].b64_json;

  if (!imageBase64) {
    throw new Error(
      `No image data was returned for concept ${index + 1}.`,
    );
  }

  const imageBuffer =
      Buffer.from(imageBase64, "base64");

  if (!imageBuffer.length) {
    throw new Error(
      `The image for concept ${index + 1} was empty.`,
    );
  }

  const conceptId = `concept_${index + 1}`;

  const storagePath =
      `brandProjects/${userId}/${projectId}/logos/` +
      `${conceptId}.png`;

  const downloadToken =
      createDownloadToken();

  const file = bucket.file(storagePath);

  await file.save(imageBuffer, {
    resumable: false,

    contentType: "image/png",

    metadata: {
      cacheControl:
          "public,max-age=31536000,immutable",

      metadata: {
        firebaseStorageDownloadTokens:
            downloadToken,

        userId,
        projectId,
        conceptId,
      },
    },
  });

  const imageUrl = buildFirebaseDownloadUrl({
    bucketName: bucket.name,
    storagePath,
    downloadToken,
  });

  return {
    id: conceptId,
    conceptName: direction.name,
    description: direction.description,
    imageUrl,
    storagePath,
    prompt: finalPrompt,
    logoType: brandBrief.logoType,
    style: brandBrief.logoStyle,
  };
}

function buildFirebaseDownloadUrl({
  bucketName,
  storagePath,
  downloadToken,
}) {
  return (
    "https://firebasestorage.googleapis.com/v0/b/" +
    `${bucketName}/o/` +
    `${encodeURIComponent(storagePath)}` +
    `?alt=media&token=${downloadToken}`
  );
}

function createDownloadToken() {
  if (
    typeof crypto !== "undefined" &&
    typeof crypto.randomUUID === "function"
  ) {
    return crypto.randomUUID();
  }

  return `${Date.now()}-${Math.random()
      .toString(36)
      .slice(2)}`;
}

function cleanString(value, maxLength) {
  if (typeof value !== "string") {
    return "";
  }

  return value
      .trim()
      .replace(/\s+/g, " ")
      .slice(0, maxLength);
}

function cleanStringArray(
  value,
  maxItems,
  maxItemLength,
) {
  if (!Array.isArray(value)) {
    return [];
  }

  return [
    ...new Set(
      value
          .filter(
            (item) => typeof item === "string",
          )
          .map(
            (item) =>
              cleanString(item, maxItemLength),
          )
          .filter(Boolean),
    ),
  ].slice(0, maxItems);
}

function normalizeHex(value, fallback) {
  if (typeof value !== "string") {
    return fallback;
  }

  let cleaned = value.trim().toUpperCase();

  if (!cleaned.startsWith("#")) {
    cleaned = `#${cleaned}`;
  }

  return /^#[0-9A-F]{6}$/.test(cleaned)
      ? cleaned
      : fallback;
}

module.exports = {
  generateBrandIdentity,
};
