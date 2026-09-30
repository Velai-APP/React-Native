import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String? currentLanguage;

  const LanguageSelectionScreen({super.key, this.currentLanguage});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';
  String _selectedCode = 'en';

  final List<AppLanguage> _languages = const [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', icon: 'A'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', icon: 'த'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', icon: 'हि'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', icon: 'తె'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', icon: 'ಕ'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', icon: 'മ'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', icon: 'म'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', icon: 'ব'),
    AppLanguage(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      icon: 'ગુ',
    ),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', icon: 'ਪੰ'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', icon: 'ଓ'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', icon: 'ا'),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.currentLanguage != null &&
        widget.currentLanguage!.trim().isNotEmpty) {
      _selectedCode = widget.currentLanguage!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppLanguage> get _filteredLanguages {
    if (_search.trim().isEmpty) {
      return _languages;
    }

    final query = _search.toLowerCase();

    return _languages.where((language) {
      return language.name.toLowerCase().contains(query) ||
          language.nativeName.toLowerCase().contains(query);
    }).toList();
  }

  void _applyLanguage() {
    final selectedLanguage = _languages.firstWhere(
      (language) => language.code == _selectedCode,
    );

    Navigator.pop(context, selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLanguages = _filteredLanguages;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        title: const Text(
          'Select Language',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // TOP HEADER
            // ==================================================
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF172554),
                    Color(0xFF1E40AF),
                    Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose your language',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Select the language you prefer to use in Velai.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // SEARCH
            // ==================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _search = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search language',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                  ),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();

                            setState(() {
                              _search = '';
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // LABEL
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Available Languages',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredLanguages.length}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ==================================================
            // LANGUAGE LIST
            // ==================================================
            Expanded(
              child: filteredLanguages.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: filteredLanguages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final language = filteredLanguages[index];

                        return _languageTile(language);
                      },
                    ),
            ),

            // ==================================================
            // APPLY BUTTON
            // ==================================================
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _applyLanguage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text(
                    'Apply Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LANGUAGE TILE
  // ============================================================

  Widget _languageTile(AppLanguage language) {
    final bool selected = language.code == _selectedCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCode = language.code;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFE8EDF4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // ===============================================
              // LANGUAGE ICON
              // ===============================================
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  language.icon,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // ===============================================
              // NAME
              // ===============================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 3),

                    if (language.nativeName != language.name)
                      Text(
                        language.name,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // ===============================================
              // SELECTED
              // ===============================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFCBD5E1),
                    width: 2,
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
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.translate_rounded,
                size: 35,
                color: Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Language not found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 5),

            const Text(
              'Try searching using another language name.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// LANGUAGE MODEL
// =============================================================

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String icon;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.icon,
  });
}
