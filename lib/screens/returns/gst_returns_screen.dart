import 'package:flutter/material.dart';

class GstReturnsScreen extends StatefulWidget {
  final Map<String, dynamic> gstProfile;

  const GstReturnsScreen({
    super.key,
    required this.gstProfile,
  });

  @override
  State<GstReturnsScreen> createState() =>
      _GstReturnsScreenState();
}

class _GstReturnsScreenState
    extends State<GstReturnsScreen> {
  String selectedFinancialYear = '2026-27';
  String selectedFrequency = 'Monthly';

  final List<String> financialYears = [
    '2026-27',
    '2025-26',
    '2024-25',
  ];

  final List<String> frequencies = [
    'Monthly',
    'Quarterly',
    'Annual',
  ];

  final List<GstReturnData> returnItems = [
    GstReturnData(
      returnType: 'GSTR-1',
      title: 'Outward Supplies',
      subtitle:
          'Sales invoices, debit notes, credit notes and exports',
      period: 'August 2026',
      dueDate: '11 Sep 2026',
      status: GstReturnStatus.pending,
      color: Colors.blue,
      icon: Icons.upload_file_rounded,
      completion: 0.72,
    ),
    GstReturnData(
      returnType: 'GSTR-3B',
      title: 'Summary Return',
      subtitle:
          'Tax liability, eligible ITC and payment summary',
      period: 'August 2026',
      dueDate: '20 Sep 2026',
      status: GstReturnStatus.inProgress,
      color: Colors.orange,
      icon: Icons.description_outlined,
      completion: 0.48,
    ),
    GstReturnData(
      returnType: 'GSTR-1',
      title: 'Outward Supplies',
      subtitle:
          'Sales invoices, debit notes, credit notes and exports',
      period: 'July 2026',
      dueDate: '11 Aug 2026',
      status: GstReturnStatus.filed,
      color: Colors.blue,
      icon: Icons.upload_file_rounded,
      completion: 1,
    ),
    GstReturnData(
      returnType: 'GSTR-3B',
      title: 'Summary Return',
      subtitle:
          'Tax liability, ITC and tax payment',
      period: 'July 2026',
      dueDate: '20 Aug 2026',
      status: GstReturnStatus.filed,
      color: Colors.orange,
      icon: Icons.description_outlined,
      completion: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final String tradeName =
        widget.gstProfile['tradeName']?.toString().trim() ?? '';

    final String legalName =
        widget.gstProfile['legalName']?.toString().trim() ?? '';

    final String businessName =
        tradeName.isNotEmpty
            ? tradeName
            : legalName.isNotEmpty
                ? legalName
                : 'Business';

    final String gstin =
        widget.gstProfile['gstin']?.toString() ?? '';

        Widget _headerButton({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(.10),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
      ),
    ),
  );
}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: CustomScrollView(
        slivers: [
         SliverAppBar(
  pinned: true,
  automaticallyImplyLeading: false,
  toolbarHeight: 92,
  backgroundColor: const Color(0xFF14532D),
  elevation: 0,
  scrolledUnderElevation: 0,

  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF14532D),
          Color(0xFF15803D),
          Color(0xFF16A34A),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // BACK BUTTON
            // ==========================================

            _headerButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(width: 12),

            // ==========================================
            // GST ICON
            // ==========================================

            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(.12),
                ),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),

            const SizedBox(width: 13),

            // ==========================================
            // BUSINESS DETAILS
            // ==========================================

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Container(
                        height: 7,
                        width: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF86EFAC),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Flexible(
                        child: Text(
                          gstin.isNotEmpty
                              ? gstin
                              : 'GST Profile',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: .45,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            

            // ==========================================
            // NOTIFICATION
            // ==========================================

            Stack(
              clipBehavior: Clip.none,
              children: [
                _headerButton(
                  icon:
                      Icons.notifications_none_rounded,
                  onTap: () {
                    // Open GST notifications
                  },
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF15803D),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
),

SliverToBoxAdapter(
  child: Container(
    color: const Color(0xFFF5F7FB),
    padding: const EdgeInsets.fromLTRB(
      18,
      22,
      18,
      4,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'GST Returns',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage and track your GST filings',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                color: Color(0xFF15803D),
                size: 15,
              ),
              SizedBox(width: 5),
              Text(
                'Active',
                style: TextStyle(
                  color: Color(0xFF15803D),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              35,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _summarySection(),

                  const SizedBox(height: 22),

                  _filterCard(),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return Workspace',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Prepare, review and track GST returns',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.history_rounded,
                          size: 18,
                        ),
                        label:
                            const Text('History'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ...returnItems.map(
                    (item) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _returnCard(
                        context,
                        item,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _filingHealthCard(),

                  const SizedBox(height: 20),

                  _complianceInsightCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUMMARY
  // =========================================================

  Widget _summarySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Filed',
                value: '14',
                subtitle: 'This FY',
                icon: Icons.task_alt_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'Pending',
                value: '2',
                subtitle: 'Current',
                icon: Icons.schedule_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'Overdue',
                value: '0',
                subtitle: 'Great',
                icon:
                    Icons.warning_amber_rounded,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'Compliance',
                value: '92%',
                subtitle: 'Excellent',
                icon:
                    Icons.verified_rounded,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.045),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTER CARD
  // =========================================================

  Widget _filterCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.035),
            blurRadius: 13,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color:
                    Color(0xFF166534),
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Filing Period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  value:
                      selectedFinancialYear,
                  decoration:
                      _dropdownDecoration(
                    'Financial Year',
                    Icons
                        .calendar_today_outlined,
                  ),
                  items:
                      financialYears
                          .map(
                            (year) =>
                                DropdownMenuItem(
                              value: year,
                              child: Text(
                                year,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedFinancialYear =
                          value;
                    });
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  value:
                      selectedFrequency,
                  decoration:
                      _dropdownDecoration(
                    'Frequency',
                    Icons
                        .repeat_rounded,
                  ),
                  items:
                      frequencies
                          .map(
                            (frequency) =>
                                DropdownMenuItem(
                              value:
                                  frequency,
                              child: Text(
                                frequency,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedFrequency =
                          value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color:
            const Color(0xFF166534),
        size: 19,
      ),
      filled: true,
      fillColor:
          const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),
    );
  }

  // =========================================================
  // RETURN CARD
  // =========================================================

  Widget _returnCard(
    BuildContext context,
    GstReturnData item,
  ) {
    final status =
        _statusInfo(item.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.04),
            blurRadius: 14,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color:
                      item.color.withOpacity(
                    .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.returnType,
                            style:
                                const TextStyle(
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: status.color
                                .withOpacity(.10),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              color:
                                  status.color,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _metaItem(
                    'Period',
                    item.period,
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  color:
                      Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metaItem(
                    'Due Date',
                    item.dueDate,
                  ),
                ),
              ],
            ),
          ),

          if (item.status !=
              GstReturnStatus.filed) ...[
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preparation Progress',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(item.completion * 100).round()}%',
                  style: TextStyle(
                    color: item.color,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child:
                  LinearProgressIndicator(
                minHeight: 7,
                value: item.completion,
                backgroundColor:
                    Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation(
                  item.color,
                ),
              ),
            ),
          ],

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton(
                  onPressed: () {
                    _showReturnDetails(
                      context,
                      item,
                    );
                  },
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF166534,
                    ),
                    side: BorderSide(
                      color:
                          Colors.green.shade200,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child:
                    ElevatedButton(
                  onPressed: () {
                    _handleReturnAction(
                      context,
                      item,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        item.status ==
                                GstReturnStatus
                                    .filed
                            ? const Color(
                                0xFFF0FDF4,
                              )
                            : const Color(
                                0xFF166534,
                              ),
                    foregroundColor:
                        item.status ==
                                GstReturnStatus
                                    .filed
                            ? const Color(
                                0xFF166534,
                              )
                            : Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                  child: Text(
                    item.status ==
                            GstReturnStatus
                                .filed
                        ? 'Download'
                        : item.status ==
                                GstReturnStatus
                                    .inProgress
                            ? 'Continue'
                            : 'Prepare',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaItem(
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color:
                Colors.grey.shade500,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // FILING HEALTH
  // =========================================================

  Widget _filingHealthCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFECFDF5),
            Color(0xFFF0FDF4),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFFBBF7D0),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                Color(0xFFDCFCE7),
            child: Icon(
              Icons.verified_rounded,
              color:
                  Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Excellent filing health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'No overdue returns are detected for this financial year.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // AI INSIGHT
  // =========================================================

  Widget _complianceInsightCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEEF2FF),
            Color(0xFFF5F3FF),
          ],
        ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFFC7D2FE),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color:
                  Colors.deepPurple.withOpacity(
                .10,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color:
                  Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Velai AI Insight',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Complete GSTR-1 first so the outward liability can be reviewed before preparing GSTR-3B.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // RETURN ACTION
  // =========================================================

  void _handleReturnAction(
    BuildContext context,
    GstReturnData item,
  ) {
    if (item.returnType == 'GSTR-1') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Next: Open GSTR-1 preparation workspace',
          ),
        ),
      );

      return;
    }

    if (item.returnType == 'GSTR-3B') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Next: Open GSTR-3B preparation workspace',
          ),
        ),
      );

      return;
    }
  }

  // =========================================================
  // DETAIL SHEET
  // =========================================================

  void _showReturnDetails(
    BuildContext context,
    GstReturnData item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (_) {
        final status =
            _statusInfo(item.status);

        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            14,
            22,
            30,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top:
                  Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: item.color
                          .withOpacity(.10),
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.returnType,
                          style:
                              const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(
                          item.title,
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: status.color
                          .withOpacity(.10),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color:
                            status.color,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _detailTile(
                Icons.calendar_month_outlined,
                'Return Period',
                item.period,
              ),

              _detailTile(
                Icons.event_outlined,
                'Due Date',
                item.dueDate,
              ),

              _detailTile(
                Icons.info_outline,
                'Return Description',
                item.subtitle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color:
                const Color(0xFF166534),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ReturnStatusInfo _statusInfo(
    GstReturnStatus status,
  ) {
    switch (status) {
      case GstReturnStatus.filed:
        return const ReturnStatusInfo(
          label: 'FILED',
          color: Colors.green,
        );

      case GstReturnStatus.pending:
        return const ReturnStatusInfo(
          label: 'PENDING',
          color: Colors.orange,
        );

      case GstReturnStatus.inProgress:
        return const ReturnStatusInfo(
          label: 'IN PROGRESS',
          color: Colors.blue,
        );

      case GstReturnStatus.overdue:
        return const ReturnStatusInfo(
          label: 'OVERDUE',
          color: Colors.red,
        );
    }
  }
}

// ===========================================================
// MODELS
// ===========================================================

enum GstReturnStatus {
  filed,
  pending,
  inProgress,
  overdue,
}

class GstReturnData {
  final String returnType;
  final String title;
  final String subtitle;
  final String period;
  final String dueDate;
  final GstReturnStatus status;
  final Color color;
  final IconData icon;
  final double completion;

  const GstReturnData({
    required this.returnType,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.dueDate,
    required this.status,
    required this.color,
    required this.icon,
    required this.completion,
  });
}

class ReturnStatusInfo {
  final String label;
  final Color color;

  const ReturnStatusInfo({
    required this.label,
    required this.color,
  });
}