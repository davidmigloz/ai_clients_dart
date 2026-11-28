part of 'deltas.dart';

/// The result of a server-initiated media processing delta.
final class ProcessingResultDelta extends StepDeltaData {
  @override
  String get type => 'processing_result';

  /// Opaque signature for replay and backend validation.
  final String? signature;

  /// Additional wire fields retained for forward compatibility.
  final Map<String, dynamic> additionalProperties;

  /// Creates a [ProcessingResultDelta].
  const ProcessingResultDelta({
    this.signature,
    this.additionalProperties = const {},
  });

  /// Reads a [ProcessingResultDelta] from the Interactions wire format.
  factory ProcessingResultDelta.fromJson(Map<String, dynamic> json) =>
      ProcessingResultDelta(
        signature: json['signature'] as String?,
        additionalProperties: mediaExtensions(json, const {
          'type',
          'signature',
        }),
      );

  @override
  Map<String, dynamic> toJson() => {
    ...additionalProperties,
    'type': type,
    'signature': ?signature,
  };

  /// Creates a copy with updated fields.
  ProcessingResultDelta copyWith({
    Object? signature = unsetCopyWithValue,
    Map<String, dynamic>? additionalProperties,
  }) => ProcessingResultDelta(
    signature: signature == unsetCopyWithValue
        ? this.signature
        : signature as String?,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );
}
