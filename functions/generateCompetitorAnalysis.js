const {onCall, HttpsError} =
  require("firebase-functions/v2/https");

const {defineSecret} =
  require("firebase-functions/params");

const admin = require("firebase-admin");
const OpenAI = require("openai");


// ============================================================
// FIREBASE
// ============================================================

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();


// ============================================================
// OPENAI SECRET
// ============================================================

const openAiKey =
  defineSecret("OPENAI_API_KEY");


// ============================================================
// ALLOWED MODULES
// ============================================================

const ALLOWED_MODULES = [
  "Company Profile",
  "Customer Reviews",
  "Competitors",
  "Growth Ideas",
];


// ============================================================
// SAFE STRING ARRAY
// Maximum 10 findings
// ============================================================

function safeArray(value) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .filter((item) => item != null)
    .map((item) => item.toString().trim())
    .filter((item) => item.length > 0)
    .slice(0, 10);
}


// ============================================================
// SAFE SOURCES
// ============================================================

function safeSources(value) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .slice(0, 20)
    .map((item) => ({
      title:
        item?.title?.toString().trim() ?? "",

      url:
        item?.url?.toString().trim() ?? "",
    }))
    .filter(
      (item) =>
        item.title.length > 0 ||
        item.url.length > 0
    );
}


// ============================================================
// SAFE COMPETITORS
// ============================================================

function safeCompetitors(value) {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .slice(0, 8)
    .map((item) => ({
      name:
        item?.name?.toString().trim() ?? "",

      reason:
        item?.reason?.toString().trim() ?? "",

      strength:
        item?.strength?.toString().trim() ?? "",

      weakness:
        item?.weakness?.toString().trim() ?? "",
    }))
    .filter(
      (item) =>
        item.name.length > 0
    );
}


// ============================================================
// NORMALISE AI RESULT
// ============================================================

function normaliseResult(data) {
  return {
    executiveSummary:
      safeArray(
        data.executiveSummary
      ),

    companyProfile:
      safeArray(
        data.companyProfile
      ),

    customerReviews:
      safeArray(
        data.customerReviews
      ),

    competitors:
      safeArray(
        data.competitors
      ),

    competitorCompanies:
      safeCompetitors(
        data.competitorCompanies
      ),

    growthIdeas:
      safeArray(
        data.growthIdeas
      ),

    sources:
      safeSources(
        data.sources
      ),
  };
}


// ============================================================
// BUILD SELECTED MODULE PROMPT
// ============================================================

function buildModulePrompt(
  selectedModules
) {
  const tasks = [];


  // ----------------------------------------------------------
  // COMPANY PROFILE
  // ----------------------------------------------------------

  if (
    selectedModules.includes(
      "Company Profile"
    )
  ) {
    tasks.push(`
COMPANY PROFILE

Return maximum 10 concise findings covering
the most useful combination of:

- company overview
- history
- products/services
- target customers
- geographic presence
- business model
- positioning
- digital presence
- strengths
- weaknesses

Do NOT create separate strengths and weaknesses arrays.

Put the most important information directly inside
the companyProfile array.
`);
  }


  // ----------------------------------------------------------
  // CUSTOMER REVIEWS
  // ----------------------------------------------------------

  if (
    selectedModules.includes(
      "Customer Reviews"
    )
  ) {
    tasks.push(`
CUSTOMER REVIEWS

Return maximum 10 TOTAL findings.

Do not generate 10 positive + 10 negative +
10 expectations.

Instead choose the 10 most useful customer
intelligence findings overall.

Cover the most important combination of:

- positive customer themes
- negative customer themes
- recurring complaints
- staff/service
- product quality
- pricing
- billing
- returns/exchanges
- delivery
- store experience
- online experience
- customer expectations

Example style:

"Wide product assortment is repeatedly praised,
especially for wedding and family shopping."

"Service quality appears inconsistent across
branches and individual sales staff."

Do not fabricate reviews or ratings.
`);
  }


  // ----------------------------------------------------------
  // COMPETITORS
  // ----------------------------------------------------------

  if (
    selectedModules.includes(
      "Competitors"
    )
  ) {
    tasks.push(`
COMPETITOR ANALYSIS

Return maximum 10 concise competitive findings.

Identify the most important direct competitors.

Focus on:

- positioning
- customer overlap
- product overlap
- geographic competition
- differentiation
- digital presence
- strengths
- vulnerabilities

Also populate competitorCompanies.

Include maximum 8 important competitors.

For each competitor provide only:

name
reason
strength
weakness

Keep these concise.

Do not fabricate market share.
`);
  }


  // ----------------------------------------------------------
  // GROWTH
  // ----------------------------------------------------------

  if (
    selectedModules.includes(
      "Growth Ideas"
    )
  ) {
    tasks.push(`
GROWTH IDEAS

Return maximum 10 TOTAL recommendations.

Do not create separate lists for immediate,
medium-term and strategic recommendations.

Choose the 10 highest-value opportunities.

Consider:

- customer pain points
- product opportunities
- service improvements
- digital opportunities
- ecommerce
- loyalty
- CRM
- pricing
- operational improvements
- competitive gaps

Every recommendation should be practical and concise.
`);
  }


  return tasks.join("\n\n");
}


