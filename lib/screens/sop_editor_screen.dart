import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SopEditorScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> documentData;

  const SopEditorScreen({
    super.key,
    required this.documentId,
    required this.documentData,
  });

  @override
  State<SopEditorScreen> createState() => _SopEditorScreenState();
}

class _SopEditorScreenState extends State<SopEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSaving = false;
  bool hasChanges = false;

  late Map<String, dynamic> sopData;
  late Map<String, dynamic> inputData;

  late final TextEditingController titleController;
  late final TextEditingController companyController;
  late final TextEditingController departmentController;

  late final TextEditingController purposeController;
  late final TextEditingController scopeController;
  late final TextEditingController responsibilitiesController;
  late final TextEditingController procedureController;

  late final TextEditingController controlsController;
  late final TextEditingController recordsController;

  late final TextEditingController exceptionsController;
  late final TextEditingController escalationController;
  late final TextEditingController approvalController;

  late final TextEditingController notesController;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    final rawSop = widget.documentData['sop'];
    final rawInput = widget.documentData['inputData'];

    sopData = rawSop is Map
        ? Map<String, dynamic>.from(rawSop)
        : Map<String, dynamic>.from(widget.documentData);

    inputData = rawInput is Map
        ? Map<String, dynamic>.from(rawInput)
        : Map<String, dynamic>.from(widget.documentData);

    titleController = TextEditingController(
      text: _findValue(['title', 'sopTitle', 'name']),
    );

    companyController = TextEditingController(
      text: _findValue(['company', 'organisation', 'organization', 'business']),
    );

    departmentController = TextEditingController(
      text: _findValue(['department']),
    );

    purposeController = TextEditingController(
      text: _findValue(['purpose', 'objective']),
    );

    scopeController = TextEditingController(
      text: _findValue(['scope', 'applicability']),
    );

    responsibilitiesController = TextEditingController(
      text: _findValue([
        'responsibilities',
        'responsiblePersons',
        'responsibility',
      ]),
    );

    procedureController = TextEditingController(
      text: _findValue([
        'procedure',
        'detailedProcedure',
        'process',
        'processDescription',
        'steps',
      ]),
    );

    controlsController = TextEditingController(
      text: _findValue(['controls', 'internalControls', 'checks']),
    );

    recordsController = TextEditingController(
      text: _findValue(['records', 'documents', 'documentsRecords']),
    );

    exceptionsController = TextEditingController(
      text: _findValue(['exceptions', 'exceptionHandling']),
    );

    escalationController = TextEditingController(
      text: _findValue(['escalation', 'escalationProcess', 'escalationMatrix']),
    );

    approvalController = TextEditingController(
      text: _findValue(['approval', 'approvalFlow', 'approvalStructure']),
    );

    notesController = TextEditingController(
      text: _findValue(['notes', 'additionalInstructions']),
    );
  }

  // ============================================================
  // READ EXISTING VALUES
  // ============================================================

  String _findValue(List<String> keys) {
    for (final key in keys) {
      if (sopData[key] != null) {
        return _convertToText(sopData[key]);
      }
    }

    for (final key in keys) {
      if (inputData[key] != null) {
        return _convertToText(inputData[key]);
      }
    }

    for (final key in keys) {
      if (widget.documentData[key] != null) {
        return _convertToText(widget.documentData[key]);
      }
    }

    return '';
  }

  String _convertToText(dynamic value) {
    if (value == null) return '';

    if (value is String) {
      return value;
    }

    if (value is List) {
      return value.map((e) => e.toString()).join('\n');
    }

    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n');
    }

    return value.toString();
  }

  // ============================================================
  // SAVE IN ORIGINAL KEY
  // ============================================================

  void _setValue({
    required Map<String, dynamic> map,
    required List<String> existingKeys,
    required String defaultKey,
    required String value,
  }) {
    for (final key in existingKeys) {
      if (map.containsKey(key)) {
        map[key] = value;
        return;
      }
    }

    map[defaultKey] = value;
  }

  void _markChanged(String _) {
    if (!hasChanges) {
      setState(() {
        hasChanges = true;
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveSop() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });

    try {
      final updatedSop = Map<String, dynamic>.from(sopData);

      final updatedInput = Map<String, dynamic>.from(inputData);

      _setValue(
        map: updatedSop,
        existingKeys: ['title', 'sopTitle', 'name'],
        defaultKey: 'title',
        value: titleController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['purpose', 'objective'],
        defaultKey: 'purpose',
        value: purposeController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['scope', 'applicability'],
        defaultKey: 'scope',
        value: scopeController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: [
          'responsibilities',
          'responsiblePersons',
          'responsibility',
        ],
        defaultKey: 'responsibilities',
        value: responsibilitiesController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: [
          'procedure',
          'detailedProcedure',
          'process',
          'processDescription',
          'steps',
        ],
        defaultKey: 'procedure',
        value: procedureController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['controls', 'internalControls', 'checks'],
        defaultKey: 'controls',
        value: controlsController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['records', 'documents', 'documentsRecords'],
        defaultKey: 'records',
        value: recordsController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['exceptions', 'exceptionHandling'],
        defaultKey: 'exceptions',
        value: exceptionsController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['escalation', 'escalationProcess', 'escalationMatrix'],
        defaultKey: 'escalation',
        value: escalationController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['approval', 'approvalFlow', 'approvalStructure'],
        defaultKey: 'approvalFlow',
        value: approvalController.text.trim(),
      );

      _setValue(
        map: updatedSop,
        existingKeys: ['notes', 'additionalInstructions'],
        defaultKey: 'notes',
        value: notesController.text.trim(),
      );

      updatedInput['title'] = titleController.text.trim();

      updatedInput['company'] = companyController.text.trim();

      updatedInput['department'] = departmentController.text.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sops')
          .doc(widget.documentId)
          .set({
            'title': titleController.text.trim(),

            'company': companyController.text.trim(),

            'department': departmentController.text.trim(),

            'sop': updatedSop,

            'inputData': updatedInput,

            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      sopData = updatedSop;
      inputData = updatedInput;

      setState(() {
        hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF059669),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'SOP updated successfully',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Unable to save SOP: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Unable to save SOP: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    departmentController.dispose();

    purposeController.dispose();
    scopeController.dispose();

    responsibilitiesController.dispose();
    procedureController.dispose();

    controlsController.dispose();
    recordsController.dispose();

    exceptionsController.dispose();
    escalationController.dispose();
    approvalController.dispose();

    notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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

                    if (hasChanges) _buildUnsavedNotice(),

                    if (hasChanges) const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.description_outlined,
                      title: 'SOP Details',
                      subtitle: 'Basic information about this procedure.',
                      children: [
                        _field(
                          controller: titleController,
                          label: 'SOP Title',
                          icon: Icons.title_rounded,
                          required: true,
                        ),

                        _field(
                          controller: companyController,
                          label: 'Organisation / Business',
                          icon: Icons.business_outlined,
                        ),

                        _field(
                          controller: departmentController,
                          label: 'Department',
                          icon: Icons.account_tree_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.flag_outlined,
                      title: 'Purpose & Scope',
                      subtitle:
                          'Define why the procedure exists and where it applies.',
                      children: [
                        _field(
                          controller: purposeController,
                          label: 'Purpose',
                          icon: Icons.flag_outlined,
                          required: true,
                          maxLines: 5,
                        ),

                        _field(
                          controller: scopeController,
                          label: 'Scope',
                          icon: Icons.filter_center_focus_outlined,
                          maxLines: 5,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.groups_2_outlined,
                      title: 'Roles & Responsibilities',
                      subtitle:
                          'Specify who performs, reviews and owns the process.',
                      children: [
                        _field(
                          controller: responsibilitiesController,
                          label: 'Responsibilities',
                          icon: Icons.people_alt_outlined,
                          maxLines: 7,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildProcedureSection(),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.verified_user_outlined,
                      title: 'Controls & Records',
                      subtitle:
                          'Maintain internal controls and supporting documentation.',
                      children: [
                        _field(
                          controller: controlsController,
                          label: 'Internal Controls / Checks',
                          icon: Icons.verified_outlined,
                          maxLines: 7,
                        ),

                        _field(
                          controller: recordsController,
                          label: 'Documents / Records',
                          icon: Icons.folder_copy_outlined,
                          maxLines: 6,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.warning_amber_rounded,
                      title: 'Exceptions & Escalation',
                      subtitle:
                          'Define what should happen when the normal process cannot be followed.',
                      children: [
                        _field(
                          controller: exceptionsController,
                          label: 'Exception Handling',
                          icon: Icons.report_problem_outlined,
                          maxLines: 6,
                        ),

                        _field(
                          controller: escalationController,
                          label: 'Escalation Process',
                          icon: Icons.trending_up_rounded,
                          maxLines: 6,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    _buildSection(
                      icon: Icons.approval_outlined,
                      title: 'Approval & Final Notes',
                      subtitle:
                          'Document the approval structure and additional information.',
                      children: [
                        _field(
                          controller: approvalController,
                          label: 'Approval Structure',
                          icon: Icons.how_to_reg_outlined,
                          maxLines: 5,
                        ),

                        _field(
                          controller: notesController,
                          label: 'Additional Notes',
                          icon: Icons.edit_note_outlined,
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            _buildSaveBar(),
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
            right: -60,
            top: -70,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
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
                        color: Colors.white.withOpacity(.11),
                        shape: BoxShape.circle,
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
                          Icons.edit_note_rounded,
                          color: Color(0xFFE9D5FF),
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'EDIT MODE',
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
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.edit_document,
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
                          'SOP Editor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Review and refine your procedure.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: Color(0xFFE9D5FF),
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Edit any section below. Your original SOP is updated only when you press Save Changes.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UNSAVED
  // ============================================================

  Widget _buildUnsavedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_rounded, color: Color(0xFFD97706), size: 19),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have unsaved changes',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10.5,
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
  // PROCEDURE SPECIAL SECTION
  // ============================================================

  Widget _buildProcedureSection() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFAF8FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.format_list_numbered_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Procedure',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Edit the actual step-by-step workflow.',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _field(
            controller: procedureController,
            label: 'Procedure / Process Steps',
            icon: Icons.list_alt_rounded,
            maxLines: 14,
            required: true,
          ),
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
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 3 : 1,
        onChanged: _markChanged,
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

          alignLabelWithHint: maxLines > 1,

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

  // ============================================================
  // SAVE BAR
  // ============================================================

  Widget _buildSaveBar() {
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
      child: Row(
        children: [
          if (hasChanges)
            Expanded(
              child: Text(
                'Unsaved changes',
                style: TextStyle(
                  color: const Color(0xFFD97706),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'All changes saved',
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            height: 53,
            child: ElevatedButton(
              onPressed: isSaving || !hasChanges ? null : _saveSop,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                disabledForegroundColor: const Color(0xFF9CA3AF),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isSaving
                  ? const Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Saving...',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Icon(Icons.save_outlined, size: 19),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
