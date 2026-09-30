import 'package:flutter/material.dart';

class DomainSuggestionsScreen extends StatefulWidget {
  final String businessName;

  const DomainSuggestionsScreen({
    super.key,
    required this.businessName,
  });

  @override
  State<DomainSuggestionsScreen> createState() =>
      _DomainSuggestionsScreenState();
}

class _DomainSuggestionsScreenState
    extends State<DomainSuggestionsScreen> {
  static const Color _navy = Color(0xFF172554);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _green = Color(0xFF059669);
  static const Color _background = Color(0xFFF6F8FC);
  static const Color _text = Color(0xFF172033);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  String? _selectedDomain;
  String _selectedFilter = 'All';

  final TextEditingController _customDomainController =
      TextEditingController();

  /*
   * TEMPORARY DATA
   *
   * Replace this with the result returned from
   * generateDomainSuggestions Cloud Function.
   *
   * "available" is intentionally null because AI
   * should NOT claim real domain availability.
   */
  late List<DomainSuggestion> _domains;

  final List<String> _filters = const [
    'All',
    '.com',
    '.in',
    '.co',
    '.ai',
  ];

  @override
  void initState() {
    super.initState();

    final String brand = _brandSlug(widget.businessName);

    _domains = [
      DomainSuggestion(
        domain: '$brand.com',
        type: 'Classic',
        reason:
            'Simple, professional and suitable for a global business presence.',
        recommended: true,
      ),
      DomainSuggestion(
        domain: '$brand.in',
        type: 'India',
        reason:
            'A strong option for a business primarily serving the Indian market.',
      ),
      DomainSuggestion(
        domain: 'get$brand.com',
        type: 'Modern',
        reason:
            'A modern alternative when the shortest brand domain is unavailable.',
      ),
      DomainSuggestion(
        domain: '${brand}hq.com',
        type: 'Brand',
        reason:
            'Keeps the core business name prominent while remaining professional.',
      ),
      DomainSuggestion(
        domain: '$brand.co',
        type: 'Startup',
        reason:
            'Short and contemporary for a digital-first business.',
      ),
      DomainSuggestion(
        domain: '$brand.ai',
        type: 'AI',
        reason:
            'Suitable when artificial intelligence is central to the business.',
      ),
    ];
  }

  @override
  void dispose() {
    _customDomainController.dispose();
    super.dispose();
  }

  String _brandSlug(String value) {
    final String cleaned = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    return cleaned.isEmpty ? 'mybusiness' : cleaned;
  }

  List<DomainSuggestion> get _filteredDomains {
    if (_selectedFilter == 'All') {
      return _domains;
    }

    return _domains
        .where(
          (item) =>
              item.domain.toLowerCase().endsWith(
                    _selectedFilter.toLowerCase(),
                  ),
        )
        .toList();
  }

  void _selectDomain(String domain) {
    setState(() {
      _selectedDomain = domain;
    });
  }

  void _useCustomDomain() {
    String domain = _customDomainController.text
        .trim()
        .toLowerCase();

    domain = domain
        .replaceFirst(RegExp(r'^https?://'), '')
        .replaceFirst(RegExp(r'^www\.'), '')
        .split('/')
        .first
        .trim();

    if (domain.isEmpty) {
      _showMessage(
        'Enter a domain you would like to use.',
      );
      return;
    }

    if (!_isValidDomain(domain)) {
      _showMessage(
        'Please enter a valid domain such as mybrand.com.',
      );
      return;
    }

    final bool alreadyExists = _domains.any(
      (item) => item.domain == domain,
    );

    if (!alreadyExists) {
      setState(() {
        _domains.insert(
          0,
          DomainSuggestion(
            domain: domain,
            type: 'Custom',
            reason:
                'A custom domain entered by you.',
          ),
        );

        _selectedDomain = domain;
        _selectedFilter = 'All';
      });
    } else {
      setState(() {
        _selectedDomain = domain;
        _selectedFilter = 'All';
      });
    }

    FocusScope.of(context).unfocus();
  }

  bool _isValidDomain(String domain) {
    return RegExp(
      r'^(?!-)(?:[a-zA-Z0-9-]{1,63}\.)+[a-zA-Z]{2,}$',
    ).hasMatch(domain);
  }

  void _continue() {
    if (_selectedDomain == null ||
        _selectedDomain!.isEmpty) {
      _showMessage(
        'Please select a domain to continue.',
      );
      return;
    }

    /*
     * NEXT STEP:
     *
     * We will pass this selected domain into
     * generateBusinessEmails.
     *
     * Navigator.push(
     *   context,
     *   MaterialPageRoute(
     *     builder: (_) => ...
     *   ),
     * );
     */

    _showMessage(
      'Selected domain: $_selectedDomain',
    );
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

  @override
  Widget build(BuildContext context) {
    final double width =
        MediaQuery.sizeOf(context).width;

    final bool isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        titleSpacing: 4,
        title: const Text(
          'Find Your Domain',
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
                  30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 920,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildHero(),
                        const SizedBox(height: 22),
                        _buildCustomDomainCard(),
                        const SizedBox(height: 25),
                        _buildHeading(),
                        const SizedBox(height: 14),
                        _buildFilters(),
                        const SizedBox(height: 18),
                        _buildDomainList(),
                        const SizedBox(height: 10),
                        _buildAvailabilityNotice(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: -55,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 55,
            bottom: -80,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withOpacity(0.045),
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
                    width: 57,
                    height: 57,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.14),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
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
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'AI DOMAIN IDEAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Give your business\na home online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                'Domain ideas for ${widget.businessName} '
                'that can become the foundation for your '
                'website and professional email.',
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.82),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDomainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: _blue,
                size: 21,
              ),
              SizedBox(width: 9),
              Text(
                'Have a domain in mind?',
                style: TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Enter your own idea or choose one of the suggestions below.',
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      _customDomainController,
                  keyboardType:
                      TextInputType.url,
                  textInputAction:
                      TextInputAction.done,
                  onSubmitted: (_) =>
                      _useCustomDomain(),
                  decoration: InputDecoration(
                    hintText:
                        'yourbusiness.com',
                    hintStyle: const TextStyle(
                      color:
                          Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.language_rounded,
                      color: _blue,
                      size: 20,
                    ),
                    filled: true,
                    fillColor:
                        const Color(0xFFF8FAFC),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(
                        color: _border,
                      ),
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(
                        color: _blue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                height: 51,
                child: FilledButton(
                  onPressed: _useCustomDomain,
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 17,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested for your brand',
          style: TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Choose a simple domain your customers can remember.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String filter =
              _filters[index];

          final bool selected =
              filter == _selectedFilter;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            borderRadius:
                BorderRadius.circular(30),
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected ? _navy : Colors.white,
                borderRadius:
                    BorderRadius.circular(30),
                border: Border.all(
                  color:
                      selected ? _navy : _border,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : _muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDomainList() {
    final List<DomainSuggestion> domains =
        _filteredDomains;

    if (domains.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(color: _border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: _muted,
            ),
            SizedBox(height: 12),
            Text(
              'No suggestions in this category',
              style: TextStyle(
                color: _text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: domains
          .map(
            (domain) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 11,
              ),
              child: _buildDomainCard(
                domain,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDomainCard(
    DomainSuggestion suggestion,
  ) {
    final bool selected =
        _selectedDomain == suggestion.domain;

    return InkWell(
      onTap: () =>
          _selectDomain(suggestion.domain),
      borderRadius: BorderRadius.circular(19),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF8FAFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color:
                selected ? _blue : _border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.025),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: suggestion.recommended
                    ? const Color(0xFFFFF7ED)
                    : _blue.withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                suggestion.recommended
                    ? Icons.star_rounded
                    : Icons.language_rounded,
                color: suggestion.recommended
                    ? const Color(0xFFF59E0B)
                    : _blue,
                size: 22,
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
                          suggestion.domain,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                      if (suggestion.recommended) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFF7ED,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Text(
                            'AI PICK',
                            style: TextStyle(
                              color: Color(
                                0xFFEA580C,
                              ),
                              fontSize: 8.5,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    suggestion.type,
                    style: const TextStyle(
                      color: _blue,
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    suggestion.reason,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? _blue : Colors.white,
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

  Widget _buildAvailabilityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'These are domain name ideas. '
              'Availability must be checked before '
              'you register or use a domain.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 11.5,
                height: 1.45,
              ),
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
        12,
        18,
        12 +
            MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: _border),
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
                child: _selectedDomain == null
                    ? const Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a domain',
                            style: TextStyle(
                              color: _text,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose one to continue',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SELECTED DOMAIN',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 8.5,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _selectedDomain!,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: _selectedDomain == null
                      ? null
                      : const LinearGradient(
                          colors: [
                            _blue,
                            _purple,
                          ],
                        ),
                  color: _selectedDomain == null
                      ? const Color(0xFFE2E8F0)
                      : null,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  onPressed: _selectedDomain == null
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
                        const Color(0xFF94A3B8),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
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
}

// ======================================================
// DOMAIN MODEL
// ======================================================

class DomainSuggestion {
  final String domain;
  final String type;
  final String reason;
  final bool recommended;

  /// null = availability has NOT been checked.
  final bool? available;

  const DomainSuggestion({
    required this.domain,
    required this.type,
    required this.reason,
    this.recommended = false,
    this.available,
  });

  factory DomainSuggestion.fromMap(
    Map<String, dynamic> map,
  ) {
    return DomainSuggestion(
      domain:
          map['domain']?.toString() ?? '',
      type:
          map['type']?.toString() ?? 'Brand',
      reason:
          map['reason']?.toString() ?? '',
      recommended:
          map['recommended'] == true,
      available:
          map['available'] is bool
              ? map['available'] as bool
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'type': type,
      'reason': reason,
      'recommended': recommended,
      'available': available,
    };
  }
}