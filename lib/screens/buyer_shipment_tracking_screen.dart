
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import 'buyer_delivery_confirmation_screen.dart';

class BuyerShipmentTrackingScreen extends StatelessWidget {
  final String orderId;

  const BuyerShipmentTrackingScreen({
    super.key,
    required this.orderId,
  });

  static const Color navy = Color(0xFF151D43);
  static const Color violet = Color(0xFF6264E8);
  static const Color background = Color(0xFFF6F8FC);

  String _date(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate().toLocal();

      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year}';
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        final d = parsed.toLocal();
        return '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/'
            '${d.year}';
      }
    }

    return 'Not provided';
  }

  Widget _detail(String heading, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value.trim().isEmpty ? 'Not provided' : value,
            style: const TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slip(String storagePath) {
    if (storagePath.trim().isEmpty) {
      return const Text('No dispatch slip attached.');
    }

    // Backward compatibility for older records containing
    // a reference number rather than a Storage object path.
    final path = storagePath.trim();

    if (!path.startsWith('shipmentSlips/')) {
      return SelectableText(
        'Delivery document reference: $path',
      );
    }

    final ref = FirebaseStorage.instance.ref(path);
    final isPdf = path.toLowerCase().endsWith('.pdf');

    return FutureBuilder<Uint8List?>(
      future: ref.getData(8 * 1024 * 1024 + 1),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SelectableText(
            'Unable to open slip: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bytes = snapshot.data;

        if (bytes == null || bytes.isEmpty) {
          return const Text(
            'Dispatch slip is empty or unavailable.',
          );
        }

        if (isPdf) {
          return SizedBox(
            height: 480,
            child: PdfPreview(
              build: (_) async => bytes,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              pdfFileName: 'dispatch-slip-$orderId.pdf',
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, error, stackTrace) =>
                Text('Unable to display image: $error'),
          ),
        );
      },
    );
  }

  Widget _panel({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _deliveryAction(
    BuildContext context,
    String status,
    Map<String, dynamic> shipment,
  ) {
    if (status == 'order_completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F7F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.verified_rounded,
              color: Color(0xFF13866C),
              size: 30,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delivery confirmed. Order completed.',
                style: TextStyle(
                  color: Color(0xFF13866C),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status != 'fulfilment_submitted' ||
        shipment['status'] != 'submitted') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Have you received the goods or service?',
          style: TextStyle(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Confirm only after you have physically received '
          'the goods or verified service completion.',
          style: TextStyle(
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BuyerDeliveryConfirmationScreen(
                  orderId: orderId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text(
            'Confirm Delivery & Rate Supplier',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: violet,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 17,
              horizontal: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Sign in as the buyer to view shipment.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Shipment Tracking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: background,
        foregroundColor: navy,
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.hasError) {
            return Center(
              child: SelectableText(
                'Order error: ${orderSnapshot.error}',
              ),
            );
          }

          if (!orderSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final order = orderSnapshot.data!.data();

          if (order == null) {
            return const Center(
              child: Text('Order not found.'),
            );
          }

          if (order['buyerUid'] != uid) {
            return const Center(
              child: Text(
                'Only the assigned buyer can view this shipment.',
              ),
            );
          }

          final orderStatus =
              (order['status'] ?? '').toString();

          return StreamBuilder<
              DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('fulfilments')
                .doc(orderId)
                .snapshots(),
            builder: (context, fulfilmentSnapshot) {
              if (fulfilmentSnapshot.hasError) {
                return Center(
                  child: SelectableText(
                    'Shipment error: ${fulfilmentSnapshot.error}',
                  ),
                );
              }

              if (!fulfilmentSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final shipment =
                  fulfilmentSnapshot.data!.data();

              if (shipment == null) {
                return const Center(
                  child: Text(
                    'Supplier has not submitted shipment details yet.',
                  ),
                );
              }

              if (shipment['buyerUid'] != uid ||
                  shipment['supplierId'] != order['supplierId']) {
                return const Center(
                  child: Text('Access denied.'),
                );
              }

              final type =
                  (shipment['fulfilmentType'] ?? 'shipment')
                      .toString();

              final slipPath =
                  (shipment['deliveryProofReference'] ?? '')
                      .toString();

              return Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 780),
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              navy,
                              Color(0xFF5052B4),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Icon(
                              type == 'service'
                                  ? Icons.handyman_outlined
                                  : Icons.local_shipping_outlined,
                              size: 35,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              orderStatus == 'order_completed'
                                  ? 'Order Completed'
                                  : type == 'service'
                                      ? 'Service Fulfilment'
                                      : 'Your Order Is Dispatched',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 23,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Order: $orderId',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Status: ${orderStatus.replaceAll('_', ' ')}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      _panel(
                        title: type == 'service'
                            ? 'Service Details'
                            : 'Shipment Details',
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (type == 'shipment') ...[
                              _detail(
                                'Courier / Transporter',
                                '${shipment['carrierName'] ?? ''}',
                              ),
                              _detail(
                                'Tracking / AWB / LR Number',
                                '${shipment['trackingNumber'] ?? ''}',
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final tracking =
                                      (shipment['trackingNumber'] ??
                                              '')
                                          .toString();

                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: tracking,
                                    ),
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Tracking number copied',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.copy_rounded,
                                ),
                                label: const Text(
                                  'Copy Tracking Number',
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            _detail(
                              type == 'service'
                                  ? 'Completion Date'
                                  : 'Dispatch Date',
                              _date(shipment['dispatchDate']),
                            ),

                            if (type == 'shipment')
                              _detail(
                                'Expected Delivery',
                                _date(
                                  shipment['expectedDeliveryDate'],
                                ),
                              ),

                            _detail(
                              'Supplier Remarks',
                              '${shipment['notes'] ?? ''}',
                            ),
                          ],
                        ),
                      ),

                      _panel(
                        title: 'Dispatch Slip / Delivery Document',
                        child: _slip(slipPath),
                      ),

                      _panel(
                        title: 'Delivery Confirmation',
                        child: _deliveryAction(
                          context,
                          orderStatus,
                          shipment,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Shipment submission does not '
                        'automatically confirm delivery. '
                        'The buyer must confirm receipt.',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          height: 1.5,
                        ),
                      ),
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
