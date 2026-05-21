import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/models/sign_detail.dart';

void main() {
  test('fromJson accepts null video fields', () {
    final signDetail = SignDetail.fromJson({
      'id': 'mother',
      'englishWord': 'mother',
      'nepaliWord': 'आमा',
      'category': 'Family',
      'meaning': 'A female parent.',
      'videoUrl': null,
      'thumbnailUrl': null,
      'videoDurationSeconds': null,
    });

    expect(signDetail.hasVideo, isFalse);
    expect(signDetail.hasThumbnail, isFalse);
    expect(signDetail.videoDurationSeconds, isNull);
  });

  test('fromJson handles thumbnail-only sign', () {
    final signDetail = SignDetail.fromJson({
      'id': 'water',
      'englishWord': 'water',
      'nepaliWord': 'पानी',
      'category': 'Food & Drink',
      'meaning': 'Clear liquid essential for life.',
      'videoUrl': null,
      'thumbnailUrl': 'https://example.com/water.jpg',
      'videoDurationSeconds': null,
    });

    expect(signDetail.hasVideo, isFalse);
    expect(signDetail.hasThumbnail, isTrue);
  });

  test('fromJson handles video-ready sign', () {
    final signDetail = SignDetail.fromJson({
      'id': 'hello',
      'englishWord': 'hello',
      'nepaliWord': 'नमस्ते',
      'category': 'Greetings',
      'meaning': 'A greeting.',
      'videoUrl': 'http://127.0.0.1:3000/media/hello.mp4',
      'thumbnailUrl': null,
      'videoDurationSeconds': 15,
    });

    expect(signDetail.hasVideo, isTrue);
    expect(signDetail.hasThumbnail, isFalse);
    expect(signDetail.videoDurationSeconds, 15);
  });
}
