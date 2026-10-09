import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';









class BuyerInvoicePaymentScreen extends StatefulWidget {

  final String orderId;



  const BuyerInvoicePaymentScreen({

    super.key,

    required this.orderId,

  });



  @override

  State<BuyerInvoicePaymentScreen> createState() =>

      _BuyerInvoicePaymentScreenState();

}



class _BuyerInvoicePaymentScreenState

    extends State<BuyerInvoicePaymentScreen> {

  static const navy = Color(0xFF151D43);

  static const violet = Color(0xFF6264E8);

  static const bg = Color(0xFFF6F8FC);

  static const muted = Color(0xFF8390A6);



  final _formKey = GlobalKey<FormState>();

  final _utr = TextEditingController();



  PlatformFile? _file;

  bool _submitting = false;



  String? get uid => FirebaseAuth.instance.currentUser?.uid;



  DocumentReference<Map<String, dynamic>> get invoiceRef =>

      FirebaseFirestore.instance

          .collection('invoices')

          .doc(widget.orderId);



  DocumentReference<Map<String, dynamic>> get orderRef =>

      FirebaseFirestore.instance

          .collection('orders')

          .doc(widget.orderId);



  @override

  void dispose() {

    _utr.dispose();

    super.dispose();

  }



  String money(dynamic value) {

    final number = value is num

        ? value.toDouble()

        : double.tryParse('$value') ?? 0;

    return '₹${number.toStringAsFixed(2)}';

  }



  void message(String text) {

    if (!mounted) return;



    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(text),

        behavior: SnackBarBehavior.floating,

      ),

    );

  }











