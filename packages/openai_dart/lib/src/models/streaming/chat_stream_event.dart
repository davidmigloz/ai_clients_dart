import 'dart:convert';

import 'package:meta/meta.dart';

import '../chat/chat_audio.dart';
import '../chat/chat_completion.dart';
import '../chat/chat_completion_moderation.dart';
import '../chat/chat_message.dart';
import '../chat/reasoning_detail.dart';
import '../chat/tool_call.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/finish_reason.dart';
import '../common/json_helpers.dart';
import '../common/logprobs.dart';
import '../common/usage.dart';

/// A streaming event from the chat completions API.
///
/// Streaming events are received as the model generates tokens.
/// Each event contains partial content that can be displayed
/// progressively to the user.
///
/// ## Example
///
/// ```dart
/// final stream = client.chat.completions.createStream(request);
///
/// await for (final event in stream) {
///   final content = event.textDelta;
///   if (content != null) {
///     stdout.write(content);
///   }
/// }
/// ```
@immutable
class ChatStreamEvent {
  /// Creates a [ChatStreamEvent].
  const ChatStreamEvent({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
    this.moderation,
    this.provider,
    this.obfuscation,
  });

  /// Creates a [ChatStreamEvent] from JSON.
  factory ChatStreamEvent.fromJson(Map<String, dynamic> json) {
    return ChatStreamEvent(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: json['created'] as int?,
      model: json['model'] as String?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => ChatStreamChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      systemFingerprint: json['system_fingerprint'] as String?,
      serviceTier: json['service_tier'] as String?,
      moderation: json['moderation'] != null
          ? ChatCompletionModeration.fromJson(
              json['moderation'] as Map<String, dynamic>,
            )
          : null,
      provider: json['provider'] as String?,
      obfuscation: json.containsKey('obfuscation')
          ? requireJsonString(
              json['obfuscation'],
              'ChatStreamEvent.obfuscation',
            )
          : null,
    );
  }

  /// The unique identifier for this completion.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter
  /// doesn't return `id` with some models).
  final String? id;

  /// The object type (usually "chat.completion.chunk").
  ///
  /// May be null with some OpenAI-compatible providers (e.g., FastChat).
  /// Some providers send "chat.completion" instead of "chat.completion.chunk".
  final String? object;

  /// The Unix timestamp when this completion was created.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., FastChat).
  final int? created;

  /// The model used for this completion.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., TogetherAI).
  final String? model;

  /// The list of completion choices.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., Groq doesn't
  /// always return this field).
  final List<ChatStreamChoice>? choices;

  /// Token usage statistics (only in the final event if requested).
  final Usage? usage;

  /// The system fingerprint for the model configuration.
  final String? systemFingerprint;

  /// The service tier used (if applicable).
  final String? serviceTier;

  /// Moderation results for the request input and generated output.
  ///
  /// Present on the dedicated moderation chunk when moderated completions were
  /// requested via `ChatCompletionCreateRequest.moderation`.
  final ChatCompletionModeration? moderation;

  /// **OpenRouter only.** The provider that served the request.
  ///
  /// Not part of the official OpenAI API.
  final String? provider;

  /// Random padding used to normalize streaming payload sizes.
  ///
  /// This is metadata rather than model output. It must not be appended to
  /// content, tool arguments, or reasoning. An empty string is preserved when
  /// supplied. Omission is supported; an explicitly null wire value is invalid.
  final String? obfuscation;

  /// Gets the text delta from the first choice.
  ///
  /// Returns null if there are no choices or no content delta.
  String? get textDelta => choices?.firstOrNull?.delta.content;

  /// Gets the first choice.
  ///
  /// Returns null if there are no choices.
  ChatStreamChoice? get firstChoice => choices?.firstOrNull;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (object != null) 'object': object,
    if (created != null) 'created': created,
    if (model != null) 'model': model,
    if (choices != null) 'choices': choices!.map((c) => c.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
    if (serviceTier != null) 'service_tier': serviceTier,
    if (moderation != null) 'moderation': moderation!.toJson(),
    if (provider != null) 'provider': provider,
    if (obfuscation != null) 'obfuscation': obfuscation,
  };

