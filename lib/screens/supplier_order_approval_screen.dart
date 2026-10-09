import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'procurement_invoice_screen.dart';
import 'supplier_payment_verification_screen.dart';
import 'supplier_shipment_screen.dart';
import 'supplier_ratings_screen.dart';

class SupplierOrderApprovalScreen extends StatefulWidget {
  const SupplierOrderApprovalScreen({super.key});

  @override
  State<SupplierOrderApprovalScreen> createState() =>
      _SupplierOrderApprovalScreenState();
}

class _SupplierOrderApprovalScreenState extends State<SupplierOrderApprovalScreen> {
  static const navy = Color(0xFF151D43);
  static const violet = Color(0xFF6264E8);
  static const bg = Color(0xFFF6F8FC);

  final FirebaseFirestore db = FirebaseFirestore.instance;
  String filter = 'All';
  String? busyId;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> orders(String userId) =>
      db.collection('orders').where('supplierId', isEqualTo: userId).snapshots();

  String money(dynamic value) {
    final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  String date(dynamic value) {
    if (value is! Timestamp) return 'Pending';
    final d = value.toDate().toLocal();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String statusText(String status) {
    switch (status) {
      case 'pending_supplier_acceptance': return 'Awaiting approval';
      case 'order_accepted': return 'Accepted · Invoice pending';
      case 'order_rejected': return 'Declined';
      case 'invoice_issued': return 'Invoice issued · Awaiting payment';
      case 'payment_submitted': return 'Payment submitted · Verification pending';
      case 'payment_verified': return 'Payment verified';
      case 'payment_issue': return 'Payment discrepancy';
      case 'fulfilment_submitted': return 'Dispatched · Awaiting buyer confirmation';
      case 'order_completed': return 'Completed · Customer reviewed';
      default: return status.replaceAll('_', ' ');
    }
  }

  Color statusColor(String status) {
    if (status == 'order_rejected' || status == 'payment_issue') {
      return const Color(0xFFBC4B4B);
    }
    if (status == 'order_accepted' || status == 'payment_verified' ||
        status == 'order_completed') {
      return const Color(0xFF13866C);
    }
    if (status == 'invoice_issued') return violet;
    return const Color(0xFFAA741D);
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void openPaymentVerification() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const SupplierPaymentVerificationScreen(),
    ));
  }

