import 'package:flutter/material.dart';

import './returns/gst_returns_screen.dart';
import 'gst_notices_screen.dart';
import 'gst_reconciliation_screen.dart';
import 'gst_payments_screen.dart';
import 'gst_reports_screen.dart';

class GstDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> gstProfile;

  const GstDashboardScreen({
    super.key,
    required this.gstProfile,
  });


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF166534),
        foregroundColor: Colors.white,
        titleSpacing: 18,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GST Compliance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your tax compliance workspace',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _businessHeader(),

              const SizedBox(height: 18),

              _complianceOverview(),

              const SizedBox(height: 26),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Manage your GST activities from one place',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 16),

              _quickActions(context),

              const SizedBox(height: 28),

              _upcomingCompliance(),

              const SizedBox(height: 28),

              _taxSummary(),

              const SizedBox(height: 28),

              _attentionSection(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // BUSINESS HEADER
  // =========================================================

  Widget _businessHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF14532D),
            Color(0xFF16A34A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

   Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        gstProfile['tradeName']?.toString().trim().isNotEmpty == true
            ? gstProfile['tradeName'].toString()
            : gstProfile['legalName']?.toString() ?? 'Business',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        gstProfile['gstin']?.toString() ?? '',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          letterSpacing: .6,
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
                  color: Colors.white.withOpacity(.17),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: Color(0xFF86EFAC),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _headerMiniInfo(
                title: 'State',
                value: gstProfile['state']?.toString() ?? '-',
              ),
              const SizedBox(width: 24),
              _headerMiniInfo(
                title: 'Type',
                value: gstProfile['registrationType']?.toString() ?? '-',
              ),
              const SizedBox(width: 24),
              _headerMiniInfo(
                title: 'FY',
                value: gstProfile['financialYear']?.toString() ?? '2026-27',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerMiniInfo({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // COMPLIANCE OVERVIEW
  // =========================================================

  Widget _complianceOverview() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.task_alt_rounded,
            title: 'Compliance',
            value: '92%',
            subtitle: 'Excellent',
            iconColor: Colors.green,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _summaryCard(
            icon: Icons.calendar_month_rounded,
            title: 'Next Due',
            value: '11 Sep',
            subtitle: 'GSTR-1',
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _quickActions(
    BuildContext context,
  ) {
    final actions = [
      GstAction(
        icon: Icons.description_outlined,
        title: 'Returns',
        subtitle: 'GSTR filings',
        color: Colors.blue,
       onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GstReturnsScreen(
        gstProfile: gstProfile,
      ),
    ),
  );
},
      ),
      GstAction(
        icon: Icons.compare_arrows_rounded,
        title: 'Reconcile',
        subtitle: 'Books vs 2B',
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const GstReconciliationScreen(),
            ),
          );
        },
      ),
      GstAction(
        icon: Icons.mark_email_unread_outlined,
        title: 'Notices',
        subtitle: 'Track & reply',
        color: Colors.red,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const GstNoticesScreen(),
            ),
          );
        },
      ),
      GstAction(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payments',
        subtitle: 'Tax liability',
        color: Colors.orange,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const GstPaymentsScreen(),
            ),
          );
        },
      ),
      GstAction(
        icon: Icons.analytics_outlined,
        title: 'Reports',
        subtitle: 'GST insights',
        color: Colors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const GstReportsScreen(),
            ),
          );
        },
      ),
      GstAction(
        icon: Icons.receipt_outlined,
        title: 'Invoices',
        subtitle: 'Sales & purchase',
        color: Colors.indigo,
        onTap: () {},
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: action.onTap,
            borderRadius:
                BorderRadius.circular(20),
            child: Ink(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.045),
                    blurRadius: 14,
                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 47,
                    width: 47,
                    decoration: BoxDecoration(
                      color: action.color
                          .withOpacity(.11),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          action.subtitle,
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // UPCOMING COMPLIANCE
  // =========================================================

  Widget _upcomingCompliance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Compliance',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Stay ahead of your GST deadlines',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 15),

        _returnTile(
          returnName: 'GSTR-1',
          description: 'Outward supplies',
          dueDate: '11 Sep 2026',
          daysLeft: '31 days left',
          color: Colors.blue,
        ),

        const SizedBox(height: 12),

        _returnTile(
          returnName: 'GSTR-3B',
          description: 'Monthly summary return',
          dueDate: '20 Sep 2026',
          daysLeft: '40 days left',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _returnTile({
    required String returnName,
    required String description,
    required String dueDate,
    required String daysLeft,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.description_outlined,
              color: color,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  returnName,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Due $dueDate • $daysLeft',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 17,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAX SUMMARY
  // =========================================================

  Widget _taxSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Month',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.04),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              _moneyRow(
                'Output GST',
                '₹6,82,450',
              ),
              const Divider(height: 26),
              _moneyRow(
                'Eligible ITC',
                '₹4,10,800',
              ),
              const Divider(height: 26),
              _moneyRow(
                'Estimated Payable',
                '₹2,71,650',
                highlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moneyRow(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: highlight
                ? Colors.black87
                : Colors.grey.shade600,
            fontWeight: highlight
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: highlight
                ? Colors.orange.shade800
                : Colors.black87,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ATTENTION
  // =========================================================

  Widget _attentionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.orange
                  .withOpacity(.13),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Needs your attention',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '8 purchase invoices are missing in GSTR-2B. '
                  'Review them before claiming ITC.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// QUICK ACTION MODEL
// ===========================================================

class GstAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const GstAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}