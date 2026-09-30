import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  LanguageManager._();

  static final LanguageManager instance =
      LanguageManager._();

  final ValueNotifier<String> languageCode =
      ValueNotifier<String>('en');

  static const String _key = 'selected_language';

  Future<void> initialize() async {
    final prefs =
        await SharedPreferences.getInstance();

    languageCode.value =
        prefs.getString(_key) ?? 'en';
  }

  Future<void> changeLanguage(
    String code,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _key,
      code,
    );

    languageCode.value = code;
  }
}