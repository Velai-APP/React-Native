import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_applications_screen.dart';

class LlpRegistrationScreen extends StatefulWidget {
  const LlpRegistrationScreen({super.key});

  @override
  State<LlpRegistrationScreen> createState() => _LlpRegistrationScreenState();
}

class _LlpRegistrationScreenState extends State<LlpRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  // ============================================================
  // LLP NAME
  // ============================================================

  final proposedName1Controller = TextEditingController();
  final proposedName2Controller = TextEditingController();

  // ============================================================
  // PARTNERS
  // ============================================================

  final partner1NameController = TextEditingController();
  final partner1PanController = TextEditingController();
  final partner1MobileController = TextEditingController();
  final partner1EmailController = TextEditingController();

  final partner2NameController = TextEditingController();
  final partner2PanController = TextEditingController();
  final partner2MobileController = TextEditingController();
  final partner2EmailController = TextEditingController();

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
  // CONTRIBUTION
  // ============================================================

  final totalContributionController = TextEditingController();
  final partner1ContributionController = TextEditingController();
  final partner2ContributionController = TextEditingController();

  String possessionType = 'Owned';

  final List<_StepInfo> steps = const [
    _StepInfo(title: 'Names', icon: Icons.apartment_outlined),
    _StepInfo(title: 'Partners', icon: Icons.groups_2_outlined),
    _StepInfo(title: 'Business', icon: Icons.business_center_outlined),
    _StepInfo(title: 'Capital', icon: Icons.currency_rupee_rounded),
    _StepInfo(title: 'Review', icon: Icons.fact_check_outlined),
  ];

  @override
  void dispose() {
    proposedName1Controller.dispose();
    proposedName2Controller.dispose();

    partner1NameController.dispose();
    partner1PanController.dispose();
    partner1MobileController.dispose();
    partner1EmailController.dispose();

    partner2NameController.dispose();
    partner2PanController.dispose();
    partner2MobileController.dispose();
    partner2EmailController.dispose();

    businessActivityController.dispose();

    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();

    totalContributionController.dispose();
    partner1ContributionController.dispose();
    partner2ContributionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4FA),
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
          colors: [Color(0xFF2E1065), Color(0xFF5B21B6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(.18),
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
                color: Colors.purpleAccent.withOpacity(.05),
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
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'LIMITED LIABILITY PARTNERSHIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.3,
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
                      Icons.groups_2_outlined,
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
                          'LLP Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: -.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Flexible partnership with limited liability',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
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
        border: Border.all(color: const Color(0xFFE7E2ED)),
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
                          ? const Color(0xFF7C3AED)
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
                          ? const Color(0xFF7C3AED)
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
        return _partnersStep();
      case 2:
        return _businessStep();
      case 3:
        return _contributionStep();
      case 4:
        return _reviewStep();
      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // STEP 1 - PROPOSED NAMES
  // ============================================================

  Widget _nameStep() {
    return _section(
      key: const ValueKey('names'),
      number: '01',
      title: 'Proposed LLP Names',
      subtitle:
          'Provide your preferred names for the Limited Liability Partnership.',
      icon: Icons.apartment_outlined,
      children: [
        _field(
          controller: proposedName1Controller,
          label: 'Proposed Name 1',
          hint: 'Example: ABC Consulting LLP',
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
          'Name preference',
          'Provide a unique proposed name and keep an alternative name ready in case the first preference is unavailable.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2 - PARTNERS
  // ============================================================

  Widget _partnersStep() {
    return _section(
      key: const ValueKey('partners'),
      number: '02',
      title: 'Designated Partners',
      subtitle: 'Enter the details of the proposed designated partners.',
      icon: Icons.groups_2_outlined,
      children: [
        _partnerCard(
          title: 'Designated Partner 1',
          number: '01',
          nameController: partner1NameController,
          panController: partner1PanController,
          mobileController: partner1MobileController,
          emailController: partner1EmailController,
        ),

        const SizedBox(height: 14),

        _partnerCard(
          title: 'Designated Partner 2',
          number: '02',
          nameController: partner2NameController,
          panController: partner2PanController,
          mobileController: partner2MobileController,
          emailController: partner2EmailController,
        ),

        const SizedBox(height: 4),

        _infoBox(
          Icons.groups_outlined,
          'Partner structure',
          'This screen currently collects two designated partners. You can later extend it with an Add Partner option.',
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
    required TextEditingController emailController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE9E2F4)),
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
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
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
            hint: 'Mobile number',
            icon: Icons.phone_outlined,
            required: true,
            keyboard: TextInputType.phone,
          ),

          _field(
            controller: emailController,
            label: 'Email Address',
            hint: 'partner@example.com',
            icon: Icons.email_outlined,
            required: true,
            keyboard: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEP 3 - BUSINESS
  // ============================================================

  Widget _businessStep() {
    return _section(
      key: const ValueKey('business'),
      number: '03',
      title: 'Business & Registered Office',
      subtitle: 'Tell us what the LLP will do and where it will operate from.',
      icon: Icons.business_center_outlined,
      children: [
        _field(
          controller: businessActivityController,
          label: 'Main Business Activity',
          hint: 'Describe products or services',
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
              selectedColor: const Color(0xFFEDE9FE),
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFFE5E7EB),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF6D28D9)
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
  // STEP 4 - CONTRIBUTION
  // ============================================================

  Widget _contributionStep() {
    return _section(
      key: const ValueKey('capital'),
      number: '04',
      title: 'Partner Contribution',
      subtitle: 'Enter the proposed capital contribution to the LLP.',
      icon: Icons.currency_rupee_rounded,
      children: [
        _field(
          controller: totalContributionController,
          label: 'Total Contribution',
          hint: 'Example: 200000',
          icon: Icons.currency_rupee_rounded,
          required: true,
          keyboard: TextInputType.number,
        ),

        _field(
          controller: partner1ContributionController,
          label: 'Partner 1 Contribution',
          hint: 'Example: 100000',
          icon: Icons.person_outline,
          required: true,
          keyboard: TextInputType.number,
        ),

        _field(
          controller: partner2ContributionController,
          label: 'Partner 2 Contribution',
          hint: 'Example: 100000',
          icon: Icons.person_outline,
          required: true,
          keyboard: TextInputType.number,
        ),

        _infoBox(
          Icons.calculate_outlined,
          'Contribution check',
          'The total partner contribution should match the total proposed LLP contribution.',
        ),
      ],
    );
  }

  // ============================================================
  // STEP 5 - REVIEW
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
              colors: [Color(0xFF5B21B6), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Column(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 40),
              SizedBox(height: 11),
              Text(
                'Review LLP Application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Check the proposed LLP name, partners, registered office and contribution before submission.',
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

        _reviewCard('Proposed LLP', Icons.apartment_outlined, [
          _reviewRow('Name 1', proposedName1Controller.text),
          _reviewRow('Name 2', proposedName2Controller.text),
          _reviewRow('Activity', businessActivityController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Designated Partners', Icons.groups_2_outlined, [
          _reviewRow('Partner 1', partner1NameController.text),
          _reviewRow('Partner 2', partner2NameController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Registered Office', Icons.location_on_outlined, [
          _reviewRow('City', cityController.text),
          _reviewRow('District', districtController.text),
          _reviewRow('State', stateController.text),
          _reviewRow('Possession', possessionType),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Contribution', Icons.currency_rupee_rounded, [
          _reviewRow('Total', '₹${totalContributionController.text}'),
          _reviewRow('Partner 1', '₹${partner1ContributionController.text}'),
          _reviewRow('Partner 2', '₹${partner2ContributionController.text}'),
        ]),

        const SizedBox(height: 14),

        _infoBox(
          Icons.track_changes_rounded,
          'Track application',
          'After submission, your LLP application will automatically appear under My Applications.',
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
        border: Border.all(color: const Color(0xFFE7E2ED)),
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
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP $number',
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
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
              ? Icon(icon, color: const Color(0xFF7C3AED), size: 20)
              : null,
          filled: true,
          fillColor: const Color(0xFFFAF9FC),
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
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
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
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 20),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6D28D9),
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
        border: Border.all(color: const Color(0xFFE7E2ED)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 19),
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
          const Divider(color: Color(0xFFF0EDF4)),
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
        border: const Border(top: BorderSide(color: Color(0xFFE7E2ED))),
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
              backgroundColor: const Color(0xFFE7E2ED),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
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
                      backgroundColor: const Color(0xFF7C3AED),
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
                                    ? 'Submit LLP Application'
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
        final total =
            double.tryParse(totalContributionController.text.trim()) ?? 0;

        final partner1 =
            double.tryParse(partner1ContributionController.text.trim()) ?? 0;

        final partner2 =
            double.tryParse(partner2ContributionController.text.trim()) ?? 0;

        if ((partner1 + partner2) != total) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Partner contributions must equal total contribution',
              ),
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

      await ref.set({
        'applicationId': ref.id,
        'userId': user.uid,

        'registrationType': 'LLP',
        'status': 'submitted',

        // Used by MyApplicationsScreen
        'legalName': proposedName1Controller.text.trim(),

        'proposedNames': [
          proposedName1Controller.text.trim(),
          proposedName2Controller.text.trim(),
        ],

        'partners': [
          {
            'name': partner1NameController.text.trim(),
            'pan': partner1PanController.text.trim().toUpperCase(),
            'mobile': partner1MobileController.text.trim(),
            'email': partner1EmailController.text.trim(),
            'contribution': partner1ContributionController.text.trim(),
          },
          {
            'name': partner2NameController.text.trim(),
            'pan': partner2PanController.text.trim().toUpperCase(),
            'mobile': partner2MobileController.text.trim(),
            'email': partner2EmailController.text.trim(),
            'contribution': partner2ContributionController.text.trim(),
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

        'totalContribution': totalContributionController.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),

        'updatedAt': FieldValue.serverTimestamp(),

        'statusHistory': [
          {
            'status': 'submitted',
            'title': 'LLP Application Submitted',
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
          content: Text('Unable to submit LLP application: $e'),
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
