import 'package:flutter/material.dart';
import 'assessment_data.dart';
import '../services/ai_analysis_screen.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({super.key});

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState
    extends State<AssessmentQuestionScreen> {
  int currentIndex = 0;

  String? selectedAnswer;

  final TextEditingController answerController =
      TextEditingController();

  /// Store question + answer together.
  final Map<int, String> answers = {};

  bool get isCustomAnswerQuestion {
    final question = entrepreneurQuestions[currentIndex];

    return question.options.length == 1 &&
        question.options.first == "Write your own answer";
  }

  bool get canContinue {
    if (isCustomAnswerQuestion) {
      return answerController.text.trim().isNotEmpty;
    }

    return selectedAnswer != null &&
        selectedAnswer!.trim().isNotEmpty;
  }

  void nextQuestion() {
    final question = entrepreneurQuestions[currentIndex];

    String answer;

    if (isCustomAnswerQuestion) {
      answer = answerController.text.trim();
    } else {
      answer = selectedAnswer?.trim() ?? '';
    }

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide an answer."),
        ),
      );
      return;
    }

    /// Save question AND answer.
    answers[currentIndex] =
        "Question: ${question.question}\nAnswer: $answer";

    if (currentIndex < entrepreneurQuestions.length - 1) {
      setState(() {
        currentIndex++;

        selectedAnswer = null;
        answerController.clear();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIAnalysisScreen(
            answers: answers.values.toList(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = entrepreneurQuestions[currentIndex];

    final double progress =
        (currentIndex + 1) / entrepreneurQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xffFFF8EE),

      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.orange,
                    ),
                  ),

                  Text(
                    "${currentIndex + 1}/${entrepreneurQuestions.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ================= PROGRESS =================

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    Colors.orange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // ================= AI ICON =================

            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffff9800),
                    Color(0xffffc107),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(.3),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // ================= QUESTION =================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(25),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),

                      child: Text(
                        question.question,
                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 24,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ================= CUSTOM ANSWER =================

                    if (isCustomAnswerQuestion)
                      Container(
                        margin:
                            const EdgeInsets.only(top: 10),

                        child: TextField(
                          controller: answerController,
                          maxLines: 5,
                          minLines: 4,

                          onChanged: (value) {
                            /// IMPORTANT:
                            /// Rebuild screen whenever user types.
                            /// This enables Generate My Business button.
                            setState(() {});
                          },

                          decoration: InputDecoration(
                            hintText:
                                "Tell us about your dream business...",

                            filled: true,
                            fillColor: Colors.white,

                            contentPadding:
                                const EdgeInsets.all(20),

                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )

                    // ================= OPTIONS =================

                    else
                      Column(
                        children:
                            question.options.map((option) {
                          final bool selected =
                              selectedAnswer == option;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAnswer = option;
                              });
                            },

                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),

                              width: double.infinity,

                              margin:
                                  const EdgeInsets.only(
                                bottom: 14,
                              ),

                              padding:
                                  const EdgeInsets.all(18),

                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.orange
                                    : Colors.white,

                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),

                                border: Border.all(
                                  color: selected
                                      ? Colors.orange
                                      : Colors
                                          .grey.shade300,

                                  width: selected ? 2 : 1,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(.04),
                                    blurRadius: 10,
                                    offset:
                                        const Offset(0, 4),
                                  ),
                                ],
                              ),

                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,

                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.black87,

                                        fontSize: 16,

                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (selected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // ================= BUTTON =================

            Padding(
              padding: const EdgeInsets.all(20),

              child: SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed:
                      canContinue ? nextQuestion : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,

                    disabledBackgroundColor:
                        Colors.grey.shade300,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),

                  child: Text(
                    currentIndex ==
                            entrepreneurQuestions.length - 1
                        ? "Generate My Business 🚀"
                        : "Continue →",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                      color: canContinue
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}