import 'dart:ui';

import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData smallIcon;
  final String tag;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.smallIcon,
    required this.tag,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Center(
              child: _VisualCard(
                icon: icon,
                smallIcon: smallIcon,
                pageIndex: pageIndex,
              ),
            ),
          ),

          const SizedBox(height: 15),

          /// TAG
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF61E8F4)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFF61E8F4)
                      .withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF61E8F4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF6BE7F5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// TITLE
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.1,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// DESCRIPTION
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _VisualCard extends StatelessWidget {
  final IconData icon;
  final IconData smallIcon;
  final int pageIndex;

  const _VisualCard({
    required this.icon,
    required this.smallIcon,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// OUTER CIRCLE
          Container(
            width: 245,
            height: 245,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF62EAF5)
                    .withValues(alpha: 0.10),
              ),
            ),
          ),

          /// MAIN GLASS CARD
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18,
                sigmaY: 18,
              ),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF45DCE8)
                          .withValues(alpha: 0.10),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF67ECF4),
                          Color(0xFF6574FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF62E8F5)
                              .withValues(alpha: 0.28),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// FLOATING TOP-RIGHT CARD
          Positioned(
            top: 32,
            right: 18,
            child: _FloatingBadge(
              icon: smallIcon,
              label: _badgeText(),
            ),
          ),

          /// FLOATING BOTTOM LEFT
          Positioned(
            bottom: 30,
            left: 13,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2545)
                    .withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.09),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1CBA9D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    _bottomText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _badgeText() {
    switch (pageIndex) {
      case 0:
        return "Smart Match";
      case 1:
        return "Profile Ready";
      default:
        return "Career Growth";
    }
  }

  String _bottomText() {
    switch (pageIndex) {
      case 0:
        return "Opportunities for you";
      case 1:
        return "Stand out to employers";
      default:
        return "You're ready to begin";
    }
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FloatingBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF122A4D)
            .withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6DE7F4),
            size: 18,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}