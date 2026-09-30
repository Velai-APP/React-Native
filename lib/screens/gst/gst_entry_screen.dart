import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../gst_dashboard_screen.dart';
import 'gst_profile_screen.dart';

class GstEntryScreen extends StatefulWidget {
  const GstEntryScreen({super.key});

  @override
  State<GstEntryScreen> createState() =>
      _GstEntryScreenState();
}

class _GstEntryScreenState extends State<GstEntryScreen> {
  bool loading = true;

  String projectId = '';
  String uid = '';
  String email = '';
  String status = '';

  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      setState(() {
        loading = true;
        status = '';
      });

      final User? user =
          FirebaseAuth.instance.currentUser;

      projectId =
          Firebase.app().options.projectId;

      if (user == null) {
        setState(() {
          loading = false;
          status =
              'ERROR: FirebaseAuth.currentUser is null';
        });

        return;
      }

      uid = user.uid;
      email = user.email ?? '';

      debugPrint('==============================');
      debugPrint('FIREBASE PROJECT: $projectId');
      debugPrint('AUTH UID: $uid');
      debugPrint('EMAIL: $email');

      final FirebaseFirestore firestore =
          FirebaseFirestore.instance;

      final String path =
          'users/$uid/gstProfiles';

      debugPrint('QUERY PATH: $path');

      final QuerySnapshot<Map<String, dynamic>>
          snapshot =
          await firestore
              .collection('users')
              .doc(uid)
              .collection('gstProfiles')
              .get(
        const GetOptions(
          source: Source.server,
        ),
      );

      debugPrint(
        'DOCUMENT COUNT: ${snapshot.docs.length}',
      );

      for (final doc in snapshot.docs) {
        debugPrint('DOC ID: ${doc.id}');
        debugPrint('DOC DATA: ${doc.data()}');
      }

      if (snapshot.docs.isEmpty) {
        setState(() {
          loading = false;

          status = '''
NO GST PROFILE FOUND BY APP

Firebase Project:
$projectId

Authenticated UID:
$uid

Path queried:
users/$uid/gstProfiles

Firestore returned:
0 documents

Do NOT create another profile yet.
Compare the UID and project ID above with Firebase Console.
''';
        });

        return;
      }

      final QueryDocumentSnapshot<
          Map<String, dynamic>> document =
          snapshot.docs.first;

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        document.data(),
      );

      data['gstin'] ??= document.id;

      debugPrint('PROFILE FOUND!');
      debugPrint('GSTIN: ${data['gstin']}');

      if (!mounted) return;

      setState(() {
        profile = data;
        loading = false;
        status = 'PROFILE FOUND';
      });
    } on FirebaseException catch (e) {
      debugPrint(
        'FIREBASE ERROR: ${e.code}',
      );

      debugPrint(
        'MESSAGE: ${e.message}',
      );

      if (!mounted) return;

      setState(() {
        loading = false;

        status = '''
FIREBASE ERROR

Project:
$projectId

UID:
$uid

Code:
${e.code}

Message:
${e.message}
''';
      });
    } catch (e) {
      debugPrint('ERROR: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
        status = 'ERROR:\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FB),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF166534),
              ),
              SizedBox(height: 20),
              Text(
                'Checking GST profile...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =====================================================
    // PROFILE FOUND
    // =====================================================

    if (profile != null) {
      return GstDashboardScreen(
        gstProfile: profile!,
      );
    }

    // =====================================================
    // DEBUG PAGE
    // =====================================================

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'GST Connection Check',
        ),
        backgroundColor:
            const Color(0xFF166534),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _infoCard(
              'Firebase Project',
              projectId,
              Icons.cloud_outlined,
            ),

            const SizedBox(height: 12),

            _infoCard(
              'Authenticated UID',
              uid,
              Icons.person_outline,
            ),

            const SizedBox(height: 12),

            _infoCard(
              'Signed-in Email',
              email,
              Icons.email_outlined,
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color:
                      Colors.orange.shade200,
                ),
              ),

              child: SelectableText(
                status,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton.icon(
                onPressed: _checkProfile,

                icon: const Icon(
                  Icons.refresh,
                ),

                label: const Text(
                  'Check Firestore Again',
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF166534,
                  ),
                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const GstProfileScreen(),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.add_business,
                ),

                label: const Text(
                  'Create GST Profile',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.04),
            blurRadius: 12,
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color:
                  const Color(0xFFF0FDF4),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color:
                  const Color(0xFF166534),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                SelectableText(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}