import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';



/// Supplier shipment/service fulfilment for a verified-payment order.

class SupplierShipmentScreen extends StatefulWidget {

  final String orderId;

  const SupplierShipmentScreen({super.key, required this.orderId});



  @override

  State<SupplierShipmentScreen> createState() => _SupplierShipmentScreenState();

}



class _SupplierShipmentScreenState extends State<SupplierShipmentScreen> {

  static const navy = Color(0xFF151D43);

  static const violet = Color(0xFF6264E8);

  static const background = Color(0xFFF6F8FC);



  final _formKey = GlobalKey<FormState>();

  final _carrier = TextEditingController();

  final _tracking = TextEditingController();

  final _notes = TextEditingController();

  PlatformFile? _proofFile;

  String _type = 'shipment';

  DateTime? _dispatchDate;

  DateTime? _expectedDate;

  bool _saving = false;



  @override

  void dispose() {

    _carrier.dispose();

    _tracking.dispose();

    _notes.dispose();


    super.dispose();

  }



  Future<void> _pickDate({required bool dispatch}) async {

    final now = DateTime.now();

    final value = await showDatePicker(

      context: context,

      firstDate: DateTime(now.year - 1),

      lastDate: DateTime(now.year + 3),

      initialDate: dispatch ? (_dispatchDate ?? now) : (_expectedDate ?? now),

    );

    if (value == null || !mounted) return;

    setState(() {

      if (dispatch) {

        _dispatchDate = value;

      } else {

        _expectedDate = value;

      }

    });

  }



  String _dateLabel(DateTime? date) => date == null

      ? 'Choose date'

      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';



  InputDecoration _input(String label, {String? hint}) => InputDecoration(

        labelText: label,

        hintText: hint,

        filled: true,

        fillColor: background,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

      );



