part of 'deltas.dart';

/// A streamed delta for a Google Search tool call.
class GoogleSearchCallDelta extends StepDeltaData {
  @override
  String get type => 'google_search_call';

  /// The arguments for the Google Search call.
  final GoogleSearchCallStepArguments? arguments;

  /// Signature hash for backend validation.
  final String? signature;

  /// Creates a [GoogleSearchCallDelta] instance.
  const GoogleSearchCallDelta({this.arguments, this.signature});

  /// Creates a [GoogleSearchCallDelta] from JSON.
  factory GoogleSearchCallDelta.fromJson(Map<String, dynamic> json) =>
      GoogleSearchCallDelta(
        arguments: json['arguments'] is Map<String, dynamic>
            ? GoogleSearchCallStepArguments.fromJson(
                json['arguments'] as Map<String, dynamic>,
              )
            : null,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments!.toJson(),
    if (signature != null) 'signature': signature,
  };
}
