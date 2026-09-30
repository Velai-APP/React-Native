import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language_code', languageCode);

    _locale = Locale(languageCode);

    notifyListeners();
  }

  Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey('language_code');
  }
}