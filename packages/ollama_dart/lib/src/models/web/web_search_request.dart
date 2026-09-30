import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request for web search.
@immutable
class WebSearchRequest {
  /// Search query string.
  final String query;

  /// Maximum results (at most ten). Omit to use the server default of five.
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
          query == other.query &&
          maxResults == other.maxResults;

  @override
  int get hashCode => Object.hash(query, maxResults);

  @override
  String toString() =>
      'WebSearchRequest(query: $query, maxResults: $maxResults)';
}
