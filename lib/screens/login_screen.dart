import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'entrepreneur_intro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // =====================================================
      // GOOGLE LOGIN + ACCOUNT SELECTION
      // =====================================================

      final user = await AuthService.instance.signInWithGoogle();

      // User cancelled Google account selection
      if (user == null) {
        return;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final DocumentReference<Map<String, dynamic>> userRef = firestore
          .collection('users')
          .doc(user.uid);

      // =====================================================
      // CHECK USER
      // =====================================================

      final DocumentSnapshot<Map<String, dynamic>> userDoc = await userRef
          .get();

      if (!userDoc.exists) {
        // ===================================================
        // NEW ACCOUNT
        // ===================================================

        await userRef.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'userRole': 'customer',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // ===================================================
        // EXISTING ACCOUNT
        // ===================================================

        final Map<String, dynamic> existingData = userDoc.data() ?? {};

        final Map<String, dynamic> updateData = {
          'name': user.displayName ?? existingData['name'] ?? '',
          'email': user.email ?? existingData['email'] ?? '',
          'photoUrl': user.photoURL ?? existingData['photoUrl'] ?? '',
          'lastLoginAt': FieldValue.serverTimestamp(),
        };

        // Never overwrite existing admin/staff role.
        if (!existingData.containsKey('userRole') ||
            existingData['userRole'] == null ||
            existingData['userRole'].toString().trim().isEmpty) {
          updateData['userRole'] = 'customer';
        }

        if (!existingData.containsKey('status') ||
            existingData['status'] == null) {
          updateData['status'] = 'active';
        }

        await userRef.set(updateData, SetOptions(merge: true));
      }

      // =====================================================
      // CHECK BUSINESS PROFILE
      // =====================================================

      final DocumentSnapshot<Map<String, dynamic>> businessProfileDoc =
          await userRef.collection('businessProfile').doc('profile').get();

      if (!mounted) return;

      // =====================================================
      // EXISTING ACCOUNT + EXISTING BUSINESS
      // GO DIRECTLY TO DASHBOARD
      // =====================================================

      if (businessProfileDoc.exists && businessProfileDoc.data() != null) {
        final Map<String, dynamic> businessProfile = businessProfileDoc.data()!;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(businessProfile: businessProfile),
          ),
          (route) => false,
        );

        return;
      }

      // =====================================================
      // ACCOUNT EXISTS BUT NO BUSINESS PROFILE
      // OR COMPLETELY NEW ACCOUNT
      // =====================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const EntrepreneurIntroScreen()),
        (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('Login/Profile Check Error: $e');
      debugPrint('StackTrace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Sign in failed: $e')),
            ],
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ==================================================
          // BACKGROUND
          // ==================================================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF312E81),
                  Color(0xFF2563EB),
                  Color(0xFF06B6D4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // ==================================================
          // DECORATIVE GLOW 1
          // ==================================================
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.08),
              ),
            ),
          ),

          // ==================================================
          // DECORATIVE GLOW 2
          // ==================================================
          Positioned(
            top: size.height * .30,
            left: -100,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(.06),
              ),
            ),
          ),

          // ==================================================
          // DECORATIVE GLOW 3
          // ==================================================
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(.08),
              ),
            ),
          ),

          // ==================================================
          // MAIN CONTENT
          // ==================================================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 70),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // =========================================
                    // BRAND LOGO
                    // =========================================
                    Container(
                      height: 110,
                      width: 110,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.14),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(.20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.18),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =========================================
                    // HERO TEXT
                    // =========================================
                    const Text(
                      'Build Smarter.\nGrow Faster.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -.7,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Your AI-powered business companion for ideas, branding, websites and compliance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.55,
                        color: Colors.white.withOpacity(.75),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =========================================
                    // BENEFITS
                    // =========================================
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 9,
                      runSpacing: 9,
                      children: [
                        _featureChip(Icons.auto_awesome, 'AI Business Ideas'),
                        _featureChip(Icons.language, 'Website Builder'),
                        _featureChip(Icons.design_services, 'Brand Kit'),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // =========================================
                    // LOGIN GLASS CARD
                    // =========================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.16),
                            blurRadius: 35,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'WELCOME',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'Continue to Velai',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Sign in once and we’ll take you directly to your business workspace.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white.withOpacity(.70),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ===================================
                          // GOOGLE BUTTON
                          // ===================================
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                disabledBackgroundColor: Colors.white
                                    .withOpacity(.80),
                                foregroundColor: const Color(0xFF111827),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _isLoading
                                    ? const Row(
                                        key: ValueKey('loading'),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                          SizedBox(width: 14),
                                          Text(
                                            'Checking your business profile...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        key: ValueKey('google'),
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.google,
                                            size: 21,
                                            color: Color(0xFF4285F4),
                                          ),
                                          SizedBox(width: 14),
                                          Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 15,
                                color: Colors.white.withOpacity(.65),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Secure Google authentication',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.65),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================================
                    // USER JOURNEY INFO
                    // =========================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.07),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.psychology_alt,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              'New user? Our AI assessment will discover a suitable business for you.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.80),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.55),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Velai • Your Business Companion',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.50),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FEATURE CHIP
  // ==========================================================

  Widget _featureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
