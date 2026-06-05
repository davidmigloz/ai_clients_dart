part of 'steps.dart';

/// A function tool call step.
class FunctionCallStep extends InteractionStep {
  @override
  String get type => 'function_call';

  /// A unique ID for this specific tool call.
  final String id;

  /// The name of the tool to call.
  final String name;

  /// The arguments to pass to the function.
  final Map<String, dynamic> arguments;

  /// Creates a [FunctionCallStep] instance.
  const FunctionCallStep({
    required this.id,
    required this.name,
    required this.arguments,
  });

  /// Creates a [FunctionCallStep] from JSON.
  factory FunctionCallStep.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'function_call') {
      throw FormatException(
        'Expected type "function_call" but got "${json['type']}"',
      );
    }
    final id = json['id'];
    if (id is! String) {
      throw const FormatException('FunctionCallStep: missing required "id"');
    }
    final name = json['name'];
    if (name is! String) {
      throw const FormatException('FunctionCallStep: missing required "name"');
    }
    final arguments = json['arguments'];
    if (arguments is! Map<String, dynamic>) {
      throw const FormatException(
        'FunctionCallStep: missing required "arguments"',
      );
    }
    return FunctionCallStep(id: id, name: name, arguments: arguments);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'arguments': arguments,
  };

  /// Creates a copy with replaced values.
  FunctionCallStep copyWith({
    Object? id = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
  }) {
    return FunctionCallStep(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      name: name == unsetCopyWithValue ? this.name : name! as String,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments! as Map<String, dynamic>,
    );
  }
}
