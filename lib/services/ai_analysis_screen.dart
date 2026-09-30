import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../screens/dashboard_screen.dart';

class AIAnalysisScreen extends StatefulWidget {
  final List<String> answers;

  const AIAnalysisScreen({super.key, required this.answers});

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  String status = "Analysing your Entrepreneur Profile...";

  @override
  void initState() {
    super.initState();

    analyseBusiness();
  }

  Future<void> analyseBusiness() async {
    try {
      setState(() {
        status = "AI is analysing your skills, interests and goals...";
      });

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable("analyseEntrepreneurProfile");

      final result = await callable.call({"answers": widget.answers});

      final Map<String, dynamic> data = Map<String, dynamic>.from(result.data);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(businessProfile: data),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;

      setState(() {
        status = e.message ?? "Unable to analyse your profile.";
      });

      debugPrint("Firebase Function Error: ${e.code}");

      debugPrint("Firebase Function Message: ${e.message}");
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = "Unable to analyse your profile. Please try again.";
      });

      debugPrint("AI analysis error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff7ed),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                height: 90,
                width: 90,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffff9800), Color(0xffffc107)],
                  ),

                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(.25),
                      blurRadius: 25,
                    ),
                  ],
                ),

                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 42,
                ),
              ),

              const SizedBox(height: 35),

              const CircularProgressIndicator(color: Colors.orange),

              const SizedBox(height: 30),

              Text(
                status,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "We are finding the best business opportunity based on your profile.",
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
