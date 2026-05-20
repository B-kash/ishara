import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ishara/api/sign_api_client.dart';
import 'package:ishara/main.dart';

http.Response utf8JsonResponse(String body, {int statusCode = 200}) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  testWidgets('home screen shows Ishara and search', (WidgetTester tester) async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        return utf8JsonResponse('{"items":[]}');
      }),
    );

    await tester.pumpWidget(IsharaApp(signApiClient: signApiClient));

    expect(find.text('Ishara'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Nepali'), findsOneWidget);
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
        return http.Response('Not found', 404);
      }),
    );

    await tester.pumpWidget(IsharaApp(signApiClient: signApiClient));

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.textContaining('नमस्ते'), findsOneWidget);
  });
}
