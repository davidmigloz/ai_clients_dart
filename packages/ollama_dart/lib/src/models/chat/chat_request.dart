import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/model_options.dart';
import '../tools/tool_definition.dart';
import 'chat_message.dart';

/// Request for chat completion.
@immutable
class ChatRequest {
  /// Model name.
  final String model;

  /// Chat history as an array of message objects.
  final List<ChatMessage> messages;

  /// Optional list of function tools the model may call.
  final List<ToolDefinition>? tools;

  /// Format to return a response in.
  ///
  /// Can be `json` or a JSON schema object.
  final Object? format;

  /// Runtime options for generation.
  final ModelOptions? options;

  /// Whether to stream the response.
  final bool? stream;

  /// Enable thinking mode.
  ///
  /// Can be `true`, `false`, or `"high"`, `"medium"`, `"low"`.
  final Object? think;

  /// Model keep-alive duration (e.g., `5m`, `0`).
  final Object? keepAlive;

  /// Whether to return log probabilities.
  final bool? logprobs;

  /// Number of most likely tokens to return at each position.
  final int? topLogprobs;

  /// Creates a [ChatRequest].
  const ChatRequest({
    required this.model,
    required this.messages,
    this.tools,
    this.format,
    this.options,
    this.stream,
    this.think,
    this.keepAlive,
    this.logprobs,
    this.topLogprobs,
  });

  /// Creates a [ChatRequest] from JSON.
  factory ChatRequest.fromJson(Map<String, dynamic> json) => ChatRequest(
    model: json['model'] as String,
    messages: (json['messages'] as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList(),
    tools: (json['tools'] as List?)
        ?.map((e) => ToolDefinition.fromJson(e as Map<String, dynamic>))
        .toList(),
    format: json['format'],
    options: json['options'] != null
        ? ModelOptions.fromJson(json['options'] as Map<String, dynamic>)
        : null,
    stream: json['stream'] as bool?,
    think: json['think'],
    keepAlive: json['keep_alive'],
    logprobs: json['logprobs'] as bool?,
    topLogprobs: json['top_logprobs'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (format != null) 'format': format,
    if (options != null) 'options': options!.toJson(),
    if (stream != null) 'stream': stream,
    if (think != null) 'think': think,
    if (keepAlive != null) 'keep_alive': keepAlive,
    if (logprobs != null) 'logprobs': logprobs,
    if (topLogprobs != null) 'top_logprobs': topLogprobs,
  };

  /// Creates a copy with replaced values.
  ChatRequest copyWith({
    String? model,
    List<ChatMessage>? messages,
    Object? tools = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
    Object? options = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? think = unsetCopyWithValue,
    Object? keepAlive = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? topLogprobs = unsetCopyWithValue,
  }) {
    return ChatRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<ToolDefinition>?,
      format: format == unsetCopyWithValue ? this.format : format,
      options: options == unsetCopyWithValue
          ? this.options
          : options as ModelOptions?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      think: think == unsetCopyWithValue ? this.think : think,
      keepAlive: keepAlive == unsetCopyWithValue ? this.keepAlive : keepAlive,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as bool?,
      topLogprobs: topLogprobs == unsetCopyWithValue
          ? this.topLogprobs
          : topLogprobs as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          stream == other.stream;

  @override
  int get hashCode => Object.hash(model, stream);

  @override
  String toString() => 'ChatRequest(model: $model, messages: $messages)';
}
