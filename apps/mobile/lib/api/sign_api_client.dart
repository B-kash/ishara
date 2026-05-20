import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import '../models/sign_detail.dart';
import '../models/sign_search_result.dart';

class SignApiException implements Exception {
  SignApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SignApiClient {
  SignApiClient({
    String? baseUrl,
    http.Client? httpClient,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client httpClient;

  Future<List<Category>> getCategories() async {
    final uri = Uri.parse('$baseUrl/categories');
    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw SignApiException(
        'Could not load categories (${response.statusCode}). Is the API running?',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((entry) => Category.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  Future<List<SignSearchResult>> getSignsByCategory({
    required String categoryId,
    required SearchLanguage language,
  }) async {
    final languageCode = language.apiCode;
    final uri = Uri.parse('$baseUrl/categories/$categoryId/signs').replace(
      queryParameters: {'lang': languageCode},
    );

    final response = await httpClient.get(uri);

    if (response.statusCode == 404) {
      throw SignApiException('Category not found');
    }
    if (response.statusCode != 200) {
      throw SignApiException(
        'Could not load category signs (${response.statusCode}). Is the API running?',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map(
          (entry) =>
              SignSearchResult.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<SignSearchResult>> searchSigns({
    required String query,
    required SearchLanguage language,
  }) async {
    final languageCode = language.apiCode;
    final uri = Uri.parse('$baseUrl/signs/search').replace(
      queryParameters: {
        'q': query,
        'lang': languageCode,
      },
    );

    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw SignApiException(
        'Search failed (${response.statusCode}). Is the API running?',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map(
          (entry) =>
              SignSearchResult.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<SignDetail> getSignById(String signId) async {
    final uri = Uri.parse('$baseUrl/signs/$signId');
    final response = await httpClient.get(uri);

    if (response.statusCode == 404) {
      throw SignApiException('Sign not found');
    }
    if (response.statusCode != 200) {
      throw SignApiException(
        'Could not load sign (${response.statusCode}). Is the API running?',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return SignDetail.fromJson(body);
  }
}
