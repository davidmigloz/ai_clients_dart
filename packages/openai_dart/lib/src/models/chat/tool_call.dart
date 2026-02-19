import 'dart:convert';

import 'package:meta/meta.dart';

/// A tool call made by the model.
///
/// Tool calls are requests from the model to execute a function/tool.
/// The application should execute the function and return the result
/// in a [ToolMessage].
///
/// ## Example
///
/// ```dart
/// if (response.choices.first.message.hasToolCalls) {
///   for (final toolCall in response.choices.first.message.toolCalls!) {
///     final result = executeFunction(
///       toolCall.function.name,
///       toolCall.function.arguments,
///     );
///
///     messages.add(ChatMessage.tool(
///       toolCallId: toolCall.id,
///       content: jsonEncode(result),
///     ));
///   }
/// }
/// ```
@immutable
class ToolCall {
  /// Creates a [ToolCall].
  const ToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  /// Creates a function [ToolCall] with [type] set to `'function'`.
  factory ToolCall.functionCall({
    required String id,
    required FunctionCall call,
  }) => ToolCall(id: id, type: 'function', function: call);

  /// Creates a [ToolCall] from JSON.
  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      type: json['type'] as String,
      function: FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
    );
  }

  /// The unique ID of this tool call.
  final String id;

  /// The type of the tool call (always "function" currently).
  final String type;

  /// The function call details.
  final FunctionCall function;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'function': function.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          function == other.function;

  @override
  int get hashCode => Object.hash(id, type, function);

  @override
  String toString() => 'ToolCall(id: $id, function: ${function.name})';
}

/// A function call within a tool call.
@immutable
class FunctionCall {
  /// Creates a [FunctionCall].
  const FunctionCall({required this.name, required this.arguments});

  /// Creates a [FunctionCall] with arguments encoded from a map.
  factory FunctionCall.fromMap({
    required String name,
    required Map<String, dynamic> arguments,
  }) => FunctionCall(name: name, arguments: jsonEncode(arguments));

  /// Creates a [FunctionCall] from JSON.
  factory FunctionCall.fromJson(Map<String, dynamic> json) {
    return FunctionCall(
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );
  }

  /// The name of the function to call.
  final String name;

  /// The arguments to pass to the function, as a JSON string.
  final String arguments;

  /// The arguments parsed as a JSON map.
  ///
  /// Throws [FormatException] if [arguments] is not valid JSON or does not
  /// represent a JSON object.
  Map<String, dynamic> get argumentsMap {
    final decoded = jsonDecode(arguments);
    if (decoded is! Map) {
      throw const FormatException(
        'FunctionCall.arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

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
  String toString() => 'FunctionCall(name: $name)';
}
