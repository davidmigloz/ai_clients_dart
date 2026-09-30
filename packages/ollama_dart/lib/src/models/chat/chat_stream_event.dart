import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/done_reason.dart';
import '../common/equality_helpers.dart';
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

  /// Number of prompt tokens read from the cache, when reported by the server.
  final int? promptEvalCachedCount;

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
    this.promptEvalCachedCount,
  });

  /// Creates a [ChatStreamEvent] from JSON.
  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) =>
      ChatStreamEvent(
        promptEvalCachedCount: json['prompt_eval_cached_count'] as int?,
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
    if (promptEvalCachedCount != null)
      'prompt_eval_cached_count': promptEvalCachedCount,
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

  /// Creates a copy with replaced values.
  ChatStreamEvent copyWith({
    Object? model = unsetCopyWithValue,
    Object? remoteModel = unsetCopyWithValue,
    Object? remoteHost = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? message = unsetCopyWithValue,
    Object? done = unsetCopyWithValue,
    Object? doneReason = unsetCopyWithValue,
    Object? totalDuration = unsetCopyWithValue,
    Object? loadDuration = unsetCopyWithValue,
    Object? promptEvalCount = unsetCopyWithValue,
    Object? promptEvalDuration = unsetCopyWithValue,
    Object? evalCount = unsetCopyWithValue,
    Object? evalDuration = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? promptEvalCachedCount = unsetCopyWithValue,
  }) {
    return ChatStreamEvent(
      model: identical(model, unsetCopyWithValue)
          ? this.model
          : model as String?,
      remoteModel: identical(remoteModel, unsetCopyWithValue)
          ? this.remoteModel
          : remoteModel as String?,
      remoteHost: identical(remoteHost, unsetCopyWithValue)
          ? this.remoteHost
          : remoteHost as String?,
      createdAt: identical(createdAt, unsetCopyWithValue)
          ? this.createdAt
          : createdAt as String?,
      message: identical(message, unsetCopyWithValue)
          ? this.message
          : message as ChatResponseMessage?,
      done: identical(done, unsetCopyWithValue) ? this.done : done as bool?,
      doneReason: identical(doneReason, unsetCopyWithValue)
          ? this.doneReason
          : doneReason as DoneReason?,
      totalDuration: identical(totalDuration, unsetCopyWithValue)
          ? this.totalDuration
          : totalDuration as int?,
      loadDuration: identical(loadDuration, unsetCopyWithValue)
          ? this.loadDuration
          : loadDuration as int?,
      promptEvalCount: identical(promptEvalCount, unsetCopyWithValue)
          ? this.promptEvalCount
          : promptEvalCount as int?,
      promptEvalDuration: identical(promptEvalDuration, unsetCopyWithValue)
          ? this.promptEvalDuration
          : promptEvalDuration as int?,
      evalCount: identical(evalCount, unsetCopyWithValue)
          ? this.evalCount
          : evalCount as int?,
      evalDuration: identical(evalDuration, unsetCopyWithValue)
          ? this.evalDuration
          : evalDuration as int?,
      logprobs: identical(logprobs, unsetCopyWithValue)
          ? this.logprobs
          : logprobs as List<Logprob>?,
      promptEvalCachedCount:
          identical(promptEvalCachedCount, unsetCopyWithValue)
          ? this.promptEvalCachedCount
          : promptEvalCachedCount as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamEvent &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          remoteModel == other.remoteModel &&
          remoteHost == other.remoteHost &&
          createdAt == other.createdAt &&
          message == other.message &&
          done == other.done &&
          doneReason == other.doneReason &&
          totalDuration == other.totalDuration &&
          loadDuration == other.loadDuration &&
          promptEvalCount == other.promptEvalCount &&
          promptEvalDuration == other.promptEvalDuration &&
          evalCount == other.evalCount &&
          evalDuration == other.evalDuration &&
          listsEqual(logprobs, other.logprobs) &&
          promptEvalCachedCount == other.promptEvalCachedCount;

  @override
  int get hashCode => Object.hashAll([
    model,
    remoteModel,
    remoteHost,
    createdAt,
    message,
    done,
    doneReason,
    totalDuration,
    loadDuration,
    promptEvalCount,
    promptEvalDuration,
    evalCount,
    evalDuration,
    listHash(logprobs),
    promptEvalCachedCount,
  ]);

  @override
  String toString() =>
      'ChatStreamEvent('
      'model: $model, '
      'remoteModel: $remoteModel, '
      'remoteHost: $remoteHost, '
      'createdAt: $createdAt, '
      'message: $message, '
      'done: $done, '
      'doneReason: $doneReason, '
      'totalDuration: $totalDuration, '
      'loadDuration: $loadDuration, '
      'promptEvalCount: $promptEvalCount, '
      'promptEvalDuration: $promptEvalDuration, '
      'evalCount: $evalCount, '
      'evalDuration: $evalDuration, '
      'logprobs: $logprobs, '
      'promptEvalCachedCount: $promptEvalCachedCount)';
}
