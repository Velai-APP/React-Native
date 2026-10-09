import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Both parties open the same screen. Only the order supplier can issue.
/// A posted invoice is immutable; invoice PDF export and payments are later steps.
class ProcurementInvoiceScreen extends StatefulWidget {
  final String orderId;
  const ProcurementInvoiceScreen({super.key, required this.orderId});

  @override
  State<ProcurementInvoiceScreen> createState() => _ProcurementInvoiceScreenState();
}

class _ProcurementInvoiceScreenState extends State<ProcurementInvoiceScreen> {
  static const navy = Color(0xFF151D43);
  static const violet = Color(0xFF6264E8);
  static const bg = Color(0xFFF6F8FC);
  final _form = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _seller = TextEditingController();
  final _sellerAddress = TextEditingController();
  final _sellerGstin = TextEditingController();
  final _sellerTaxId = TextEditingController();
  final _buyer = TextEditingController();
  final _buyerAddress = TextEditingController();
  final _buyerGstin = TextEditingController();
  final _payment = TextEditingController();
  final _notes = TextEditingController();
  bool _issuing = false;
  bool _initialized = false;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  DocumentReference<Map<String, dynamic>> get _orderRef =>
      FirebaseFirestore.instance.collection('orders').doc(widget.orderId);
  DocumentReference<Map<String, dynamic>> get _invoiceRef =>
      FirebaseFirestore.instance.collection('invoices').doc(widget.orderId);

  @override
  void dispose() {
    for (final c in [_number, _seller, _sellerAddress, _sellerGstin,
      _sellerTaxId, _buyer, _buyerAddress, _buyerGstin, _payment, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  String _rupees(dynamic value) {
    final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  InputDecoration _input(String label, {String? hint}) => InputDecoration(
    labelText: label, hintText: hint, filled: true, fillColor: bg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Widget _field(TextEditingController c, String label, {bool required = false,
      int lines = 1, int? maxLength}) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextFormField(
      controller: c, maxLines: lines, maxLength: maxLength,
      decoration: _input(label),
      validator: required ? (s) => s == null || s.trim().isEmpty ? 'Required' : null : null,
    ),
  );

  Widget _panel(String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14), child,
    ]),
  );

  Widget _row(String name, String value, {bool total = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Expanded(child: Text(name, style: TextStyle(color: total ? navy : Colors.blueGrey,
          fontWeight: total ? FontWeight.w800 : FontWeight.normal))),
      Text(value, style: TextStyle(color: navy, fontSize: total ? 19 : 14,
          fontWeight: total ? FontWeight.w800 : FontWeight.w600)),
    ]),
  );

