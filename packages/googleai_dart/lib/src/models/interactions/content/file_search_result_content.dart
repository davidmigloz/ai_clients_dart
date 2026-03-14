part of 'content.dart';

/// A File Search result content block.
class FileSearchResultContent extends InteractionContent {
  @override
  String get type => 'file_search_result';

  /// ID to match the ID from the file search call block.
  final String? callId;

  /// The results of the File Search.
  final List<FileSearchResult>? result;

  /// Creates a [FileSearchResultContent] instance.
  const FileSearchResultContent({this.callId, this.result});

  /// Creates a [FileSearchResultContent] from JSON.
  factory FileSearchResultContent.fromJson(Map<String, dynamic> json) =>
      FileSearchResultContent(
        callId: json['call_id'] as String?,
        result: (json['result'] as List<dynamic>?)
            ?.map((e) => FileSearchResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (callId != null) 'call_id': callId,
    if (result != null) 'result': result!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  FileSearchResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
  }) {
    return FileSearchResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId as String?,
      result: result == unsetCopyWithValue
          ? this.result
          : result as List<FileSearchResult>?,
    );
  }
}

/// A File Search result item.
class FileSearchResult {
  /// The title of the search result.
  final String? title;

  /// The text of the search result.
  final String? text;

  /// The name of the file search store.
  final String? fileSearchStore;

  /// Creates a [FileSearchResult] instance.
  const FileSearchResult({this.title, this.text, this.fileSearchStore});

  /// Creates a [FileSearchResult] from JSON.
  factory FileSearchResult.fromJson(Map<String, dynamic> json) =>
      FileSearchResult(
        title: json['title'] as String?,
        text: json['text'] as String?,
        fileSearchStore: json['file_search_store'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (text != null) 'text': text,
    if (fileSearchStore != null) 'file_search_store': fileSearchStore,
  };

  /// Creates a copy with replaced values.
  FileSearchResult copyWith({
    Object? title = unsetCopyWithValue,
    Object? text = unsetCopyWithValue,
    Object? fileSearchStore = unsetCopyWithValue,
  }) {
    return FileSearchResult(
      title: title == unsetCopyWithValue ? this.title : title as String?,
      text: text == unsetCopyWithValue ? this.text : text as String?,
      fileSearchStore: fileSearchStore == unsetCopyWithValue
          ? this.fileSearchStore
          : fileSearchStore as String?,
    );
  }
}