  void openInvoice(String orderId) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProcurementInvoiceScreen(orderId: orderId),
    ));
  }

  void openShipment(String orderId) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SupplierShipmentScreen(orderId: orderId),
    ));
  }

  void openRatings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const SupplierRatingsScreen(),
    ));
  }

  Future<void> decide(String orderId, bool accept) async {
    if (busyId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(accept ? 'Accept this order?' : 'Decline this order?'),
        content: Text(accept
            ? 'Confirm that you can fulfil this order under the agreed quotation. You will issue an invoice next.'
            : 'The buyer will see that this order has been declined.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(accept ? 'Accept' : 'Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => busyId = orderId);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('respondToProcurementOrder');
      final result = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
        'decision': accept ? 'accept' : 'reject',
      });
      showMessage(result.data['status'] == 'order_accepted'
          ? 'Order accepted successfully'
          : 'Order declined');
    } on FirebaseFunctionsException catch (e) {
      showMessage('Order update failed (${e.code}): ${e.message ?? 'Unknown error'}');
    } on FirebaseException catch (e) {
      showMessage('Firebase error (${e.code}): ${e.message ?? 'Unknown error'}');
    } catch (e) {
      showMessage('Unable to update order: $e');
    } finally {
      if (mounted) setState(() => busyId = null);
    }
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    final child = outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
            style: FilledButton.styleFrom(backgroundColor: violet),
          );
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(width: double.infinity, child: child),
    );
  }

  Widget _completedReview(String orderId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: db.collection('supplierReviews').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Could not load review. Check supplierReviews read permission.',
                style: TextStyle(color: Colors.red)),
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final review = snapshot.data!.data();
        if (review == null) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Order completed. Customer review is not available yet.'),
          );
        }
        if (review['supplierId'] != uid || review['orderId'] != orderId) {
          return const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Review unavailable for this supplier.'),
          );
        }

        final rawRating = review['rating'];
        final rating = rawRating is num ? rawRating.toInt().clamp(0, 5) : 0;
        final feedback = (review['feedback'] ?? '').toString().trim();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFE3A1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.rate_review_rounded, color: Color(0xFFB97B18)),
                SizedBox(width: 8),
                Expanded(child: Text('Customer Rating & Feedback',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: navy))),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (int i = 1; i <= 5; i++)
                    Icon(i <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFFFB629), size: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text('$rating / 5',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(feedback.isEmpty ? 'No written feedback.' : feedback,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: navy)),
              if (review['createdAt'] is Timestamp) ...[
                const SizedBox(height: 10),
                Text('Reviewed on ${date(review['createdAt'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget orderCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'unknown').toString();
    final title = (data['title'] ?? data['requestTitle'] ?? '').toString();
    final shortId = doc.id.length <= 8 ? doc.id : doc.id.substring(0, 8);
    final isPending = status == 'pending_supplier_acceptance';
    final isBusy = busyId == doc.id;
    final color = statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEDEEFD),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.inventory_2_outlined, color: violet),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isNotEmpty ? title : 'Order $shortId',
                    style: const TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Placed ${date(data['createdAt'])}',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
              ],
            )),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text(statusText(status),
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(height: 14),
          Text(money(data['totalAmount']),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy)),
          const SizedBox(height: 12),
          Text('Buyer: ${data['buyerUid'] ?? 'Unknown'}', maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          const SizedBox(height: 5),
          Text('Request: ${data['requestId'] ?? 'Unknown'}', maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          if (isPending) ...[
            const Divider(height: 30),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: busyId == null ? () => decide(doc.id, false) : null,
                icon: const Icon(Icons.close_rounded), label: const Text('Decline'),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                onPressed: busyId == null ? () => decide(doc.id, true) : null,
                style: FilledButton.styleFrom(backgroundColor: violet),
                icon: isBusy
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Accept'),
              )),
            ]),
          ],
          if (['order_accepted', 'invoice_issued', 'payment_submitted',
                'payment_verified', 'payment_issue', 'fulfilment_submitted',
                'order_completed'].contains(status))
            _actionButton(
              text: status == 'order_accepted' ? 'Generate Invoice' : 'View Invoice',
              icon: Icons.receipt_long_rounded,
              onPressed: () => openInvoice(doc.id),
            ),
          if (status == 'payment_submitted' || status == 'payment_issue')
            _actionButton(
              text: 'Verify Customer Payment',
              icon: Icons.verified_user_outlined,
              onPressed: openPaymentVerification,
              outlined: true,
            ),
          if (status == 'payment_verified')
            _actionButton(
              text: 'Create Shipment',
              icon: Icons.local_shipping_outlined,
              onPressed: () => openShipment(doc.id),
            ),
          if (status == 'fulfilment_submitted')
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Shipment submitted. Waiting for the buyer to confirm delivery.',
                  style: TextStyle(color: Colors.blueGrey)),
            ),
          if (status == 'order_completed') _completedReview(doc.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Sign in to view supplier orders.')));
    }
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Supplier Orders', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: navy,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: orders(userId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText('Could not load orders: ${snapshot.error}'),
                ));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final all = [...snapshot.data!.docs];
              all.sort((a, b) {
                final aTime = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                final bTime = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
                return bTime.compareTo(aTime);
              });
              final pending = all.where((d) =>
                  d.data()['status'] == 'pending_supplier_acceptance').length;
              final completed = all.where((d) =>
                  d.data()['status'] == 'order_completed').length;
              final visible = all.where((d) {
                final status = d.data()['status'];
                switch (filter) {
                  case 'Pending': return status == 'pending_supplier_acceptance';
                  case 'Accepted': return status == 'order_accepted';
                  case 'Invoiced': return status == 'invoice_issued';
                  case 'Payments': return status == 'payment_submitted' ||
                      status == 'payment_verified' || status == 'payment_issue';
                  case 'Shipped': return status == 'fulfilment_submitted';
                  case 'Completed': return status == 'order_completed';
                  case 'Declined': return status == 'order_rejected';
                  default: return true;
                }
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: openPaymentVerification,
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Verify Customer Payments'),
                      style: FilledButton.styleFrom(backgroundColor: violet),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: openRatings,
                      icon: const Icon(Icons.star_rounded),
                      label: const Text('All Customer Ratings & Feedback'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [navy, Color(0xFF504CBE)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.storefront_rounded, color: Colors.white, size: 34),
                        const SizedBox(height: 16),
                        const Text('Your orders. Your decisions.',
                            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        const Text('Review orders, manage fulfilment, and read buyer feedback.',
                            style: TextStyle(color: Color(0xFFE2E4FC))),
                        const SizedBox(height: 18),
                        Text('$pending pending · $completed completed · ${all.length} total',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All', 'Pending', 'Accepted', 'Invoiced',
                        'Payments', 'Shipped', 'Completed', 'Declined',
                      ].map((label) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: filter == label,
                          selectedColor: const Color(0xFFDFE1FF),
                          onSelected: (_) => setState(() => filter = label),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (visible.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Column(children: [
                        Icon(Icons.inbox_outlined, size: 45, color: violet),
                        SizedBox(height: 12),
                        Text('No orders in this view',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                    )
                  else
                    ...visible.map(orderCard),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
