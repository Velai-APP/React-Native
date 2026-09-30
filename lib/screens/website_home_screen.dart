import 'package:flutter/material.dart';

import 'ai_website_builder_screen.dart';
import 'my_websites_screen.dart';

class WebsiteHomeScreen extends StatelessWidget {
  const WebsiteHomeScreen({super.key});

  Future<void> _openCreateWebsite(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const WebsiteBuilderScreen()));
  }

  void _openMyWebsites(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MyWebsitesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: Stack(
        children: [
          const Positioned.fill(child: _WebsiteHomeBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 24),
                      _buildHero(),
                      const SizedBox(height: 26),
                      const Text(
                        'Website tools',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF201E2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create a new website or manage your existing websites.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF77758A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 620;

                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _WebsiteActionCard(
                                    title: 'Create Website',
                                    description:
                                        'Describe your business and let AI design and publish your website.',
                                    icon: Icons.auto_awesome_rounded,
                                    gradientColors: const [
                                      Color(0xFF8C62FF),
                                      Color(0xFF5B42E8),
                                    ],
                                    buttonText: 'Create with AI',
                                    onTap: () => _openCreateWebsite(context),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _WebsiteActionCard(
                                    title: 'My Websites',
                                    description:
                                        'View website progress, copy links and open your live websites.',
                                    icon: Icons.language_rounded,
                                    gradientColors: const [
                                      Color(0xFF19C59A),
                                      Color(0xFF008F73),
                                    ],
                                    buttonText: 'View websites',
                                    onTap: () => _openMyWebsites(context),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _WebsiteActionCard(
                                title: 'Create Website',
                                description:
                                    'Describe your business and let AI design and publish your website.',
                                icon: Icons.auto_awesome_rounded,
                                gradientColors: const [
                                  Color(0xFF8C62FF),
                                  Color(0xFF5B42E8),
                                ],
                                buttonText: 'Create with AI',
                                onTap: () => _openCreateWebsite(context),
                              ),
                              const SizedBox(height: 16),
                              _WebsiteActionCard(
                                title: 'My Websites',
                                description:
                                    'View website progress, copy links and open your live websites.',
                                icon: Icons.language_rounded,
                                gradientColors: const [
                                  Color(0xFF19C59A),
                                  Color(0xFF008F73),
                                ],
                                buttonText: 'View websites',
                                onTap: () => _openMyWebsites(context),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildInformationCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFF201E2E),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Website Studio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF201E2E),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Build and manage your websites',
                style: TextStyle(fontSize: 13, color: Color(0xFF77758A)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17142B), Color(0xFF3B2878), Color(0xFF6C4DFF)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336C4DFF),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -45,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 45,
            bottom: -75,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 17,
                      color: Color(0xFFFFD166),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'AI Website Builder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Create your business\nwebsite in minutes.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Generate, publish and manage your business websites from one place.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF292736),
            ),
          ),
          SizedBox(height: 16),
          _ProcessRow(
            number: '1',
            title: 'Enter business details',
            description:
                'Tell us about your business, services and contact details.',
          ),
          _ProcessRow(
            number: '2',
            title: 'Start generation',
            description:
                'The website is created and published in the background.',
          ),
          _ProcessRow(
            number: '3',
            title: 'Receive notification',
            description:
                'Open My Websites to view and share the completed website.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _WebsiteActionCard extends StatelessWidget {
  const _WebsiteActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.buttonText,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE9E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF272535),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF77758A),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: Icon(icon, size: 20),
                  label: Text(buttonText),
                  style: FilledButton.styleFrom(
                    backgroundColor: gradientColors.last,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String number;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6C4DFF),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: const Color(0xFFE4E0F6),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333143),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF77758A),
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
}

class _WebsiteHomeBackground extends StatelessWidget {
  const _WebsiteHomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5FA),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x176C4DFF),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -100,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1200A67E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
