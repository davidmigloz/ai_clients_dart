part of 'deltas.dart';

/// A streamed delta for a Retrieval tool result.
///
/// Used by Vertex Retrieval tools such as Parallel AI, Exa AI, Vertex AI
/// Search, etc.
class RetrievalResultDelta extends StepDeltaData {
  @override
  String get type => 'retrieval_result';

  /// Whether the retrieval resulted in an error.
  final bool? isError;

  /// A signature hash for backend validation.
  final String? signature;

  /// Creates a [RetrievalResultDelta] instance.
  const RetrievalResultDelta({this.isError, this.signature});

  /// Creates a [RetrievalResultDelta] from JSON.
  factory RetrievalResultDelta.fromJson(Map<String, dynamic> json) =>
      RetrievalResultDelta(
        isError: json['is_error'] as bool?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (isError != null) 'is_error': isError,
    if (signature != null) 'signature': signature,
  };

  /// Creates a copy with replaced values.
  RetrievalResultDelta copyWith({
    Object? isError = unsetCopyWithValue,
    Object? signature = unsetCopyWithValue,
  }) {
    return RetrievalResultDelta(
      isError: isError == unsetCopyWithValue ? this.isError : isError as bool?,
      signature: signature == unsetCopyWithValue
          ? this.signature
          : signature as String?,
    );
  }
}
