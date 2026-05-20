import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ishara/api/sign_api_client.dart';
import 'package:ishara/models/search_language.dart';

void main() {
  test('searchSigns parses API response', () async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/signs/search');
        expect(request.url.queryParameters['q'], 'mother');
        expect(request.url.queryParameters['lang'], 'en');

        final responseBody = jsonEncode({
          'results': [
            {
              'id': 'mother',
              'conceptId': 'concept-mother',
              'englishWord': 'Mother',
              'nepaliWord': 'आमा',
              'meaningEnglish': 'A female parent.',
              'meaningNepali': 'महिला अभिभावक।',
              'category': 'Family',
              'videoUrl': null,
            },
          ],
        });

        return http.Response.bytes(
          utf8.encode(responseBody),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final results = await signApiClient.searchSigns(
      query: 'mother',
      language: SearchLanguage.english,
    );

    expect(results.length, 1);
    expect(results.first.englishWord, 'Mother');
  });
}
