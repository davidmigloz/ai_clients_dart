import 'package:meta/meta.dart';

import '../common/auto_or_value.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'realtime_audio_config.dart';
import 'realtime_enums.dart';
import 'realtime_reasoning.dart';
import 'realtime_tracing_config.dart';
import 'realtime_truncation.dart';

// =============================================================================
// RealtimeTool
// =============================================================================

/// A tool for realtime sessions.
@immutable
class RealtimeTool {
  /// Creates a [RealtimeTool].
  const RealtimeTool({
    required this.type,
    required this.name,
    this.description,
    this.parameters,
  });

  /// Creates a [RealtimeTool] from JSON.
  factory RealtimeTool.fromJson(Map<String, dynamic> json) {
    return RealtimeTool(
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
    );
  }

  /// The tool type (always "function").
  final String type;

  /// The function name.
  final String name;

  /// The function description.
  final String? description;

  /// The function parameters as JSON schema.
  final Map<String, dynamic>? parameters;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    if (description != null) 'description': description,
    if (parameters != null) 'parameters': parameters,
  };

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass `null` for [description] or [parameters] to clear the existing value.
  RealtimeTool copyWith({
    String? type,
    String? name,
    Object? description = unsetCopyWithValue,
    Object? parameters = unsetCopyWithValue,
  }) => RealtimeTool(
    type: type ?? this.type,
    name: name ?? this.name,
    description: identical(description, unsetCopyWithValue)
        ? this.description
        : description as String?,
    parameters: identical(parameters, unsetCopyWithValue)
        ? this.parameters
        : parameters as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTool &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          description == other.description &&
          mapsDeepEqual(parameters, other.parameters);

  @override
  int get hashCode =>
      Object.hash(type, name, description, mapDeepHashCode(parameters));

  @override
  String toString() =>
      'RealtimeTool(type: $type, name: $name, description: $description, '
      'parameters: $parameters)';
}

// =============================================================================
// RealtimeSession
// =============================================================================

/// Configuration for a Realtime session.
///
/// The Realtime API enables real-time audio conversations with the model
/// using WebSockets. Audio configuration is nested under [audio]
/// (`audio.input.*` / `audio.output.*`), output modalities are configured
/// via [outputModalities], and the maximum output token cap is set on
/// [maxOutputTokens].
///
/// Note: the `prompt` field from the spec is intentionally not modelled in
/// this PR — the spec helper schema `Prompt` has no Dart class yet. Tracked
/// as a follow-up for prompt-template support.
// TODO(prompt-support): expose `prompt: Prompt?` once the `Prompt` schema
// has a Dart model.
@immutable
class RealtimeSession {
  /// Creates a [RealtimeSession].
  const RealtimeSession({
    this.id,
    this.object,
    this.type,
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

  /// Creates a [RealtimeSession] from JSON.
  ///
  /// All fields are optional per the spec — server payloads include
  /// the relevant subset for the session shape (realtime vs.
  /// transcription) and partial frames omit metadata that hasn't been
  /// resolved yet.
  factory RealtimeSession.fromJson(Map<String, dynamic> json) {
    return RealtimeSession(
      id: json['id'] as String?,
      object: json['object'] as String?,
      type: json['type'] as String?,
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

  /// The session identifier (`sess_…`). Optional on partial frames.
  final String? id;

  /// The object type (e.g. `'realtime.session'`). Optional on partial frames.
  final String? object;

  /// The session type (`'realtime'` or `'transcription'`). Optional on
  /// partial frames.
  final String? type;

  /// The model identifier. Always present for realtime sessions; omitted
  /// for transcription sessions (which don't carry a top-level model).
  final String? model;

  /// Expiration timestamp (Unix epoch seconds). May be `null` on partial
  /// frames before the session is fully provisioned.
  final int? expiresAt;

  /// Nested audio configuration.
  final RealtimeAudioConfig? audio;

  /// Output modalities (e.g. `['audio']` or `['text']`). Defaults to
  /// `['audio']`. The server only accepts a single modality at a time.
  final List<String>? outputModalities;

  /// System instructions.
  final String? instructions;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Maximum output tokens (`'inf'` or a specific integer).
  final InfOrInt? maxOutputTokens;

  /// Whether the model may call multiple tools in parallel. Only supported by
  /// reasoning Realtime models such as `gpt-realtime-2`.
  final bool? parallelToolCalls;

  /// Reasoning configuration. Only supported by reasoning models.
  final RealtimeReasoning? reasoning;

  /// Tracing configuration.
  final RealtimeTracingConfig? tracing;

  /// Truncation configuration.
  final RealtimeTruncation? truncation;

  /// Additional fields to include in server outputs (e.g.
  /// `'item.input_audio_transcription.logprobs'`).
  final List<String>? include;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (object != null) 'object': object,
    if (type != null) 'type': type,
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

  /// Returns a copy of this [RealtimeSession] with the given fields replaced.
  ///
  /// Pass `null` for any nullable field to clear the existing value.
  RealtimeSession copyWith({
    Object? id = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
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
  }) => RealtimeSession(
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    type: identical(type, unsetCopyWithValue) ? this.type : type as String?,
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
      other is RealtimeSession &&
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
      'RealtimeSession(id: $id, model: $model, expiresAt: $expiresAt, '
      'audio: $audio, outputModalities: $outputModalities, '
      'instructions: $instructions, tools: $tools, toolChoice: $toolChoice, '
      'maxOutputTokens: $maxOutputTokens, '
      'parallelToolCalls: $parallelToolCalls, reasoning: $reasoning, '
      'tracing: $tracing, truncation: $truncation, include: $include)';
}
