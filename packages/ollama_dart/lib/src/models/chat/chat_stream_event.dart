import 'package:meta/meta.dart';

import '../common/done_reason.dart';
import '../completions/logprob.dart';
import 'chat_response.dart';

/// A streaming event from chat completion.
@immutable
class ChatStreamEvent {
  /// Model name used for this stream event.
  final String? model;

  /// Remote model name, if using a remote/proxy model.
  final String? remoteModel;

  /// Remote host, if using a remote/proxy model.
  final String? remoteHost;

  /// When this chunk was created (ISO 8601).
  final String? createdAt;

  /// The message chunk.
  final ChatResponseMessage? message;

  /// True for the final event in the stream.
  final bool? done;

  /// Reason the response finished (present in the final chunk).
  final DoneReason? doneReason;

  /// Total time spent generating in nanoseconds (present in the final chunk).
  final int? totalDuration;

  /// Time spent loading the model in nanoseconds (present in the final chunk).
  final int? loadDuration;

  /// Number of tokens in the prompt (present in the final chunk).
  final int? promptEvalCount;

  /// Time spent evaluating the prompt in nanoseconds (present in the final chunk).
  final int? promptEvalDuration;

  /// Number of tokens generated in the response (present in the final chunk).
  final int? evalCount;

  /// Time spent generating tokens in nanoseconds (present in the final chunk).
  final int? evalDuration;

  /// Log probability information for generated tokens.
  final List<Logprob>? logprobs;

  /// Creates a [ChatStreamEvent].
  const ChatStreamEvent({
    this.model,
    this.remoteModel,
    this.remoteHost,
    this.createdAt,
    this.message,
    this.done,
    this.doneReason,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.promptEvalDuration,
    this.evalCount,
    this.evalDuration,
    this.logprobs,
  });

  /// Creates a [ChatStreamEvent] from JSON.
  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) =>
      ChatStreamEvent(
        model: json['model'] as String?,
        remoteModel: json['remote_model'] as String?,
        remoteHost: json['remote_host'] as String?,
        createdAt: json['created_at'] as String?,
        message: json['message'] != null
            ? ChatResponseMessage.fromJson(
                json['message'] as Map<String, dynamic>,
              )
            : null,
        done: json['done'] as bool?,
        doneReason: doneReasonFromString(json['done_reason'] as String?),
        totalDuration: json['total_duration'] as int?,
        loadDuration: json['load_duration'] as int?,
        promptEvalCount: json['prompt_eval_count'] as int?,
        promptEvalDuration: json['prompt_eval_duration'] as int?,
        evalCount: json['eval_count'] as int?,
        evalDuration: json['eval_duration'] as int?,
        logprobs: (json['logprobs'] as List?)
            ?.map((e) => Logprob.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (remoteModel != null) 'remote_model': remoteModel,
    if (remoteHost != null) 'remote_host': remoteHost,
    if (createdAt != null) 'created_at': createdAt,
    if (message != null) 'message': message!.toJson(),
    if (done != null) 'done': done,
    if (doneReason != null) 'done_reason': doneReasonToString(doneReason!),
    if (totalDuration != null) 'total_duration': totalDuration,
    if (loadDuration != null) 'load_duration': loadDuration,
    if (promptEvalCount != null) 'prompt_eval_count': promptEvalCount,
    if (promptEvalDuration != null) 'prompt_eval_duration': promptEvalDuration,
    if (evalCount != null) 'eval_count': evalCount,
    if (evalDuration != null) 'eval_duration': evalDuration,
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamEvent &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          createdAt == other.createdAt &&
          done == other.done;

  @override
  int get hashCode => Object.hash(model, createdAt, done);

  @override
  String toString() =>
      'ChatStreamEvent('
      'model: $model, '
      'message: $message, '
      'done: $done, '
      'doneReason: $doneReason, '
      'totalDuration: $totalDuration, '
      'promptEvalCount: $promptEvalCount, '
      'evalCount: $evalCount)';
}
