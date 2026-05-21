import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api/sign_api_client.dart';
import 'locale/locale_controller.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  final localeController = LocaleController();

  await Future.wait([
    themeController.loadSavedTheme(),
    localeController.loadSavedLocale(),
  ]);

  runApp(
    IsharaApp(
      signApiClient: SignApiClient(),
      themeController: themeController,
      localeController: localeController,
    ),
  );
}

class IsharaApp extends StatelessWidget {
  const IsharaApp({
    required this.signApiClient,
    required this.themeController,
    required this.localeController,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeController, localeController]),
      builder: (context, child) {
        return MaterialApp(
          title: 'Ishara',
          theme: themeController.themeData,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale != null) {
              for (final supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == deviceLocale.languageCode) {
                  return supportedLocale;
                }
              }
            }

            return const Locale('en');
          },
          home: HomeScreen(
            signApiClient: signApiClient,
            themeController: themeController,
            localeController: localeController,
          ),
        );
      },
    );
  }
}
