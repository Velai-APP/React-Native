import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_applications_screen.dart';

class GstRegistrationScreen extends StatefulWidget {
  const GstRegistrationScreen({super.key});

  @override
  State<GstRegistrationScreen> createState() => _GstRegistrationScreenState();
}

class _GstRegistrationScreenState extends State<GstRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  final legalNameController = TextEditingController();
  final panController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  final tradeNameController = TextEditingController();
  final businessActivityController = TextEditingController();

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  final promoterNameController = TextEditingController();
  final promoterPanController = TextEditingController();
  final promoterAadhaarController = TextEditingController();

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  String constitution = 'Proprietorship';
  String possessionType = 'Owned';

  final List<String> constitutionTypes = [
    'Proprietorship',
    'Partnership',
    'LLP',
    'Private Limited Company',
    'Public Limited Company',
    'HUF',
    'Trust',
    'Society',
    'Others',
  ];

  final List<_StepInfo> steps = const [
    _StepInfo(title: 'Applicant', icon: Icons.person_outline_rounded),
    _StepInfo(title: 'Business', icon: Icons.storefront_outlined),
    _StepInfo(title: 'Address', icon: Icons.location_on_outlined),
    _StepInfo(title: 'Details', icon: Icons.account_balance_outlined),
    _StepInfo(title: 'Review', icon: Icons.fact_check_outlined),
  ];

  @override
  void dispose() {
    legalNameController.dispose();
    panController.dispose();
    mobileController.dispose();
    emailController.dispose();
    tradeNameController.dispose();
    businessActivityController.dispose();
    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    promoterNameController.dispose();
    promoterPanController.dispose();
    promoterAadhaarController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHero()),
                    SliverToBoxAdapter(child: _buildStepper()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(.04, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _buildCurrentStep(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -40,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -65,
            child: Container(
              height: 135,
              width: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withOpacity(.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _heroButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'GST REGISTRATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            letterSpacing: .7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GST Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Apply for your GSTIN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _heroMiniCard(
                      Icons.route_rounded,
                      '5 Steps',
                      'Guided',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _heroMiniCard(
                      Icons.security_rounded,
                      'Secure',
                      'Your data',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _heroMiniCard(
                      Icons.track_changes_rounded,
                      'Live',
                      'Tracking',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _heroMiniCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: Colors.white),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(.60),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEPPER
  // ============================================================

  Widget _buildStepper() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final completed = index < currentStep;
          final active = index == currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: index < currentStep
                  ? () {
                      setState(() {
                        currentStep = index;
                      });
                    }
                  : null,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: active ? 42 : 36,
                    width: active ? 42 : 36,
                    decoration: BoxDecoration(
                      color: completed || active
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(.20),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : steps[index].icon,
                      size: active ? 20 : 17,
                      color: completed || active
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    steps[index].title,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // CURRENT STEP
  // ============================================================

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _applicantStep();
      case 1:
        return _businessStep();
      case 2:
        return _addressStep();
      case 3:
        return _additionalDetailsStep();
      case 4:
        return _reviewStep();
      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _applicantStep() {
    return _premiumSection(
      key: const ValueKey('applicant'),
      step: '01',
      title: 'Applicant Details',
      subtitle: 'Enter the primary details for GST registration.',
      icon: Icons.person_outline_rounded,
      children: [
        _field(
          controller: legalNameController,
          label: 'Legal Name of Business',
          hint: 'Name as per PAN',
          icon: Icons.business_outlined,
          required: true,
        ),
        _field(
          controller: panController,
          label: 'PAN',
          hint: 'ABCDE1234F',
          icon: Icons.credit_card_outlined,
          required: true,
        ),
        _field(
          controller: mobileController,
          label: 'Mobile Number',
          hint: 'Enter mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          required: true,
        ),
        _field(
          controller: emailController,
          label: 'Email Address',
          hint: 'name@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          required: true,
        ),
        _infoBox(
          icon: Icons.security_rounded,
          title: 'Contact details',
          message:
              'Use the email and mobile number available with the authorised applicant.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _businessStep() {
    return _premiumSection(
      key: const ValueKey('business'),
      step: '02',
      title: 'Business Details',
      subtitle: 'Tell us about the business being registered.',
      icon: Icons.storefront_outlined,
      children: [
        _field(
          controller: tradeNameController,
          label: 'Trade Name',
          hint: 'Business / brand name',
          icon: Icons.store_outlined,
        ),
        _dropdown(
          title: 'Constitution of Business',
          icon: Icons.account_tree_outlined,
          value: constitution,
          items: constitutionTypes,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              constitution = value;
            });
          },
        ),
        const SizedBox(height: 14),
        _field(
          controller: businessActivityController,
          label: 'Nature of Business',
          hint: 'Trading / Service / Manufacturing',
          icon: Icons.work_outline_rounded,
          required: true,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget _addressStep() {
    return _premiumSection(
      key: const ValueKey('address'),
      step: '03',
      title: 'Principal Place of Business',
      subtitle: 'Enter the primary location of your business.',
      icon: Icons.location_on_outlined,
      children: [
        _field(
          controller: addressController,
          label: 'Business Address',
          hint: 'Door no, street, area',
          icon: Icons.home_work_outlined,
          maxLines: 3,
          required: true,
        ),
        Row(
          children: [
            Expanded(
              child: _field(
                controller: cityController,
                label: 'City',
                hint: 'City',
                icon: Icons.location_city_outlined,
                required: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                controller: pincodeController,
                label: 'PIN Code',
                hint: '6 digits',
                icon: Icons.pin_drop_outlined,
                required: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _field(
          controller: districtController,
          label: 'District',
          hint: 'District',
          icon: Icons.map_outlined,
          required: true,
        ),
        _field(
          controller: stateController,
          label: 'State',
          hint: 'State',
          icon: Icons.public_outlined,
          required: true,
        ),
        _possessionSelector(),
      ],
    );
  }

  Widget _possessionSelector() {
    final options = ['Owned', 'Rented', 'Leased', 'Consent'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nature of Possession',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((item) {
            final selected = possessionType == item;

            return ChoiceChip(
              label: Text(item),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  possessionType = item;
                });
              },
              selectedColor: const Color(0xFFDBEAFE),
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE5E7EB),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // STEP 4
  // ============================================================

  Widget _additionalDetailsStep() {
    return Column(
      key: const ValueKey('details'),
      children: [
        _premiumSection(
          step: '04',
          title: 'Promoter / Proprietor',
          subtitle: 'Enter authorised person details.',
          icon: Icons.groups_outlined,
          children: [
            _field(
              controller: promoterNameController,
              label: 'Full Name',
              hint: 'Name of proprietor / promoter',
              icon: Icons.person_outline,
            ),
            _field(
              controller: promoterPanController,
              label: 'PAN',
              hint: 'ABCDE1234F',
              icon: Icons.credit_card_outlined,
            ),
            _field(
              controller: promoterAadhaarController,
              label: 'Aadhaar Number',
              hint: '12 digit Aadhaar',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ),

        const SizedBox(height: 15),

        _premiumSection(
          step: '',
          title: 'Bank Details',
          subtitle: 'Provide business bank account details.',
          icon: Icons.account_balance_outlined,
          children: [
            _field(
              controller: bankNameController,
              label: 'Bank Name',
              hint: 'Bank name',
              icon: Icons.account_balance_outlined,
            ),
            _field(
              controller: accountNumberController,
              label: 'Account Number',
              hint: 'Business account number',
              icon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
            ),
            _field(
              controller: ifscController,
              label: 'IFSC Code',
              hint: 'SBIN0001234',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // REVIEW
  // ============================================================

  Widget _reviewStep() {
    return Column(
      key: const ValueKey('review'),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(23),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 39),
              SizedBox(height: 12),
              Text(
                'Review Your Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Check the details carefully before submitting your GST registration request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        _reviewCard(
          title: 'Applicant',
          icon: Icons.person_outline_rounded,
          children: [
            _reviewRow('Legal Name', legalNameController.text),
            _reviewRow('PAN', panController.text.toUpperCase()),
            _reviewRow('Mobile', mobileController.text),
            _reviewRow('Email', emailController.text),
          ],
        ),

        const SizedBox(height: 12),

        _reviewCard(
          title: 'Business',
          icon: Icons.storefront_outlined,
          children: [
            _reviewRow('Trade Name', tradeNameController.text),
            _reviewRow('Constitution', constitution),
            _reviewRow('Activity', businessActivityController.text),
          ],
        ),

        const SizedBox(height: 12),

        _reviewCard(
          title: 'Business Location',
          icon: Icons.location_on_outlined,
          children: [
            _reviewRow('City', cityController.text),
            _reviewRow('District', districtController.text),
            _reviewRow('State', stateController.text),
            _reviewRow('Possession', possessionType),
          ],
        ),

        const SizedBox(height: 15),

        _infoBox(
          icon: Icons.track_changes_rounded,
          title: 'Track after submission',
          message:
              'Your GST registration status will appear under My Applications automatically.',
        ),
      ],
    );
  }

  // ============================================================
  // PREMIUM SECTION
  // ============================================================

  Widget _premiumSection({
    Key? key,
    required String step,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE5E9EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step.isNotEmpty)
                      Text(
                        'STEP $step',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 9.5,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                    if (step.isNotEmpty) const SizedBox(height: 3),

                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // FIELDS
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }

                return null;
              }
            : null,
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: maxLines == 1
              ? Icon(icon, color: const Color(0xFF2563EB), size: 20)
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String title,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: title,
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2563EB), size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E40AF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF5F6B76),
                    fontSize: 11.5,
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

  // ============================================================
  // REVIEW CARDS
  // ============================================================

  Widget _reviewCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 19),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const Divider(color: Color(0xFFF0F2F5)),

          ...children,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomBar() {
    final progress = (currentStep + 1) / 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              if (currentStep > 0)
                SizedBox(
                  height: 54,
                  width: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentStep--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFFE1E5EA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

              if (currentStep > 0) const SizedBox(width: 10),

              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (currentStep < 4) {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              setState(() {
                                currentStep++;
                              });
                            } else {
                              _submitApplication();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: const Color(0xFF93B4ED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 21,
                            width: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentStep == 4
                                    ? 'Submit GST Application'
                                    : 'Save & Continue',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                currentStep == 4
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 19,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitApplication() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final ref = FirebaseFirestore.instance
          .collection('registrationApplications')
          .doc();

      await ref.set({
        'applicationId': ref.id,
        'userId': user.uid,
        'registrationType': 'GST',
        'status': 'submitted',

        'legalName': legalNameController.text.trim(),

        'tradeName': tradeNameController.text.trim(),

        'pan': panController.text.trim().toUpperCase(),

        'mobile': mobileController.text.trim(),

        'email': emailController.text.trim(),

        'constitution': constitution,

        'businessActivity': businessActivityController.text.trim(),

        'principalPlace': {
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'district': districtController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
          'possessionType': possessionType,
        },

        'promoter': {
          'name': promoterNameController.text.trim(),
          'pan': promoterPanController.text.trim().toUpperCase(),
          'aadhaarLast4': promoterAadhaarController.text.length >= 4
              ? promoterAadhaarController.text.substring(
                  promoterAadhaarController.text.length - 4,
                )
              : '',
        },

        'bankDetails': {
          'bankName': bankNameController.text.trim(),
          'accountNumber': accountNumberController.text.trim(),
          'ifsc': ifscController.text.trim().toUpperCase(),
        },

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),

        'statusHistory': [
          {
            'status': 'submitted',
            'title': 'GST Application Submitted',
            'timestamp': Timestamp.now(),
          },
        ],
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text('Unable to submit GST application: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}

class _StepInfo {
  final String title;
  final IconData icon;

  const _StepInfo({required this.title, required this.icon});
}
