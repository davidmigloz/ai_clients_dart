import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'logprob.dart';

/// Response from text generation.
@immutable
class GenerateResponse {
  /// Model name.
  final String? model;

  /// ISO 8601 timestamp of response creation.
  final String? createdAt;

  /// The model's generated text response.
  final String? response;

  /// The model's generated thinking output.
  final String? thinking;

  /// Indicates whether generation has finished.
  final bool? done;

  /// Reason the generation stopped.
  final String? doneReason;

  /// Time spent generating the response in nanoseconds.
  final int? totalDuration;

  /// Time spent loading the model in nanoseconds.
  final int? loadDuration;

  /// Number of input tokens in the prompt.
  final int? promptEvalCount;

  /// Time spent evaluating the prompt in nanoseconds.
  final int? promptEvalDuration;

  /// Number of output tokens generated.
  final int? evalCount;

  /// Time spent generating tokens in nanoseconds.
  final int? evalDuration;

  /// Log probability information for generated tokens.
  final List<Logprob>? logprobs;

  /// Creates a [GenerateResponse].
  const GenerateResponse({
    this.model,
    this.createdAt,
    this.response,
    this.thinking,
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

  /// Creates a [GenerateResponse] from JSON.
  factory GenerateResponse.fromJson(Map<String, dynamic> json) =>
      GenerateResponse(
        model: json['model'] as String?,
        createdAt: json['created_at'] as String?,
        response: json['response'] as String?,
        thinking: json['thinking'] as String?,
        done: json['done'] as bool?,
        doneReason: json['done_reason'] as String?,
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
    if (createdAt != null) 'created_at': createdAt,
    if (response != null) 'response': response,
    if (thinking != null) 'thinking': thinking,
    if (done != null) 'done': done,
    if (doneReason != null) 'done_reason': doneReason,
    if (totalDuration != null) 'total_duration': totalDuration,
    if (loadDuration != null) 'load_duration': loadDuration,
    if (promptEvalCount != null) 'prompt_eval_count': promptEvalCount,
    if (promptEvalDuration != null) 'prompt_eval_duration': promptEvalDuration,
    if (evalCount != null) 'eval_count': evalCount,
    if (evalDuration != null) 'eval_duration': evalDuration,
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  GenerateResponse copyWith({
    Object? model = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? response = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? done = unsetCopyWithValue,
    Object? doneReason = unsetCopyWithValue,
    Object? totalDuration = unsetCopyWithValue,
    Object? loadDuration = unsetCopyWithValue,
    Object? promptEvalCount = unsetCopyWithValue,
    Object? promptEvalDuration = unsetCopyWithValue,
    Object? evalCount = unsetCopyWithValue,
    Object? evalDuration = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
  }) {
    return GenerateResponse(
      model: model == unsetCopyWithValue ? this.model : model as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      response: response == unsetCopyWithValue
          ? this.response
          : response as String?,
      thinking: thinking == unsetCopyWithValue
          ? this.thinking
          : thinking as String?,
      done: done == unsetCopyWithValue ? this.done : done as bool?,
      doneReason: doneReason == unsetCopyWithValue
          ? this.doneReason
          : doneReason as String?,
      totalDuration: totalDuration == unsetCopyWithValue
          ? this.totalDuration
          : totalDuration as int?,
      loadDuration: loadDuration == unsetCopyWithValue
          ? this.loadDuration
          : loadDuration as int?,
      promptEvalCount: promptEvalCount == unsetCopyWithValue
          ? this.promptEvalCount
          : promptEvalCount as int?,
      promptEvalDuration: promptEvalDuration == unsetCopyWithValue
          ? this.promptEvalDuration
          : promptEvalDuration as int?,
      evalCount: evalCount == unsetCopyWithValue
          ? this.evalCount
          : evalCount as int?,
      evalDuration: evalDuration == unsetCopyWithValue
          ? this.evalDuration
          : evalDuration as int?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<Logprob>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateResponse &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          response == other.response &&
          done == other.done;

  @override
  int get hashCode => Object.hash(model, response, done);

  @override
  String toString() =>
      'GenerateResponse('
      'model: $model, '
      'response: $response, '
      'done: $done)';
}
