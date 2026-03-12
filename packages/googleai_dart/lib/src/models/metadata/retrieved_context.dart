import '../common/grounding_chunk_custom_metadata.dart';
import '../copy_with_sentinel.dart';

/// Chunk from context retrieved by the file search tool.
class RetrievedContext {
  /// Optional. URI reference of the semantic retrieval document.
  final String? uri;

  /// Optional. Title of the document.
  final String? title;

  /// Optional. Text of the chunk.
  final String? text;

  /// Optional. Name of the `FileSearchStore` containing the document.
  ///
  /// Example: `fileSearchStores/123`
  final String? fileSearchStore;

  /// Optional. Custom metadata associated with the retrieved context.
  final List<GroundingChunkCustomMetadata>? customMetadata;

  /// Creates a [RetrievedContext].
  const RetrievedContext({
    this.uri,
    this.title,
    this.text,
    this.fileSearchStore,
    this.customMetadata,
  });

  /// Creates a [RetrievedContext] from JSON.
  factory RetrievedContext.fromJson(Map<String, dynamic> json) =>
      RetrievedContext(
        uri: json['uri'] as String?,
        title: json['title'] as String?,
        text: json['text'] as String?,
        fileSearchStore: json['fileSearchStore'] as String?,
        customMetadata: (json['customMetadata'] as List?)
            ?.map(
              (e) => GroundingChunkCustomMetadata.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (uri != null) 'uri': uri,
    if (title != null) 'title': title,
    if (text != null) 'text': text,
    if (fileSearchStore != null) 'fileSearchStore': fileSearchStore,
    if (customMetadata != null)
      'customMetadata': customMetadata!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  RetrievedContext copyWith({
    Object? uri = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? fileSearchStore = unsetCopyWithValue,
    Object? customMetadata = unsetCopyWithValue,
  }) {
    return RetrievedContext(
      uri: uri == unsetCopyWithValue ? this.uri : uri as String?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      text: text == unsetCopyWithValue ? this.text : text as String?,
      fileSearchStore: fileSearchStore == unsetCopyWithValue
          ? this.fileSearchStore
          : fileSearchStore as String?,
      customMetadata: customMetadata == unsetCopyWithValue
          ? this.customMetadata
          : customMetadata as List<GroundingChunkCustomMetadata>?,
    );
  }

  @override
  String toString() =>
      'RetrievedContext(uri: $uri, title: $title, text: $text, fileSearchStore: $fileSearchStore, customMetadata: $customMetadata)';
}
