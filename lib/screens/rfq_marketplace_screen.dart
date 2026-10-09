import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'supplier_quotation_screen.dart';
import 'buyer_quotation_comparison_screen.dart';
/// Buyer and supplier RFQ inboxes for the VEL AI procurement marketplace.
/// Supplier IDs correspond to the owner's Firebase UID in v1.
class RfqMarketplaceScreen extends StatefulWidget {
  const RfqMarketplaceScreen({super.key});
  @override
  State<RfqMarketplaceScreen> createState() => _RfqMarketplaceScreenState();
}
class _RfqMarketplaceScreenState extends State<RfqMarketplaceScreen> {
  static const _navy = Color(0xFF151D43);
  static const _violet = Color(0xFF6264E8);
  static const _bg = Color(0xFFF6F8FC);
  static const _muted = Color(0xFF7E89A3);
  final _db = FirebaseFirestore.instance;
  final _search = TextEditingController();
  bool _supplierTab = false;
  String _status = 'All';
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Sign in to view RFQs')));
    }
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('RFQ Marketplace',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: _bg,
        foregroundColor: _navy,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  children: [
                    _hero(),
                    const SizedBox(height: 18),
                    _tabs(),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search RFQs by title or location',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _search.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    _statusFilters(),
                    const SizedBox(height: 19),
                    _supplierTab ? _supplierList(uid) : _buyerList(uid),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _hero() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [_navy, Color(0xFF303B88), Color(0xFF6264E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFFC9CAFF)),
              SizedBox(width: 8),
              Text('VEL AI · SMART SOURCING',
                  style: TextStyle(color: Color(0xFFD9DBFF),
                      fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
            SizedBox(height: 19),
            Text('Connect. Quote. Grow.',
                style: TextStyle(color: Colors.white, fontSize: 27,
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 9),
            Text('Manage your requests and respond to relevant buyer RFQs.',
                style: TextStyle(color: Color(0xFFDAE0F5), height: 1.5)),
          ],
        ),
      );
  Widget _tabs() => Row(children: [
        Expanded(child: _tab('My RFQs', Icons.shopping_bag_outlined, false)),
        const SizedBox(width: 10),
        Expanded(child: _tab('Supplier Inbox', Icons.storefront_outlined, true)),
      ]);
  Widget _tab(String label, IconData icon, bool supplier) {
    final active = supplier == _supplierTab;
    return InkWell(
      onTap: () => setState(() {
        _supplierTab = supplier;
        _status = 'All';
      }),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 9),
        decoration: BoxDecoration(
          color: active ? _violet : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 19, color: active ? Colors.white : _navy),
          const SizedBox(width: 7),
          Flexible(child: Text(label, maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: active ? Colors.white : _navy,
                fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }
  Widget _statusFilters() {
    const statuses = ['All', 'Open', 'Quoted', 'Closed'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = statuses[index];
          return ChoiceChip(
            label: Text(value),
            selected: _status == value,
            selectedColor: const Color(0xFFE2E3FF),
            onSelected: (_) => setState(() => _status = value),
          );
        },
      ),
    );
  }
  Widget _buyerList(String uid) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // The query deliberately avoids ordering, so no composite index is needed.
        stream: _db.collection('purchaseRequests')
            .where('buyerUid', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _error(snapshot.error);
          if (!snapshot.hasData) return _loading();
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) => _time(b.data()).compareTo(_time(a.data())));
          final results = docs.where((doc) => _matches(doc.data())).toList();
          if (results.isEmpty) return _empty('No matching purchase requests',
              'Create and publish a purchase request to invite suppliers.');
          return Column(children: results.map((doc) => _requestCard(
                doc.id, doc.data(), supplier: false,
              )).toList());
        },
      );
  Widget _supplierList(String uid) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('rfqInvitations')
            .where('supplierId', isEqualTo: uid).snapshots(),
        builder: (context, invitations) {
          if (invitations.hasError) return _error(invitations.error);
          if (!invitations.hasData) return _loading();
          final docs = invitations.data!.docs.toList()
            ..sort((a, b) => _time(b.data()).compareTo(_time(a.data())));
          if (docs.isEmpty) return _empty('No RFQ invitations yet',
              'Matching buyer requirements will appear here once invitations are sent.');
          final matching = docs.where((d) =>
              _status == 'All' || _invitationStatusMatches(d.data())).toList();
          if (matching.isEmpty) return _empty('No invitations match this filter',
              'Try another status.');
          return Column(children: matching.map((invitation) {
            final invitationData = invitation.data();
            final requestId = invitationData['requestId']?.toString() ?? '';
            if (requestId.isEmpty) return const SizedBox.shrink();
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _db.collection('purchaseRequests').doc(requestId).snapshots(),
              builder: (context, request) {
                if (request.hasError) return _error(request.error);
                if (!request.hasData) return _loading();
                final data = request.data!.data();
                if (data == null || !_matchesSearch(data)) {
                  return const SizedBox.shrink();
                }
                return _requestCard(requestId, data,
                    supplier: true,
                    invitationId: invitation.id,
                    invitationStatus: invitationData['status']?.toString());
              },
            );
          }).toList());
        },
      );
  bool _invitationStatusMatches(Map<String, dynamic> d) {
    final status = (d['status'] ?? 'sent').toString().toLowerCase();
    if (_status == 'Open') return ['sent', 'viewed', 'invited', 'pending'].contains(status);
    if (_status == 'Quoted') return ['quoted', 'responded'].contains(status);
    if (_status == 'Closed') return ['closed', 'declined', 'expired'].contains(status);
    return true;
  }
  bool _matches(Map<String, dynamic> data) {
    if (!_matchesSearch(data)) return false;
    final status = (data['status'] ?? 'draft').toString().toLowerCase();
    if (_status == 'All') return true;
    if (_status == 'Open') return ['open', 'rfq_sent', 'published'].contains(status);
    if (_status == 'Quoted') return ['quotes_received', 'quoted'].contains(status);
    return ['closed', 'completed', 'cancelled'].contains(status);
  }
  bool _matchesSearch(Map<String, dynamic> data) {
    final q = _search.text.trim().toLowerCase();
    final title = (data['title'] ?? '').toString();
    final location = (data['deliveryLocation'] ?? '').toString();
    return '$title $location'.toLowerCase().contains(q);
  }
  DateTime _time(Map<String, dynamic> data) {
    final raw = data['createdAt'] ?? data['invitedAt'];
    return raw is Timestamp ? raw.toDate() : DateTime(1970);
  }
  Widget _requestCard(String id, Map<String, dynamic> d,
      {required bool supplier, String? invitationId, String? invitationStatus}) {
    final title = (d['title'] ?? 'Purchase request').toString();
    final items = d['items'];
    final count = items is List ? items.length : 0;
    final budget = d['budget'];
    final location = (d['deliveryLocation'] ?? 'Not specified').toString();
    final status = supplier
        ? (invitationStatus ?? 'sent')
        : (d['status'] ?? 'draft').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFEBEDF5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.request_quote_outlined, color: _violet)),
          const SizedBox(width: 11),
          Expanded(child: Text(title, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                  color: _navy))),
        ]),
        const SizedBox(height: 13),
        Wrap(spacing: 9, runSpacing: 7, children: [
          _chip(status.replaceAll('_', ' ').toUpperCase()),
          _chip('$count ${count == 1 ? 'item' : 'items'}'),
        ]),
        const SizedBox(height: 15),
        Wrap(spacing: 20, runSpacing: 12, children: [
          _metric('Target budget', _money(budget)),
          _metric('Delivery location', location),
        ]),
        const SizedBox(height: 15),
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _details(id, d,
                supplier: supplier, invitationId: invitationId),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text(supplier ? 'Review buyer requirement' : 'View RFQ details'),
          ),
        ),
      ]),
    );
  }
  Widget _chip(String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFF0F1FF),
        borderRadius: BorderRadius.circular(9)),
    child: Text(s, style: const TextStyle(color: _violet,
        fontSize: 10, fontWeight: FontWeight.w800)),
  );
  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: _navy,
          fontWeight: FontWeight.w700, fontSize: 13)),
    ],
  );
  String _money(dynamic value) {
    if (value is num) return '₹${value.toStringAsFixed(2)}';
    return value == null ? 'Not specified' : '₹$value';
  }
  void _details(String id, Map<String, dynamic> data,
      {required bool supplier, String? invitationId}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _RfqDetailsPage(
        requestId: id,
        request: data,
        supplier: supplier,
        invitationId: invitationId,
      ),
    ));
  }
  Widget _error(Object? error) => Padding(
    padding: const EdgeInsets.all(18),
    child: Text('Unable to load RFQs: $error',
        style: const TextStyle(color: Colors.redAccent)),
  );
  Widget _loading() => const Padding(
    padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()));
  Widget _empty(String heading, String detail) => Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(22)),
    child: Column(children: [
      const Icon(Icons.markunread_mailbox_outlined, color: _violet, size: 42),
      const SizedBox(height: 12),
      Text(heading, textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 8),
      Text(detail, textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.4)),
    ]),
  );
}
class _RfqDetailsPage extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> request;
  final bool supplier;
  final String? invitationId;
  const _RfqDetailsPage({required this.requestId, required this.request,
      required this.supplier, this.invitationId});
  @override
  State<_RfqDetailsPage> createState() => _RfqDetailsPageState();
}

