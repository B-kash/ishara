class Sign {
  const Sign({
    required this.id,
    required this.englishWord,
    required this.nepaliWord,
    required this.meaningEnglish,
    required this.meaningNepali,
    required this.category,
  });

  final String id;
  final String englishWord;
  final String nepaliWord;
  final String meaningEnglish;
  final String meaningNepali;
  final String category;
}

enum SearchLanguage { english, nepali }
