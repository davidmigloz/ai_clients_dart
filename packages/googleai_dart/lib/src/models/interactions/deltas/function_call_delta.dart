part of 'deltas.dart';

/// A function call delta update.
class FunctionCallDelta extends InteractionDelta {
  @override
  String get type => 'function_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// The name of the function to call.
  final String? name;

  /// The arguments to pass to the function.
  final Map<String, dynamic>? arguments;

  /// A signature for this tool call.
  final String? signature;

  /// Creates a [FunctionCallDelta] instance.
  const FunctionCallDelta({this.id, this.name, this.arguments, this.signature});

  /// Creates a [FunctionCallDelta] from JSON.
  factory FunctionCallDelta.fromJson(Map<String, dynamic> json) =>
      FunctionCallDelta(
        id: json['id'] as String?,
        name: json['name'] as String?,
        arguments: json['arguments'] as Map<String, dynamic>?,
        signature: json['signature'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
    if (signature != null) 'signature': signature,
  };
}
