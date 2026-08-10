import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }

  void setArabic() {
    setLocale(const Locale('ar'));
  }

  void setEnglish() {
    setLocale(const Locale('en'));
  }

  void toggleLocale() {
    setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}
