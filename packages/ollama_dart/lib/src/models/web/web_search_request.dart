import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request for web search.
@immutable
class WebSearchRequest {
  /// Search query string.
  final String query;

  /// Maximum number of results to return (1-10).
  final int? maxResults;

  /// Creates a [WebSearchRequest].
  const WebSearchRequest({required this.query, this.maxResults});

  /// Creates a [WebSearchRequest] from JSON.
  factory WebSearchRequest.fromJson(Map<String, dynamic> json) =>
      WebSearchRequest(
        query: json['query'] as String,
        maxResults: json['max_results'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'query': query,
    if (maxResults != null) 'max_results': maxResults,
  };

  /// Creates a copy with replaced values.
  WebSearchRequest copyWith({
    String? query,
    Object? maxResults = unsetCopyWithValue,
  }) {
    return WebSearchRequest(
      query: query ?? this.query,
      maxResults: maxResults == unsetCopyWithValue
          ? this.maxResults
          : maxResults as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchRequest &&
          runtimeType == other.runtimeType &&
          query == other.query;

  @override
  int get hashCode => query.hashCode;

  @override
  String toString() => 'WebSearchRequest(query: $query)';
}
