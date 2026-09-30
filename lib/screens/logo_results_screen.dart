import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'brand_kit_screen.dart';
import 'logo_generation_screen.dart';

class LogoResultsScreen extends StatefulWidget {
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

  final List<LogoConcept> logoConcepts;
  final Map<String, dynamic> brandStrategy;
  final String? projectId;

  const LogoResultsScreen({
    super.key,
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
    required this.logoConcepts,
    required this.brandStrategy,
    this.projectId,
  });

  @override
  State<LogoResultsScreen> createState() => _LogoResultsScreenState();
}

class _LogoResultsScreenState extends State<LogoResultsScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF059669);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  late List<LogoConcept> _concepts;

  int? _selectedIndex;
  int? _regeneratingIndex;

  @override
  void initState() {
    super.initState();
    _concepts = List<LogoConcept>.from(widget.logoConcepts);
  }

  Future<void> _regenerateConcept(int index) async {
    if (_regeneratingIndex != null) {
      return;
    }

    setState(() {
      _regeneratingIndex = index;
    });

    try {
      final LogoConcept currentConcept = _concepts[index];

      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable(
            'regenerateLogoConcept',
            options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
          );

      final HttpsCallableResult<dynamic> result = await callable.call({
        'projectId': widget.projectId,
        'conceptId': currentConcept.id,
        'businessName': widget.businessName,
        'industry': widget.industry,
        'businessDescription': widget.businessDescription,
        'targetAudience': widget.targetAudience,
        'personalities': widget.personalities,
        'brandValues': widget.brandValues,
        'brandVoice': widget.brandVoice,
        'audienceFeeling': widget.audienceFeeling,
        'logoStyle': widget.logoStyle,
        'logoType': widget.logoType,
        'colorDirection': widget.colorDirection,
        'symbolPreference': widget.symbolPreference,
        'fontStyle': widget.fontStyle,
        'previousPrompt': currentConcept.prompt,
      });

      final dynamic rawData = result.data;

      if (rawData is! Map) {
        throw const FormatException(
          'The server returned an invalid logo response.',
        );
      }

      final Map<String, dynamic> response = Map<String, dynamic>.from(rawData);

      final dynamic rawConcept = response['logoConcept'] ?? response;

      if (rawConcept is! Map) {
        throw const FormatException(
          'The regenerated logo information is missing.',
        );
      }

      final LogoConcept regenerated = LogoConcept.fromMap(
        Map<String, dynamic>.from(rawConcept),
      );

      if (regenerated.imageUrl.isEmpty) {
        throw const FormatException('The regenerated logo image is missing.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _concepts[index] = regenerated;

        if (_selectedIndex == index) {
          _selectedIndex = null;
        }
      });

      _showMessage('Logo concept regenerated successfully.');
    } on FirebaseFunctionsException catch (error) {
      _showMessage(
        error.message ?? 'Unable to regenerate this concept.',
        isError: true,
      );
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _regeneratingIndex = null;
        });
      }
    }
  }

  void _selectConcept(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openFullPreview(int index) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) {
        final LogoConcept concept = _concepts[index];

        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750, maxHeight: 850),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    color: primaryBlue,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            concept.conceptName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF8FAFC),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            concept.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const _ImageErrorView();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          concept.description.isEmpty
                              ? 'AI-generated logo concept for ${widget.businessName}.'
                              : concept.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _selectConcept(index);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: brightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'Select This Concept',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
      },
    );
  }

  void _continueToBrandKit() {
    if (_selectedIndex == null) {
      _showMessage('Select one logo concept to continue.', isError: true);
      return;
    }

    final LogoConcept selectedConcept = _concepts[_selectedIndex!];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandKitScreen(
          projectId: widget.projectId,
          businessName: widget.businessName,
          industry: widget.industry,
          businessDescription: widget.businessDescription,
          targetAudience: widget.targetAudience,
          tagline: widget.tagline,
          personalities: widget.personalities,
          brandValues: widget.brandValues,
          brandVoice: widget.brandVoice,
          audienceFeeling: widget.audienceFeeling,
          logoStyle: widget.logoStyle,
          logoType: widget.logoType,
          colorDirection: widget.colorDirection,
          symbolPreference: widget.symbolPreference,
          fontStyle: widget.fontStyle,
          selectedLogo: selectedConcept,
          brandStrategy: widget.brandStrategy,
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
    final double width = MediaQuery.sizeOf(context).width;

    final bool isDesktop = width >= 950;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Logo Concepts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 18,
            22,
            isDesktop ? 40 : 18,
            130,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildBrandSummary(),
                  const SizedBox(height: 26),
                  _buildConceptGrid(isDesktop),
                  const SizedBox(height: 28),
                  _buildStrategySection(isDesktop),
                  const SizedBox(height: 25),
                  _buildHelpCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your favourite concept',
                style: TextStyle(
                  color: textColor,
                  fontSize: 29,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '${_concepts.length} unique logo concepts were generated for ${widget.businessName}. Select one to build your complete brand kit.',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: successGreen.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: successGreen, size: 18),
              SizedBox(width: 6),
              Text(
                'Generated',
                style: TextStyle(
                  color: successGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Wrap(
        spacing: 25,
        runSpacing: 16,
        children: [
          _summaryItem(
            Icons.business_outlined,
            'Business',
            widget.businessName,
          ),
          _summaryItem(Icons.category_outlined, 'Industry', widget.industry),
          _summaryItem(Icons.auto_awesome_outlined, 'Style', widget.logoStyle),
          _summaryItem(
            Icons.dashboard_customize_outlined,
            'Logo type',
            widget.logoType,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String title, String value) {
    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: primaryBlue, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConceptGrid(bool isDesktop) {
    if (_concepts.isEmpty) {
      return const Center(child: Text('No logo concepts are available.'));
    }

    return GridView.builder(
      itemCount: _concepts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 2 : 1,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        mainAxisExtent: isDesktop ? 560 : 545,
      ),
      itemBuilder: (context, index) {
        return _buildConceptCard(index);
      },
    );
  }

  Widget _buildConceptCard(int index) {
    final LogoConcept concept = _concepts[index];

    final bool isSelected = _selectedIndex == index;

    final bool isRegenerating = _regeneratingIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isSelected ? brightBlue : borderColor,
          width: isSelected ? 2.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? brightBlue.withOpacity(0.15)
                : Colors.black.withOpacity(0.045),
            blurRadius: isSelected ? 22 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  child: InkWell(
                    onTap: isRegenerating
                        ? null
                        : () {
                            _openFullPreview(index);
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.network(
                        concept.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImageErrorView();
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'CONCEPT ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filled(
                    tooltip: 'Full preview',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.92),
                      foregroundColor: primaryBlue,
                    ),
                    onPressed: isRegenerating
                        ? null
                        : () {
                            _openFullPreview(index);
                          },
                    icon: const Icon(Icons.fullscreen_rounded),
                  ),
                ),
                if (isSelected)
                  const Positioned(
                    bottom: 14,
                    right: 14,
                    child: CircleAvatar(
                      radius: 21,
                      backgroundColor: brightBlue,
                      child: Icon(Icons.check_rounded, color: Colors.white),
                    ),
                  ),
                if (isRegenerating)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.88),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 15),
                          Text(
                            'Regenerating concept...',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concept.conceptName.isEmpty
                      ? 'Logo Concept ${index + 1}'
                      : concept.conceptName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  concept.description.isEmpty
                      ? 'A ${widget.logoStyle.toLowerCase()} ${widget.logoType.toLowerCase()} created for ${widget.businessName}.'
                      : concept.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _conceptTag(
                      concept.style.isEmpty ? widget.logoStyle : concept.style,
                    ),
                    _conceptTag(
                      concept.logoType.isEmpty
                          ? widget.logoType
                          : concept.logoType,
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _regeneratingIndex == null
                              ? () {
                                  _regenerateConcept(index);
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryBlue,
                            side: const BorderSide(color: primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text(
                            'Regenerate',
                            maxLines: 1,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: isRegenerating
                              ? null
                              : () {
                                  _selectConcept(index);
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: isSelected
                                ? successGreen
                                : brightBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.check_circle_outline,
                            size: 20,
                          ),
                          label: Text(
                            isSelected ? 'Selected' : 'Select',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conceptTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryBlue,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStrategySection(bool isDesktop) {
    final String summary = _strategyValue(
      'brandSummary',
      fallback:
          'A ${widget.logoStyle.toLowerCase()} brand identity designed to connect with ${widget.targetAudience}.',
    );

    final String generatedTagline = _strategyValue(
      'tagline',
      fallback: widget.tagline.isEmpty
          ? 'No tagline generated'
          : widget.tagline,
    );

    final String toneOfVoice = _strategyValue(
      'toneOfVoice',
      fallback: widget.brandVoice,
    );

    final String primaryColor = _strategyValue(
      'primaryColor',
      fallback: '#1E3A8A',
    );

    final String secondaryColor = _strategyValue(
      'secondaryColor',
      fallback: '#2563EB',
    );

    final String accentColor = _strategyValue(
      'accentColor',
      fallback: '#F59E0B',
    );

    final String headingFont = _strategyValue(
      'headingFont',
      fallback: widget.fontStyle,
    );

    final String bodyFont = _strategyValue('bodyFont', fallback: 'Inter');

    return _sectionCard(
      title: 'AI Brand Strategy',
      subtitle: 'A supporting identity direction created from your answers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _strategyBlock(
            icon: Icons.auto_awesome,
            title: 'Brand summary',
            content: summary,
          ),
          const SizedBox(height: 14),
          _strategyBlock(
            icon: Icons.format_quote_rounded,
            title: 'Suggested tagline',
            content: generatedTagline,
          ),
          const SizedBox(height: 14),
          _strategyBlock(
            icon: Icons.record_voice_over_outlined,
            title: 'Tone of voice',
            content: toneOfVoice,
          ),
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _colorPaletteCard(
                    primaryColor,
                    secondaryColor,
                    accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _typographyCard(headingFont, bodyFont)),
              ],
            )
          else ...[
            _colorPaletteCard(primaryColor, secondaryColor, accentColor),
            const SizedBox(height: 16),
            _typographyCard(headingFont, bodyFont),
          ],
        ],
      ),
    );
  }

  Widget _strategyBlock({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: brightBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorPaletteCard(String primary, String secondary, String accent) {
    final colors = [
      ('Primary', primary),
      ('Secondary', secondary),
      ('Accent', accent),
    ];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colour Palette',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...colors.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 39,
                    height: 39,
                    decoration: BoxDecoration(
                      color: _hexToColor(item.$2),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _typographyCard(String headingFont, String bodyFont) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Typography',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'HEADING FONT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 9.5,
              letterSpacing: 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            headingFont,
            style: const TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'BODY FONT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 9.5,
              letterSpacing: 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            bodyFont,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Clear typography helps your brand remain consistent across websites, social media and documents.',
            style: TextStyle(color: Colors.grey, fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706)),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Select the concept that best represents the brand rather than choosing only by colour. Colours and supporting typography can be refined in the brand kit.',
              style: TextStyle(
                color: Color(0xFF92400E),
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
              fontSize: 20,
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

  Widget _buildBottomBar() {
    final bool hasSelection = _selectedIndex != null;

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
                  onPressed: _regeneratingIndex == null
                      ? () {
                          Navigator.pop(context);
                        }
                      : null,
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
                  onPressed: hasSelection && _regeneratingIndex == null
                      ? _continueToBrandKit
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: brightBlue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.palette_outlined, size: 21),
                  label: Text(
                    hasSelection ? 'Build Brand Kit' : 'Select a Logo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _strategyValue(String key, {required String fallback}) {
    final String value = widget.brandStrategy[key]?.toString().trim() ?? '';

    return value.isEmpty ? fallback : value;
  }

  Color _hexToColor(String hexValue) {
    try {
      String cleaned = hexValue.replaceAll('#', '').trim();

      if (cleaned.length == 6) {
        cleaned = 'FF$cleaned';
      }

      if (cleaned.length != 8) {
        return Colors.grey.shade300;
      }

      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }
}

class _ImageErrorView extends StatelessWidget {
  const _ImageErrorView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 52, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'Unable to load this logo',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
