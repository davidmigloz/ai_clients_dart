part of 'deltas.dart';

/// A server-initiated media processing delta.
final class ProcessingCallDelta extends StepDeltaData {
  @override
  String get type => 'processing_call';

  /// Opaque signature for replay and backend validation.
  final String? signature;

  /// Additional wire fields retained for forward compatibility.
  final Map<String, dynamic> additionalProperties;

  /// Creates a [ProcessingCallDelta].
  const ProcessingCallDelta({
    this.signature,
    this.additionalProperties = const {},
  });

  /// Reads a [ProcessingCallDelta] from the Interactions wire format.
  factory ProcessingCallDelta.fromJson(Map<String, dynamic> json) =>
      ProcessingCallDelta(
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
  ProcessingCallDelta copyWith({
    Object? signature = unsetCopyWithValue,
    Map<String, dynamic>? additionalProperties,
  }) => ProcessingCallDelta(
    signature: signature == unsetCopyWithValue
        ? this.signature
        : signature as String?,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );
}
