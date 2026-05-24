part of 'deltas.dart';

/// A streamed delta for a Google Search result.
class GoogleSearchResultDelta extends StepDeltaData {
  @override
  String get type => 'google_search_result';

  /// The results of the Google Search query.
  final List<GoogleSearchResultItem>? result;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleSearchResultDelta] instance.
  const GoogleSearchResultDelta({this.result, this.isError, this.signature});

  /// Creates a [GoogleSearchResultDelta] from JSON.
  factory GoogleSearchResultDelta.fromJson(Map<String, dynamic> json) =>
      GoogleSearchResultDelta(
        result: (json['result'] as List<dynamic>?)
            ?.map(
              (e) => GoogleSearchResultItem.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (result != null) 'result': result!.map((e) => e.toJson()).toList(),
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };
}
