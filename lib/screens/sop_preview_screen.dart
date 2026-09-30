import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sop_editor_screen.dart';

class SopPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> sop;
  final Map<String, dynamic> inputData;

  // Null when SOP has just been generated.
  // Available when opening an already-saved SOP.
  final String? documentId;

  const SopPreviewScreen({
    super.key,
    required this.sop,
    required this.inputData,
    this.documentId,
  });

  @override
  State<SopPreviewScreen> createState() => _SopPreviewScreenState();
}

class _SopPreviewScreenState extends State<SopPreviewScreen> {
  bool isSaving = false;

  late Map<String, dynamic> sopData;

  String? savedDocumentId;

  @override
  void initState() {
    super.initState();

    sopData = Map<String, dynamic>.from(widget.sop);

    savedDocumentId = widget.documentId;
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        sopData['sopTitle']?.toString().trim().isNotEmpty == true
        ? sopData['sopTitle'].toString()
        : widget.inputData['title']?.toString() ??
              'Standard Operating Procedure';

    final String organisation =
        sopData['organisation']?.toString().trim().isNotEmpty == true
        ? sopData['organisation'].toString()
        : widget.inputData['company']?.toString() ?? '-';

    final String department =
        sopData['department']?.toString().trim().isNotEmpty == true
        ? sopData['department'].toString()
        : widget.inputData['department']?.toString() ?? '-';

    final String version = sopData['version']?.toString() ?? '1.0';

    final String sopNumber =
        sopData['sopNumber']?.toString().trim().isNotEmpty == true
        ? sopData['sopNumber'].toString()
        : 'Draft';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHero(
                      title: title,
                      organisation: organisation,
                      department: department,
                      version: version,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildMetaCard(
                      sopNumber: sopNumber,
                      version: version,
                      department: department,
                      frequency:
                          sopData['frequency']?.toString() ??
                          widget.inputData['frequency']?.toString() ??
                          '-',
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _textSection(
                          number: '01',
                          title: 'Purpose',
                          icon: Icons.flag_outlined,
                          content: sopData['purpose']?.toString() ?? '-',
                        ),

                        _gap(),

                        _textSection(
                          number: '02',
                          title: 'Scope',
                          icon: Icons.zoom_out_map_rounded,
                          content: sopData['scope']?.toString() ?? '-',
                        ),

                        if (_list('definitions').isNotEmpty) ...[
                          _gap(),
                          _simpleListSection(
                            number: '03',
                            title: 'Definitions',
                            icon: Icons.menu_book_outlined,
                            items: _list('definitions'),
                          ),
                        ],

                        if (_list('responsibilities').isNotEmpty) ...[
                          _gap(),
                          _responsibilitiesSection(),
                        ],

                        if (_list('procedure').isNotEmpty) ...[
                          _gap(),
                          _procedureSection(),
                        ],

                        if (_list('internalControls').isNotEmpty) ...[
                          _gap(),
                          _simpleListSection(
                            number: '06',
                            title: 'Internal Controls',
                            icon: Icons.verified_user_outlined,
                            items: _list('internalControls'),
                          ),
                        ],

                        if (_list('documentsAndRecords').isNotEmpty) ...[
                          _gap(),
                          _simpleListSection(
                            number: '07',
                            title: 'Documents & Records',
                            icon: Icons.folder_copy_outlined,
                            items: _list('documentsAndRecords'),
                          ),
                        ],

                        if (_list('exceptions').isNotEmpty) ...[
                          _gap(),
                          _simpleListSection(
                            number: '08',
                            title: 'Exceptions',
                            icon: Icons.warning_amber_rounded,
                            items: _list('exceptions'),
                          ),
                        ],

                        if (_list('escalationMatrix').isNotEmpty) ...[
                          _gap(),
                          _escalationSection(),
                        ],

                        _gap(),

                        _approvalSection(),

                        const SizedBox(height: 20),

                        _aiDisclaimer(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            _bottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero({
    required String title,
    required String organisation,
    required String department,
    required String version,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 18),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4C1D95), Color(0xFF7C3AED)],
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
                color: Colors.white.withOpacity(.05),
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
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Color(0xFFE9D5FF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'AI GENERATED',
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

              const SizedBox(height: 27),

              const Text(
                'STANDARD OPERATING PROCEDURE',
                style: TextStyle(
                  color: Color(0xFFD8B4FE),
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _heroInfo(
                      Icons.business_outlined,
                      'Organisation',
                      organisation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _heroInfo(
                      Icons.account_tree_outlined,
                      'Department',
                      department,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _heroInfo(Icons.history_rounded, 'Version', version),
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
          color: Colors.white.withOpacity(.11),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _heroInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.50),
                    fontSize: 8.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
    );
  }

  // ============================================================
  // META CARD
  // ============================================================

  Widget _buildMetaCard({
    required String sopNumber,
    required String version,
    required String department,
    required String frequency,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Row(
        children: [
          Expanded(child: _metaItem('SOP No.', sopNumber)),
          _divider(),
          Expanded(child: _metaItem('Version', version)),
          _divider(),
          Expanded(child: _metaItem('Frequency', frequency)),
        ],
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 9.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 34, width: 1, color: const Color(0xFFE5E7EB));
  }

  // ============================================================
  // GENERIC TEXT SECTION
  // ============================================================

  Widget _textSection({
    required String number,
    required String title,
    required IconData icon,
    required String content,
  }) {
    return _sectionShell(
      number: number,
      title: title,
      icon: icon,
      child: Text(
        content.isEmpty ? '-' : content,
        style: const TextStyle(
          color: Color(0xFF4B5563),
          fontSize: 13,
          height: 1.65,
        ),
      ),
    );
  }

  // ============================================================
  // SIMPLE LIST
  // ============================================================

  Widget _simpleListSection({
    required String number,
    required String title,
    required IconData icon,
    required List<dynamic> items,
  }) {
    return _sectionShell(
      number: number,
      title: title,
      icon: icon,
      child: Column(
        children: List.generate(items.length, (index) {
          return _bullet(index + 1, items[index].toString());
        }),
      ),
    );
  }

  Widget _bullet(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 26,
            width: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESPONSIBILITIES
  // ============================================================

  Widget _responsibilitiesSection() {
    final items = _list('responsibilities');

    return _sectionShell(
      number: '04',
      title: 'Roles & Responsibilities',
      icon: Icons.groups_2_outlined,
      child: Column(
        children: items.map((item) {
          final data = Map<String, dynamic>.from(item as Map);

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDEEF2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['role']?.toString() ?? 'Role',
                  style: const TextStyle(
                    color: Color(0xFF6D28D9),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data['responsibility']?.toString() ?? '-',
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // PROCEDURE
  // ============================================================

  Widget _procedureSection() {
    final procedure = _list('procedure');

    return _sectionShell(
      number: '05',
      title: 'Detailed Procedure',
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        children: List.generate(procedure.length, (index) {
          final item = Map<String, dynamic>.from(procedure[index] as Map);

          return _procedureStep(
            step: item['stepNumber']?.toString() ?? '${index + 1}',
            title: item['title']?.toString() ?? 'Step ${index + 1}',
            description: item['description']?.toString() ?? '-',
            role: item['responsibleRole']?.toString() ?? '',
            control: item['control']?.toString() ?? '',
            last: index == procedure.length - 1,
          );
        }),
      ),
    );
  }

  Widget _procedureStep({
    required String step,
    required String title,
    required String description,
    required String role,
    required String control,
    required bool last,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C3AED),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFE9D5FF)),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFC),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFEDEEF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),

                    if (role.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _miniTag(
                        Icons.person_outline_rounded,
                        'Responsible: $role',
                      ),
                    ],

                    if (control.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      _miniTag(
                        Icons.verified_user_outlined,
                        'Control: $control',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6D28D9),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESCALATION
  // ============================================================

  Widget _escalationSection() {
    final data = _list('escalationMatrix');

    return _sectionShell(
      number: '09',
      title: 'Escalation Matrix',
      icon: Icons.alt_route_rounded,
      child: Column(
        children: data.map((item) {
          final row = Map<String, dynamic>.from(item as Map);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDEEF2)),
            ),
            child: Column(
              children: [
                _detailRow('Issue', row['issue']?.toString() ?? '-'),
                _detailRow('Escalate To', row['escalateTo']?.toString() ?? '-'),
                _detailRow('Timeline', row['timeline']?.toString() ?? '-'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPROVAL
  // ============================================================

  Widget _approvalSection() {
    return _sectionShell(
      number: '10',
      title: 'Review & Approval',
      icon: Icons.approval_outlined,
      child: Column(
        children: [
          _approvalTile(
            'Prepared By',
            sopData['preparedBy']?.toString() ?? 'Not specified',
          ),
          _approvalTile(
            'Reviewed By',
            sopData['reviewedBy']?.toString() ?? 'Not specified',
          ),
          _approvalTile(
            'Approved By',
            sopData['approvedBy']?.toString() ?? 'Not specified',
          ),
          _approvalTile(
            'Review Frequency',
            sopData['reviewFrequency']?.toString() ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _approvalTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION SHELL
  // ============================================================

  Widget _sectionShell({
    required String number,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFFE7E9EF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF7C3AED), size: 21),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECTION $number',
                      style: const TextStyle(
                        color: Color(0xFF7C3AED),
                        fontSize: 8.5,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          child,
        ],
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 14);
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _aiDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-generated SOPs should be reviewed by the appropriate process owner before formal implementation.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BAR
  // ============================================================

  Widget _bottomActionBar() {
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
          SizedBox(
            height: 54,
            width: 54,
            child: OutlinedButton(
              onPressed: _editSop,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color(0xFF7C3AED),
                side: const BorderSide(color: Color(0xFFD8B4FE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.edit_outlined),
            ),
          ),

          const SizedBox(width: 9),

          SizedBox(
            height: 54,
            width: 54,
            child: OutlinedButton(
              onPressed: _regenerateSop,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: const Color(0xFF7C3AED),
                side: const BorderSide(color: Color(0xFFD8B4FE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.refresh_rounded),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveSop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 19),
                          SizedBox(width: 8),
                          Text(
                            'Save SOP',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<String?> _saveSop({bool showMessage = true}) async {
    if (isSaving) return savedDocumentId;

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Please sign in to save this SOP.');
      }

      final collection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sops');

      // ----------------------------------------------------------
      // NEW SOP
      // ----------------------------------------------------------

      final DocumentReference<Map<String, dynamic>> ref;

      if (savedDocumentId == null) {
        ref = collection.doc();
        savedDocumentId = ref.id;
      } else {
        // --------------------------------------------------------
        // EXISTING SOP
        // --------------------------------------------------------

        ref = collection.doc(savedDocumentId);
      }

      final data = <String, dynamic>{
        'sopId': ref.id,

        'title':
            sopData['sopTitle'] ??
            widget.inputData['title'] ??
            'Standard Operating Procedure',

        'organisation':
            sopData['organisation'] ?? widget.inputData['company'] ?? '',

        'department':
            sopData['department'] ?? widget.inputData['department'] ?? '',

        'version': sopData['version'] ?? '1.0',

        'status': 'draft',

        'inputData': Map<String, dynamic>.from(widget.inputData),

        'generatedSop': Map<String, dynamic>.from(sopData),

        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only set createdAt when first creating the SOP.
      if (widget.documentId == null && savedDocumentId == ref.id) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      await ref.set(data, SetOptions(merge: true));

      if (!mounted) {
        return ref.id;
      }

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF059669),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 9),
                Text(
                  'SOP saved successfully',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        );
      }

      return ref.id;
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Unable to save SOP: $e'),
        ),
      );

      return null;
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // EDIT / REGENERATE
  // ============================================================

  Future<void> _editSop() async {
    //
    // If this SOP came directly from AI generation,
    // it does not have a Firestore document yet.
    // Save it automatically before opening editor.
    //
    if (savedDocumentId == null) {
      final id = await _saveSop(showMessage: false);

      if (id == null) {
        return;
      }

      savedDocumentId = id;
    }

    if (!mounted) return;

    final editorData = <String, dynamic>{
      'sopId': savedDocumentId,

      'title': sopData['sopTitle'] ?? widget.inputData['title'],

      'organisation': sopData['organisation'] ?? widget.inputData['company'],

      'department': sopData['department'] ?? widget.inputData['department'],

      'version': sopData['version'] ?? '1.0',

      'status': 'draft',

      'inputData': Map<String, dynamic>.from(widget.inputData),

      'generatedSop': Map<String, dynamic>.from(sopData),
    };

    final updatedData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SopEditorScreen(
          documentId: savedDocumentId!,
          documentData: editorData,
        ),
      ),
    );

    //
    // If editor returns updated SOP,
    // immediately refresh Preview.
    //
    if (updatedData != null && mounted) {
      setState(() {
        sopData = Map<String, dynamic>.from(updatedData);
      });
    }
  }

  void _regenerateSop() {
    Navigator.pop(context);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<dynamic> _list(String key) {
    final value = sopData[key];

    if (value is List) {
      return value;
    }

    return [];
  }
}
