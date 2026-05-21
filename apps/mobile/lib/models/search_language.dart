import 'package:flutter/material.dart';

enum SearchLanguage {
  english,
  nepali;

  String get apiCode {
    switch (this) {
      case SearchLanguage.english:
        return 'en';
      case SearchLanguage.nepali:
        return 'ne';
    }
  }
}

SearchLanguage searchLanguageFromLocale(Locale locale) {
  if (locale.languageCode == 'ne') {
    return SearchLanguage.nepali;
  }

  return SearchLanguage.english;
}
