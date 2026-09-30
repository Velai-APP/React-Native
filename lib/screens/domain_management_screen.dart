import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add_domain_screen.dart';

class DomainManagementScreen extends StatelessWidget {
  const DomainManagementScreen({super.key});

  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color backgroundColor = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please sign in to manage your domains.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Domain Management',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Domain',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddDomainScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('domains')
            .where('userId', isEqualTo: userId)
            .orderBy('expiryDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          final docs = snapshot.data?.docs ?? [];

          final summary = _calculateSummary(docs);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _OverviewHeader(
                  total: summary.total,
                  active: summary.active,
                  expiring: summary.expiring,
                  expired: summary.expired,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'My Domains',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${docs.length} ${docs.length == 1 ? 'domain' : 'domains'}',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (docs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
                  sliver: SliverList.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final document = docs[index];

                      final data =
                          document.data() as Map<String, dynamic>;

                      final expiryDate =
                          _getExpiryDate(data['expiryDate']);

                      return _DomainCard(
                        documentId: document.id,
                        data: data,
                        expiryDate: expiryDate,
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static DateTime? _getExpiryDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static _DomainSummary _calculateSummary(
    List<QueryDocumentSnapshot> docs,
  ) {
    int active = 0;
    int expiring = 0;
    int expired = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final expiryDate = _getExpiryDate(data['expiryDate']);

      if (expiryDate == null) {
        continue;
      }

      final status = _DomainStatusHelper.getStatus(expiryDate);

      switch (status) {
        case DomainStatus.active:
          active++;
          break;
        case DomainStatus.expiring:
          expiring++;
          break;
        case DomainStatus.expired:
          expired++;
          break;
      }
    }

    return _DomainSummary(
      total: docs.length,
      active: active,
      expiring: expiring,
      expired: expired,
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
    required this.total,
    required this.active,
    required this.expiring,
    required this.expired,
  });

  final int total;
  final int active;
  final int expiring;
  final int expired;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DomainManagementScreen.primaryColor,
            DomainManagementScreen.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Domain Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                total == 0
                    ? 'Add your first domain and track its expiry.'
                    : 'Track expiry dates and keep your domains active.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 600;

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total',
                            value: total,
                            icon: Icons.language_rounded,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Active',
                            value: active,
                            icon: Icons.verified_rounded,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Expiring',
                            value: expiring,
                            icon: Icons.warning_amber_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Expired',
                            value: expired,
                            icon: Icons.cancel_rounded,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Total',
                              value: total,
                              icon: Icons.language_rounded,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Active',
                              value: active,
                              icon: Icons.verified_rounded,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Expiring',
                              value: expiring,
                              icon: Icons.warning_amber_rounded,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Expired',
                              value: expired,
                              icon: Icons.cancel_rounded,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({
    required this.documentId,
    required this.data,
    required this.expiryDate,
  });

  final String documentId;
  final Map<String, dynamic> data;
  final DateTime? expiryDate;

  @override
  Widget build(BuildContext context) {
    final String domainName =
        data['domainName']?.toString().trim().isNotEmpty == true
            ? data['domainName'].toString().trim()
            : 'Unnamed Domain';

    final status = expiryDate == null
        ? DomainStatus.expiring
        : _DomainStatusHelper.getStatus(expiryDate!);

    final statusDetails =
        _DomainStatusHelper.getStatusDetails(status);

    final int daysLeft = expiryDate == null
        ? 0
        : _DomainStatusHelper.daysRemaining(expiryDate!);

    final String expiryText = expiryDate == null
        ? 'Expiry date unavailable'
        : DateFormat('dd MMM yyyy').format(expiryDate!);

    final String description = expiryDate == null
        ? 'Please update the domain expiry date'
        : _DomainStatusHelper.getExpiryMessage(daysLeft);

    final double progress = expiryDate == null
        ? 0
        : _DomainStatusHelper.getProgress(daysLeft);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111827)
                .withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddDomainScreen(
                  docId: documentId,
                  existingData: data,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DomainLogo(
                      domainName: domainName,
                      color: statusDetails.color,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            domainName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Expiry: $expiryText',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DomainPopupMenu(
                      documentId: documentId,
                      data: data,
                      domainName: domainName,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatusBadge(
                      label: statusDetails.label,
                      icon: statusDetails.icon,
                      color: statusDetails.color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        description,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: statusDetails.color,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor:
                        statusDetails.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      statusDetails.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomainLogo extends StatelessWidget {
  const _DomainLogo({
    required this.domainName,
    required this.color,
  });

  final String domainName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String firstLetter =
        domainName.isNotEmpty ? domainName[0].toUpperCase() : 'D';

    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.68),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainPopupMenu extends StatelessWidget {
  const _DomainPopupMenu({
    required this.documentId,
    required this.data,
    required this.domainName,
  });

  final String documentId;
  final Map<String, dynamic> data;
  final String domainName;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Domain options',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF6B7280),
      ),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddDomainScreen(
                  docId: documentId,
                  existingData: data,
                ),
              ),
            );
            break;

          case 'delete':
            await _confirmDelete(context);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Color(0xFF4F46E5),
              ),
              SizedBox(width: 11),
              Text(
                'Edit domain',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
              ),
              SizedBox(width: 11),
              Text(
                'Delete domain',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
              size: 30,
            ),
          ),
          title: const Text(
            'Delete Domain?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "$domainName"? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
              ),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('domains')
          .doc(documentId)
          .delete();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$domainName deleted successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111827),
        ),
      );
    } on FirebaseException catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Unable to delete the domain.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 35, 28, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DomainManagementScreen.primaryColor
                      .withValues(alpha: 0.12),
                  DomainManagementScreen.secondaryColor
                      .withValues(alpha: 0.06),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.language_rounded,
              size: 52,
              color: DomainManagementScreen.primaryColor,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'No domains added',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add your domains to monitor expiry dates and avoid losing them.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor:
                  DomainManagementScreen.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddDomainScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add your first domain',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: DomainManagementScreen.primaryColor,
          ),
          SizedBox(height: 18),
          Text(
            'Loading your domains...',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load domains',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.contains('failed-precondition')
                  ? 'A Firestore index may be required for this query.'
                  : 'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DomainStatus {
  active,
  expiring,
  expired,
}

