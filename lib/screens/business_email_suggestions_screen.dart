import 'package:flutter/material.dart';
import 'email_provider_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_email_screen.dart';

class BusinessEmailSuggestionsScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const BusinessEmailSuggestionsScreen({
    super.key,
    required this.result,
  });

  @override
  State<BusinessEmailSuggestionsScreen> createState() =>
      _BusinessEmailSuggestionsScreenState();
}

class _BusinessEmailSuggestionsScreenState
    extends State<BusinessEmailSuggestionsScreen> {
  static const Color _navy = Color(0xFF172554);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _green = Color(0xFF059669);
  static const Color _background = Color(0xFFF6F8FC);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  late final String businessName;
  late final String domain;
  late final String recommendedEmail;
  late final String recommendationReason;

  final Set<String> _selectedEmails = <String>{};

  late List<BusinessEmailSuggestion> suggestions;

  @override
  void initState() {
    super.initState();

    businessName =
        widget.result['businessName']?.toString() ?? 'Your Business';

    domain =
        widget.result['domain']?.toString() ?? '';

    recommendedEmail =
        widget.result['recommendedEmail']?.toString() ?? '';

    recommendationReason =
        widget.result['recommendationReason']?.toString() ?? '';

    suggestions = _parseSuggestions(
      widget.result['suggestions'],
    );

    // Select AI recommended email by default.
    if (recommendedEmail.isNotEmpty) {
      _selectedEmails.add(recommendedEmail);
    }
  }

  List<BusinessEmailSuggestion> _parseSuggestions(dynamic raw) {
    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map(
          (item) => BusinessEmailSuggestion.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((item) => item.email.isNotEmpty)
        .toList();
  }

  void _toggleEmail(String email) {
    setState(() {
      if (_selectedEmails.contains(email)) {
        _selectedEmails.remove(email);
      } else {
        _selectedEmails.add(email);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedEmails.length == suggestions.length) {
        _selectedEmails.clear();
      } else {
        _selectedEmails
          ..clear()
          ..addAll(
            suggestions.map((item) => item.email),
          );
      }
    });
  }

  bool _isSaving = false;

Future<void> _continue() async {
  if (_isSaving) return;

  // Validate selection
  if (_selectedEmails.isEmpty) {
    _showMessage('Select at least one business email.');
    return;
  }

  // Get currently logged-in user
  final User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    _showMessage('Please log in to continue.');
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    // Selected email usernames
    final List<String> selectedEmails =
        _selectedEmails.toList();

    // Store under the current user's UID
    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('businessEmailSelections')
            .doc();

    await docRef.set({
      'userId': user.uid,
      'businessName': businessName,
      'selectedEmails': selectedEmails,
      'recommendedEmail': recommendedEmail,
      'status': 'selected',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    debugPrint(
      'Business email selection saved successfully: ${docRef.id}',
    );
    _showMessage('Business email selection saved successfully.');

    if (!mounted) return;

    // Navigate only after saving successfully
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BusinessEmailScreen(
  
        ),
      ),
    );
  } on FirebaseException catch (error) {
    debugPrint(
      'Firestore error: ${error.code} - ${error.message}',
    );

    if (mounted) {
      _showMessage(
        error.message ?? 'Unable to save selected emails.',
      );
    }
  } catch (error) {
    debugPrint('Save error: $error');

    if (mounted) {
      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  Map<String, List<BusinessEmailSuggestion>>
      _groupSuggestions() {
    final Map<String, List<BusinessEmailSuggestion>> groups = {};

    for (final item in suggestions) {
      groups.putIfAbsent(
        item.category,
        () => [],
      );

      groups[item.category]!.add(item);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop = width >= 900;

    final groups = _groupSuggestions();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        titleSpacing: 4,
        title: const Text(
          'Email Suggestions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 40 : 18,
                  20,
                  isDesktop ? 40 : 18,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 920,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 22),

                        if (recommendedEmail.isNotEmpty) ...[
                          _buildRecommendedCard(),
                          const SizedBox(height: 26),
                        ],

                        _buildSectionHeader(),

                        const SizedBox(height: 16),

                        if (suggestions.isEmpty)
                          _buildEmptyState()
                        else
                          ...groups.entries.map(
                            (entry) => _buildCategory(
                              entry.key,
                              entry.value,
                            ),
                          ),

                        const SizedBox(height: 20),

                        _buildInfoCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (suggestions.isNotEmpty)
              _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF172554),
            Color(0xFF3730A3),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.14),
                      borderRadius:
                          BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'AI Generated',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Your professional emails\nare ready',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'We created email identities for '
                '$businessName based on common '
                'business communication needs.',
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.80),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 19),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.14),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        domain,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard() {
    final bool selected =
        _selectedEmails.contains(recommendedEmail);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFECFDF5),
            Color(0xFFF0FDF4),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI RECOMMENDED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        letterSpacing: 0.4,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      _green.withOpacity(0.11),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.alternate_email_rounded,
                  color: _green,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  recommendedEmail,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              InkWell(
                onTap: () =>
                    _toggleEmail(recommendedEmail),
                borderRadius:
                    BorderRadius.circular(50),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selected
                        ? _green
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? _green
                          : _border,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ),
            ],
          ),

          if (recommendationReason.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              recommendationReason,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final bool allSelected =
        suggestions.isNotEmpty &&
        _selectedEmails.length ==
            suggestions.length;

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your emails',
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Select the addresses your business needs.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        if (suggestions.isNotEmpty)
          TextButton(
            onPressed: _selectAll,
            child: Text(
              allSelected
                  ? 'Clear all'
                  : 'Select all',
              style: const TextStyle(
                color: _blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategory(
    String category,
    List<BusinessEmailSuggestion> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 22,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _categoryColor(category)
                      .withOpacity(0.09),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Icon(
                  _categoryIcon(category),
                  color:
                      _categoryColor(category),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                category,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          ...items.map(
            (item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 10),
              child: _buildEmailCard(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard(
    BusinessEmailSuggestion item,
  ) {
    final bool selected =
        _selectedEmails.contains(item.email);

    final bool recommended =
        item.email == recommendedEmail;

    return InkWell(
      onTap: () => _toggleEmail(item.email),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF8FAFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                selected ? _blue : _border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: _categoryColor(
                  item.category,
                ).withOpacity(0.09),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                _categoryIcon(item.category),
                color:
                    _categoryColor(item.category),
                size: 21,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.email,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                      if (recommended) ...[
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.star_rounded,
                          color:
                              Color(0xFFF59E0B),
                          size: 16,
                        ),
                      ],
                    ],
                  ),

                  if (item.purpose.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      item.purpose,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],

                  if (item.reason.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      item.reason,
                      style: const TextStyle(
                        color:
                            Color(0xFF64748B),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color:
                    selected ? _blue : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected ? _blue : _border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 17,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFD97706),
            size: 21,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'You do not need every address immediately. '
              'Start with the emails your business actually '
              'uses and add more as your team grows.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            size: 50,
            color: _muted,
          ),
          SizedBox(height: 15),
          Text(
            'No email suggestions found',
            style: TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Go back and generate the suggestions again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        13,
        18,
        13 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: _border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 920),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedEmails.length} selected',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'You can change this later',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      _blue,
                      _purple,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed:
                      _selectedEmails.isEmpty
                          ? null
                          : _continue,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent,
                    disabledBackgroundColor:
                        Colors.transparent,
                    shadowColor:
                        Colors.transparent,
                    foregroundColor:
                        Colors.white,
                    disabledForegroundColor:
                        Colors.white54,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 19,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sales':
        return Icons.trending_up_rounded;

      case 'support':
        return Icons.headset_mic_rounded;

      case 'finance':
        return Icons.account_balance_wallet_rounded;

      case 'careers':
        return Icons.people_alt_rounded;

      case 'management':
        return Icons.admin_panel_settings_rounded;

      case 'general':
      default:
        return Icons.alternate_email_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sales':
        return const Color(0xFF7C3AED);

      case 'support':
        return const Color(0xFF0891B2);

      case 'finance':
        return const Color(0xFF059669);

      case 'careers':
        return const Color(0xFFDB2777);

      case 'management':
        return const Color(0xFFEA580C);

      case 'general':
      default:
        return _blue;
    }
  }
}

// ======================================================
// MODEL
// ======================================================

class BusinessEmailSuggestion {
  final String email;
  final String localPart;
  final String category;
  final String purpose;
  final String reason;

  const BusinessEmailSuggestion({
    required this.email,
    required this.localPart,
    required this.category,
    required this.purpose,
    required this.reason,
  });

  factory BusinessEmailSuggestion.fromMap(
    Map<String, dynamic> map,
  ) {
    return BusinessEmailSuggestion(
      email:
          map['email']?.toString() ?? '',
      localPart:
          map['localPart']?.toString() ?? '',
      category:
          map['category']?.toString() ??
          'General',
      purpose:
          map['purpose']?.toString() ?? '',
      reason:
          map['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'localPart': localPart,
      'category': category,
      'purpose': purpose,
      'reason': reason,
    };
  }
}