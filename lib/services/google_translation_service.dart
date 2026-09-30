import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class GoogleTranslationService {
  GoogleTranslationService._();

  static final GoogleTranslationService instance =
      GoogleTranslationService._();

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  final Map<String, String> _cache = {};

  // ============================================================
  // LANGUAGE MAPPING
  // ============================================================

  TranslateLanguage _getLanguage(
    String code,
  ) {
    switch (code) {
      case 'ta':
        return TranslateLanguage.tamil;

      case 'hi':
        return TranslateLanguage.hindi;

      case 'te':
        return TranslateLanguage.telugu;

      case 'kn':
        return TranslateLanguage.kannada;

  

      case 'mr':
        return TranslateLanguage.marathi;

      case 'bn':
        return TranslateLanguage.bengali;

      case 'gu':
        return TranslateLanguage.gujarati;

      case 'ur':
        return TranslateLanguage.urdu;

      default:
        return TranslateLanguage.english;
    }
  }

  // ============================================================
  // DOWNLOAD MODEL
  // ============================================================

  Future<void> prepareLanguage(
    String languageCode,
  ) async {
    if (languageCode == 'en') {
      return;
    }

    final source =
        TranslateLanguage.english;

    final target =
        _getLanguage(languageCode);

    final bool sourceDownloaded =
        await _modelManager.isModelDownloaded(
      source.bcpCode,
    );

    if (!sourceDownloaded) {
      await _modelManager.downloadModel(
        source.bcpCode,
      );
    }

    final bool targetDownloaded =
        await _modelManager.isModelDownloaded(
      target.bcpCode,
    );

    if (!targetDownloaded) {
      await _modelManager.downloadModel(
        target.bcpCode,
      );
    }
  }

  // ============================================================
  // TRANSLATE
  // ============================================================

  Future<String> translate({
    required String text,
    required String targetLanguage,
  }) async {
    if (text.trim().isEmpty) {
      return text;
    }

    // English selected - no translation required
    if (targetLanguage == 'en') {
      return text;
    }

    final String cacheKey =
        '$targetLanguage::$text';

    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      await prepareLanguage(
        targetLanguage,
      );

      final translator =
          OnDeviceTranslator(
        sourceLanguage:
            TranslateLanguage.english,
        targetLanguage:
            _getLanguage(targetLanguage),
      );

      try {
        final String translated =
            await translator.translateText(
          text,
        );

        _cache[cacheKey] =
            translated;

        return translated;
      } finally {
        translator.close();
      }
    } catch (e) {
      // Never break UI because translation failed.
      return text;
    }
  }

  void clearCache() {
    _cache.clear();
  }
}