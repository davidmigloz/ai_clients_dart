part of 'steps.dart';

/// An [InteractionStep] whose `type` is not one of the documented variants.
///
/// The Interactions API is experimental and evolving; new step types may be
/// returned in `steps` or streamed in `step.start` events before this client
/// models them. Such steps are surfaced here with their raw JSON preserved
/// instead of failing to parse, keeping streams resilient and
/// forward-compatible.
class UnknownStep extends InteractionStep {
  @override
  final String type;

  /// The raw JSON payload of the step, preserved verbatim.
  final Map<String, dynamic> json;

  /// Creates an [UnknownStep] instance.
  const UnknownStep({required this.type, required this.json});

  /// Creates an [UnknownStep] from JSON.
  factory UnknownStep.fromJson(Map<String, dynamic> json) =>
      UnknownStep(type: json['type'] as String? ?? '', json: json);

  @override
  Map<String, dynamic> toJson() => json;
}
