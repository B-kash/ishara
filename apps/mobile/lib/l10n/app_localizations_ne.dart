// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appTitle => 'इशारा';

  @override
  String get appSubtitle => 'नेपाली साङ्केतिक भाषा शब्दकोश';

  @override
  String get searchHintEnglish => 'अङ्ग्रेजीमा खोज्नुहोस्';

  @override
  String get searchHintNepali => 'नेपालीमा खोज्नुहोस्';

  @override
  String get searchLanguageEnglish => 'अङ्ग्रेजी';

  @override
  String get searchLanguageNepali => 'नेपाली';

  @override
  String get categoriesTitle => 'वर्गहरू';

  @override
  String get couldNotLoadCategories => 'वर्गहरू लोड गर्न सकिएन';

  @override
  String get noCategoriesYet => 'अहिले कुनै वर्ग छैन।';

  @override
  String get tryAgain => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get somethingWentWrong => 'केही गडबड भयो।';

  @override
  String get chooseTheme => 'थिम छान्नुहोस्';

  @override
  String get chooseAppLanguage => 'एप भाषा';

  @override
  String get themeIshara => 'इशारा';

  @override
  String get themeOcean => 'महासागर';

  @override
  String get themeForest => 'वन';

  @override
  String get themeSlate => 'स्लेट';

  @override
  String get themeNight => 'रात';

  @override
  String resultsFor(String query) {
    return '\"$query\" का लागि नतिजा';
  }

  @override
  String get noSignsFound =>
      'कुनै सङ्केत फेला परेन। अर्को शब्द वा वर्ग प्रयास गर्नुहोस्।';

  @override
  String get noSignsInCategory => 'यो वर्गमा अहिले कुनै सङ्केत छैन।';

  @override
  String get couldNotReachApi => 'API मा पुग्न सकिएन';

  @override
  String get noResults => 'कुनै नतिजा छैन';

  @override
  String get couldNotLoadSign => 'सङ्केत लोड गर्न सकिएन';

  @override
  String get signNotFound => 'सङ्केत फेला परेन।';

  @override
  String get signDetailTitle => 'सङ्केत विवरण';

  @override
  String get detailEnglish => 'अङ्ग्रेजी';

  @override
  String get detailNepali => 'नेपाली';

  @override
  String get detailCategory => 'वर्ग';

  @override
  String get detailMeaning => 'अर्थ';

  @override
  String get signVideoComingSoon => 'साङ्केतिक भिडियो चाँडै आउँदैछ';

  @override
  String get previewImage => 'पूर्वावलोकन छवि';

  @override
  String get couldNotLoadVideo => 'भिडियो लोड गर्न सकिएन';

  @override
  String get videoCheckApiRunning =>
      'API चलिरहेको छ कि जाँच गर्नुहोस् र फेरि प्रयास गर्नुहोस्।';

  @override
  String get videoReadyLater => 'भिडियो तयार — प्लेब्याक अर्को अपडेटमा';

  @override
  String get missingData => 'डाटा छैन।';

  @override
  String get nothingHereYet => 'अहिले यहाँ केही छैन।';

  @override
  String apiCategoriesLoadFailed(int statusCode) {
    return 'वर्गहरू लोड गर्न सकिएन ($statusCode)। API चलिरहेको छ?';
  }

  @override
  String get apiCategoryNotFound => 'वर्ग फेला परेन';

  @override
  String apiCategorySignsLoadFailed(int statusCode) {
    return 'वर्गका सङ्केतहरू लोड गर्न सकिएन ($statusCode)। API चलिरहेको छ?';
  }

  @override
  String apiSearchFailed(int statusCode) {
    return 'खोज असफल ($statusCode)। API चलिरहेको छ?';
  }

  @override
  String get apiSignNotFound => 'सङ्केत फेला परेन';

  @override
  String apiSignLoadFailed(int statusCode) {
    return 'सङ्केत लोड गर्न सकिएन ($statusCode)। API चलिरहेको छ?';
  }
}
