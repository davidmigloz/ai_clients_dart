import 'package:meta/meta.dart';

import 'data_source_config.dart';
import 'eval_grader.dart';

/// An evaluation definition for testing LLM integrations.
///
/// Evaluations define the structure for testing model performance using
/// a data source configuration and testing criteria (graders).
@immutable
class Eval {
  /// Creates an [Eval].
  const Eval({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.object,
    required this.dataSourceConfig,
    required this.testingCriteria,
    this.metadata,
  });

  /// Creates an [Eval] from JSON.
  factory Eval.fromJson(Map<String, dynamic> json) {
    return Eval(
      id: json['id'] as String,
      createdAt: json['created_at'] as int,
      name: json['name'] as String,
      object: json['object'] as String,
      dataSourceConfig: EvalDataSourceConfig.fromJson(
        json['data_source_config'] as Map<String, dynamic>,
      ),
      testingCriteria: (json['testing_criteria'] as List<dynamic>)
          .map((e) => EvalGrader.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The unique identifier for this evaluation.
  final String id;

  /// The Unix timestamp (in seconds) when this evaluation was created.
  final int createdAt;

  /// The name of this evaluation.
  final String name;

  /// The object type (always "eval").
  final String object;

  /// The configuration for the data source used in evaluation runs.
  final EvalDataSourceConfig dataSourceConfig;

  /// The list of graders (testing criteria) for evaluation runs.
  final List<EvalGrader> testingCriteria;

  /// Optional metadata attached to this evaluation.
  ///
  /// Up to 16 key-value pairs, with keys up to 64 characters and
  /// values up to 512 characters.
  final Map<String, dynamic>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt,
    'name': name,
    'object': object,
    'data_source_config': dataSourceConfig.toJson(),
    'testing_criteria': testingCriteria.map((g) => g.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Eval && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Eval(id: $id, name: $name)';
}

/// A paginated list of evaluations.
@immutable
class EvalList {
  /// Creates an [EvalList].
  const EvalList({
    required this.object,
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates an [EvalList] from JSON.
  factory EvalList.fromJson(Map<String, dynamic> json) {
    return EvalList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Eval.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of evaluations.
  final List<Eval> data;

  /// Whether there are more evaluations available.
  final bool hasMore;

  /// The ID of the first evaluation in this page.
  final String? firstId;

  /// The ID of the last evaluation in this page.
  final String? lastId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'EvalList(${data.length} evaluations)';
}

/// Request to create a new evaluation.
@immutable
class CreateEvalRequest {
  /// Creates a [CreateEvalRequest].
  const CreateEvalRequest({
    required this.dataSourceConfig,
    required this.testingCriteria,
    this.name,
    this.metadata,
  });

  /// Creates a [CreateEvalRequest] from JSON.
  factory CreateEvalRequest.fromJson(Map<String, dynamic> json) {
    return CreateEvalRequest(
      dataSourceConfig: EvalDataSourceConfig.fromJson(
        json['data_source_config'] as Map<String, dynamic>,
      ),
      testingCriteria: (json['testing_criteria'] as List<dynamic>)
          .map((e) => EvalGrader.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The configuration for the data source.
  ///
  /// Graders reference data source variables using `{{item.variable_name}}`
  /// and model output via `{{sample.output_text}}`.
  final EvalDataSourceConfig dataSourceConfig;

  /// The list of graders (testing criteria) for evaluation runs.
  final List<EvalGrader> testingCriteria;

  /// Optional name for the evaluation.
  final String? name;

  /// Optional metadata to attach to the evaluation.
  final Map<String, dynamic>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data_source_config': dataSourceConfig.toJson(),
    'testing_criteria': testingCriteria.map((g) => g.toJson()).toList(),
    if (name != null) 'name': name,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEvalRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(dataSourceConfig, testingCriteria.length);

  @override
  String toString() =>
      'CreateEvalRequest(name: $name, criteria: ${testingCriteria.length})';
}

/// Request to update an existing evaluation.
@immutable
class UpdateEvalRequest {
  /// Creates an [UpdateEvalRequest].
  const UpdateEvalRequest({this.name, this.metadata});

  /// Creates an [UpdateEvalRequest] from JSON.
  factory UpdateEvalRequest.fromJson(Map<String, dynamic> json) {
    return UpdateEvalRequest(
      name: json['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// New name for the evaluation.
  final String? name;

  /// New metadata for the evaluation.
  final Map<String, dynamic>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateEvalRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(name, metadata);

  @override
  String toString() => 'UpdateEvalRequest(name: $name)';
}

/// Response from deleting an evaluation.
@immutable
class DeleteEvalResponse {
  /// Creates a [DeleteEvalResponse].
  const DeleteEvalResponse({
    required this.evalId,
    this.object,
    required this.deleted,
  });

  /// Creates a [DeleteEvalResponse] from JSON.
  factory DeleteEvalResponse.fromJson(Map<String, dynamic> json) {
    return DeleteEvalResponse(
      evalId: json['eval_id'] as String,
      object: json['object'] as String?,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted evaluation.
  final String evalId;

  /// The object type (typically "eval.deleted").
  final String? object;

  /// Whether the evaluation was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'eval_id': evalId,
    if (object != null) 'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteEvalResponse &&
          runtimeType == other.runtimeType &&
          evalId == other.evalId;

  @override
  int get hashCode => evalId.hashCode;

  @override
  String toString() => 'DeleteEvalResponse(evalId: $evalId, deleted: $deleted)';
}
