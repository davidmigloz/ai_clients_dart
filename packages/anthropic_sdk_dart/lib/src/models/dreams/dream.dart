import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'dream_error.dart';
import 'dream_input.dart';
import 'dream_model_config.dart';
import 'dream_output.dart';
import 'dream_status.dart';
import 'dream_usage.dart';

/// An asynchronous memory-consolidation job that reads a memory store plus a
/// set of session transcripts and writes consolidated memories into a new
/// output memory store.
///
/// The Dreams API is in research preview: the request and response shapes
/// are volatile and may change without the deprecation period that applies
/// to generally-available endpoints.
@immutable
class Dream {
  /// Object type. Always `dream`.
  final String type;

  /// Unique identifier for the dream.
  final String id;

  /// Input sources the dream reads from.
  final List<DreamInput> inputs;

  /// Output destinations the dream writes consolidated memories into.
  final List<DreamOutput> outputs;

  /// Lifecycle status of the dream.
  final DreamStatus status;

  /// When the dream was created.
  final DateTime createdAt;

  /// When the dream finished processing (successfully, with failure, or by
  /// cancellation). Null while the dream is still pending or running.
  final DateTime? endedAt;

  /// When the dream was archived. Null if not archived.
  final DateTime? archivedAt;

  /// Failure detail when [status] is [DreamStatus.failed]. Null otherwise.
  final DreamError? error;

  /// Model identifier and configuration applied to every pipeline stage.
  final DreamModelConfig model;

  /// Custom instructions supplied when the dream was created.
  final String? instructions;

  /// ID of the session the dream ran within, if any.
  final String? sessionId;

  /// Cumulative token usage for the dream across every pipeline stage.
  final DreamUsage usage;

  /// Creates a [Dream].
  const Dream({
    this.type = 'dream',
    required this.id,
    required this.inputs,
    required this.outputs,
    required this.status,
    required this.createdAt,
    this.endedAt,
    this.archivedAt,
    this.error,
    required this.model,
    this.instructions,
    this.sessionId,
    required this.usage,
  });

  /// Creates a [Dream] from JSON.
  factory Dream.fromJson(Map<String, dynamic> json) {
    final rawInputs = json['inputs'] as List? ?? [];
    final inputs = rawInputs.map((e) {
      if (e is! Map<String, dynamic>) {
        throw FormatException(
          'Dream.inputs: expected Map, got ${e.runtimeType}',
        );
      }
      return DreamInput.fromJson(e);
    }).toList();

    final rawOutputs = json['outputs'] as List? ?? [];
    final outputs = rawOutputs.map((e) {
      if (e is! Map<String, dynamic>) {
        throw FormatException(
          'Dream.outputs: expected Map, got ${e.runtimeType}',
        );
      }
      return DreamOutput.fromJson(e);
    }).toList();

    return Dream(
      type: json['type'] as String? ?? 'dream',
      id: json['id'] as String,
      inputs: inputs,
      outputs: outputs,
      status: DreamStatus.fromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      error: json['error'] != null
          ? DreamError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      model: DreamModelConfig.fromJson(json['model'] as Map<String, dynamic>),
      instructions: json['instructions'] as String?,
      sessionId: json['session_id'] as String?,
      usage: DreamUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'inputs': inputs.map((e) => e.toJson()).toList(),
    'outputs': outputs.map((e) => e.toJson()).toList(),
    'status': status.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'ended_at': endedAt?.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'error': error?.toJson(),
    'model': model.toJson(),
    'instructions': instructions,
    'session_id': sessionId,
    'usage': usage.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([endedAt], [archivedAt], [error], [instructions],
  /// [sessionId]), pass the sentinel value [unsetCopyWithValue] (or omit) to
  /// keep the original value, or pass `null` explicitly to set the field to
  /// null.
  Dream copyWith({
    String? type,
    String? id,
    List<DreamInput>? inputs,
    List<DreamOutput>? outputs,
    DreamStatus? status,
    DateTime? createdAt,
    Object? endedAt = unsetCopyWithValue,
    Object? archivedAt = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    DreamModelConfig? model,
    Object? instructions = unsetCopyWithValue,
    Object? sessionId = unsetCopyWithValue,
    DreamUsage? usage,
  }) {
    return Dream(
      type: type ?? this.type,
      id: id ?? this.id,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt == unsetCopyWithValue
          ? this.endedAt
          : endedAt as DateTime?,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as DateTime?,
      error: error == unsetCopyWithValue ? this.error : error as DreamError?,
      model: model ?? this.model,
      instructions: instructions == unsetCopyWithValue
          ? this.instructions
          : instructions as String?,
      sessionId: sessionId == unsetCopyWithValue
          ? this.sessionId
          : sessionId as String?,
      usage: usage ?? this.usage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dream &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          listsEqual(inputs, other.inputs) &&
          listsEqual(outputs, other.outputs) &&
          status == other.status &&
          createdAt == other.createdAt &&
          endedAt == other.endedAt &&
          archivedAt == other.archivedAt &&
          error == other.error &&
          model == other.model &&
          instructions == other.instructions &&
          sessionId == other.sessionId &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    listHash(inputs),
    listHash(outputs),
    status,
    createdAt,
    endedAt,
    archivedAt,
    error,
    model,
    instructions,
    sessionId,
    usage,
  );

  @override
  String toString() =>
      'Dream('
      'type: $type, '
      'id: $id, '
      'inputs: ${inputs.length} items, '
      'outputs: ${outputs.length} items, '
      'status: $status, '
      'createdAt: $createdAt, '
      'endedAt: $endedAt, '
      'archivedAt: $archivedAt, '
      'error: $error, '
      'model: $model, '
      'instructions: $instructions, '
      'sessionId: $sessionId, '
      'usage: $usage)';
}
