class SignDetail {
  const SignDetail({
    required this.id,
    required this.englishWord,
    required this.nepaliWord,
    required this.category,
    required this.meaning,
    this.videoUrl,
    this.thumbnailUrl,
    this.videoDurationSeconds,
  });

  final String id;
  final String englishWord;
  final String nepaliWord;
  final String category;
  final String meaning;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int? videoDurationSeconds;

  bool get hasVideo => videoUrl != null && videoUrl!.trim().isNotEmpty;

  bool get hasThumbnail =>
      thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;

  factory SignDetail.fromJson(Map<String, dynamic> json) {
    final durationValue = json['videoDurationSeconds'];
    int? videoDurationSeconds;
    if (durationValue is int) {
      videoDurationSeconds = durationValue;
    } else if (durationValue is num) {
      videoDurationSeconds = durationValue.round();
    }

    return SignDetail(
      id: json['id'] as String,
      englishWord: json['englishWord'] as String,
      nepaliWord: json['nepaliWord'] as String,
      category: json['category'] as String,
      meaning: json['meaning'] as String,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoDurationSeconds: videoDurationSeconds,
    );
  }
}