  Widget _panel({required String title, required Widget child}) => Container(

        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: const Color(0xFFE7EBF4)),

        ),

        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text(title,

              style: const TextStyle(

                  fontSize: 17, fontWeight: FontWeight.w800, color: navy)),

          const SizedBox(height: 14),

          child,

        ]),

      );



  Future<void> _pickSlip() async {
    if (_saving) return;
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.single;
      final extension = file.extension?.toLowerCase();
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
        _snack('Please select a PDF, JPG or PNG slip.');
        return;
      }
      if (file.size == 0 || file.size > 8 * 1024 * 1024) {
        _snack('File must be between 1 byte and 8 MB.');
        return;
      }
      if (file.bytes == null || file.bytes!.isEmpty) {
        _snack('Unable to read file data. Please select it again.');
        return;
      }
      setState(() => _proofFile = file);
    } catch (e) {
      _snack('Cannot select slip: $e');
    }
  }

  Future<String> _uploadSlip(String supplierUid) async {
    final file = _proofFile!;
    final extension = file.extension!.toLowerCase();
    const mime = {
      'pdf': 'application/pdf',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };
    final path = 'shipmentSlips/$supplierUid/${widget.orderId}/'
        '${DateTime.now().microsecondsSinceEpoch}.$extension';
    final ref = FirebaseStorage.instance.ref(path);
    debugPrint('Shipment proof upload path: ${ref.fullPath}');
    await ref.putData(
      file.bytes!,
      SettableMetadata(
        contentType: mime[extension],
        customMetadata: {
          'supplierUid': supplierUid,
          'orderId': widget.orderId,
        },
      ),
    );
    return path;
  }

  Future<void> _submit() async {

    if (_saving || !_formKey.currentState!.validate()) return;

    if (_type == 'shipment' && _proofFile == null) {
      _snack('Upload the dispatch slip before submitting.');
      return;
    }
    if (_type == 'shipment' && _dispatchDate == null) {

      _snack('Please enter the dispatch date.');

      return;

    }

    if (_type == 'service' && _dispatchDate == null) {

      _snack('Please enter the service completion date.');

      return;

    }

    if (_expectedDate != null && _type == 'shipment' &&

        _expectedDate!.isBefore(_dispatchDate!)) {

      _snack('Expected delivery cannot be before dispatch.');

      return;

    }

    setState(() => _saving = true);

    try {

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw StateError('Sign in again.');
      final uploadedPath = _proofFile == null ? null : await _uploadSlip(user.uid);

      final function = FirebaseFunctions.instanceFor(region: 'us-central1')

          .httpsCallable('submitProcurementFulfilment');

      await function.call({

        'orderId': widget.orderId,

        'fulfilmentType': _type,

        'carrierName': _type == 'shipment' ? _carrier.text.trim() : '',

        'trackingNumber': _type == 'shipment' ? _tracking.text.trim() : '',

        'dispatchDate': _dispatchDate!.toUtc().toIso8601String(),

        'expectedDeliveryDate':

            _expectedDate?.toUtc().toIso8601String(),

        'deliveryProofReference': uploadedPath ?? '',

        'notes': _notes.text.trim(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(

        content: Text('Fulfilment submitted to buyer.'),

        backgroundColor: Color(0xFF15866B),

      ));

      Navigator.pop(context, true);

    } on FirebaseFunctionsException catch (e) {

      _snack('${e.code}: ${e.message ?? 'Submission failed'}');

    } catch (e) {

      _snack('Unable to submit: $e');

    } finally {

      if (mounted) setState(() => _saving = false);

    }

  }



  void _snack(String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context)

        .showSnackBar(SnackBar(content: Text(message)));

  }



  @override

  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {

      return const Scaffold(body: Center(child: Text('Please sign in.')));

    }

    return Scaffold(

      backgroundColor: background,

      appBar: AppBar(

        title: const Text('Shipment & Fulfilment'),

        backgroundColor: background,

        foregroundColor: navy,

      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(

        stream: FirebaseFirestore.instance

            .collection('orders')

            .doc(widget.orderId)

            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {

            return Center(child: SelectableText('Order error: ${snapshot.error}'));

          }

          if (!snapshot.hasData) {

            return const Center(child: CircularProgressIndicator());

          }

          final order = snapshot.data!.data();

          if (order == null) {

            return const Center(child: Text('Order not found.'));

          }

          if (order['supplierId'] != uid) {

            return const Center(child: Text('Only the assigned supplier can fulfil this order.'));

          }

          final status = (order['status'] ?? '').toString();

          if (status != 'payment_verified') {

            return Center(

              child: Padding(

                padding: const EdgeInsets.all(24),

                child: Text(

                  status == 'fulfilment_submitted' || status == 'order_completed'

                      ? 'Fulfilment has already been submitted. Status: $status'

                      : 'Wait until payment is verified. Current status: $status',

                  textAlign: TextAlign.center,

                ),

              ),

            );

          }

          return Center(

            child: ConstrainedBox(

              constraints: const BoxConstraints(maxWidth: 760),

              child: Form(

                key: _formKey,

                child: ListView(

                  padding: const EdgeInsets.all(18),

                  children: [

                    Container(

                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(

                        gradient: const LinearGradient(

                          colors: [navy, Color(0xFF4B50B4)],

                        ),

                        borderRadius: BorderRadius.circular(24),

                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const Icon(Icons.local_shipping_outlined,

                              color: Colors.white, size: 30),

                          const SizedBox(height: 12),

                          const Text('Ready to fulfil',

                              style: TextStyle(color: Colors.white,

                                  fontSize: 24, fontWeight: FontWeight.w800)),

                          const SizedBox(height: 8),

                          Text('Order: ${widget.orderId}',

                              style: const TextStyle(color: Colors.white70)),

                          const Text('Payment verified. Share shipment or service details with the buyer.',

                              style: TextStyle(color: Colors.white70)),

                        ],

                      ),

                    ),

                    const SizedBox(height: 18),

                    _panel(

                      title: 'Fulfilment type',

                      child: SegmentedButton<String>(

                        segments: const [

                          ButtonSegment(value: 'shipment',

                              label: Text('Goods'), icon: Icon(Icons.local_shipping_outlined)),

                          ButtonSegment(value: 'service',

                              label: Text('Service'), icon: Icon(Icons.handyman_outlined)),

                        ],

                        selected: {_type},

                        onSelectionChanged: _saving

                            ? null

                            : (values) => setState(() => _type = values.first),

                      ),

                    ),

                    _panel(

                      title: _type == 'shipment' ? 'Shipment details' : 'Service details',

                      child: Column(children: [

                        if (_type == 'shipment') ...[

                          TextFormField(

                            controller: _carrier,

                            maxLength: 100,

                            decoration: _input('Carrier / Transporter *', hint: 'e.g. Blue Dart'),

                            validator: (v) => _type == 'shipment' &&

                                (v == null || v.trim().isEmpty)

                                ? 'Enter a carrier or transporter' : null,

                          ),

                          const SizedBox(height: 10),

                          TextFormField(

                            controller: _tracking,

                            maxLength: 120,

                            decoration: _input('Tracking / LR / AWB number *'),

                            validator: (v) => _type == 'shipment' &&

                                (v == null || v.trim().isEmpty)

                                ? 'Enter tracking or LR number' : null,

                          ),

                        ],

                        OutlinedButton.icon(

                          onPressed: _saving ? null : () => _pickDate(dispatch: true),

                          icon: const Icon(Icons.calendar_month_outlined),

                          label: Text(_type == 'shipment'

                              ? 'Dispatch date: ${_dateLabel(_dispatchDate)}'

                              : 'Service completed on: ${_dateLabel(_dispatchDate)}'),

                        ),

                        if (_type == 'shipment') ...[

                          const SizedBox(height: 12),

                          OutlinedButton.icon(

                            onPressed: _saving ? null : () => _pickDate(dispatch: false),

                            icon: const Icon(Icons.event_available_outlined),

                            label: Text('Expected delivery: ${_dateLabel(_expectedDate)}'),

                          ),

                        ],

                        const SizedBox(height: 12),

                                                  OutlinedButton.icon(
                            onPressed: _saving ? null : _pickSlip,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(
                              _proofFile == null
                                  ? (_type == 'shipment'
                                      ? 'Upload Dispatch Slip *'
                                      : 'Upload Service Proof (optional)')
                                  : _proofFile!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'PDF, JPG or PNG · Maximum 8 MB',
                            style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                          ),
const SizedBox(height: 10),

                        TextFormField(

                          controller: _notes,

                          minLines: 3,

                          maxLines: 5,

                          maxLength: 1000,

                          decoration: _input('Remarks (optional)',

                              hint: 'Packing details or service handover notes'),

                        ),

                      ]),

                    ),

                    SizedBox(

                      height: 56,

                      child: FilledButton.icon(

                        onPressed: _saving ? null : _submit,

                        icon: _saving

                            ? const SizedBox(height: 20, width: 20,

                                child: CircularProgressIndicator(strokeWidth: 2,

                                    color: Colors.white))

                            : const Icon(Icons.send_rounded),

                        label: Text(_saving ? 'Submitting...' : 'Submit Fulfilment'),

                        style: FilledButton.styleFrom(

                          backgroundColor: violet,

                          shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(15)),

                        ),

                      ),

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
