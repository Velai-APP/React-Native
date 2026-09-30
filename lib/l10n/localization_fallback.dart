import 'dart:async';
import 'package:flutter/material.dart';
import '../services/google_translation_service.dart';

/// Hybrid localization used across the existing Velai UI.
/// 1. Uses curated ARB translations when they exist.
/// 2. Otherwise requests Google ML Kit translation and caches the result.
/// 3. Falls back to the original English string if translation fails.
class TranslationFallbackController {
  TranslationFallbackController._();
  static final instance = TranslationFallbackController._();

  final ValueNotifier<int> revision = ValueNotifier<int>(0);
  final Map<String, String> _cache = <String, String>{};
  final Set<String> _pending = <String>{};

  static const Map<String, String> _ta = <String, String>{
    'Velai': 'வேலை',
    'Choose your language': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    'Continue': 'தொடரவும்',
    'Home': 'முகப்பு'
  };
  static const Map<String, String> _hi = <String, String>{
    'Velai': 'वेलै',
    'Choose your language': 'अपनी भाषा चुनें',
    'Continue': 'जारी रखें',
    'Home': 'होम'
  };

  String resolve(BuildContext context, String source) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'en' || source.trim().isEmpty) return source;

    final curated = code == 'ta' ? _ta[source] : code == 'hi' ? _hi[source] : null;
    if (curated != null && curated.isNotEmpty) return curated;

    final key = '$code::$source';
    final cached = _cache[key];
    if (cached != null) return cached;

    if (!_pending.contains(key)) {
      _pending.add(key);
      unawaited(_translate(key, source, code));
    }
    return source;
  }

  Future<void> _translate(String key, String source, String code) async {
    try {
      final translated = await GoogleTranslationService.instance.translate(
        text: source,
        targetLanguage: code,
      );
      _cache[key] = translated;
    } finally {
      _pending.remove(key);
      revision.value++;
    }
  }

  void localeChanged() {
    revision.value++;
  }
}

String tr(BuildContext context, String source) =>
    TranslationFallbackController.instance.resolve(context, source);

class LocalizedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;
  final TextDirection? textDirection;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const LocalizedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.textDirection,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: TranslationFallbackController.instance.revision,
      builder: (context, _, __) => Text(
        tr(context, text),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textDirection: textDirection,
        locale: locale,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
      ),
    );
  }
}
