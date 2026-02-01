import 'package:meta/meta.dart';

/// A tool available for the model to call.
///
/// Currently only supports function tools, but the structure allows for
/// future expansion to other tool types.
///
/// ## Example
///
/// ```dart
/// final tool = Tool.function(
///   name: 'get_weather',
///   description: 'Get the current weather for a location',
///   parameters: {
///     'type': 'object',
///     'properties': {
///       'location': {
///         'type': 'string',
///         'description': 'The city and state, e.g. San Francisco, CA',
///       },
///       'unit': {
///         'type': 'string',
///         'enum': ['celsius', 'fahrenheit'],
///       },
///     },
///     'required': ['location'],
///   },
/// );
/// ```
@immutable
class Tool {
  /// Creates a [Tool].
  const Tool({required this.type, required this.function});

  /// Creates a function tool.
  factory Tool.function({
    required String name,
    String? description,
    Map<String, dynamic>? parameters,
    bool strict = false,
  }) {
    return Tool(
      type: 'function',
      function: FunctionDefinition(
        name: name,
        description: description,
        parameters: parameters,
        strict: strict,
      ),
    );
  }

  /// Creates a [Tool] from JSON.
  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      type: json['type'] as String,
      function: FunctionDefinition.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
    );
  }

  /// The type of the tool (currently only "function").
  final String type;

  /// The function definition.
  final FunctionDefinition function;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'function': function.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          function == other.function;

  @override
  int get hashCode => Object.hash(type, function);

  @override
  String toString() => 'Tool(type: $type, function: ${function.name})';
}

/// A function definition for a tool.
@immutable
class FunctionDefinition {
  /// Creates a [FunctionDefinition].
  const FunctionDefinition({
    required this.name,
    this.description,
    this.parameters,
    this.strict = false,
  });

  /// Creates a [FunctionDefinition] from JSON.
  factory FunctionDefinition.fromJson(Map<String, dynamic> json) {
    return FunctionDefinition(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool? ?? false,
    );
  }

  /// The name of the function.
  ///
  /// Must be a-z, A-Z, 0-9, underscores, or dashes. Max 64 characters.
  final String name;

  /// A description of what the function does.
  ///
  /// Used by the model to decide when to call the function.
  final String? description;

  /// The parameters the function accepts, as a JSON Schema object.
  ///
  /// If omitted, the function takes no parameters.
  final Map<String, dynamic>? parameters;

  /// Whether to enable strict schema adherence.
  ///
  /// When true, the model will be constrained to only generate
  /// function calls that match the schema exactly.
  final bool strict;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
    if (strict) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(name, description, strict);

  @override
  String toString() => 'FunctionDefinition(name: $name)';
}
