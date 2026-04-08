import 'package:meta/meta.dart';

import 'post_judge_in_schema.dart';

/// Request to perform live judging on a dataset record.
@immutable
class PostDatasetRecordJudgingInSchema {
  /// The judge definition to use.
  final PostJudgeInSchema judgeDefinition;

  /// Creates a [PostDatasetRecordJudgingInSchema].
  const PostDatasetRecordJudgingInSchema({required this.judgeDefinition});

  /// Creates a [PostDatasetRecordJudgingInSchema] from JSON.
  factory PostDatasetRecordJudgingInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetRecordJudgingInSchema(
    judgeDefinition: PostJudgeInSchema.fromJson(
      json['judge_definition'] as Map<String, dynamic>? ?? {},
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'judge_definition': judgeDefinition.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetRecordJudgingInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return judgeDefinition == other.judgeDefinition;
  }

  @override
  int get hashCode => judgeDefinition.hashCode;

  @override
  String toString() =>
      'PostDatasetRecordJudgingInSchema('
      'judgeDefinition: $judgeDefinition)';
}
