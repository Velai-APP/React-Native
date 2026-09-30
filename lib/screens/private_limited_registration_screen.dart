import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_applications_screen.dart';

class PrivateLimitedRegistrationScreen extends StatefulWidget {
  const PrivateLimitedRegistrationScreen({super.key});

  @override
  State<PrivateLimitedRegistrationScreen> createState() =>
      _PrivateLimitedRegistrationScreenState();
}

class _PrivateLimitedRegistrationScreenState
    extends State<PrivateLimitedRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  // ============================================================
  // COMPANY NAME
  // ============================================================

  final proposedName1Controller = TextEditingController();
  final proposedName2Controller = TextEditingController();

  // ============================================================
  // DIRECTORS
  // ============================================================

  final director1NameController = TextEditingController();
  final director1PanController = TextEditingController();
  final director1MobileController = TextEditingController();
  final director1EmailController = TextEditingController();

  final director2NameController = TextEditingController();
  final director2PanController = TextEditingController();
  final director2MobileController = TextEditingController();
  final director2EmailController = TextEditingController();

  // ============================================================
  // BUSINESS
  // ============================================================

  final businessActivityController = TextEditingController();

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // ============================================================
  // CAPITAL
  // ============================================================

  final authorisedCapitalController = TextEditingController(text: '100000');

  final paidUpCapitalController = TextEditingController(text: '100000');

  final shareValueController = TextEditingController(text: '10');

  String possessionType = 'Owned';

  final List<_StepInfo> steps = const [
    _StepInfo(title: 'Names', icon: Icons.apartment_rounded),
    _StepInfo(title: 'Directors', icon: Icons.groups_outlined),
    _StepInfo(title: 'Business', icon: Icons.business_center_outlined),
    _StepInfo(title: 'Capital', icon: Icons.currency_rupee_rounded),
    _StepInfo(title: 'Review', icon: Icons.fact_check_outlined),
  ];

  @override
  void dispose() {
    proposedName1Controller.dispose();
    proposedName2Controller.dispose();

    director1NameController.dispose();
    director1PanController.dispose();
    director1MobileController.dispose();
    director1EmailController.dispose();

    director2NameController.dispose();
    director2PanController.dispose();
    director2MobileController.dispose();
    director2EmailController.dispose();

    businessActivityController.dispose();

    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    authorisedCapitalController.dispose();
    paidUpCapitalController.dispose();
    shareValueController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F6),
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
          colors: [Color(0xFF4C0519), Color(0xFF9F1239), Color(0xFFBE123C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBE123C).withOpacity(.18),
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
                color: Colors.pinkAccent.withOpacity(.05),
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
                          Icons.verified_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PRIVATE LIMITED COMPANY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
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
                      Icons.apartment_rounded,
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
                          'Private Limited',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: -.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Build a scalable company',
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
                    child: _heroStat(Icons.groups_outlined, '2+', 'Directors'),
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
        border: Border.all(color: const Color(0xFFE9E2E6)),
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
                          ? const Color(0xFFBE123C)
                          : const Color(0xFFF3F4F6),
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
                          ? const Color(0xFFBE123C)
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
        return _nameStep();

      case 1:
        return _directorStep();

      case 2:
        return _businessStep();

      case 3:
        return _capitalStep();

      case 4:
        return _reviewStep();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1
  // ============================================================

  Widget _nameStep() {
    return _section(
      key: const ValueKey('names'),
      number: '01',
      title: 'Proposed Company Names',
      subtitle: 'Provide your preferred names for the proposed company.',
      icon: Icons.apartment_rounded,
      children: [
        _field(
          controller: proposedName1Controller,
          label: 'Proposed Name 1',
          hint: 'Example: ABC Technologies Private Limited',
          icon: Icons.business_outlined,
          required: true,
        ),

        _field(
          controller: proposedName2Controller,
          label: 'Proposed Name 2',
          hint: 'Second preference',
          icon: Icons.business_outlined,
        ),

        _infoBox(
          Icons.lightbulb_outline_rounded,
          'Company name preference',
          'Keep an alternative proposed name ready in case your first preference is unavailable.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2
  // ============================================================

  Widget _directorStep() {
    return _section(
      key: const ValueKey('directors'),
      number: '02',
      title: 'Director Details',
      subtitle: 'Enter the details of the proposed directors.',
      icon: Icons.groups_outlined,
      children: [
        _directorCard(
          title: 'Director 1',
          number: '01',
          nameController: director1NameController,
          panController: director1PanController,
          mobileController: director1MobileController,
          emailController: director1EmailController,
        ),

        const SizedBox(height: 14),

        _directorCard(
          title: 'Director 2',
          number: '02',
          nameController: director2NameController,
          panController: director2PanController,
          mobileController: director2MobileController,
          emailController: director2EmailController,
        ),

        const SizedBox(height: 4),

        _infoBox(
          Icons.groups_outlined,
          'Director information',
          'This version collects two proposed directors. You can later extend it with an Add Director option.',
        ),
      ],
    );
  }

  Widget _directorCard({
    required String title,
    required String number,
    required TextEditingController nameController,
    required TextEditingController panController,
    required TextEditingController mobileController,
    required TextEditingController emailController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FA),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFF1E3E8)),
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
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFFBE123C),
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
            label: 'Director Name',
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
            hint: 'Mobile number',
            icon: Icons.phone_outlined,
            required: true,
            keyboard: TextInputType.phone,
          ),

          _field(
            controller: emailController,
            label: 'Email Address',
            hint: 'director@example.com',
            icon: Icons.email_outlined,
            required: true,
            keyboard: TextInputType.emailAddress,
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
      title: 'Business & Registered Office',
      subtitle:
          'Tell us what the company will do and where it will be registered.',
      icon: Icons.business_center_outlined,
      children: [
        _field(
          controller: businessActivityController,
          label: 'Main Business Activity',
          hint: 'Describe the proposed business',
          icon: Icons.work_outline_rounded,
          required: true,
          maxLines: 2,
        ),

        _field(
          controller: addressController,
          label: 'Registered Office Address',
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

  Widget _possessionSelector() {
    const options = ['Owned', 'Rented', 'Leased', 'Consent'];

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
              selectedColor: const Color(0xFFFFE4E6),
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(
                color: selected
                    ? const Color(0xFFBE123C)
                    : const Color(0xFFE5E7EB),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF9F1239)
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

  Widget _capitalStep() {
    return _section(
      key: const ValueKey('capital'),
      number: '04',
      title: 'Share Capital',
      subtitle: 'Enter the proposed capital structure of the company.',
      icon: Icons.currency_rupee_rounded,
      children: [
        _field(
          controller: authorisedCapitalController,
          label: 'Authorised Capital',
          hint: '100000',
          icon: Icons.currency_rupee_rounded,
          required: true,
          keyboard: TextInputType.number,
        ),

        _field(
          controller: paidUpCapitalController,
          label: 'Paid-up Capital',
          hint: '100000',
          icon: Icons.account_balance_wallet_outlined,
          required: true,
          keyboard: TextInputType.number,
        ),

        _field(
          controller: shareValueController,
          label: 'Face Value Per Share',
          hint: '10',
          icon: Icons.numbers_rounded,
          required: true,
          keyboard: TextInputType.number,
        ),

        _capitalSummary(),

        const SizedBox(height: 13),

        _infoBox(
          Icons.calculate_outlined,
          'Capital structure',
          'Paid-up capital should not exceed the authorised capital entered for the proposed company.',
        ),
      ],
    );
  }

  Widget _capitalSummary() {
    final authorised = double.tryParse(authorisedCapitalController.text) ?? 0;

    final paidUp = double.tryParse(paidUpCapitalController.text) ?? 0;

    final faceValue = double.tryParse(shareValueController.text) ?? 0;

    final shares = faceValue > 0 ? paidUp / faceValue : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFF7F8)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _capitalItem(
              'Authorised',
              '₹${authorised.toStringAsFixed(0)}',
            ),
          ),

          Container(width: 1, height: 35, color: const Color(0xFFF1D6DC)),

          Expanded(
            child: _capitalItem('Paid-up', '₹${paidUp.toStringAsFixed(0)}'),
          ),

          Container(width: 1, height: 35, color: const Color(0xFFF1D6DC)),

          Expanded(child: _capitalItem('Shares', shares.toStringAsFixed(0))),
        ],
      ),
    );
  }

  Widget _capitalItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF9F1239),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 9.5),
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
              colors: [Color(0xFF9F1239), Color(0xFFBE123C)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 40),

              SizedBox(height: 11),

              Text(
                'Review Company Application',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 6),

              Text(
                'Check the proposed company, directors, registered office and share capital before submission.',
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

        _reviewCard('Proposed Company', Icons.apartment_rounded, [
          _reviewRow('Name 1', proposedName1Controller.text),
          _reviewRow('Name 2', proposedName2Controller.text),
          _reviewRow('Activity', businessActivityController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Directors', Icons.groups_outlined, [
          _reviewRow('Director 1', director1NameController.text),
          _reviewRow('Director 2', director2NameController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Registered Office', Icons.location_on_outlined, [
          _reviewRow('City', cityController.text),
          _reviewRow('District', districtController.text),
          _reviewRow('State', stateController.text),
          _reviewRow('Possession', possessionType),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Share Capital', Icons.currency_rupee_rounded, [
          _reviewRow('Authorised', '₹${authorisedCapitalController.text}'),
          _reviewRow('Paid-up', '₹${paidUpCapitalController.text}'),
          _reviewRow('Face Value', '₹${shareValueController.text}'),
        ]),

        const SizedBox(height: 14),

        _infoBox(
          Icons.track_changes_rounded,
          'Track incorporation',
          'After submission, the Private Limited application will automatically appear in My Applications.',
        ),
      ],
    );
  }

  // ============================================================
  // COMMON SECTION
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
        border: Border.all(color: const Color(0xFFE9E2E6)),
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
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFFBE123C), size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP $number',
                      style: const TextStyle(
                        color: Color(0xFFBE123C),
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
        onChanged: (_) {
          if (currentStep == 3) {
            setState(() {});
          }
        },
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
              ? Icon(icon, color: const Color(0xFFBE123C), size: 20)
              : null,

          filled: true,

          fillColor: const Color(0xFFFFFAFB),

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
            borderSide: const BorderSide(color: Color(0xFFBE123C), width: 1.5),
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
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFBE123C), size: 20),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF9F1239),
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
        border: Border.all(color: const Color(0xFFE9E2E6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFBE123C), size: 19),
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

          const Divider(color: Color(0xFFF3ECEF)),

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
  // BOTTOM
  // ============================================================

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE9E2E6))),
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
              backgroundColor: const Color(0xFFE9E2E6),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFBE123C)),
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
                      backgroundColor: const Color(0xFFBE123C),
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
                                    ? 'Submit Company Application'
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

      if (currentStep == 3) {
        final authorised =
            double.tryParse(authorisedCapitalController.text.trim()) ?? 0;

        final paidUp =
            double.tryParse(paidUpCapitalController.text.trim()) ?? 0;

        final faceValue =
            double.tryParse(shareValueController.text.trim()) ?? 0;

        if (paidUp > authorised) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Paid-up capital cannot exceed authorised capital'),
            ),
          );

          return;
        }

        if (faceValue <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Enter a valid face value per share'),
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
  // FIRESTORE
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

      final authorised =
          double.tryParse(authorisedCapitalController.text.trim()) ?? 0;

      final paidUp = double.tryParse(paidUpCapitalController.text.trim()) ?? 0;

      final faceValue = double.tryParse(shareValueController.text.trim()) ?? 0;

      final totalShares = faceValue > 0 ? paidUp / faceValue : 0;

      await ref.set({
        'applicationId': ref.id,

        'userId': user.uid,

        'registrationType': 'PRIVATE LIMITED',

        'status': 'submitted',

        // Used in MyApplicationsScreen
        'legalName': proposedName1Controller.text.trim(),

        'proposedNames': [
          proposedName1Controller.text.trim(),
          proposedName2Controller.text.trim(),
        ],

        'directors': [
          {
            'name': director1NameController.text.trim(),

            'pan': director1PanController.text.trim().toUpperCase(),

            'mobile': director1MobileController.text.trim(),

            'email': director1EmailController.text.trim(),
          },

          {
            'name': director2NameController.text.trim(),

            'pan': director2PanController.text.trim().toUpperCase(),

            'mobile': director2MobileController.text.trim(),

            'email': director2EmailController.text.trim(),
          },
        ],

        'businessActivity': businessActivityController.text.trim(),

        'registeredOffice': {
          'address': addressController.text.trim(),

          'city': cityController.text.trim(),

          'district': districtController.text.trim(),

          'state': stateController.text.trim(),

          'pincode': pincodeController.text.trim(),

          'possessionType': possessionType,
        },

        'capital': {
          'authorisedCapital': authorised,

          'paidUpCapital': paidUp,

          'faceValue': faceValue,

          'totalShares': totalShares,
        },

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),

        'statusHistory': [
          {
            'status': 'submitted',

            'title': 'Private Limited Application Submitted',

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
          content: Text('Unable to submit company application: $e'),
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
