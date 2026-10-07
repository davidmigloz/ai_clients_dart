import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/finish_reason.dart';
import '../common/logprobs.dart';
import '../common/usage.dart';
import 'chat_audio.dart';
import 'chat_completion_moderation.dart';
import 'chat_message.dart';

/// A chat completion response from the OpenAI API.
///
/// This represents the response from the chat completions endpoint,
/// containing one or more completion choices.
///
/// ## Example
///
/// ```dart
/// final response = await client.chat.completions.create(request);
///
/// // Get the text content
/// print(response.text);
///
/// // Access choices directly
/// for (final choice in response.choices) {
///   print('Choice ${choice.index}: ${choice.message.content}');
/// }
/// ```
@immutable
class ChatCompletion {
  /// Creates a [ChatCompletion].
  const ChatCompletion({
    this.id,
    required this.object,
    this.created,
    required this.model,
    required this.choices,
    this.usage,
    this.systemFingerprint,
    this.serviceTier,
    this.moderation,
    this.provider,
  });

  /// Creates a [ChatCompletion] from JSON.
  factory ChatCompletion.fromJson(Map<String, dynamic> json) {
    return ChatCompletion(
      id: json['id'] as String?,
      // FastChat omits this; GPT4All historically returned "text_completion"
      object: json['object'] as String? ?? 'chat.completion',
      created: json['created'] as int?,
      // FastChat may omit this field
      model: json['model'] as String? ?? '',
      // Custom Bedrock proxies may return error responses without choices
      choices:
          (json['choices'] as List<dynamic>?)
              ?.map((e) => ChatChoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
    );
  }

  /// The unique identifier for this completion.
  ///
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter
  /// doesn't return `id` with some models).
  final String? id;

  /// The object type (usually "chat.completion").
  ///
  /// May be missing or different with some OpenAI-compatible providers
  /// (e.g., FastChat omits this, GPT4All historically returned
  /// "text_completion").
  final String object;

  /// The Unix timestamp when this completion was created.
  ///
  /// May be null with some OpenAI-compatible providers.
  final int? created;

  /// The model used for this completion.
  ///
  /// May be empty with some OpenAI-compatible providers (e.g., FastChat
  /// may omit this field).
  final String model;

  /// The list of completion choices.
  ///
  /// Defaults to empty if missing. Some proxy servers (e.g., custom Bedrock
  /// proxies) may return error responses without a choices array.
  final List<ChatChoice> choices;

  /// Token usage statistics.
  final Usage? usage;

  /// The system fingerprint for the model configuration.
  ///
  /// Can be used to verify that the same model and configuration
  /// were used across requests.
  final String? systemFingerprint;

  /// The service tier used (if applicable).
  final String? serviceTier;

  /// Moderation results for the request input and generated output.
  ///
  /// Present only when moderated completions were requested via
  /// [ChatCompletionCreateRequest.moderation].
  final ChatCompletionModeration? moderation;

  /// **OpenRouter only.** The provider that served the request.
  ///
  /// Not part of the official OpenAI API.
  final String? provider;

  /// Gets the text content from the first choice.
  ///
  /// This is a convenience getter for accessing the most common use case.
  /// Returns null if there are no choices or no content.
  String? get text => choices.firstOrNull?.message.content;

  /// Complete generated audio from the first choice, when present.
  ChatCompletionAudio? get audio =>
      switch (choices.firstOrNull?.message.audio) {
        final ChatCompletionAudio audio => audio,
        _ => null,
      };

  /// Gets the first choice.
  ChatChoice? get firstChoice => choices.firstOrNull;

  /// Gets the creation time as a [DateTime], or null if [created] is null.
  DateTime? get createdAt => created != null
      ? DateTime.fromMillisecondsSinceEpoch(created! * 1000)
      : null;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'object': object,
    if (created != null) 'created': created,
    'model': model,
    'choices': choices.map((c) => c.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (systemFingerprint != null) 'system_fingerprint': systemFingerprint,
    if (serviceTier != null) 'service_tier': serviceTier,
    if (moderation != null) 'moderation': moderation!.toJson(),
    if (provider != null) 'provider': provider,
  };

  /// Creates a copy; nullable metadata can be explicitly cleared.
  ChatCompletion copyWith({
    Object? id = unsetCopyWithValue,
    String? object,
    Object? created = unsetCopyWithValue,
    String? model,
    List<ChatChoice>? choices,
    Object? usage = unsetCopyWithValue,
    Object? systemFingerprint = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? moderation = unsetCopyWithValue,
    Object? provider = unsetCopyWithValue,
  }) => ChatCompletion(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    object: object ?? this.object,
    created: created == unsetCopyWithValue ? this.created : created as int?,
    model: model ?? this.model,
    choices: choices ?? this.choices,
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
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatCompletion &&
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
          provider == other.provider;

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
  );

  @override
  String toString() =>
      'ChatCompletion(id: ${id == null ? 'null' : '[REDACTED]'}, '
      'object: $object, created: $created, model: $model, '
      'choices: ${choices.length} items, usage: $usage, '
      'systemFingerprint: ${systemFingerprint == null ? 'null' : '[REDACTED]'}, '
      'serviceTier: $serviceTier, '
      'moderation: ${moderation == null ? 'null' : 'present'}, provider: $provider)';
}

/// A single completion choice.
@immutable
class ChatChoice {
  /// Creates a [ChatChoice].
  const ChatChoice({
    this.index,
    required this.message,
    this.finishReason,
    this.logprobs,
  });

  /// Creates a [ChatChoice] from JSON.
  factory ChatChoice.fromJson(Map<String, dynamic> json) {
    return ChatChoice(
      index: json['index'] as int?,
      message: AssistantMessage.fromResponseJson(
        json['message'] as Map<String, dynamic>,
      ),
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
  /// May be null with some OpenAI-compatible providers (e.g., OpenRouter
  /// doesn't return `index` with some responses).
  final int? index;

  /// The message generated by the model.
  final AssistantMessage message;

  /// The reason the model stopped generating.
  final FinishReason? finishReason;

  /// Log probability information.
  final Logprobs? logprobs;

  /// Whether the model wants to call tools.
  bool get hasToolCalls => message.hasToolCalls;

  /// Whether the model refused to respond.
  bool get isRefusal => message.isRefusal;

  /// Whether the response was truncated due to length.
  bool get isTruncated => finishReason?.isTruncated ?? false;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (index != null) 'index': index,
    'message': message.toResponseJson(),
    if (finishReason != null) 'finish_reason': finishReason!.toJson(),
    if (logprobs != null) 'logprobs': logprobs!.toJson(),
  };

  /// Creates a copy; optional choice metadata can be explicitly cleared.
  ChatChoice copyWith({
    Object? index = unsetCopyWithValue,
    AssistantMessage? message,
    Object? finishReason = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
  }) => ChatChoice(
    index: index == unsetCopyWithValue ? this.index : index as int?,
    message: message ?? this.message,
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
      other is ChatChoice &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          message == other.message &&
          finishReason == other.finishReason &&
          logprobs == other.logprobs;

  @override
  int get hashCode => Object.hash(index, message, finishReason, logprobs);

  @override
  String toString() =>
      'ChatChoice(index: $index, message: present, finishReason: $finishReason, '
      'logprobs: ${logprobs == null ? 'null' : 'present'})';
}
