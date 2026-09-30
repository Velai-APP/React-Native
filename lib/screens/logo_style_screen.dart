import 'package:flutter/material.dart';

import 'logo_generation_screen.dart';

class LogoStyleScreen extends StatefulWidget {
  final String businessName;
  final String industry;
  final String businessDescription;
  final String targetAudience;
  final String tagline;
  final String website;
  final bool isExistingBusiness;

  final List<String> personalities;
  final List<String> brandValues;
  final String brandVoice;
  final String audienceFeeling;

  const LogoStyleScreen({
    super.key,
    required this.businessName,
    required this.industry,
    required this.businessDescription,
    required this.targetAudience,
    required this.tagline,
    required this.website,
    required this.isExistingBusiness,
    required this.personalities,
    required this.brandValues,
    required this.brandVoice,
    required this.audienceFeeling,
  });

  @override
  State<LogoStyleScreen> createState() => _LogoStyleScreenState();
}

class _LogoStyleScreenState extends State<LogoStyleScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  String? _selectedLogoStyle;
  String? _selectedLogoType;
  String? _selectedColorDirection;
  String? _selectedSymbolPreference;
  String? _selectedFontStyle;

  final List<LogoStyleItem> _logoStyles = const [
    LogoStyleItem(
      title: 'Minimal',
      description: 'Clean shapes, simple lines and uncluttered composition',
      icon: Icons.crop_square_rounded,
      previewIcon: Icons.hexagon_outlined,
      color: Color(0xFF334155),
    ),
    LogoStyleItem(
      title: 'Modern',
      description: 'Contemporary, sharp and suitable for growing brands',
      icon: Icons.auto_awesome_outlined,
      previewIcon: Icons.change_circle_outlined,
      color: Color(0xFF2563EB),
    ),
    LogoStyleItem(
      title: 'Luxury',
      description: 'Elegant, refined and premium visual presentation',
      icon: Icons.diamond_outlined,
      previewIcon: Icons.diamond_rounded,
      color: Color(0xFF7C3AED),
    ),
    LogoStyleItem(
      title: 'Bold',
      description: 'Strong forms, confident type and high visual impact',
      icon: Icons.bolt_outlined,
      previewIcon: Icons.bolt_rounded,
      color: Color(0xFFE11D48),
    ),
    LogoStyleItem(
      title: 'Playful',
      description: 'Friendly, colourful and expressive visual identity',
      icon: Icons.celebration_outlined,
      previewIcon: Icons.bubble_chart_rounded,
      color: Color(0xFFF59E0B),
    ),
    LogoStyleItem(
      title: 'Organic',
      description: 'Natural forms, calm curves and earthy inspiration',
      icon: Icons.eco_outlined,
      previewIcon: Icons.eco_rounded,
      color: Color(0xFF059669),
    ),
    LogoStyleItem(
      title: 'Classic',
      description: 'Traditional, established and professionally balanced',
      icon: Icons.account_balance_outlined,
      previewIcon: Icons.shield_outlined,
      color: Color(0xFF92400E),
    ),
    LogoStyleItem(
      title: 'Futuristic',
      description: 'Innovative, digital and technology-focused appearance',
      icon: Icons.rocket_launch_outlined,
      previewIcon: Icons.blur_circular_rounded,
      color: Color(0xFF0891B2),
    ),
  ];

  final List<LogoTypeItem> _logoTypes = const [
    LogoTypeItem(
      title: 'Wordmark',
      description: 'Business name designed using distinctive typography',
      icon: Icons.text_fields_rounded,
      example: 'NEXORA',
    ),
    LogoTypeItem(
      title: 'Lettermark',
      description: 'Initials or abbreviated letters used as the main logo',
      icon: Icons.font_download_outlined,
      example: 'TN',
    ),
    LogoTypeItem(
      title: 'Icon Mark',
      description: 'A recognizable symbol without the full business name',
      icon: Icons.category_outlined,
      example: '◆',
    ),
    LogoTypeItem(
      title: 'Combination Mark',
      description: 'Business name combined with a unique visual symbol',
      icon: Icons.dashboard_customize_outlined,
      example: '◆ NEXORA',
    ),
    LogoTypeItem(
      title: 'Emblem',
      description: 'Text contained within a badge, crest or seal',
      icon: Icons.workspace_premium_outlined,
      example: 'N',
    ),
  ];

  final List<ColorDirectionItem> _colorDirections = const [
    ColorDirectionItem(
      title: 'Professional Blue',
      description: 'Trustworthy and corporate',
      colors: [
        Color(0xFF1E3A8A),
        Color(0xFF2563EB),
        Color(0xFF93C5FD),
        Color(0xFFF8FAFC),
      ],
    ),
    ColorDirectionItem(
      title: 'Premium Dark',
      description: 'Elegant and high-value',
      colors: [
        Color(0xFF111827),
        Color(0xFF374151),
        Color(0xFFD4AF37),
        Color(0xFFF9FAFB),
      ],
    ),
    ColorDirectionItem(
      title: 'Natural Green',
      description: 'Organic and sustainable',
      colors: [
        Color(0xFF14532D),
        Color(0xFF16A34A),
        Color(0xFFA3E635),
        Color(0xFFF7FEE7),
      ],
    ),
    ColorDirectionItem(
      title: 'Creative Purple',
      description: 'Innovative and imaginative',
      colors: [
        Color(0xFF581C87),
        Color(0xFF7C3AED),
        Color(0xFFC084FC),
        Color(0xFFFAF5FF),
      ],
    ),
    ColorDirectionItem(
      title: 'Energetic Warm',
      description: 'Bold and attention-grabbing',
      colors: [
        Color(0xFF9A3412),
        Color(0xFFEA580C),
        Color(0xFFFBBF24),
        Color(0xFFFFFBEB),
      ],
    ),
    ColorDirectionItem(
      title: 'Soft Pastel',
      description: 'Friendly and approachable',
      colors: [
        Color(0xFFF9A8D4),
        Color(0xFFC4B5FD),
        Color(0xFF93C5FD),
        Color(0xFFFFF7ED),
      ],
    ),
    ColorDirectionItem(
      title: 'Monochrome',
      description: 'Clean, simple and timeless',
      colors: [
        Color(0xFF111827),
        Color(0xFF6B7280),
        Color(0xFFD1D5DB),
        Color(0xFFFFFFFF),
      ],
    ),
    ColorDirectionItem(
      title: 'Let AI Decide',
      description: 'Based on your brand personality',
      colors: [
        Color(0xFF2563EB),
        Color(0xFF7C3AED),
        Color(0xFFE11D48),
        Color(0xFFF59E0B),
      ],
    ),
  ];

  final List<SelectionOption> _symbolOptions = const [
    SelectionOption(
      title: 'Abstract Symbol',
      description: 'Unique geometric or conceptual shape',
      icon: Icons.blur_on_rounded,
    ),
    SelectionOption(
      title: 'Industry Symbol',
      description: 'Visual connected to your business category',
      icon: Icons.business_center_outlined,
    ),
    SelectionOption(
      title: 'Initials',
      description: 'Use business initials as the main symbol',
      icon: Icons.font_download_outlined,
    ),
    SelectionOption(
      title: 'Nature Inspired',
      description: 'Leaves, growth, earth or natural forms',
      icon: Icons.eco_outlined,
    ),
    SelectionOption(
      title: 'No Symbol',
      description: 'Typography-focused logo without an icon',
      icon: Icons.text_fields_rounded,
    ),
    SelectionOption(
      title: 'Let AI Decide',
      description: 'AI selects the most suitable direction',
      icon: Icons.auto_awesome,
    ),
  ];

  final List<SelectionOption> _fontOptions = const [
    SelectionOption(
      title: 'Clean Sans Serif',
      description: 'Modern, clear and highly readable',
      icon: Icons.title_rounded,
    ),
    SelectionOption(
      title: 'Elegant Serif',
      description: 'Sophisticated and traditional',
      icon: Icons.format_size_rounded,
    ),
    SelectionOption(
      title: 'Bold Display',
      description: 'Strong, expressive and attention-grabbing',
      icon: Icons.text_increase_rounded,
    ),
    SelectionOption(
      title: 'Friendly Rounded',
      description: 'Soft, welcoming and approachable',
      icon: Icons.text_format_rounded,
    ),
    SelectionOption(
      title: 'Handcrafted',
      description: 'Personal, creative and artistic',
      icon: Icons.draw_outlined,
    ),
    SelectionOption(
      title: 'Let AI Decide',
      description: 'AI matches typography with your brand',
      icon: Icons.auto_awesome,
    ),
  ];

  void _continueToGeneration() {
    if (_selectedLogoStyle == null) {
      _showMessage('Select a visual logo style.');
      return;
    }

    if (_selectedLogoType == null) {
      _showMessage('Select your preferred logo type.');
      return;
    }

    if (_selectedColorDirection == null) {
      _showMessage('Select a colour direction.');
      return;
    }

    if (_selectedSymbolPreference == null) {
      _showMessage('Select a symbol preference.');
      return;
    }

    if (_selectedFontStyle == null) {
      _showMessage('Select a typography style.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogoGenerationScreen(
          businessName: widget.businessName,
          industry: widget.industry,
          businessDescription: widget.businessDescription,
          targetAudience: widget.targetAudience,
          tagline: widget.tagline,
          website: widget.website,
          isExistingBusiness: widget.isExistingBusiness,
          personalities: widget.personalities,
          brandValues: widget.brandValues,
          brandVoice: widget.brandVoice,
          audienceFeeling: widget.audienceFeeling,
          logoStyle: _selectedLogoStyle!,
          logoType: _selectedLogoType!,
          colorDirection: _selectedColorDirection!,
          symbolPreference: _selectedSymbolPreference!,
          fontStyle: _selectedFontStyle!,
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
          'Logo Style',
          style: TextStyle(fontWeight: FontWeight.bold),
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
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProgressSection(currentStep: 3, totalSteps: 4),
                  const SizedBox(height: 28),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBrandDirectionCard(),
                  const SizedBox(height: 26),
                  _buildLogoStyleSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildLogoTypeSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildColorSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildSymbolSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildFontSection(isDesktop),
                  const SizedBox(height: 26),
                  _buildSelectionSummary(),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(),
                  const SizedBox(height: 32),
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
          'Choose your visual direction',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Select the style, logo format, colours and typography that best represent your business.',
          style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildBrandDirectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
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
                const SizedBox(height: 5),
                Text(
                  widget.personalities.join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit personality',
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.edit_outlined, color: primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoStyleSection(bool isDesktop) {
    return _sectionCard(
      title: 'Select a visual style',
      subtitle: 'Choose the overall design direction for your logo.',
      child: GridView.builder(
        itemCount: _logoStyles.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: isDesktop ? 210 : 218,
        ),
        itemBuilder: (context, index) {
          return _logoStyleCard(_logoStyles[index]);
        },
      ),
    );
  }

  Widget _logoStyleCard(LogoStyleItem item) {
    final bool selected = _selectedLogoStyle == item.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLogoStyle = item.title;
          });
        },
        borderRadius: BorderRadius.circular(19),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? item.color.withOpacity(0.07)
                : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected ? item.color : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(item.previewIcon, size: 58, color: item.color),
                      if (selected)
                        Positioned(
                          right: 9,
                          top: 9,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: item.color,
                            size: 23,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 4, 13, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, size: 18, color: item.color),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoTypeSection(bool isDesktop) {
    return _sectionCard(
      title: 'Choose a logo type',
      subtitle: 'Select how your business name and symbol should appear.',
      child: GridView.builder(
        itemCount: _logoTypes.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 5 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 178,
        ),
        itemBuilder: (context, index) {
          return _logoTypeCard(_logoTypes[index]);
        },
      ),
    );
  }

  Widget _logoTypeCard(LogoTypeItem item) {
    final bool selected = _selectedLogoType == item.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLogoType = item.title;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? brightBlue.withOpacity(0.08)
                : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? brightBlue : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    item.icon,
                    color: selected ? brightBlue : Colors.grey.shade700,
                    size: 22,
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: brightBlue, size: 20),
                ],
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  item.example,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSection(bool isDesktop) {
    return _sectionCard(
      title: 'Choose a colour direction',
      subtitle: 'The AI will use this palette as a visual starting point.',
      child: GridView.builder(
        itemCount: _colorDirections.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 145,
        ),
        itemBuilder: (context, index) {
          return _colorDirectionCard(_colorDirections[index]);
        },
      ),
    );
  }

  Widget _colorDirectionCard(ColorDirectionItem item) {
    final bool selected = _selectedColorDirection == item.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedColorDirection = item.title;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? brightBlue.withOpacity(0.06)
                : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? brightBlue : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: item.colors.map((color) {
                  return Expanded(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle, color: brightBlue, size: 19),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolSection(bool isDesktop) {
    return _sectionCard(
      title: 'Symbol preference',
      subtitle: 'Choose what kind of icon or symbol should appear in the logo.',
      child: GridView.builder(
        itemCount: _symbolOptions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 134,
        ),
        itemBuilder: (context, index) {
          final item = _symbolOptions[index];

          return _selectionCard(
            item: item,
            selected: _selectedSymbolPreference == item.title,
            onTap: () {
              setState(() {
                _selectedSymbolPreference = item.title;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFontSection(bool isDesktop) {
    return _sectionCard(
      title: 'Typography style',
      subtitle: 'Choose the type of lettering that suits your brand.',
      child: GridView.builder(
        itemCount: _fontOptions.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 134,
        ),
        itemBuilder: (context, index) {
          final item = _fontOptions[index];

          return _selectionCard(
            item: item,
            selected: _selectedFontStyle == item.title,
            onTap: () {
              setState(() {
                _selectedFontStyle = item.title;
              });
            },
          );
        },
      ),
    );
  }

  Widget _selectionCard({
    required SelectionOption item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
              color: selected ? brightBlue : borderColor,
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
                    color: selected ? brightBlue : Colors.grey.shade700,
                    size: 25,
                  ),
                  const Spacer(),
                  if (selected)
                    const Icon(Icons.check_circle, color: brightBlue, size: 20),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13.5,
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
                  fontSize: 10.8,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionSummary() {
    final bool hasSelection =
        _selectedLogoStyle != null ||
        _selectedLogoType != null ||
        _selectedColorDirection != null ||
        _selectedSymbolPreference != null ||
        _selectedFontStyle != null;

    if (!hasSelection) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.visibility_outlined, color: brightBlue),
              SizedBox(width: 9),
              Text(
                'Selected visual direction',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_selectedLogoStyle != null)
            _summaryRow('Style', _selectedLogoStyle!),
          if (_selectedLogoType != null)
            _summaryRow('Logo type', _selectedLogoType!),
          if (_selectedColorDirection != null)
            _summaryRow('Colours', _selectedColorDirection!),
          if (_selectedSymbolPreference != null)
            _summaryRow('Symbol', _selectedSymbolPreference!),
          if (_selectedFontStyle != null)
            _summaryRow(
              'Typography',
              _selectedFontStyle!,
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
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 8 : 0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, height: 1.4),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Color(0xFF334155)),
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
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
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
                side: const BorderSide(color: primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: _continueToGeneration,
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
                  Icon(Icons.auto_awesome, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Generate 4 Logo Concepts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class LogoStyleItem {
  final String title;
  final String description;
  final IconData icon;
  final IconData previewIcon;
  final Color color;

  const LogoStyleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.previewIcon,
    required this.color,
  });
}

class LogoTypeItem {
  final String title;
  final String description;
  final IconData icon;
  final String example;

  const LogoTypeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.example,
  });
}

class ColorDirectionItem {
  final String title;
  final String description;
  final List<Color> colors;

  const ColorDirectionItem({
    required this.title,
    required this.description,
    required this.colors,
  });
}

class SelectionOption {
  final String title;
  final String description;
  final IconData icon;

  const SelectionOption({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _ProgressSection extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressSection({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final int percentage = ((currentStep / totalSteps) * 100).round();

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
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: List.generate(totalSteps, (index) {
            final bool active = index < currentStep;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 6,
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 7),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFDDE3EC),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