Future<void> pickProof() async {

  try {

    final FilePickerResult? result =

        await FilePicker.pickFiles(

      type: FileType.custom,

      allowedExtensions: [

        'jpg',

        'jpeg',

        'png',

        'pdf',

      ],

      withData: true,

      allowMultiple: false,

    );



    // User cancelled

    if (result == null || result.files.isEmpty) {

      return;

    }



    final PlatformFile file = result.files.single;



    // Check file size - maximum 8 MB

    if (file.size > 8 * 1024 * 1024) {

      message('Maximum file size is 8 MB.');

      return;

    }



    // Check file bytes

    if (file.bytes == null || file.bytes!.isEmpty) {

      message('Unable to read selected file.');

      return;

    }



    // Validate extension

    final extension = file.extension?.toLowerCase();



    if (!['jpg', 'jpeg', 'png', 'pdf']

        .contains(extension)) {

      message('Only JPG, PNG and PDF files are allowed.');

      return;

    }



    if (!mounted) return;



    setState(() {

      _file = file;

    });



    message('File selected: ${file.name}');

  } catch (e) {

    message('File selection failed: $e');

  }

}









  Future<void> submitPayment(Map<String, dynamic> invoice) async {

    if (_submitting || !_formKey.currentState!.validate()) {

      return;

    }



    final userId = uid;



    if (userId == null || _file == null) {

      message('Enter the UTR and select payment proof.');

      return;

    }



    if (invoice['buyerUid'] != userId) {

      message('You are not authorized to pay this invoice.');

      return;

    }



    setState(() => _submitting = true);



    try {

      final bytes = _file!.bytes!;

      final extension =

          _file!.extension?.toLowerCase() ?? '';



      final mimeTypes = {

        'jpg': 'image/jpeg',

        'jpeg': 'image/jpeg',

        'png': 'image/png',

        'pdf': 'application/pdf',

      };



      final contentType = mimeTypes[extension];



      if (contentType == null) {

        throw Exception('Unsupported file format.');

      }



      // Allocate a unique upload path.

      final proofId = FirebaseFirestore.instance

          .collection('_generatedIds')

          .doc()

          .id;



      final path =

          'paymentProofs/$userId/${widget.orderId}/'

          '$proofId.$extension';



      final storageRef =

          FirebaseStorage.instance.ref(path);



      debugPrint('Payment proof Storage path: ${storageRef.fullPath}');
      debugPrint('Firebase buyer UID: $userId');
      debugPrint('Proof content type: $contentType, bytes: ${bytes.length}');

      await storageRef.putData(

        bytes,

        SettableMetadata(

          contentType: contentType,

          customMetadata: {

            'buyerUid': userId,

            'orderId': widget.orderId,

          },

        ),

      );



      // Backend validates the proof and order.

      final callable = FirebaseFunctions.instanceFor(

        region: 'us-central1',

      ).httpsCallable('submitProcurementPayment');



      await callable.call({

        'orderId': widget.orderId,

        'transactionReference': _utr.text.trim(),

        'proofStoragePath': path,

      });



      if (!mounted) return;



      setState(() {

        _file = null;

      });



      message('Payment proof submitted for verification.');

    } on FirebaseFunctionsException catch (e) {

      message('${e.code}: ${e.message ?? "Submission failed"}');

    } on FirebaseException catch (e) {

      message('${e.code}: ${e.message ?? "Firebase error"}');

    } catch (e) {

      message('Unable to submit payment: $e');

    } finally {

      if (mounted) {

        setState(() => _submitting = false);

      }

    }

  }



  Widget sectionTitle(String title, IconData icon) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 14),

      child: Row(

        children: [

          Icon(icon, color: violet, size: 22),

          const SizedBox(width: 10),

          Expanded(

            child: Text(

              title,

              style: const TextStyle(

                color: navy,

                fontSize: 17,

                fontWeight: FontWeight.w800,

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget card(Widget child) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(20),

      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(

          color: const Color(0xFFEBEEF6),

        ),

      ),

      child: child,

    );

  }



  Widget amountRow(String label, dynamic value) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: Row(

        children: [

          Expanded(

            child: Text(

              label,

              style: const TextStyle(color: muted),

            ),

          ),

          Text(

            money(value),

            style: const TextStyle(

              color: navy,

              fontWeight: FontWeight.w700,

            ),

          ),

        ],

      ),

    );

  }



  Widget invoiceSummary(Map<String, dynamic> data) {

    final invoiceNo =

        data['invoiceNumber']?.toString() ?? '-';



    final items = data['lineItems'] is List

        ? data['lineItems'] as List

        : <dynamic>[];



    return card(

      Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          sectionTitle(

            'Invoice Summary',

            Icons.receipt_long_rounded,

          ),

          Text(

            invoiceNo,

            style: const TextStyle(

              fontSize: 19,

              fontWeight: FontWeight.w800,

              color: navy,

            ),

          ),

          const SizedBox(height: 6),

          Text(

            'Order: ${widget.orderId}',

            style: const TextStyle(

              color: muted,

              fontSize: 12,

            ),

          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 10),



          for (final raw in items)

            if (raw is Map)

              Padding(

                padding: const EdgeInsets.only(bottom: 12),

                child: Row(

                  children: [

                    Expanded(

                      child: Text(

                        raw['description']?.toString() ?? 'Item',

                        style: const TextStyle(color: navy),

                      ),

                    ),

                    Text(

                      money(raw['amount']),

                      style: const TextStyle(

                        fontWeight: FontWeight.w700,

                      ),

                    ),

                  ],

                ),

              ),



          const Divider(),

          const SizedBox(height: 12),

          amountRow('Subtotal', data['subtotal']),

          amountRow('GST', data['taxAmount']),

          amountRow('Freight', data['freight']),

          const Divider(),

          const SizedBox(height: 12),

          Row(

            children: [

              const Expanded(

                child: Text(

                  'Total Payable',

                  style: TextStyle(

                    color: navy,

                    fontWeight: FontWeight.w800,

                    fontSize: 17,

                  ),

                ),

              ),

              Text(

                money(data['totalAmount']),

                style: const TextStyle(

                  color: violet,

                  fontWeight: FontWeight.w900,

                  fontSize: 23,

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }



  Widget paymentInstructions(Map<String, dynamic> data) {

    return card(

      Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          sectionTitle(

            'Supplier Payment Details',

            Icons.account_balance_outlined,

          ),

          Text(

            data['sellerName']?.toString() ?? 'Supplier',

            style: const TextStyle(

              color: navy,

              fontWeight: FontWeight.w800,

              fontSize: 16,

            ),

          ),

          const SizedBox(height: 12),

          SelectableText(

            data['paymentInstructions']?.toString().isNotEmpty == true

                ? data['paymentInstructions'].toString()

                : 'Supplier has not provided payment instructions.',

            style: const TextStyle(

              height: 1.6,

              color: Color(0xFF536079),

            ),

          ),

        ],

      ),

    );

  }



  Widget paymentForm(Map<String, dynamic> invoice) {

    return card(

      Form(

        key: _formKey,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            sectionTitle(

              'Submit Payment Proof',

              Icons.payments_outlined,

            ),

            const Text(

              'Pay the supplier using the provided instructions, '

              'then enter your transaction details.',

              style: TextStyle(

                color: muted,

                height: 1.6,

              ),

            ),

            const SizedBox(height: 20),

            TextFormField(

              controller: _utr,

              maxLength: 100,

              decoration: InputDecoration(

                labelText: 'Transaction / UTR Reference',

                prefixIcon:

                    const Icon(Icons.numbers, color: violet),

                filled: true,

                fillColor: bg,

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(14),

                  borderSide: BorderSide.none,

                ),

              ),

              validator: (value) {

                if (value == null || value.trim().isEmpty) {

                  return 'Enter your transaction reference';

                }

                return null;

              },

            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(

              onPressed: _submitting ? null : pickProof,

              icon: const Icon(Icons.cloud_upload_outlined),

              label: Text(

                _file == null

                    ? 'Upload Transaction Slip'

                    : _file!.name,

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

              ),

              style: OutlinedButton.styleFrom(

                minimumSize: const Size(double.infinity, 58),

                foregroundColor: violet,

                side: const BorderSide(color: violet),

                shape: RoundedRectangleBorder(

                  borderRadius: BorderRadius.circular(14),

                ),

              ),

            ),

            const SizedBox(height: 12),

            const Text(

              'Accepted: PDF, JPG, PNG · Maximum 8 MB',

              style: TextStyle(

                color: muted,

                fontSize: 12,

              ),

            ),

            const SizedBox(height: 22),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: FilledButton.icon(

                onPressed: _submitting

                    ? null

                    : () => submitPayment(invoice),

                style: FilledButton.styleFrom(

                  backgroundColor: violet,

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(15),

                  ),

                ),

                icon: _submitting

                    ? const SizedBox(

                        width: 18,

                        height: 18,

                        child: CircularProgressIndicator(

                          color: Colors.white,

                          strokeWidth: 2,

                        ),

                      )

                    : const Icon(Icons.verified_outlined),

                label: Text(

                  _submitting

                      ? 'Submitting...'

                      : 'Submit Payment Proof',

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget statusCard(String status) {

    final verified = status == 'verified';



    return card(

      Row(

        children: [

          Icon(

            verified

                ? Icons.verified_rounded

                : Icons.hourglass_top_rounded,

            color: verified

                ? Colors.green

                : Colors.orange,

            size: 32,

          ),

          const SizedBox(width: 14),

          Expanded(

            child: Column(

              crossAxisAlignment:

                  CrossAxisAlignment.start,

              children: [

                Text(

                  verified

                      ? 'Payment Verified'

                      : status == 'rejected'

                          ? 'Payment Requires Attention'

                          : 'Verification Pending',

                  style: const TextStyle(

                    color: navy,

                    fontWeight: FontWeight.w800,

                  ),

                ),

                const SizedBox(height: 5),

                Text(

                  verified

                      ? 'Supplier has confirmed receipt.'

                      : status == 'rejected'

                          ? 'Contact your supplier about the payment.'

                          : 'Your supplier is reviewing the payment.',

                  style: const TextStyle(

                    color: muted,

                    fontSize: 12,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    if (uid == null) {

      return const Scaffold(

        body: Center(

          child: Text('Please sign in first.'),

        ),

      );

    }



    return Scaffold(

      backgroundColor: bg,

      appBar: AppBar(

        title: const Text(

          'Invoice & Payment',

          style: TextStyle(fontWeight: FontWeight.w800),

        ),

        backgroundColor: bg,

        foregroundColor: navy,

        elevation: 0,

      ),

      body: StreamBuilder<

          DocumentSnapshot<Map<String, dynamic>>>(

        stream: invoiceRef.snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {

            return Center(

              child: SelectableText(

                'Invoice error: ${snapshot.error}',

              ),

            );

          }



          if (!snapshot.hasData) {

            return const Center(

              child: CircularProgressIndicator(),

            );

          }



          if (!snapshot.data!.exists) {

            return const Center(

              child: Text('Invoice not issued yet.'),

            );

          }



          final invoice = snapshot.data!.data()!;



          if (invoice['buyerUid'] != uid) {

            return const Center(

              child: Text('Access denied.'),

            );

          }



          return StreamBuilder<

              DocumentSnapshot<Map<String, dynamic>>>(

            stream: FirebaseFirestore.instance

                .collection('payments')

                .doc(widget.orderId)

                .snapshots(),

            builder: (context, paymentSnapshot) {

              if (paymentSnapshot.hasError) {

                return Center(

                  child: SelectableText(

                    'Payment error: ${paymentSnapshot.error}',

                  ),

                );

              }



              if (!paymentSnapshot.hasData) {

                return const Center(

                  child: CircularProgressIndicator(),

                );

              }



              final payment =

                  paymentSnapshot.data!.data();



              final status =

                  payment?['verificationStatus']

                          ?.toString() ??

                      'not_submitted';



              return Center(

                child: ConstrainedBox(

                  constraints:

                      const BoxConstraints(maxWidth: 800),

                  child: ListView(

                    padding: const EdgeInsets.fromLTRB(

                      18, 14, 18, 45,

                    ),

                    children: [

                      Container(

                        padding: const EdgeInsets.all(25),

                        margin:

                            const EdgeInsets.only(bottom: 20),

                        decoration: BoxDecoration(

                          gradient: const LinearGradient(

                            colors: [

                              navy,

                              Color(0xFF5149BC),

                            ],

                          ),

                          borderRadius:

                              BorderRadius.circular(24),

                        ),

                        child: const Column(

                          crossAxisAlignment:

                              CrossAxisAlignment.start,

                          children: [

                            Icon(

                              Icons.shield_outlined,

                              color: Colors.white,

                              size: 32,

                            ),

                            SizedBox(height: 15),

                            Text(

                              'Review. Pay. Confirm.',

                              style: TextStyle(

                                color: Colors.white,

                                fontSize: 25,

                                fontWeight: FontWeight.w800,

                              ),

                            ),

                            SizedBox(height: 8),

                            Text(

                              'Your order invoice and payment '

                              'information, in one place.',

                              style: TextStyle(

                                color: Color(0xFFDDE1FA),

                                height: 1.5,

                              ),

                            ),

                          ],

                        ),

                      ),

                      invoiceSummary(invoice),

                      paymentInstructions(invoice),

                      if (payment == null &&

                          invoice['status'] == 'issued')

                        paymentForm(invoice)

                      else if (payment != null)

                        statusCard(status)

                      else

                        statusCard('pending'),

                    ],

                  ),

                ),

              );

            },

          );

        },

      ),

    );

  }

}
