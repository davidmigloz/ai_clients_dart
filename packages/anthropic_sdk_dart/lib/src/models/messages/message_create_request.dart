import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/cache_control.dart';
import '../metadata/metadata.dart';
import '../metadata/service_tier.dart';
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
          _listsEqual(blocks, other.blocks);

  @override
  int get hashCode => blocks.hashCode;

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
  /// Controls how the model chooses tools.
  /// Use `Map<String, dynamic>` for now, will be replaced with ToolChoice type.
  final Map<String, dynamic>? toolChoice;

  /// Tools available to the model.
  ///
  /// Use `List<Map<String, dynamic>>` for now, will be replaced with Tool types.
  final List<Map<String, dynamic>>? tools;

  /// Nucleus sampling parameter.
  final double? topP;

  /// Top-K sampling parameter.
  final int? topK;

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
      toolChoice: json['tool_choice'] as Map<String, dynamic>?,
      tools: (json['tools'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      topP: (json['top_p'] as num?)?.toDouble(),
      topK: json['top_k'] as int?,
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
    if (toolChoice != null) 'tool_choice': toolChoice,
    if (tools != null) 'tools': tools,
    if (topP != null) 'top_p': topP,
    if (topK != null) 'top_k': topK,
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
          : toolChoice as Map<String, dynamic>?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<Map<String, dynamic>>?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          _listsEqual(messages, other.messages) &&
          maxTokens == other.maxTokens &&
          system == other.system &&
          metadata == other.metadata &&
          serviceTier == other.serviceTier &&
          _listsEqual(stopSequences, other.stopSequences) &&
          stream == other.stream &&
          temperature == other.temperature &&
          thinking == other.thinking &&
          _mapsEqual(toolChoice, other.toolChoice) &&
          _listsEqual(tools, other.tools) &&
          topP == other.topP &&
          topK == other.topK;

  @override
  int get hashCode => Object.hash(
    model,
    messages,
    maxTokens,
    system,
    metadata,
    serviceTier,
    stopSequences,
    stream,
    temperature,
    thinking,
    toolChoice,
    tools,
    topP,
    topK,
  );

  @override
  String toString() =>
      'MessageCreateRequest(model: $model, messages: $messages, '
      'maxTokens: $maxTokens, system: $system, metadata: $metadata, '
      'serviceTier: $serviceTier, stopSequences: $stopSequences, '
      'stream: $stream, temperature: $temperature, thinking: $thinking, '
      'toolChoice: $toolChoice, tools: $tools, topP: $topP, topK: $topK)';
}

bool _listsEqual<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapsEqual<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
