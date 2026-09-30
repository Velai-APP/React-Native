import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium, live view of the signed-in user's saved brand-based usernames.
/// No domain or email-provider information is displayed.
/// Compatible with both selectedUsernames and legacy selectedEmails records.
class SavedBusinessEmailsScreen extends StatefulWidget {
  const SavedBusinessEmailsScreen({super.key});

  @override
  State<SavedBusinessEmailsScreen> createState() =>
      _SavedBusinessEmailsScreenState();
}

class _SavedBusinessEmailsScreenState extends State<SavedBusinessEmailsScreen> {
  static const _navy = Color(0xFF14234D);
  static const _blue = Color(0xFF315CF5);
  static const _purple = Color(0xFF8156E9);
  static const _ink = Color(0xFF17233D);
  static const _muted = Color(0xFF71809A);
  static const _canvas = Color(0xFFF4F7FD);
  static const _border = Color(0xFFE6EBF4);

  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _expanded = {};
  String? _deletingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
  }

  String _username(Object? input) {
    if (input == null) return '';
    // Normalize legacy full addresses to usernames only.
    return input.toString().trim().split('@').first.trim();
  }

  List<String> _names(Map<String, dynamic> data) {
    final raw = data['selectedUsernames'] ?? data['selectedEmails'];
    final found = <String>[];
    if (raw is List) {
      for (final value in raw) {
        final name = value is Map
            ? _username(value['username'] ?? value['localPart'] ?? value['email'])
            : _username(value);
        if (name.isNotEmpty && !found.contains(name)) found.add(name);
      }
    }
    if (found.isEmpty && data['selectedSuggestions'] is List) {
      for (final value in data['selectedSuggestions'] as List) {
        if (value is! Map) continue;
        final name = _username(value['username'] ?? value['localPart'] ?? value['email']);
        if (name.isNotEmpty && !found.contains(name)) found.add(name);
      }
    }
    return found;
  }

  DateTime? _updated(Map<String, dynamic> data) {
    final value = data['updatedAt'] ?? data['createdAt'];
    return value is Timestamp ? value.toDate() : null;
  }

  String _date(DateTime? value) {
    if (value == null) return 'Saved selection';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = value.toLocal();
    return 'Updated ${local.day} ${months[local.month - 1]} ${local.year}';
  }

  Future<void> _copy(String username) async {
    await Clipboard.setData(ClipboardData(text: username));
    _message('Copied $username');
  }

  Future<void> _delete(
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final name = document.data()['businessName']?.toString() ?? 'this business';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Delete saved names?'),
        content: Text('Remove your saved email names for $name? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC3545)),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _deletingId = document.id);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('businessEmailSelections')
          .doc(document.id)
          .delete();
      _expanded.remove(document.id);
      _message('Saved names deleted');
    } on FirebaseException catch (error) {
      _message(error.message ?? 'Could not delete the saved names.');
    } catch (_) {
      _message('Could not delete the saved names.');
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        title: const Text('Saved Email Names',
            style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: _ink),
        elevation: 0,
      ),
      body: user == null
          ? _centerState(
              Icons.lock_outline_rounded,
              'Sign in to view your names',
              'Your saved business email names are private to your account.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('businessEmailSelections')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _centerState(
                    Icons.cloud_off_rounded,
                    'Unable to load your saved names',
                    'Check your internet connection and Firestore security rules.',
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _blue));
                }

                final all = snapshot.data!.docs.toList()
                  ..sort((a, b) =>
                      (_updated(b.data()) ?? DateTime.fromMillisecondsSinceEpoch(0))
                          .compareTo(_updated(a.data()) ??
                              DateTime.fromMillisecondsSinceEpoch(0)));
                final count = all.fold<int>(0, (sum, doc) => sum + _names(doc.data()).length);
                final query = _query.toLowerCase();
                final filtered = all.where((doc) {
                  final data = doc.data();
                  return (data['businessName']?.toString().toLowerCase() ?? '')
                          .contains(query) ||
                      _names(data).any((name) => name.toLowerCase().contains(query));
                }).toList();

                return RefreshIndicator(
                  color: _blue,
                  onRefresh: () async {
                    // Firestore snapshots are already live; this forces a server check.
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('businessEmailSelections')
                          .get(const GetOptions(source: Source.server));
                    } catch (_) {
                      _message('Could not refresh. Showing available saved names.');
                    }
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(isWide ? 32 : 17, 22, isWide ? 32 : 17, 38),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _hero(all.length, count, isWide),
                              const SizedBox(height: 24),
                              _searchField(),
                              const SizedBox(height: 23),
                              Row(
                                children: [
                                  const Text('Your collections',
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: _ink)),
                                  const Spacer(),
                                  Text('${filtered.length} business${filtered.length == 1 ? '' : 'es'}',
                                      style: const TextStyle(color: _muted, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (all.isEmpty)
                                _emptyCard(
                                    Icons.bookmarks_outlined,
                                    'Nothing saved yet',
                                    'Generate email names for a business, select your favourites and save them.'),
                              if (all.isNotEmpty && filtered.isEmpty)
                                _emptyCard(
                                    Icons.search_off_rounded,
                                    'No matching names',
                                    'Try another business name or username.'),
                              ...filtered.map((doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _businessCard(user.uid, doc),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _hero(int businesses, int names, bool wide) {
    return Container(
      padding: EdgeInsets.all(wide ? 30 : 23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, Color(0xFF3845A9), _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [BoxShadow(
          color: _purple.withOpacity(0.19),
          blurRadius: 26,
          offset: const Offset(0, 11),
        )],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -60,
            child: Container(
              height: 165,
              width: 165,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.065),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 53,
                width: 53,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.bookmarks_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 19),
              const Text('Your brand identity,\nbeautifully organised.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      height: 1.13,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 9),
              Text('All the names you saved, together in one place.',
                  style: TextStyle(color: Colors.white.withOpacity(0.77), fontSize: 13)),
              const SizedBox(height: 23),
              Row(
                children: [
                  _statPill(Icons.business_rounded, '$businesses',
                      businesses == 1 ? 'Business' : 'Businesses'),
                  const SizedBox(width: 11),
                  _statPill(Icons.alternate_email_rounded, '$names',
                      names == 1 ? 'Saved name' : 'Saved names'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String count, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.13),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 21),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(count,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900)),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _searchField() => TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        decoration: InputDecoration(
          hintText: 'Search businesses or saved names',
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _blue),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: _blue, width: 1.4),
          ),
        ),
      );

  Widget _businessCard(
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final names = _names(data);
    final business = data['businessName']?.toString() ?? 'Your business';
    final recommended = _username(data['recommendedUsername'] ?? data['recommendedEmail']);
    final expanded = _expanded.contains(document.id);
    final visible = expanded ? names : names.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(
          color: _navy.withOpacity(0.035),
          blurRadius: 17,
          offset: const Offset(0, 5),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEAF0FF), Color(0xFFF1EAFE)]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      business.trim().isEmpty ? '?' : business.trim()[0].toUpperCase(),
                      style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: _blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(business,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(_date(_updated(data)),
                          style: const TextStyle(fontSize: 11, color: _muted)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Collection options',
                  icon: const Icon(Icons.more_horiz_rounded, color: _muted),
                  enabled: _deletingId != document.id,
                  onSelected: (choice) {
                    if (choice == 'delete') _delete(uid, document);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded, color: Color(0xFFDC3545), size: 19),
                        SizedBox(width: 8),
                        Text('Delete collection'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              _badge(Icons.bookmark_added_outlined, '${names.length} saved'),
              if (recommended.isNotEmpty) ...[
                const SizedBox(width: 8),
                _badge(Icons.auto_awesome_rounded, 'AI pick'),
              ],
            ]),
            const SizedBox(height: 14),
            if (_deletingId == document.id)
              const LinearProgressIndicator(color: _blue),
            if (names.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No saved names in this collection.',
                    style: TextStyle(color: _muted)),
              ),
            ...visible.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _nameTile(name, recommended == name),
                )),
            if (names.length > 3) ...[
              const SizedBox(height: 2),
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    if (expanded) {
                      _expanded.remove(document.id);
                    } else {
                      _expanded.add(document.id);
                    }
                  }),
                  icon: Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                  label: Text(expanded ? 'Show less' : 'Show all ${names.length} names'),
                  style: TextButton.styleFrom(foregroundColor: _blue),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FD),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: _blue),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: _navy, fontWeight: FontWeight.w700, fontSize: 11)),
        ]),
      );

  Widget _nameTile(String name, bool recommended) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: recommended ? const Color(0xFFEDF8F5) : const Color(0xFFF8FAFE),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: recommended ? const Color(0xFFC7EBDF) : _border),
        ),
        child: Row(children: [
          Icon(Icons.alternate_email_rounded,
              size: 19, color: recommended ? const Color(0xFF07946C) : _blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _ink, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          if (recommended) ...[
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFF0B956E)),
            const SizedBox(width: 4),
          ],
          IconButton(
            tooltip: 'Copy username',
            constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
            icon: const Icon(Icons.copy_rounded, size: 17, color: _muted),
            onPressed: () => _copy(name),
          ),
        ]),
      );

  Widget _emptyCard(IconData icon, String title, String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _border),
        ),
        child: Column(children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFEDF0FF),
            radius: 35,
            child: Icon(icon, size: 34, color: _blue),
          ),
          const SizedBox(height: 15),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, height: 1.45, fontSize: 12)),
        ]),
      );

  Widget _centerState(IconData icon, String title, String message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _emptyCard(icon, title, message),
          ),
        ),
      );
}
