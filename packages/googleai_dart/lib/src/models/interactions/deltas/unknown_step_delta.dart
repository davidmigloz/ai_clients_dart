part of 'deltas.dart';

/// A `step.delta` payload whose `type` is not one of the documented
/// [StepDeltaData] variants.
///
/// During streaming, the Interactions API also emits tool-call/result payloads
/// (e.g. `google_search_call`, `url_context_result`) as `step.delta` events
/// whose `type` mirrors the corresponding step. These are not part of the
/// published `StepDeltaData` schema, so rather than failing the stream they are
/// surfaced here with their raw JSON preserved in [json]. This also keeps
/// parsing forward-compatible with future delta types.
class UnknownStepDelta extends StepDeltaData {
  @override
  final String type;

  /// The raw JSON payload of the delta, preserved verbatim.
  final Map<String, dynamic> json;

  /// Creates an [UnknownStepDelta] instance.
  const UnknownStepDelta({required this.type, required this.json});

  /// Creates an [UnknownStepDelta] from JSON.
  factory UnknownStepDelta.fromJson(Map<String, dynamic> json) =>
      UnknownStepDelta(type: json['type'] as String? ?? '', json: json);

  @override
  Map<String, dynamic> toJson() => json;
}
