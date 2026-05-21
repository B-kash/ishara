import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ishara'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nepali Sign Language dictionary'**
  String get appSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in English or Nepali'**
  String get searchHint;

  /// No description provided for @searchHintEnglish.
  ///
  /// In en, this message translates to:
  /// **'Search in English'**
  String get searchHintEnglish;

  /// No description provided for @searchHintNepali.
  ///
  /// In en, this message translates to:
  /// **'Search in Nepali'**
  String get searchHintNepali;

  /// No description provided for @searchLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get searchLanguageEnglish;

  /// No description provided for @searchLanguageNepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get searchLanguageNepali;

  /// No description provided for @browseDictionaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse dictionary'**
  String get browseDictionaryTitle;

  /// No description provided for @browseDictionaryAction.
  ///
  /// In en, this message translates to:
  /// **'Browse all words'**
  String get browseDictionaryAction;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @couldNotLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories'**
  String get couldNotLoadCategories;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get noCategoriesYet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseTheme;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get chooseAppLanguage;

  /// No description provided for @themeIshara.
  ///
  /// In en, this message translates to:
  /// **'Ishara'**
  String get themeIshara;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get themeSlate;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get themeNight;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String resultsFor(String query);

  /// No description provided for @noSignsFound.
  ///
  /// In en, this message translates to:
  /// **'No signs found. Try another word or category.'**
  String get noSignsFound;

  /// No description provided for @noSignsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No signs in this category yet.'**
  String get noSignsInCategory;

  /// No description provided for @couldNotReachApi.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the API'**
  String get couldNotReachApi;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @couldNotLoadSign.
  ///
  /// In en, this message translates to:
  /// **'Could not load sign'**
  String get couldNotLoadSign;

  /// No description provided for @signNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sign not found.'**
  String get signNotFound;

  /// No description provided for @signDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign detail'**
  String get signDetailTitle;

  /// No description provided for @detailEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get detailEnglish;

  /// No description provided for @detailNepali.
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get detailNepali;

  /// No description provided for @detailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCategory;

  /// No description provided for @detailMeaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get detailMeaning;

  /// No description provided for @signVideoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign video coming soon'**
  String get signVideoComingSoon;

  /// No description provided for @previewImage.
  ///
  /// In en, this message translates to:
  /// **'Preview image'**
  String get previewImage;

  /// No description provided for @couldNotLoadVideo.
  ///
  /// In en, this message translates to:
  /// **'Could not load video'**
  String get couldNotLoadVideo;

  /// No description provided for @videoCheckApiRunning.
  ///
  /// In en, this message translates to:
  /// **'Check that the API is running and try again.'**
  String get videoCheckApiRunning;

  /// No description provided for @videoReadyLater.
  ///
  /// In en, this message translates to:
  /// **'Video ready — playback in next update'**
  String get videoReadyLater;

  /// No description provided for @missingData.
  ///
  /// In en, this message translates to:
  /// **'Missing data.'**
  String get missingData;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHereYet;

  /// No description provided for @apiCategoriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load categories ({statusCode}). Is the API running?'**
  String apiCategoriesLoadFailed(int statusCode);

  /// No description provided for @apiCategoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get apiCategoryNotFound;

  /// No description provided for @apiCategorySignsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load category signs ({statusCode}). Is the API running?'**
  String apiCategorySignsLoadFailed(int statusCode);

  /// No description provided for @apiBrowseDictionaryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load dictionary ({statusCode}). Is the API running?'**
  String apiBrowseDictionaryLoadFailed(int statusCode);

  /// No description provided for @apiSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed ({statusCode}). Is the API running?'**
  String apiSearchFailed(int statusCode);

  /// No description provided for @apiSignNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sign not found'**
  String get apiSignNotFound;

  /// No description provided for @apiSignLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load sign ({statusCode}). Is the API running?'**
  String apiSignLoadFailed(int statusCode);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
