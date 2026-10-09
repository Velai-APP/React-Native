import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'supplier_registration_screen.dart';
import 'create_purchase_request_screen.dart';
import 'rfq_marketplace_screen.dart';
import 'supplier_order_approval_screen.dart';
/// User-owned procurement dashboard. No business profile is needed.
class ProcurementDashboardScreen extends StatefulWidget {
  const ProcurementDashboardScreen({super.key});
  @override
  State<ProcurementDashboardScreen> createState() =>
      _ProcurementDashboardScreenState();
}
class _ProcurementDashboardScreenState extends State<ProcurementDashboardScreen> {
  static const navy = Color(0xFF111C3D);
  static const violet = Color(0xFF6264E8);
  static const background = Color(0xFFF6F8FC);
  static const ink = Color(0xFF17213B);
  static const muted = Color(0xFF8590A5);
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
late final String? _initialUid = uid;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _requestsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _suppliersStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _rfqsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _quotesStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _ordersStream;
  @override
  void initState() {
    super.initState();
    final userId = _initialUid;
    if (userId == null) return;

    // All procurement data uses the shared marketplace collections.
    _requestsStream = FirebaseFirestore.instance
        .collection('purchaseRequests')
        .where('buyerUid', isEqualTo: userId)
        .snapshots();

    _suppliersStream = FirebaseFirestore.instance
        .collection('suppliers')
        .where('isActive', isEqualTo: true)
        .where('verificationStatus', isEqualTo: 'approved')
        .snapshots();

    _rfqsStream = FirebaseFirestore.instance
        .collection('rfqInvitations')
        .where('supplierId', isEqualTo: userId)
        .snapshots();

    _quotesStream = FirebaseFirestore.instance
        .collection('quotations')
        .where('buyerUid', isEqualTo: userId)
        .snapshots();

    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('buyerUid', isEqualTo: userId)
        .snapshots();
  }

