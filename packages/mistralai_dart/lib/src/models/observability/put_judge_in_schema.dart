import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'judge_output_config.dart';

/// Request to update a judge.
@immutable
class PutJudgeInSchema {
  /// Judge name (5-50 characters).
  final String name;

  /// Judge description (max 500 characters).
  final String description;

  /// Model name to use (max 500 characters).
  final String modelName;

  /// Output configuration (classification or regression).
  final JudgeOutputConfig output;

  /// Evaluation instructions (max 10000 characters).
  final String instructions;

  /// Tools available to the judge.
  final List<String> tools;

  /// Creates a [PutJudgeInSchema].
  PutJudgeInSchema({
    required this.name,
    required this.description,
    required this.modelName,
    required this.output,
    required this.instructions,
    required List<String> tools,
  }) : tools = List.unmodifiable(tools);

  /// Creates a [PutJudgeInSchema] from JSON.
  factory PutJudgeInSchema.fromJson(Map<String, dynamic> json) =>
      PutJudgeInSchema(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        modelName: json['model_name'] as String? ?? '',
        output: JudgeOutputConfig.fromJson(
          json['output'] as Map<String, dynamic>? ?? {},
        ),
        instructions: json['instructions'] as String? ?? '',
        tools: (json['tools'] as List?)?.cast<String>() ?? [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'model_name': modelName,
    'output': output.toJson(),
    'instructions': instructions,
    'tools': tools,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PutJudgeInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name &&
        description == other.description &&
        modelName == other.modelName &&
        output == other.output &&
        instructions == other.instructions &&
        listsEqual(tools, other.tools);
  }

  @override
  int get hashCode => Object.hash(
    name,
    description,
    modelName,
    output,
    instructions,
    listHash(tools),
  );

  @override
  String toString() => 'PutJudgeInSchema(name: $name, modelName: $modelName)';
}
