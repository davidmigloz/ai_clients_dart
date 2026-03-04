import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'web_search_result.dart';

/// Response from web search.
@immutable
class WebSearchResponse {
  /// Array of matching search results.
  final List<WebSearchResult>? results;

  /// Creates a [WebSearchResponse].
  const WebSearchResponse({this.results});

  /// Creates a [WebSearchResponse] from JSON.
  factory WebSearchResponse.fromJson(Map<String, dynamic> json) =>
      WebSearchResponse(
        results: (json['results'] as List?)
            ?.map((e) => WebSearchResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (results != null) 'results': results!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WebSearchResponse copyWith({Object? results = unsetCopyWithValue}) {
    return WebSearchResponse(
      results: results == unsetCopyWithValue
          ? this.results
          : results as List<WebSearchResult>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(results, other.results);

  @override
  int get hashCode => listHash(results);

  @override
  String toString() =>
      'WebSearchResponse(results: ${results?.length ?? 0} results)';
}
