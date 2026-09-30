import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'onboarding_page.dart';
import 'language_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "title": "Find the Right\nOpportunity",
      "subtitle":
          "Discover jobs and career opportunities matched to your skills, interests and ambitions.",
      "icon": Icons.travel_explore_rounded,
      "smallIcon": Icons.auto_awesome_rounded,
      "tag": "SMART JOB DISCOVERY",
    },
    {
      "title": "Build a Profile\nThat Stands Out",
      "subtitle":
          "Showcase your skills, experience and strengths so the right employers can discover you.",
      "icon": Icons.person_search_rounded,
      "smallIcon": Icons.verified_rounded,
      "tag": "YOUR CAREER IDENTITY",
    },
    {
      "title": "Your Next Career\nMove Starts Here",
      "subtitle":
          "Apply to the right opportunities, track your progress and move confidently towards your goals.",
      "icon": Icons.rocket_launch_rounded,
      "smallIcon": Icons.trending_up_rounded,
      "tag": "READY TO GROW",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("onboarding_completed", true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void nextPage() {
    if (currentPage == pages.length - 1) {
      _completeOnboarding();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> previousPage() async {
  // Page 2 or Page 3:
  // Move to the previous onboarding page.
  if (currentPage > 0) {
    await _controller.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    return;
  }

  // Page 1:
  // Go back to language selection.
  if (!mounted) return;

  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      pageBuilder: (_, animation, secondaryAnimation) {
        return const LanguageScreen();
      },
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(-0.08, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF07152B),
      body: Stack(
        children: [
          /// MAIN BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF07152B),
                  Color(0xFF0B1F42),
                  Color(0xFF123B69),
                ],
              ),
            ),
          ),

          /// TOP GLOW
          Positioned(
            top: -120,
            right: -100,
            child: _GlowCircle(
              size: size.width * 0.8,
              color: const Color(0xFF5B7CFF),
            ),
          ),

          /// LEFT GLOW
          Positioned(
            top: size.height * 0.42,
            left: -180,
            child: _GlowCircle(
              size: size.width * 0.9,
              color: const Color(0xFF15C6C8),
            ),
          ),

          /// BOTTOM GLOW
          Positioned(
            bottom: -160,
            right: -100,
            child: _GlowCircle(
              size: size.width * 0.85,
              color: const Color(0xFF7467FF),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                /// HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                     Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: previousPage,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      height: 43,
      width: 43,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white,
        size: 22,
      ),
    ),
  ),
),

                      const SizedBox(width: 12),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "VELAI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Build your career",
                            style: TextStyle(
                              color: Color(0xFF9FB4D0),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 11,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// PAGE CONTENT
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemCount: pages.length,
                    itemBuilder: (_, index) {
                      return OnboardingPage(
                        title: pages[index]["title"],
                        subtitle: pages[index]["subtitle"],
                        icon: pages[index]["icon"],
                        smallIcon: pages[index]["smallIcon"],
                        tag: pages[index]["tag"],
                        pageIndex: index,
                      );
                    },
                  ),
                ),

                /// BOTTOM SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Column(
                    children: [
                      /// PROGRESS + COUNT
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: List.generate(pages.length, (index) {
                                final active = currentPage == index;

                                return Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOut,
                                    height: 4,
                                    margin: EdgeInsets.only(
                                      right: index == pages.length - 1 ? 0 : 7,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: active
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF60EFFF),
                                                Color(0xFF7C6CFF),
                                              ],
                                            )
                                          : null,
                                      color: active
                                          ? null
                                          : Colors.white.withValues(
                                              alpha: 0.13,
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(width: 18),

                          Text(
                            "0${currentPage + 1}/0${pages.length}",
                            style: const TextStyle(
                              color: Color(0xFFA9B9CF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 23),

                      /// BUTTON
                      SizedBox(
                        height: 62,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6BE7F5), Color(0xFF6677FF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6677FF,
                                ).withValues(alpha: 0.35),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: nextPage,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Text(
                                    currentPage == pages.length - 1
                                        ? "Start Your Journey"
                                        : "Continue",
                                    key: ValueKey(currentPage),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Container(
                                  width: 31,
                                  height: 31,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    currentPage == pages.length - 1
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_rounded,
                                    size: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.20),
          ),
        ),
      ),
    );
  }
}
