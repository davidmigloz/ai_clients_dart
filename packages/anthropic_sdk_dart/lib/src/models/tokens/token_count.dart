import 'package:meta/meta.dart';

import '../beta/config/output_config.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality.dart';
import '../messages/input_message.dart';
import '../messages/message_create_request.dart';
import '../messages/thinking_config.dart';
import '../metadata/cache_control.dart';
import '../metadata/speed.dart';
import '../tools/tool_choice.dart';
import '../tools/tool_definition.dart';

/// Request for counting tokens.
@immutable
class TokenCountRequest {
  /// The model to use for token counting.
  final String model;

  /// Input messages.
  final List<InputMessage> messages;

  /// System prompt.
  final SystemPrompt? system;

  /// Thinking configuration.
  final ThinkingConfig? thinking;

  /// Tool choice configuration.
  ///
  /// Controls how the model chooses tools. Use [ToolChoice.auto],
  /// [ToolChoice.any], [ToolChoice.tool], or [ToolChoice.none].
  final ToolChoice? toolChoice;

  /// Tools available to the model.
  ///
  /// Can include custom tools ([ToolDefinition.custom]) and built-in tools
  /// ([ToolDefinition.builtIn]).
  final List<ToolDefinition>? tools;

  /// Output behavior configuration (effort, structured output).
  final OutputConfig? outputConfig;

  /// Inference speed mode.
  final Speed? speed;

  /// Top-level cache control.
  ///
  /// Automatically applies a cache control marker to the last cacheable block
  /// in the request.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [TokenCountRequest].
  const TokenCountRequest({
    required this.model,
    required this.messages,
    this.system,
    this.thinking,
    this.toolChoice,
    this.tools,
    this.outputConfig,
    this.speed,
    this.cacheControl,
  });

  /// Creates a [TokenCountRequest] from a [MessageCreateRequest].
  ///
  /// Copies the fields relevant to token counting: model, messages,
  /// system, thinking, toolChoice, tools, outputConfig, speed, and
  /// cacheControl.
  factory TokenCountRequest.fromMessageCreateRequest(
    MessageCreateRequest request,
  ) {
    return TokenCountRequest(
      model: request.model,
      messages: request.messages,
      system: request.system,
      thinking: request.thinking,
      toolChoice: request.toolChoice,
      tools: request.tools,
      outputConfig: request.outputConfig,
      speed: request.speed,
      cacheControl: request.cacheControl,
    );
  }

  /// Creates a [TokenCountRequest] from JSON.
  factory TokenCountRequest.fromJson(Map<String, dynamic> json) {
    return TokenCountRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List)
          .map((e) => InputMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      system: json['system'] != null
          ? SystemPrompt.fromJson(json['system'])
          : null,
      thinking: json['thinking'] != null
          ? ThinkingConfig.fromJson(json['thinking'] as Map<String, dynamic>)
          : null,
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'] as Map<String, dynamic>)
          : null,
      tools: (json['tools'] as List?)
          ?.map((e) => ToolDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      outputConfig: json['output_config'] != null
          ? OutputConfig.fromJson(json['output_config'] as Map<String, dynamic>)
          : null,
      speed: json['speed'] != null
          ? Speed.fromJson(json['speed'] as String)
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (system != null) 'system': system!.toJson(),
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (outputConfig != null) 'output_config': outputConfig!.toJson(),
    if (speed != null) 'speed': speed!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  /// Creates a copy with replaced values.
  TokenCountRequest copyWith({
    String? model,
    List<InputMessage>? messages,
    Object? system = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? outputConfig = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
  }) {
    return TokenCountRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      system: system == unsetCopyWithValue
          ? this.system
          : system as SystemPrompt?,
      thinking: thinking == unsetCopyWithValue
          ? this.thinking
          : thinking as ThinkingConfig?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<ToolDefinition>?,
      outputConfig: outputConfig == unsetCopyWithValue
          ? this.outputConfig
          : outputConfig as OutputConfig?,
      speed: speed == unsetCopyWithValue ? this.speed : speed as Speed?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenCountRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listsEqual(messages, other.messages) &&
          system == other.system &&
          thinking == other.thinking &&
          toolChoice == other.toolChoice &&
          listsEqual(tools, other.tools) &&
          outputConfig == other.outputConfig &&
          speed == other.speed &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(
    model,
    listHash(messages),
    system,
    thinking,
    toolChoice,
    listHash(tools),
    outputConfig,
    speed,
    cacheControl,
  );

  @override
  String toString() =>
      'TokenCountRequest(model: $model, messages: $messages, system: $system, '
      'thinking: $thinking, toolChoice: $toolChoice, tools: $tools, '
      'outputConfig: $outputConfig, speed: $speed, '
      'cacheControl: $cacheControl)';
}

/// Response for token counting.
@immutable
class TokenCountResponse {
  /// Number of input tokens.
  final int inputTokens;

  /// Creates a [TokenCountResponse].
  const TokenCountResponse({required this.inputTokens});

  /// Creates a [TokenCountResponse] from JSON.
  factory TokenCountResponse.fromJson(Map<String, dynamic> json) {
    return TokenCountResponse(inputTokens: json['input_tokens'] as int);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'input_tokens': inputTokens};

  /// Creates a copy with replaced values.
  TokenCountResponse copyWith({int? inputTokens}) {
    return TokenCountResponse(inputTokens: inputTokens ?? this.inputTokens);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenCountResponse &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens;

  @override
  int get hashCode => inputTokens.hashCode;

  @override
  String toString() => 'TokenCountResponse(inputTokens: $inputTokens)';
}
