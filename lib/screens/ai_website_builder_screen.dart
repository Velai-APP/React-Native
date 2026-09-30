import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'my_websites_screen.dart';

class WebsiteBuilderScreen extends StatefulWidget {
  const WebsiteBuilderScreen({super.key});

  @override
  State<WebsiteBuilderScreen> createState() =>
      _WebsiteBuilderScreenState();
}

class _WebsiteBuilderScreenState extends State<WebsiteBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aboutController = TextEditingController();
  final _servicesController = TextEditingController();

  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  final _workingHoursController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _googleMapsController = TextEditingController();
  final _ctaController = TextEditingController();

  final _siteNameController = TextEditingController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  String _selectedTemplate = 'Modern';
  String _selectedTone = 'Professional';
  Color _selectedColor = const Color(0xFF6C4DFF);

  final List<String> _templates = const [
    'Modern',
    'Minimal',
    'Elegant',
    'Bold',
  ];

  final List<String> _tones = const [
    'Professional',
    'Friendly',
    'Premium',
    'Energetic',
  ];

  final List<Color> _availableColors = const [
    Color(0xFF6C4DFF),
    Color(0xFF006CFF),
    Color(0xFF00A67E),
    Color(0xFFFF7A00),
    Color(0xFFE84078),
    Color(0xFF121826),
  ];

  @override
  void dispose() {
    _scrollController.dispose();

    _businessNameController.dispose();
    _businessTypeController.dispose();
    _descriptionController.dispose();
    _aboutController.dispose();
    _servicesController.dispose();

    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    _workingHoursController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _googleMapsController.dispose();
    _ctaController.dispose();

    _siteNameController.dispose();
    super.dispose();
  }

  Future<void> _startWebsiteGeneration() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!_validateRequiredBusinessFields()) {
      setState(() {
        _currentStep = 0;
      });

      await _scrollToTop();

      _showMessage(
        'Please complete the required business details.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
      final navigator = Navigator.of(
    context,
    rootNavigator: true,
  );

  bool navigationCompleted = false;

    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-south1',
      ).httpsCallable(
        // IMPORTANT:
        // This must match the lightweight Firebase callable.
        'startWebsiteGeneration',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 300),
        ),
      );

      final result = await callable.call(<String, dynamic>{
        'businessName': _businessNameController.text.trim(),
        'businessType': _businessTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'about': _aboutController.text.trim(),
        'services': _servicesController.text.trim(),

        'phone': _phoneController.text.trim(),
        'alternatePhone': _alternatePhoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),

        'workingHours': _workingHoursController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'googleMaps': _googleMapsController.text.trim(),
        'ctaText': _ctaController.text.trim(),

        'preferredSiteName': _siteNameController.text.trim(),
        'template': _selectedTemplate,
        'tone': _selectedTone,
        'primaryColor': _colorToHex(_selectedColor),
      });

      if (result.data is! Map) {
        throw const FormatException(
          'The server returned an invalid response.',
        );
      }

      final response = Map<String, dynamic>.from(
        result.data as Map,
      );

   final websiteId =
        response['websiteId']?.toString().trim() ?? '';

    if (websiteId.isEmpty) {
      throw const FormatException(
        'Website queue ID was not returned.',
      );
    }

    debugPrint(
      'Website queued successfully: $websiteId',
    );

    if (!mounted) {
      debugPrint(
        'Builder screen is no longer mounted.',
      );
      return;
    }

    // Stop button state before leaving the page.
    setState(() {
      _isSubmitting = false;
    });

    navigationCompleted = true;

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MyWebsitesScreen(
          highlightedWebsiteId: websiteId,
        ),
      ),
      (route) => route.isFirst,
    );

    return;
    } on FirebaseFunctionsException catch (error, stackTrace) {
      debugPrint('Firebase function code: ${error.code}');
      debugPrint('Firebase function message: ${error.message}');
      debugPrint('Firebase function details: ${error.details}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        error.message ??
            'Unable to start website generation (${error.code}).',
      );
    } catch (error, stackTrace) {
      debugPrint('Website queue error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage(
        'Unable to start website generation: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _validateRequiredBusinessFields() {
    return _businessNameController.text.trim().isNotEmpty &&
        _businessTypeController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goToStep(int step) async {
    if (_isSubmitting) return;

    setState(() {
      _currentStep = step;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 50),
    );

    await _scrollToTop();
  }

  void _nextStep() {
    if (_isSubmitting) return;

    if (_currentStep == 0) {
      final form = _formKey.currentState;

      if (form == null || !form.validate()) {
        _showMessage(
          'Please complete all required fields.',
        );
        return;
      }

      _goToStep(1);
      return;
    }

    if (_currentStep == 1) {
      _goToStep(2);
      return;
    }

    if (_currentStep == 2) {
      _startWebsiteGeneration();
    }
  }

  void _previousStep() {
    if (_isSubmitting || _currentStep == 0) return;
    _goToStep(_currentStep - 1);
  }

  String _colorToHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final pattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!pattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null;
    }

    final digits = phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  IconData _templateIcon(String template) {
    switch (template) {
      case 'Minimal':
        return Icons.crop_square_rounded;
      case 'Elegant':
        return Icons.diamond_outlined;
      case 'Bold':
        return Icons.bolt_rounded;
      default:
        return Icons.dashboard_customize_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF6F6FB),
        body: Stack(
          children: [
            const Positioned.fill(
              child: _BackgroundDecoration(),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        132,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 760,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _buildHero(),
                              const SizedBox(height: 22),
                              _buildStepIndicator(),
                              const SizedBox(height: 20),
                              AnimatedSwitcher(
                                duration:
                                    const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: _buildCurrentStep(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 760,
                    ),
                    child: _buildBottomActions(),
                  ),
                ),
              ),
            ),
            // if (_isSubmitting) const _QueueStartingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFE8E7EF),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CFF),
                  Color(0xFF5544E9),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336C4DFF),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VELAI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'AI Website Studio',
                  style: TextStyle(
                    color: Color(0xFF77778A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16142B),
            Color(0xFF37276F),
            Color(0xFF6C4DFF),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336C4DFF),
            blurRadius: 35,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius:
                      BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: Color(0xFFFFD166),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Powered by AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Turn your business\ninto a live website.',
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
                'Add your details, choose a design and send the website to the background queue.',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.78,
                  ),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = [
      'Business',
      'Design',
      'Publish',
    ];

    return Row(
      children: List.generate(
        steps.length,
        (index) {
          final completed = index < _currentStep;
          final active = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 250),
                      width: active ? 38 : 32,
                      height: active ? 38 : 32,
                      decoration: BoxDecoration(
                        color: completed || active
                            ? const Color(0xFF6C4DFF)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: completed || active
                              ? const Color(0xFF6C4DFF)
                              : const Color(0xFFE0E0EA),
                        ),
                        boxShadow: active
                            ? const [
                                BoxShadow(
                                  color: Color(0x336C4DFF),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : const Color(
                                          0xFF8B8B9D,
                                        ),
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: active
                            ? const Color(0xFF6C4DFF)
                            : const Color(0xFF77778A),
                      ),
                    ),
                  ],
                ),
                if (index != steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin:
                          const EdgeInsets.fromLTRB(
                        8,
                        0,
                        8,
                        20,
                      ),
                      color: completed
                          ? const Color(0xFF6C4DFF)
                          : const Color(0xFFE4E4ED),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBusinessStep();
      case 1:
        return _buildDesignStep();
      case 2:
        return _buildPublishStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBusinessStep() {
    return _SectionCard(
      key: const ValueKey('business'),
      title: 'Tell us about your business',
      subtitle:
          'Provide complete business and contact information.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const _FormSectionTitle(
              icon: Icons.storefront_outlined,
              title: 'Business information',
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _businessNameController,
              label: 'Business name',
              hint: 'Example: TNR and Company',
              icon: Icons.storefront_outlined,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _businessTypeController,
              label: 'Business category',
              hint: 'Example: Chartered Accountants',
              icon: Icons.category_outlined,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _descriptionController,
              label: 'Short business description',
              hint: 'Briefly explain what your business does',
              icon: Icons.notes_rounded,
              maxLines: 3,
              validator: _requiredValidator,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _aboutController,
              label: 'About the business',
              hint:
                  'Share your experience, mission and strengths',
              icon: Icons.info_outline_rounded,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _servicesController,
              label: 'Products or services',
              hint:
                  'Audit, GST, Income Tax, Company Registration...',
              icon: Icons.grid_view_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 26),
            const _FormSectionTitle(
              icon: Icons.contact_phone_outlined,
              title: 'Contact information',
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _phoneController,
              label: 'Primary phone number',
              hint: '+91 98765 43210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _phoneValidator,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _alternatePhoneController,
              label: 'Alternate phone number',
              hint: '+91 98765 43211',
              icon: Icons.phone_in_talk_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _whatsappController,
              label: 'WhatsApp number',
              hint: '+91 98765 43210',
              icon: Icons.chat_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _emailController,
              label: 'Business email',
              hint: 'hello@business.com',
              icon: Icons.email_outlined,
              keyboardType:
                  TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _addressController,
              label: 'Business address',
              hint: 'Full business address',
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 26),
            const _FormSectionTitle(
              icon: Icons.public_rounded,
              title: 'Online presence',
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _instagramController,
              label: 'Instagram profile',
              hint:
                  'https://instagram.com/business',
              icon: Icons.camera_alt_outlined,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _facebookController,
              label: 'Facebook page',
              hint:
                  'https://facebook.com/business',
              icon: Icons.facebook_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _googleMapsController,
              label: 'Google Maps link',
              hint:
                  'Paste your business location link',
              icon: Icons.map_outlined,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 26),
            const _FormSectionTitle(
              icon: Icons.schedule_rounded,
              title: 'Business availability',
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _workingHoursController,
              label: 'Working hours',
              hint:
                  'Monday–Saturday, 9:30 AM–6:30 PM',
              icon: Icons.access_time_rounded,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _AppTextField(
              controller: _ctaController,
              label: 'Call-to-action text',
              hint: 'Book a consultation today',
              icon: Icons.ads_click_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignStep() {
    return _SectionCard(
      key: const ValueKey('design'),
      title: 'Choose your website style',
      subtitle:
          'Select a visual direction for your website.',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const _InputLabel('Template style'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: _templates.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final template = _templates[index];
              final selected =
                  template == _selectedTemplate;

              return _TemplateCard(
                title: template,
                selected: selected,
                icon: _templateIcon(template),
                onTap: () {
                  setState(() {
                    _selectedTemplate = template;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const _InputLabel('Brand tone'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _tones.map((tone) {
              final selected =
                  tone == _selectedTone;

              return ChoiceChip(
                label: Text(tone),
                selected: selected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color(0xFF49495B),
                  fontWeight: FontWeight.w700,
                ),
                selectedColor:
                    const Color(0xFF6C4DFF),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF6C4DFF)
                      : const Color(0xFFE2E2EB),
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedTone = tone;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _InputLabel(
            'Primary brand colour',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children:
                _availableColors.map((color) {
              final selected =
                  color.toARGB32() ==
                      _selectedColor.toARGB32();

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishStep() {
    return _SectionCard(
      key: const ValueKey('publish'),
      title: 'Publish your website',
      subtitle:
          'Choose the preferred Netlify website name and start generation.',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _AppTextField(
            controller: _siteNameController,
            label: 'Preferred website name',
            hint: 'tnr-and-company',
            icon: Icons.language_rounded,
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder<
              TextEditingValue>(
            valueListenable: _siteNameController,
            builder: (
              context,
              value,
              child,
            ) {
              final siteName =
                  value.text.trim();

              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFF1EEFF),
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        const Color(0xFFDCD4FF),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      color:
                          Color(0xFF6C4DFF),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        siteName.isEmpty
                            ? 'Netlify will automatically create a unique website address.'
                            : 'Requested address: $siteName.netlify.app. Availability is confirmed during deployment.',
                        style: const TextStyle(
                          color:
                              Color(0xFF57526D),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const _FeatureRow(
            icon:
                Icons.auto_awesome_rounded,
            title:
                'AI-generated content and layout',
          ),
          const _FeatureRow(
            icon:
                Icons.phone_android_rounded,
            title:
                'Responsive mobile design',
          ),
          const _FeatureRow(
            icon:
                Icons.queue_rounded,
            title:
                'Background queue processing',
          ),
          const _FeatureRow(
            icon:
                Icons.notifications_active_outlined,
            title:
                'Notification when completed',
          ),
          const _FeatureRow(
            icon:
                Icons.rocket_launch_outlined,
            title:
                'Automatic Netlify publishing',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.97,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEAEAF1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            IconButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : _previousStep,
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: FilledButton(
              onPressed:
                  _isSubmitting
                      ? null
                      : _nextStep,
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(56),
                backgroundColor:
                    const Color(0xFF6C4DFF),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFFB9ACEF),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  if (_isSubmitting) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    _isSubmitting
                        ? 'Starting generation...'
                        : _currentStep == 2
                            ? 'Generate website'
                            : 'Continue',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!_isSubmitting) ...[
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep == 2
                          ? Icons
                              .auto_awesome_rounded
                          : Icons
                              .arrow_forward_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFEAEAF1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: Color(0xFF1F1E2C),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF77778A),
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint:
            maxLines > 1,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
            const Color(0xFFF9F9FC),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5EF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF6C4DFF),
            width: 1.8,
          ),
        ),
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
                const Color(0xFFF1EEFF),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                const Color(0xFF6C4DFF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF333244),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFF333244),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFFF1EEFF)
          : const Color(0xFFF8F8FC),
      borderRadius:
          BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6C4DFF)
                  : const Color(0xFFE7E7EF),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected
                    ? const Color(0xFF6C4DFF)
                    : const Color(0xFF77778A),
                size: 28,
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? const Color(0xFF4F32DD)
                      : const Color(0xFF333244),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF1EEFF),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color:
                  const Color(0xFF6C4DFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF464557),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F6FB),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _GlowCircle(
              size: 290,
              color: Color(0x1A6C4DFF),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: _GlowCircle(
              size: 250,
              color: Color(0x1400A67E),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QueueStartingOverlay extends StatefulWidget {
  const _QueueStartingOverlay();

  @override
  State<_QueueStartingOverlay> createState() =>
      _QueueStartingOverlayState();
}

class _QueueStartingOverlayState
    extends State<_QueueStartingOverlay> {
  static const _messages = <String>[
    'Saving your website details',
    'Adding your website to the queue',
    'Opening your website dashboard',
  ];

  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _rotateMessages();
  }

  Future<void> _rotateMessages() async {
    while (mounted) {
      await Future<void>.delayed(
        const Duration(seconds: 2),
      );

      if (!mounted) return;

      setState(() {
        _messageIndex =
            (_messageIndex + 1) %
                _messages.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC1A172D),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.all(28),
            constraints:
                const BoxConstraints(
              maxWidth: 380,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 32,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF8B5CFF),
                        Color(0xFF5544E9),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),
                  child:
                      const CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Starting your website',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w900,
                    color: Color(0xFF1F1E2C),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey<int>(
                      _messageIndex,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      height: 1.5,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(0xFF77778A),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(99),
                  child:
                      const LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor:
                        Color(0xFFEAE7F8),
                    color:
                        Color(0xFF6C4DFF),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You will be redirected as soon as the background job is queued.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: Color(0xFF9694A2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
