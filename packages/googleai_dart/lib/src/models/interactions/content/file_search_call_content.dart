part of 'content.dart';

/// A File Search call content block.
class FileSearchCallContent extends InteractionContent {
  @override
  String get type => 'file_search_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The signature of the file search call.
  final String? signature;

  /// Creates a [FileSearchCallContent] instance.
  const FileSearchCallContent({required this.id, this.signature});

  /// Creates a [FileSearchCallContent] from JSON.
  ///
  /// The [id] field defaults to `''` when absent (e.g. content.start events).
  factory FileSearchCallContent.fromJson(Map<String, dynamic> json) =>
      FileSearchCallContent(
        id: json['id'] as String? ?? '',
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FileSearchCallContent copyWith({
    Object? id = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FileSearchCallContent(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
