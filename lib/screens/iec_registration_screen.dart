import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'my_applications_screen.dart';

class IecRegistrationScreen extends StatefulWidget {
  const IecRegistrationScreen({super.key});

  @override
  State<IecRegistrationScreen> createState() => _IecRegistrationScreenState();
}

class _IecRegistrationScreenState extends State<IecRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  int currentStep = 0;
  bool isSubmitting = false;

  // Applicant
  final firmNameController = TextEditingController();
  final panController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  // Business
  final gstinController = TextEditingController();
  final businessActivityController = TextEditingController();

  // Address
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Bank
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final branchController = TextEditingController();

  String constitution = 'Proprietorship';
  String activityType = 'Export';
  String possessionType = 'Owned';

  final constitutionTypes = [
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

  final steps = const [
    _IecStep('Applicant', Icons.person_outline_rounded),
    _IecStep('Business', Icons.business_center_outlined),
    _IecStep('Address', Icons.location_on_outlined),
    _IecStep('Bank', Icons.account_balance_outlined),
    _IecStep('Review', Icons.fact_check_outlined),
  ];

  @override
  void dispose() {
    firmNameController.dispose();
    panController.dispose();
    mobileController.dispose();
    emailController.dispose();
    gstinController.dispose();
    businessActivityController.dispose();
    addressController.dispose();
    cityController.dispose();
    districtController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    branchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _hero()),
                    SliverToBoxAdapter(child: _stepper()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 7, 16, 30),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: _currentStep(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF082F49), Color(0xFF0369A1), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withOpacity(.20),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),

          Positioned(
            right: 50,
            bottom: -75,
            child: Container(
              width: 145,
              height: 145,
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
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
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
                          Icons.public_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'IMPORT • EXPORT',
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
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      size: 33,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IEC Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: -.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Import Export Code application',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 23),

              Row(
                children: [
                  _heroFeature(Icons.route_outlined, '5 Steps', 'Guided'),
                  const SizedBox(width: 8),
                  _heroFeature(Icons.security_rounded, 'Secure', 'Application'),
                  const SizedBox(width: 8),
                  _heroFeature(
                    Icons.track_changes_rounded,
                    'Track',
                    'Live status',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFeature(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.06)),
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
              style: TextStyle(
                color: Colors.white.withOpacity(.60),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STEPPER
  // ============================================================

  Widget _stepper() {
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
                      setState(() => currentStep = index);
                    }
                  : null,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: active ? 42 : 36,
                    height: active ? 42 : 36,
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

  Widget _currentStep() {
    switch (currentStep) {
      case 0:
        return _applicant();
      case 1:
        return _business();
      case 2:
        return _address();
      case 3:
        return _bank();
      case 4:
        return _review();
      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // APPLICANT
  // ============================================================

  Widget _applicant() {
    return _section(
      key: const ValueKey('applicant'),
      number: '01',
      icon: Icons.person_outline_rounded,
      title: 'Applicant Details',
      subtitle: 'Enter the details of the firm applying for IEC.',
      children: [
        _field(
          firmNameController,
          'Firm / Business Name',
          'Enter legal name',
          Icons.business_outlined,
          required: true,
        ),

        _field(
          panController,
          'PAN',
          'ABCDE1234F',
          Icons.credit_card_outlined,
          required: true,
        ),

        _field(
          mobileController,
          'Mobile Number',
          'Enter mobile number',
          Icons.phone_outlined,
          required: true,
          keyboard: TextInputType.phone,
        ),

        _field(
          emailController,
          'Email Address',
          'name@example.com',
          Icons.email_outlined,
          required: true,
          keyboard: TextInputType.emailAddress,
        ),

        _info(
          Icons.info_outline_rounded,
          'Applicant information',
          'Enter the legal details of the entity for which the IEC application is being submitted.',
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS
  // ============================================================

  Widget _business() {
    return _section(
      key: const ValueKey('business'),
      number: '02',
      icon: Icons.business_center_outlined,
      title: 'Business Details',
      subtitle: 'Tell us about the constitution and trade activity.',
      children: [
        _dropdown(
          title: 'Constitution of Business',
          value: constitution,
          items: constitutionTypes,
          icon: Icons.account_tree_outlined,
          onChanged: (value) {
            if (value != null) {
              setState(() => constitution = value);
            }
          },
        ),

        const SizedBox(height: 15),

        const Text(
          'Import / Export Activity',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _activityChoice('Import', Icons.south_west_rounded),
            const SizedBox(width: 8),
            _activityChoice('Export', Icons.north_east_rounded),
            const SizedBox(width: 8),
            _activityChoice('Both', Icons.sync_alt_rounded),
          ],
        ),

        const SizedBox(height: 16),

        _field(
          businessActivityController,
          'Nature of Business',
          'Goods / services / products',
          Icons.inventory_2_outlined,
          required: true,
        ),

        _field(
          gstinController,
          'GSTIN',
          'Optional',
          Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  Widget _activityChoice(String title, IconData icon) {
    final selected = activityType == title;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => activityType = title);
        },
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(15),
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
                size: 19,
                color: selected
                    ? const Color(0xFF0891B2)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
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

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _address() {
    return _section(
      key: const ValueKey('address'),
      number: '03',
      icon: Icons.location_on_outlined,
      title: 'Business Address',
      subtitle: 'Enter the registered or principal business location.',
      children: [
        _field(
          addressController,
          'Address',
          'Door no, street, area',
          Icons.home_work_outlined,
          required: true,
          maxLines: 3,
        ),

        Row(
          children: [
            Expanded(
              child: _field(
                cityController,
                'City',
                'City',
                Icons.location_city_outlined,
                required: true,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _field(
                pincodeController,
                'PIN Code',
                '6 digits',
                Icons.pin_drop_outlined,
                required: true,
                keyboard: TextInputType.number,
              ),
            ),
          ],
        ),

        _field(
          districtController,
          'District',
          'District',
          Icons.map_outlined,
          required: true,
        ),

        _field(
          stateController,
          'State',
          'State',
          Icons.public_outlined,
          required: true,
        ),

        _possession(),
      ],
    );
  }

  Widget _possession() {
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
                setState(() => possessionType = item);
              },
              selectedColor: const Color(0xFFCFFAFE),
              backgroundColor: const Color(0xFFF8FAFC),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF0891B2)
                    : const Color(0xFFE5E7EB),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // BANK
  // ============================================================

  Widget _bank() {
    return _section(
      key: const ValueKey('bank'),
      number: '04',
      icon: Icons.account_balance_outlined,
      title: 'Bank Details',
      subtitle: 'Enter the bank account details of the applicant.',
      children: [
        _field(
          bankNameController,
          'Bank Name',
          'Enter bank name',
          Icons.account_balance_outlined,
          required: true,
        ),

        _field(
          accountNumberController,
          'Account Number',
          'Enter account number',
          Icons.numbers_rounded,
          required: true,
          keyboard: TextInputType.number,
        ),

        _field(
          ifscController,
          'IFSC Code',
          'Example: SBIN0001234',
          Icons.account_tree_outlined,
          required: true,
        ),

        _field(
          branchController,
          'Branch',
          'Bank branch',
          Icons.location_city_outlined,
        ),

        _info(
          Icons.verified_user_outlined,
          'Bank verification',
          'Provide the bank account maintained in the name of the applicant or business.',
        ),
      ],
    );
  }

  // ============================================================
  // REVIEW
  // ============================================================

  Widget _review() {
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
                'Review IEC Application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Check your information before submitting the registration request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        _reviewCard('Applicant', Icons.person_outline_rounded, [
          _reviewRow('Firm Name', firmNameController.text),
          _reviewRow('PAN', panController.text.toUpperCase()),
          _reviewRow('Mobile', mobileController.text),
          _reviewRow('Email', emailController.text),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Business', Icons.business_center_outlined, [
          _reviewRow('Constitution', constitution),
          _reviewRow('Activity', activityType),
          _reviewRow('Business', businessActivityController.text),
          _reviewRow(
            'GSTIN',
            gstinController.text.isEmpty
                ? 'Not provided'
                : gstinController.text.toUpperCase(),
          ),
        ]),

        const SizedBox(height: 12),

        _reviewCard('Bank Account', Icons.account_balance_outlined, [
          _reviewRow('Bank', bankNameController.text),
          _reviewRow('Account', _maskAccount(accountNumberController.text)),
          _reviewRow('IFSC', ifscController.text.toUpperCase()),
        ]),

        const SizedBox(height: 14),

        _info(
          Icons.track_changes_rounded,
          'Live application tracking',
          'After submission, track your IEC registration from My Applications.',
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
    required IconData icon,
    required String title,
    required String subtitle,
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
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF0891B2)),
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
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
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

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    bool required = false,
    TextInputType? keyboard,
    int maxLines = 1,
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
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String title,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: title,
        prefixIcon: Icon(icon, color: const Color(0xFF0891B2)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0891B2)),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _info(IconData icon, String title, String text) {
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
  // REVIEW HELPERS
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
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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

  String _maskAccount(String value) {
    if (value.length <= 4) return value;
    return '••••••${value.substring(value.length - 4)}';
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _bottomBar() {
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
                      setState(() => currentStep--);
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
                                    ? 'Submit IEC Application'
                                    : 'Save & Continue',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
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
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        currentStep++;
      });
      return;
    }

    _submit();
  }

  // ============================================================
  // FIRESTORE SUBMISSION
  // ============================================================

  Future<void> _submit() async {
    setState(() => isSubmitting = true);

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

        // Important for common tracking screen
        'registrationType': 'IEC',
        'status': 'submitted',

        'firmName': firmNameController.text.trim(),
        'legalName': firmNameController.text.trim(),

        'pan': panController.text.trim().toUpperCase(),

        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),

        'constitution': constitution,

        'activityType': activityType,

        'businessActivity': businessActivityController.text.trim(),

        'gstin': gstinController.text.trim().toUpperCase(),

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
          'branch': branchController.text.trim(),
        },

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        'statusHistory': [
          {
            'status': 'submitted',
            'title': 'IEC Application Submitted',
            'timestamp': Timestamp.now(),
          },
        ],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('IEC application submitted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to submit IEC application: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }
}

class _IecStep {
  final String title;
  final IconData icon;

  const _IecStep(this.title, this.icon);
}
