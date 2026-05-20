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
