import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF2563EB);

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _navigationTimer;

  bool _isNavigating = false;
  String _statusText = 'Preparing your workspace...';

  @override
  void initState() {
    super.initState();

    _initializeAnimation();
    _initializeSplash();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  Future<void> _initializeSplash() async {
    try {
      setStateIfMounted('Checking your account...');

      // Ensure SharedPreferences is ready.
      await SharedPreferences.getInstance().timeout(const Duration(seconds: 2));

      // Minimum splash display time.
      _navigationTimer = Timer(const Duration(seconds: 3), () {
        _navigateToNextScreen();
      });
    } on TimeoutException {
      // Continue even if SharedPreferences takes too long.
      _navigationTimer = Timer(const Duration(milliseconds: 500), () {
        _navigateToNextScreen();
      });
    } catch (error, stackTrace) {
      debugPrint('Splash initialization error: $error');
      debugPrintStack(stackTrace: stackTrace);

      _navigationTimer = Timer(const Duration(milliseconds: 500), () {
        _navigateToNextScreen();
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
  if (!mounted || _isNavigating) {
    return;
  }

  _isNavigating = true;

  try {
    setStateIfMounted('Opening Velai...');

    final SharedPreferences preferences =
        await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 2),
    );

    // -------------------------------------------------------
    // 1. CHECK LANGUAGE FIRST
    // -------------------------------------------------------
    final String? languageCode =
        preferences.getString('language_code');

    if (!mounted) return;

    // First-ever launch / language not selected
    if (languageCode == null || languageCode.isEmpty) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LanguageScreen(),
        ),
        (route) => false,
      );

      return;
    }

    // -------------------------------------------------------
    // 2. LANGUAGE ALREADY SELECTED
    // Continue with existing app flow
    // -------------------------------------------------------

    final bool onboardingCompleted =
        preferences.getBool('onboarding_completed') ?? false;

    final User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) {
      return;
    }

    final Widget destination;

    if (!onboardingCompleted) {
      destination = const OnboardingScreen();
    }

    // Uncomment later if you want logged-in users
    // to go directly to Dashboard.
    //
    // else if (user != null) {
    //   destination = const DashboardScreen();
    // }

    else {
      destination = const LoginScreen();
    }

    await Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return destination;
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  } on TimeoutException {
    _openLoginScreen();
  } catch (error, stackTrace) {
    debugPrint('Splash navigation error: $error');
    debugPrintStack(stackTrace: stackTrace);

    _openLoginScreen();
  }
}

  void _openLoginScreen() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void setStateIfMounted(String status) {
    if (!mounted) {
      return;
    }

    setState(() {
      _statusText = status;
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          final bool isSmallHeight = height < 600;
          final bool isTablet = width >= 600;
          final bool isLandscape = width > height;

          final double logoSize = isLandscape
              ? height * 0.26
              : isTablet
              ? 170
              : isSmallHeight
              ? 105
              : 140;

          final double titleSize = isSmallHeight
              ? 31
              : isTablet
              ? 48
              : 40;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF111B45),
                  primaryColor,
                  secondaryColor,
                  Color(0xFF7C3AED),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  const Positioned.fill(child: _SplashDecoration()),

                  Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 60 : 24,
                        vertical: 20,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 600 : 420,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildLogo(logoSize),
                                SizedBox(height: isSmallHeight ? 18 : 30),
                                Text(
                                  'VELAI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: isSmallHeight ? 4 : 6,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: isSmallHeight ? 8 : 13),
                                Text(
                                  'Your business, powered by AI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.82),
                                    fontSize: isSmallHeight ? 13 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: isSmallHeight ? 24 : 45),
                                SizedBox(
                                  width: isSmallHeight ? 155 : 190,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: const LinearProgressIndicator(
                                      minHeight: 5,
                                      backgroundColor: Color(0x35FFFFFF),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    _statusText,
                                    key: ValueKey<String>(_statusText),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.72),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isSmallHeight ? 10 : 20,
                    child: Text(
                      'BUILD • LAUNCH • GROW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.48),
                        fontSize: isSmallHeight ? 9 : 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(double logoSize) {
    return Container(
      width: logoSize,
      height: logoSize,
      padding: EdgeInsets.all(logoSize * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(logoSize * 0.24),
        border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.24),
            blurRadius: 36,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.auto_awesome_rounded,
            color: primaryColor,
            size: logoSize * 0.52,
          );
        },
      ),
    );
  }
}

class _SplashDecoration extends StatelessWidget {
  const _SplashDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -110,
            right: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(top: 100, left: 30, child: _dot(7)),
          Positioned(top: 170, right: 45, child: _dot(10)),
          Positioned(bottom: 130, right: 55, child: _dot(6)),
        ],
      ),
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.38),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
