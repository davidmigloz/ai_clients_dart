import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Definition of a function that can be called by the model.
@immutable
class FunctionDefinition {
  /// The name of the function.
  final String name;

  /// A description of what the function does.
  final String? description;

  /// The parameters the function accepts as a JSON Schema object.
  final Map<String, dynamic>? parameters;

  /// Creates a [FunctionDefinition].
  const FunctionDefinition({
    required this.name,
    this.description,
    this.parameters,
  });

  /// Creates a [FunctionDefinition] from JSON.
  factory FunctionDefinition.fromJson(Map<String, dynamic> json) =>
      FunctionDefinition(
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        parameters: json['parameters'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionDefinition &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapEquals(parameters, other.parameters);

  @override
  int get hashCode => Object.hash(name, description, parameters);

  @override
  String toString() =>
      'FunctionDefinition(name: $name, description: $description)';
}
