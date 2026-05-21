import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ishara/api/sign_api_client.dart';
import 'package:ishara/locale/locale_controller.dart';
import 'package:ishara/main.dart';
import 'package:ishara/theme/ishara_theme.dart';
import 'package:ishara/theme/theme_controller.dart';

http.Response utf8JsonResponse(String body, {int statusCode = 200}) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Widget buildTestApp(SignApiClient signApiClient) {
  return IsharaApp(
    signApiClient: signApiClient,
    themeController: ThemeController(),
    localeController: LocaleController(),
  );
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home screen shows Ishara and search', (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/categories') {
          return utf8JsonResponse(
            jsonEncode({
              'items': [
                {'id': 'greetings', 'name': 'Greetings'},
              ],
            }),
          );
        }
        return utf8JsonResponse('{"items":[]}');
      }),
    );

    await tester.pumpWidget(buildTestApp(signApiClient));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Ishara'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
  });

  testWidgets('search navigates to API results', (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path.contains('search')) {
          return utf8JsonResponse(
            jsonEncode({
              'items': [
                {
                  'id': 'hello',
                  'englishWord': 'hello',
                  'nepaliWord': 'नमस्ते',
                  'category': 'Greetings',
                  'meaning': 'A greeting used when meeting someone.',
                },
              ],
            }),
          );
        }
        if (request.url.path == '/categories') {
          return utf8JsonResponse('{"items":[]}');
        }
        return http.Response('Not found', 404);
      }),
    );

    await tester.pumpWidget(buildTestApp(signApiClient));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.textContaining('नमस्ते'), findsOneWidget);
  });

  testWidgets('search shows empty state when API returns no items',
      (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path.contains('search')) {
          return utf8JsonResponse('{"items":[]}');
        }
        if (request.url.path == '/categories') {
          return utf8JsonResponse('{"items":[]}');
        }
        return http.Response('Not found', 404);
      }),
    );

    await tester.pumpWidget(buildTestApp(signApiClient));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'zzznomatch');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('No results'), findsOneWidget);
    expect(
      find.text('No signs found. Try another word or category.'),
      findsOneWidget,
    );
  });

  testWidgets('search shows error state when API fails',
      (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path.contains('search')) {
          return http.Response('Server error', 500);
        }
        if (request.url.path == '/categories') {
          return utf8JsonResponse('{"items":[]}');
        }
        return http.Response('Not found', 404);
      }),
    );

    await tester.pumpWidget(buildTestApp(signApiClient));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Could not reach the API'), findsOneWidget);
    expect(find.textContaining('500'), findsNothing);
    expect(find.text('Try again'), findsWidgets);
  });

  testWidgets('home shows error when categories fail to load',
      (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/categories') {
          return http.Response('Server error', 500);
        }
        return utf8JsonResponse('{"items":[]}');
      }),
    );

    await tester.pumpWidget(buildTestApp(signApiClient));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Could not load categories'), findsOneWidget);
    expect(find.textContaining('500'), findsNothing);
    expect(find.text('Try again'), findsWidgets);
  });

  testWidgets('theme menu switches app theme', (WidgetTester tester) async {
    final themeController = ThemeController();
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/categories') {
          return utf8JsonResponse('{"items":[]}');
        }
        return utf8JsonResponse('{"items":[]}');
      }),
    );

    await tester.pumpWidget(
      IsharaApp(
        signApiClient: signApiClient,
        themeController: themeController,
        localeController: LocaleController(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(themeController.currentTheme, IsharaThemeId.purple);

    await tester.tap(find.byIcon(Icons.palette_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ocean').last);
    await tester.pumpAndSettle();

    expect(themeController.currentTheme, IsharaThemeId.teal);
    expect(find.text('Ishara'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
