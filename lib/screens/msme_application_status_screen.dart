import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MsmeApplicationStatusScreen extends StatelessWidget {
  final String applicationId;

  const MsmeApplicationStatusScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'MSME Application',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('registrationApplications')
            .doc(applicationId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();

          if (data == null) {
            return const Center(child: Text('Application not found'));
          }

          final status = data['status'] ?? 'submitted';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 42,
                      ),

                      const SizedBox(height: 14),

                      Text(
                        data['enterpriseName'] ?? 'MSME Application',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        _statusTitle(status),
                        style: TextStyle(color: Colors.white.withOpacity(.80)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _statusTimeline(status),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusTimeline(String currentStatus) {
    const stages = [
      'submitted',
      'underReview',
      'readyForFiling',
      'filed',
      'approved',
    ];

    final currentIndex = stages.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final completed = index <= currentIndex;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: completed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      completed ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),

                  if (index != stages.length - 1)
                    Container(
                      height: 55,
                      width: 2,
                      color: completed
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE5E7EB),
                    ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(
                    _statusTitle(stages[index]),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: completed
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'submitted':
        return 'Application Submitted';

      case 'underReview':
        return 'Under Review';

      case 'documentsPending':
        return 'Documents Pending';

      case 'readyForFiling':
        return 'Ready for Filing';

      case 'filed':
        return 'Filed with Udyam';

      case 'approved':
        return 'Registration Completed';

      case 'rejected':
        return 'Action Required';

      default:
        return 'Application Processing';
    }
  }
}