  /// Creates a copy, allowing every optional field to be explicitly cleared.
  ChatStreamEvent copyWith({
    Object? id = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? created = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? choices = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? systemFingerprint = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? provider = unsetCopyWithValue,
    Object? obfuscation = unsetCopyWithValue,
  }) => ChatStreamEvent(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    object: object == unsetCopyWithValue ? this.object : object as String?,
    created: created == unsetCopyWithValue ? this.created : created as int?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    choices: choices == unsetCopyWithValue
        ? this.choices
        : choices == null
        ? null
        : List<ChatStreamChoice>.from(choices as List),
    usage: usage == unsetCopyWithValue ? this.usage : usage as Usage?,
    systemFingerprint: systemFingerprint == unsetCopyWithValue
        ? this.systemFingerprint
        : systemFingerprint as String?,
    serviceTier: serviceTier == unsetCopyWithValue
        ? this.serviceTier
        : serviceTier as String?,
    moderation: moderation == unsetCopyWithValue
        ? this.moderation
        : moderation as ChatCompletionModeration?,
    provider: provider == unsetCopyWithValue
        ? this.provider
        : provider as String?,
    obfuscation: obfuscation == unsetCopyWithValue
        ? this.obfuscation
        : obfuscation as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          created == other.created &&
          model == other.model &&
          listsEqual(choices, other.choices) &&
          usage == other.usage &&
          systemFingerprint == other.systemFingerprint &&
          serviceTier == other.serviceTier &&
          moderation == other.moderation &&
          provider == other.provider &&
          obfuscation == other.obfuscation;

  @override
  int get hashCode => Object.hash(
    id,
    object,
    created,
    model,
    listHash(choices),
    usage,
    systemFingerprint,
    serviceTier,
    moderation,
    provider,
    obfuscation,
  );

  @override
  String toString() =>
      'ChatStreamEvent(id: $id, object: $object, created: $created, model: $model, '
      'choices: ${choices == null ? 'null' : '${choices!.length} items'}, '
      'usage: $usage, systemFingerprint: $systemFingerprint, '
      'serviceTier: $serviceTier, moderation: ${moderation == null ? 'null' : 'present'}, '
      'provider: $provider, '
      'obfuscation: ${obfuscation == null ? 'null' : '${obfuscation!.length} chars'})';
}

/// A single choice in a streaming response.
@immutable
class ChatStreamChoice {
  /// Creates a [ChatStreamChoice].
  const ChatStreamChoice({
    this.index,
    required this.delta,
    this.finishReason,
    this.logprobs,
  }) : _deltaPresence = _DeltaPresence.present;

  const ChatStreamChoice._({
    this.index,
    required this.delta,
    this.finishReason,
    this.logprobs,
    required this._deltaPresence,
  });

