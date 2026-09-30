import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_applications_screen.dart';

class PartnershipRegistrationScreen extends StatefulWidget {
  const PartnershipRegistrationScreen({super.key});

  @override
  State<PartnershipRegistrationScreen> createState() =>
      _PartnershipRegistrationScreenState();
}

class _PartnershipRegistrationScreenState
    extends State<PartnershipRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  // ============================================================
  // FIRM DETAILS
  // ============================================================

  final firmNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final businessActivityController = TextEditingController();

  // ============================================================
  // PARTNERS
  // ============================================================

  final partner1NameController = TextEditingController();
  final partner1PanController = TextEditingController();
  final partner1MobileController = TextEditingController();
  final partner1ShareController = TextEditingController();

  final partner2NameController = TextEditingController();
  final partner2PanController = TextEditingController();
  final partner2MobileController = TextEditingController();
  final partner2ShareController = TextEditingController();

  // ============================================================
  // ADDRESS
  // ============================================================

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // ============================================================
  // BANK
  // ============================================================

  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  String businessType = 'Services';
  String possessionType = 'Owned';

  final List<_StepInfo> steps = const [
    _StepInfo(title: 'Firm', icon: Icons.handshake_outlined),
    _StepInfo(title: 'Partners', icon: Icons.groups_outlined),
    _StepInfo(title: 'Business', icon: Icons.storefront_outlined),
    _StepInfo(title: 'Bank', icon: Icons.account_balance_outlined),
    _StepInfo(title: 'Review', icon: Icons.fact_check_outlined),
  ];

  @override
  void dispose() {
    firmNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    businessActivityController.dispose();

    partner1NameController.dispose();
    partner1PanController.dispose();
    partner1MobileController.dispose();
    partner1ShareController.dispose();

    partner2NameController.dispose();
    partner2PanController.dispose();
    partner2MobileController.dispose();
    partner2ShareController.dispose();

    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
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
          colors: [Color(0xFF083344), Color(0xFF0E7490), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withOpacity(.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -45,
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
            right: 45,
            bottom: -70,
            child: Container(
              height: 140,
              width: 140,
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
                  _headerButton(
                    Icons.arrow_back_ios_new_rounded,
                    () => Navigator.pop(context),
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
                          Icons.handshake_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PARTNERSHIP FIRM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: .8,
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
                      Icons.handshake_outlined,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partnership',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: -.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Build your business together',
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
                    child: _heroStat(Icons.route_outlined, '5 Steps', 'Guided'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroStat(Icons.groups_outlined, '2+', 'Partners'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroStat(
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

  Widget _headerButton(IconData icon, VoidCallback onTap) {
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

  Widget _heroStat(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white.withOpacity(.60), fontSize: 9),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final completed = index < currentStep;
          final active = index == currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: completed
                  ? () {
                      setState(() {
                        currentStep = index;
                      });
                    }
                  : null,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: active ? 42 : 36,
                    width: active ? 42 : 36,
                    decoration: BoxDecoration(
                      color: completed || active
                          ? const Color(0xFF0891B2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : steps[index].icon,
                      size: 18,
                      color: completed || active
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    steps[index].title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active
                          ? const Color(0xFF0891B2)
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

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _firmStep();
      case 1:
        return _partnersStep();
      case 2:
        return _businessStep();
      case 3:
        return _bankStep();
      case 4:
        return _reviewStep();
      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _firmStep() {
    return _section(
      key: const ValueKey('firm'),
      number: '01',
      title: 'Firm Details',
      subtitle: 'Enter the proposed partnership firm details.',
      icon: Icons.handshake_outlined,
      children: [
        _field(
          controller: firmNameController,
          label: 'Firm Name',
          hint: 'Example: ABC & Associates',
          icon: Icons.storefront_outlined,
          required: true,
        ),
        _field(
          controller: mobileController,
          label: 'Mobile Number',
          hint: 'Enter contact number',
          icon: Icons.phone_outlined,
          required: true,
          keyboard: TextInputType.phone,
        ),
        _field(
          controller: emailController,
          label: 'Email Address',
          hint: 'firm@example.com',
          icon: Icons.email_outlined,
          required: true,
          keyboard: TextInputType.emailAddress,
        ),
        _infoBox(
          Icons.info_outline_rounded,
          'Firm information',
          'Use the proposed trade name and primary contact details for this partnership request.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _partnersStep() {
    return _section(
      key: const ValueKey('partners'),
      number: '02',
      title: 'Partner Details',
      subtitle: 'Enter details and proposed profit-sharing ratio.',
      icon: Icons.groups_outlined,
      children: [
        _partnerCard(
          title: 'Partner 1',
          number: '01',
          nameController: partner1NameController,
          panController: partner1PanController,
          mobileController: partner1MobileController,
          shareController: partner1ShareController,
        ),
        const SizedBox(height: 14),
        _partnerCard(
          title: 'Partner 2',
          number: '02',
          nameController: partner2NameController,
          panController: partner2PanController,
          mobileController: partner2MobileController,
          shareController: partner2ShareController,
        ),
        const SizedBox(height: 4),
        _infoBox(
          Icons.percent_rounded,
          'Profit-sharing ratio',
          'Ensure the total proposed profit-sharing percentage of all partners is 100%.',
        ),
      ],
    );
  }

  Widget _partnerCard({
    required String title,
    required String number,
    required TextEditingController nameController,
    required TextEditingController panController,
    required TextEditingController mobileController,
    required TextEditingController shareController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 39,
                width: 39,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFF0E7490),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field(
            controller: nameController,
            label: 'Partner Name',
            hint: 'Full name',
            icon: Icons.person_outline,
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
            hint: 'Mobile',
            icon: Icons.phone_outlined,
            required: true,
            keyboard: TextInputType.phone,
          ),
          _field(
            controller: shareController,
            label: 'Profit Sharing %',
            hint: 'Example: 50',
            icon: Icons.percent_rounded,
            required: true,
            keyboard: TextInputType.number,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3
  // ============================================================

  Widget _businessStep() {
    return _section(
      key: const ValueKey('business'),
      number: '03',
      title: 'Business & Address',
      subtitle: 'Tell us what the firm does and where it operates.',
      icon: Icons.storefront_outlined,
      children: [
        const Text(
          'Business Type',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _businessTypeCard('Trading', Icons.shopping_bag_outlined),
            const SizedBox(width: 8),
            _businessTypeCard('Services', Icons.design_services_outlined),
            const SizedBox(width: 8),
            _businessTypeCard('Manufacturing', Icons.factory_outlined),
          ],
        ),
        const SizedBox(height: 17),
        _field(
          controller: businessActivityController,
          label: 'Nature of Business',
          hint: 'Describe products or services',
          icon: Icons.work_outline_rounded,
          required: true,
          maxLines: 2,
        ),
        _field(
          controller: addressController,
          label: 'Principal Business Address',
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
                label: 'City',
                hint: 'City',
                icon: Icons.location_city_outlined,
                required: true,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _field(
                controller: pincodeController,
                label: 'PIN Code',
                hint: '6 digits',
                icon: Icons.pin_drop_outlined,
                required: true,
                keyboard: TextInputType.number,
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

  Widget _businessTypeCard(String title, IconData icon) {
    final selected = businessType == title;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            businessType = title;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFECFEFF) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0891B2)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? const Color(0xFF0891B2)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: title == 'Manufacturing' ? 9 : 10.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFF0E7490)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
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
              selectedColor: const Color(0xFFCFFAFE),
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF0891B2)
                    : const Color(0xFFE5E7EB),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF0E7490)
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

  Widget _bankStep() {
    return _section(
      key: const ValueKey('bank'),
      number: '04',
      title: 'Bank Details',
      subtitle: 'Enter the proposed or existing banking details of the firm.',
      icon: Icons.account_balance_outlined,
      children: [
        _field(
          controller: bankNameController,
          label: 'Bank Name',
          hint: 'Enter bank name',
          icon: Icons.account_balance_outlined,
        ),
        _field(
          controller: accountNumberController,
          label: 'Account Number',
          hint: 'Enter account number',
          icon: Icons.numbers_outlined,
          keyboard: TextInputType.number,
        ),
        _field(
          controller: ifscController,
          label: 'IFSC Code',
          hint: 'SBIN0001234',
          icon: Icons.account_tree_outlined,
        ),
        _infoBox(
          Icons.account_balance_wallet_outlined,
          'Bank account',
          'If a firm bank account has not yet been opened, you can leave these fields blank and provide them later.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 5 REVIEW
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
              colors: [Color(0xFF0E7490), Color(0xFF0891B2)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 40),
              SizedBox(height: 11),
              Text(
                'Review Partnership',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Check all firm and partner details before submitting your application.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _reviewCard('Firm', Icons.handshake_outlined, [
          _reviewRow('Firm Name', firmNameController.text),
          _reviewRow('Business', businessType),
          _reviewRow('Activity', businessActivityController.text),
          _reviewRow('Contact', mobileController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Partners', Icons.groups_outlined, [
          _reviewRow('Partner 1', partner1NameController.text),
          _reviewRow('Share', '${partner1ShareController.text}%'),
          _reviewRow('Partner 2', partner2NameController.text),
          _reviewRow('Share', '${partner2ShareController.text}%'),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Business Address', Icons.location_on_outlined, [
          _reviewRow('City', cityController.text),
          _reviewRow('District', districtController.text),
          _reviewRow('State', stateController.text),
          _reviewRow('Possession', possessionType),
        ]),

        const SizedBox(height: 14),

        _infoBox(
          Icons.track_changes_rounded,
          'Track application',
          'After submission, this partnership request will automatically appear in My Applications.',
        ),
      ],
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section({
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
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF0891B2), size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP $number',
                      style: const TextStyle(
                        color: Color(0xFF0891B2),
                        fontSize: 9.5,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
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
                        fontSize: 12,
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
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: maxLines == 1
              ? Icon(icon, color: const Color(0xFF0891B2), size: 20)
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0891B2), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String title, String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFECFEFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFCFFAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0891B2), size: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0E7490),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
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
  // REVIEW
  // ============================================================

  Widget _reviewCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E9EF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF0891B2), size: 19),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const Divider(color: Color(0xFFF0F2F5)),
          ...children,
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 5,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF0891B2)),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              if (currentStep > 0) ...[
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0891B2),
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
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentStep == 4
                                    ? 'Submit Partnership Application'
                                    : 'Save & Continue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
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

  void _continue() {
    if (currentStep < 4) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Validate partnership share ratio
      if (currentStep == 1) {
        final p1 = double.tryParse(partner1ShareController.text.trim()) ?? 0;

        final p2 = double.tryParse(partner2ShareController.text.trim()) ?? 0;

        if ((p1 + p2) != 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Total profit-sharing ratio must be 100%'),
            ),
          );
          return;
        }
      }

      setState(() {
        currentStep++;
      });

      return;
    }

    _submitApplication();
  }

  // ============================================================
  // FIRESTORE SUBMISSION
  // ============================================================

  Future<void> _submitApplication() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please sign in to continue');
      }

      final ref = FirebaseFirestore.instance
          .collection('registrationApplications')
          .doc();

      await ref.set({
        'applicationId': ref.id,
        'userId': user.uid,

        'registrationType': 'PARTNERSHIP',
        'status': 'submitted',

        // Used by MyApplicationsScreen
        'legalName': firmNameController.text.trim(),

        'tradeName': firmNameController.text.trim(),

        'businessType': businessType,

        'businessActivity': businessActivityController.text.trim(),

        'contact': {
          'mobile': mobileController.text.trim(),
          'email': emailController.text.trim(),
        },

        'partners': [
          {
            'name': partner1NameController.text.trim(),
            'pan': partner1PanController.text.trim().toUpperCase(),
            'mobile': partner1MobileController.text.trim(),
            'profitShare': partner1ShareController.text.trim(),
          },
          {
            'name': partner2NameController.text.trim(),
            'pan': partner2PanController.text.trim().toUpperCase(),
            'mobile': partner2MobileController.text.trim(),
            'profitShare': partner2ShareController.text.trim(),
          },
        ],

        'businessAddress': {
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'district': districtController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
          'possessionType': possessionType,
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
            'title': 'Partnership Application Submitted',
            'timestamp': Timestamp.now(),
          },
        ],
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111827),
          content: Text('Unable to submit partnership application: $e'),
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
