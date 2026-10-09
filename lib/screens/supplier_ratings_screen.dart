import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupplierRatingsScreen extends StatelessWidget {
  const SupplierRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Sign in as a supplier.')));
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Ratings & Feedback')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('supplierReviews')
            .where('supplierId', isEqualTo: uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: SelectableText('Unable to load reviews: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = [...snapshot.data!.docs];
          docs.sort((a, b) {
            final at = a.data()['createdAt'] as Timestamp?;
            final bt = b.data()['createdAt'] as Timestamp?;
            return (bt?.millisecondsSinceEpoch ?? 0).compareTo(at?.millisecondsSinceEpoch ?? 0);
          });
          if (docs.isEmpty) return const Center(child: Text('No buyer reviews yet.'));
          final total = docs.fold<int>(0, (sum, d) => sum + ((d.data()['rating'] as num?)?.toInt() ?? 0));
          final average = total / docs.length;
          return ListView(padding: const EdgeInsets.all(16), children: [
            Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              Text('${average.toStringAsFixed(1)} / 5', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 30)),
              Text('${docs.length} verified order review(s)'),
            ]))),
            ...docs.map((doc) {
              final review = doc.data();
              final rating = (review['rating'] as num?)?.toInt() ?? 0;
              return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order: ${review['orderId'] ?? doc.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: List.generate(5, (i) => Icon(
                    i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 22, color: Colors.amber.shade700,
                  ))),
                  const SizedBox(height: 8),
                  Text((review['feedback'] ?? '').toString()),
                ],
              )));
            }),
          ]);
        },
      ),
    );
  }
}
