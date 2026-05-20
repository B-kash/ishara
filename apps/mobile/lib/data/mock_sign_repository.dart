import '../models/sign.dart';
import 'mock_sign_loader.dart';

class MockSignRepository {
  static List<Sign>? _cachedSigns;

  static Future<void> ensureLoaded() async {
    if (_cachedSigns != null) {
      return;
    }
    _cachedSigns = await MockSignLoader.loadSigns();
  }

  static List<Sign> get signs {
    final cachedSigns = _cachedSigns;
    if (cachedSigns == null) {
      throw StateError('Mock signs not loaded. Call ensureLoaded() first.');
    }
    return cachedSigns;
  }
}

List<String> get mockCategories {
  return MockSignRepository.signs
      .map((sign) => sign.category)
      .toSet()
      .toList()
    ..sort();
}

List<Sign> searchSigns({
  required String query,
  required SearchLanguage language,
  String? category,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return [];
  }

  return MockSignRepository.signs.where((sign) {
    if (category != null && sign.category != category) {
      return false;
    }
    final wordText = language == SearchLanguage.english
        ? sign.englishWord.toLowerCase()
        : sign.nepaliWord.toLowerCase();
    return wordText.contains(normalizedQuery);
  }).toList();
}
