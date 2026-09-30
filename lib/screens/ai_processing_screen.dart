import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'competitor_result_screen.dart';

class AIProcessingScreen extends StatefulWidget {
  final String companyName;
  final String industry;
  final List<String> selectedModules;

  const AIProcessingScreen({
    super.key,
    required this.companyName,
    required this.industry,
    required this.selectedModules,
  });

  @override
  State<AIProcessingScreen> createState() =>
      _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> {
  int progress = 0;

  List<Map<String, dynamic>> agents = [];

  @override
  void initState() {
    super.initState();

    _buildSelectedAgents();

    // Actual Firebase function is called here
    startAIAnalysis();
  }

  // ============================================================
  // CREATE ONLY THE AGENTS SELECTED BY USER
  // ============================================================

  void _buildSelectedAgents() {
    agents = [];

    if (widget.selectedModules.contains("Company Profile")) {
      agents.add({
        "module": "Company Profile",
        "title": "Company Research Agent",
        "subtitle": "Collecting website, products & history",
        "icon": Icons.language_rounded,
        "status": "waiting",
      });
    }

    if (widget.selectedModules.contains("Customer Reviews")) {
      agents.add({
        "module": "Customer Reviews",
        "title": "Customer Intelligence Agent",
        "subtitle": "Analysing customer reviews & sentiment",
        "icon": Icons.star_rounded,
        "status": "waiting",
      });
    }

    if (widget.selectedModules.contains("Competitors")) {
      agents.add({
        "module": "Competitors",
        "title": "Competitor Agent",
        "subtitle": "Finding market competitors",
        "icon": Icons.compare_arrows_rounded,
        "status": "waiting",
      });
    }

    if (widget.selectedModules.contains("Growth Ideas")) {
      agents.add({
        "module": "Growth Ideas",
        "title": "Strategy Agent",
        "subtitle": "Generating business recommendations",
        "icon": Icons.trending_up_rounded,
        "status": "waiting",
      });
    }

    if (agents.isNotEmpty) {
      agents[0]["status"] = "running";
    }
  }

  // ============================================================
  // CALL FIREBASE CLOUD FUNCTION
  // ============================================================

  Future<void> startAIAnalysis() async {
    if (agents.isEmpty) {
      return;
    }

    try {
      // Show analysis has started
      if (mounted) {
        setState(() {
          progress = 10;
        });
      }

      // Firebase callable function
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable(
        'generateCompetitorAnalysis',
        options: HttpsCallableOptions(
          timeout: const Duration(minutes: 5),
        ),
      );

      // Send data to Firebase
      final HttpsCallableResult result = await callable.call({
        "companyName": widget.companyName,
        "industry": widget.industry,
        "selectedModules": widget.selectedModules,
      });

      if (!mounted) {
        return;
      }

      // Firebase response
      final Map<String, dynamic> analysisResult =
          Map<String, dynamic>.from(result.data);

      // Mark all agents completed
      setState(() {
        progress = 100;

        for (final agent in agents) {
          agent["status"] = "completed";
        }
      });

      debugPrint("======================================");
      debugPrint("AI ANALYSIS COMPLETED");
      debugPrint("Company: ${widget.companyName}");
      debugPrint("Industry: ${widget.industry}");
      debugPrint("Modules: ${widget.selectedModules}");
      debugPrint("Result: $analysisResult");
      debugPrint("======================================");

      // NEXT STEP:
      // Here we will open the result screen.
      //
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => CompetitorResultScreen(
      companyName: widget.companyName,
      industry: widget.industry,
      selectedModules: widget.selectedModules,
      analysisResult: analysisResult,
    ),
  ),
);
    } on FirebaseFunctionsException catch (e) {
      debugPrint("Firebase Function Error");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");

      if (!mounted) {
        return;
      }

      _showError(
        e.message ?? "AI analysis failed",
      );
    } catch (e) {
      debugPrint("AI Analysis Error: $e");

      if (!mounted) {
        return;
      }

      _showError(
        "Unable to complete competitor analysis.",
      );
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // CLOSE BUTTON

              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // AI ORB

              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff8B5CF6),
                      Color(0xff2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // TITLE

              const Text(
                "AI ANALYSTS\nWORKING",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // COMPANY NAME

              Text(
                "Analysing ${widget.companyName}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              // INDUSTRY + MODULE COUNT

              Text(
                "${widget.industry} • "
                "${widget.selectedModules.length} "
                "${widget.selectedModules.length == 1 ? "module" : "modules"}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.45),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              // PROGRESS BAR

              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                backgroundColor: Colors.white12,
                color: Colors.purpleAccent,
              ),

              const SizedBox(height: 10),

              Text(
                "$progress% Completed",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 25),

              // AGENTS

              Expanded(
                child: ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    return agentCard(
                      agents[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AGENT CARD
  // ============================================================

  Widget agentCard(
    Map<String, dynamic> agent,
  ) {
    final bool completed =
        agent["status"] == "completed";

    final bool running =
        agent["status"] == "running";

    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: running
              ? Colors.purpleAccent
              : Colors.transparent,
          width: 2,
        ),
      ),

      child: Row(
        children: [
          // AGENT ICON

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              agent["icon"] as IconData,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 15),

          // AGENT DETAILS

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  agent["title"].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  agent["subtitle"].toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // STATUS ICON

          Icon(
            completed
                ? Icons.check_circle
                : running
                    ? Icons.sync
                    : Icons.circle_outlined,
            color: completed
                ? Colors.green
                : running
                    ? Colors.purpleAccent
                    : Colors.white30,
          ),
        ],
      ),
    );
  }
}