// ============================================================
// CLOUD FUNCTION
// ============================================================

exports.generateCompetitorAnalysis =
  onCall(
    {
      secrets: [
        openAiKey,
      ],

      timeoutSeconds: 300,

      memory: "1GiB",

      region: "us-central1",
    },

    async (request) => {
      let reportRef = null;

      try {

        // ====================================================
        // INPUT
        // ====================================================

        const companyName =
          request.data?.companyName
            ?.toString()
            .trim();

        const industry =
          request.data?.industry
            ?.toString()
            .trim();

        const selectedModules =
          request.data?.selectedModules;


        // ====================================================
        // VALIDATION
        // ====================================================

        if (!companyName) {
          throw new HttpsError(
            "invalid-argument",
            "Company name is required."
          );
        }


        if (!industry) {
          throw new HttpsError(
            "invalid-argument",
            "Industry is required."
          );
        }


        if (
          !Array.isArray(selectedModules) ||
          selectedModules.length === 0
        ) {
          throw new HttpsError(
            "invalid-argument",
            "Select at least one analysis module."
          );
        }


        const invalidModules =
          selectedModules.filter(
            (module) =>
              !ALLOWED_MODULES.includes(
                module
              )
          );


        if (invalidModules.length > 0) {
          throw new HttpsError(
            "invalid-argument",
            "Invalid analysis module."
          );
        }


        // ====================================================
        // USER
        // ====================================================

        const userId =
          request.auth?.uid ?? null;


        // ====================================================
        // FIRESTORE DOCUMENT
        // ====================================================

        reportRef =
          db
            .collection(
              "competitorReports"
            )
            .doc();


        await reportRef.set({
          reportId:
            reportRef.id,

          userId:
            userId,

          companyName:
            companyName,

          industry:
            industry,

          selectedModules:
            selectedModules,

          status:
            "processing",

          reportGenerated:
            false,

          createdAt:
            admin.firestore
              .FieldValue
              .serverTimestamp(),

          updatedAt:
            admin.firestore
              .FieldValue
              .serverTimestamp(),
        });


        // ====================================================
        // MODULE PROMPT
        // ====================================================

        const modulePrompt =
          buildModulePrompt(
            selectedModules
          );


        // ====================================================
        // FAST PROMPT
        // ====================================================

        const prompt = `
You are a competitive intelligence analyst.

Research the following company using CURRENT
public web information.

COMPANY:
${companyName}

INDUSTRY:
${industry}

SELECTED MODULES:
${selectedModules.join(", ")}


==================================================
OBJECTIVE
==================================================

This is the FAST FIRST-PASS analysis for a mobile app.

The user needs useful results quickly.

Do NOT write a long report.

Do NOT write an essay.

Do NOT create a detailed fullReport.

Research efficiently and return only the most
decision-useful findings.


==================================================
EXECUTIVE SUMMARY
==================================================

Return maximum 5 concise findings.

These should communicate the most important
things discovered during research.

Do not repeat the same information later
unnecessarily.


==================================================
SELECTED ANALYSIS
==================================================

${modulePrompt}


==================================================
SOURCES
==================================================

Include the most important sources actually
used in the research.

Prefer:

1. Official company website
2. Credible business publications
3. Reputable news sources
4. Industry sources
5. Public review platforms when customer
   reviews are requested

Return maximum 20 sources.

Never invent URLs.


==================================================
ACCURACY
==================================================

Do NOT fabricate:

- company facts
- revenue
- profits
- customer reviews
- ratings
- competitors
- news
- market share
- locations

If evidence is weak, phrase the finding
carefully.

Customer review platforms contain individual
opinions and are not necessarily statistically
representative.


==================================================
STYLE
==================================================

Every finding should normally be ONE concise
sentence.

Avoid long paragraphs.

Avoid introductions.

Avoid conclusions.

Avoid unnecessary explanation.

Do not use Markdown.

Return ONLY valid JSON.

Do not surround JSON with triple backticks.


==================================================
JSON
==================================================

Return exactly this structure:

{
  "executiveSummary": [
    "Finding"
  ],

  "companyProfile": [
    "Finding"
  ],

  "customerReviews": [
    "Finding"
  ],

  "competitors": [
    "Finding"
  ],

  "competitorCompanies": [
    {
      "name": "",
      "reason": "",
      "strength": "",
      "weakness": ""
    }
  ],

  "growthIdeas": [
    "Recommendation"
  ],

  "sources": [
    {
      "title": "",
      "url": ""
    }
  ]
}

IMPORTANT:

If a module was NOT selected,
return an empty array for that module.

executiveSummary:
maximum 5 items.

Every selected module:
maximum 10 items.

competitorCompanies:
maximum 8 items.

Keep the response compact.
`;


        // ====================================================
        // OPENAI
        // ====================================================

        const openai =
          new OpenAI({
            apiKey:
              openAiKey.value(),
          });


        console.log(
          "Starting FAST analysis:",
          companyName
        );


        const startedAt =
          Date.now();


        // ====================================================
        // FAST MODEL + WEB SEARCH
        // ====================================================

        const response =
          await openai.responses.create({
            model:
              "gpt-5.6-terra",

            reasoning: {
              effort:
                "low",
            },

            tools: [
              {
                type:
                  "web_search",
              },
            ],

            input:
              prompt,

            text: {
              verbosity:
                "low",
            },
          });


        console.log(
          "OpenAI completed in:",
          Date.now() - startedAt,
          "ms"
        );


        // ====================================================
        // OUTPUT
        // ====================================================

        let rawOutput =
          response.output_text
            ?.trim();


        if (!rawOutput) {
          throw new Error(
            "AI returned an empty response."
          );
        }


        // ====================================================
        // REMOVE ACCIDENTAL CODE FENCES
        // ====================================================

        rawOutput =
          rawOutput
            .replace(
              /^```json\s*/i,
              ""
            )
            .replace(
              /^```\s*/i,
              ""
            )
            .replace(
              /\s*```$/i,
              ""
            )
            .trim();


        // ====================================================
        // PARSE
        // ====================================================

        let parsed;


        try {
          parsed =
            JSON.parse(
              rawOutput
            );
        } catch (error) {

          console.error(
            "Invalid JSON:"
          );

          console.error(
            rawOutput
          );

          throw new Error(
            "AI returned invalid JSON."
          );
        }


        // ====================================================
        // NORMALISE
        // ====================================================

        const report =
          normaliseResult(
            parsed
          );


        const generatedAt =
          new Date()
            .toISOString();


        const durationMs =
          Date.now() -
          startedAt;


        // ====================================================
        // SAVE TO FIRESTORE
        // ====================================================

        await reportRef.update({
          status:
            "completed",

          generatedAt:
            generatedAt,

          analysisDurationMs:
            durationMs,

          executiveSummary:
            report.executiveSummary,

          companyProfile:
            report.companyProfile,

          customerReviews:
            report.customerReviews,

          competitors:
            report.competitors,

          competitorCompanies:
            report.competitorCompanies,

          growthIdeas:
            report.growthIdeas,

          sources:
            report.sources,

          reportGenerated:
            false,

          updatedAt:
            admin.firestore
              .FieldValue
              .serverTimestamp(),
        });


        console.log(
          "FAST report saved:",
          reportRef.id
        );


        // ====================================================
        // RETURN IMMEDIATELY
        // ====================================================

        return {
          success:
            true,

          reportId:
            reportRef.id,

          companyName:
            companyName,

          industry:
            industry,

          selectedModules:
            selectedModules,

          generatedAt:
            generatedAt,

          analysisDurationMs:
            durationMs,

          executiveSummary:
            report.executiveSummary,

          companyProfile:
            report.companyProfile,

          customerReviews:
            report.customerReviews,

          competitors:
            report.competitors,

          competitorCompanies:
            report.competitorCompanies,

          growthIdeas:
            report.growthIdeas,

          sources:
            report.sources,

          reportGenerated:
            false,
        };

      } catch (error) {

        console.error(
          "FAST competitor analysis failed:",
          error
        );


        // ====================================================
        // SAVE FAILED STATUS
        // ====================================================

        if (reportRef != null) {
          try {
            await reportRef.update({
              status:
                "failed",

              error:
                error?.message ??
                "Unknown error",

              updatedAt:
                admin.firestore
                  .FieldValue
                  .serverTimestamp(),
            });
          } catch (_) {
            // Ignore secondary Firestore failure
          }
        }


        if (
          error instanceof HttpsError
        ) {
          throw error;
        }


        throw new HttpsError(
          "internal",
          error?.message ??
            "Unable to generate competitor analysis."
        );
      }
    }
  );