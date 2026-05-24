part of 'deltas.dart';

/// A streamed delta for a URL context result.
class UrlContextResultDelta extends StepDeltaData {
  @override
  String get type => 'url_context_result';

  /// The results of the URL context retrieval.
  final List<UrlContextResultItem>? result;

  /// Whether the tool call resulted in an error.
  final bool? isError;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [UrlContextResultDelta] instance.
  const UrlContextResultDelta({this.result, this.isError, this.signature});

  /// Creates a [UrlContextResultDelta] from JSON.
  factory UrlContextResultDelta.fromJson(Map<String, dynamic> json) =>
      UrlContextResultDelta(
        result: (json['result'] as List<dynamic>?)
            ?.map(
              (e) => UrlContextResultItem.fromJson(e as Map<String, dynamic>),
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
