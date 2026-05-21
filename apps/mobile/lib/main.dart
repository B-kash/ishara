import 'package:flutter/material.dart';

import 'api/sign_api_client.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  await themeController.loadSavedTheme();

  runApp(
    IsharaApp(
      signApiClient: SignApiClient(),
      themeController: themeController,
    ),
  );
}

class IsharaApp extends StatelessWidget {
  const IsharaApp({
    required this.signApiClient,
    required this.themeController,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ishara',
          theme: themeController.themeData,
          home: HomeScreen(
            signApiClient: signApiClient,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
