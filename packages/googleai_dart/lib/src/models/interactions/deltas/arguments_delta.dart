part of 'deltas.dart';

/// An arguments delta update.
///
/// Streams partial JSON-encoded arguments as they are produced for a
/// tool-call step (e.g. function call, code execution call).
class ArgumentsDelta extends StepDeltaData {
  @override
  String get type => 'arguments_delta';

  /// A partial JSON-encoded fragment of the arguments object.
  final String? arguments;

  /// Creates an [ArgumentsDelta] instance.
  const ArgumentsDelta({this.arguments});

  /// Creates an [ArgumentsDelta] from JSON.
  factory ArgumentsDelta.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'arguments_delta') {
      throw FormatException(
        'Expected type "arguments_delta" but got "${json['type']}"',
      );
    }
    return ArgumentsDelta(arguments: json['arguments'] as String?);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (arguments != null) 'arguments': arguments,
  };
}
