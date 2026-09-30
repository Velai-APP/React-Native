import 'package:flutter/material.dart';

import 'brand_kit_screen.dart';
import 'logo_generation_screen.dart';

class LogoEditorScreen extends StatefulWidget {
  final String? projectId;

  final String businessName;
  final String industry;
  final String businessDescription;
  final String targetAudience;
  final String tagline;

  final List<String> personalities;
  final List<String> brandValues;
  final String brandVoice;
  final String audienceFeeling;

  final String logoStyle;
  final String logoType;
  final String colorDirection;
  final String symbolPreference;
  final String fontStyle;

  final LogoConcept selectedLogo;
  final Map<String, dynamic> brandStrategy;

  const LogoEditorScreen({
    super.key,
    required this.projectId,
    required this.businessName,
    required this.industry,
    required this.businessDescription,
    required this.targetAudience,
    required this.tagline,
    required this.personalities,
    required this.brandValues,
    required this.brandVoice,
    required this.audienceFeeling,
    required this.logoStyle,
    required this.logoType,
    required this.colorDirection,
    required this.symbolPreference,
    required this.fontStyle,
    required this.selectedLogo,
    required this.brandStrategy,
  });

  @override
  State<LogoEditorScreen> createState() => _LogoEditorScreenState();
}

class _LogoEditorScreenState extends State<LogoEditorScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF059669);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  late final TextEditingController _businessNameController;
  late final TextEditingController _taglineController;

  double _logoScale = 1;
  double _logoRotation = 0;
  double _logoPadding = 24;
  double _horizontalPosition = 0;
  double _verticalPosition = 0;

  bool _showBusinessName = true;
  bool _showTagline = true;
  bool _showSafeArea = false;

  String _selectedBackground = 'Light';

  Color _customBackgroundColor = Colors.white;

  final List<_BackgroundOption> _backgroundOptions = const [
    _BackgroundOption(
      title: 'Light',
      color: Colors.white,
      icon: Icons.light_mode_outlined,
    ),
    _BackgroundOption(
      title: 'Dark',
      color: Color(0xFF111827),
      icon: Icons.dark_mode_outlined,
    ),
    _BackgroundOption(
      title: 'Brand',
      color: Color(0xFF1E3A8A),
      icon: Icons.palette_outlined,
    ),
    _BackgroundOption(
      title: 'Transparent',
      color: Color(0xFFF1F5F9),
      icon: Icons.grid_4x4_rounded,
    ),
    _BackgroundOption(
      title: 'Custom',
      color: Color(0xFFF8FAFC),
      icon: Icons.color_lens_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _businessNameController = TextEditingController(text: widget.businessName);

    _taglineController = TextEditingController(
      text: _strategyValue('tagline', fallback: widget.tagline),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  void _resetEditor() {
    setState(() {
      _businessNameController.text = widget.businessName;

      _taglineController.text = _strategyValue(
        'tagline',
        fallback: widget.tagline,
      );

      _logoScale = 1;
      _logoRotation = 0;
      _logoPadding = 24;
      _horizontalPosition = 0;
      _verticalPosition = 0;

      _showBusinessName = true;
      _showTagline = true;
      _showSafeArea = false;

      _selectedBackground = 'Light';
      _customBackgroundColor = Colors.white;
    });

    _showMessage('Logo editor reset.');
  }

  void _continueToBrandKit() {
    final String editedBusinessName = _businessNameController.text.trim();

    if (editedBusinessName.isEmpty) {
      _showMessage('Enter the business name.', isError: true);
      return;
    }

    final Map<String, dynamic> updatedStrategy = Map<String, dynamic>.from(
      widget.brandStrategy,
    );

    updatedStrategy['tagline'] = _taglineController.text.trim();

    updatedStrategy['logoEditor'] = {
      'businessName': editedBusinessName,
      'tagline': _taglineController.text.trim(),
      'scale': _logoScale,
      'rotation': _logoRotation,
      'padding': _logoPadding,
      'horizontalPosition': _horizontalPosition,
      'verticalPosition': _verticalPosition,
      'background': _selectedBackground,
      'customBackground': _colorToHex(_customBackgroundColor),
      'showBusinessName': _showBusinessName,
      'showTagline': _showTagline,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandKitScreen(
          projectId: widget.projectId,
          businessName: editedBusinessName,
          industry: widget.industry,
          businessDescription: widget.businessDescription,
          targetAudience: widget.targetAudience,
          tagline: _taglineController.text.trim(),
          personalities: widget.personalities,
          brandValues: widget.brandValues,
          brandVoice: widget.brandVoice,
          audienceFeeling: widget.audienceFeeling,
          logoStyle: widget.logoStyle,
          logoType: widget.logoType,
          colorDirection: widget.colorDirection,
          symbolPreference: widget.symbolPreference,
          fontStyle: widget.fontStyle,
          selectedLogo: widget.selectedLogo,
          brandStrategy: updatedStrategy,
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : successGreen,
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

    final bool isDesktop = screenWidth >= 950;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Logo Editor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset editor',
            onPressed: _resetEditor,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 38 : 18,
            22,
            isDesktop ? 38 : 18,
            120,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildPreviewSection()),
                        const SizedBox(width: 20),
                        Expanded(flex: 4, child: _buildEditorControls()),
                      ],
                    )
                  else ...[
                    _buildPreviewSection(),
                    const SizedBox(height: 20),
                    _buildEditorControls(),
                  ],
                  const SizedBox(height: 22),
                  _buildPreviewModes(),
                  const SizedBox(height: 22),
                  _buildEditorNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refine your selected logo',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Adjust the presentation of ${widget.selectedLogo.conceptName} before building the complete brand kit.',
          style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return _sectionCard(
      title: 'Live logo preview',
      subtitle: 'Changes made in the editor appear here immediately.',
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _previewBackgroundColor(),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (_selectedBackground == 'Transparent')
                    const Positioned.fill(child: _CheckerboardBackground()),
                  if (_showSafeArea)
                    Positioned(
                      left: 28,
                      top: 28,
                      right: 28,
                      bottom: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: brightBlue, width: 1.4),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  Center(
                    child: Transform.translate(
                      offset: Offset(_horizontalPosition, _verticalPosition),
                      child: Transform.rotate(
                        angle: _logoRotation,
                        child: Transform.scale(
                          scale: _logoScale,
                          child: Padding(
                            padding: EdgeInsets.all(_logoPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 310,
                                      maxHeight: 260,
                                    ),
                                    child: Image.network(
                                      widget.selectedLogo.imageUrl,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.broken_image_outlined,
                                              size: 65,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                if (_showBusinessName) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    _businessNameController.text.trim().isEmpty
                                        ? widget.businessName
                                        : _businessNameController.text.trim(),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _previewTextColor(),
                                      fontSize: 24,
                                      letterSpacing: 1.4,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                                if (_showTagline &&
                                    _taglineController.text
                                        .trim()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 7),
                                  Text(
                                    _taglineController.text.trim(),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _previewTextColor().withOpacity(
                                        0.72,
                                      ),
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.68),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _selectedBackground.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          letterSpacing: 0.7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _previewInformation(
                  Icons.zoom_out_map_rounded,
                  'Scale',
                  '${(_logoScale * 100).round()}%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _previewInformation(
                  Icons.rotate_right_rounded,
                  'Rotation',
                  '${(_logoRotation * 57.2958).round()}°',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _previewInformation(
                  Icons.padding_outlined,
                  'Padding',
                  '${_logoPadding.round()} px',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewInformation(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: brightBlue, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorControls() {
    return Column(
      children: [
        _sectionCard(
          title: 'Brand text',
          subtitle: 'Update the name and tagline displayed below the logo.',
          child: Column(
            children: [
              TextField(
                controller: _businessNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: _inputDecoration(
                  label: 'Business name',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _taglineController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: _inputDecoration(
                  label: 'Tagline',
                  icon: Icons.short_text_rounded,
                ),
              ),
              const SizedBox(height: 13),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showBusinessName,
                activeColor: brightBlue,
                title: const Text(
                  'Show business name',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (value) {
                  setState(() {
                    _showBusinessName = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showTagline,
                activeColor: brightBlue,
                title: const Text(
                  'Show tagline',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                onChanged: (value) {
                  setState(() {
                    _showTagline = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionCard(
          title: 'Logo adjustments',
          subtitle: 'Control the size, position and spacing of the logo.',
          child: Column(
            children: [
              _sliderControl(
                title: 'Logo scale',
                value: _logoScale,
                minimum: 0.5,
                maximum: 1.6,
                divisions: 22,
                displayValue: '${(_logoScale * 100).round()}%',
                onChanged: (value) {
                  setState(() {
                    _logoScale = value;
                  });
                },
              ),
              _sliderControl(
                title: 'Rotation',
                value: _logoRotation,
                minimum: -0.35,
                maximum: 0.35,
                divisions: 28,
                displayValue: '${(_logoRotation * 57.2958).round()}°',
                onChanged: (value) {
                  setState(() {
                    _logoRotation = value;
                  });
                },
              ),
              _sliderControl(
                title: 'Logo padding',
                value: _logoPadding,
                minimum: 0,
                maximum: 70,
                divisions: 14,
                displayValue: '${_logoPadding.round()} px',
                onChanged: (value) {
                  setState(() {
                    _logoPadding = value;
                  });
                },
              ),
              _sliderControl(
                title: 'Horizontal position',
                value: _horizontalPosition,
                minimum: -80,
                maximum: 80,
                divisions: 32,
                displayValue: '${_horizontalPosition.round()}',
                onChanged: (value) {
                  setState(() {
                    _horizontalPosition = value;
                  });
                },
              ),
              _sliderControl(
                title: 'Vertical position',
                value: _verticalPosition,
                minimum: -80,
                maximum: 80,
                divisions: 32,
                displayValue: '${_verticalPosition.round()}',
                onChanged: (value) {
                  setState(() {
                    _verticalPosition = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _showSafeArea,
                activeColor: brightBlue,
                title: const Text(
                  'Show safe area',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Displays the recommended clear space.',
                  style: TextStyle(fontSize: 11),
                ),
                onChanged: (value) {
                  setState(() {
                    _showSafeArea = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionCard(
          title: 'Preview background',
          subtitle: 'Test the logo against different background types.',
          child: Column(
            children: [
              GridView.builder(
                itemCount: _backgroundOptions.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 82,
                ),
                itemBuilder: (context, index) {
                  final _BackgroundOption option = _backgroundOptions[index];

                  return _backgroundCard(option);
                },
              ),
              if (_selectedBackground == 'Custom') ...[
                const SizedBox(height: 15),
                _buildCustomColors(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sliderControl({
    required String title,
    required double value,
    required double minimum,
    required double maximum,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: brightBlue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: minimum,
            max: maximum,
            divisions: divisions,
            activeColor: brightBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _backgroundCard(_BackgroundOption option) {
    final bool selected = _selectedBackground == option.title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBackground = option.title;

            if (option.title == 'Brand') {
              _customBackgroundColor = _hexToColor(
                _strategyValue('primaryColor', fallback: '#1E3A8A'),
              );
            }
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: selected
                ? brightBlue.withOpacity(0.08)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? brightBlue : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: option.color,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.black.withOpacity(0.08)),
                ),
                child: Icon(
                  option.icon,
                  color: option.title == 'Dark' ? Colors.white : primaryBlue,
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  option.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? primaryBlue : textColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: brightBlue, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomColors() {
    final List<Color> colors = [
      Colors.white,
      const Color(0xFFF8FAFC),
      const Color(0xFF111827),
      const Color(0xFF1E3A8A),
      const Color(0xFF7C3AED),
      const Color(0xFF14532D),
      const Color(0xFF9A3412),
      const Color(0xFFFFFBEB),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final bool selected = _customBackgroundColor.value == color.value;

        return InkWell(
          onTap: () {
            setState(() {
              _customBackgroundColor = color;
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 39,
            height: 39,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? brightBlue : borderColor,
                width: selected ? 2.2 : 1,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black.withOpacity(0.08)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewModes() {
    final String primaryColor = _strategyValue(
      'primaryColor',
      fallback: '#1E3A8A',
    );

    return _sectionCard(
      title: 'Application previews',
      subtitle: 'See how your logo may appear across common brand assets.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth >= 700;

          return GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 3 : 1,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: 190,
            ),
            children: [
              _applicationPreview(
                title: 'Business Card',
                background: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      widget.selectedLogo.imageUrl,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_outlined, size: 45);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _businessNameController.text,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              _applicationPreview(
                title: 'Social Profile',
                background: _hexToColor(primaryColor),
                child: Center(
                  child: Container(
                    width: 105,
                    height: 105,
                    padding: const EdgeInsets.all(13),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.selectedLogo.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_outlined);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              _applicationPreview(
                title: 'Website Header',
                background: const Color(0xFFF8FAFC),
                child: Row(
                  children: [
                    Image.network(
                      widget.selectedLogo.imageUrl,
                      width: 65,
                      height: 65,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_outlined);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _businessNameController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.menu_rounded),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _applicationPreview({
    required String title,
    required Color background,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Padding(padding: const EdgeInsets.all(17), child: child),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            color: Colors.black.withOpacity(0.06),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textColor,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: brightBlue),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'These controls change how the logo is presented inside the brand kit. Editing individual shapes, letters or objects inside the generated image requires a separate image-editing process.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: brightBlue, width: 1.7),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 13, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
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
                height: 54,
                child: FilledButton.icon(
                  onPressed: _continueToBrandKit,
                  style: FilledButton.styleFrom(
                    backgroundColor: brightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.palette_outlined),
                  label: const Text(
                    'Continue to Brand Kit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _previewBackgroundColor() {
    switch (_selectedBackground) {
      case 'Dark':
        return const Color(0xFF111827);

      case 'Brand':
        return _hexToColor(_strategyValue('primaryColor', fallback: '#1E3A8A'));

      case 'Custom':
        return _customBackgroundColor;

      case 'Transparent':
        return Colors.transparent;

      case 'Light':
      default:
        return Colors.white;
    }
  }

  Color _previewTextColor() {
    final Color background = _previewBackgroundColor();

    final double luminance = background.computeLuminance();

    return luminance < 0.45 ? Colors.white : textColor;
  }

  String _strategyValue(String key, {required String fallback}) {
    final String value = widget.brandStrategy[key]?.toString().trim() ?? '';

    return value.isEmpty ? fallback : value;
  }

  Color _hexToColor(String value) {
    try {
      String hex = value.replaceAll('#', '').trim();

      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      if (hex.length != 8) {
        return primaryBlue;
      }

      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return primaryBlue;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class _BackgroundOption {
  final String title;
  final Color color;
  final IconData icon;

  const _BackgroundOption({
    required this.title,
    required this.color,
    required this.icon,
  });
}

class _CheckerboardBackground extends StatelessWidget {
  const _CheckerboardBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CheckerboardPainter());
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double squareSize = 18;

    final Paint lightPaint = Paint()..color = const Color(0xFFF8FAFC);

    final Paint darkPaint = Paint()..color = const Color(0xFFE2E8F0);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final int column = (x / squareSize).floor();

        final int row = (y / squareSize).floor();

        final bool isDark = (column + row).isOdd;

        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isDark ? darkPaint : lightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
