// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ishara';

  @override
  String get appSubtitle => 'Nepali Sign Language dictionary';

  @override
  String get searchHintEnglish => 'Search in English';

  @override
  String get searchHintNepali => 'Search in Nepali';

  @override
  String get searchLanguageEnglish => 'English';

  @override
  String get searchLanguageNepali => 'Nepali';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get couldNotLoadCategories => 'Could not load categories';

  @override
  String get noCategoriesYet => 'No categories yet.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get chooseAppLanguage => 'App language';

  @override
  String get themeIshara => 'Ishara';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeSlate => 'Slate';

  @override
  String get themeNight => 'Night';

  @override
  String resultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get noSignsFound => 'No signs found. Try another word or category.';

  @override
  String get noSignsInCategory => 'No signs in this category yet.';

  @override
  String get couldNotReachApi => 'Could not reach the API';

  @override
  String get noResults => 'No results';

  @override
  String get couldNotLoadSign => 'Could not load sign';

  @override
  String get signNotFound => 'Sign not found.';

  @override
  String get signDetailTitle => 'Sign detail';

  @override
  String get detailEnglish => 'English';

  @override
  String get detailNepali => 'Nepali';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailMeaning => 'Meaning';

  @override
  String get signVideoComingSoon => 'Sign video coming soon';

  @override
  String get previewImage => 'Preview image';

  @override
  String get couldNotLoadVideo => 'Could not load video';

  @override
  String get videoCheckApiRunning =>
      'Check that the API is running and try again.';

  @override
  String get videoReadyLater => 'Video ready — playback in next update';

  @override
  String get missingData => 'Missing data.';

  @override
  String get nothingHereYet => 'Nothing here yet.';

  @override
  String apiCategoriesLoadFailed(int statusCode) {
    return 'Could not load categories ($statusCode). Is the API running?';
  }

  @override
  String get apiCategoryNotFound => 'Category not found';

  @override
  String apiCategorySignsLoadFailed(int statusCode) {
    return 'Could not load category signs ($statusCode). Is the API running?';
  }

  @override
  String apiSearchFailed(int statusCode) {
    return 'Search failed ($statusCode). Is the API running?';
  }

  @override
  String get apiSignNotFound => 'Sign not found';

  @override
  String apiSignLoadFailed(int statusCode) {
    return 'Could not load sign ($statusCode). Is the API running?';
  }
}
