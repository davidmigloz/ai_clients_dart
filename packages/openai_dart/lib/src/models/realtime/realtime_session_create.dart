import 'package:meta/meta.dart';

import '../common/auto_or_value.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'realtime_audio_config.dart';
import 'realtime_enums.dart';
import 'realtime_reasoning.dart';
import 'realtime_session.dart';
import 'realtime_tracing_config.dart';
import 'realtime_truncation.dart';

// =============================================================================
// RealtimeSessionCreateRequest
// =============================================================================

/// Realtime session configuration.
///
/// Used as the embedded `session` in [RealtimeClientSecretCreateRequest]
/// when calling `client.realtimeSessions.createClientSecret(...)` and as the
/// payload of the `session.update` WebSocket event.
///
/// ## Example
///
/// ```dart
/// final response = await client.realtimeSessions.createClientSecret(
///   RealtimeClientSecretCreateRequest(
///     session: RealtimeSessionCreateRequest(
///       model: 'gpt-realtime-2',
///       audio: RealtimeAudioConfig(
///         output: RealtimeAudioConfigOutput(voice: 'alloy'),
///       ),
///       instructions: 'You are a helpful assistant.',
///       reasoning: RealtimeReasoning(effort: RealtimeReasoningEffort.minimal),
///     ),
///   ),
/// );
/// ```
@immutable
class RealtimeSessionCreateRequest {
  /// Creates a [RealtimeSessionCreateRequest].
  ///
  /// The [type] field is the session-type discriminator (`'realtime'` for
  /// realtime sessions). Set this when the API needs to distinguish between
  /// realtime and transcription sessions, such as when creating client
  /// secrets.
  const RealtimeSessionCreateRequest({
    required this.model,
    this.type,
    this.audio,
    this.outputModalities,
    this.instructions,
    this.tools,
    this.toolChoice,
    this.maxOutputTokens,
    this.parallelToolCalls,
    this.reasoning,
    this.tracing,
    this.truncation,
    this.include,
  });

