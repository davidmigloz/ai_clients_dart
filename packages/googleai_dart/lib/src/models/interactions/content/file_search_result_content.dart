part of 'content.dart';

/// A File Search result content block.
class FileSearchResultContent extends InteractionContent {
  @override
  String get type => 'file_search_result';

  /// ID to match the ID from the file search call block.
  final String callId;

  /// The results of the File Search.
  final List<FileSearchResult> result;

  /// The signature of the file search result.
  final String? signature;

  /// Creates a [FileSearchResultContent] instance.
  const FileSearchResultContent({
    required this.callId,
    required this.result,
    this.signature,
  });

  /// Creates a [FileSearchResultContent] from JSON.
  ///
  /// Required fields default to empty values when absent
  /// (e.g. content.start events).
  factory FileSearchResultContent.fromJson(Map<String, dynamic> json) =>
      FileSearchResultContent(
        callId: json['call_id'] as String? ?? '',
        result:
            (json['result'] as List<dynamic>?)
                ?.map(
                  (e) => FileSearchResult.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  FileSearchResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return FileSearchResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<FileSearchResult>,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A File Search result item.
class FileSearchResult {
  /// User provided metadata about the FileSearchResult.
  final List<Map<String, dynamic>>? customMetadata;

  /// Creates a [FileSearchResult] instance.
  const FileSearchResult({this.customMetadata});

  /// Creates a [FileSearchResult] from JSON.
  factory FileSearchResult.fromJson(Map<String, dynamic> json) =>
      FileSearchResult(
        customMetadata: (json['custom_metadata'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (customMetadata != null) 'custom_metadata': customMetadata,
  };

  /// Creates a copy with replaced values.
  FileSearchResult copyWith({Object? customMetadata = unsetCopyWithValue}) {
    return FileSearchResult(
      customMetadata: customMetadata == unsetCopyWithValue
          ? this.customMetadata
          : customMetadata as List<Map<String, dynamic>>?,
    );
  }
}
