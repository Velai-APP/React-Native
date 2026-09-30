import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'business_email_suggestions_screen.dart';
import 'saved_business_emails_screen.dart';

/// Brand-based username generation with a live, user-specific saved section.
/// Requires: firebase_auth, cloud_firestore, cloud_functions.
class BusinessEmailScreen extends StatefulWidget {
  const BusinessEmailScreen({super.key});

  @override
  State<BusinessEmailScreen> createState() => _BusinessEmailScreenState();
}

class _BusinessEmailScreenState extends State<BusinessEmailScreen> {
  static const _navy = Color(0xFF111D48);
  static const _blue = Color(0xFF315CF5);
  static const _purple = Color(0xFF8055E9);
  static const _ink = Color(0xFF19233D);
  static const _muted = Color(0xFF71809B);
  static const _bg = Color(0xFFF5F7FD);

  final _businessController = TextEditingController();
  bool _generating = false;

  @override
  void dispose() {
    _businessController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  Future<void> _generate() async {
    if (_generating) return;
    final name = _businessController.text.trim();
    if (name.isEmpty) {
      _toast('Enter your business name first.');
      return;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _toast('Sign in to generate and save your email names.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _generating = true);
    try {
      final fn = FirebaseFunctions.instanceFor(region: 'asia-south1')
          .httpsCallable('generateBusinessEmails',
              options: HttpsCallableOptions(timeout: const Duration(minutes: 2)));
      final response = await fn.call(<String, dynamic>{'businessName': name});
      if (response.data is! Map) throw StateError('Unexpected server response');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BusinessEmailSuggestionsScreen(result: data),
      ));
      // The saved section below updates automatically via Firestore snapshots.
    } on FirebaseFunctionsException catch (e) {
      if (mounted) _toast(e.message ?? 'Could not generate suggestions.');
    } catch (e) {
      debugPrint('Email suggestions error: $e');
      if (mounted) _toast('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text('Business Email Studio',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            tooltip: 'View all saved email names',
            icon: const Icon(Icons.bookmark_border_rounded, color: _navy),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const SavedBusinessEmailsScreen(),
            )),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(desktop ? 32 : 18, 22, desktop ? 32 : 18, 34),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _hero(),
              const SizedBox(height: 22),
              _generatorCard(),
              const SizedBox(height: 32),
              _savedSection(),
              const SizedBox(height: 22),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navy, Color(0xFF3D368F), _purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [BoxShadow(
              color: _purple.withOpacity(.17),
              blurRadius: 26,
              offset: const Offset(0, 12))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.alternate_email_rounded, color: Colors.white, size: 29),
          ),
          const SizedBox(height: 19),
          const Text('Your brand. Your email identity.',
              style: TextStyle(color: Colors.white, fontSize: 26,
                  fontWeight: FontWeight.w900, height: 1.15)),
          const SizedBox(height: 9),
          Text('Discover professional usernames based on your business name, '
              'then keep your favorites in one place.',
              style: TextStyle(color: Colors.white.withOpacity(.83), height: 1.5)),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(.12),
                borderRadius: BorderRadius.circular(30)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 15),
              SizedBox(width: 7),
              Text('Brand-based names only  •  No domains',
                  style: TextStyle(color: Colors.white, fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      );

  Widget _generatorCard() => Container(
        padding: const EdgeInsets.all(22),
        decoration: _surface(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create new suggestions', style: TextStyle(
              fontSize: 19, color: _ink, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Just enter the business name. No other details needed.',
              style: TextStyle(fontSize: 13, color: _muted)),
          const SizedBox(height: 23),
          const Text('BUSINESS NAME', style: TextStyle(
              fontSize: 11, letterSpacing: .8, color: _muted,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          TextField(
            controller: _businessController,
            onSubmitted: (_) => _generate(),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'e.g. Vesko',
              prefixIcon: const Icon(Icons.storefront_outlined, color: _blue),
              filled: true,
              fillColor: _bg,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: _blue, width: 1.5)),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_blue, _purple]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generate,
                icon: _generating
                    ? const SizedBox(height: 17, width: 17,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            color: Colors.white))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_generating ? 'Generating...' : 'Suggest email names',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Example: vesko  •  hellovesko  •  veskosupport',
              style: TextStyle(fontSize: 12, color: _muted)),
        ]),
      );

  Widget _savedSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EFFF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.bookmarks_rounded, color: _blue),
            ),
            const SizedBox(width: 11),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My saved email names', style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w900, color: _ink)),
                SizedBox(height: 3),
                Text('Only visible to your signed-in account',
                    style: TextStyle(fontSize: 12, color: _muted)),
              ],
            )),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const SavedBusinessEmailsScreen(),
              )),
              child: const Text('View all  →',
                  style: TextStyle(color: _blue, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 15),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, auth) {
              final user = auth.data;
              if (user == null) {
                return _empty('Sign in to view your saved names',
                    'Your personal collection will appear here.');
              }
              final stream = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('businessEmailSelections')
                  .snapshots();
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                key: ValueKey(user.uid),
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _empty('Unable to load your saved names',
                        'Check your Firestore security rules and connection.');
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final docs = snapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final at = a.data()['updatedAt'];
                      final bt = b.data()['updatedAt'];
                      final aDate = at is Timestamp ? at.millisecondsSinceEpoch : 0;
                      final bDate = bt is Timestamp ? bt.millisecondsSinceEpoch : 0;
                      return bDate.compareTo(aDate);
                    });
                  if (docs.isEmpty) {
                    return _empty('No saved names yet',
                        'Generate suggestions and save your favorites to see them here.');
                  }
                  return Column(children: [
                    ...docs.take(3).map((doc) => _savedCard(doc.data())),
                    if (docs.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.grid_view_rounded),
                          label: Text('View all ${docs.length} businesses'),
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => const SavedBusinessEmailsScreen(),
                          )),
                        ),
                      ),
                  ]);
                },
              );
            },
          ),
        ],
      );

  Widget _savedCard(Map<String, dynamic> data) {
    // Supports both the current selectedUsernames field and the earlier
    // selectedEmails field. Display usernames, never an @domain suffix.
    final raw = data['selectedUsernames'] ?? data['selectedEmails'];
    final usernames = raw is List
        ? raw.whereType<String>()
            .map((value) => value.split('@').first.trim())
            .where((value) => value.isNotEmpty)
            .toSet().toList()
        : <String>[];
    final name = data['businessName']?.toString().trim();
    final business = name == null || name.isEmpty ? 'My business' : name;
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(19),
      decoration: _surface(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            height: 46,
            width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE6EDFF), Color(0xFFF1E9FF)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(business.characters.first.toUpperCase(),
                style: const TextStyle(color: _blue, fontSize: 21,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(business, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _ink, fontWeight: FontWeight.w900,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text('${usernames.length} saved ${usernames.length == 1 ? 'name' : 'names'}',
                style: const TextStyle(color: _muted, fontSize: 12)),
          ])),
          const Icon(Icons.verified_user_outlined, color: Color(0xFF12A67A), size: 21),
        ]),
        const SizedBox(height: 16),
        if (usernames.isEmpty)
          const Text('No usernames in this selection.',
              style: TextStyle(color: _muted))
        else
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: usernames.map((value) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                border: Border.all(color: const Color(0xFFE0E8FF)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.alternate_email, size: 14, color: _blue),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(
                    fontSize: 12.5, color: _navy, fontWeight: FontWeight.w700)),
              ]),
            )).toList(),
          ),
      ]),
    );
  }

  Widget _empty(String title, String description) => Container(
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        decoration: _surface(),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_unread_outlined,
                color: _blue, size: 29),
          ),
          const SizedBox(height: 13),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: _ink,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(description, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _muted, height: 1.5)),
        ]),
      );

  BoxDecoration _surface() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: [BoxShadow(
          color: _navy.withOpacity(.035),
          blurRadius: 20,
          offset: const Offset(0, 6),
        )],
      );
}
