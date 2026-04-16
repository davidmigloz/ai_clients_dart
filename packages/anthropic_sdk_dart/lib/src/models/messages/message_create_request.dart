import 'package:meta/meta.dart';

import '../beta/config/output_config.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/cache_control.dart';
import '../metadata/metadata.dart';
import '../metadata/service_tier.dart';
import '../metadata/speed.dart';
import '../tools/tool_choice.dart';
import '../tools/tool_definition.dart';
import 'input_message.dart';
import 'thinking_config.dart';

/// System prompt content.
///
/// Can be a simple string or a list of text blocks.
sealed class SystemPrompt {
  const SystemPrompt();

  /// Creates a text system prompt.
  factory SystemPrompt.text(String text) = TextSystemPrompt;

  /// Creates a blocks system prompt.
  factory SystemPrompt.blocks(List<SystemTextBlock> blocks) =
      BlocksSystemPrompt;

  /// Creates a [SystemPrompt] from dynamic JSON value.
  factory SystemPrompt.fromJson(dynamic json) {
    if (json is String) {
      return TextSystemPrompt(json);
    }
    if (json is List) {
      return BlocksSystemPrompt(
        json
            .map((e) => SystemTextBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid SystemPrompt: $json');
  }

  /// Converts to JSON.
  dynamic toJson();
}

/// Text system prompt.
@immutable
class TextSystemPrompt extends SystemPrompt {
  /// The text content.
  final String text;

  /// Creates a [TextSystemPrompt].
  const TextSystemPrompt(this.text);

  @override
  String toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSystemPrompt &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextSystemPrompt(text: [${text.length} chars])';
}

/// Blocks system prompt.
@immutable
class BlocksSystemPrompt extends SystemPrompt {
  /// The text blocks.
  final List<SystemTextBlock> blocks;

  /// Creates a [BlocksSystemPrompt].
  const BlocksSystemPrompt(this.blocks);

  @override
  List<Map<String, dynamic>> toJson() => blocks.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlocksSystemPrompt &&
          runtimeType == other.runtimeType &&
          listsEqual(blocks, other.blocks);

  @override
  int get hashCode => listHash(blocks);

  @override
  String toString() => 'BlocksSystemPrompt(blocks: $blocks)';
}

/// Text block for system prompts.
@immutable
class SystemTextBlock {
  /// The text content.
  final String text;

  /// Cache control for this block.
  final CacheControlEphemeral? cacheControl;

  /// Creates a [SystemTextBlock].
  const SystemTextBlock({required this.text, this.cacheControl});

  /// Creates a [SystemTextBlock] from JSON.
  factory SystemTextBlock.fromJson(Map<String, dynamic> json) {
    return SystemTextBlock(
      text: json['text'] as String,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'text',
    'text': text,
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemTextBlock &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          cacheControl == other.cacheControl;

  @override
  int get hashCode => Object.hash(text, cacheControl);

  @override
  String toString() =>
      'SystemTextBlock(text: [${text.length} chars], cacheControl: $cacheControl)';
}

/// Request parameters for creating a message.
@immutable
class MessageCreateRequest {
  /// The model to use.
  final String model;

  /// Input messages for the conversation.
  final List<InputMessage> messages;

  /// Maximum number of tokens to generate.
  final int maxTokens;

  /// System prompt.
  final SystemPrompt? system;

  /// Request metadata.
  final Metadata? metadata;

  /// Service tier to use.
  final ServiceTierRequest? serviceTier;

  /// Custom stop sequences.
  final List<String>? stopSequences;

  /// Whether to stream the response.
  final bool? stream;

  /// Temperature for randomness (0.0-1.0).
  final double? temperature;

  /// Extended thinking configuration.
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

  /// Nucleus sampling parameter.
  final double? topP;

  /// Top-K sampling parameter.
  final int? topK;

  /// Inference region to execute the request in.
  final String? inferenceGeo;

  /// Output behavior configuration (effort, structured output).
  final OutputConfig? outputConfig;

  /// Optional reusable container identifier for code execution.
  final String? container;

  /// Inference speed mode.
  final Speed? speed;

  /// Top-level cache control.
  ///
  /// Automatically applies a cache control marker to the last cacheable block
  /// in the request.
  final CacheControlEphemeral? cacheControl;

  /// Optional identifier of the end-user profile this request belongs to.
  final String? userProfileId;

  /// Creates a [MessageCreateRequest].
  const MessageCreateRequest({
    required this.model,
    required this.messages,
    required this.maxTokens,
    this.system,
    this.metadata,
    this.serviceTier,
    this.stopSequences,
    this.stream,
    this.temperature,
    this.thinking,
    this.toolChoice,
    this.tools,
    this.topP,
    this.topK,
    this.inferenceGeo,
    this.outputConfig,
    this.container,
    this.speed,
    this.cacheControl,
    this.userProfileId,
  });

  /// Creates a [MessageCreateRequest] from JSON.
  factory MessageCreateRequest.fromJson(Map<String, dynamic> json) {
    return MessageCreateRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List)
          .map((e) => InputMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxTokens: json['max_tokens'] as int,
      system: json['system'] != null
          ? SystemPrompt.fromJson(json['system'])
          : null,
      metadata: json['metadata'] != null
          ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      serviceTier: json['service_tier'] != null
          ? ServiceTierRequest.fromJson(json['service_tier'] as String)
          : null,
      stopSequences: (json['stop_sequences'] as List?)?.cast<String>(),
      stream: json['stream'] as bool?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      thinking: json['thinking'] != null
          ? ThinkingConfig.fromJson(json['thinking'] as Map<String, dynamic>)
          : null,
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'] as Map<String, dynamic>)
          : null,
      tools: (json['tools'] as List?)
          ?.map((e) => ToolDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: json['top_k'] as int?,
      inferenceGeo: json['inference_geo'] as String?,
      outputConfig: json['output_config'] != null
          ? OutputConfig.fromJson(json['output_config'] as Map<String, dynamic>)
          : null,
      container: json['container'] as String?,
      speed: json['speed'] != null
          ? Speed.fromJson(json['speed'] as String)
          : null,
      cacheControl: json['cache_control'] != null
          ? CacheControlEphemeral.fromJson(
              json['cache_control'] as Map<String, dynamic>,
            )
          : null,
      userProfileId: json['user_profile_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    'max_tokens': maxTokens,
    if (system != null) 'system': system!.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (serviceTier != null) 'service_tier': serviceTier!.toJson(),
    if (stopSequences != null) 'stop_sequences': stopSequences,
    if (stream != null) 'stream': stream,
    if (temperature != null) 'temperature': temperature,
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (topP != null) 'top_p': topP,
    if (topK != null) 'top_k': topK,
    if (inferenceGeo != null) 'inference_geo': inferenceGeo,
    if (outputConfig != null) 'output_config': outputConfig!.toJson(),
    if (container != null) 'container': container,
    if (speed != null) 'speed': speed!.toJson(),
    if (cacheControl != null) 'cache_control': cacheControl!.toJson(),
    if (userProfileId != null) 'user_profile_id': userProfileId,
  };

  /// Creates a copy with replaced values.
  MessageCreateRequest copyWith({
    String? model,
    List<InputMessage>? messages,
    int? maxTokens,
    Object? system = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? stopSequences = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
    Object? inferenceGeo = unsetCopyWithValue,
    Object? outputConfig = unsetCopyWithValue,
    Object? container = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? cacheControl = unsetCopyWithValue,
    Object? userProfileId = unsetCopyWithValue,
  }) {
    return MessageCreateRequest(
      model: model ?? this.model,
      messages: messages ?? this.messages,
      maxTokens: maxTokens ?? this.maxTokens,
      system: system == unsetCopyWithValue
          ? this.system
          : system as SystemPrompt?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Metadata?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTierRequest?,
      stopSequences: stopSequences == unsetCopyWithValue
          ? this.stopSequences
          : stopSequences as List<String>?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      thinking: thinking == unsetCopyWithValue
          ? this.thinking
          : thinking as ThinkingConfig?,
      toolChoice: toolChoice == unsetCopyWithValue
          ? this.toolChoice
          : toolChoice as ToolChoice?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<ToolDefinition>?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
      inferenceGeo: inferenceGeo == unsetCopyWithValue
          ? this.inferenceGeo
          : inferenceGeo as String?,
      outputConfig: outputConfig == unsetCopyWithValue
          ? this.outputConfig
          : outputConfig as OutputConfig?,
      container: container == unsetCopyWithValue
          ? this.container
          : container as String?,
      speed: speed == unsetCopyWithValue ? this.speed : speed as Speed?,
      cacheControl: cacheControl == unsetCopyWithValue
          ? this.cacheControl
          : cacheControl as CacheControlEphemeral?,
      userProfileId: userProfileId == unsetCopyWithValue
          ? this.userProfileId
          : userProfileId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listsEqual(messages, other.messages) &&
          maxTokens == other.maxTokens &&
          system == other.system &&
          metadata == other.metadata &&
          serviceTier == other.serviceTier &&
          listsEqual(stopSequences, other.stopSequences) &&
          stream == other.stream &&
          temperature == other.temperature &&
          thinking == other.thinking &&
          toolChoice == other.toolChoice &&
          listsEqual(tools, other.tools) &&
          topP == other.topP &&
          topK == other.topK &&
          inferenceGeo == other.inferenceGeo &&
          outputConfig == other.outputConfig &&
          container == other.container &&
          speed == other.speed &&
          cacheControl == other.cacheControl &&
          userProfileId == other.userProfileId;

  @override
  int get hashCode => Object.hash(
    model,
    listHash(messages),
    maxTokens,
    system,
    metadata,
    serviceTier,
    listHash(stopSequences),
    stream,
    temperature,
    thinking,
    toolChoice,
    listHash(tools),
    topP,
    topK,
    inferenceGeo,
    outputConfig,
    container,
    speed,
    cacheControl,
    userProfileId,
  );

  @override
  String toString() =>
      'MessageCreateRequest(model: $model, messages: $messages, '
      'maxTokens: $maxTokens, system: $system, metadata: $metadata, '
      'serviceTier: $serviceTier, stopSequences: $stopSequences, '
      'stream: $stream, temperature: $temperature, thinking: $thinking, '
      'toolChoice: $toolChoice, tools: $tools, topP: $topP, topK: $topK, '
      'inferenceGeo: $inferenceGeo, outputConfig: $outputConfig, '
      'container: $container, speed: $speed, cacheControl: $cacheControl, '
      'userProfileId: $userProfileId)';
}
