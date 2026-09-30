import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AdminGstRegistrationScreen extends StatelessWidget {
  final String applicationId;

  const AdminGstRegistrationScreen({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'GST Application',
        ),
        backgroundColor:
            const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('registrationApplications')
            .doc(applicationId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Application not found',
              ),
            );
          }

          final data =
              snapshot.data!.data()!;

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                data['legalName'] ??
                    data['tradeName'] ??
                    'GST Registration',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Status: ${data['status'] ?? 'submitted'}',
              ),

              const SizedBox(height: 20),

              // GST details here

              ElevatedButton(
                onPressed: () {
                  // Open status update
                },
                child: const Text(
                  'Update Application Status',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}