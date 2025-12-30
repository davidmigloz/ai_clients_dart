import 'package:meta/meta.dart';

/// A streaming event from text generation.
@immutable
class GenerateStreamEvent {
  /// Model name.
  final String? model;

  /// ISO 8601 timestamp of response creation.
  final String? createdAt;

  /// The model's generated text response for this chunk.
  final String? response;

  /// The model's generated thinking output for this chunk.
  final String? thinking;

  /// Indicates whether the stream has finished.
  final bool? done;

  /// Reason streaming finished.
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

  /// Creates a [GenerateStreamEvent].
  const GenerateStreamEvent({
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
  });

  /// Creates a [GenerateStreamEvent] from JSON.
  factory GenerateStreamEvent.fromJson(Map<String, dynamic> json) =>
      GenerateStreamEvent(
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
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateStreamEvent &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          response == other.response &&
          done == other.done;

  @override
  int get hashCode => Object.hash(model, response, done);

  @override
  String toString() =>
      'GenerateStreamEvent('
      'model: $model, '
      'response: $response, '
      'done: $done)';
}
