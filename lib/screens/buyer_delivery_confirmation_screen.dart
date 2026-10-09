import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BuyerDeliveryConfirmationScreen extends StatefulWidget {
  final String orderId;
  const BuyerDeliveryConfirmationScreen({super.key, required this.orderId});

  @override
  State<BuyerDeliveryConfirmationScreen> createState() => _BuyerDeliveryConfirmationScreenState();
}

class _BuyerDeliveryConfirmationScreenState extends State<BuyerDeliveryConfirmationScreen> {
  static const violet = Color(0xFF6264E8);
  static const navy = Color(0xFF151D43);
  final _formKey = GlobalKey<FormState>();
  final _feedback = TextEditingController();
  int _rating = 0;
  bool _received = false;
  bool _saving = false;

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (!_received) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirm that you have actually received the goods or service.')));
      return;
    }
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating.')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delivery?'),
        content: const Text('This completes the order and publishes your rating and feedback to the supplier. You cannot submit another review for this order.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('confirmProcurementDelivery').call({
        'orderId': widget.orderId,
        'rating': _rating,
        'feedback': _feedback.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed. Thank you for reviewing the supplier!')));
      Navigator.pop(context, true);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${e.code}: ${e.message ?? 'Confirmation failed'}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to confirm delivery: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(title: const Text('Confirm Delivery & Review'), backgroundColor: const Color(0xFFF6F8FC), foregroundColor: navy),
      body: uid == null
          ? const Center(child: Text('Sign in as the buyer.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: SelectableText('${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final order = snapshot.data!.data();
                if (order == null) return const Center(child: Text('Order not found.'));
                if (order['buyerUid'] != uid) return const Center(child: Text('This order belongs to another buyer.'));
                if (order['status'] == 'order_completed') return const Center(child: Text('Delivery has already been confirmed and reviewed.'));
                if (order['status'] != 'fulfilment_submitted') return const Center(child: Text('Wait until the supplier submits shipment or service fulfilment.'));
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text('Have you received your order?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: navy)),
                          const SizedBox(height: 8),
                          Text('Order: ${widget.orderId}', style: const TextStyle(color: Colors.blueGrey)),
                          const SizedBox(height: 20),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CheckboxListTile(
                                value: _received,
                                onChanged: _saving ? null : (value) => setState(() => _received = value ?? false),
                                title: const Text('I confirm that I received the goods / service'),
                                subtitle: const Text('Confirm only after verifying the delivery and its condition.'),
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Rate this supplier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 1,
                                    children: List.generate(5, (index) => IconButton(
                                      tooltip: '${index + 1} stars',
                                      onPressed: _saving ? null : () => setState(() => _rating = index + 1),
                                      icon: Icon(index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                                        size: 37, color: Colors.amber.shade700),
                                    )),
                                  ),
                                  Text(_rating == 0 ? 'Select 1–5 stars' : '$_rating / 5 stars', style: const TextStyle(color: Colors.blueGrey)),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _feedback,
                                    maxLength: 1000,
                                    minLines: 4,
                                    maxLines: 6,
                                    decoration: const InputDecoration(
                                      labelText: 'Feedback about the supplier',
                                      hintText: 'Product quality, packing, dispatch time, communication...',
                                      border: OutlineInputBorder(),
                                      alignLabelWithHint: true,
                                    ),
                                    validator: (value) {
                                      final n = (value ?? '').trim().length;
                                      if (n < 10) return 'Enter at least 10 characters.';
                                      if (n > 1000) return 'Limit feedback to 1000 characters.';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: _saving
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.verified_outlined),
                            label: Text(_saving ? 'Submitting...' : 'Confirm Delivery & Submit Review'),
                            style: FilledButton.styleFrom(backgroundColor: violet, foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(54)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
