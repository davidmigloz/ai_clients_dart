import 'package:meta/meta.dart';

import 'post_judge_in_schema.dart';

/// Request to perform live judging on a chat completion event.
@immutable
class PostChatCompletionEventJudgingInSchema {
  /// The judge definition to use.
  final PostJudgeInSchema judgeDefinition;

  /// Creates a [PostChatCompletionEventJudgingInSchema].
  const PostChatCompletionEventJudgingInSchema({required this.judgeDefinition});

  /// Creates a [PostChatCompletionEventJudgingInSchema] from JSON.
  factory PostChatCompletionEventJudgingInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostChatCompletionEventJudgingInSchema(
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
    if (other is! PostChatCompletionEventJudgingInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return judgeDefinition == other.judgeDefinition;
  }

  @override
  int get hashCode => judgeDefinition.hashCode;

  @override
  String toString() =>
      'PostChatCompletionEventJudgingInSchema('
      'judgeDefinition: $judgeDefinition)';
}
