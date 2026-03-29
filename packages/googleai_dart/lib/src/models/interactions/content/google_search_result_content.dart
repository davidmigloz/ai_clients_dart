part of 'content.dart';

/// A Google Search result content block.
class GoogleSearchResultContent extends InteractionContent {
  @override
  String get type => 'google_search_result';

  /// ID to match the ID from the Google Search call block.
  final String callId;

  /// The results of the Google Search.
  final List<GoogleSearchResult> result;

  /// Whether the Google Search resulted in an error.
  final bool? isError;

  /// The signature of the Google Search result.
  final String? signature;

  /// Creates a [GoogleSearchResultContent] instance.
  const GoogleSearchResultContent({
    required this.callId,
    required this.result,
    this.isError,
    this.signature,
  });

  /// Creates a [GoogleSearchResultContent] from JSON.
  ///
  /// Required fields default to empty values when absent
  /// (e.g. content.start events).
  factory GoogleSearchResultContent.fromJson(Map<String, dynamic> json) =>
      GoogleSearchResultContent(
        callId: json['call_id'] as String? ?? '',
        result:
            (json['result'] as List<dynamic>?)
                ?.map(
                  (e) => GoogleSearchResult.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            const [],
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleSearchResultContent copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleSearchResultContent(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<GoogleSearchResult>,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A Google Search result item.
class GoogleSearchResult {
  /// Search suggestions text.
  final String? searchSuggestions;

  /// Creates a [GoogleSearchResult] instance.
  const GoogleSearchResult({this.searchSuggestions});

  /// Creates a [GoogleSearchResult] from JSON.
  factory GoogleSearchResult.fromJson(Map<String, dynamic> json) =>
      GoogleSearchResult(
        searchSuggestions: json['search_suggestions'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchSuggestions != null) 'search_suggestions': searchSuggestions,
  };

  /// Creates a copy with replaced values.
  GoogleSearchResult copyWith({
    Object? searchSuggestions = unsetCopyWithValue,
  }) {
    return GoogleSearchResult(
      searchSuggestions: searchSuggestions == unsetCopyWithValue
          ? this.searchSuggestions
          : searchSuggestions as String?,
    );
  }
}
