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

  factory Sign.fromJson(Map<String, dynamic> json) {
    return Sign(
      id: json['id'] as String,
      englishWord: json['englishWord'] as String,
      nepaliWord: json['nepaliWord'] as String,
      meaningEnglish: json['meaningEnglish'] as String,
      meaningNepali: json['meaningNepali'] as String,
      category: json['category'] as String,
    );
  }
}

enum SearchLanguage { english, nepali }