class _DomainStatusHelper {
  static DateTime _startOfDay(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static int daysRemaining(DateTime expiryDate) {
    final today = _startOfDay(DateTime.now());
    final expiry = _startOfDay(expiryDate);

    return expiry.difference(today).inDays;
  }

  static DomainStatus getStatus(DateTime expiryDate) {
    final daysLeft = daysRemaining(expiryDate);

    if (daysLeft < 0) {
      return DomainStatus.expired;
    }

    if (daysLeft <= 30) {
      return DomainStatus.expiring;
    }

    return DomainStatus.active;
  }

  static String getExpiryMessage(int daysLeft) {
    if (daysLeft < 0) {
      final daysExpired = daysLeft.abs();

      return daysExpired == 1
          ? 'Expired 1 day ago'
          : 'Expired $daysExpired days ago';
    }

    if (daysLeft == 0) {
      return 'Expires today';
    }

    if (daysLeft == 1) {
      return 'Expires tomorrow';
    }

    return 'Expires in $daysLeft days';
  }

  static double getProgress(int daysLeft) {
    if (daysLeft <= 0) {
      return 1;
    }

    if (daysLeft >= 365) {
      return 0.05;
    }

    return (1 - (daysLeft / 365)).clamp(0.05, 1.0);
  }

  static _StatusDetails getStatusDetails(
    DomainStatus status,
  ) {
    switch (status) {
      case DomainStatus.active:
        return const _StatusDetails(
          label: 'Active',
          color: Color(0xFF16A34A),
          icon: Icons.verified_rounded,
        );

      case DomainStatus.expiring:
        return const _StatusDetails(
          label: 'Expiring',
          color: Color(0xFFF59E0B),
          icon: Icons.warning_amber_rounded,
        );

      case DomainStatus.expired:
        return const _StatusDetails(
          label: 'Expired',
          color: Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
        );
    }
  }
}

class _StatusDetails {
  const _StatusDetails({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}

class _DomainSummary {
  const _DomainSummary({
    required this.total,
    required this.active,
    required this.expiring,
    required this.expired,
  });

  final int total;
  final int active;
  final int expiring;
  final int expired;
}