  /// Creates a [RealtimeSessionCreateRequest] from JSON.
  factory RealtimeSessionCreateRequest.fromJson(Map<String, dynamic> json) {
    if (json['model'] == null) {
      throw const FormatException(
        'RealtimeSessionCreateRequest.fromJson missing required "model" field',
      );
    }
    return RealtimeSessionCreateRequest(
      model: json['model'] as String,
      type: json['type'] as String?,
      audio: json['audio'] != null
          ? RealtimeAudioConfig.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
      outputModalities: (json['output_modalities'] as List<dynamic>?)
          ?.cast<String>(),
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? RealtimeToolChoice.fromJson(json['tool_choice'] as Object)
          : null,
      maxOutputTokens: json['max_output_tokens'] != null
          ? InfOrInt.fromJson(json['max_output_tokens'] as Object)
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      reasoning: json['reasoning'] != null
          ? RealtimeReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            )
          : null,
      tracing: json['tracing'] != null
          ? RealtimeTracingConfig.fromJson(json['tracing'] as Object)
          : null,
      truncation: json['truncation'] != null
          ? RealtimeTruncation.fromJson(json['truncation'] as Object)
          : null,
      include: (json['include'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The session type discriminator.
  ///
  /// Used by the API to distinguish between realtime sessions and
  /// transcription sessions when creating client secrets. Set to
  /// `'realtime'` for realtime sessions.
  final String? type;

  /// The model identifier (required).
  final String model;

  /// Nested audio configuration.
  final RealtimeAudioConfig? audio;

  /// Output modalities.
  final List<String>? outputModalities;

  /// System instructions.
  final String? instructions;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Maximum output tokens (`'inf'` or a specific integer).
  final InfOrInt? maxOutputTokens;

  /// Whether the model may call multiple tools in parallel.
  final bool? parallelToolCalls;

  /// Reasoning configuration.
  final RealtimeReasoning? reasoning;

  /// Tracing configuration.
  final RealtimeTracingConfig? tracing;

  /// Truncation configuration.
  final RealtimeTruncation? truncation;

  /// Additional fields to include in server outputs.
  final List<String>? include;

  /// Converts to JSON.
  ///
  /// `type` is only emitted when explicitly set. The bare `/realtime/sessions`
  /// endpoint rejects unknown parameters; the `/realtime/client_secrets`
  /// wrapper injects `'type': 'realtime'` itself when it serializes the
  /// embedded session.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    'model': model,
    if (audio != null) 'audio': audio!.toJson(),
    if (outputModalities != null) 'output_modalities': outputModalities,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (tracing != null) 'tracing': tracing!.toJson(),
    if (truncation != null) 'truncation': truncation!.toJson(),
    if (include != null) 'include': include,
  };

  /// Returns a copy of this [RealtimeSessionCreateRequest] with the given
  /// fields replaced. Pass `null` for any nullable field to clear the
  /// existing value.
  RealtimeSessionCreateRequest copyWith({
    String? model,
    Object? type = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? outputModalities = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? tracing = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
  }) => RealtimeSessionCreateRequest(
    model: model ?? this.model,
    type: identical(type, unsetCopyWithValue) ? this.type : type as String?,
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeAudioConfig?,
    outputModalities: identical(outputModalities, unsetCopyWithValue)
        ? this.outputModalities
        : outputModalities as List<String>?,
    instructions: identical(instructions, unsetCopyWithValue)
        ? this.instructions
        : instructions as String?,
    tools: identical(tools, unsetCopyWithValue)
        ? this.tools
        : tools as List<RealtimeTool>?,
    toolChoice: identical(toolChoice, unsetCopyWithValue)
        ? this.toolChoice
        : toolChoice as RealtimeToolChoice?,
    maxOutputTokens: identical(maxOutputTokens, unsetCopyWithValue)
        ? this.maxOutputTokens
        : maxOutputTokens as InfOrInt?,
    parallelToolCalls: identical(parallelToolCalls, unsetCopyWithValue)
        ? this.parallelToolCalls
        : parallelToolCalls as bool?,
    reasoning: identical(reasoning, unsetCopyWithValue)
        ? this.reasoning
        : reasoning as RealtimeReasoning?,
    tracing: identical(tracing, unsetCopyWithValue)
        ? this.tracing
        : tracing as RealtimeTracingConfig?,
    truncation: identical(truncation, unsetCopyWithValue)
        ? this.truncation
        : truncation as RealtimeTruncation?,
    include: identical(include, unsetCopyWithValue)
        ? this.include
        : include as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeSessionCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          type == other.type &&
          audio == other.audio &&
          listsEqual(outputModalities, other.outputModalities) &&
          instructions == other.instructions &&
          listsEqual(tools, other.tools) &&
          toolChoice == other.toolChoice &&
          maxOutputTokens == other.maxOutputTokens &&
          parallelToolCalls == other.parallelToolCalls &&
          reasoning == other.reasoning &&
          tracing == other.tracing &&
          truncation == other.truncation &&
          listsEqual(include, other.include);

  @override
  int get hashCode => Object.hash(
    model,
    type,
    audio,
    listHash(outputModalities),
    instructions,
    listHash(tools),
    toolChoice,
    maxOutputTokens,
    parallelToolCalls,
    reasoning,
    tracing,
    truncation,
    listHash(include),
  );

  @override
  String toString() =>
      'RealtimeSessionCreateRequest(model: $model, type: $type, audio: $audio, '
      'outputModalities: $outputModalities, instructions: $instructions, '
      'tools: $tools, toolChoice: $toolChoice, '
      'maxOutputTokens: $maxOutputTokens, parallelToolCalls: $parallelToolCalls, '
      'reasoning: $reasoning, tracing: $tracing, truncation: $truncation, '
      'include: $include)';
}

// =============================================================================
// RealtimeSessionCreateResponse
// =============================================================================

/// Response from creating a Realtime session via HTTP.
///
/// Contains the session configuration. The client secret is **not** nested
/// on this response — the `/realtime/client_secrets` endpoint returns a
/// [RealtimeClientSecretCreateResponse] wrapping this
/// [RealtimeSessionCreateResponse] alongside the secret.
@immutable
class RealtimeSessionCreateResponse {
  /// Creates a [RealtimeSessionCreateResponse].
  const RealtimeSessionCreateResponse({
    required this.id,
    required this.object,
    required this.type,
    this.model,
    this.expiresAt,
    this.audio,
    this.outputModalities,
    this.instructions,
    this.tools,
    this.toolChoice,
    this.maxOutputTokens,
    this.parallelToolCalls,
    this.reasoning,
    this.tracing,
    this.truncation,
    this.include,
  });

  /// Creates a [RealtimeSessionCreateResponse] from JSON.
  ///
  /// Throws [FormatException] when any spec-required field (`id`,
  /// `object`, `type`) is missing. `model` and `expires_at` are
  /// optional per the spec — transcription session responses don't
  /// carry a top-level `model`, and partial frames may omit
  /// `expires_at`.
  factory RealtimeSessionCreateResponse.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['object'] == null || json['type'] == null) {
      throw const FormatException(
        'RealtimeSessionCreateResponse.fromJson missing one or more required '
        'fields (id, object, type)',
      );
    }
    return RealtimeSessionCreateResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      type: json['type'] as String,
      model: json['model'] as String?,
      expiresAt: json['expires_at'] as int?,
      audio: json['audio'] != null
          ? RealtimeAudioConfig.fromJson(json['audio'] as Map<String, dynamic>)
          : null,
      outputModalities: (json['output_modalities'] as List<dynamic>?)
          ?.cast<String>(),
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? RealtimeToolChoice.fromJson(json['tool_choice'] as Object)
          : null,
      maxOutputTokens: json['max_output_tokens'] != null
          ? InfOrInt.fromJson(json['max_output_tokens'] as Object)
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      reasoning: json['reasoning'] != null
          ? RealtimeReasoning.fromJson(
              json['reasoning'] as Map<String, dynamic>,
            )
          : null,
      tracing: json['tracing'] != null
          ? RealtimeTracingConfig.fromJson(json['tracing'] as Object)
          : null,
      truncation: json['truncation'] != null
          ? RealtimeTruncation.fromJson(json['truncation'] as Object)
          : null,
      include: (json['include'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The session identifier.
  final String id;

  /// The object type (e.g. `'realtime.session'` /
  /// `'realtime.transcription_session'`).
  final String object;

  /// The session type (`'realtime'` or `'transcription'`).
  final String type;

  /// The model identifier. Always present for realtime sessions; omitted
  /// from transcription session responses (which carry the model on the
  /// nested `audio.input.transcription` instead).
  final String? model;

  /// Expiration timestamp (Unix epoch seconds). May be `null` on partial
  /// or transient frames.
  final int? expiresAt;

  /// Nested audio configuration.
  final RealtimeAudioConfig? audio;

  /// Output modalities.
  final List<String>? outputModalities;

  /// System instructions.
  final String? instructions;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Maximum output tokens.
  final InfOrInt? maxOutputTokens;

  /// Whether the model may call multiple tools in parallel.
  final bool? parallelToolCalls;

  /// Reasoning configuration.
  final RealtimeReasoning? reasoning;

  /// Tracing configuration.
  final RealtimeTracingConfig? tracing;

  /// Truncation configuration.
  final RealtimeTruncation? truncation;

  /// Additional fields to include in server outputs.
  final List<String>? include;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'type': type,
    if (model != null) 'model': model,
    if (expiresAt != null) 'expires_at': expiresAt,
    if (audio != null) 'audio': audio!.toJson(),
    if (outputModalities != null) 'output_modalities': outputModalities,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (reasoning != null) 'reasoning': reasoning!.toJson(),
    if (tracing != null) 'tracing': tracing!.toJson(),
    if (truncation != null) 'truncation': truncation!.toJson(),
    if (include != null) 'include': include,
  };

  /// Returns a copy of this [RealtimeSessionCreateResponse] with the given
  /// fields replaced. Pass `null` for any nullable field to clear the
  /// existing value.
  RealtimeSessionCreateResponse copyWith({
    String? id,
    String? object,
    String? type,
    Object? model = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    Object? audio = unsetCopyWithValue,
    Object? outputModalities = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? toolChoice = unsetCopyWithValue,
    Object? maxOutputTokens = unsetCopyWithValue,
    Object? parallelToolCalls = unsetCopyWithValue,
    Object? reasoning = unsetCopyWithValue,
    Object? tracing = unsetCopyWithValue,
    Object? truncation = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
  }) => RealtimeSessionCreateResponse(
    id: id ?? this.id,
    object: object ?? this.object,
    type: type ?? this.type,
    model: identical(model, unsetCopyWithValue) ? this.model : model as String?,
    expiresAt: identical(expiresAt, unsetCopyWithValue)
        ? this.expiresAt
        : expiresAt as int?,
    audio: identical(audio, unsetCopyWithValue)
        ? this.audio
        : audio as RealtimeAudioConfig?,
    outputModalities: identical(outputModalities, unsetCopyWithValue)
        ? this.outputModalities
        : outputModalities as List<String>?,
    instructions: identical(instructions, unsetCopyWithValue)
        ? this.instructions
        : instructions as String?,
    tools: identical(tools, unsetCopyWithValue)
        ? this.tools
        : tools as List<RealtimeTool>?,
    toolChoice: identical(toolChoice, unsetCopyWithValue)
        ? this.toolChoice
        : toolChoice as RealtimeToolChoice?,
    maxOutputTokens: identical(maxOutputTokens, unsetCopyWithValue)
        ? this.maxOutputTokens
        : maxOutputTokens as InfOrInt?,
    parallelToolCalls: identical(parallelToolCalls, unsetCopyWithValue)
        ? this.parallelToolCalls
        : parallelToolCalls as bool?,
    reasoning: identical(reasoning, unsetCopyWithValue)
        ? this.reasoning
        : reasoning as RealtimeReasoning?,
    tracing: identical(tracing, unsetCopyWithValue)
        ? this.tracing
        : tracing as RealtimeTracingConfig?,
    truncation: identical(truncation, unsetCopyWithValue)
        ? this.truncation
        : truncation as RealtimeTruncation?,
    include: identical(include, unsetCopyWithValue)
        ? this.include
        : include as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeSessionCreateResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          type == other.type &&
          model == other.model &&
          expiresAt == other.expiresAt &&
          audio == other.audio &&
          listsEqual(outputModalities, other.outputModalities) &&
          instructions == other.instructions &&
          listsEqual(tools, other.tools) &&
          toolChoice == other.toolChoice &&
          maxOutputTokens == other.maxOutputTokens &&
          parallelToolCalls == other.parallelToolCalls &&
          reasoning == other.reasoning &&
          tracing == other.tracing &&
          truncation == other.truncation &&
          listsEqual(include, other.include);

  @override
  int get hashCode => Object.hash(
    id,
    object,
    type,
    model,
    expiresAt,
    audio,
    listHash(outputModalities),
    instructions,
    listHash(tools),
    toolChoice,
    maxOutputTokens,
    parallelToolCalls,
    reasoning,
    tracing,
    truncation,
    listHash(include),
  );

  @override
  String toString() =>
      'RealtimeSessionCreateResponse(id: $id, model: $model, '
      'expiresAt: $expiresAt, audio: $audio)';
}
