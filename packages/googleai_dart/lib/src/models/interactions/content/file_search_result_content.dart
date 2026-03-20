part of 'content.dart';

/// A File Search result content block.
class FileSearchResultContent extends InteractionContent {
  @override
  String get type => 'file_search_result';

  /// ID to match the ID from the file search call block.
  final String? callId;

  /// The results of the File Search.
  final List<FileSearchResult>? result;

  /// The signature of the file search result.
  final String? signature;

  /// Creates a [FileSearchResultContent] instance.
  const FileSearchResultContent({this.callId, this.result, this.signature});

  /// Creates a [FileSearchResultContent] from JSON.
  factory FileSearchResultContent.fromJson(Map<String, dynamic> json) =>
      FileSearchResultContent(
        callId: json['call_id'] as String?,
        result: (json['result'] as List<dynamic>?)
            ?.map((e) => FileSearchResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (callId != null) 'call_id': callId,
    if (result != null) 'result': result!.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FileSearchResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FileSearchResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId as String?,
      result: result == unsetCopyWithValue
          ? this.result
          : result as List<FileSearchResult>?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A File Search result item.
class FileSearchResult {
  /// Creates a [FileSearchResult] instance.
  const FileSearchResult();

  /// Creates a [FileSearchResult] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory FileSearchResult.fromJson(Map<String, dynamic> json) =>
      const FileSearchResult();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {};
}
