import 'package:flutter/material.dart';

import '../models/assessment_question.dart';

import 'assessment_data.dart';
import 'medium_assessment_data.dart';
import 'high_assessment_data.dart';

import '../services/ai_analysis_screen.dart';

class AssessmentQuestionScreen extends StatefulWidget {
  const AssessmentQuestionScreen({super.key});

  @override
  State<AssessmentQuestionScreen> createState() =>
      _AssessmentQuestionScreenState();
}

class _AssessmentQuestionScreenState
    extends State<AssessmentQuestionScreen> {

  // ============================================================
  // ASSESSMENT LEVEL
  // ============================================================

  /// null means user has not selected Quick / Detailed / Deep yet.
  String? selectedAssessmentLevel;

  /// Questions currently being used.
  List<AssessmentQuestion> selectedQuestions = [];

  // ============================================================
  // QUESTION STATE
  // ============================================================

  int currentIndex = 0;

  String? selectedAnswer;

  final TextEditingController answerController =
      TextEditingController();

  /// Store question + answer together.
  final Map<int, String> answers = {};

  // ============================================================
  // SELECT ASSESSMENT
  // ============================================================

  void selectAssessment(String level) {
    setState(() {
      selectedAssessmentLevel = level;

      if (level == "low") {
        selectedQuestions = entrepreneurQuestions;
      } else if (level == "medium") {
        selectedQuestions = mediumEntrepreneurQuestions;
      } else if (level == "high") {
        selectedQuestions = highEntrepreneurQuestions;
      }

      currentIndex = 0;
      selectedAnswer = null;
      answers.clear();
      answerController.clear();
    });
  }

  // ============================================================
  // CUSTOM ANSWER
  // ============================================================

  bool get isCustomAnswerQuestion {
    if (selectedQuestions.isEmpty) {
      return false;
    }

    final question = selectedQuestions[currentIndex];

    return question.options.length == 1 &&
        question.options.first == "Write your own answer";
  }

  // ============================================================
  // CONTINUE BUTTON VALIDATION
  // ============================================================

  bool get canContinue {
    if (selectedQuestions.isEmpty) {
      return false;
    }

    if (isCustomAnswerQuestion) {
      return answerController.text.trim().isNotEmpty;
    }

    return selectedAnswer != null &&
        selectedAnswer!.trim().isNotEmpty;
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  void nextQuestion() {
    if (selectedQuestions.isEmpty) {
      return;
    }

    final question = selectedQuestions[currentIndex];

    String answer;

    if (isCustomAnswerQuestion) {
      answer = answerController.text.trim();
    } else {
      answer = selectedAnswer?.trim() ?? '';
    }

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please provide an answer.",
          ),
        ),
      );

      return;
    }

    // Save question AND answer.
    answers[currentIndex] =
        "Question: ${question.question}\nAnswer: $answer";

    if (currentIndex < selectedQuestions.length - 1) {
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

  // ============================================================
  // GO BACK
  // ============================================================

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;

        selectedAnswer = null;
        answerController.clear();
      });
    } else {
      // If on first question, return to assessment level selection.
      setState(() {
        selectedAssessmentLevel = null;
        selectedQuestions = [];
        currentIndex = 0;
        selectedAnswer = null;
        answerController.clear();
        answers.clear();
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    // First show assessment selector.
    if (selectedAssessmentLevel == null) {
      return _buildAssessmentLevelSelection();
    }

    // Safety check
    if (selectedQuestions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No assessment questions available.",
          ),
        ),
      );
    }

    final question =
        selectedQuestions[currentIndex];

    final double progress =
        (currentIndex + 1) /
            selectedQuestions.length;

    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8EE),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.all(20),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [

                  Row(
                    children: [

                      // BACK BUTTON

                      GestureDetector(
                        onTap: previousQuestion,

                        child: Container(
                          height: 46,
                          width: 46,

                          decoration:
                              BoxDecoration(
                            color: Colors.white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black
                                        .withOpacity(
                                  .04,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      // AI ICON

                      Container(
                        padding:
                            const EdgeInsets
                                .all(
                          12,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),

                        child: const Icon(
                          Icons.psychology,
                          color:
                              Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,

                    children: [

                      Text(
                        "${currentIndex + 1}/${selectedQuestions.length}",

                        style:
                            const TextStyle(
                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        _getAssessmentName(),

                        style: TextStyle(
                          fontSize: 11,

                          fontWeight:
                              FontWeight.w600,

                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ==================================================
            // PROGRESS
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                child:
                    LinearProgressIndicator(
                  minHeight: 8,

                  value: progress,

                  backgroundColor:
                      Colors.grey.shade200,

                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Colors.orange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // AI ICON
            // ==================================================

            Container(
              height: 75,
              width: 75,

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffff9800),
                    Color(0xffffc107),
                  ],
                ),

                shape: BoxShape.circle,

                boxShadow: [
                  BoxShadow(
                    color: Colors.orange
                        .withOpacity(.3),
                    blurRadius: 25,
                  ),
                ],
              ),

              child: const Icon(
                Icons.auto_awesome,

                size: 36,

                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // QUESTION AREA
            // ==================================================

            Expanded(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                child: Column(
                  children: [

                    // ==========================================
                    // QUESTION
                    // ==========================================

                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        25,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black
                                    .withOpacity(
                              .05,
                            ),
                            blurRadius: 20,
                          ),
                        ],
                      ),

                      child: Text(
                        question.question,

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          fontSize: 23,

                          height: 1.3,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================
                    // CUSTOM ANSWER
                    // ==========================================

                    if (isCustomAnswerQuestion)

                      Container(
                        margin:
                            const EdgeInsets
                                .only(
                          top: 10,
                        ),

                        child: TextField(
                          controller:
                              answerController,

                          maxLines: 6,

                          minLines: 4,

                          onChanged:
                              (value) {
                            setState(() {});
                          },

                          decoration:
                              InputDecoration(
                            hintText:
                                "Tell us about your dream business...",

                            hintStyle:
                                TextStyle(
                              color: Colors
                                  .grey.shade500,
                            ),

                            filled: true,

                            fillColor:
                                Colors.white,

                            contentPadding:
                                const EdgeInsets
                                    .all(
                              20,
                            ),

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),

                              borderSide:
                                  BorderSide
                                      .none,
                            ),

                            enabledBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),

                              borderSide:
                                  BorderSide(
                                color: Colors.grey
                                    .shade300,
                              ),
                            ),

                            focusedBorder:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),

                              borderSide:
                                  const BorderSide(
                                color:
                                    Colors.orange,

                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )

                    // ==========================================
                    // OPTIONS
                    // ==========================================

                    else

                      Column(
                        children:
                            question.options
                                .map(
                          (option) {

                            final bool
                                selected =
                                selectedAnswer ==
                                    option;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAnswer =
                                      option;
                                });
                              },

                              child:
                                  AnimatedContainer(
                                duration:
                                    const Duration(
                                  milliseconds:
                                      200,
                                ),

                                width:
                                    double.infinity,

                                margin:
                                    const EdgeInsets
                                        .only(
                                  bottom: 14,
                                ),

                                padding:
                                    const EdgeInsets
                                        .all(
                                  18,
                                ),

                                decoration:
                                    BoxDecoration(
                                  color: selected
                                      ? Colors
                                          .orange
                                      : Colors.white,

                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),

                                  border:
                                      Border.all(
                                    color: selected
                                        ? Colors
                                            .orange
                                        : Colors
                                            .grey
                                            .shade300,

                                    width:
                                        selected
                                            ? 2
                                            : 1,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .black
                                          .withOpacity(
                                        .04,
                                      ),

                                      blurRadius:
                                          10,

                                      offset:
                                          const Offset(
                                        0,
                                        4,
                                      ),
                                    ),
                                  ],
                                ),

                                child: Row(
                                  children: [

                                    Expanded(
                                      child:
                                          Text(
                                        option,

                                        style:
                                            TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : Colors.black87,

                                          fontSize:
                                              16,

                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 10,
                                    ),

                                    if (selected)
                                      const Icon(
                                        Icons
                                            .check_circle,

                                        color:
                                            Colors.white,
                                      )

                                    else
                                      Icon(
                                        Icons
                                            .radio_button_unchecked,

                                        color: Colors
                                            .grey
                                            .shade300,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),

                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BUTTON
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),

              child: SizedBox(
                width: double.infinity,

                height: 60,

                child: ElevatedButton(
                  onPressed:
                      canContinue
                          ? nextQuestion
                          : null,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black87,

                    disabledBackgroundColor:
                        Colors.grey.shade300,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

                  child: Text(
                    currentIndex ==
                            selectedQuestions
                                    .length -
                                1
                        ? "Generate My Business 🚀"
                        : "Continue →",

                    style: TextStyle(
                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,

                      color: canContinue
                          ? Colors.white
                          : Colors
                              .grey.shade600,
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

  // ============================================================
  // ASSESSMENT LEVEL NAME
  // ============================================================

  String _getAssessmentName() {
    switch (selectedAssessmentLevel) {
      case "low":
        return "QUICK ASSESSMENT";

      case "medium":
        return "DETAILED ASSESSMENT";

      case "high":
        return "DEEP AI ASSESSMENT";

      default:
        return "";
    }
  }

  // ============================================================
  // ASSESSMENT SELECTION SCREEN
  // ============================================================

  Widget _buildAssessmentLevelSelection() {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8EE),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            22,
          ),

          child: Column(
            children: [

              // ==================================================
              // BACK
              // ==================================================

              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                    },

                    child: Container(
                      height: 46,
                      width: 46,

                      decoration:
                          BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black
                                    .withOpacity(
                              .05,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons
                            .arrow_back_ios_new_rounded,

                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // AI ICON
              // ==================================================

              Container(
                height: 95,
                width: 95,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(
                        0xffff9800,
                      ),
                      Color(
                        0xffffc107,
                      ),
                    ],
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors
                          .orange
                          .withOpacity(
                        .25,
                      ),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons
                      .psychology_alt_rounded,

                  color:
                      Colors.white,

                  size: 47,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                "Choose Your\nAssessment",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 30,

                  height: 1.15,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                "Choose how deeply you want AI to understand your skills, personality, resources and goals.",

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 15,

                  height: 1.5,

                  color: Colors
                      .grey.shade600,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              // ==================================================
              // QUICK
              // ==================================================

              _assessmentCard(
                title:
                    "Quick Assessment",

                subtitle:
                    "A fast assessment to understand your basic skills, interests and business preferences.",

                questions:
                    "${entrepreneurQuestions.length} Questions",

                time:
                    "2–3 min",

                icon:
                    Icons.bolt_rounded,

                level:
                    "low",

                badge:
                    "QUICK",
              ),

              const SizedBox(
                height: 17,
              ),

              // ==================================================
              // DETAILED
              // ==================================================

              _assessmentCard(
                title:
                    "Detailed Assessment",

                subtitle:
                    "A deeper analysis of your skills, motivation, risk appetite, resources and preferred business model.",

                questions:
                    "${mediumEntrepreneurQuestions.length} Questions",

                time:
                    "4–5 min",

                icon:
                    Icons.analytics_outlined,

                level:
                    "medium",

                badge:
                    "RECOMMENDED",

                recommended:
                    true,
              ),

              const SizedBox(
                height: 17,
              ),

              // ==================================================
              // DEEP
              // ==================================================

              _assessmentCard(
                title:
                    "Deep AI Assessment",

                subtitle:
                    "Our most comprehensive assessment covering personality, execution, skills, lifestyle, risk and business goals.",

                questions:
                    "${highEntrepreneurQuestions.length} Questions",

                time:
                    "8–10 min",

                icon:
                    Icons.auto_awesome,

                level:
                    "high",

                badge:
                    "DEEP",
              ),

              const SizedBox(
                height: 28,
              ),

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .all(
                  18,
                ),

                decoration:
                    BoxDecoration(
                  color: Colors.orange
                      .withOpacity(
                    .07,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Icon(
                      Icons
                          .lightbulb_outline,

                      color: Colors
                          .orange
                          .shade800,

                      size: 22,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        "All assessments generate AI business recommendations. More detailed assessments allow AI to personalise your results more accurately.",

                        style:
                            TextStyle(
                          fontSize: 13,

                          height: 1.5,

                          color: Colors
                              .grey
                              .shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ASSESSMENT CARD
  // ============================================================

  Widget _assessmentCard({
    required String title,
    required String subtitle,
    required String questions,
    required String time,
    required IconData icon,
    required String level,
    required String badge,
    bool recommended = false,
  }) {

    return GestureDetector(
      onTap: () {
        selectAssessment(level);
      },

      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          border:
              Border.all(
            color: recommended
                ? Colors.orange
                : Colors
                    .grey.shade200,

            width:
                recommended
                    ? 2
                    : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: recommended
                  ? Colors.orange
                      .withOpacity(
                      .10,
                    )
                  : Colors.black
                      .withOpacity(
                      .05,
                    ),

              blurRadius: 20,

              offset:
                  const Offset(
                0,
                6,
              ),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                // ================================================
                // ICON
                // ================================================

                Container(
                  height: 58,
                  width: 58,

                  decoration:
                      BoxDecoration(
                    color: Colors.orange
                        .withOpacity(
                      .10,
                    ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      17,
                    ),
                  ),

                  child: Icon(
                    icon,

                    color:
                        Colors.orange,

                    size: 29,
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                // ================================================
                // CONTENT
                // ================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Expanded(
                            child: Text(
                              title,

                              style:
                                  const TextStyle(
                                fontSize:
                                    18,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  9,
                              vertical:
                                  5,
                            ),

                            decoration:
                                BoxDecoration(
                              color: recommended
                                  ? Colors.orange
                                  : Colors.orange
                                      .withOpacity(
                                      .10,
                                    ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),

                            child:
                                Text(
                              badge,

                              style:
                                  TextStyle(
                                color: recommended
                                    ? Colors.white
                                    : Colors.orange
                                        .shade800,

                                fontSize:
                                    9,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        subtitle,

                        style:
                            TextStyle(
                          fontSize: 13,

                          height: 1.45,

                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 17,
            ),

            Divider(
              color:
                  Colors.grey.shade200,
              height: 1,
            ),

            const SizedBox(
              height: 15,
            ),

            Row(
              children: [

                Icon(
                  Icons
                      .quiz_outlined,

                  size: 17,

                  color: Colors
                      .grey.shade600,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  questions,

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight:
                        FontWeight.w600,

                    color: Colors
                        .grey.shade700,
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                Icon(
                  Icons
                      .schedule_rounded,

                  size: 17,

                  color: Colors
                      .grey.shade600,
                ),

                const SizedBox(
                  width: 6,
                ),

                Text(
                  time,

                  style: TextStyle(
                    fontSize: 13,

                    fontWeight:
                        FontWeight.w600,

                    color: Colors
                        .grey.shade700,
                  ),
                ),

                const Spacer(),

                Container(
                  height: 34,
                  width: 34,

                  decoration:
                      BoxDecoration(
                    color: Colors.orange
                        .withOpacity(
                      .10,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      const Icon(
                    Icons
                        .arrow_forward_ios_rounded,

                    size: 14,

                    color:
                        Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}