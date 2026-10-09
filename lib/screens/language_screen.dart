import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'onboarding_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color secondaryColor = Color(0xFF2563EB);

  String selectedLanguage = 'en';
  bool _isSaving = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final List<_LanguageOption> languages = const [
    _LanguageOption(
      code: 'en',
      title: 'English',
      nativeTitle: 'English',
      subtitle: 'Continue in English',
      greeting: 'Welcome',
      iconText: 'A',
    ),
    // _LanguageOption(
    //   code: 'ta',
    //   title: 'Tamil',
    //   nativeTitle: 'தமிழ்',
    //   subtitle: 'தமிழில் தொடரவும்',
    //   greeting: 'வணக்கம்',
    //   iconText: 'அ',
    // ),
    // _LanguageOption(
    //   code: 'hi',
    //   title: 'Hindi',
    //   nativeTitle: 'हिन्दी',
    //   subtitle: 'हिन्दी में जारी रखें',
    //   greeting: 'नमस्ते',
    //   iconText: 'अ',
    // ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  Future<void> saveLanguage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        'language_code',
        selectedLanguage,
      );

      if (!mounted) return;

      // Change app locale immediately.
      MyApp.of(context)?.setLocale(
        Locale(selectedLanguage),
      );

      // Continue to onboarding.
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error saving language: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save language. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String get _buttonText {
    switch (selectedLanguage) {
      case 'ta':
        return 'தொடரவும்';
      case 'hi':
        return 'जारी रखें';
      default:
        return 'Continue';
    }
  }

  String get _selectedMessage {
    switch (selectedLanguage) {
      case 'ta':
        return 'Velai-ஐ தமிழில் பயன்படுத்துங்கள்';
      case 'hi':
        return 'Velai का उपयोग हिन्दी में करें';
      default:
        return 'Use Velai in English';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111B45),
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: _LanguageBackground(),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 20,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 40,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              // -------------------------
                              // LOGO
                              // -------------------------

                              Container(
                                width: 74,
                                height: 74,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.20),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Icon(
                                      Icons.auto_awesome_rounded,
                                      color: primaryColor,
                                      size: 42,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                'VELAI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // -------------------------
                              // LANGUAGE ICON
                              // -------------------------

                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.20),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.translate_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),

                              const SizedBox(height: 18),

                              const Text(
                                'Choose your language',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்  •  अपनी भाषा चुनें',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // -------------------------
                              // LANGUAGE CARDS
                              // -------------------------

                              ...languages.map(
                                (language) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 13),
                                  child: _buildLanguageCard(language),
                                ),
                              ),

                              const SizedBox(height: 12),

                              AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 250),
                                child: Text(
                                  _selectedMessage,
                                  key: ValueKey(selectedLanguage),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.70),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // -------------------------
                              // CONTINUE BUTTON
                              // -------------------------

                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: FilledButton(
                                  onPressed:
                                      _isSaving ? null : saveLanguage,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryColor,
                                    disabledBackgroundColor:
                                        Colors.white.withOpacity(0.7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: primaryColor,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              child: Text(
                                                _buttonText,
                                                key: ValueKey(
                                                  selectedLanguage,
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 22,
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              Text(
                                'You can change this anytime in Settings',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.50),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(_LanguageOption language) {
    final bool selected = selectedLanguage == language.code;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white
            : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? Colors.white
              : Colors.white.withOpacity(0.18),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              selectedLanguage = language.code;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            child: Row(
              children: [
                // Native alphabet icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryColor.withOpacity(0.10)
                        : Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    language.iconText,
                    style: TextStyle(
                      color:
                          selected ? primaryColor : Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              language.nativeTitle,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF111827)
                                    : Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          if (language.title !=
                              language.nativeTitle)
                            Text(
                              language.title,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF6B7280)
                                    : Colors.white.withOpacity(0.55),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        language.subtitle,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF6B7280)
                              : Colors.white.withOpacity(0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? primaryColor
                          : Colors.white.withOpacity(0.45),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String title;
  final String nativeTitle;
  final String subtitle;
  final String greeting;
  final String iconText;

  const _LanguageOption({
    required this.code,
    required this.title,
    required this.nativeTitle,
    required this.subtitle,
    required this.greeting,
    required this.iconText,
  });
}

class _LanguageBackground extends StatelessWidget {
  const _LanguageBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
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
            bottom: -150,
            left: -110,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 170,
            left: 30,
            child: _dot(7),
          ),
          Positioned(
            top: 250,
            right: 35,
            child: _dot(10),
          ),
          Positioned(
            bottom: 180,
            right: 50,
            child: _dot(6),
          ),
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
        color: Colors.white.withOpacity(0.35),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.20),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}