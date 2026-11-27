part of 'deltas.dart';

/// A partial update for a server-side tool search call.
class ToolSearchCallDelta extends StepDeltaData {
  @override
  String get type => 'tool_search_call';

  /// The requested functions, when present in this delta.
  final ToolSearchCallStepArguments? arguments;

  /// Opaque server signature, when present in this delta.
  final String? signature;

  /// Creates a tool search call delta.
  const ToolSearchCallDelta({this.arguments, this.signature});

  /// Parses a partial tool search call.
  factory ToolSearchCallDelta.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'tool_search_call') {
      throw const FormatException(
        'ToolSearchCallDelta: expected type "tool_search_call"',
      );
    }
    final arguments = json['arguments'];
    return ToolSearchCallDelta(
      arguments: arguments == null
          ? null
          : ToolSearchCallStepArguments.fromJson(
              arguments as Map<String, dynamic>,
            ),
      signature: json['signature'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments!.toJson(),
    if (signature != null) 'signature': signature,
  };
}
