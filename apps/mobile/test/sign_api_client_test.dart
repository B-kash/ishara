import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ishara/api/sign_api_client.dart';
void main() {
  test('searchSigns parses API response', () async {
    final signApiClient = SignApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/signs/search');
        expect(request.url.queryParameters['q'], 'mother');
        expect(request.url.queryParameters.containsKey('lang'), isFalse);

        final responseBody = jsonEncode({
          'items': [
            {
              'id': 'mother',
              'englishWord': 'mother',
              'nepaliWord': 'आमा',
              'category': 'Family',
              'meaning': 'A female parent.',
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

    final results = await signApiClient.searchSigns(query: 'mother');

    expect(results.length, 1);
    expect(results.first.englishWord, 'mother');
    expect(results.first.meaning, 'A female parent.');
  });
}
