part of 'content.dart';

/// A File Search call content block.
class FileSearchCallContent extends InteractionContent {
  @override
  String get type => 'file_search_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// Creates a [FileSearchCallContent] instance.
  const FileSearchCallContent({this.id});

  /// Creates a [FileSearchCallContent] from JSON.
  factory FileSearchCallContent.fromJson(Map<String, dynamic> json) =>
      FileSearchCallContent(id: json['id'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': type, if (id != null) 'id': id};

  /// Creates a copy with replaced values.
  FileSearchCallContent copyWith({Object? id = unsetCopyWithValue}) {
    return FileSearchCallContent(
      id: id == unsetCopyWithValue ? this.id : id as String?,
    );
  }
}
