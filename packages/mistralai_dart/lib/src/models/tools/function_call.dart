import 'package:meta/meta.dart';

/// Function call details from the model.
@immutable
class FunctionCall {
  /// The name of the function to call.
  final String name;

  /// The arguments to the function as a JSON string.
  final String arguments;

  /// Creates a [FunctionCall].
  const FunctionCall({required this.name, required this.arguments});

  /// Creates a [FunctionCall] from JSON.
  factory FunctionCall.fromJson(Map<String, dynamic> json) => FunctionCall(
    name: json['name'] as String? ?? '',
    arguments: json['arguments'] as String? ?? '{}',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name, 'arguments': arguments};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(name, arguments);

  @override
  String toString() => 'FunctionCall(name: $name, arguments: $arguments)';
}
