import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sop_preview_screen.dart';

class MySopsScreen extends StatefulWidget {
  const MySopsScreen({super.key});

  @override
  State<MySopsScreen> createState() => _MySopsScreenState();
}

class _MySopsScreenState extends State<MySopsScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            _buildSearch(),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('sops')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _errorState(snapshot.error.toString());
                  }

                  var documents = snapshot.data?.docs ?? [];

                  documents = documents.where((doc) {
                    final data = doc.data();

                    final title = _getTitle(data).toLowerCase();

                    return title.contains(searchText.toLowerCase());
                  }).toList();

                  documents.sort((a, b) {
                    final dateA = _getDate(a.data());

                    final dateB = _getDate(b.data());

                    return dateB.compareTo(dateA);
                  });

                  if (documents.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 30),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return _sopCard(documents[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My SOPs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your saved procedures',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),

          Container(
            height: 47,
            width: 47,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.11),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.folder_copy_outlined,
              color: Color(0xFFE9D5FF),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 15),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search your SOPs...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF7C3AED),
          ),
          suffixIcon: searchText.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      searchText = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE7E9EF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.4),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SOP CARD
  // ============================================================

  Widget _sopCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final title = _getTitle(data);
    final department = _getDepartment(data);
    final date = _getDate(data);

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () => _openSop(data),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: const Color(0xFFE7E9EF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3E8FF), Color(0xFFEDE9FE)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: Color(0xFF7C3AED),
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.account_tree_outlined,
                          size: 13,
                          color: Color(0xFF7C3AED),
                        ),

                        const SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            department,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: Color(0xFF9CA3AF),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          _formatDate(date),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                height: 37,
                width: 37,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F3FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF7C3AED),
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPEN SOP
  // ============================================================

  void _openSop(Map<String, dynamic> data) {
    Map<String, dynamic> sop;
    Map<String, dynamic> inputData;

    if (data['sop'] is Map) {
      sop = Map<String, dynamic>.from(data['sop']);
    } else {
      sop = Map<String, dynamic>.from(data);
    }

    if (data['inputData'] is Map) {
      inputData = Map<String, dynamic>.from(data['inputData']);
    } else {
      inputData = Map<String, dynamic>.from(data);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SopPreviewScreen(sop: sop, inputData: inputData),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _getTitle(Map<String, dynamic> data) {
    if (data['title'] != null) {
      return data['title'].toString();
    }

    if (data['inputData'] is Map) {
      final input = Map<String, dynamic>.from(data['inputData']);

      if (input['title'] != null) {
        return input['title'].toString();
      }
    }

    if (data['sop'] is Map) {
      final sop = Map<String, dynamic>.from(data['sop']);

      if (sop['title'] != null) {
        return sop['title'].toString();
      }
    }

    return 'Standard Operating Procedure';
  }

  String _getDepartment(Map<String, dynamic> data) {
    if (data['department'] != null) {
      return data['department'].toString();
    }

    if (data['inputData'] is Map) {
      final input = Map<String, dynamic>.from(data['inputData']);

      return input['department']?.toString() ?? 'General';
    }

    return 'General';
  }

  DateTime _getDate(Map<String, dynamic> data) {
    final value = data['createdAt'] ?? data['savedAt'] ?? data['updatedAt'];

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime(2000);
  }

  String _formatDate(DateTime date) {
    if (date.year == 2000) {
      return 'Saved SOP';
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 95,
              width: 95,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF7C3AED),
                size: 43,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No SOPs yet',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Generate your first SOP and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          'Unable to load SOPs.\n\n$error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
