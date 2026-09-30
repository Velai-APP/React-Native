import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sop_generator_screen.dart';
import 'my_sops_screen.dart';

class SopHomeScreen extends StatefulWidget {
  const SopHomeScreen({super.key});

  @override
  State<SopHomeScreen> createState() => _SopHomeScreenState();
}

class _SopHomeScreenState extends State<SopHomeScreen> {
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 35),
                children: [
                  _buildHero(),

                  const SizedBox(height: 22),

                  _buildStats(),

                  const SizedBox(height: 24),

                  _sectionHeader(
                    title: 'SOP Workspace',
                    subtitle: 'Create, manage and access your procedures',
                  ),

                  const SizedBox(height: 14),

                  _buildGenerateCard(),

                  const SizedBox(height: 14),

                  _buildViewSopCard(),

                  const SizedBox(height: 25),

                  _buildWhySop(),

                  const SizedBox(height: 20),

                  _buildTip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(.22),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              height: 210,
              width: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            right: 30,
            child: Container(
              height: 190,
              width: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(.08),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.11),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFE9D5FF),
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI WORKSPACE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                height: 68,
                width: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.13),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(.10)),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),

              const SizedBox(height: 19),

              const Text(
                'SOP Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  letterSpacing: -.8,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Create professional Standard Operating Procedures\nand keep every process organised.',
                style: TextStyle(
                  color: Colors.white.withOpacity(.72),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  _heroBadge(icon: Icons.auto_awesome, text: 'AI Powered'),
                  const SizedBox(width: 8),
                  _heroBadge(
                    icon: Icons.cloud_done_outlined,
                    text: 'Cloud Saved',
                  ),
                  const SizedBox(width: 8),
                  _heroBadge(icon: Icons.lock_outline, text: 'Secure'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sops')
          .snapshots(),
      builder: (context, snapshot) {
        final total = snapshot.data?.docs.length ?? 0;

        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.description_rounded,
                value: total.toString(),
                label: 'My SOPs',
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF3E8FF),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.auto_awesome,
                value: 'AI',
                label: 'Generator',
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _statCard(
                icon: Icons.cloud_done_rounded,
                value: 'Cloud',
                label: 'Storage',
                iconColor: const Color(0xFF059669),
                iconBg: const Color(0xFFD1FAE5),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5),
        ),
      ],
    );
  }

  // ============================================================
  // GENERATE SOP
  // ============================================================

  Widget _buildGenerateCard() {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SopGeneratorScreen()),
        );

        if (mounted) {
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(.20),
              blurRadius: 23,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Generate New SOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Let AI transform your workflow into a structured SOP.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.72),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              height: 39,
              width: 39,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VIEW SOP
  // ============================================================

  Widget _buildViewSopCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MySopsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE7E9EF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
                ),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.folder_copy_rounded,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View My SOPs',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Access, review and manage all your saved procedures.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 39,
              width: 39,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF111827),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WHY SOP
  // ============================================================

  Widget _buildWhySop() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: Color(0xFF7C3AED),
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Build better processes',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _benefit(
            Icons.format_list_numbered_rounded,
            'Structured Procedures',
            'Turn informal workflows into clear step-by-step processes.',
          ),

          _benefit(
            Icons.verified_user_outlined,
            'Internal Controls',
            'Document checks, approvals and responsibilities.',
          ),

          _benefit(
            Icons.groups_2_outlined,
            'Team Clarity',
            'Help everyone understand who should do what.',
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIP
  // ============================================================

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFF7C3AED),
            size: 21,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Text(
              'Tip: Describe your actual workflow, approvals and controls while generating an SOP. More detail helps AI create a stronger procedure.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
