import 'package:flutter/material.dart';

import 'api/sign_api_client.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    IsharaApp(
      signApiClient: SignApiClient(),
    ),
  );
}

class IsharaApp extends StatelessWidget {
  const IsharaApp({required this.signApiClient, super.key});

  final SignApiClient signApiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ishara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(signApiClient: signApiClient),
    );
  }
}
