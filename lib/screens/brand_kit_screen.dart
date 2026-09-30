import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'brand_export_screen.dart';
import 'logo_generation_screen.dart';

class BrandKitScreen extends StatefulWidget {
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

  const BrandKitScreen({
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
  State<BrandKitScreen> createState() => _BrandKitScreenState();
}

class _BrandKitScreenState extends State<BrandKitScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color successGreen = Color(0xFF059669);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  bool _isSaving = false;
  bool _isSaved = false;

  late final String _brandSummary;
  late final String _generatedTagline;
  late final String _toneOfVoice;

  late final String _primaryHex;
  late final String _secondaryHex;
  late final String _accentHex;
  late final String _backgroundHex;

  late final String _headingFont;
  late final String _bodyFont;

  @override
  void initState() {
    super.initState();

    _brandSummary = _strategyValue(
      'brandSummary',
      fallback:
          '${widget.businessName} is a ${widget.logoStyle.toLowerCase()} '
          'brand designed for ${widget.targetAudience}.',
    );

    _generatedTagline = _strategyValue(
      'tagline',
      fallback: widget.tagline.isEmpty
          ? 'Built for what comes next'
          : widget.tagline,
    );

    _toneOfVoice = _strategyValue(
      'toneOfVoice',
      fallback: widget.brandVoice,
    );

    _primaryHex = _normaliseHex(
      _strategyValue(
        'primaryColor',
        fallback: '#1E3A8A',
      ),
      '#1E3A8A',
    );

    _secondaryHex = _normaliseHex(
      _strategyValue(
        'secondaryColor',
        fallback: '#2563EB',
      ),
      '#2563EB',
    );

    _accentHex = _normaliseHex(
      _strategyValue(
        'accentColor',
        fallback: '#F59E0B',
      ),
      '#F59E0B',
    );

    _backgroundHex = _normaliseHex(
      _strategyValue(
        'backgroundColor',
        fallback: '#F8FAFC',
      ),
      '#F8FAFC',
    );

    _headingFont = _strategyValue(
      'headingFont',
      fallback: widget.fontStyle,
    );

    _bodyFont = _strategyValue(
      'bodyFont',
      fallback: 'Inter',
    );
  }

  Future<void> _saveBrandKit() async {
    if (_isSaving) {
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'Please sign in again before saving.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> brandKitData = {
        'userId': user.uid,
        'businessName': widget.businessName,
        'industry': widget.industry,
        'businessDescription': widget.businessDescription,
        'targetAudience': widget.targetAudience,
        'tagline': _generatedTagline,
        'personalities': widget.personalities,
        'brandValues': widget.brandValues,
        'brandVoice': widget.brandVoice,
        'audienceFeeling': widget.audienceFeeling,
        'logoStyle': widget.logoStyle,
        'logoType': widget.logoType,
        'colorDirection': widget.colorDirection,
        'symbolPreference': widget.symbolPreference,
        'fontStyle': widget.fontStyle,
        'selectedLogo': widget.selectedLogo.toMap(),
        'brandStrategy': {
          ...widget.brandStrategy,
          'brandSummary': _brandSummary,
          'tagline': _generatedTagline,
          'toneOfVoice': _toneOfVoice,
          'primaryColor': _primaryHex,
          'secondaryColor': _secondaryHex,
          'accentColor': _accentHex,
          'backgroundColor': _backgroundHex,
          'headingFont': _headingFont,
          'bodyFont': _bodyFont,
        },
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.projectId != null &&
          widget.projectId!.trim().isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('brandProjects')
            .doc(widget.projectId)
            .set(
          brandKitData,
          SetOptions(merge: true),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('brandProjects')
            .add({
          ...brandKitData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = true;
      });

      _showMessage('Brand kit saved successfully.');
    } on FirebaseException catch (error) {
      _showMessage(
        error.message ?? 'Unable to save the brand kit.',
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
          _isSaving = false;
        });
      }
    }
  }

