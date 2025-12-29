import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../completions/logprob.dart';
import '../tools/tool_call.dart';

/// Response message from the assistant.
@immutable
class ChatResponseMessage {
  /// Always `assistant` for model responses.
  final String? role;

  /// Assistant message text.
  final String? content;

  /// Optional deliberate thinking trace when `think` is enabled.
  final String? thinking;

  /// Tool calls requested by the assistant.
  final List<ToolCall>? toolCalls;

  /// Optional base64-encoded images in the response.
  final List<String>? images;

  /// Creates a [ChatResponseMessage].
  const ChatResponseMessage({
    this.role,
    this.content,
    this.thinking,
    this.toolCalls,
    this.images,
  });

  /// Creates a [ChatResponseMessage] from JSON.
  factory ChatResponseMessage.fromJson(Map<String, dynamic> json) =>
      ChatResponseMessage(
        role: json['role'] as String?,
        content: json['content'] as String?,
        thinking: json['thinking'] as String?,
        toolCalls: (json['tool_calls'] as List?)
            ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
            .toList(),
        images: (json['images'] as List?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (role != null) 'role': role,
    if (content != null) 'content': content,
    if (thinking != null) 'thinking': thinking,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((e) => e.toJson()).toList(),
    if (images != null) 'images': images,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatResponseMessage &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content &&
          thinking == other.thinking;

  @override
  int get hashCode => Object.hash(role, content, thinking);

  @override
  String toString() =>
      'ChatResponseMessage('
      'role: $role, '
      'content: $content, '
      'thinking: $thinking)';
}

/// Response from chat completion.
@immutable
class ChatResponse {
  /// Model name used to generate this message.
  final String? model;

  /// Timestamp of response creation (ISO 8601).
  final String? createdAt;

  /// The assistant's response message.
  final ChatResponseMessage? message;

  /// Indicates whether the chat response has finished.
  final bool? done;

  /// Reason the response finished.
  final String? doneReason;

  /// Total time spent generating in nanoseconds.
  final int? totalDuration;

  /// Time spent loading the model in nanoseconds.
  final int? loadDuration;

  /// Number of tokens in the prompt.
  final int? promptEvalCount;

  /// Time spent evaluating the prompt in nanoseconds.
  final int? promptEvalDuration;

  /// Number of tokens generated in the response.
  final int? evalCount;

  /// Time spent generating tokens in nanoseconds.
  final int? evalDuration;

  /// Log probability information for generated tokens.
  final List<Logprob>? logprobs;

  /// Creates a [ChatResponse].
  const ChatResponse({
    this.model,
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

  /// Creates a [ChatResponse] from JSON.
  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    model: json['model'] as String?,
    createdAt: json['created_at'] as String?,
    message: json['message'] != null
        ? ChatResponseMessage.fromJson(json['message'] as Map<String, dynamic>)
        : null,
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
    if (message != null) 'message': message!.toJson(),
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
  ChatResponse copyWith({
    Object? model = unsetCopyWithValue,
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
  }) {
    return ChatResponse(
      model: model == unsetCopyWithValue ? this.model : model as String?,
      createdAt: createdAt == unsetCopyWithValue
          ? this.createdAt
          : createdAt as String?,
      message: message == unsetCopyWithValue
          ? this.message
          : message as ChatResponseMessage?,
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
      other is ChatResponse &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          createdAt == other.createdAt &&
          done == other.done;

  @override
  int get hashCode => Object.hash(model, createdAt, done);

  @override
  String toString() =>
      'ChatResponse('
      'model: $model, '
      'message: $message, '
      'done: $done)';
}
