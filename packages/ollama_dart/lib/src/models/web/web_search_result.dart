import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A single web search result.
@immutable
class WebSearchResult {
  /// Page title of the result.
  final String? title;

  /// Resolved URL for the result.
  final String? url;

  /// Extracted text content snippet.
  final String? content;

  /// Creates a [WebSearchResult].
  const WebSearchResult({this.title, this.url, this.content});

  /// Creates a [WebSearchResult] from JSON.
  factory WebSearchResult.fromJson(Map<String, dynamic> json) =>
      WebSearchResult(
        title: json['title'] as String?,
        url: json['url'] as String?,
        content: json['content'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (url != null) 'url': url,
    if (content != null) 'content': content,
  };

  /// Creates a copy with replaced values.
  WebSearchResult copyWith({
    Object? title = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
  }) {
    return WebSearchResult(
      title: title == unsetCopyWithValue ? this.title : title as String?,
      url: url == unsetCopyWithValue ? this.url : url as String?,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchResult &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'WebSearchResult(title: $title, url: $url)';
}
