import 'dart:convert';

import 'package:ishara/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import '../models/sign_browse_page.dart';
import '../models/sign_detail.dart';
import '../models/sign_search_result.dart';

enum SignApiErrorKind {
  categoriesLoadFailed,
  categoryNotFound,
  categorySignsLoadFailed,
  browseDictionaryLoadFailed,
  searchFailed,
  signNotFound,
  signLoadFailed,
}

class SignApiException implements Exception {
  SignApiException(this.kind, {this.statusCode});

  final SignApiErrorKind kind;
  final int? statusCode;

  String localize(AppLocalizations l10n) {
    final statusCode = this.statusCode ?? 0;

    switch (kind) {
      case SignApiErrorKind.categoriesLoadFailed:
        return l10n.apiCategoriesLoadFailed(statusCode);
      case SignApiErrorKind.categoryNotFound:
        return l10n.apiCategoryNotFound;
      case SignApiErrorKind.categorySignsLoadFailed:
        return l10n.apiCategorySignsLoadFailed(statusCode);
      case SignApiErrorKind.browseDictionaryLoadFailed:
        return l10n.apiBrowseDictionaryLoadFailed(statusCode);
      case SignApiErrorKind.searchFailed:
        return l10n.apiSearchFailed(statusCode);
      case SignApiErrorKind.signNotFound:
        return l10n.apiSignNotFound;
      case SignApiErrorKind.signLoadFailed:
        return l10n.apiSignLoadFailed(statusCode);
    }
  }

  @override
  String toString() => kind.name;
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
        SignApiErrorKind.categoriesLoadFailed,
        statusCode: response.statusCode,
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
      throw SignApiException(SignApiErrorKind.categoryNotFound);
    }
    if (response.statusCode != 200) {
      throw SignApiException(
        SignApiErrorKind.categorySignsLoadFailed,
        statusCode: response.statusCode,
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

  Future<SignBrowsePage> listSigns({
    required SearchLanguage language,
    String? cursor,
    int limit = 20,
    String? letter,
    SearchLanguage? letterLanguage,
  }) async {
    final queryParameters = <String, String>{
      'lang': language.apiCode,
      'limit': limit.toString(),
    };

    if (cursor != null) {
      queryParameters['cursor'] = cursor;
    }

    if (letter != null && letterLanguage != null) {
      queryParameters['letter'] = letter;
      queryParameters['letterLang'] = letterLanguage.apiCode;
    }

    final uri = Uri.parse('$baseUrl/signs').replace(
      queryParameters: queryParameters,
    );

    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw SignApiException(
        SignApiErrorKind.browseDictionaryLoadFailed,
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return SignBrowsePage.fromJson(body);
  }

  Future<List<SignSearchResult>> searchSigns({
    required String query,
  }) async {
    final uri = Uri.parse('$baseUrl/signs/search').replace(
      queryParameters: {
        'q': query,
      },
    );

    final response = await httpClient.get(uri);

    if (response.statusCode != 200) {
      throw SignApiException(
        SignApiErrorKind.searchFailed,
        statusCode: response.statusCode,
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
      throw SignApiException(SignApiErrorKind.signNotFound);
    }
    if (response.statusCode != 200) {
      throw SignApiException(
        SignApiErrorKind.signLoadFailed,
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return SignDetail.fromJson(body);
  }
}
