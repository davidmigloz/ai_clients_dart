import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'dream_input.dart';
import 'dream_model_config.dart';
import 'output_behavior.dart';

/// Request parameters for creating a Dream.
@immutable
class CreateDreamRequest {
  /// Input sources the dream should read from.
  final List<DreamInput> inputs;

  /// Custom instructions for the dream. 1-4096 characters.
  final String? instructions;

  /// Model identifier and configuration applied to every pipeline stage.
  final DreamModelParams model;

  /// Where the job writes its consolidated memories. Omit to create a new
  /// output memory store (the default).
  final OutputBehavior? outputBehavior;

  /// Creates a [CreateDreamRequest].
  const CreateDreamRequest({
    required this.inputs,
    this.instructions,
    required this.model,
    this.outputBehavior,
  });

  /// Creates a [CreateDreamRequest] from JSON.
  factory CreateDreamRequest.fromJson(Map<String, dynamic> json) {
    final rawInputs = json['inputs'] as List? ?? [];
    final inputs = rawInputs.map((e) {
      if (e is! Map<String, dynamic>) {
        throw FormatException(
          'CreateDreamRequest.inputs: expected Map, got ${e.runtimeType}',
        );
      }
      return DreamInput.fromJson(e);
    }).toList();

    return CreateDreamRequest(
      inputs: inputs,
      instructions: json['instructions'] as String?,
      model: DreamModelParams.fromJson(json['model'] as Object),
      outputBehavior: json['output_behavior'] != null
          ? OutputBehavior.fromJson(
              json['output_behavior'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'inputs': inputs.map((e) => e.toJson()).toList(),
    if (instructions != null) 'instructions': instructions,
    'model': model.toJson(),
    if (outputBehavior != null) 'output_behavior': outputBehavior!.toJson(),
  };

  /// Creates a copy with replaced values.
  CreateDreamRequest copyWith({
    List<DreamInput>? inputs,
    Object? instructions = unsetCopyWithValue,
    DreamModelParams? model,
    Object? outputBehavior = unsetCopyWithValue,
  }) {
    return CreateDreamRequest(
      inputs: inputs ?? this.inputs,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      model: model ?? this.model,
      outputBehavior: outputBehavior == unsetCopyWithValue
          ? this.outputBehavior
          : outputBehavior as OutputBehavior?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDreamRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(inputs, other.inputs) &&
          instructions == other.instructions &&
          model == other.model &&
          outputBehavior == other.outputBehavior;

  @override
  int get hashCode =>
      Object.hash(listHash(inputs), instructions, model, outputBehavior);

  @override
  String toString() =>
      'CreateDreamRequest('
      'inputs: ${inputs.length} items, '
      'instructions: $instructions, '
      'model: $model, '
      'outputBehavior: $outputBehavior)';
}
