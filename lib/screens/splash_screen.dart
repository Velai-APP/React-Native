import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset(
      "assets/images/google.mp4",
    )
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
      });

    _videoController.setLooping(true);
    _videoController.setVolume(0);

    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final onboardingDone =
        prefs.getBool("onboarding_completed") ?? false;

    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildLogo() {
    if (!_videoController.value.isInitialized) {
return Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Colors.white24,
      width: 1,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.asset(
      "assets/images/logo.png",
      width: 130,
      fit: BoxFit.cover,
    ),
  ),
);
    }

    return SizedBox(
      width: 160,
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),

            const SizedBox(height: 25),

            const Text(
              "Velai",
              style: TextStyle(
                fontSize: 34,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}