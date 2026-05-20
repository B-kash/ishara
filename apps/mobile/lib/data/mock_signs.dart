import '../models/sign.dart';

const mockSigns = <Sign>[
  Sign(
    id: 'hello',
    englishWord: 'Hello',
    nepaliWord: 'नमस्ते',
    meaningEnglish: 'A greeting used when meeting someone.',
    meaningNepali: 'कसैलाई भेट्दा प्रयोग गरिने अभिवादन।',
    category: 'Greetings',
  ),
  Sign(
    id: 'thank-you',
    englishWord: 'Thank you',
    nepaliWord: 'धन्यवाद',
    meaningEnglish: 'Expression of gratitude.',
    meaningNepali: 'कृतज्ञता व्यक्त गर्ने शब्द।',
    category: 'Greetings',
  ),
  Sign(
    id: 'water',
    englishWord: 'Water',
    nepaliWord: 'पानी',
    meaningEnglish: 'Clear liquid essential for life.',
    meaningNepali: 'जीवनको लागि आवश्यक पेय पदार्थ।',
    category: 'Food & Drink',
  ),
  Sign(
    id: 'rice',
    englishWord: 'Rice',
    nepaliWord: 'भात',
    meaningEnglish: 'Staple grain eaten daily in Nepal.',
    meaningNepali: 'नेपालमा दैनिक खाने मुख्य अन्न।',
    category: 'Food & Drink',
  ),
  Sign(
    id: 'mother',
    englishWord: 'Mother',
    nepaliWord: 'आमा',
    meaningEnglish: 'A female parent.',
    meaningNepali: 'महिला अभिभावक।',
    category: 'Family',
  ),
  Sign(
    id: 'father',
    englishWord: 'Father',
    nepaliWord: 'बुबा',
    meaningEnglish: 'A male parent.',
    meaningNepali: 'पुरुष अभिभावक।',
    category: 'Family',
  ),
  Sign(
    id: 'school',
    englishWord: 'School',
    nepaliWord: 'स्कूल',
    meaningEnglish: 'A place where children learn.',
    meaningNepali: 'बालबालिकाले पढ्ने ठाउँ।',
    category: 'Education',
  ),
  Sign(
    id: 'friend',
    englishWord: 'Friend',
    nepaliWord: 'साथी',
    meaningEnglish: 'A person you know and like.',
    meaningNepali: 'तपाईंले चिन्ने र मन पराउने व्यक्ति।',
    category: 'People',
  ),
];

List<String> get mockCategories {
  return mockSigns.map((s) => s.category).toSet().toList()..sort();
}

List<Sign> searchSigns({
  required String query,
  required SearchLanguage language,
  String? category,
}) {
  final trimmed = query.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return [];
  }

  return mockSigns.where((sign) {
    if (category != null && sign.category != category) {
      return false;
    }
    final haystack = language == SearchLanguage.english
        ? sign.englishWord.toLowerCase()
        : sign.nepaliWord.toLowerCase();
    return haystack.contains(trimmed);
  }).toList();
}
