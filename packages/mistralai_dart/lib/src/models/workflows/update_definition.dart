import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Definition of a workflow update.
@immutable
class UpdateDefinition {
  /// The update name.
  final String name;

  /// The input JSON schema.
  final Map<String, dynamic> inputSchema;

  /// The output JSON schema.
  final Map<String, dynamic>? outputSchema;

  /// Description of the update.
  final String? description;

  /// Creates a [UpdateDefinition].
  const UpdateDefinition({
    required this.name,
    required this.inputSchema,
    this.outputSchema,
    this.description,
  });

  /// Creates a [UpdateDefinition] from JSON.
  factory UpdateDefinition.fromJson(Map<String, dynamic> json) =>
      UpdateDefinition(
        name: json['name'] as String? ?? '',
        inputSchema: json['input_schema'] as Map<String, dynamic>? ?? {},
        outputSchema: json['output_schema'] as Map<String, dynamic>?,
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'input_schema': inputSchema,
    if (outputSchema != null) 'output_schema': outputSchema,
    if (description != null) 'description': description,
  };

  /// Creates a copy with replaced values.
  UpdateDefinition copyWith({
    String? name,
    Map<String, dynamic>? inputSchema,
    Object? outputSchema = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
  }) {
    return UpdateDefinition(
      name: name ?? this.name,
      inputSchema: inputSchema ?? this.inputSchema,
      outputSchema: outputSchema == unsetCopyWithValue
          ? this.outputSchema
          : outputSchema as Map<String, dynamic>?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(inputSchema, other.inputSchema)) return false;
    if (!mapsDeepEqual(outputSchema, other.outputSchema)) return false;
    return name == other.name && description == other.description;
  }

  @override
  int get hashCode => Object.hash(
    name,
    mapDeepHashCode(inputSchema),
    mapDeepHashCode(outputSchema),
    description,
  );

  @override
  String toString() =>
      'UpdateDefinition('
      'name: $name, '
      'inputSchema: ${inputSchema.length}, '
      'outputSchema: ${outputSchema?.length ?? 'null'}, '
      'description: $description'
      ')';
}
