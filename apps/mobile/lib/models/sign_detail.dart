class SignDetail {
  const SignDetail({
    required this.id,
    required this.englishWord,
    required this.nepaliWord,
    required this.category,
    required this.meaning,
    this.videoUrl,
    this.thumbnailUrl,
  });

  final String id;
  final String englishWord;
  final String nepaliWord;
  final String category;
  final String meaning;
  final String? videoUrl;
  final String? thumbnailUrl;

  factory SignDetail.fromJson(Map<String, dynamic> json) {
    return SignDetail(
      id: json['id'] as String,
      englishWord: json['englishWord'] as String,
      nepaliWord: json['nepaliWord'] as String,
      category: json['category'] as String,
      meaning: json['meaning'] as String,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}
