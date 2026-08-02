import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// The raw Vespa schema definition (`.sd` file) of a RAG search index schema
/// (beta).
@immutable
class SearchIndexSchemaSdFile {
  /// The raw `.sd` file content, or `null` if unavailable.
  final String? content;

  /// Creates a [SearchIndexSchemaSdFile].
  const SearchIndexSchemaSdFile({required this.content});

  /// Creates a [SearchIndexSchemaSdFile] from JSON.
  factory SearchIndexSchemaSdFile.fromJson(Map<String, dynamic> json) =>
      SearchIndexSchemaSdFile(content: json['content'] as String?);

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'content': content};

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` to clear [content] explicitly; omit to keep.
  SearchIndexSchemaSdFile copyWith({Object? content = unsetCopyWithValue}) =>
      SearchIndexSchemaSdFile(
        content: content == unsetCopyWithValue
            ? this.content
            : content as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexSchemaSdFile &&
          runtimeType == other.runtimeType &&
          content == other.content;

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() => 'SearchIndexSchemaSdFile(content: $content)';
}
