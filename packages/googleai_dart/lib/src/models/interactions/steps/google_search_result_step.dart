part of 'steps.dart';

/// Result of a Google Search call.
class GoogleSearchResultStep extends InteractionStep {
  @override
  String get type => 'google_search_result';

  /// ID matching the corresponding [GoogleSearchCallStep.id].
  final String callId;

  /// The results of the Google Search.
  final List<GoogleSearchResultItem> result;

  /// Whether the Google Search resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleSearchResultStep] instance.
  const GoogleSearchResultStep({
    required this.callId,
    required this.result,
    this.isError,
    this.signature,
  });

  /// Creates a [GoogleSearchResultStep] from JSON.
  factory GoogleSearchResultStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'google_search_result') {
      throw FormatException(
        'Expected type "google_search_result" but got "${json['type']}"',
      );
    }
    final callId = json['call_id'];
    if (callId is! String) {
      throw const FormatException(
        'GoogleSearchResultStep: missing required "call_id"',
      );
    }
    // In streaming `step.start`, the step arrives as a partial skeleton and
    // `result` is populated later via `step.delta`; default to empty when
    // absent.
    final resultJson = json['result'];
    final result = resultJson is List
        ? resultJson
              .map(
                (e) =>
                    GoogleSearchResultItem.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : <GoogleSearchResultItem>[];
    return GoogleSearchResultStep(
      callId: callId,
      result: result,
      isError: json['is_error'] as bool?,
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'result': result.map((e) => e.toJson()).toList(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  GoogleSearchResultStep copyWith({
    Object? callId = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return GoogleSearchResultStep(
      callId: callId == unsetCopyWithValue ? this.callId : callId! as String,
      result: result == unsetCopyWithValue
          ? this.result
          : result! as List<GoogleSearchResultItem>,
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}

/// A single result from a Google Search.
class GoogleSearchResultItem {
  /// Web content snippet that can be embedded in a web page or app webview.
  final String? searchSuggestions;

  /// Creates a [GoogleSearchResultItem] instance.
  const GoogleSearchResultItem({this.searchSuggestions});

  /// Creates from JSON.
  factory GoogleSearchResultItem.fromJson(Map<String, dynamic> json) =>
      GoogleSearchResultItem(
        searchSuggestions: json['search_suggestions'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (searchSuggestions != null) 'search_suggestions': searchSuggestions,
  };

  /// Creates a copy with replaced values.
  GoogleSearchResultItem copyWith({
    Object? searchSuggestions = unsetCopyWithValue,
  }) {
    return GoogleSearchResultItem(
      searchSuggestions: searchSuggestions == unsetCopyWithValue
          ? this.searchSuggestions
          : searchSuggestions as String?,
    );
  }
}
