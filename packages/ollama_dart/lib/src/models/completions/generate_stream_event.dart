import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/done_reason.dart';
import '../common/equality_helpers.dart';
import '../tools/tool_call.dart';
import 'logprob.dart';

/// A streaming event from text generation.
///
/// [GenerateStreamEvent.fromJson] and [copyWith] copy and freeze [toolCalls],
/// [context], and [logprobs]. Existing collections within tool calls and
/// [Logprob] retain their historical behavior. The const constructor retains
/// supplied collection references, which callers should keep immutable.
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
  /// Ollama 0.35.0 rejects image generation; retained for compatible servers.
  final String? image;

  /// Number of completed diffusion steps during image generation.
  ///
  /// Experimental: only present for image generation models while streaming.
  /// Ollama 0.35.0 rejects image generation; retained for compatible servers.
  final int? completed;

  /// Total number of diffusion steps for image generation.
  ///
  /// Experimental: only present for image generation models while streaming.
  /// Ollama 0.35.0 rejects image generation; retained for compatible servers.
  final int? total;

  /// Number of prompt tokens read from the cache, when reported by the server.
  final int? promptEvalCachedCount;

  /// Tool calls parsed from the generated output, when present.
  final List<ToolCall>? toolCalls;

  /// Encoded conversation history, generally reported in the final chunk.
  ///
  /// Ollama deprecates context-based conversational memory. Prefer `/api/chat`
  /// with message history. Retained for existing generate workflows.
  final List<int>? context;

  /// Log probabilities for the generated tokens in this chunk.
  final List<Logprob>? logprobs;

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
    this.promptEvalCachedCount,
    this.toolCalls,
    this.context,
    this.logprobs,
  });

  /// Creates a [GenerateStreamEvent] from JSON.
  factory GenerateStreamEvent.fromJson(Map<String, dynamic> json) =>
      GenerateStreamEvent(
        promptEvalCachedCount: json['prompt_eval_cached_count'] as int?,
        toolCalls: _freezeList(
          (json['tool_calls'] as List?)?.map(
            (e) => ToolCall.fromJson(e as Map<String, dynamic>),
          ),
        ),
        context: _freezeList((json['context'] as List?)?.cast<int>()),
        logprobs: _freezeList(
          (json['logprobs'] as List?)?.map(
            (e) => Logprob.fromJson(e as Map<String, dynamic>),
          ),
        ),
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
    if (promptEvalCachedCount != null)
      'prompt_eval_cached_count': promptEvalCachedCount,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
    if (context != null) 'context': context,
    if (logprobs != null) 'logprobs': logprobs!.map((e) => e.toJson()).toList(),
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

  /// Creates a copy with replaced values.
  GenerateStreamEvent copyWith({
    Object? model = unsetCopyWithValue,
    Object? remoteModel = unsetCopyWithValue,
    Object? remoteHost = unsetCopyWithValue,
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
    Object? image = unsetCopyWithValue,
    Object? completed = unsetCopyWithValue,
    Object? total = unsetCopyWithValue,
    Object? promptEvalCachedCount = unsetCopyWithValue,
    Object? toolCalls = unsetCopyWithValue,
    Object? context = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
  }) {
    return GenerateStreamEvent(
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
      response: identical(response, unsetCopyWithValue)
          ? this.response
          : response as String?,
      thinking: identical(thinking, unsetCopyWithValue)
          ? this.thinking
          : thinking as String?,
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
      image: identical(image, unsetCopyWithValue)
          ? this.image
          : image as String?,
      completed: identical(completed, unsetCopyWithValue)
          ? this.completed
          : completed as int?,
      total: identical(total, unsetCopyWithValue) ? this.total : total as int?,
      promptEvalCachedCount:
          identical(promptEvalCachedCount, unsetCopyWithValue)
          ? this.promptEvalCachedCount
          : promptEvalCachedCount as int?,
      toolCalls: _freezeList(
        identical(toolCalls, unsetCopyWithValue)
            ? this.toolCalls
            : toolCalls as List<ToolCall>?,
      ),
      context: _freezeList(
        identical(context, unsetCopyWithValue)
            ? this.context
            : context as List<int>?,
      ),
      logprobs: _freezeList(
        identical(logprobs, unsetCopyWithValue)
            ? this.logprobs
            : logprobs as List<Logprob>?,
      ),
    );
  }

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
          total == other.total &&
          promptEvalCachedCount == other.promptEvalCachedCount &&
          listsEqual(toolCalls, other.toolCalls) &&
          listsEqual(context, other.context) &&
          listsEqual(logprobs, other.logprobs);

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
    promptEvalCachedCount,
    listHash(toolCalls),
    listHash(context),
    listHash(logprobs),
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
      'total: $total, '
      'promptEvalCachedCount: $promptEvalCachedCount, '
      'toolCalls: $toolCalls, '
      'context: $context, '
      'logprobs: $logprobs)';
}

List<T>? _freezeList<T>(Iterable<T>? values) =>
    values == null ? null : List<T>.unmodifiable(values);
