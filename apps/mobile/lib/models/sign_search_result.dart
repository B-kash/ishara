class SignSearchResult {
  const SignSearchResult({
    required this.id,
    required this.englishWord,
    required this.nepaliWord,
    required this.category,
    required this.meaning,
  });

  final String id;
  final String englishWord;
  final String nepaliWord;
  final String category;
  final String meaning;

  factory SignSearchResult.fromJson(Map<String, dynamic> json) {
    return SignSearchResult(
      id: json['id'] as String,
      englishWord: json['englishWord'] as String,
      nepaliWord: json['nepaliWord'] as String,
      category: json['category'] as String,
      meaning: json['meaning'] as String,
    );
  }
}
