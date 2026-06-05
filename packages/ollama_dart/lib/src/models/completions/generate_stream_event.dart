import 'package:meta/meta.dart';

import '../common/done_reason.dart';

/// A streaming event from text generation.
@immutable
class GenerateStreamEvent {
  /// Model name.
  final String? model;

  /// Remote model name, if using a remote/proxy model.
  final String? remoteModel;

  /// Remote host, if using a remote/proxy model.
  final String? remoteHost;

  /// ISO 8601 timestamp of response creation.
  final String? createdAt;

  /// The model's generated text response for this chunk.
  final String? response;

  /// The model's generated thinking output for this chunk.
  final String? thinking;

  /// Indicates whether the stream has finished.
  final bool? done;

  /// Reason streaming finished.
  final DoneReason? doneReason;

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

  /// Base64-encoded generated image (final chunk for image generation models).
  ///
  /// Experimental: only present for image generation models. Decode with
  /// `base64Decode` before use. May change or be removed in a future Ollama
  /// release.
  final String? image;

  /// Number of completed diffusion steps during image generation.
  ///
  /// Experimental: only present for image generation models while streaming.
  final int? completed;

  /// Total number of diffusion steps for image generation.
  ///
  /// Experimental: only present for image generation models while streaming.
  final int? total;

  /// Creates a [GenerateStreamEvent].
  const GenerateStreamEvent({
    this.model,
    this.remoteModel,
    this.remoteHost,
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
    this.image,
    this.completed,
    this.total,
  });

  /// Creates a [GenerateStreamEvent] from JSON.
  factory GenerateStreamEvent.fromJson(Map<String, dynamic> json) =>
      GenerateStreamEvent(
        model: json['model'] as String?,
        remoteModel: json['remote_model'] as String?,
        remoteHost: json['remote_host'] as String?,
        createdAt: json['created_at'] as String?,
        response: json['response'] as String?,
        thinking: json['thinking'] as String?,
        done: json['done'] as bool?,
        doneReason: doneReasonFromString(json['done_reason'] as String?),
        totalDuration: json['total_duration'] as int?,
        loadDuration: json['load_duration'] as int?,
        promptEvalCount: json['prompt_eval_count'] as int?,
        promptEvalDuration: json['prompt_eval_duration'] as int?,
        evalCount: json['eval_count'] as int?,
        evalDuration: json['eval_duration'] as int?,
        image: json['image'] as String?,
        completed: json['completed'] as int?,
        total: json['total'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (model != null) 'model': model,
    if (remoteModel != null) 'remote_model': remoteModel,
    if (remoteHost != null) 'remote_host': remoteHost,
    if (createdAt != null) 'created_at': createdAt,
    if (response != null) 'response': response,
    if (thinking != null) 'thinking': thinking,
    if (done != null) 'done': done,
    if (doneReason != null) 'done_reason': doneReasonToString(doneReason!),
    if (totalDuration != null) 'total_duration': totalDuration,
    if (loadDuration != null) 'load_duration': loadDuration,
    if (promptEvalCount != null) 'prompt_eval_count': promptEvalCount,
    if (promptEvalDuration != null) 'prompt_eval_duration': promptEvalDuration,
    if (evalCount != null) 'eval_count': evalCount,
    if (evalDuration != null) 'eval_duration': evalDuration,
    if (image != null) 'image': image,
    if (completed != null) 'completed': completed,
    if (total != null) 'total': total,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateStreamEvent &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          remoteModel == other.remoteModel &&
          remoteHost == other.remoteHost &&
          createdAt == other.createdAt &&
          response == other.response &&
          thinking == other.thinking &&
          done == other.done &&
          doneReason == other.doneReason &&
          totalDuration == other.totalDuration &&
          loadDuration == other.loadDuration &&
          promptEvalCount == other.promptEvalCount &&
          promptEvalDuration == other.promptEvalDuration &&
          evalCount == other.evalCount &&
          evalDuration == other.evalDuration &&
          image == other.image &&
          completed == other.completed &&
          total == other.total;

  @override
  int get hashCode => Object.hashAll([
    model,
    remoteModel,
    remoteHost,
    createdAt,
    response,
    thinking,
    done,
    doneReason,
    totalDuration,
    loadDuration,
    promptEvalCount,
    promptEvalDuration,
    evalCount,
    evalDuration,
    image,
    completed,
    total,
  ]);

  @override
  String toString() =>
      'GenerateStreamEvent('
      'model: $model, '
      'remoteModel: $remoteModel, '
      'remoteHost: $remoteHost, '
      'createdAt: $createdAt, '
      'response: $response, '
      'thinking: $thinking, '
      'done: $done, '
      'doneReason: $doneReason, '
      'totalDuration: $totalDuration, '
      'loadDuration: $loadDuration, '
      'promptEvalCount: $promptEvalCount, '
      'promptEvalDuration: $promptEvalDuration, '
      'evalCount: $evalCount, '
      'evalDuration: $evalDuration, '
      'image: ${image == null ? null : '[${image!.length} chars]'}, '
      'completed: $completed, '
      'total: $total)';
}