class _RfqDetailsPageState extends State<_RfqDetailsPage> {
  bool _sending = false;

 
Future<void> _sendRfq() async {
  if (_sending) return;

  setState(() => _sending = true);

  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please log in before sending the RFQ.');
    }

    // Refresh Firebase authentication.
    final token = await user.getIdToken(true);

    if (token == null || token.isEmpty) {
      throw Exception('Firebase authentication token unavailable.');
    }

    // Verify that this request belongs to the buyer.
    final requestDoc = await FirebaseFirestore.instance
        .collection('purchaseRequests')
        .doc(widget.requestId)
        .get();

    if (!requestDoc.exists ||
        requestDoc.data()?['buyerUid'] != user.uid) {
      throw Exception(
        'This purchase request does not belong to your account.',
      );
    }

    // Publish the RFQ using Firebase Cloud Functions.
    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable('publishProcurementRfq');

    final result = await callable.call({
      'requestId': widget.requestId,
    });

    if (!mounted) return;

    final response = result.data;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'RFQ sent successfully! '
          '${response is Map ? response['invitedCount'] ?? 0 : 0} '
          'supplier(s) invited.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  } on FirebaseFunctionsException catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'RFQ Error (${e.code}): ${e.message ?? "Unknown error"}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to send RFQ: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _sending = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final requestId = widget.requestId;
    final request = widget.request;
    final supplier = widget.supplier;
    final invitationId = widget.invitationId;
    final items = request['items'] is List ? request['items'] as List : [];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(title: const Text('RFQ Details'),
          backgroundColor: const Color(0xFFF6F8FC)),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(padding: const EdgeInsets.all(18), children: [
          _section('Purchase requirement', [
            _line('Title', request['title']),
            _line('Description', request['description']),
            _line('Delivery location', request['deliveryLocation']),
            _line('Budget', request['budget']),
            _line('Required date', _date(request['requiredDate'])),
            _line('Status', request['status']),
          ]),
          const SizedBox(height: 14),
          _section('Items and specifications', [
            if (items.isEmpty) const Text('No line items supplied.'),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final raw = entry.value;
              if (raw is! Map) return Text('Item ${i + 1}: $raw');
              final item = Map<String, dynamic>.from(raw);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Item ${i + 1}', style: const TextStyle(
                      fontWeight: FontWeight.w800, color: Color(0xFF6264E8))),
                  _line('Name', item['name'] ?? item['title'] ?? item['description']),
                  _line('Type', item['type']),
                  _line('Quantity', item['quantity']),
                  _line('Unit', item['unit']),
                  _line('Specifications', item['specifications']),
                  _line('Target unit price', item['targetUnitPrice'] ?? item['targetPrice'] ?? item['unitPrice']),
                ]),
              );
            }),
          ]),
          const SizedBox(height: 14),
          if (supplier)
          FilledButton.icon(
  onPressed: invitationId == null
      ? null
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierQuotationScreen(
                requestId: requestId,
                invitationId: invitationId!,
              ),
            ),
          );
        },
  icon: const Icon(Icons.description_outlined),
  label: const Text('Create Quotation'),
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF6264E8),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
)
          else
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if ((request['status'] ?? 'draft').toString().toLowerCase() == 'draft') ...[
          FilledButton.icon(
            onPressed: _sending ? null : _sendRfq,
            icon: _sending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: Text(_sending ? 'Sending RFQ...' : 'Send RFQ to Suppliers'),
          ),
          const SizedBox(height: 12),
        ],
      FilledButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerQuotationComparisonScreen(
          requestId: requestId,
        ),
      ),
    );
  },
  icon: const Icon(Icons.compare_arrows_rounded),
  label: const Text('Compare Quotations'),
),
      ])
        ]),
      )),
    );
  }
  Widget _section(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 17,
          fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      ...children,
    ]),
  );
  Widget _line(String label, dynamic value) {
    final text = value == null || value.toString().trim().isEmpty
        ? 'Not specified' : value.toString();
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF8590A5),
            fontSize: 11)),
        const SizedBox(height: 3),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
  String _date(dynamic value) {
    if (value is Timestamp) return value.toDate().toLocal().toString().split(' ').first;
    return value?.toString() ?? '';
  }
  Widget _notice(String text) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      const Icon(Icons.auto_awesome, color: Color(0xFF6264E8)),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
    ]),
  );
}
