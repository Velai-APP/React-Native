import 'package:flutter/material.dart';

import 'logo_style_screen.dart';

class BrandPersonalityScreen extends StatefulWidget {
  final String businessName;
  final String industry;
  final String businessDescription;
  final String targetAudience;
  final String tagline;
  final String website;
  final bool isExistingBusiness;

  const BrandPersonalityScreen({
    super.key,
    required this.businessName,
    required this.industry,
    required this.businessDescription,
    required this.targetAudience,
    required this.tagline,
    required this.website,
    required this.isExistingBusiness,
  });

  @override
  State<BrandPersonalityScreen> createState() =>
      _BrandPersonalityScreenState();
}

class _BrandPersonalityScreenState
    extends State<BrandPersonalityScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  final Set<String> _selectedPersonalities = {};
  final Set<String> _selectedValues = {};

  String? _selectedVoice;
  String? _selectedAudienceFeeling;

  final List<BrandPersonalityItem> _personalities = const [
    BrandPersonalityItem(
      title: 'Professional',
      description: 'Reliable, structured and business-focused',
      icon: Icons.business_center_outlined,
      color: Color(0xFF2563EB),
    ),
    BrandPersonalityItem(
      title: 'Modern',
      description: 'Fresh, progressive and contemporary',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFF7C3AED),
    ),
    BrandPersonalityItem(
      title: 'Friendly',
      description: 'Warm, approachable and welcoming',
      icon: Icons.sentiment_satisfied_alt_outlined,
      color: Color(0xFFEA580C),
    ),
    BrandPersonalityItem(
      title: 'Premium',
      description: 'Exclusive, refined and high-value',
      icon: Icons.diamond_outlined,
      color: Color(0xFF9333EA),
    ),
    BrandPersonalityItem(
      title: 'Bold',
      description: 'Confident, energetic and attention-grabbing',
      icon: Icons.bolt_outlined,
      color: Color(0xFFE11D48),
    ),
    BrandPersonalityItem(
      title: 'Minimal',
      description: 'Simple, clear and uncluttered',
      icon: Icons.crop_square_rounded,
      color: Color(0xFF334155),
    ),
    BrandPersonalityItem(
      title: 'Playful',
      description: 'Fun, creative and full of personality',
      icon: Icons.celebration_outlined,
      color: Color(0xFFF59E0B),
    ),
    BrandPersonalityItem(
      title: 'Trustworthy',
      description: 'Dependable, secure and credible',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF059669),
    ),
    BrandPersonalityItem(
      title: 'Innovative',
      description: 'Original, imaginative and future-focused',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFF0891B2),
    ),
    BrandPersonalityItem(
      title: 'Elegant',
      description: 'Graceful, sophisticated and timeless',
      icon: Icons.auto_fix_high_outlined,
      color: Color(0xFFBE185D),
    ),
    BrandPersonalityItem(
      title: 'Organic',
      description: 'Natural, calm and environmentally conscious',
      icon: Icons.eco_outlined,
      color: Color(0xFF16A34A),
    ),
    BrandPersonalityItem(
      title: 'Youthful',
      description: 'Energetic, vibrant and trend-aware',
      icon: Icons.rocket_launch_outlined,
      color: Color(0xFFDB2777),
    ),
  ];

  final List<String> _brandValues = const [
    'Quality',
    'Trust',
    'Innovation',
    'Affordability',
    'Sustainability',
    'Customer Care',
    'Speed',
    'Transparency',
    'Creativity',
    'Expertise',
    'Community',
    'Simplicity',
  ];

  final List<VoiceOption> _voiceOptions = const [
    VoiceOption(
      title: 'Formal',
      description: 'Clear, professional and authoritative',
      icon: Icons.account_balance_outlined,
    ),
    VoiceOption(
      title: 'Conversational',
      description: 'Natural, relatable and easy to understand',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    VoiceOption(
      title: 'Inspirational',
      description: 'Positive, motivating and emotionally engaging',
      icon: Icons.light_mode_outlined,
    ),
    VoiceOption(
      title: 'Bold',
      description: 'Direct, confident and action-oriented',
      icon: Icons.campaign_outlined,
    ),
  ];

  final List<FeelingOption> _audienceFeelings = const [
    FeelingOption(
      title: 'Confident',
      icon: Icons.workspace_premium_outlined,
    ),
    FeelingOption(
      title: 'Excited',
      icon: Icons.celebration_outlined,
    ),
    FeelingOption(
      title: 'Safe',
      icon: Icons.shield_outlined,
    ),
    FeelingOption(
      title: 'Inspired',
      icon: Icons.auto_awesome_outlined,
    ),
    FeelingOption(
      title: 'Connected',
      icon: Icons.people_alt_outlined,
    ),
    FeelingOption(
      title: 'Relaxed',
      icon: Icons.spa_outlined,
    ),
  ];

  void _togglePersonality(String personality) {
    setState(() {
      if (_selectedPersonalities.contains(personality)) {
        _selectedPersonalities.remove(personality);
      } else {
        if (_selectedPersonalities.length >= 4) {
          _showMessage(
            'Select a maximum of four brand personalities.',
          );
          return;
        }

        _selectedPersonalities.add(personality);
      }
    });
  }

  void _toggleValue(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        if (_selectedValues.length >= 4) {
          _showMessage(
            'Select a maximum of four core values.',
          );
          return;
        }

        _selectedValues.add(value);
      }
    });
  }

  void _continueToLogoStyle() {
    if (_selectedPersonalities.length < 2) {
      _showMessage(
        'Select at least two brand personalities.',
      );
      return;
    }

    if (_selectedValues.length < 2) {
      _showMessage(
        'Select at least two brand values.',
      );
      return;
    }

    if (_selectedVoice == null) {
      _showMessage(
        'Select your preferred brand voice.',
      );
      return;
    }

    if (_selectedAudienceFeeling == null) {
      _showMessage(
        'Select how your audience should feel.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogoStyleScreen(
          businessName: widget.businessName,
          industry: widget.industry,
          businessDescription: widget.businessDescription,
          targetAudience: widget.targetAudience,
          tagline: widget.tagline,
          website: widget.website,
          isExistingBusiness: widget.isExistingBusiness,
          personalities: _selectedPersonalities.toList(),
          brandValues: _selectedValues.toList(),
          brandVoice: _selectedVoice!,
          audienceFeeling: _selectedAudienceFeeling!,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Brand Personality',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : 18,
            vertical: 22,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 950,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProgressSection(
                    currentStep: 2,
                    totalSteps: 4,
                  ),
                  const SizedBox(height: 28),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBusinessSummary(),
                  const SizedBox(height: 26),
                  _buildPersonalitySection(isDesktop),
                  const SizedBox(height: 26),
                  _buildValuesSection(),
                  const SizedBox(height: 26),
                  _buildVoiceSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildFeelingSection(isDesktop),
                  const SizedBox(height: 28),
                  _buildSelectionSummary(),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How should your brand feel?',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Choose the traits, values and communication style that should define your brand identity.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF5F3FF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.industry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit business details',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalitySection(bool isDesktop) {
    return _sectionCard(
      title: 'Select your brand personality',
      subtitle:
          'Choose two to four traits that best describe the brand.',
      trailing:
          '${_selectedPersonalities.length}/4 selected',
      child: GridView.builder(
        itemCount: _personalities.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: isDesktop ? 146 : 165,
        ),
        itemBuilder: (context, index) {
          final BrandPersonalityItem item =
              _personalities[index];

          return _personalityCard(item);
        },
      ),
    );
  }

  Widget _personalityCard(BrandPersonalityItem item) {
    final bool selected =
        _selectedPersonalities.contains(item.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePersonality(item.title),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? item.color.withOpacity(0.08)
                : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? item.color : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: item.color,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValuesSection() {
    return _sectionCard(
      title: 'What does your brand stand for?',
      subtitle:
          'Select two to four values that should guide the brand.',
      trailing: '${_selectedValues.length}/4 selected',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _brandValues.map((value) {
          final bool selected =
              _selectedValues.contains(value);

          return FilterChip(
            label: Text(value),
            selected: selected,
            showCheckmark: false,
            avatar: selected
                ? const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: brightBlue,
                  )
                : null,
            labelStyle: TextStyle(
              color: selected ? primaryBlue : textColor,
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
            selectedColor: brightBlue.withOpacity(0.10),
            backgroundColor: const Color(0xFFF9FAFC),
            side: BorderSide(
              color: selected ? brightBlue : borderColor,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 9,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onSelected: (_) => _toggleValue(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVoiceSection(bool isDesktop) {
    return _sectionCard(
      title: 'Choose your brand voice',
      subtitle:
          'How should your brand communicate with customers?',
      child: GridView.builder(
        itemCount: _voiceOptions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 145,
        ),
        itemBuilder: (context, index) {
          final VoiceOption item = _voiceOptions[index];
          final bool selected =
              _selectedVoice == item.title;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedVoice = item.title;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selected
                      ? brightBlue.withOpacity(0.08)
                      : const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        selected ? brightBlue : borderColor,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? brightBlue
                              : Colors.grey.shade700,
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: brightBlue,
                            size: 21,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeelingSection(bool isDesktop) {
    return _sectionCard(
      title: 'How should customers feel?',
      subtitle:
          'Choose the main emotion your brand should create.',
      child: GridView.builder(
        itemCount: _audienceFeelings.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 6 : 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 108,
        ),
        itemBuilder: (context, index) {
          final FeelingOption item =
              _audienceFeelings[index];

          final bool selected =
              _selectedAudienceFeeling == item.title;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAudienceFeeling = item.title;
                });
              },
              borderRadius: BorderRadius.circular(17),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: selected
                      ? brightBlue.withOpacity(0.09)
                      : const Color(0xFFF9FAFC),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color:
                        selected ? brightBlue : borderColor,
                    width: selected ? 1.7 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 27,
                      color: selected
                          ? brightBlue
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            selected ? primaryBlue : textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final bool hasSelections =
        _selectedPersonalities.isNotEmpty ||
            _selectedValues.isNotEmpty ||
            _selectedVoice != null ||
            _selectedAudienceFeeling != null;

    if (!hasSelections) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: brightBlue,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Your brand direction',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedPersonalities.isNotEmpty)
            _summaryRow(
              'Personality',
              _selectedPersonalities.join(', '),
            ),
          if (_selectedValues.isNotEmpty)
            _summaryRow(
              'Values',
              _selectedValues.join(', '),
            ),
          if (_selectedVoice != null)
            _summaryRow(
              'Voice',
              _selectedVoice!,
            ),
          if (_selectedAudienceFeeling != null)
            _summaryRow(
              'Customer feeling',
              _selectedAudienceFeeling!,
              showBottomSpacing: false,
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool showBottomSpacing = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing ? 8 : 0,
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: brightBlue.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(
                  color: primaryBlue,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
              label: const Text(
                'Back',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _continueToLogoStyle,
              style: FilledButton.styleFrom(
                backgroundColor: brightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Continue to Logo Style',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BrandPersonalityItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const BrandPersonalityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class VoiceOption {
  final String title;
  final String description;
  final IconData icon;

  const VoiceOption({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class FeelingOption {
  final String title;
  final IconData icon;

  const FeelingOption({
    required this.title,
    required this.icon,
  });
}

class _ProgressSection extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressSection({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage =
        ((currentStep / totalSteps) * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '$percentage% complete',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: List.generate(
            totalSteps,
            (index) {
              final bool active = index < currentStep;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 250,
                  ),
                  height: 6,
                  margin: EdgeInsets.only(
                    right:
                        index == totalSteps - 1 ? 0 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFDDE3EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}