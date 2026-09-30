import 'package:flutter/material.dart';

import 'assessment_question_screen.dart';
import 'existing_business_screen.dart';

class EntrepreneurIntroScreen extends StatelessWidget {
  const EntrepreneurIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffFFF3E0),
              Color(0xffFFE0B2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height - 80,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.05),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 55),

                  Container(
                    height: 145,
                    width: 145,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffff9800),
                          Color(0xffffc107),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange
                              .withOpacity(0.30),
                          blurRadius: 35,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 75,
                    ),
                  ),

                  const SizedBox(height: 38),

                  const Text(
                    "Discover Your\nIdeal Business",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Let AI understand your skills, goals and resources "
                    "and help you build the right business journey.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        buildFeature(
                          Icons.psychology,
                          "Personality & Skill Analysis",
                        ),
                        buildFeature(
                          Icons.business_center,
                          "Business Opportunity Matching",
                        ),
                        buildFeature(
                          Icons.rocket_launch,
                          "Growth Roadmap",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AssessmentQuestionScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Start AI Assessment  →",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.business_center_outlined,
                      ),
                      label: const Text(
                        "I Already Have a Business Idea",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.orange.shade800,
                        side: BorderSide(
                          color:
                              Colors.orange.shade400,
                          width: 1.5,
                        ),
                        backgroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ExistingBusinessScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Already know what you want to build? "
                    "Tell us a few details and we’ll create your business profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeature(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color:
                  Colors.orange.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}