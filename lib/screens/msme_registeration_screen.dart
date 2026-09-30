import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:velai/screens/msme_application_status_screen.dart';

class MsmeRegistrationScreen extends StatefulWidget {
  const MsmeRegistrationScreen({super.key});

  @override
  State<MsmeRegistrationScreen> createState() => _MsmeRegistrationScreenState();
}

class _MsmeRegistrationScreenState extends State<MsmeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  final applicantNameController = TextEditingController();
  final aadhaarController = TextEditingController();
  final panController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  final enterpriseNameController = TextEditingController();
  final gstinController = TextEditingController();

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  final employeesController = TextEditingController();
  final investmentController = TextEditingController();
  final turnoverController = TextEditingController();

  String organisationType = 'Proprietorship';
  String businessActivity = 'Services';

  final List<String> organisationTypes = [
    'Proprietorship',
    'Partnership',
    'HUF',
    'LLP',
    'Private Limited Company',
    'Public Limited Company',
    'Co-operative Society',
    'Trust',
    'Society',
    'Others',
  ];

  final List<_StepInfo> stepInfo = const [
    _StepInfo(
      title: 'Applicant',
      subtitle: 'Identity',
      icon: Icons.person_outline_rounded,
    ),
    _StepInfo(
      title: 'Business',
      subtitle: 'Enterprise',
      icon: Icons.business_center_outlined,
    ),
    _StepInfo(
      title: 'Address',
      subtitle: 'Location',
      icon: Icons.location_on_outlined,
    ),
    _StepInfo(
      title: 'Details',
      subtitle: 'Financial',
      icon: Icons.account_balance_outlined,
    ),
    _StepInfo(
      title: 'Review',
      subtitle: 'Submit',
      icon: Icons.fact_check_outlined,
    ),
  ];

  @override
  void dispose() {
    applicantNameController.dispose();
    aadhaarController.dispose();
    panController.dispose();
    mobileController.dispose();
    emailController.dispose();
    enterpriseNameController.dispose();
    gstinController.dispose();
    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    employeesController.dispose();
    investmentController.dispose();
    turnoverController.dispose();
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
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(.03, 0),
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
          colors: [Color(0xFF0F172A), Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -35,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),

          Positioned(
            right: 45,
            bottom: -60,
            child: Container(
              height: 130,
              width: 130,
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
                  _heroIconButton(
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
                      border: Border.all(color: Colors.white.withOpacity(.10)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Udyam Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.factory_outlined,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MSME Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.4,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Start your Udyam registration',
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
                      icon: Icons.timer_outlined,
                      title: '5 Steps',
                      subtitle: 'Guided',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _heroMiniCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'Secure',
                      subtitle: 'Your data',
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _heroMiniCard(
                      icon: Icons.track_changes_outlined,
                      title: 'Live',
                      subtitle: 'Tracking',
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

  Widget _heroIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(.12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _heroMiniCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: List.generate(stepInfo.length, (index) {
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
                    duration: const Duration(milliseconds: 250),
                    height: active ? 42 : 36,
                    width: active ? 42 : 36,
                    decoration: BoxDecoration(
                      color: completed || active
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: const Color(0xFF0F766E).withOpacity(.20),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : stepInfo[index].icon,
                      size: active ? 20 : 17,
                      color: completed || active
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    stepInfo[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active
                          ? const Color(0xFF0F766E)
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
        return _financialStep();
      case 4:
        return _reviewStep();
      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // APPLICANT
  // ============================================================

  Widget _applicantStep() {
    return _premiumSection(
      key: const ValueKey('applicant'),
      number: '01',
      title: 'Applicant Details',
      subtitle: 'Enter the details of the entrepreneur or authorised person.',
      icon: Icons.person_outline_rounded,
      children: [
        _field(
          controller: applicantNameController,
          label: 'Name as per Aadhaar',
          hint: 'Enter full name',
          icon: Icons.person_outline,
          required: true,
        ),

        _field(
          controller: aadhaarController,
          label: 'Aadhaar Number',
          hint: '12 digit Aadhaar number',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          required: true,
        ),

        _field(
          controller: panController,
          label: 'PAN',
          hint: 'ABCDE1234F',
          icon: Icons.credit_card_outlined,
          required: true,
        ),

        Row(
          children: [
            Expanded(
              child: _field(
                controller: mobileController,
                label: 'Mobile',
                hint: 'Mobile number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                required: true,
              ),
            ),
          ],
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
          title: 'Your information is protected',
          message:
              'Sensitive details are used only for processing your registration request.',
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS
  // ============================================================

  Widget _businessStep() {
    return _premiumSection(
      key: const ValueKey('business'),
      number: '02',
      title: 'Business Details',
      subtitle: 'Tell us about your enterprise.',
      icon: Icons.business_center_outlined,
      children: [
        _field(
          controller: enterpriseNameController,
          label: 'Enterprise Name',
          hint: 'Enter business name',
          icon: Icons.storefront_outlined,
          required: true,
        ),

        _dropdown(
          title: 'Organisation Type',
          icon: Icons.account_tree_outlined,
          value: organisationType,
          items: organisationTypes,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              organisationType = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _activitySelector(),

        const SizedBox(height: 17),

        _field(
          controller: gstinController,
          label: 'GSTIN',
          hint: 'Optional, if applicable',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  Widget _activitySelector() {
    final activities = [
      {'name': 'Manufacturing', 'icon': Icons.factory_outlined},
      {'name': 'Services', 'icon': Icons.design_services_outlined},
      {'name': 'Trading', 'icon': Icons.storefront_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Major Business Activity',
          style: TextStyle(
            color: Color(0xFF374151),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: activities.map((activity) {
            final name = activity['name'] as String;
            final icon = activity['icon'] as IconData;
            final selected = businessActivity == name;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: name != 'Trading' ? 8 : 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      businessActivity = name;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE6FFFA)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF0F766E)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 21,
                          color: selected
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? const Color(0xFF0F766E)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _addressStep() {
    return _premiumSection(
      key: const ValueKey('address'),
      number: '03',
      title: 'Business Address',
      subtitle: 'Where your enterprise operates from.',
      icon: Icons.location_on_outlined,
      children: [
        _field(
          controller: addressController,
          label: 'Office / Business Address',
          hint: 'Door no, street, area',
          icon: Icons.home_work_outlined,
          required: true,
          maxLines: 3,
        ),

        Row(
          children: [
            Expanded(
              child: _field(
                controller: cityController,
                label: 'City / Town',
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
                keyboardType: TextInputType.number,
                required: true,
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
      ],
    );
  }

  // ============================================================
  // FINANCIAL
  // ============================================================

  Widget _financialStep() {
    return Column(
      key: const ValueKey('financial'),
      children: [
        _premiumSection(
          number: '04',
          title: 'Bank Details',
          subtitle: 'Provide your business banking information.',
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
              hint: 'Bank account number',
              icon: Icons.numbers_outlined,
              keyboardType: TextInputType.number,
            ),

            _field(
              controller: ifscController,
              label: 'IFSC Code',
              hint: 'Example: SBIN0001234',
              icon: Icons.account_tree_outlined,
            ),
          ],
        ),

        const SizedBox(height: 15),

        _premiumSection(
          number: '',
          title: 'Enterprise Information',
          subtitle: 'Operational and financial details.',
          icon: Icons.query_stats_outlined,
          children: [
            _field(
              controller: employeesController,
              label: 'Number of Employees',
              hint: 'Example: 10',
              icon: Icons.groups_outlined,
              keyboardType: TextInputType.number,
            ),

            _field(
              controller: investmentController,
              label: 'Investment in Plant / Equipment',
              hint: 'Enter amount',
              icon: Icons.factory_outlined,
              keyboardType: TextInputType.number,
              prefixText: '₹ ',
            ),

            _field(
              controller: turnoverController,
              label: 'Annual Turnover',
              hint: 'Enter annual turnover',
              icon: Icons.trending_up_rounded,
              keyboardType: TextInputType.number,
              prefixText: '₹ ',
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
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 38),
              SizedBox(height: 12),
              Text(
                'Ready to submit?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Review the information below before submitting your MSME registration request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        _reviewCard(
          title: 'Applicant',
          icon: Icons.person_outline,
          children: [
            _reviewRow('Name', applicantNameController.text),
            _reviewRow('PAN', panController.text.toUpperCase()),
            _reviewRow('Mobile', mobileController.text),
            _reviewRow('Email', emailController.text),
          ],
        ),

        const SizedBox(height: 12),

        _reviewCard(
          title: 'Enterprise',
          icon: Icons.business_center_outlined,
          children: [
            _reviewRow('Business', enterpriseNameController.text),
            _reviewRow('Entity', organisationType),
            _reviewRow('Activity', businessActivity),
            _reviewRow(
              'GSTIN',
              gstinController.text.isEmpty
                  ? 'Not provided'
                  : gstinController.text.toUpperCase(),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _reviewCard(
          title: 'Address',
          icon: Icons.location_on_outlined,
          children: [
            _reviewRow('City', cityController.text),
            _reviewRow('District', districtController.text),
            _reviewRow('State', stateController.text),
            _reviewRow('PIN', pincodeController.text),
          ],
        ),

        const SizedBox(height: 15),

        _infoBox(
          icon: Icons.track_changes_rounded,
          title: 'Track after submission',
          message:
              'Once submitted, you can follow the progress of your application in real time.',
        ),
      ],
    );
  }

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
                  color: const Color(0xFFE6FFFA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF0F766E), size: 19),
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

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _premiumSection({
    Key? key,
    required String number,
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
                  color: const Color(0xFFE6FFFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF0F766E), size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (number.isNotEmpty)
                      Text(
                        'STEP $number',
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),

                    if (number.isNotEmpty) const SizedBox(height: 3),

                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.25,
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
  // FIELD
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          prefixIcon: maxLines == 1
              ? Icon(icon, size: 20, color: const Color(0xFF0F766E))
              : null,
          labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          hintStyle: const TextStyle(
            color: Color(0xFFB1B7C2),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
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
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF0F766E)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
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
  // INFO BOX
  // ============================================================

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFCCFBF1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F766E), size: 21),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF115E59),
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
  // REVIEW ROW
  // ============================================================

  Widget _reviewRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
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
  // BOTTOM CTA
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
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0F766E)),
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
                      padding: EdgeInsets.zero,
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
                      backgroundColor: const Color(0xFF0F766E),
                      disabledBackgroundColor: const Color(0xFF99D5CF),
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
                                    ? 'Submit Application'
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
  // SUBMISSION
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
        'registrationType': 'MSME',
        'status': 'submitted',

        'applicantName': applicantNameController.text.trim(),

        'aadhaarLast4': aadhaarController.text.length >= 4
            ? aadhaarController.text.substring(
                aadhaarController.text.length - 4,
              )
            : '',

        'pan': panController.text.trim().toUpperCase(),

        'mobile': mobileController.text.trim(),

        'email': emailController.text.trim(),

        'enterpriseName': enterpriseNameController.text.trim(),

        'organisationType': organisationType,

        'gstin': gstinController.text.trim().toUpperCase(),

        'businessActivity': businessActivity,

        'address': {
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'district': districtController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },

        'bankDetails': {
          'bankName': bankNameController.text.trim(),
          'accountNumber': accountNumberController.text.trim(),
          'ifsc': ifscController.text.trim().toUpperCase(),
        },

        'employees': employeesController.text.trim(),

        'investment': investmentController.text.trim(),

        'turnover': turnoverController.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),

        'statusHistory': [
          {
            'status': 'submitted',
            'title': 'Application Submitted',
            'timestamp': Timestamp.now(),
          },
        ],
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MsmeApplicationStatusScreen(applicationId: ref.id),
        ),
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
          content: Text('Unable to submit application: $e'),
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
  final String subtitle;
  final IconData icon;

  const _StepInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
