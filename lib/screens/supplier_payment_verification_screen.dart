
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupplierPaymentVerificationScreen
    extends StatefulWidget {
  const SupplierPaymentVerificationScreen({super.key});

  @override
  State<SupplierPaymentVerificationScreen> createState() =>
      _SupplierPaymentVerificationScreenState();
}

class _SupplierPaymentVerificationScreenState
    extends State<SupplierPaymentVerificationScreen> {
  static const navy = Color(0xFF151D43);
  static const purple = Color(0xFF6264E8);
  static const bg = Color(0xFFF6F8FC);

  final db = FirebaseFirestore.instance;
  final functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  String filter = 'All';
  String? busyId;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  void notify(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String money(dynamic value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  String date(dynamic value) {
    if (value is! Timestamp) return 'Pending';

    final d = value.toDate().toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'disputed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> viewProof(String paymentId) async {
    if (busyId != null) return;

    setState(() => busyId = paymentId);

    try {
      final result = await functions
          .httpsCallable('getProcurementPaymentProof')
          .call<Map<String, dynamic>>({
        'paymentId': paymentId,
      });

      final url = result.data['url']?.toString();

      if (url == null || url.isEmpty) {
        throw Exception('Payment proof is unavailable.');
      }

      final uri = Uri.parse(url);

      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Unable to open payment proof.');
      }
    } on FirebaseFunctionsException catch (e) {
      notify(e.message ?? e.code);
    } catch (e) {
      notify('Unable to view proof: $e');
    } finally {
      if (mounted) setState(() => busyId = null);
    }
  }

  Future<void> verifyPayment(
    String paymentId,
    bool approve,
  ) async {
    if (busyId != null) return;

    final reason = TextEditingController();
    String? explanation;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              approve
                  ? 'Confirm payment received?'
                  : 'Flag payment discrepancy?',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  approve
                      ? 'Verify that the full amount has actually '
                        'reached your bank account.'
                      : 'Explain why the transaction cannot '
                        'be verified.',
                ),
                if (!approve) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: reason,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!approve &&
                      reason.text.trim().length < 5) {
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  approve ? 'Confirm Receipt' : 'Flag Issue',
                ),
              ),
            ],
          );
        },
      );

      explanation = reason.text.trim();

      if (confirmed != true || !mounted) return;

      setState(() => busyId = paymentId);

      await functions
          .httpsCallable('verifyProcurementPayment')
          .call({
        'paymentId': paymentId,
        'decision': approve ? 'verify' : 'dispute',
        'reason': approve ? '' : explanation,
      });

      notify(
        approve
            ? 'Payment verified successfully.'
            : 'Payment discrepancy recorded.',
      );
    } on FirebaseFunctionsException catch (e) {
      notify('${e.code}: ${e.message ?? "Unable to verify"}');
    } catch (e) {
      notify('Verification failed: $e');
    } finally {
      reason.dispose();
      if (mounted) setState(() => busyId = null);
    }
  }

  Widget paymentCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final status =
        (data['verificationStatus'] ?? 'pending').toString();

    final color = statusColor(status);
    final pending = status == 'pending';
    final busy = busyId == doc.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE9ECF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBFF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order ${data['orderId'] ?? doc.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            money(data['amount']),
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Submitted ${date(data['submittedAt'])}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const Divider(height: 30),
          detail(
            'Transaction Reference',
            '${data['transactionReference'] ?? '-'}',
          ),
          detail(
            'Buyer',
            '${data['buyerUid'] ?? '-'}',
          ),
          if (status == 'disputed')
            detail(
              'Discrepancy',
              '${data['disputeReason'] ?? '-'}',
            ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busyId == null
                  ? () => viewProof(doc.id)
                  : null,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('View Transaction Slip'),
              style: OutlinedButton.styleFrom(
                foregroundColor: purple,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ),
          if (pending) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 360;

                final buttons = [
                  OutlinedButton(
                    onPressed: busyId == null
                        ? () => verifyPayment(doc.id, false)
                        : null,
                    child: const Text('Flag Issue'),
                  ),
                  FilledButton.icon(
                    onPressed: busyId == null
                        ? () => verifyPayment(doc.id, true)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: purple,
                    ),
                    icon: busy
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: const Text('Verify Payment'),
                  ),
                ];

                if (narrow) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      buttons[0],
                      const SizedBox(height: 8),
                      buttons[1],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: buttons[0]),
                    const SizedBox(width: 10),
                    Expanded(child: buttons[1]),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in.')),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'Payment Verification',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: bg,
        foregroundColor: navy,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('payments')
            .where('supplierId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Unable to load payments: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = [...snapshot.data!.docs];

          docs.sort((a, b) {
            final aDate =
                a.data()['submittedAt'] as Timestamp?;
            final bDate =
                b.data()['submittedAt'] as Timestamp?;

            return (bDate?.millisecondsSinceEpoch ?? 0)
                .compareTo(
                  aDate?.millisecondsSinceEpoch ?? 0,
                );
          });

          final pendingCount = docs.where(
            (d) => d.data()['verificationStatus'] == 'pending',
          ).length;

          final verifiedCount = docs.where(
            (d) => d.data()['verificationStatus'] == 'verified',
          ).length;

          final filtered = docs.where((doc) {
            final status =
                doc.data()['verificationStatus'];
            return filter == 'All' ||
                status == filter.toLowerCase();
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 900),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18, 12, 18, 45,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          navy,
                          Color(0xFF504AC0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 33,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Verify with confidence.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Review customer payment details '
                          'before fulfilling an order.',
                          style: TextStyle(
                            color: Color(0xFFE0E3FC),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: summary(
                          'Pending',
                          pendingCount,
                          Icons.hourglass_top_rounded,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: summary(
                          'Verified',
                          verifiedCount,
                          Icons.verified_rounded,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'Pending',
                        'Verified',
                        'Disputed',
                      ].map((value) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(value),
                            selected: filter == value,
                            onSelected: (_) =>
                                setState(() => filter = value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 45,
                            color: purple,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No payments in this view',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filtered.map(paymentCard),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget summary(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
