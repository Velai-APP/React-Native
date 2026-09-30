import 'package:flutter/material.dart';

import 'brand_personality_screen.dart';

class BrandDetailsScreen extends StatefulWidget {
  const BrandDetailsScreen({super.key});

  @override
  State<BrandDetailsScreen> createState() =>
      _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color borderColor = Color(0xFFE3E8F2);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _businessNameController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _targetAudienceController =
      TextEditingController();

  final TextEditingController _taglineController =
      TextEditingController();

  final TextEditingController _websiteController =
      TextEditingController();

  final List<String> _industries = [
    'Accounting & Finance',
    'Agriculture',
    'Beauty & Wellness',
    'Construction',
    'Consulting',
    'Education',
    'Fashion & Clothing',
    'Food & Beverage',
    'Healthcare',
    'Interior Design',
    'Legal Services',
    'Manufacturing',
    'Marketing & Advertising',
    'Real Estate',
    'Retail & E-commerce',
    'Software & Technology',
    'Travel & Hospitality',
    'Other',
  ];

  String? _selectedIndustry;

  bool _isExistingBusiness = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _targetAudienceController.dispose();
    _taglineController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _continueToPersonality() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BrandPersonalityScreen(
          businessName: _businessNameController.text.trim(),
          industry: _selectedIndustry!,
          businessDescription:
              _descriptionController.text.trim(),
          targetAudience:
              _targetAudienceController.text.trim(),
          tagline: _taglineController.text.trim(),
          website: _websiteController.text.trim(),
          isExistingBusiness: _isExistingBusiness,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Business Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 18,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 850,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const _ProgressSection(
                      currentStep: 1,
                      totalSteps: 4,
                    ),
                    const SizedBox(height: 28),
                    _buildHeader(),
                    const SizedBox(height: 25),
                    _buildFormCard(),
                    const SizedBox(height: 22),
                    _buildInformationCard(),
                    const SizedBox(height: 26),
                    _buildContinueButton(),
                    const SizedBox(height: 30),
                  ],
                ),
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
          'Tell us about your business',
          style: TextStyle(
            color: textColor,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'These details will help the AI understand your business and create a more relevant logo and brand identity.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel(
            title: 'Business name',
            requiredField: true,
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: _businessNameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText: 'Example: TNR & Company',
              icon: Icons.business_rounded,
            ),
            validator: (value) {
              final String name = value?.trim() ?? '';

              if (name.isEmpty) {
                return 'Enter your business name';
              }

              if (name.length < 2) {
                return 'Business name is too short';
              }

              if (name.length > 60) {
                return 'Use a business name below 60 characters';
              }

              return null;
            },
          ),
          const SizedBox(height: 22),
          _buildFieldLabel(
            title: 'Industry',
            requiredField: true,
          ),
          const SizedBox(height: 9),
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            isExpanded: true,
            decoration: _inputDecoration(
              hintText: 'Select your business industry',
              icon: Icons.category_outlined,
            ),
            items: _industries.map((industry) {
              return DropdownMenuItem<String>(
                value: industry,
                child: Text(
                  industry,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIndustry = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Select your business industry';
              }

              return null;
            },
          ),
          const SizedBox(height: 22),
          _buildFieldLabel(
            title: 'What does your business do?',
            requiredField: true,
          ),
          const SizedBox(height: 5),
          const Text(
            'Describe your products, services and what makes the business different.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              hintText:
                  'Example: We provide accounting, taxation and business advisory services to startups and growing businesses.',
              alignIconTop: true,
              icon: Icons.description_outlined,
            ),
            validator: (value) {
              final String description =
                  value?.trim() ?? '';

              if (description.isEmpty) {
                return 'Describe your business';
              }

              if (description.length < 20) {
                return 'Provide at least 20 characters';
              }

              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildFieldLabel(
            title: 'Target audience',
            requiredField: true,
          ),
          const SizedBox(height: 5),
          const Text(
            'Mention the people or businesses you want to attract.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: _targetAudienceController,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration(
              hintText:
                  'Example: Startups, small businesses and entrepreneurs aged 25–45.',
              alignIconTop: true,
              icon: Icons.groups_2_outlined,
            ),
            validator: (value) {
              final String audience =
                  value?.trim() ?? '';

              if (audience.isEmpty) {
                return 'Enter your target audience';
              }

              if (audience.length < 10) {
                return 'Describe your audience in more detail';
              }

              return null;
            },
          ),
          const SizedBox(height: 22),
          _buildFieldLabel(
            title: 'Existing tagline',
            optional: true,
          ),
          const SizedBox(height: 9),
          TextFormField(
            controller: _taglineController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hintText:
                  'Leave blank if you want AI to suggest one',
              icon: Icons.short_text_rounded,
            ),
          ),
          const SizedBox(height: 22),
          _buildBusinessStatusSelector(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _isExistingBusiness
                ? Padding(
                    padding:
                        const EdgeInsets.only(top: 22),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(
                          title: 'Website or social page',
                          optional: true,
                        ),
                        const SizedBox(height: 9),
                        TextFormField(
                          controller: _websiteController,
                          keyboardType:
                              TextInputType.url,
                          textInputAction:
                              TextInputAction.done,
                          decoration: _inputDecoration(
                            hintText:
                                'https://yourwebsite.com',
                            icon: Icons.language_rounded,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(
          title: 'Business status',
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _statusCard(
                title: 'New business',
                subtitle: 'Starting from scratch',
                icon: Icons.rocket_launch_outlined,
                selected: !_isExistingBusiness,
                onTap: () {
                  setState(() {
                    _isExistingBusiness = false;
                    _websiteController.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statusCard(
                title: 'Existing',
                subtitle: 'Refreshing my brand',
                icon: Icons.storefront_outlined,
                selected: _isExistingBusiness,
                onTap: () {
                  setState(() {
                    _isExistingBusiness = true;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected
                ? brightBlue.withOpacity(0.08)
                : const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? brightBlue : borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? brightBlue
                    : Colors.grey.shade600,
                size: 28,
              ),
              const SizedBox(height: 9),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      selected ? primaryBlue : textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({
    required String title,
    bool requiredField = false,
    bool optional = false,
  }) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (requiredField)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (optional)
          const Text(
            '  Optional',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11.5,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    bool alignIconTop = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 13.5,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(
          top: alignIconTop ? 13 : 0,
        ),
        child: Icon(
          icon,
          color: primaryBlue,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 50,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: brightBlue,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.7,
        ),
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome,
            color: brightBlue,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'More specific business details will produce more relevant logo concepts, taglines, colours and typography recommendations.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: brightBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _continueToPersonality,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue to Brand Personality',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 9),
            Icon(
              Icons.arrow_forward_rounded,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
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
              '${((currentStep / totalSteps) * 100).round()}% complete',
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
                  duration:
                      const Duration(milliseconds: 250),
                  height: 6,
                  margin: EdgeInsets.only(
                    right:
                        index == totalSteps - 1 ? 0 : 7,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFDDE3EC),
                    borderRadius:
                        BorderRadius.circular(20),
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