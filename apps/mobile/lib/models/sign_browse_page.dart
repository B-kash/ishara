import 'sign_search_result.dart';

class SignBrowsePage {
  const SignBrowsePage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<SignSearchResult> items;
  final String? nextCursor;
  final bool hasMore;

  factory SignBrowsePage.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    final pageInfo = json['pageInfo'] as Map<String, dynamic>;

    return SignBrowsePage(
      items: itemsJson
          .map(
            (entry) =>
                SignSearchResult.fromJson(entry as Map<String, dynamic>),
          )
          .toList(),
      nextCursor: pageInfo['nextCursor'] as String?,
      hasMore: pageInfo['hasMore'] as bool,
    );
  }
}
