part of 'steps.dart';

/// A server-initiated media processing step.
final class ProcessingCallStep extends InteractionStep {
  @override
  String get type => 'processing_call';

  /// The identifier linking this call and its result.
  final String id;

  /// Opaque signature for replay and backend validation.
  final String? signature;

  /// Additional wire fields retained for forward compatibility.
  final Map<String, dynamic> additionalProperties;

  /// Creates a [ProcessingCallStep].
  const ProcessingCallStep({
    required this.id,
    this.signature,
    this.additionalProperties = const {},
  });

  /// Reads a [ProcessingCallStep] from the Interactions wire format.
  factory ProcessingCallStep.fromJson(Map<String, dynamic> json) =>
      ProcessingCallStep(
        id: json['id'] as String,
        signature: json['signature'] as String?,
        additionalProperties: mediaExtensions(json, const {
          'type',
          'id',
          'signature',
        }),
      );

  @override
  Map<String, dynamic> toJson() => {
    ...additionalProperties,
    'type': type,
    'id': id,
    'signature': ?signature,
  };

  /// Creates a copy with updated fields.
  ProcessingCallStep copyWith({
    String? id,
    Object? signature = unsetCopyWithValue,
    Map<String, dynamic>? additionalProperties,
  }) => ProcessingCallStep(
    id: id ?? this.id,
    signature: signature == unsetCopyWithValue
        ? this.signature
        : signature as String?,
    additionalProperties: additionalProperties ?? this.additionalProperties,
  );
}
