import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Supplier quotation for one invitation. Requires a trusted backend-created
/// rfqInvitations record and a readable purchaseRequests record.
class SupplierQuotationScreen extends StatefulWidget {
  final String requestId;
  final String invitationId;
  const SupplierQuotationScreen({super.key, required this.requestId, required this.invitationId});

  @override
  State<SupplierQuotationScreen> createState() => _SupplierQuotationScreenState();
}

class _Line {
  final String description;
  final String unit;
  final double quantity;
  final String specifications;
  final TextEditingController rate = TextEditingController();
  _Line(Map<String, dynamic> value)
      : description = (value['description'] ?? value['name'] ?? value['title'] ?? 'Item').toString(),
        unit = (value['unit'] ?? 'Nos').toString(),
        quantity = (value['quantity'] as num?)?.toDouble() ?? 1,
        specifications = (value['specifications'] ?? '').toString();
  double get price => double.tryParse(rate.text.trim()) ?? 0;
  double get amount => quantity * price;
  void dispose() => rate.dispose();
}

class _SupplierQuotationScreenState extends State<SupplierQuotationScreen> {
  static const navy = Color(0xFF151D43);
  static const violet = Color(0xFF6264E8);
  static const bg = Color(0xFFF6F8FC);
  final _formKey = GlobalKey<FormState>();
  final _gst = TextEditingController(text: '0');
  final _freight = TextEditingController(text: '0');
  final _deliveryDays = TextEditingController();
  final _warranty = TextEditingController();
  final _paymentTerms = TextEditingController();
  final _notes = TextEditingController();
  final _lines = <_Line>[];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;
  String? _buyerUid;
  String _title = '';
  String? _quotationId;
  bool _submitted = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  CollectionReference<Map<String, dynamic>> get _quotes =>
      FirebaseFirestore.instance.collection('quotations');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = _uid;
      if (uid == null) throw StateError('Sign in before preparing a quotation.');
      final db = FirebaseFirestore.instance;
      final invitation = await db.collection('rfqInvitations').doc(widget.invitationId).get();
      if (!invitation.exists || invitation.data()?['supplierId'] != uid ||
          invitation.data()?['requestId'] != widget.requestId) {
        throw StateError('This request was not assigned to your supplier account.');
      }
      final request = await db.collection('purchaseRequests').doc(widget.requestId).get();
      if (!request.exists) throw StateError('Purchase request not found.');
      final data = request.data()!;
      final items = data['items'];
      if (items is! List || items.isEmpty) throw StateError('This request has no items.');
      final existing = await _quotes.doc('${widget.invitationId}_$uid').get();
      if (!mounted) return;
      _buyerUid = data['buyerUid']?.toString();
      if (_buyerUid == null || _buyerUid!.isEmpty) {
        throw StateError('Buyer reference missing on the purchase request.');
      }
      _title = (data['title'] ?? 'Purchase Request').toString();
      for (final item in items) {
        if (item is Map) _lines.add(_Line(Map<String, dynamic>.from(item)));
      }
      if (_lines.isEmpty) throw StateError('No valid line items.');
      if (existing.exists) {
        final doc = existing;
        final q = doc.data()!;
        _quotationId = doc.id;
        _submitted = q['status'] == 'submitted';
        final savedLines = q['lineItems'];
        if (savedLines is List) {
          for (var i = 0; i < _lines.length && i < savedLines.length; i++) {
            final line = savedLines[i];
            if (line is Map) _lines[i].rate.text = '${line['unitPrice'] ?? ''}';
          }
        }
        _gst.text = '${q['gstRate'] ?? 0}';
        _freight.text = '${q['freight'] ?? 0}';
        _deliveryDays.text = '${q['deliveryDays'] ?? ''}';
        _warranty.text = (q['warranty'] ?? '').toString();
        _paymentTerms.text = (q['paymentTerms'] ?? '').toString();
        _notes.text = (q['notes'] ?? '').toString();
      }
      setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() { _loadError = e.toString(); _loading = false; });
    }
  }

  double get _subtotal => _lines.fold<double>(0, (s, l) => s + l.amount);
  double get _tax => _subtotal * ((double.tryParse(_gst.text) ?? 0) / 100);
  double get _total => _subtotal + _tax + (double.tryParse(_freight.text) ?? 0);

  Future<void> _save({required bool submit}) async {
    if (_saving || _submitted || !_formKey.currentState!.validate()) return;
    if (submit && _lines.any((l) => l.rate.text.trim().isEmpty)) {
      _message('Enter a price for every item before submitting.');
      return;
    }
    final uid = _uid;
    if (uid == null || _buyerUid == null) return;
    setState(() => _saving = true);
    try {
      final ref = _quotationId == null
          ? _quotes.doc('${widget.invitationId}_$uid')
          : _quotes.doc(_quotationId);
      final payload = <String, dynamic>{
        'requestId': widget.requestId,
        'invitationId': widget.invitationId,
        'supplierId': uid,
        'buyerUid': _buyerUid,
        'currency': 'INR',
        'lineItems': _lines.map((l) => {
          'description': l.description,
          'specifications': l.specifications,
          'quantity': l.quantity,
          'unit': l.unit,
          'unitPrice': l.price,
          'amount': l.amount,
        }).toList(),
        'gstRate': double.parse(_gst.text),
        'subtotal': _subtotal,
        'taxAmount': _tax,
        'freight': double.parse(_freight.text),
        'grandTotal': _total,
        'deliveryDays': int.tryParse(_deliveryDays.text),
        'warranty': _warranty.text.trim(),
        'paymentTerms': _paymentTerms.text.trim(),
        'notes': _notes.text.trim(),
        'status': submit ? 'submitted' : 'draft',
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_quotationId == null) {
        await ref.set({...payload, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await ref.update(payload);
      }
      if (!mounted) return;
      setState(() { _quotationId = ref.id; _submitted = submit; });
      _message(submit ? 'Quotation submitted to the buyer.' : 'Quotation draft saved.');
      if (submit) Navigator.of(context).pop(true);
    } on FirebaseException catch (e) {
      _message('Firestore: ${e.code}. ${e.message ?? ''}');
    } catch (e) {
      _message('Unable to save quotation: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  InputDecoration _input(String label) => InputDecoration(
        labelText: label, filled: true, fillColor: bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
      );

  Widget _number(String label, TextEditingController ctrl, {bool required = true, double? maximum}) =>
      TextFormField(
        controller: ctrl, enabled: !_submitted,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: _input(label),
        validator: (v) {
          if (!required && (v == null || v.trim().isEmpty)) return null;
          final n = double.tryParse(v?.trim() ?? '');
          if (n == null || !n.isFinite || n < 0 || (maximum != null && n > maximum)) {
            return 'Enter a valid non-negative value${maximum == null ? '' : ' (max $maximum)'}';
          }
          return null;
        },
      );

  Widget _panel(String title, Widget body) => Container(
    margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w800)),
      const SizedBox(height: 16), body,
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Prepare Quotation'), backgroundColor: bg, foregroundColor: navy),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : _loadError != null ? Center(child: Padding(padding: const EdgeInsets.all(25), child: Text(_loadError!)))
          : Form(
              key: _formKey,
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
                  Container(padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [navy, Color(0xFF5551BF)]),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('VEL AI • SUPPLIER STUDIO', style: TextStyle(color: Color(0xFFD1D4FF), letterSpacing: 1.2, fontSize: 11)),
                      const SizedBox(height: 12),
                      Text(_title, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 9),
                      Text(_submitted ? 'Submitted quotation' : 'Price each item and set your commercial terms.',
                          style: const TextStyle(color: Color(0xFFDFE1FF))),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  ..._lines.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return _panel('Item ${i + 1} • ${item.description}', Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Quantity: ${item.quantity} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (item.specifications.isNotEmpty) ...[
                          const SizedBox(height: 7), Text(item.specifications),
                        ],
                        const SizedBox(height: 14),
                        _number('Unit price (₹)', item.rate, required: _submitted),
                        const SizedBox(height: 10),
                        Text('Line total: ₹${item.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: violet)),
                      ],
                    ));
                  }),
                  _panel('Tax & delivery', Column(children: [
                    LayoutBuilder(builder: (context, box) {
                      final narrow = box.maxWidth < 440;
                      final a = _number('GST rate (%)', _gst, maximum: 100);
                      final b = _number('Freight / delivery fee (₹)', _freight);
                      return narrow ? Column(children: [a, const SizedBox(height: 12), b])
                          : Row(children: [Expanded(child: a), const SizedBox(width: 12), Expanded(child: b)]);
                    }),
                    const SizedBox(height: 12),
                    TextFormField(controller: _deliveryDays, enabled: !_submitted,
                      keyboardType: TextInputType.number, decoration: _input('Delivery within (days)'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final days = int.tryParse(v.trim());
                        return days == null || days < 0 ? 'Enter a valid number of days' : null;
                      }),
                    const SizedBox(height: 12),
                    TextFormField(controller: _warranty, enabled: !_submitted, decoration: _input('Warranty / service support')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _paymentTerms, enabled: !_submitted, maxLines: 2,
                        decoration: _input('Payment terms')),
                    const SizedBox(height: 12),
                    TextFormField(controller: _notes, enabled: !_submitted, maxLines: 2,
                        decoration: _input('Additional notes')),
                  ])),
                  _panel('Quotation summary', Column(children: [
                    _sum('Subtotal', _subtotal), _sum('GST', _tax),
                    _sum('Freight', double.tryParse(_freight.text) ?? 0),
                    const Divider(), _sum('Grand total', _total, bold: true),
                  ])),
                  if (!_submitted) ...[
                    OutlinedButton.icon(onPressed: _saving ? null : () => _save(submit: false),
                      icon: const Icon(Icons.save_outlined), label: const Text('Save Draft')),
                    const SizedBox(height: 10),
                    SizedBox(height: 54, child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: violet),
                      onPressed: _saving ? null : () => _save(submit: true),
                      icon: _saving ? const SizedBox(height: 19, width: 19,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
                      label: Text(_saving ? 'Saving...' : 'Submit Quotation'),
                    )),
                  ],
                ]),
              )),
            ),
    );
  }

  Widget _sum(String title, double value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [Expanded(child: Text(title)), Text('₹${value.toStringAsFixed(2)}',
      style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, fontSize: bold ? 20 : 14))]),
  );

  @override
  void dispose() {
    for (final line in _lines) { line.dispose(); }
    for (final c in [_gst, _freight, _deliveryDays, _warranty, _paymentTerms, _notes]) { c.dispose(); }
    super.dispose();
  }
}
