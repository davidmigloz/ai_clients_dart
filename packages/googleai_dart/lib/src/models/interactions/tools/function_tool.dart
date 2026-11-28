part of 'tools.dart';

/// A function tool that can be called by the model.
class FunctionTool extends InteractionTool {
  @override
  String get type => 'function';

  /// The name of the function.
  final String? name;

  /// A description of the function.
  final String? description;

  /// The JSON Schema for the function's parameters.
  final Map<String, dynamic>? parameters;

  /// Whether a server-side [ToolSearchTool] should load this schema on demand.
  final bool? deferLoading;

  /// A compact description shown to the model when [deferLoading] is true.
  final String? shortDescription;

  /// Creates a [FunctionTool] instance.
  const FunctionTool({
    this.name,
    this.description,
    this.parameters,
    this.deferLoading,
    this.shortDescription,
  });

  /// Creates a [FunctionTool] from JSON.
  factory FunctionTool.fromJson(Map<String, dynamic> json) => FunctionTool(
    name: json['name'] as String?,
    description: json['description'] as String?,
    parameters: json['parameters'] as Map<String, dynamic>?,
    deferLoading: json['defer_loading'] as bool?,
    shortDescription: json['short_description'] as String?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
    if (deferLoading != null) 'defer_loading': deferLoading,
    if (shortDescription != null) 'short_description': shortDescription,
  };

  /// Creates a copy with replaced values.
  FunctionTool copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
    Object? deferLoading = unsetCopyWithValue,
    Object? shortDescription = unsetCopyWithValue,
  }) => FunctionTool(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    parameters: parameters == unsetCopyWithValue
        ? this.parameters
        : parameters as Map<String, dynamic>?,
    deferLoading: deferLoading == unsetCopyWithValue
        ? this.deferLoading
        : deferLoading as bool?,
    shortDescription: shortDescription == unsetCopyWithValue
        ? this.shortDescription
        : shortDescription as String?,
  );
}
