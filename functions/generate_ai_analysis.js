const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");

const {
  defineSecret,
} = require("firebase-functions/params");

const admin = require("firebase-admin");

const OpenAI = require("openai");

admin.initializeApp();

const db = admin.firestore();

const OPENAI_API_KEY =
  defineSecret("OPENAI_API_KEY");


exports.analyseEntrepreneurProfile =
onCall(
  {
    region: "asia-south1",

    secrets: [
      OPENAI_API_KEY,
    ],

    timeoutSeconds: 120,

    memory: "512MiB",
  },

  async (request) => {
    try {
      // ===================================================
      // CHECK LOGIN
      // ===================================================

      if (!request.auth) {
        throw new HttpsError(
          "unauthenticated",
          "Please login before generating your business profile.",
        );
      }

      const uid =
        request.auth.uid;

      // ===================================================
      // GET ANSWERS
      // ===================================================

      const answers =
        request.data?.answers;

      if (
        !Array.isArray(answers) ||
        answers.length === 0
      ) {
        throw new HttpsError(
          "invalid-argument",
          "Entrepreneur assessment answers are required.",
        );
      }

      // ===================================================
      // FORMAT ASSESSMENT
      // ===================================================

      const assessment =
        answers
          .map(
            (answer, index) =>
              `${index + 1}. ${answer}`,
          )
          .join("\n\n");

      // ===================================================
      // OPENAI
      // ===================================================

      const openai =
        new OpenAI({
          apiKey:
            OPENAI_API_KEY.value(),
        });

      const prompt = `
You are an expert business strategist,
startup advisor and entrepreneurship analyst.

A user has completed an entrepreneur
assessment.

Analyse the answers carefully and determine
the most suitable realistic business for
this individual.

Consider:

- Professional skills
- Work experience
- Interests
- Available capital
- Risk tolerance
- Technology capability
- Sales ability
- Preferred customers
- Time available
- Business experience
- Personal strengths
- Business ambitions
- Scalability preference
- Industry preference
- Entrepreneur personality

Do NOT recommend a generic business.

The business must match the person's
actual skills, financial capacity and
interests.

If the user has limited investment
capacity, do not recommend a capital
intensive business.

If the user has strong professional
skills, use those skills when suggesting
the business.

Return ONLY valid JSON.

Use exactly this JSON structure:

{
  "businessName": "",
  "businessCategory": "",
  "matchScore": 0,
  "investment": "",
  "timeToLaunch": "",
  "difficulty": "",
  "description": "",
  "opportunitySummary": "",
  "whyItFits": "",
  "targetCustomers": "",
  "revenueModel": "",
  "entrepreneurStrengths": [],
  "skillsRequired": [],
  "possibleWeaknesses": [],
  "majorRisks": [],
  "firstSteps": [],
  "alternativeBusinesses": []
}

Rules:

matchScore must be between 0 and 100.

entrepreneurStrengths must contain
3 to 6 items.

skillsRequired must contain
3 to 6 items.

possibleWeaknesses must contain
2 to 4 items.

majorRisks must contain
2 to 5 items.

firstSteps must contain exactly
5 practical actions.

alternativeBusinesses must contain
exactly 2 alternative business ideas.

All recommendations must be realistic,
practical and commercially viable.

ENTREPRENEUR ASSESSMENT:

${assessment}
`;

      // ===================================================
      // CALL OPENAI
      // ===================================================

      const response =
        await openai.responses.create({
          model: "gpt-5-mini",

          input: prompt,
        });

      const rawText =
        response.output_text;

      if (!rawText) {
        throw new Error(
          "OpenAI returned an empty response.",
        );
      }

      console.log(
        "OpenAI response:",
        rawText,
      );

      // ===================================================
      // CLEAN JSON
      // ===================================================

      const cleaned =
        rawText
          .replace(
            /```json/g,
            "",
          )
          .replace(
            /```/g,
            "",
          )
          .trim();

      let businessProfile;

      try {
        businessProfile =
          JSON.parse(cleaned);
      } catch (parseError) {
        console.error(
          "JSON parse error:",
          cleaned,
        );

        throw new Error(
          "AI returned invalid business profile JSON.",
        );
      }

      // ===================================================
      // ADD FIRESTORE INFORMATION
      // ===================================================

      const profileToSave = {
        ...businessProfile,

        assessmentAnswers:
          answers,

        createdAt:
          admin.firestore
            .FieldValue
            .serverTimestamp(),

        updatedAt:
          admin.firestore
            .FieldValue
            .serverTimestamp(),

        generatedBy:
          "openai",

        status:
          "active",
      };

      // ===================================================
      // SAVE TO FIRESTORE
      // ===================================================

      await db
        .collection("users")
        .doc(uid)
        .collection(
          "businessProfile",
        )
        .doc("profile")
        .set(
          profileToSave,
          {
            merge: true,
          },
        );

      // ===================================================
      // ALSO UPDATE USER
      // ===================================================

      await db
        .collection("users")
        .doc(uid)
        .set(
          {
            hasBusinessProfile:
              true,

            businessName:
              businessProfile
                .businessName,

            businessCategory:
              businessProfile
                .businessCategory,

            businessMatchScore:
              businessProfile
                .matchScore,

            businessProfileUpdatedAt:
              admin.firestore
                .FieldValue
                .serverTimestamp(),
          },

          {
            merge: true,
          },
        );

      // ===================================================
      // RETURN TO FLUTTER
      // ===================================================

      return businessProfile;
    } catch (error) {
      console.error(
        "analyseEntrepreneurProfile error:",
        error,
      );

      if (
        error instanceof HttpsError
      ) {
        throw error;
      }

      throw new HttpsError(
        "internal",
        error.message ||
          "Unable to generate business profile.",
      );
    }
  },
);