  Widget _lineItems(dynamic raw) {
    final items = raw is List ? raw : [];
    return Column(children: [
      for (final item in items)
        if (item is Map) Container(
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${item['description'] ?? 'Item'}', style: const TextStyle(fontWeight: FontWeight.w700, color: navy)),
            const SizedBox(height: 5),
            Text('${item['quantity'] ?? 0} ${item['unit'] ?? 'Nos'} × ${_rupees(item['unitPrice'])}',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
            Align(alignment: Alignment.centerRight,
                child: Text(_rupees(item['amount']), style: const TextStyle(fontWeight: FontWeight.w800))),
          ]),
        ),
    ]);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),
        behavior: SnackBarBehavior.floating));
  }

  Future<void> _issue() async {
    if (_issuing || !_form.currentState!.validate()) return;
    final sure = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Issue this invoice?'),
      content: const Text('Please verify invoice number, tax treatment, party details and bank instructions. The issued invoice cannot be edited in this version.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Review')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Issue invoice')),
      ],
    ));
    if (sure != true || !mounted) return;
    setState(() => _issuing = true);
    try {
      final response = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('issueProcurementInvoice').call({
        'orderId': widget.orderId,
        'invoiceNumber': _number.text.trim(),
        'sellerName': _seller.text.trim(),
        'sellerAddress': _sellerAddress.text.trim(),
        'sellerGstin': _sellerGstin.text.trim().toUpperCase(),
        'sellerTaxId': _sellerTaxId.text.trim(),
        'buyerName': _buyer.text.trim(),
        'buyerAddress': _buyerAddress.text.trim(),
        'buyerGstin': _buyerGstin.text.trim().toUpperCase(),
        'paymentInstructions': _payment.text.trim(),
        'notes': _notes.text.trim(),
      });
      _toast(response.data['alreadyIssued'] == true ? 'Invoice already issued' : 'Invoice issued successfully');
    } on FirebaseFunctionsException catch (e) {
      _toast('${e.code}: ${e.message ?? 'Unable to issue invoice'}');
    } catch (e) {
      _toast('Invoice error: $e');
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  Widget _invoiceView(Map<String, dynamic> invoice) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 48), children: [
      _hero('Invoice issued', 'The buyer and supplier can view the same invoice.'),
      const SizedBox(height: 18),
      _panel('Invoice information', Column(children: [
        _row('Invoice number', '${invoice['invoiceNumber'] ?? '-'}'),
        _row('Status', '${invoice['status'] ?? 'issued'}'.toUpperCase()),
        _row('Order', widget.orderId),
      ])),
      _panel('Seller', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${invoice['sellerName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
        Text('${invoice['sellerAddress'] ?? ''}'),
        if ('${invoice['sellerGstin'] ?? ''}'.isNotEmpty) Text('GSTIN: ${invoice['sellerGstin']}'),
      ])),
      _panel('Buyer', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${invoice['buyerName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800)),
        Text('${invoice['buyerAddress'] ?? ''}'),
        if ('${invoice['buyerGstin'] ?? ''}'.isNotEmpty) Text('GSTIN: ${invoice['buyerGstin']}'),
      ])),
      _panel('Invoice items', _lineItems(invoice['lineItems'])),
      _panel('Amount due', Column(children: [
        _row('Subtotal', _rupees(invoice['subtotal'])),
        _row('GST (${invoice['gstRate'] ?? 0}%)', _rupees(invoice['taxAmount'])),
        _row('Freight', _rupees(invoice['freight'])),
        const Divider(),
        _row('Total', _rupees(invoice['totalAmount']), total: true),
      ])),
      if ('${invoice['paymentInstructions'] ?? ''}'.isNotEmpty)
        _panel('Payment instructions', Text('${invoice['paymentInstructions']}')),
      if ('${invoice['notes'] ?? ''}'.isNotEmpty)
        _panel('Notes', Text('${invoice['notes']}')),
      const Text('Invoice PDF generation and payment upload will be added in the next module.',
          style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
    ]);
  }

  Widget _hero(String title, String subtitle) => Container(
    padding: const EdgeInsets.all(23),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [navy, Color(0xFF514EC0)]),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 32),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25)),
      const SizedBox(height: 7),
      Text(subtitle, style: const TextStyle(color: Color(0xFFE0E3FC), height: 1.5)),
    ]),
  );

  Widget _formView(Map<String, dynamic> order, Map<String, dynamic> quote) {
    final isSupplier = order['supplierId'] == _uid;
    final accepted = order['status'] == 'order_accepted';
    if (!isSupplier || !accepted) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(isSupplier
            ? 'Invoice not yet available. Supplier must accept the order first.'
            : 'Waiting for the supplier to issue the invoice.', textAlign: TextAlign.center),
      ));
    }
    if (!_initialized) {
      _initialized = true;
      _number.text = 'INV-${widget.orderId.length > 8 ? widget.orderId.substring(0, 8).toUpperCase() : widget.orderId.toUpperCase()}';
    }
    return Form(
      key: _form,
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 65), children: [
        _hero('Prepare invoice', 'Review the accepted quotation and enter accurate billing details.'),
        const SizedBox(height: 18),
        _panel('Invoice & seller details', Column(children: [
          _field(_number, 'Invoice number *', required: true, maxLength: 150),
          _field(_seller, 'Seller legal name *', required: true, maxLength: 150),
          _field(_sellerAddress, 'Seller billing address *', required: true, lines: 3, maxLength: 500),
          _field(_sellerGstin, 'Seller GSTIN (if registered)', maxLength: 50),
          _field(_sellerTaxId, 'Other seller tax ID (optional)', maxLength: 50),
        ])),
        _panel('Buyer details', Column(children: [
          _field(_buyer, 'Buyer name *', required: true, maxLength: 150),
          _field(_buyerAddress, 'Buyer billing address *', required: true, lines: 3, maxLength: 500),
          _field(_buyerGstin, 'Buyer GSTIN (optional)', maxLength: 50),
        ])),
        _panel('Accepted quotation', Column(children: [
          _lineItems(quote['lineItems']),
          const Divider(),
          _row('Subtotal', _rupees(quote['subtotal'])),
          _row('GST (${quote['gstRate'] ?? 0}%)', _rupees(quote['taxAmount'])),
          _row('Freight', _rupees(quote['freight'])),
          const Divider(),
          _row('Order total', _rupees(order['totalAmount']), total: true),
        ])),
        _panel('Payment & additional details', Column(children: [
          _field(_payment, 'Payment instructions', lines: 3, maxLength: 1000),
          _field(_notes, 'Additional notes', lines: 3, maxLength: 1000),
        ])),
        const Text('Amounts are copied from the accepted quotation. Confirm the GST treatment before issuance.',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
        const SizedBox(height: 14),
        SizedBox(height: 54, child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: violet),
          onPressed: _issuing ? null : _issue,
          icon: _issuing ? const SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_circle_outline),
          label: Text(_issuing ? 'Issuing...' : 'Issue invoice to buyer'),
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) return const Scaffold(body: Center(child: Text('Please sign in')));
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Order Invoice', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: bg, foregroundColor: navy),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _orderRef.snapshots(),
          builder: (context, orderSnap) {
            if (orderSnap.hasError) return Center(child: SelectableText('Order read failed: ${orderSnap.error}'));
            if (!orderSnap.hasData) return const Center(child: CircularProgressIndicator());
            if (!orderSnap.data!.exists) return const Center(child: Text('Order not found'));
            final order = orderSnap.data!.data()!;
            if (order['buyerUid'] != _uid && order['supplierId'] != _uid) {
              return const Center(child: Text('You cannot access this order.'));
            }
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _invoiceRef.snapshots(),
              builder: (context, invoiceSnap) {
                if (invoiceSnap.hasError) return Center(child: SelectableText('Invoice read failed: ${invoiceSnap.error}'));
                if (!invoiceSnap.hasData) return const Center(child: CircularProgressIndicator());
                if (invoiceSnap.data!.exists) return _invoiceView(invoiceSnap.data!.data()!);
                if (order['status'] != 'order_accepted' || order['supplierId'] != _uid) {
                  return _formView(order, const {});
                }
                final quotationId = '${order['quotationId'] ?? ''}';
                if (quotationId.isEmpty) return const Center(child: Text('Quotation reference missing'));
                return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance.collection('quotations').doc(quotationId).get(),
                  builder: (context, quoteSnap) {
                    if (quoteSnap.hasError) return Center(child: SelectableText('Quotation read failed: ${quoteSnap.error}'));
                    if (!quoteSnap.hasData) return const Center(child: CircularProgressIndicator());
                    if (!quoteSnap.data!.exists) return const Center(child: Text('Quotation not found'));
                    return _formView(order, quoteSnap.data!.data()!);
                  },
                );
              },
            );
          },
        ),
      )),
    );
  }
}
