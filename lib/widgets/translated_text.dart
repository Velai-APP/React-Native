import 'package:flutter/material.dart';

import '../services/google_translation_service.dart';
import '../services/language_manager.dart';

class TranslatedText extends StatelessWidget {
  final String text;

  final TextStyle? style;

  final TextAlign? textAlign;

  final int? maxLines;

  final TextOverflow? overflow;

  final bool softWrap;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.instance.languageCode,

      builder: (context, languageCode, child) {
        // =============================================
        // ENGLISH
        // =============================================

        if (languageCode == 'en') {
          return TranslatedText(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
          );
        }

        // =============================================
        // GOOGLE TRANSLATION
        // =============================================

        return FutureBuilder<String>(
          future: GoogleTranslationService.instance.translate(
            text: text,
            targetLanguage: languageCode,
          ),

          builder: (context, snapshot) {
            // Show English until translation finishes
            final String translatedText = snapshot.data ?? text;

            return TranslatedText(
              translatedText,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
              softWrap: softWrap,
            );
          },
        );
      },
    );
  }
}
