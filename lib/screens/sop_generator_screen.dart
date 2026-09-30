import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'sop_preview_screen.dart';

class SopGeneratorScreen extends StatefulWidget {
  const SopGeneratorScreen({super.key});

  @override
  State<SopGeneratorScreen> createState() => _SopGeneratorScreenState();
}

class _SopGeneratorScreenState extends State<SopGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isGenerating = false;

  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final purposeController = TextEditingController();
  final processController = TextEditingController();
  final responsibilityController = TextEditingController();
  final approvalsController = TextEditingController();
  final documentsController = TextEditingController();
  final controlsController = TextEditingController();
  final additionalController = TextEditingController();

  String selectedDepartment = 'Finance & Accounts';
  String selectedFrequency = 'As Required';

  final departments = [
    'Finance & Accounts',
    'GST & Taxation',
    'Human Resources',
    'Purchase',
    'Sales',
    'Inventory',
    'Operations',
    'Manufacturing',
    'IT & Security',
    'Administration',
    'Compliance',
    'Custom',
  ];

  final frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Annually',
    'As Required',
  ];

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    purposeController.dispose();
    processController.dispose();
    responsibilityController.dispose();
    approvalsController.dispose();
    documentsController.dispose();
    controlsController.dispose();
    additionalController.dispose();
    super.dispose();
  }

  Future<void> _generateSop() async {
    debugPrint('========== SOP BUTTON CLICKED ==========');

    final isValid = _formKey.currentState?.validate() ?? false;

    debugPrint('FORM VALID: $isValid');

    if (!isValid) {
      debugPrint('STOPPED: Required fields are missing');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          content: Text('Please complete all required fields.'),
        ),
      );

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isGenerating = true;
    });

    try {
      final sopData = <String, dynamic>{
        'title': titleController.text.trim(),
        'company': companyController.text.trim(),
        'department': selectedDepartment,
        'purpose': purposeController.text.trim(),
        'processDescription': processController.text.trim(),
        'responsiblePersons': responsibilityController.text.trim(),
        'approvalFlow': approvalsController.text.trim(),
        'frequency': selectedFrequency,
        'documents': documentsController.text.trim(),
        'controls': controlsController.text.trim(),
        'additionalInstructions': additionalController.text.trim(),
      };

      debugPrint('SOP DATA CREATED');
      debugPrint(sopData.toString());

      final functions = FirebaseFunctions.instanceFor(region: 'asia-south1');

      debugPrint('FIREBASE FUNCTIONS INSTANCE CREATED');

      final callable = functions.httpsCallable(
        'generateSop',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );

      debugPrint('CALLING generateSop...');

      final result = await callable.call(sopData);

      debugPrint('FUNCTION RESPONSE RECEIVED');

      debugPrint('RAW RESPONSE: ${result.data}');

      if (result.data == null) {
        throw Exception('Firebase Function returned no data.');
      }

      final response = Map<String, dynamic>.from(result.data as Map);

      debugPrint('SUCCESS VALUE: ${response['success']}');

      if (response['success'] != true) {
        throw Exception('SOP generation failed.');
      }

      if (response['sop'] == null) {
        throw Exception('SOP was not returned by the server.');
      }

      final sop = Map<String, dynamic>.from(response['sop'] as Map);

      debugPrint('SOP PARSED SUCCESSFULLY');
      debugPrint(sop.toString());

      if (!mounted) return;

      debugPrint('OPENING SopPreviewScreen...');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SopPreviewScreen(sop: sop, inputData: sopData),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('========== FIREBASE FUNCTION ERROR ==========');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('DETAILS: ${e.details}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
          content: Text(
            'Firebase error: '
            '${e.code}\n'
            '${e.message ?? "Unknown error"}',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('========== GENERAL ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
          content: Text('Unable to generate SOP:\n$e'),
        ),
      );
    } finally {
      debugPrint('========== SOP GENERATION FINISHED ==========');

      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  children: [
                    _buildHero(),

                    const SizedBox(height: 18),

                    _buildQuickInfo(),

                    const SizedBox(height: 18),

                    _buildSection(
                      icon: Icons.description_outlined,
                      title: 'SOP Information',
                      subtitle:
                          'Start with the basic details of the procedure.',
                      children: [
                        _field(
                          controller: titleController,
                          label: 'SOP Title',
                          hint: 'Example: Vendor Payment Process',
                          icon: Icons.title_rounded,
                          required: true,
                        ),

                        _field(
                          controller: companyController,
                          label: 'Organisation / Business',
                          hint: 'Enter organisation name',
                          icon: Icons.business_outlined,
                          required: true,
                        ),

                        _dropdown(
                          label: 'Department',
                          icon: Icons.account_tree_outlined,
                          value: selectedDepartment,
                          values: departments,
                          onChanged: (value) {
                            setState(() {
                              selectedDepartment = value!;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.flag_outlined,
                      title: 'Purpose & Process',
                      subtitle:
                          'Explain what the SOP should achieve and how the process works.',
                      children: [
                        _field(
                          controller: purposeController,
                          label: 'Purpose',
                          hint: 'What should this SOP achieve?',
                          icon: Icons.flag_outlined,
                          required: true,
                          maxLines: 3,
                        ),

                        _field(
                          controller: processController,
                          label: 'Process Description',
                          hint: 'Explain the process from beginning to end...',
                          icon: Icons.account_tree_rounded,
                          required: true,
                          maxLines: 5,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.groups_2_outlined,
                      title: 'Responsibility & Approval',
                      subtitle:
                          'Tell AI who performs and approves the process.',
                      children: [
                        _field(
                          controller: responsibilityController,
                          label: 'Responsible Persons',
                          hint: 'Example: Accountant, Finance Manager',
                          icon: Icons.people_outline,
                          required: true,
                          maxLines: 2,
                        ),

                        _field(
                          controller: approvalsController,
                          label: 'Approval Flow',
                          hint: 'Example: Accountant → Manager → Director',
                          icon: Icons.approval_outlined,
                          maxLines: 2,
                        ),

                        _dropdown(
                          label: 'Process Frequency',
                          icon: Icons.schedule_outlined,
                          value: selectedFrequency,
                          values: frequencies,
                          onChanged: (value) {
                            setState(() {
                              selectedFrequency = value!;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.security_outlined,
                      title: 'Documents & Controls',
                      subtitle:
                          'Add records, checks and internal controls used in the process.',
                      children: [
                        _field(
                          controller: documentsController,
                          label: 'Documents / Records',
                          hint: 'Example: PO, Invoice, GRN, Payment Voucher',
                          icon: Icons.folder_copy_outlined,
                          maxLines: 3,
                        ),

                        _field(
                          controller: controlsController,
                          label: 'Controls / Checks',
                          hint:
                              'Example: 3-way matching, duplicate invoice check...',
                          icon: Icons.verified_user_outlined,
                          maxLines: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.tune_rounded,
                      title: 'Additional Instructions',
                      subtitle:
                          'Optional instructions for AI while preparing the SOP.',
                      children: [
                        _field(
                          controller: additionalController,
                          label: 'Additional Requirements',
                          hint:
                              'Example: Include escalation matrix and maker-checker control...',
                          icon: Icons.edit_note_rounded,
                          maxLines: 4,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    _aiNotice(),
                  ],
                ),
              ),
            ),

            _buildGenerateBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(.20),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              height: 170,
              width: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),

          Positioned(
            right: 30,
            bottom: -80,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(.08),
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
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.11),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.11),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFFE9D5FF),
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI POWERED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 27),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_motion_rounded,
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
                          'AI SOP Generator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            letterSpacing: -.6,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Turn your process into a professional SOP.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
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
                    child: _heroFeature(
                      Icons.bolt_rounded,
                      'Fast',
                      'Generation',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroFeature(
                      Icons.edit_document,
                      'Smart',
                      'Structure',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroFeature(Icons.save_outlined, 'Save', 'Anytime'),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: Colors.white),
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
            style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK INFO
  // ============================================================

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFF7C3AED),
            size: 22,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Better input = better SOP',
                  style: TextStyle(
                    color: Color(0xFF6D28D9),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Describe the actual workflow, responsibilities and controls. AI will organise them into a professional procedure.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
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
  // SECTION
  // ============================================================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7E9EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
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
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
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
          fillColor: const Color(0xFFFAFAFC),
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

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        onChanged: onChanged,
        items: values
            .map(
              (item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)),
            )
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          filled: true,
          fillColor: const Color(0xFFFAFAFC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AI NOTICE
  // ============================================================

  Widget _aiNotice() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),

          SizedBox(width: 12),

          Expanded(
            child: Text(
              'AI will use the information above to prepare the purpose, scope, responsibilities, detailed procedure, controls, records, exceptions, escalation process and approval structure.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENERATE BUTTON
  // ============================================================

  Widget _buildGenerateBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 16),
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
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isGenerating ? null : _generateSop,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: isGenerating
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Creating your SOP...',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 20),
                    SizedBox(width: 9),
                    Text(
                      'Generate SOP with AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 19),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // GENERATE
  // ============================================================
}
