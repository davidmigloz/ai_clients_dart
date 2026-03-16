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
      // Some providers omit type (e.g., vLLM, custom proxies)
      type: json['type'] as String? ?? 'function',
      function: FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
    );
  }

  /// The unique ID of this tool call.
  final String id;

  /// The type of the tool call (always "function" currently).
  ///
  /// Defaults to "function" if omitted by the provider (e.g., some vLLM
  /// configurations and custom proxies may not include this field).
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
      // Some providers return arguments as a parsed JSON object instead of a
      // string (e.g., Llamafile — llama.cpp#20198, custom AWS Bedrock proxies
      // that pass through Converse API's toolUse.input without stringifying).
      arguments: switch (json['arguments']) {
        final String s => s,
        final Map<dynamic, dynamic> m => jsonEncode(m),
        null => '{}',
        final other => jsonEncode(other),
      },
    );
  }

  /// The name of the function to call.
  final String name;

  /// The arguments to pass to the function, as a JSON string.
  ///
  /// Per the OpenAI spec, this is always a JSON-encoded string. However,
  /// some OpenAI-compatible providers return arguments as a parsed JSON
  /// object instead (e.g., Llamafile — llama.cpp#20198, custom AWS Bedrock
  /// proxies that pass through Converse API's `toolUse.input` without
  /// stringifying). The [fromJson] factory handles both formats.
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