  /// Creates a [ChatStreamChoice] from JSON.
  factory ChatStreamChoice.fromJson(Map<String, dynamic> json) {
    final rawDelta = json['delta'];
    return ChatStreamChoice._(
      index: json['index'] as int?,
      // Some providers may return null or omit the delta field
      delta: rawDelta is Map
          ? ChatDelta.fromJson(
              requireJsonObject(rawDelta, 'ChatStreamChoice.delta'),
            )
          : const ChatDelta(),
      deltaPresence: !json.containsKey('delta')
          ? _DeltaPresence.absent
          : rawDelta == null
          ? _DeltaPresence.nullValue
          : _DeltaPresence.present,
      finishReason: json['finish_reason'] != null
          ? FinishReason.fromJson(json['finish_reason'] as String)
          : null,
      logprobs: json['logprobs'] != null
          ? Logprobs.fromJson(json['logprobs'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The index of this choice in the list.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter).
  final int? index;

  /// The delta content for this chunk.
  ///
  /// Defaults to an empty delta if null or missing in the JSON response,
  /// which can occur with some OpenAI-compatible providers.
  final ChatDelta delta;

  // Node ignores absent/null deltas when tracking the final audio update.
  final _DeltaPresence _deltaPresence;

  /// The reason the model stopped generating (in the final chunk).
  final FinishReason? finishReason;

  /// Log probability information.
  final Logprobs? logprobs;

  /// Whether this is the final chunk (has a finish reason).
  bool get isFinal => finishReason != null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (index != null) 'index': index,
    if (_deltaPresence == _DeltaPresence.present) 'delta': delta.toJson(),
    if (_deltaPresence == _DeltaPresence.nullValue) 'delta': null,
    if (finishReason != null) 'finish_reason': finishReason!.toJson(),
    if (logprobs != null) 'logprobs': logprobs!.toJson(),
  };

  /// Creates a copy, allowing nullable metadata to be explicitly cleared.
  ChatStreamChoice copyWith({
    Object? index = unsetCopyWithValue,
    ChatDelta? delta,
    Object? finishReason = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
  }) => ChatStreamChoice._(
    index: index == unsetCopyWithValue ? this.index : index as int?,
    delta: delta ?? this.delta,
    deltaPresence: delta == null ? _deltaPresence : _DeltaPresence.present,
    finishReason: finishReason == unsetCopyWithValue
        ? this.finishReason
        : finishReason as FinishReason?,
    logprobs: logprobs == unsetCopyWithValue
        ? this.logprobs
        : logprobs as Logprobs?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatStreamChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          delta == other.delta &&
          _deltaPresence == other._deltaPresence &&
          finishReason == other.finishReason &&
          logprobs == other.logprobs;

  @override
  int get hashCode =>
      Object.hash(index, delta, _deltaPresence, finishReason, logprobs);

  @override
  String toString() =>
      'ChatStreamChoice(index: $index, delta: ${_deltaPresence.name}, finishReason: $finishReason, '
      'logprobs: ${logprobs == null ? 'null' : 'present'})';
}

enum _DeltaPresence { absent, nullValue, present }

/// The delta content in a streaming chunk.
///
/// Each delta contains only the new tokens generated since the last chunk.
@immutable
class ChatDelta {
  /// Creates a [ChatDelta].
  const ChatDelta({
    this.role,
    this.content,
    this.refusal,
    this.toolCalls,
    this.reasoningContent,
    this.reasoning,
    this.reasoningDetails,
    this.audio,
  }) : _extraFields = const {};

  const ChatDelta._({
    this.role,
    this.content,
    this.refusal,
    this.toolCalls,
    this.reasoningContent,
    this.reasoning,
    this.reasoningDetails,
    this.audio,
    required this._extraFields,
  });

  /// Creates a [ChatDelta] from JSON.
  factory ChatDelta.fromJson(Map<String, dynamic> json) {
    ChatAudioDelta? audio;
    if (json.containsKey('audio')) {
      final rawAudio = requireJsonObject(json['audio'], 'ChatDelta.audio');
      try {
        audio = ChatAudioDelta.fromJson(rawAudio);
      } on FormatException catch (error) {
        throw FormatException('ChatDelta.audio: ${error.message}');
      }
    }
    return ChatDelta._(
      role: json['role'] as String?,
      content: json['content'] as String?,
      refusal: json['refusal'] as String?,
      toolCalls: (json['tool_calls'] as List<dynamic>?)?.indexed
          .map(
            (e) => ToolCallDelta.fromJson(
              e.$2 as Map<String, dynamic>,
              fallbackIndex: e.$1,
            ),
          )
          .toList(),
      // Reasoning fields for OpenRouter/DeepSeek compatibility
      reasoningContent: json['reasoning_content'] as String?,
      reasoning: json['reasoning'] as String?,
      reasoningDetails: (json['reasoning_details'] as List<dynamic>?)
          ?.map((e) => ReasoningDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      audio: audio,
      extraFields: freezeJsonObject({
        for (final entry in json.entries)
          if (!_knownDeltaKeys.contains(entry.key) ||
              (_providerReasoningKeys.contains(entry.key) &&
                  entry.value == null))
            entry.key: entry.value,
      }),
    );
  }

  /// The role of the message author (only in the first chunk).
  final String? role;

  /// The new content tokens.
  final String? content;

  /// Refusal content (if the model refused to respond).
  final String? refusal;

  /// Tool call deltas.
  final List<ToolCallDelta>? toolCalls;

  /// **DeepSeek R1 / vLLM only.** Reasoning content delta.
  ///
  /// Not part of the official OpenAI API. Contains new reasoning tokens.
  final String? reasoningContent;

  /// **OpenRouter only.** Reasoning summary delta.
  ///
  /// Not part of the official OpenAI API.
  final String? reasoning;

  /// **OpenRouter only.** Detailed reasoning delta.
  ///
  /// Not part of the official OpenAI API.
  final List<ReasoningDetail>? reasoningDetails;

  /// Partial audio output, whose fields arrive independently across chunks.
  ///
  /// Empty objects and empty strings are preserved. Present-null audio objects
  /// or members are invalid wire values. Use the accumulator's audio snapshot
  /// to inspect progress without requiring a complete output.
  final ChatAudioDelta? audio;

  // Unknown and provider-reasoning keys affect Node's pure-expiry predicate.
  // Preserve their parsed presence and JSON, including explicit nulls.
  final Map<String, dynamic> _extraFields;

  static const _knownDeltaKeys = {
    'role',
    'content',
    'refusal',
    'tool_calls',
    'reasoning_content',
    'reasoning',
    'reasoning_details',
    'audio',
  };
  static const _providerReasoningKeys = {
    'reasoning_content',
    'reasoning',
    'reasoning_details',
  };

  bool get _isPureAudioExpiry =>
      audio?.expiresAt != null &&
      audio?.id == null &&
      audio?.data == null &&
      audio?.transcript == null &&
      role == null &&
      content == null &&
      refusal == null &&
      toolCalls == null &&
      reasoningContent == null &&
      reasoning == null &&
      reasoningDetails == null &&
      _extraFields.keys.every((key) => key == 'function_call') &&
      _extraFields['function_call'] == null;

  /// Whether this delta has content.
  bool get hasContent => content != null && content!.isNotEmpty;

  /// Whether this delta has tool calls.
  bool get hasToolCalls => toolCalls != null && toolCalls!.isNotEmpty;

  /// Whether this delta has reasoning content.
  bool get hasReasoningContent =>
      reasoningContent != null || reasoning != null || reasoningDetails != null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ..._extraFields,
    if (role != null) 'role': role,
    if (content != null) 'content': content,
    if (refusal != null) 'refusal': refusal,
    if (toolCalls != null)
      'tool_calls': toolCalls!.map((tc) => tc.toJson()).toList(),
    if (reasoningContent != null) 'reasoning_content': reasoningContent,
    if (reasoning != null) 'reasoning': reasoning,
    if (reasoningDetails != null)
      'reasoning_details': reasoningDetails!.map((rd) => rd.toJson()).toList(),
    if (audio != null) 'audio': audio!.toJson(),
  };

  /// Creates a copy, allowing every optional field to be explicitly cleared.
  ///
  /// Clearing provider reasoning also removes its parsed-presence marker.
  ChatDelta copyWith({
    Object? role = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
    Object? refusal = unsetCopyWithValue,
    Object? toolCalls = unsetCopyWithValue,
    Object? reasoningContent = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? reasoningDetails = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
  }) {
    final extras = Map<String, dynamic>.of(_extraFields);
    if (reasoningContent != unsetCopyWithValue) {
      extras.remove('reasoning_content');
    }
    if (reasoning != unsetCopyWithValue) extras.remove('reasoning');
    if (reasoningDetails != unsetCopyWithValue) {
      extras.remove('reasoning_details');
    }
    return ChatDelta._(
      role: role == unsetCopyWithValue ? this.role : role as String?,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      refusal: refusal == unsetCopyWithValue
          ? this.refusal
          : refusal as String?,
      toolCalls: toolCalls == unsetCopyWithValue
          ? this.toolCalls
          : toolCalls == null
          ? null
          : List<ToolCallDelta>.from(toolCalls as List),
      reasoningContent: reasoningContent == unsetCopyWithValue
          ? this.reasoningContent
          : reasoningContent as String?,
      reasoning: reasoning == unsetCopyWithValue
          ? this.reasoning
          : reasoning as String?,
      reasoningDetails: reasoningDetails == unsetCopyWithValue
          ? this.reasoningDetails
          : reasoningDetails == null
          ? null
          : List<ReasoningDetail>.from(reasoningDetails as List),
      audio: audio == unsetCopyWithValue
          ? this.audio
          : audio as ChatAudioDelta?,
      extraFields: freezeJsonObject(extras),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDelta &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          content == other.content &&
          refusal == other.refusal &&
          listsEqual(toolCalls, other.toolCalls) &&
          reasoningContent == other.reasoningContent &&
          reasoning == other.reasoning &&
          listsEqual(reasoningDetails, other.reasoningDetails) &&
          audio == other.audio &&
          mapsDeepEqual(_extraFields, other._extraFields);

  @override
  int get hashCode => Object.hash(
    role,
    content,
    refusal,
    toolCalls != null ? Object.hashAll(toolCalls!) : null,
    reasoningContent,
    reasoning,
    reasoningDetails != null ? Object.hashAll(reasoningDetails!) : null,
    audio,
    mapDeepHashCode(_extraFields),
  );

  @override
  String toString() =>
      'ChatDelta(role: $role, content: ${_textSummary(content)}, '
      'refusal: ${_textSummary(refusal)}, toolCalls: ${_listSummary(toolCalls)}, '
      'reasoningContent: ${_textSummary(reasoningContent)}, reasoning: ${_textSummary(reasoning)}, '
      'reasoningDetails: ${_listSummary(reasoningDetails)}, audio: $audio, '
      'additionalFields: ${_extraFields.length} entries)';
}

String _textSummary(String? value) =>
    value == null ? 'null' : '${value.length} chars';
String _listSummary(List<dynamic>? value) =>
    value == null ? 'null' : '${value.length} items';

/// A tool call delta in a streaming chunk.
@immutable
class ToolCallDelta {
  /// Creates a [ToolCallDelta].
  const ToolCallDelta({required this.index, this.id, this.type, this.function});

  /// Creates a [ToolCallDelta] from JSON.
  ///
  /// If `index` is missing from [json], [fallbackIndex] is used instead
  /// (defaults to 0). This handles OpenAI-compatible providers (e.g. Ollama)
  /// that omit the field.
  factory ToolCallDelta.fromJson(
    Map<String, dynamic> json, {
    int fallbackIndex = 0,
  }) {
    return ToolCallDelta(
      index: json['index'] as int? ?? fallbackIndex,
      id: json['id'] as String?,
      type: json['type'] as String?,
      function: json['function'] != null
          ? FunctionCallDelta.fromJson(json['function'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The index of this tool call in the list.
  final int index;

  /// The ID of the tool call (only in the first chunk for this tool call).
  final String? id;

  /// The type of the tool call (only in the first chunk).
  final String? type;

  /// The function call delta.
  final FunctionCallDelta? function;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'index': index,
    if (id != null) 'id': id,
    if (type != null) 'type': type,
    if (function != null) 'function': function!.toJson(),
  };

  /// Creates a copy, allowing optional metadata to be explicitly cleared.
  ToolCallDelta copyWith({
    int? index,
    Object? id = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    Object? function = unsetCopyWithValue,
  }) => ToolCallDelta(
    index: index ?? this.index,
    id: id == unsetCopyWithValue ? this.id : id as String?,
    type: type == unsetCopyWithValue ? this.type : type as String?,
    function: function == unsetCopyWithValue
        ? this.function
        : function as FunctionCallDelta?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCallDelta &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          id == other.id &&
          type == other.type &&
          function == other.function;

  @override
  int get hashCode => Object.hash(index, id, type, function);

  @override
  String toString() =>
      'ToolCallDelta(index: $index, id: $id, type: $type, '
      'function: ${function == null ? 'null' : 'present'})';
}

/// A function call delta in a streaming chunk.
@immutable
class FunctionCallDelta {
  /// Creates a [FunctionCallDelta].
  const FunctionCallDelta({this.name, this.arguments});

  /// Creates a [FunctionCallDelta] from JSON.
  factory FunctionCallDelta.fromJson(Map<String, dynamic> json) {
    return FunctionCallDelta(
      name: json['name'] as String?,
      // Some providers (e.g., Llamafile, custom Bedrock proxies) may return
      // a parsed object instead of a JSON string fragment.
      arguments: switch (json['arguments']) {
        final String s => s,
        final Map<dynamic, dynamic> m => jsonEncode(m),
        _ => null,
      },
    );
  }

  /// The name of the function (only in the first chunk for this function).
  final String? name;

  /// The partial arguments string for this chunk.
  ///
  /// Per the OpenAI spec, this is a JSON string fragment. Some providers
  /// (e.g., Llamafile, custom Bedrock proxies) may return a parsed object
  /// instead. The [fromJson] factory handles both formats.
  final String? arguments;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallDelta &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          arguments == other.arguments;

  @override
  int get hashCode => Object.hash(name, arguments);

  @override
  String toString() {
    if (name != null) return 'FunctionCallDelta(name: $name)';
    return 'FunctionCallDelta(arguments: ${arguments?.length ?? 0} chars)';
  }
}

/// A read-only snapshot of a single accumulated choice's state.
///
/// Each instance corresponds to one of the `n` choices in the request.
/// For standard requests (`n=1`), there is a single [AccumulatedChoice].
///
/// Use [ChatStreamAccumulator.choices] to access per-choice state.
@immutable
class AccumulatedChoice {
  const AccumulatedChoice._({
    required this.index,
    required this.content,
    required this.refusal,
    required this.role,
    required this.finishReason,
    required this.toolCalls,
    required this.reasoningContent,
    required this.reasoning,
    required this.reasoningDetails,
    required this.reasoningDetailsPresent,
    required this.logprobs,
    required this.audio,
  });

  /// The index of this choice.
  final int index;

  /// The accumulated text content.
  final String content;

  /// The accumulated refusal content.
  final String refusal;

  /// The message role.
  final String? role;

  /// The finish reason.
  final FinishReason? finishReason;

  /// The accumulated tool calls.
  final List<ToolCall> toolCalls;

  /// **DeepSeek R1 / vLLM only.** The accumulated reasoning content.
  final String reasoningContent;

  /// **OpenRouter only.** The accumulated reasoning summary.
  final String reasoning;

  /// **OpenRouter only.** The accumulated reasoning details.
  final List<ReasoningDetail> reasoningDetails;

  /// Whether at least one delta contained the `reasoning_details` field.
  ///
  /// This distinguishes an explicitly empty array from an absent field.
  final bool reasoningDetailsPresent;

  /// Log probability information.
  final Logprobs? logprobs;

  /// An immutable snapshot of the audio fields received for this choice.
  ///
  /// Null means no audio object was received; an empty object remains a partial
  /// snapshot. Its strings are stable when subsequent chunks arrive.
  final ChatAudioDelta? audio;

  /// Whether there are any tool calls.
  bool get hasToolCalls => toolCalls.isNotEmpty;

  /// Whether there is any reasoning content.
  bool get hasReasoningContent =>
      reasoningContent.isNotEmpty ||
      reasoning.isNotEmpty ||
      reasoningDetailsPresent;

  /// Creates an immutable copy; nullable metadata can be explicitly cleared.
  AccumulatedChoice copyWith({
    int? index,
    String? content,
    String? refusal,
    Object? role = unsetCopyWithValue,
    Object? finishReason = unsetCopyWithValue,
    List<ToolCall>? toolCalls,
    String? reasoningContent,
    String? reasoning,
    List<ReasoningDetail>? reasoningDetails,
    bool? reasoningDetailsPresent,
    Object? logprobs = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
  }) => AccumulatedChoice._(
    index: index ?? this.index,
    content: content ?? this.content,
    refusal: refusal ?? this.refusal,
    role: role == unsetCopyWithValue ? this.role : role as String?,
    finishReason: finishReason == unsetCopyWithValue
        ? this.finishReason
        : finishReason as FinishReason?,
    toolCalls: List.unmodifiable(toolCalls ?? this.toolCalls),
    reasoningContent: reasoningContent ?? this.reasoningContent,
    reasoning: reasoning ?? this.reasoning,
    reasoningDetails: List.unmodifiable(
      reasoningDetails ?? this.reasoningDetails,
    ),
    reasoningDetailsPresent:
        reasoningDetailsPresent ?? this.reasoningDetailsPresent,
    logprobs: logprobs == unsetCopyWithValue
        ? this.logprobs
        : logprobs as Logprobs?,
    audio: audio == unsetCopyWithValue ? this.audio : audio as ChatAudioDelta?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccumulatedChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          content == other.content &&
          refusal == other.refusal &&
          role == other.role &&
          finishReason == other.finishReason &&
          listsEqual(toolCalls, other.toolCalls) &&
          reasoningContent == other.reasoningContent &&
          reasoning == other.reasoning &&
          listsEqual(reasoningDetails, other.reasoningDetails) &&
          reasoningDetailsPresent == other.reasoningDetailsPresent &&
          logprobs == other.logprobs &&
          audio == other.audio;

  @override
  int get hashCode => Object.hash(
    index,
    content,
    refusal,
    role,
    finishReason,
    listHash(toolCalls),
    reasoningContent,
    reasoning,
    listHash(reasoningDetails),
    reasoningDetailsPresent,
    logprobs,
    audio,
  );

  @override
  String toString() =>
      'AccumulatedChoice(index: $index, content: ${_textSummary(content)}, '
      'refusal: ${_textSummary(refusal)}, role: $role, finishReason: $finishReason, '
      'toolCalls: ${_listSummary(toolCalls)}, reasoningContent: ${_textSummary(reasoningContent)}, '
      'reasoning: ${_textSummary(reasoning)}, reasoningDetails: ${_listSummary(reasoningDetails)}, '
      'reasoningDetailsPresent: $reasoningDetailsPresent, logprobs: $logprobs, audio: $audio)';
}

/// Helper class for accumulating streaming chunks into a complete response.
///
/// Use this to merge all streaming deltas into a final [ChatCompletion]-like
/// object. Supports multi-choice streams (`n > 1`) with independent
/// per-choice accumulation.
///
/// ## Example
///
/// ```dart
/// final accumulator = ChatStreamAccumulator();
///
/// await for (final event in stream) {
///   accumulator.add(event);
///   stdout.write(event.textDelta ?? '');
/// }
///
/// final fullContent = accumulator.content;
/// final toolCalls = accumulator.toolCalls;
///
/// // For multi-choice streams, access per-choice state:
/// for (final choice in accumulator.choices) {
///   print('Choice ${choice.index}: ${choice.content}');
/// }
/// ```
class ChatStreamAccumulator {
  /// Creates a [ChatStreamAccumulator].
  ChatStreamAccumulator();

  String? _id;
  String? _model;
  int? _created;
  String? _systemFingerprint;
  String? _serviceTier;
  String? _provider;
  Usage? _usage;
  ChatCompletionModeration? _moderation;
  final List<_AccumulatedChoice> _choices = [];

  _AccumulatedChoice _getOrCreateChoice(int index) {
    while (_choices.length <= index) {
      _choices.add(_AccumulatedChoice());
    }
    return _choices[index];
  }

  /// Adds a streaming event to the accumulator.
  void add(ChatStreamEvent event) {
    _id ??= event.id;
    _model ??= event.model;
    _created ??= event.created;
    _systemFingerprint ??= event.systemFingerprint;
    _serviceTier ??= event.serviceTier;
    _provider ??= event.provider;
    if (event.usage != null) _usage = event.usage;
    if (event.moderation != null) _moderation = event.moderation;

    // Handle nullable choices for compatibility with providers like Groq
    final choices = event.choices;
    if (choices == null) return;

    for (final choice in choices) {
      final choiceIndex = choice.index ?? 0;
      final accumulated = _getOrCreateChoice(choiceIndex);
      final delta = choice.delta;

      accumulated.role ??= delta.role;
      accumulated.finishReason ??= choice.finishReason;

      if (choice.logprobs != null) {
        if (choice.logprobs!.content != null) {
          accumulated.logprobsContent.addAll(choice.logprobs!.content!);
        }
        if (choice.logprobs!.refusal != null) {
          accumulated.logprobsRefusal.addAll(choice.logprobs!.refusal!);
        }
      }

      if (choice._deltaPresence != _DeltaPresence.present) continue;
      accumulated.audioDone = delta._isPureAudioExpiry;
      if (delta.audio case final audio?) {
        accumulated.audioSeen = true;
        if (audio.id case final id?) accumulated.audioId = id;
        if (audio.data case final data?) {
          (accumulated.audioData ??= StringBuffer()).write(data);
        }
        if (audio.transcript case final transcript?) {
          (accumulated.audioTranscript ??= StringBuffer()).write(transcript);
        }
        if (audio.expiresAt case final expiry?) {
          accumulated.audioExpiresAt = expiry;
        }
      }

      if (delta.content != null) {
        accumulated.content.write(delta.content);
      }

      if (delta.refusal != null) {
        accumulated.refusal.write(delta.refusal);
      }

      // Accumulate reasoning content for OpenRouter/DeepSeek compatibility
      if (delta.reasoningContent != null) {
        accumulated.reasoningContent.write(delta.reasoningContent);
      }

      if (delta.reasoning != null) {
        accumulated.reasoning.write(delta.reasoning);
      }

      if (delta.reasoningDetails != null) {
        accumulated.reasoningDetailsPresent = true;
        accumulated.reasoningDetails.addAll(delta.reasoningDetails!);
      }

      if (delta.toolCalls != null) {
        for (final tc in delta.toolCalls!) {
          _accumulateToolCall(accumulated, tc);
        }
      }
    }
  }

  void _accumulateToolCall(_AccumulatedChoice choice, ToolCallDelta delta) {
    // Find or create the tool call at this index
    while (choice.toolCalls.length <= delta.index) {
      choice.toolCalls.add(_AccumulatedToolCall());
    }

    final accumulated = choice.toolCalls[delta.index]
      ..id ??= delta.id
      ..type ??= delta.type;

    if (delta.function case final fn?) {
      accumulated.functionName ??= fn.name;
      if (fn.arguments case final args?) {
        accumulated.arguments.write(args);
      }
    }
  }

  List<ToolCall> _buildToolCalls(_AccumulatedChoice choice) {
    return choice.toolCalls
        .where((tc) => tc.id != null && tc.functionName != null)
        .map(
          (tc) => ToolCall(
            id: tc.id!,
            type: tc.type ?? 'function',
            function: FunctionCall(
              name: tc.functionName!,
              arguments: tc.arguments.toString(),
            ),
          ),
        )
        .toList();
  }

  Logprobs? _buildLogprobs(_AccumulatedChoice choice) {
    if (choice.logprobsContent.isEmpty && choice.logprobsRefusal.isEmpty) {
      return null;
    }
    return Logprobs(
      content: choice.logprobsContent.isNotEmpty
          ? List.unmodifiable(choice.logprobsContent)
          : null,
      refusal: choice.logprobsRefusal.isNotEmpty
          ? List.unmodifiable(choice.logprobsRefusal)
          : null,
    );
  }

  ChatAudioDelta? _buildAudio(_AccumulatedChoice choice) => choice.audioSeen
      ? ChatAudioDelta(
          id: choice.audioId,
          data: choice.audioData?.toString(),
          transcript: choice.audioTranscript?.toString(),
          expiresAt: choice.audioExpiresAt,
        )
      : null;

  /// The completion ID.
  String? get id => _id;

  /// The model used.
  String? get model => _model;

  /// The service tier used (if applicable).
  String? get serviceTier => _serviceTier;

  /// **OpenRouter only.** The provider that served the request.
  String? get provider => _provider;

  /// The accumulated text content.
  ///
  /// For multi-choice streams, returns choice 0's content.
  String get content => _choices.isEmpty ? '' : _choices[0].content.toString();

  /// An immutable snapshot of choice zero's audio fields received so far.
  ///
  /// Null means no audio object was received. Partial snapshots can be inspected
  /// safely before all fields required by a complete audio output arrive.
  ChatAudioDelta? get audio =>
      _choices.isEmpty ? null : _buildAudio(_choices[0]);

  /// The accumulated refusal content.
  ///
  /// For multi-choice streams, returns choice 0's refusal.
  String get refusal => _choices.isEmpty ? '' : _choices[0].refusal.toString();

  /// **DeepSeek R1 / vLLM only.** The accumulated reasoning content.
  ///
  /// Not part of the official OpenAI API.
  /// For multi-choice streams, returns choice 0's reasoning content.
  String get reasoningContent =>
      _choices.isEmpty ? '' : _choices[0].reasoningContent.toString();

  /// **OpenRouter only.** The accumulated reasoning summary.
  ///
  /// Not part of the official OpenAI API.
  /// For multi-choice streams, returns choice 0's reasoning.
  String get reasoning =>
      _choices.isEmpty ? '' : _choices[0].reasoning.toString();

  /// Whether there is any reasoning content.
  ///
  /// For multi-choice streams, checks choice 0.
  bool get hasReasoningContent =>
      _choices.isNotEmpty &&
      (_choices[0].reasoningContent.isNotEmpty ||
          _choices[0].reasoning.isNotEmpty ||
          _choices[0].reasoningDetailsPresent);

  /// The message role.
  ///
  /// For multi-choice streams, returns choice 0's role.
  String? get role => _choices.isEmpty ? null : _choices[0].role;

  /// The finish reason.
  ///
  /// For multi-choice streams, returns choice 0's finish reason.
  FinishReason? get finishReason =>
      _choices.isEmpty ? null : _choices[0].finishReason;

  /// Token usage statistics.
  Usage? get usage => _usage;

  /// Moderation results for the request input and generated output.
  ///
  /// Populated from the dedicated moderation chunk when moderated completions
  /// were requested.
  ChatCompletionModeration? get moderation => _moderation;

  /// The accumulated tool calls.
  ///
  /// For multi-choice streams, returns choice 0's tool calls.
  List<ToolCall> get toolCalls =>
      _choices.isEmpty ? const [] : _buildToolCalls(_choices[0]);

  /// Whether there are any tool calls.
  ///
  /// For multi-choice streams, checks choice 0.
  bool get hasToolCalls =>
      _choices.isNotEmpty && _choices[0].toolCalls.any((tc) => tc.id != null);

  /// Returns a read-only view of all accumulated choices.
  ///
  /// Each element corresponds to one of the `n` choices in the request.
  /// For standard requests (`n=1`), this list has a single element.
  ///
  /// Note: Each call creates fresh snapshot objects. For hot-path access
  /// during streaming, prefer the flat getters (`content`, `toolCalls`, etc.)
  /// which delegate to choice 0 without allocation.
  List<AccumulatedChoice> get choices => List.unmodifiable([
    for (var i = 0; i < _choices.length; i++)
      AccumulatedChoice._(
        index: i,
        content: _choices[i].content.toString(),
        refusal: _choices[i].refusal.toString(),
        role: _choices[i].role,
        finishReason: _choices[i].finishReason,
        toolCalls: List.unmodifiable(_buildToolCalls(_choices[i])),
        reasoningContent: _choices[i].reasoningContent.toString(),
        reasoning: _choices[i].reasoning.toString(),
        reasoningDetails: List.unmodifiable(_choices[i].reasoningDetails),
        reasoningDetailsPresent: _choices[i].reasoningDetailsPresent,
        logprobs: _buildLogprobs(_choices[i]),
        audio: _buildAudio(_choices[i]),
      ),
  ]);

  /// Builds a [ChatCompletion] from the accumulated stream data.
  ///
  /// This assembles the accumulated content, tool calls, reasoning, and
  /// metadata into a complete [ChatCompletion] object — the same type
  /// returned by the non-streaming chat completions endpoint.
  ///
  /// For multi-choice streams, produces one [ChatChoice] per accumulated
  /// choice with independent content, tool calls, and finish reasons.
  ///
  /// Throws [StateError] if any choice has received audio without all four
  /// required fields. Inspect [audio] or [choices] for partial snapshots.
  /// Final conversion can infer `stop` from a pure expiry-only last delta with
  /// complete audio; raw events and snapshot finish reasons stay unchanged.
  ChatCompletion toChatCompletion() {
    final chatChoices = _choices.isEmpty
        ? [const ChatChoice(index: 0, message: AssistantMessage())]
        : [
            for (var i = 0; i < _choices.length; i++)
              _buildChatChoice(i, _choices[i]),
          ];

    return ChatCompletion(
      id: _id,
      object: 'chat.completion',
      created: _created,
      model: _model ?? '',
      choices: chatChoices,
      usage: _usage,
      systemFingerprint: _systemFingerprint,
      serviceTier: _serviceTier,
      moderation: _moderation,
      provider: _provider,
    );
  }

  ChatChoice _buildChatChoice(int index, _AccumulatedChoice choice) {
    final contentStr = choice.content.toString();
    final refusalStr = choice.refusal.toString();
    final reasoningContentStr = choice.reasoningContent.toString();
    final reasoningStr = choice.reasoning.toString();
    final tcs = _buildToolCalls(choice);
    final lp = _buildLogprobs(choice);
    final rds = choice.reasoningDetails;
    final audio = _buildAudio(choice);
    if (audio != null && !audio.isComplete) {
      throw StateError(
        'Incomplete audio for choice $index; inspect partial audio snapshots before converting.',
      );
    }

    return ChatChoice(
      index: index,
      finishReason:
          choice.finishReason ??
          (choice.audioDone && audio?.isComplete == true
              ? FinishReason.stop
              : null),
      logprobs: lp,
      message: AssistantMessage(
        audio: audio?.toCompleteAudio(),
        content: contentStr.isNotEmpty ? contentStr : null,
        refusal: refusalStr.isNotEmpty ? refusalStr : null,
        toolCalls: tcs.isNotEmpty ? tcs : null,
        reasoningContent: reasoningContentStr.isNotEmpty
            ? reasoningContentStr
            : null,
        reasoning: reasoningStr.isNotEmpty ? reasoningStr : null,
        reasoningDetails: choice.reasoningDetailsPresent
            ? List.unmodifiable(rds)
            : null,
      ),
    );
  }

  /// Resets the accumulator for reuse.
  void reset() {
    _id = null;
    _model = null;
    _created = null;
    _systemFingerprint = null;
    _serviceTier = null;
    _provider = null;
    _usage = null;
    _moderation = null;
    _choices.clear();
  }
}

/// Internal helper for accumulating per-choice state.
class _AccumulatedChoice {
  String? role;
  FinishReason? finishReason;
  final StringBuffer content = StringBuffer();
  final StringBuffer refusal = StringBuffer();
  final StringBuffer reasoningContent = StringBuffer();
  final StringBuffer reasoning = StringBuffer();
  final List<ReasoningDetail> reasoningDetails = [];
  bool reasoningDetailsPresent = false;
  final List<_AccumulatedToolCall> toolCalls = [];
  final List<TokenLogprob> logprobsContent = [];
  final List<TokenLogprob> logprobsRefusal = [];
  bool audioSeen = false;
  String? audioId;
  StringBuffer? audioData;
  StringBuffer? audioTranscript;
  int? audioExpiresAt;
  bool audioDone = false;
}

/// Internal helper for accumulating tool call data.
class _AccumulatedToolCall {
  String? id;
  String? type;
  String? functionName;
  final StringBuffer arguments = StringBuffer();
}
