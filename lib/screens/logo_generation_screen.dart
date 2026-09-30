import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'logo_results_screen.dart';

class LogoGenerationScreen extends StatefulWidget {
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

  final String logoStyle;
  final String logoType;
  final String colorDirection;
  final String symbolPreference;
  final String fontStyle;

  const LogoGenerationScreen({
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
    required this.logoStyle,
    required this.logoType,
    required this.colorDirection,
    required this.symbolPreference,
    required this.fontStyle,
  });

  @override
  State<LogoGenerationScreen> createState() => _LogoGenerationScreenState();
}

class _LogoGenerationScreenState extends State<LogoGenerationScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color purple = Color(0xFF7C3AED);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);
  static const Color successColor = Color(0xFF059669);

  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;

  Timer? _messageTimer;

  bool _isGenerating = true;
  bool _hasError = false;
  String _errorMessage = '';

  int _currentStage = 0;
  int _currentMessage = 0;

  final List<GenerationStage> _stages = const [
    GenerationStage(
      title: 'Understanding your business',
      subtitle: 'Reviewing your industry, audience and business description.',
      icon: Icons.business_center_outlined,
    ),
    GenerationStage(
      title: 'Building your brand direction',
      subtitle: 'Combining your personality, values and brand voice.',
      icon: Icons.explore_outlined,
    ),
    GenerationStage(
      title: 'Creating logo concepts',
      subtitle: 'Designing four different visual ideas for your business.',
      icon: Icons.auto_awesome,
    ),
    GenerationStage(
      title: 'Preparing colour palettes',
      subtitle: 'Selecting colours that support your brand personality.',
      icon: Icons.palette_outlined,
    ),
    GenerationStage(
      title: 'Selecting typography',
      subtitle: 'Choosing font combinations for your brand identity.',
      icon: Icons.text_fields_rounded,
    ),
    GenerationStage(
      title: 'Finalising your brand kit',
      subtitle: 'Preparing your generated concepts for review.',
      icon: Icons.inventory_2_outlined,
    ),
  ];

  final List<String> _generationMessages = const [
    'Exploring visual directions...',
    'Balancing personality and professionalism...',
    'Creating memorable logo symbols...',
    'Testing colour combinations...',
    'Selecting suitable typography...',
    'Preparing your final concepts...',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _hasError = false;
      _errorMessage = '';
      _currentStage = 0;
      _currentMessage = 0;
    });

    _startStatusAnimation();

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Your login session has expired. Please sign in again.',
        );
      }

      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable(
            'generateBrandIdentity',
            options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
          );

      final HttpsCallableResult<dynamic> result = await callable.call({
        'businessName': widget.businessName,
        'industry': widget.industry,
        'businessDescription': widget.businessDescription,
        'targetAudience': widget.targetAudience,
        'tagline': widget.tagline,
        'website': widget.website,
        'isExistingBusiness': widget.isExistingBusiness,
        'personalities': widget.personalities,
        'brandValues': widget.brandValues,
        'brandVoice': widget.brandVoice,
        'audienceFeeling': widget.audienceFeeling,
        'logoStyle': widget.logoStyle,
        'logoType': widget.logoType,
        'colorDirection': widget.colorDirection,
        'symbolPreference': widget.symbolPreference,
        'fontStyle': widget.fontStyle,
      });

      if (!mounted) {
        return;
      }

      final dynamic rawData = result.data;

      if (rawData is! Map) {
        throw const FormatException('The server returned an invalid response.');
      }

      final Map<String, dynamic> response = Map<String, dynamic>.from(rawData);

      final List<LogoConcept> concepts = _parseLogoConcepts(response);

      if (concepts.isEmpty) {
        throw const FormatException(
          'No logo concepts were returned by the server.',
        );
      }

      _messageTimer?.cancel();

      setState(() {
        _currentStage = _stages.length;
        _isGenerating = false;
      });

      await Future<void>.delayed(const Duration(milliseconds: 700));

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LogoResultsScreen(
            businessName: widget.businessName,
            industry: widget.industry,
            businessDescription: widget.businessDescription,
            targetAudience: widget.targetAudience,
            tagline: response['tagline']?.toString() ?? widget.tagline,
            personalities: widget.personalities,
            brandValues: widget.brandValues,
            brandVoice: widget.brandVoice,
            audienceFeeling: widget.audienceFeeling,
            logoStyle: widget.logoStyle,
            logoType: widget.logoType,
            colorDirection: widget.colorDirection,
            symbolPreference: widget.symbolPreference,
            fontStyle: widget.fontStyle,
            logoConcepts: concepts,
            brandStrategy: _extractBrandStrategy(response),
            projectId: response['projectId']?.toString(),
          ),
        ),
      );
    } on FirebaseFunctionsException catch (error, stackTrace) {
      debugPrint('========== FIREBASE FUNCTION ERROR ==========');
      debugPrint('Function: generateBrandIdentity');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Details: ${error.details}');
      debugPrint('Plugin: ${error.plugin}');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('=============================================');

      _handleError(
        'Code: ${error.code}\n'
        'Message: ${error.message ?? 'No message'}\n'
        'Details: ${error.details ?? 'No details'}',
      );
    } on TimeoutException {
      _handleError('Logo generation took too long. Please try again.');
    } on FormatException catch (error) {
      _handleError(error.message);
    } catch (error, stackTrace) {
      debugPrint('========== FLUTTER ERROR ==========');
      debugPrint('Error: $error');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('===================================');

      _handleError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _startStatusAnimation() {
    _messageTimer?.cancel();

    _messageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_isGenerating) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_currentStage < _stages.length - 1) {
          _currentStage++;
        }

        _currentMessage = (_currentMessage + 1) % _generationMessages.length;
      });
    });
  }

  List<LogoConcept> _parseLogoConcepts(Map<String, dynamic> response) {
    final dynamic rawConcepts =
        response['logoConcepts'] ?? response['logos'] ?? response['images'];

    if (rawConcepts is! List) {
      return [];
    }

    return rawConcepts
        .whereType<Map>()
        .map((item) => LogoConcept.fromMap(Map<String, dynamic>.from(item)))
        .where((concept) => concept.imageUrl.isNotEmpty)
        .toList();
  }

 Map<String, dynamic> _extractBrandStrategy(
  Map<String, dynamic> response,
) {
  final dynamic strategy = response['brandStrategy'];

  if (strategy is Map) {
    return Map<String, dynamic>.from(strategy);
  }

  return {
    'brandSummary':
        response['brandSummary'] ?? '',

    'tagline':
        response['tagline'] ?? '',

    'missionStatement':
        response['missionStatement'] ?? '',

    'positioningStatement':
        response['positioningStatement'] ?? '',

    'toneOfVoice':
        response['toneOfVoice'] ?? '',

    'primaryColor':
        response['primaryColor'] ?? '',

    'secondaryColor':
        response['secondaryColor'] ?? '',

    'accentColor':
        response['accentColor'] ?? '',

    'backgroundColor':
        response['backgroundColor'] ?? '',

    'headingFont':
        response['headingFont'] ?? '',

    'bodyFont':
        response['bodyFont'] ?? '',

    'typographyReason':
        response['typographyReason'] ?? '',

    'logoRationale':
        response['logoRationale'] ?? '',

    'keywords':
        response['keywords'] ?? [],

    // NEW
    'visitingCardStyle':
        response['visitingCardStyle'] ?? '',

    'visitingCardFrontPrompt':
        response['visitingCardFrontPrompt'] ?? '',

    'visitingCardBackPrompt':
        response['visitingCardBackPrompt'] ?? '',
  };
}

  void _handleError(String message) {
    _messageTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _isGenerating = false;
      _hasError = true;
      _errorMessage = message;
    });
  }

  String _firebaseErrorMessage(FirebaseFunctionsException error) {
    final String serverMessage = error.message?.trim().isNotEmpty == true
        ? error.message!.trim()
        : 'No server message was returned.';

    switch (error.code) {
      case 'unauthenticated':
        return 'Authentication error:\n$serverMessage';

      case 'permission-denied':
        return 'Permission error:\n$serverMessage';

      case 'resource-exhausted':
        return 'Usage limit error:\n$serverMessage';

      case 'deadline-exceeded':
        return 'Function timeout:\n$serverMessage';

      case 'unavailable':
        return 'Cloud Function unavailable:\n$serverMessage';

      case 'invalid-argument':
        return 'Invalid request:\n$serverMessage';

      case 'not-found':
        return 'Function not found:\n'
            'Check that generateBrandIdentity is deployed in asia-south1.';

      case 'internal':
        return 'Cloud Function internal error:\n'
            '$serverMessage\n\n'
            'Details: ${error.details ?? 'Not provided'}';

      default:
        return 'Firebase Functions error:\n'
            'Code: ${error.code}\n'
            'Message: $serverMessage\n'
            'Details: ${error.details ?? 'Not provided'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width >= 900;

    return PopScope(
      canPop: !_isGenerating,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _isGenerating) {
          _showGenerationWarning();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: !_isGenerating,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Creating Your Brand',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 42 : 18,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: _hasError
                    ? _buildErrorContent()
                    : _buildGenerationContent(isDesktop),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationContent(bool isDesktop) {
    return Column(
      children: [
        const _ProgressSection(currentStep: 4, totalSteps: 4),
        const SizedBox(height: 32),
        _buildAnimatedLogo(),
        const SizedBox(height: 28),
        Text(
          _isGenerating
              ? 'Creating something special'
              : 'Your concepts are ready!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textColor,
            fontSize: 29,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            _isGenerating
                ? _generationMessages[_currentMessage]
                : 'Opening your generated logo concepts...',
            key: ValueKey<String>(
              _isGenerating
                  ? _generationMessages[_currentMessage]
                  : 'completed',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
        const SizedBox(height: 30),
        _buildProgressCard(),
        const SizedBox(height: 22),
        _buildBrandSummaryCard(isDesktop),
        const SizedBox(height: 22),
        _buildInformationCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [brightBlue, purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(44),
          boxShadow: [
            BoxShadow(
              color: brightBlue.withOpacity(0.28),
              blurRadius: 34,
              spreadRadius: 4,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 65),
            if (_isGenerating)
              Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.18),
                ),
              ),
            if (!_isGenerating)
              const Positioned(
                right: 14,
                bottom: 14,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: successColor,
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final double progress = _isGenerating
        ? (_currentStage + 1) / _stages.length
        : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Generation progress',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: brightBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5EAF3),
              valueColor: const AlwaysStoppedAnimation<Color>(brightBlue),
            ),
          ),
          const SizedBox(height: 23),
          ...List.generate(_stages.length, (index) {
            final GenerationStage stage = _stages[index];

            final bool completed = !_isGenerating || index < _currentStage;

            final bool active = _isGenerating && index == _currentStage;

            return _buildStageItem(
              stage: stage,
              completed: completed,
              active: active,
              showLine: index != _stages.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStageItem({
    required GenerationStage stage,
    required bool completed,
    required bool active,
    required bool showLine,
  }) {
    Color iconColor = Colors.grey;
    Color background = const Color(0xFFF1F3F7);

    if (completed) {
      iconColor = successColor;
      background = successColor.withOpacity(0.11);
    } else if (active) {
      iconColor = brightBlue;
      background = brightBlue.withOpacity(0.11);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        color: successColor,
                        size: 23,
                      )
                    : active
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: iconColor,
                        ),
                      )
                    : Icon(stage.icon, color: iconColor, size: 22),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: completed
                        ? successColor.withOpacity(0.25)
                        : borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 21),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: TextStyle(
                      color: active || completed ? textColor : Colors.grey,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage.subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
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

  Widget _buildBrandSummaryCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.business_rounded, color: Colors.white),
              ),
              const SizedBox(width: 13),
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
                    const SizedBox(height: 3),
                    Text(
                      widget.industry,
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _summaryItem(
                    'Personality',
                    widget.personalities.join(', '),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _summaryItem(
                    'Logo direction',
                    '${widget.logoStyle} • ${widget.logoType}',
                  ),
                ),
              ],
            )
          else ...[
            _summaryItem('Personality', widget.personalities.join(', ')),
            const SizedBox(height: 13),
            _summaryItem(
              'Logo direction',
              '${widget.logoStyle} • ${widget.logoType}',
            ),
          ],
          const SizedBox(height: 13),
          _summaryItem('Colour direction', widget.colorDirection),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10.5,
            letterSpacing: 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: textColor,
            fontSize: 13.5,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
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
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFD97706),
            size: 22,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Logo generation may take a little time because four unique concepts and their supporting brand elements are being created.',
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

  Widget _buildErrorContent() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.09),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 65,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Generation failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton.icon(
            onPressed: _startGeneration,
            style: FilledButton.styleFrom(
              backgroundColor: brightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Try Again',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
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
              'Edit Logo Style',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _showGenerationWarning() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            'Please allow the logo generation process to complete.',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}

class GenerationStage {
  final String title;
  final String subtitle;
  final IconData icon;

  const GenerationStage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class LogoConcept {
  final String id;
  final String imageUrl;
  final String conceptName;
  final String description;
  final String prompt;
  final String logoType;
  final String style;

  const LogoConcept({
    required this.id,
    required this.imageUrl,
    required this.conceptName,
    required this.description,
    required this.prompt,
    required this.logoType,
    required this.style,
  });

  factory LogoConcept.fromMap(Map<String, dynamic> map) {
    return LogoConcept(
      id:
          map['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      imageUrl: map['imageUrl']?.toString() ?? map['url']?.toString() ?? '',
      conceptName:
          map['conceptName']?.toString() ??
          map['name']?.toString() ??
          'Logo Concept',
      description: map['description']?.toString() ?? '',
      prompt: map['prompt']?.toString() ?? '',
      logoType: map['logoType']?.toString() ?? '',
      style: map['style']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'conceptName': conceptName,
      'description': description,
      'prompt': prompt,
      'logoType': logoType,
      'style': style,
    };
  }
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
              child: Container(
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
