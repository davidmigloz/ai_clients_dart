import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../messages/input_message.dart';
import '../messages/message_create_request.dart';
import '../messages/thinking_config.dart';

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
  final Map<String, dynamic>? toolChoice;

  /// Tools available to the model.
  final List<Map<String, dynamic>>? tools;

  /// Creates a [TokenCountRequest].
  const TokenCountRequest({
    required this.model,
    required this.messages,
    this.system,
    this.thinking,
    this.toolChoice,
    this.tools,
  });

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
      toolChoice: json['tool_choice'] as Map<String, dynamic>?,
      tools: (json['tools'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((e) => e.toJson()).toList(),
    if (system != null) 'system': system!.toJson(),
    if (thinking != null) 'thinking': thinking!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice,
    if (tools != null) 'tools': tools,
  };

  /// Creates a copy with replaced values.
  TokenCountRequest copyWith({
    String? model,
    List<InputMessage>? messages,
    Object? system = unsetCopyWithValue,
    Object? thinking = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
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
          : toolChoice as Map<String, dynamic>?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<Map<String, dynamic>>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenCountRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          _listsEqual(messages, other.messages) &&
          system == other.system &&
          thinking == other.thinking &&
          _mapsEqual(toolChoice, other.toolChoice) &&
          _listsEqual(tools, other.tools);

  @override
  int get hashCode =>
      Object.hash(model, messages, system, thinking, toolChoice, tools);

  @override
  String toString() =>
      'TokenCountRequest(model: $model, messages: $messages, system: $system, '
      'thinking: $thinking, toolChoice: $toolChoice, tools: $tools)';
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
