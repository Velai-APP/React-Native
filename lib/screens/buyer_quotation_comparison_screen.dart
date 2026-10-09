import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';



import 'package:firebase_auth/firebase_auth.dart';



import 'package:flutter/material.dart';



import 'buyer_invoice_payment_screen.dart';
import 'buyer_shipment_tracking_screen.dart';








/// Buyer comparison of submitted supplier quotations for one purchase request.



/// Requires the quotation and order security rules supplied separately.



class BuyerQuotationComparisonScreen extends StatefulWidget {



  final String requestId;



  const BuyerQuotationComparisonScreen({super.key, required this.requestId});







  @override



  State<BuyerQuotationComparisonScreen> createState() =>



      _BuyerQuotationComparisonScreenState();



}







class _BuyerQuotationComparisonScreenState



    extends State<BuyerQuotationComparisonScreen> {



  static const navy = Color(0xFF151D43);



  static const violet = Color(0xFF6264E8);



  static const bg = Color(0xFFF6F8FC);



  static const subtle = Color(0xFF69738A);



  final _db = FirebaseFirestore.instance;



  String? _selectedId;



  bool _placing = false;



  String? _requestTitle;



  String? _error;



  bool _loading = true;



  String? get _uid => FirebaseAuth.instance.currentUser?.uid;







  @override



  void initState() {



    super.initState();



    _loadRequest();



  }







  Future<void> _loadRequest() async {



    try {



      final uid = _uid;



      if (uid == null) throw StateError('Sign in to view your quotations.');



      final snap = await _db.collection('purchaseRequests').doc(widget.requestId).get();



      if (!snap.exists || snap.data()?['buyerUid'] != uid) {



        throw StateError('Purchase request unavailable for this account.');



      }



      if (!mounted) return;



      setState(() {



        _requestTitle = (snap.data()?['title'] ?? 'Purchase Request').toString();



        _loading = false;



      });



    } catch (e) {



      if (mounted) setState(() { _loading = false; _error = e.toString(); });



    }



  }







  String _money(dynamic amount) {



    final n = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;



    return '₹${n.toStringAsFixed(2)}';



  }







  double _number(dynamic value) =>



      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;







  String _supplierLabel(dynamic id) {



    final value = id?.toString() ?? '';



    if (value.isEmpty) return 'Unknown';



    return value.length <= 8 ? value : value.substring(0, 8);



  }







  void _toast(String message) {



    if (!mounted) return;



    ScaffoldMessenger.of(context).showSnackBar(



      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),



    );



  }







  /// Request an order through the trusted backend, never via client writes.
  Future<void> _requestOrder(Map<String, dynamic> quotation, String quoteId) async {
    if (_placing || _uid == null) return;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request this order?'),
        content: Text('Send an order request for ${_money(quotation['grandTotal'])} '
            'to this supplier? The supplier must accept before invoicing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Request Order')),
        ],
      ),
    );
    if (accepted != true || !mounted) return;

    setState(() => _placing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('Please sign in again.');
      await user.getIdToken(true);
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('requestProcurementOrder');
      await callable.call(<String, dynamic>{
        'requestId': widget.requestId,
        'quotationId': quoteId,
      });
      _toast('Order request sent. Await supplier acceptance.');
    } on FirebaseFunctionsException catch (e) {
      _toast('Order error (${e.code}): ${e.message ?? 'Unknown error'}');
    } on FirebaseException catch (e) {
      _toast('Firebase error (${e.code}): ${e.message ?? 'Unknown error'}');
    } catch (e) {
      _toast('Unable to request order: $e');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Widget _surface(Widget child) => Container(



    decoration: BoxDecoration(



      color: Colors.white,



      borderRadius: BorderRadius.circular(20),



      border: Border.all(color: const Color(0xFFE9EBF3)),



    ),



    padding: const EdgeInsets.all(17),



    child: child,



  );







  Widget _quotationCard(String id, Map<String, dynamic> d, bool cheapest) {



    final selected = _selectedId == id;



    final lines = d['lineItems'] is List ? (d['lineItems'] as List) : const [];



    return Padding(



      padding: const EdgeInsets.only(bottom: 12),



      child: Material(



        color: Colors.white,



        borderRadius: BorderRadius.circular(20),



        child: InkWell(



          borderRadius: BorderRadius.circular(20),



          onTap: () => setState(() => _selectedId = id),



          child: Container(



            decoration: BoxDecoration(



              borderRadius: BorderRadius.circular(20),



              border: Border.all(color: selected ? violet : const Color(0xFFE9EBF3), width: selected ? 2 : 1),



            ),



            padding: const EdgeInsets.all(18),



            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [



              Row(children: [



                Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,



                    color: selected ? violet : subtle),



                const SizedBox(width: 9),



                Expanded(child: Text('Supplier • ${_supplierLabel(d['supplierId'])}',



                    style: const TextStyle(fontWeight: FontWeight.w800, color: navy))),



                if (cheapest) const Chip(label: Text('Lowest price')),



              ]),



              const SizedBox(height: 14),



              Text(_money(d['grandTotal']), style: const TextStyle(fontSize: 27, color: navy, fontWeight: FontWeight.w900)),



              const SizedBox(height: 6),



              Text('Delivery: ${d['deliveryDays'] ?? 'Not specified'} days',



                  style: const TextStyle(color: subtle)),



              const Divider(height: 28),



              ...lines.whereType<Map>().map((line) => Padding(



                padding: const EdgeInsets.only(bottom: 8),



                child: Row(children: [



                  Expanded(child: Text('${line['description'] ?? 'Item'}  × ${line['quantity'] ?? '-'}',



                    maxLines: 2, overflow: TextOverflow.ellipsis)),



                  const SizedBox(width: 8),



                  Text(_money(line['amount']), style: const TextStyle(fontWeight: FontWeight.w700)),



                ]),



              )),



              const SizedBox(height: 6),



              _detail('Subtotal', _money(d['subtotal'])),



              _detail('GST (${d['gstRate'] ?? 0}%)', _money(d['taxAmount'])),



              _detail('Freight', _money(d['freight'])),



              if ('${d['warranty'] ?? ''}'.isNotEmpty) _detail('Warranty', '${d['warranty']}'),



              if ('${d['paymentTerms'] ?? ''}'.isNotEmpty) _detail('Payment terms', '${d['paymentTerms']}'),



              if ('${d['notes'] ?? ''}'.isNotEmpty) Padding(



                padding: const EdgeInsets.only(top: 8),



                child: Text('Notes: ${d['notes']}', style: const TextStyle(color: subtle)),



              ),



            ]),



          ),



        ),



      ),



    );



  }







  Widget _detail(String k, String v) => Padding(



    padding: const EdgeInsets.symmetric(vertical: 4),



    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [



      Expanded(child: Text(k, style: const TextStyle(color: subtle, fontSize: 12))),



      const SizedBox(width: 10),



      Flexible(child: Text(v, textAlign: TextAlign.right,



        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),



    ]),



  );







  @override



  Widget build(BuildContext context) {



    if (_uid == null) return const Scaffold(body: Center(child: Text('Please sign in.')));



    return Scaffold(



      backgroundColor: bg,



      appBar: AppBar(



        title: const Text('Compare Offers', style: TextStyle(fontWeight: FontWeight.w800)),



        backgroundColor: bg, foregroundColor: navy,



      ),



      body: _loading



          ? const Center(child: CircularProgressIndicator())



          : _error != null



              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))



              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(



                  stream: _db.collection('quotations')



                      .where('buyerUid', isEqualTo: _uid)



                      .where('status', isEqualTo: 'submitted').snapshots(),



                  builder: (context, snap) {



                    if (snap.hasError) return Center(child: Text('Unable to load quotations: ${snap.error}'));



                    if (!snap.hasData) return const Center(child: CircularProgressIndicator());



                    final quotes = snap.data!.docs



                        .where((d) => d.data()['requestId'] == widget.requestId)



                        .toList();



                    quotes.sort((a, b) => _number(a.data()['grandTotal'])



                        .compareTo(_number(b.data()['grandTotal'])));



                    final chosen = quotes.where((d) => d.id == _selectedId).toList();



                    return Center(child: ConstrainedBox(



                      constraints: const BoxConstraints(maxWidth: 850),



                      child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 110), children: [



                        Container(



                          decoration: BoxDecoration(



                            gradient: const LinearGradient(colors: [navy, Color(0xFF514EC0)]),



                            borderRadius: BorderRadius.circular(25)),



                          padding: const EdgeInsets.all(24),



                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [



                            const Icon(Icons.auto_awesome, color: Colors.white, size: 30),



                            const SizedBox(height: 16),



                            const Text('Compare supplier offers', style: TextStyle(



                              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24)),



                            const SizedBox(height: 7),



                            Text(_requestTitle ?? '', style: const TextStyle(color: Color(0xFFDEE3FB))),



                            const SizedBox(height: 16),



                            Text('${quotes.length} submitted offer(s)', style: const TextStyle(



                              color: Colors.white, fontWeight: FontWeight.w700)),



                          ]),



                        ),



                        const SizedBox(height: 16),



                        _surface(const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [



                          Icon(Icons.info_outline, color: violet),



                          SizedBox(width: 10),



                          Expanded(child: Text('Offers are sorted by quoted total. Compare specifications, delivery, warranty and payment terms before choosing. Lowest price is not necessarily the best offer.')),



                        ])),



                        const SizedBox(height: 22),



                        if (quotes.isEmpty)



                          _surface(const Text('No submitted quotations yet. Your invited suppliers can send quotations from their RFQ inbox.')),



                        ...quotes.asMap().entries.map((e) =>



                          _quotationCard(e.value.id, e.value.data(), e.key == 0)),



                        const SizedBox(height: 10),



                        // Always observe the buyer's order, even when no quote

                        // is selected. This keeps invoice/payment access visible

                        // when the buyer revisits the comparison page.

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(

                          stream: _db

                              .collection('orders')

                              .doc(widget.requestId)

                              .snapshots(),

                          builder: (context, orderSnap) {

                            if (orderSnap.hasError) {

                              return _surface(Text(

                                'Order status unavailable: ${orderSnap.error}',

                              ));

                            }

                            if (!orderSnap.hasData) {

                              return const Center(

                                child: CircularProgressIndicator(),

                              );

                            }



                            final orderDoc = orderSnap.data!;

                            if (!orderDoc.exists) {

                              if (chosen.isEmpty) {

                                return const SizedBox.shrink();

                              }

                              return SizedBox(

                                width: double.infinity,

                                height: 54,

                                child: FilledButton.icon(

                                  onPressed: _placing

                                      ? null

                                      : () => _requestOrder(

                                            chosen.first.data(),

                                            chosen.first.id,

                                          ),

                                  style: FilledButton.styleFrom(

                                    backgroundColor: violet,

                                  ),

                                  icon: const Icon(Icons.shopping_bag_outlined),

                                  label: Text(_placing

                                      ? 'Sending request...'

                                      : 'Request Order'),

                                ),

                              );

                            }



                            final order = orderDoc.data()!;

                            if (order['buyerUid'] != _uid) {

                              return _surface(const Text(

                                'This order does not belong to your account.',

                              ));

                            }



                            final status =

                                (order['status'] ?? '').toString();

                            final canViewInvoice = <String>{

                              'invoice_issued',

                              'payment_submitted',

                              'payment_verified',

                              'fulfilment_submitted',
                              'order_completed',
                              'in_progress',

                              'delivered',

                              'completed',

                            }.contains(status);



                            return Column(

                              crossAxisAlignment: CrossAxisAlignment.stretch,

                              children: [

                                _surface(Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [

                                    const Text(

                                      'Your order',

                                      style: TextStyle(

                                        fontSize: 16,

                                        fontWeight: FontWeight.w800,

                                        color: navy,

                                      ),

                                    ),

                                    const SizedBox(height: 8),

                                    Text('Status: ${status.replaceAll('_', ' ')}'),

                                    const SizedBox(height: 4),

                                    Text('Total: ${_money(order['totalAmount'])}'),

                                  ],

                                )),

                                if (canViewInvoice) ...[

                                  const SizedBox(height: 16),

                                  SizedBox(

                                    width: double.infinity,

                                    child: FilledButton.icon(

                                      onPressed: () {

                                        Navigator.push(

                                          context,

                                          MaterialPageRoute(

                                            builder: (_) =>

                                                BuyerInvoicePaymentScreen(

                                              orderId: orderDoc.id,

                                            ),

                                          ),

                                        );

                                      },

                                      icon: const Icon(Icons.payment_rounded),

                                      label: const Text('View Invoice & Payment'),

                                      style: FilledButton.styleFrom(

                                        backgroundColor: violet,

                                        foregroundColor: Colors.white,

                                        padding: const EdgeInsets.symmetric(

                                          vertical: 16,

                                        ),

                                        shape: RoundedRectangleBorder(

                                          borderRadius:

                                              BorderRadius.circular(14),

                                        ),

                                      ),

                                    ),

                                  ),

                                ],
                                if (<String>{'fulfilment_submitted', 'in_progress', 'delivered', 'completed', 'order_completed'}.contains(status)) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BuyerShipmentTrackingScreen(orderId: orderDoc.id),
                                        ),
                                      ),
                                      icon: const Icon(Icons.local_shipping_outlined),
                                      label: const Text('Track Shipment & View Dispatch Slip'),
                                    ),
                                  ),
                                ],
                                if (!canViewInvoice) ...[

                                  const SizedBox(height: 12),

                                  _surface(Text(

                                    status == 'order_rejected'

                                        ? 'Supplier declined the order.'

                                        : status == 'order_accepted'

                                            ? 'Supplier accepted. Awaiting invoice.'

                                            : 'Waiting for supplier acceptance.',

                                  )),

                                ],

                              ],

                            );

                          },

                        ),

                      ]),



                    ));



                  },



                ),



    );



  }



}
