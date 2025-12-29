import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// A function call requested by the model.
@immutable
class ToolCallFunction {
  /// Name of the function to call.
  final String name;

  /// Description of what the function does.
  final String? description;

  /// JSON object of arguments to pass to the function.
  final Map<String, dynamic>? arguments;

  /// Creates a [ToolCallFunction].
  const ToolCallFunction({
    required this.name,
    this.description,
    this.arguments,
  });

  /// Creates a [ToolCallFunction] from JSON.
  factory ToolCallFunction.fromJson(Map<String, dynamic> json) =>
      ToolCallFunction(
        name: json['name'] as String,
        description: json['description'] as String?,
        arguments: json['arguments'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (arguments != null) 'arguments': arguments,
  };

  /// Creates a copy with replaced values.
  ToolCallFunction copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Object? arguments = unsetCopyWithValue,
  }) {
    return ToolCallFunction(
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      arguments: arguments == unsetCopyWithValue
          ? this.arguments
          : arguments as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCallFunction &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          _mapsEqual(arguments, other.arguments);

  @override
  int get hashCode => Object.hash(name, description, arguments);

  @override
  String toString() =>
      'ToolCallFunction('
      'name: $name, '
      'description: $description, '
      'arguments: $arguments)';
}

/// A tool call produced by the model.
@immutable
class ToolCall {
  /// The function to call.
  final ToolCallFunction? function;

  /// Creates a [ToolCall].
  const ToolCall({this.function});

  /// Creates a [ToolCall] from JSON.
  factory ToolCall.fromJson(Map<String, dynamic> json) => ToolCall(
    function: json['function'] != null
        ? ToolCallFunction.fromJson(json['function'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (function != null) 'function': function!.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolCall copyWith({Object? function = unsetCopyWithValue}) {
    return ToolCall(
      function: function == unsetCopyWithValue
          ? this.function
          : function as ToolCallFunction?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCall &&
          runtimeType == other.runtimeType &&
          function == other.function;

  @override
  int get hashCode => function.hashCode;

  @override
  String toString() => 'ToolCall(function: $function)';
}

bool _mapsEqual(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
