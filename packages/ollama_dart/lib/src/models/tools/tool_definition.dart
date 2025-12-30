import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Function definition for a tool.
@immutable
class ToolFunction {
  /// Function name exposed to the model.
  final String name;

  /// Human-readable description of the function.
  final String? description;

  /// JSON Schema for the function parameters.
  final Map<String, dynamic> parameters;

  /// Creates a [ToolFunction].
  const ToolFunction({
    required this.name,
    this.description,
    required this.parameters,
  });

  /// Creates a [ToolFunction] from JSON.
  factory ToolFunction.fromJson(Map<String, dynamic> json) => ToolFunction(
    name: json['name'] as String,
    description: json['description'] as String?,
    parameters: json['parameters'] as Map<String, dynamic>? ?? {},
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    'parameters': parameters,
  };

  /// Creates a copy with replaced values.
  ToolFunction copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Map<String, dynamic>? parameters,
  }) {
    return ToolFunction(
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolFunction &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description;

  @override
  int get hashCode => Object.hash(name, description);

  @override
  String toString() =>
      'ToolFunction('
      'name: $name, '
      'description: $description, '
      'parameters: $parameters)';
}

/// Tool type.
enum ToolType {
  /// Function tool type.
  function,
}

/// Converts string to [ToolType] enum.
ToolType toolTypeFromString(String? value) {
  return switch (value) {
    'function' => ToolType.function,
    _ => ToolType.function,
  };
}

/// Converts [ToolType] enum to string.
String toolTypeToString(ToolType value) {
  return switch (value) {
    ToolType.function => 'function',
  };
}

/// A tool definition that can be provided to the model.
@immutable
class ToolDefinition {
  /// Type of tool (always `function`).
  final ToolType type;

  /// The function definition.
  final ToolFunction function;

  /// Creates a [ToolDefinition].
  const ToolDefinition({this.type = ToolType.function, required this.function});

  /// Creates a [ToolDefinition] from JSON.
  factory ToolDefinition.fromJson(Map<String, dynamic> json) => ToolDefinition(
    type: toolTypeFromString(json['type'] as String?),
    function: ToolFunction.fromJson(json['function'] as Map<String, dynamic>),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': toolTypeToString(type),
    'function': function.toJson(),
  };

  /// Creates a copy with replaced values.
  ToolDefinition copyWith({ToolType? type, ToolFunction? function}) {
    return ToolDefinition(
      type: type ?? this.type,
      function: function ?? this.function,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolDefinition &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          function == other.function;

  @override
  int get hashCode => Object.hash(type, function);

  @override
  String toString() => 'ToolDefinition(type: $type, function: $function)';
}
