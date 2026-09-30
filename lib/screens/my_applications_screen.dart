import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String selectedFilter = 'All';

  final filters = ['All', 'Active', 'Completed', 'Action Required'];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your applications')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('registrationApplications')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _errorState(snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            // Sort locally so Firestore composite index is not required.
            docs.sort((a, b) {
              final aTime = a.data()['createdAt'] as Timestamp?;
              final bTime = b.data()['createdAt'] as Timestamp?;

              if (aTime == null || bTime == null) return 0;

              return bTime.compareTo(aTime);
            });

            final allApplications = docs.map((e) => e.data()).toList();

            final applications = _filterApplications(allApplications);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(allApplications)),

                SliverToBoxAdapter(child: _buildSummary(allApplications)),

                SliverToBoxAdapter(child: _buildFilters()),

                if (applications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                    sliver: SliverList.separated(
                      itemCount: applications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _applicationCard(applications[index]);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(List<Map<String, dynamic>> applications) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF312E81), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(.15),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
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
            right: 50,
            bottom: -70,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.035),
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
                      color: Colors.white.withOpacity(.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'LIVE STATUS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            letterSpacing: .7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 29),

              const Text(
                'My Applications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.6,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Track all your registrations and\ncompliance requests in one place.',
                style: TextStyle(
                  color: Colors.white.withOpacity(.70),
                  height: 1.5,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 23),

              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.09),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.white.withOpacity(.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Text(
                        applications.isEmpty
                            ? 'Your submitted applications will appear here.'
                            : 'Application status updates appear here automatically.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(.80),
                          fontSize: 11.5,
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

  Widget _headerButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.10),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(List<Map<String, dynamic>> applications) {
    final active = applications.where((app) {
      final status = app['status'] ?? '';
      return !_isCompleted(status) && !_isActionRequired(status);
    }).length;

    final completed = applications.where((app) {
      return _isCompleted(app['status'] ?? '');
    }).length;

    final actionRequired = applications.where((app) {
      return _isActionRequired(app['status'] ?? '');
    }).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              value: '${applications.length}',
              label: 'Total',
              icon: Icons.description_outlined,
              color: const Color(0xFF4F46E5),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: _summaryCard(
              value: '$active',
              label: 'Active',
              icon: Icons.pending_actions_outlined,
              color: const Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: _summaryCard(
              value: '$completed',
              label: 'Completed',
              icon: Icons.check_circle_outline_rounded,
              color: const Color(0xFF059669),
            ),
          ),

          if (actionRequired > 0) ...[
            const SizedBox(width: 9),

            Expanded(
              child: _summaryCard(
                value: '$actionRequired',
                label: 'Action',
                icon: Icons.error_outline_rounded,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 17),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF8B93A1),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 18),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final selected = selectedFilter == filter;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF6B7280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // APPLICATION CARD
  // ============================================================

  Widget _applicationCard(Map<String, dynamic> data) {
    final type = (data['registrationType'] ?? 'Registration')
        .toString()
        .toUpperCase();

    final status = (data['status'] ?? 'submitted').toString();

    final style = _serviceStyle(type);
    final statusInfo = _statusInfo(status);

    final businessName = _businessName(data);

    final applicationId = (data['applicationId'] ?? '').toString();

    final progress = _progressForStatus(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showApplicationDetails(data);
        },
        borderRadius: BorderRadius.circular(25),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE7EAF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 18,
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
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: style.color.withOpacity(.09),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(style.icon, color: style.color, size: 26),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              type,
                              style: TextStyle(
                                color: style.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .8,
                              ),
                            ),

                            const Spacer(),

                            _statusBadge(statusInfo.title, statusInfo.color),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        if (applicationId.isNotEmpty) ...[
                          const SizedBox(height: 4),

                          Text(
                            'Application • ${_shortId(applicationId)}',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusInfo.description,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    statusInfo.stepLabel,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: style.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEEF0F3),
                  valueColor: AlwaysStoppedAnimation(
                    _isActionRequired(status)
                        ? const Color(0xFFDC2626)
                        : style.color,
                  ),
                ),
              ),

              if (_isActionRequired(status)) ...[
                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 17,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your attention is required to continue processing.',
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DETAILS BOTTOM SHEET
  // ============================================================

  void _showApplicationDetails(Map<String, dynamic> data) {
    final type = (data['registrationType'] ?? 'Registration')
        .toString()
        .toUpperCase();

    final status = (data['status'] ?? 'submitted').toString();

    final statusInfo = _statusInfo(status);
    final style = _serviceStyle(type);

    final history = (data['statusHistory'] as List?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: .72,
          minChildSize: .55,
          maxChildSize: .92,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 23),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: style.color,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.15),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            style.icon,
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
                                '$type Registration',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _businessName(data),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: statusInfo.color.withOpacity(.10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            statusInfo.icon,
                            color: statusInfo.color,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CURRENT STATUS',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .7,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                statusInfo.title,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Application Journey',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (history.isEmpty)
                    _defaultTimeline(status, style.color)
                  else
                    _historyTimeline(history, style.color),

                  if (status == 'approved') ...[
                    const SizedBox(height: 18),
                    _completedCard(data, type),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // TIMELINES
  // ============================================================

  Widget _defaultTimeline(String currentStatus, Color color) {
    final stages = [
      'submitted',
      'underReview',
      'readyForFiling',
      'filed',
      'approved',
    ];

    int currentIndex = stages.indexOf(currentStatus);

    if (currentIndex < 0) {
      currentIndex = currentStatus == 'documentsPending' ? 1 : 0;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final reached = index <= currentIndex;

          return _timelineItem(
            title: _statusInfo(stages[index]).title,
            completed: reached,
            last: index == stages.length - 1,
            color: color,
          );
        }),
      ),
    );
  }

  Widget _historyTimeline(List history, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: List.generate(history.length, (index) {
          final item = Map<String, dynamic>.from(history[index]);

          return _timelineItem(
            title: item['title'] ?? _statusInfo(item['status'] ?? '').title,
            completed: true,
            last: index == history.length - 1,
            color: color,
          );
        }),
      ),
    );
  }

  Widget _timelineItem({
    required String title,
    required bool completed,
    required bool last,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: completed ? color : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                completed ? Icons.check_rounded : Icons.circle,
                color: Colors.white,
                size: 16,
              ),
            ),

            if (!last)
              Container(
                height: 42,
                width: 2,
                color: completed
                    ? color.withOpacity(.45)
                    : const Color(0xFFE5E7EB),
              ),
          ],
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              title,
              style: TextStyle(
                color: completed
                    ? const Color(0xFF111827)
                    : const Color(0xFF9CA3AF),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMPLETION CARD
  // ============================================================

  Widget _completedCard(Map<String, dynamic> data, String type) {
    String? number;

    if (type == 'GST') {
      number = data['gstin'];
    } else if (type == 'MSME') {
      number = data['udyamNumber'];
    } else {
      number = data['registrationNumber'];
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF10B981)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.verified_rounded, color: Colors.white),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registration Completed',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),

                if (number != null && number.toString().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    number.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  List<Map<String, dynamic>> _filterApplications(
    List<Map<String, dynamic>> apps,
  ) {
    if (selectedFilter == 'All') {
      return apps;
    }

    if (selectedFilter == 'Completed') {
      return apps.where((app) => _isCompleted(app['status'] ?? '')).toList();
    }

    if (selectedFilter == 'Action Required') {
      return apps
          .where((app) => _isActionRequired(app['status'] ?? ''))
          .toList();
    }

    return apps.where((app) {
      final status = (app['status'] ?? '').toString();

      return !_isCompleted(status) && !_isActionRequired(status);
    }).toList();
  }

  bool _isCompleted(String status) {
    return status == 'approved' || status == 'completed';
  }

  bool _isActionRequired(String status) {
    return status == 'documentsPending' ||
        status == 'rejected' ||
        status == 'actionRequired';
  }

  String _businessName(Map<String, dynamic> data) {
    return (data['enterpriseName'] ??
            data['legalName'] ??
            data['tradeName'] ??
            'Registration Application')
        .toString();
  }

  String _shortId(String id) {
    if (id.length <= 8) return id.toUpperCase();

    return id.substring(0, 8).toUpperCase();
  }

  double _progressForStatus(String status) {
    switch (status) {
      case 'submitted':
        return .20;

      case 'underReview':
        return .40;

      case 'documentsPending':
        return .40;

      case 'readyForFiling':
        return .60;

      case 'filed':
        return .80;

      case 'arnGenerated':
        return .90;

      case 'approved':
      case 'completed':
        return 1;

      case 'rejected':
      case 'actionRequired':
        return .40;

      default:
        return .15;
    }
  }

  _ServiceStyle _serviceStyle(String type) {
    switch (type) {
      case 'GST':
        return const _ServiceStyle(
          icon: Icons.receipt_long_outlined,
          color: Color(0xFF2563EB),
        );

      case 'MSME':
        return const _ServiceStyle(
          icon: Icons.factory_outlined,
          color: Color(0xFF0F766E),
        );

      case 'IEC':
        return const _ServiceStyle(
          icon: Icons.public_rounded,
          color: Color(0xFF0891B2),
        );

      case 'LLP':
        return const _ServiceStyle(
          icon: Icons.groups_2_outlined,
          color: Color(0xFF7C3AED),
        );

      case 'PRIVATE LIMITED':
      case 'PVT LTD':
        return const _ServiceStyle(
          icon: Icons.apartment_rounded,
          color: Color(0xFFDB2777),
        );

      case 'PARTNERSHIP':
        return const _ServiceStyle(
          icon: Icons.handshake_outlined,
          color: Color(0xFFEA580C),
        );

      default:
        return const _ServiceStyle(
          icon: Icons.description_outlined,
          color: Color(0xFF4F46E5),
        );
    }
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'submitted':
        return const _StatusInfo(
          title: 'Submitted',
          description: 'Your application has been received successfully.',
          stepLabel: 'Application received',
          color: Color(0xFF2563EB),
          icon: Icons.check_circle_outline_rounded,
        );

      case 'underReview':
        return const _StatusInfo(
          title: 'Under Review',
          description: 'Our team is currently reviewing your application.',
          stepLabel: 'Verification in progress',
          color: Color(0xFFF59E0B),
          icon: Icons.manage_search_rounded,
        );

      case 'documentsPending':
        return const _StatusInfo(
          title: 'Documents Required',
          description: 'Additional documents are required to continue.',
          stepLabel: 'Waiting for your action',
          color: Color(0xFFDC2626),
          icon: Icons.upload_file_rounded,
        );

      case 'readyForFiling':
        return const _StatusInfo(
          title: 'Ready for Filing',
          description:
              'Verification is complete and the application is ready for filing.',
          stepLabel: 'Ready for submission',
          color: Color(0xFF7C3AED),
          icon: Icons.task_alt_rounded,
        );

      case 'filed':
        return const _StatusInfo(
          title: 'Filed',
          description: 'Your registration application has been filed.',
          stepLabel: 'Government processing',
          color: Color(0xFF0891B2),
          icon: Icons.cloud_done_outlined,
        );

      case 'arnGenerated':
        return const _StatusInfo(
          title: 'ARN Generated',
          description:
              'Your GST application reference number has been generated.',
          stepLabel: 'Awaiting final approval',
          color: Color(0xFF0891B2),
          icon: Icons.numbers_rounded,
        );

      case 'approved':
      case 'completed':
        return const _StatusInfo(
          title: 'Completed',
          description: 'Your registration has been completed successfully.',
          stepLabel: 'Registration completed',
          color: Color(0xFF059669),
          icon: Icons.verified_rounded,
        );

      case 'rejected':
      case 'actionRequired':
        return const _StatusInfo(
          title: 'Action Required',
          description:
              'Please review the application and complete the required action.',
          stepLabel: 'Your action is required',
          color: Color(0xFFDC2626),
          icon: Icons.error_outline_rounded,
        );

      default:
        return const _StatusInfo(
          title: 'Processing',
          description: 'Your application is currently being processed.',
          stepLabel: 'Processing',
          color: Color(0xFF6B7280),
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  Widget _statusBadge(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 37,
                color: Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No applications yet',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Your registration applications will appear here once submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(title: const Text('My Applications')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Text(
            'Unable to load applications.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// MODELS
// ================================================================

class _ServiceStyle {
  final IconData icon;
  final Color color;

  const _ServiceStyle({required this.icon, required this.color});
}

class _StatusInfo {
  final String title;
  final String description;
  final String stepLabel;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.title,
    required this.description,
    required this.stepLabel,
    required this.color,
    required this.icon,
  });
}
