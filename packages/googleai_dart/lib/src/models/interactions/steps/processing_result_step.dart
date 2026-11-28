part of 'steps.dart';

/// The result of a server-initiated media processing step.
final class ProcessingResultStep extends InteractionStep {
  @override
  String get type => 'processing_result';

  /// The identifier linking this call and its result.
  final String callId;

  /// Opaque signature for replay and backend validation.
  final String? signature;

  /// Additional wire fields retained for forward compatibility.
  final Map<String, dynamic> additionalProperties;

  /// Creates a [ProcessingResultStep].
  const ProcessingResultStep({
    required this.callId,
    this.signature,
    this.additionalProperties = const {},
  });

  /// Reads a [ProcessingResultStep] from the Interactions wire format.
  factory ProcessingResultStep.fromJson(Map<String, dynamic> json) =>
      ProcessingResultStep(
        callId: json['call_id'] as String,
        signature: json['signature'] as String?,
        additionalProperties: mediaExtensions(json, const {
          'type',
          'call_id',
          'signature',
        }),
      );

  @override
  Map<String, dynamic> toJson() => {
    ...additionalProperties,
    'type': type,
    'call_id': callId,
    'signature': ?signature,
  };

  /// Creates a copy with updated fields.
  ProcessingResultStep copyWith({
    String? callId,
    Object? signature = unsetCopyWithValue,
    Map<String, dynamic>? additionalProperties,
  }) => ProcessingResultStep(
    callId: callId ?? this.callId,
    signature: signature == unsetCopyWithValue
        ? this.signature
        : signature as String?,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );
}
