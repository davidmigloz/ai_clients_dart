import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response from fetching a web page.
@immutable
class WebFetchResponse {
  /// Title of the fetched page.
  final String? title;

  /// Extracted page content.
  final String? content;

  /// Links found on the page.
  final List<String>? links;

  /// Creates a [WebFetchResponse].
  const WebFetchResponse({this.title, this.content, this.links});

  /// Creates a [WebFetchResponse] from JSON.
  factory WebFetchResponse.fromJson(Map<String, dynamic> json) =>
      WebFetchResponse(
        title: json['title'] as String?,
        content: json['content'] as String?,
        links: (json['links'] as List?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (content != null) 'content': content,
    if (links != null) 'links': links,
  };

  /// Creates a copy with replaced values.
  WebFetchResponse copyWith({
    Object? title = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
    Object? links = unsetCopyWithValue,
  }) {
    return WebFetchResponse(
      title: title == unsetCopyWithValue ? this.title : title as String?,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      links: links == unsetCopyWithValue ? this.links : links as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchResponse &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() => 'WebFetchResponse(title: $title)';
}