  String _money(num number) {
    final value = number.toStringAsFixed(0);
    final negative = value.startsWith('-');
    var digits = negative ? value.substring(1) : value;
    if (digits.length > 3) {
      final last = digits.substring(digits.length - 3);
      var first = digits.substring(0, digits.length - 3);
      final pieces = <String>[];
      while (first.length > 2) {
        pieces.insert(0, first.substring(first.length - 2));
        first = first.substring(0, first.length - 2);
      }
      if (first.isNotEmpty) pieces.insert(0, first);
      digits = '${pieces.join(',')},$last';
    }
    return '${negative ? '-' : ''}₹$digits';
  }
  num _estimate(Map<String, dynamic> request) {
    final items = request['items'];
    if (items is! List) return 0;
    num total = 0;
    for (final item in items) {
      if (item is! Map) continue;
      final q = item['quantity'];
      final price = item['targetUnitPrice'];
      if (q is num && price is num) total += q * price;
    }
    return total;
  }
  void _comingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be available in the next phase.'),
        behavior: SnackBarBehavior.floating),
    );
  }
  Future<void> _newRequest() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreatePurchaseRequestScreen()),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase request saved as draft.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_initialUid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in to continue.')));
    }
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newRequest,
        backgroundColor: violet,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Request'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _requestsStream,
              builder: (context, requestSnapshot) {
                final docs = requestSnapshot.data?.docs ?? [];
                final pending = docs.where((d) {
                  final status = (d.data()['status'] ?? 'draft').toString().toLowerCase();
                  return status == 'draft' || status == 'pending' || status == 'pending_approval';
                }).length;
                num totalEstimate = 0;
                for (final doc in docs) { totalEstimate += _estimate(doc.data()); }
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 115),
                      sliver: SliverList(delegate: SliverChildListDelegate([
                        _header(),
                        const SizedBox(height: 20),
                        _hero(),
                        const SizedBox(height: 24),
                        _section('Procurement overview', 'Live Firestore data'),
                        const SizedBox(height: 12),
                        LayoutBuilder(builder: (context, c) {
                          final cols = c.maxWidth >= 720 ? 4 : 2;
                          const gap = 12.0;
                          final w = (c.maxWidth - gap * (cols - 1)) / cols;
                          return Wrap(spacing: gap, runSpacing: gap, children: [
                            _stat('Requests', '${docs.length}', Icons.assignment_outlined,
                              const Color(0xFF5267E8), w, requestSnapshot.hasError),
                            _stat('To action', '$pending', Icons.pending_actions_outlined,
                              const Color(0xFFE6A04A), w, requestSnapshot.hasError),
                            _countStat('Suppliers', _suppliersStream, Icons.groups_outlined,
                              const Color(0xFF9A64D8), w),
                            _countStat('Orders', _ordersStream, Icons.shopping_bag_outlined,
                              const Color(0xFF22A98A), w),
                          ]);
                        }),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: _panel(),
                          child: Row(children: [
                            const Icon(Icons.currency_rupee_rounded, color: violet),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Estimated request value',
                              style: TextStyle(color: muted, fontSize: 12))),
                            Text(requestSnapshot.hasError ? 'Unavailable' : _money(totalEstimate),
                              style: const TextStyle(fontWeight: FontWeight.w800, color: ink, fontSize: 16)),
                          ]),
                        ),
                        const SizedBox(height: 26),
                        _section('Your workspace', 'Purchase tools'),
                        const SizedBox(height: 14),
                        _workspace(),
                        const SizedBox(height: 24),
                        _activityCounts(),
                        const SizedBox(height: 25),
                        _section('Recent purchase requests', '${docs.length} total'),
                        const SizedBox(height: 12),
                        if (requestSnapshot.hasError)
                          _info('Could not load requests. Check your Firestore rules and sign-in.',
                            Icons.error_outline_rounded)
                        else if (requestSnapshot.connectionState == ConnectionState.waiting)
                          const Center(child: Padding(
                            padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                        else if (docs.isEmpty)
                          _info('No purchases yet. Create your first request to begin.',
                            Icons.inventory_2_outlined)
                        else
                          ...(_sortedRequests(docs).take(10).map(_requestCard)),
                      ])),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedRequests(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final sorted = [...docs];
    sorted.sort((a, b) {
      final at = a.data()['createdAt'];
      final bt = b.data()['createdAt'];
      final aMs = at is Timestamp ? at.millisecondsSinceEpoch : 0;
      final bMs = bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
      return bMs.compareTo(aMs);
    });
    return sorted;
  }
  Widget _header() => Row(children: [
    Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(15)),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('VEL AI', style: TextStyle(color: muted, fontSize: 11, letterSpacing: 1.2)),
        Text('AI Procurement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink))])),
  ]);
  Widget _hero() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [navy, Color(0xFF293A83), Color(0xFF514EC0)]),
      borderRadius: BorderRadius.circular(25),
      boxShadow: const [BoxShadow(color: Color(0x23111C3D), blurRadius: 22, offset: Offset(0, 10))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.auto_awesome, size: 15, color: Color(0xFFD5D7FF)),
        SizedBox(width: 8),
        Text('YOUR PURCHASING HUB', style: TextStyle(color: Color(0xFFD5D7FF), fontSize: 11, letterSpacing: 1)),
      ]),
      const SizedBox(height: 17),
      const Text('Buy smarter.\nSpend better.', style: TextStyle(
        color: Colors.white, fontSize: 31, height: 1.12, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      const Text('Manage products, services, suppliers and requests in one place.',
        style: TextStyle(color: Color(0xFFDFE2FC), fontSize: 13, height: 1.6)),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: _newRequest,
        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: navy,
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14)),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Create purchase request'),
      ),
    ]),
  );
  BoxDecoration _panel() => BoxDecoration(
    color: Colors.white, borderRadius: BorderRadius.circular(19),
    border: Border.all(color: const Color(0xFFECEFFA)),
  );
  Widget _section(String title, String detail) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800, color: ink))),
    Text(detail, style: const TextStyle(color: muted, fontSize: 11)),
  ]);
  Widget _stat(String label, String value, IconData icon, Color color,
      double width, bool failed) => Container(
    width: width, padding: const EdgeInsets.all(15),
    decoration: _panel(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22)),
      const SizedBox(height: 15),
      Text(failed ? '!' : value, style: const TextStyle(
        fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: muted, fontSize: 12)),
    ]),
  );
  Widget _countStat(String label,
      Stream<QuerySnapshot<Map<String, dynamic>>>? stream,
      IconData icon, Color color, double width) =>
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, s) => _stat(label,
        s.hasData ? '${s.data!.docs.length}' : '—',
        icon, color, width, s.hasError),
    );
  Widget _workspace() => LayoutBuilder(builder: (context, c) {
    final tiles = <({String label, IconData icon, Color color, VoidCallback open})>[
(
  label: 'Suppliers',
  icon: Icons.groups_rounded,
  color: const Color(0xFF7952C7),
  open: () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in first.'),
        ),
      );
      return;
    }
    try {
      final supplierDoc = await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(user.uid)
          .get();
      if (!context.mounted) return;
      if (supplierDoc.exists) {
        final supplier = supplierDoc.data()!;
        final status =
            (supplier['verificationStatus'] ?? 'pending')
                .toString();
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF6264E8),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Already Registered'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You have already registered as a supplier.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Business: ${supplier['displayName'] ?? '-'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${status.toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SupplierRegistrationScreen(),
                    ),
                  );
                },
                child: const Text('View / Edit Profile'),
              ),
            ],
          ),
        );
      } else {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SupplierRegistrationScreen(),
          ),
        );
        if (!context.mounted) return;
        if (result != null && result.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result),
              backgroundColor: const Color(0xFF13866C),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on FirebaseException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to check registration: ${e.message ?? e.code}',
          ),
        ),
      );
    }
  },
),
      (label: 'RFQs', icon: Icons.request_quote_rounded,
        color: const Color(0xFFE09A37), open: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const RfqMarketplaceScreen()))),
      // (label: 'Compare', icon: Icons.balance_rounded,
      //   color: const Color(0xFF316AD7), open: () => _comingSoon('Comparison')),
      (label: 'Orders', icon: Icons.inventory_2_outlined,
        color: const Color(0xFF149C81), open: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const SupplierOrderApprovalScreen()))),
    ];
    final cols = c.maxWidth < 340 ? 2 : 4;
    const gap = 10.0;
    final width = (c.maxWidth - gap * (cols - 1)) / cols;
    return Wrap(spacing: gap, runSpacing: gap, children: tiles.map((tile) {
      return SizedBox(width: width, child: Material(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        child: InkWell(onTap: tile.open, borderRadius: BorderRadius.circular(18),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
            child: Column(children: [
              Icon(tile.icon, color: tile.color, size: 29),
              const SizedBox(height: 9),
              Text(tile.label, textAlign: TextAlign.center,
                style: const TextStyle(color: ink, fontSize: 12, fontWeight: FontWeight.w700)),
            ]))),
      ));
    }).toList());
  });
  Widget _activityCounts() => Container(
    decoration: _panel(), padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quotation pipeline', style: TextStyle(fontSize: 15,
        color: ink, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _miniCount('RFQs', _rfqsStream)),
        Expanded(child: _miniCount('Quotations', _quotesStream)),
      ]),
      const SizedBox(height: 8),
      const Text('Quotation automation is coming in the next phase.',
        style: TextStyle(fontSize: 11, color: muted)),
    ]),
  );
  Widget _miniCount(String label,
      Stream<QuerySnapshot<Map<String, dynamic>>>? stream) =>
    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) => Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(snapshot.hasError ? '!' : snapshot.hasData
          ? '${snapshot.data!.docs.length}' : '—', style: const TextStyle(
          fontSize: 22, color: ink, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(fontSize: 12, color: muted)),
      ]),
    );
  Widget _info(String message, IconData icon) => Container(
    width: double.infinity, padding: const EdgeInsets.all(26),
    decoration: _panel(), child: Column(children: [
      Icon(icon, color: violet, size: 33),
      const SizedBox(height: 10),
      Text(message, textAlign: TextAlign.center,
        style: const TextStyle(color: muted, height: 1.5)),
    ]),
  );
  Widget _requestCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final items = data['items'];
    final count = items is List ? items.length : 0;
    final status = (data['status'] ?? 'draft').toString();
    final title = (data['title'] ?? 'Untitled request').toString();
    final amount = _estimate(data);
    final location = (data['deliveryLocation'] ?? '').toString();
    final chips = [
      if (count > 0) '$count item${count == 1 ? '' : 's'}',
      if (amount > 0) _money(amount),
      if (location.isNotEmpty) location,
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _panel(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        leading: Container(padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: const Color(0xFFEDF0FF),
            borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.shopping_bag_outlined, color: violet)),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, color: ink)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6),
          child: Text('${status.toUpperCase()}${chips.isNotEmpty ? '  •  ${chips.join('  •  ')}' : ''}',
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: muted))),
        trailing: const Icon(Icons.chevron_right_rounded, color: muted),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _RequestDetailsScreen(requestRef: doc.reference))),
      ),
    );
  }
}
/// Read-only request details until edit and RFQ workflows are implemented.
class _RequestDetailsScreen extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> requestRef;
  const _RequestDetailsScreen({required this.requestRef});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F8FC),
    appBar: AppBar(title: const Text('Request details'),
      backgroundColor: const Color(0xFFF6F8FC)),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: requestRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Unable to load request.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data();
        if (data == null) return const Center(child: Text('Request not found.'));
        final items = data['items'] is List ? data['items'] as List : const [];
        final suppliers = data['preferredSupplierIds'] is List
            ? data['preferredSupplierIds'] as List
            : const [];
        final required = data['requiredDate'];
        final date = required is Timestamp
          ? '${required.toDate().day}/${required.toDate().month}/${required.toDate().year}' : 'Not specified';
        return ListView(padding: const EdgeInsets.all(18), children: [
          Text((data['title'] ?? '').toString(), style: const TextStyle(
            fontSize: 25, color: Color(0xFF17213B), fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _line('Status', (data['status'] ?? 'draft').toString().toUpperCase()),
          _line('Description', (data['description'] ?? '').toString()),
          _line('Budget', data['budget'] is num ? '₹${data['budget']}' : 'Not specified'),
          _line('Delivery location', (data['deliveryLocation'] ?? '').toString()),
          _line('Required by', date),
          _line('Suppliers selected', '${suppliers.length}'),
          const SizedBox(height: 18),
          const Text('Products and services', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final raw in items)
            if (raw is Map) Card(child: Padding(padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text((raw['description'] ?? 'Item').toString(),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${raw['type'] ?? 'Product'} • ${raw['quantity'] ?? 0} ${raw['unit'] ?? 'Nos'}'),
                if (raw['targetUnitPrice'] != null)
                  Text('Target unit price: ₹${raw['targetUnitPrice']}'),
                if ((raw['specifications'] ?? '').toString().isNotEmpty)
                  Text('Specifications: ${raw['specifications']}'),
              ]))),
        ]);
      },
    ),
  );
  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8590A5))),
      const SizedBox(height: 3),
      Text(value.isEmpty ? 'Not specified' : value,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const Divider(),
    ]),
  );
}