  void _openExportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandExportScreen(
          projectId: widget.projectId,
          businessName: widget.businessName,
          industry: widget.industry,
          tagline: _generatedTagline,
          brandSummary: _brandSummary,
          personalities: widget.personalities,
          brandValues: widget.brandValues,
          brandVoice: _toneOfVoice,
          logoStyle: widget.logoStyle,
          logoType: widget.logoType,
          selectedLogo: widget.selectedLogo,
          primaryColor: _primaryHex,
          secondaryColor: _secondaryHex,
          accentColor: _accentHex,
          backgroundColor: _backgroundHex,
          headingFont: _headingFont,
          bodyFont: _bodyFont,
          brandStrategy: widget.brandStrategy,
        ),
      ),
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
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
          'Brand Kit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Save brand kit',
            onPressed: _isSaving ? null : _saveBrandKit,
            icon: _isSaving
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _isSaved
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 18,
            22,
            isDesktop ? 40 : 18,
            125,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 22),
                  _buildHeroBrandCard(isDesktop),
                  const SizedBox(height: 24),
                  _buildLogoSystem(isDesktop),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildColourSystem(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTypographySystem(),
                        ),
                      ],
                    )
                  else ...[
                    _buildColourSystem(),
                    const SizedBox(height: 20),
                    _buildTypographySystem(),
                  ],
                  const SizedBox(height: 24),
                  _buildBrandPersonality(),
                  const SizedBox(height: 24),
                  _buildLogoGuidelines(isDesktop),
                  const SizedBox(height: 24),
                  _buildApplicationPreviews(isDesktop),
                  const SizedBox(height: 24),
                  _buildAssetChecklist(isDesktop),
                  const SizedBox(height: 24),
                  _buildCompletionCard(),
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your complete brand identity',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Review the logo, colours, typography and usage guidance '
          'created for ${widget.businessName}.',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBrandCard(bool isDesktop) {
    final Color primary = _hexToColor(_primaryHex);
    final Color secondary = _hexToColor(_secondaryHex);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 34 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _brandHeroContent(),
                ),
                const SizedBox(width: 35),
                Expanded(
                  child: _heroLogoPreview(),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _brandHeroContent(),
                const SizedBox(height: 25),
                _heroLogoPreview(),
              ],
            ),
    );
  }

  Widget _brandHeroContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'BRAND IDENTITY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          widget.businessName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _generatedTagline,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _brandSummary,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.personalities
              .map(
                (personality) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    personality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _heroLogoPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: Image.network(
              widget.selectedLogo.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                final int? expectedBytes =
                    loadingProgress.expectedTotalBytes;

                return Center(
                  child: CircularProgressIndicator(
                    value: expectedBytes == null
                        ? null
                        : loadingProgress.cumulativeBytesLoaded /
                            expectedBytes,
                  ),
                );
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const _LogoErrorView();
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.selectedLogo.conceptName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSystem(bool isDesktop) {
    return _sectionCard(
      title: 'Logo System',
      subtitle:
          'Use the logo consistently across light, dark and brand backgrounds.',
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          mainAxisExtent: 255,
        ),
        children: [
          _logoVariationCard(
            title: 'Primary Logo',
            subtitle: 'Preferred version for light backgrounds',
            background: Colors.white,
            textColorValue: textColor,
          ),
          _logoVariationCard(
            title: 'Reverse Logo',
            subtitle: 'For dark and photographic backgrounds',
            background: const Color(0xFF111827),
            textColorValue: Colors.white,
          ),
          _logoVariationCard(
            title: 'Brand Background',
            subtitle: 'For campaign and promotional applications',
            background: _hexToColor(_primaryHex),
            textColorValue: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _logoVariationCard({
    required String title,
    required String subtitle,
    required Color background,
    required Color textColorValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: background == Colors.white
              ? borderColor
              : Colors.transparent,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Image.network(
                widget.selectedLogo.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Icon(
                    Icons.broken_image_outlined,
                    color: textColorValue,
                    size: 48,
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            color: Colors.black.withOpacity(0.08),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColorValue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColorValue.withOpacity(0.7),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColourSystem() {
    final List<_BrandColour> colours = [
      _BrandColour(
        name: 'Primary',
        hex: _primaryHex,
        purpose: 'Core brand recognition',
      ),
      _BrandColour(
        name: 'Secondary',
        hex: _secondaryHex,
        purpose: 'Supporting elements',
      ),
      _BrandColour(
        name: 'Accent',
        hex: _accentHex,
        purpose: 'Calls to action',
      ),
      _BrandColour(
        name: 'Background',
        hex: _backgroundHex,
        purpose: 'Neutral surfaces',
      ),
    ];

    return _sectionCard(
      title: 'Colour System',
      subtitle:
          'Use these colours to maintain a consistent visual identity.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: colours
            .map(
              (colour) => _colourRow(colour),
            )
            .toList(),
      ),
    );
  }

  Widget _colourRow(_BrandColour colour) {
    final Color parsedColour = _hexToColor(colour.hex);
    final List<int> rgb = _rgbValues(parsedColour);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: parsedColour,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colour.name,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  colour.purpose,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    _colourCode('HEX', colour.hex),
                    _colourCode(
                      'RGB',
                      '${rgb[0]}, ${rgb[1]}, ${rgb[2]}',
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

  Widget _colourCode(
    String label,
    String value,
  ) {
    return Text(
      '$label  $value',
      style: const TextStyle(
        color: primaryBlue,
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTypographySystem() {
    return _sectionCard(
      title: 'Typography System',
      subtitle:
          'Apply this hierarchy across digital and printed material.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fontPreview(
            category: 'Display Heading',
            fontName: _headingFont,
            text: widget.businessName,
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(height: 13),
          _fontPreview(
            category: 'Section Heading',
            fontName: _headingFont,
            text: 'A clear brand message',
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 13),
          _fontPreview(
            category: 'Body Text',
            fontName: _bodyFont,
            text:
                'Use this font for paragraphs, descriptions and everyday communication.',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 13),
          _fontPreview(
            category: 'Button and Label',
            fontName: _bodyFont,
            text: 'GET STARTED',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ],
      ),
    );
  }

  Widget _fontPreview({
    required String category,
    required String fontName,
    required String text,
    required double fontSize,
    required FontWeight fontWeight,
    double letterSpacing = 0,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  fontName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPersonality() {
    return _sectionCard(
      title: 'Brand Personality & Voice',
      subtitle:
          'These principles should guide visual and written communication.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _strategyInformationCard(
            icon: Icons.auto_awesome,
            title: 'Brand personality',
            content: widget.personalities.join(', '),
          ),
          const SizedBox(height: 12),
          _strategyInformationCard(
            icon: Icons.favorite_border_rounded,
            title: 'Core values',
            content: widget.brandValues.join(', '),
          ),
          const SizedBox(height: 12),
          _strategyInformationCard(
            icon: Icons.record_voice_over_outlined,
            title: 'Tone of voice',
            content: _toneOfVoice,
          ),
          const SizedBox(height: 12),
          _strategyInformationCard(
            icon: Icons.people_alt_outlined,
            title: 'Desired audience feeling',
            content: widget.audienceFeeling,
          ),
        ],
      ),
    );
  }

  Widget _strategyInformationCard({
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
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: brightBlue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: brightBlue,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13.5,
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

  Widget _buildLogoGuidelines(bool isDesktop) {
    final List<_GuidelineItem> correctGuidelines = const [
      _GuidelineItem(
        icon: Icons.check_circle_outline,
        title: 'Maintain clear space',
        description:
            'Leave sufficient empty space around every side of the logo.',
        positive: true,
      ),
      _GuidelineItem(
        icon: Icons.check_circle_outline,
        title: 'Use approved colours',
        description:
            'Use only the official brand palette and approved logo versions.',
        positive: true,
      ),
      _GuidelineItem(
        icon: Icons.check_circle_outline,
        title: 'Keep proportions',
        description:
            'Resize the logo proportionately without stretching or compressing.',
        positive: true,
      ),
    ];

    final List<_GuidelineItem> incorrectGuidelines = const [
      _GuidelineItem(
        icon: Icons.cancel_outlined,
        title: 'Do not distort',
        description:
            'Do not stretch, rotate or alter the shape of the logo.',
        positive: false,
      ),
      _GuidelineItem(
        icon: Icons.cancel_outlined,
        title: 'Do not add effects',
        description:
            'Avoid shadows, outlines, gradients and unapproved visual effects.',
        positive: false,
      ),
      _GuidelineItem(
        icon: Icons.cancel_outlined,
        title: 'Avoid poor contrast',
        description:
            'Do not place the logo over backgrounds that reduce readability.',
        positive: false,
      ),
    ];

    return _sectionCard(
      title: 'Logo Usage Guidelines',
      subtitle:
          'Follow these standards to protect recognition and consistency.',
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _guidelineColumn(
                    title: 'Correct Usage',
                    items: correctGuidelines,
                    colour: successGreen,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _guidelineColumn(
                    title: 'Avoid',
                    items: incorrectGuidelines,
                    colour: Colors.red,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _guidelineColumn(
                  title: 'Correct Usage',
                  items: correctGuidelines,
                  colour: successGreen,
                ),
                const SizedBox(height: 16),
                _guidelineColumn(
                  title: 'Avoid',
                  items: incorrectGuidelines,
                  colour: Colors.red,
                ),
              ],
            ),
    );
  }

  Widget _guidelineColumn({
    required String title,
    required List<_GuidelineItem> items,
    required Color colour,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colour.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colour.withOpacity(0.22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colour,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.icon,
                    color: colour,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11.5,
                            height: 1.4,
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

  Widget _buildApplicationPreviews(bool isDesktop) {
    return _sectionCard(
      title: 'Brand Applications',
      subtitle:
          'Preview how the identity can appear across common business assets.',
      child: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          mainAxisExtent: 250,
        ),
        children: [
          _businessCardPreview(),
          _socialProfilePreview(),
          _websiteHeaderPreview(),
        ],
      ),
    );
  }

  Widget _businessCardPreview() {
    return _applicationCard(
      title: 'Business Card',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _hexToColor(_primaryHex),
              _hexToColor(_secondaryHex),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Image.network(
                widget.selectedLogo.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 45,
                  );
                },
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.businessName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _generatedTagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    'Name Surname\nDesignation\ncontact@business.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 8.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialProfilePreview() {
    return _applicationCard(
      title: 'Social Media Profile',
      child: Container(
        decoration: BoxDecoration(
          color: _hexToColor(_primaryHex),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.network(
              widget.selectedLogo.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.image_outlined,
                  size: 50,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _websiteHeaderPreview() {
    return _applicationCard(
      title: 'Website Header',
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Image.network(
                  widget.selectedLogo.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.image_outlined,
                    );
                  },
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.menu_rounded,
                  color: primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              _generatedTagline,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _hexToColor(_primaryHex),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicationCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: child,
          ),
          const SizedBox(height: 11),
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetChecklist(bool isDesktop) {
    final List<_AssetItem> assets = const [
      _AssetItem(
        icon: Icons.image_outlined,
        title: 'Primary Logo',
        format: 'PNG',
      ),
      _AssetItem(
        icon: Icons.layers_outlined,
        title: 'Transparent Logo',
        format: 'PNG',
      ),
      _AssetItem(
        icon: Icons.dark_mode_outlined,
        title: 'Dark Background Logo',
        format: 'PNG',
      ),
      _AssetItem(
        icon: Icons.palette_outlined,
        title: 'Colour Palette',
        format: 'HEX / RGB',
      ),
      _AssetItem(
        icon: Icons.text_fields_rounded,
        title: 'Typography Guide',
        format: 'PDF',
      ),
      _AssetItem(
        icon: Icons.menu_book_outlined,
        title: 'Brand Guidelines',
        format: 'PDF',
      ),
      _AssetItem(
        icon: Icons.person_outline,
        title: 'Social Profile',
        format: 'PNG',
      ),
      _AssetItem(
        icon: Icons.web_outlined,
        title: 'Website Assets',
        format: 'PNG',
      ),
    ];

    return _sectionCard(
      title: 'Brand Kit Assets',
      subtitle:
          'The export screen will prepare the following downloadable files.',
      child: GridView.builder(
        itemCount: assets.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          mainAxisExtent: 125,
        ),
        itemBuilder: (context, index) {
          final _AssetItem asset = assets[index];

          return Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  asset.icon,
                  color: brightBlue,
                  size: 24,
                ),
                const SizedBox(height: 16),
                Text(
                  asset.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  asset.format,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: successGreen,
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your brand kit is ready',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Save the project and continue to the export screen to prepare downloadable logo files, social assets and brand guidelines.',
                  style: TextStyle(
                    color: Color(0xFF047857),
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
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: borderColor,
            ),
          ),
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
                  onPressed: _isSaving
                      ? null
                      : _saveBrandKit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(
                      color: primaryBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                          ),
                        )
                      : Icon(
                          _isSaved
                              ? Icons.cloud_done_outlined
                              : Icons.save_outlined,
                        ),
                  label: Text(
                    _isSaved ? 'Saved' : 'Save',
                    style: const TextStyle(
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
                height: 54,
                child: FilledButton.icon(
                  onPressed: _openExportScreen,
                  style: FilledButton.styleFrom(
                    backgroundColor: brightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.download_outlined,
                  ),
                  label: const Text(
                    'Export Brand Kit',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _strategyValue(
    String key, {
    required String fallback,
  }) {
    final String value =
        widget.brandStrategy[key]?.toString().trim() ?? '';

    return value.isEmpty ? fallback : value;
  }

  String _normaliseHex(
    String value,
    String fallback,
  ) {
    String cleaned = value.trim().toUpperCase();

    if (!cleaned.startsWith('#')) {
      cleaned = '#$cleaned';
    }

    final RegExp validHex =
        RegExp(r'^#[0-9A-F]{6}$');

    return validHex.hasMatch(cleaned)
        ? cleaned
        : fallback;
  }

  Color _hexToColor(String value) {
    try {
      String cleaned =
          value.replaceAll('#', '').trim();

      if (cleaned.length == 6) {
        cleaned = 'FF$cleaned';
      }

      if (cleaned.length != 8) {
        return primaryBlue;
      }

      return Color(
        int.parse(
          cleaned,
          radix: 16,
        ),
      );
    } catch (_) {
      return primaryBlue;
    }
  }

  List<int> _rgbValues(Color color) {
    return [
      color.red,
      color.green,
      color.blue,
    ];
  }
}

class _BrandColour {
  final String name;
  final String hex;
  final String purpose;

  const _BrandColour({
    required this.name,
    required this.hex,
    required this.purpose,
  });
}

class _GuidelineItem {
  final IconData icon;
  final String title;
  final String description;
  final bool positive;

  const _GuidelineItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.positive,
  });
}

class _AssetItem {
  final IconData icon;
  final String title;
  final String format;

  const _AssetItem({
    required this.icon,
    required this.title,
    required this.format,
  });
}

class _LogoErrorView extends StatelessWidget {
  const _LogoErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 55,
          ),
          SizedBox(height: 9),
          Text(
            'Unable to load logo',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}