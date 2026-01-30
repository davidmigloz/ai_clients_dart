import 'package:meta/meta.dart';

import '../common/auto_or_value.dart';
import 'realtime_enums.dart';

/// Configuration for a realtime session.
///
/// The Realtime API enables real-time audio conversations with the model
/// using WebSockets.
@immutable
class RealtimeSession {
  /// Creates a [RealtimeSession].
  const RealtimeSession({
    required this.id,
    required this.object,
    required this.model,
    this.modalities,
    this.instructions,
    this.voice,
    this.inputAudioFormat,
    this.outputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.tools,
    this.toolChoice,
    this.temperature,
    this.maxResponseOutputTokens,
  });

  /// Creates a [RealtimeSession] from JSON.
  factory RealtimeSession.fromJson(Map<String, dynamic> json) {
    return RealtimeSession(
      id: json['id'] as String,
      object: json['object'] as String,
      model: json['model'] as String,
      modalities: (json['modalities'] as List<dynamic>?)?.cast<String>(),
      instructions: json['instructions'] as String?,
      voice: json['voice'] != null
          ? RealtimeVoice.fromJson(json['voice'] as String)
          : null,
      inputAudioFormat: json['input_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['input_audio_format'] as String)
          : null,
      outputAudioFormat: json['output_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['output_audio_format'] as String)
          : null,
      inputAudioTranscription: json['input_audio_transcription'] != null
          ? InputAudioTranscription.fromJson(
              json['input_audio_transcription'] as Map<String, dynamic>,
            )
          : null,
      turnDetection: json['turn_detection'] != null
          ? TurnDetection.fromJson(
              json['turn_detection'] as Map<String, dynamic>,
            )
          : null,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? RealtimeToolChoice.fromJson(json['tool_choice'] as Object)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxResponseOutputTokens: json['max_response_output_tokens'] != null
          ? InfOrInt.fromJson(json['max_response_output_tokens'] as Object)
          : null,
    );
  }

  /// The session identifier.
  final String id;

  /// The object type (always "realtime.session").
  final String object;

  /// The model to use.
  final String model;

  /// The modalities enabled (e.g., ["text", "audio"]).
  final List<String>? modalities;

  /// System instructions for the model.
  final String? instructions;

  /// The voice to use for audio output.
  final RealtimeVoice? voice;

  /// Input audio format.
  final RealtimeAudioFormat? inputAudioFormat;

  /// Output audio format.
  final RealtimeAudioFormat? outputAudioFormat;

  /// Configuration for input audio transcription.
  final InputAudioTranscription? inputAudioTranscription;

  /// Turn detection configuration.
  final TurnDetection? turnDetection;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Sampling temperature.
  final double? temperature;

  /// Maximum output tokens ("inf" or a specific integer).
  final InfOrInt? maxResponseOutputTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'model': model,
    if (modalities != null) 'modalities': modalities,
    if (instructions != null) 'instructions': instructions,
    if (voice != null) 'voice': voice!.toJson(),
    if (inputAudioFormat != null)
      'input_audio_format': inputAudioFormat!.toJson(),
    if (outputAudioFormat != null)
      'output_audio_format': outputAudioFormat!.toJson(),
    if (inputAudioTranscription != null)
      'input_audio_transcription': inputAudioTranscription!.toJson(),
    if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (maxResponseOutputTokens != null)
      'max_response_output_tokens': maxResponseOutputTokens!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RealtimeSession(id: $id, model: $model)';
}

/// Configuration for updating a session.
@immutable
class SessionUpdateConfig {
  /// Creates a [SessionUpdateConfig].
  const SessionUpdateConfig({
    this.modalities,
    this.instructions,
    this.voice,
    this.inputAudioFormat,
    this.outputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.tools,
    this.toolChoice,
    this.temperature,
    this.maxResponseOutputTokens,
  });

  /// Creates a [SessionUpdateConfig] from JSON.
  factory SessionUpdateConfig.fromJson(Map<String, dynamic> json) {
    return SessionUpdateConfig(
      modalities: (json['modalities'] as List<dynamic>?)?.cast<String>(),
      instructions: json['instructions'] as String?,
      voice: json['voice'] != null
          ? RealtimeVoice.fromJson(json['voice'] as String)
          : null,
      inputAudioFormat: json['input_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['input_audio_format'] as String)
          : null,
      outputAudioFormat: json['output_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['output_audio_format'] as String)
          : null,
      inputAudioTranscription: json['input_audio_transcription'] != null
          ? InputAudioTranscription.fromJson(
              json['input_audio_transcription'] as Map<String, dynamic>,
            )
          : null,
      turnDetection: json['turn_detection'] != null
          ? TurnDetection.fromJson(
              json['turn_detection'] as Map<String, dynamic>,
            )
          : null,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => RealtimeTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolChoice: json['tool_choice'] != null
          ? RealtimeToolChoice.fromJson(json['tool_choice'] as Object)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxResponseOutputTokens: json['max_response_output_tokens'] != null
          ? InfOrInt.fromJson(json['max_response_output_tokens'] as Object)
          : null,
    );
  }

  /// The modalities to enable.
  final List<String>? modalities;

  /// System instructions.
  final String? instructions;

  /// The voice to use.
  final RealtimeVoice? voice;

  /// Input audio format.
  final RealtimeAudioFormat? inputAudioFormat;

  /// Output audio format.
  final RealtimeAudioFormat? outputAudioFormat;

  /// Input audio transcription config.
  final InputAudioTranscription? inputAudioTranscription;

  /// Turn detection config.
  final TurnDetection? turnDetection;

  /// Available tools.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Sampling temperature.
  final double? temperature;

  /// Maximum output tokens ("inf" or a specific integer).
  final InfOrInt? maxResponseOutputTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modalities != null) 'modalities': modalities,
    if (instructions != null) 'instructions': instructions,
    if (voice != null) 'voice': voice!.toJson(),
    if (inputAudioFormat != null)
      'input_audio_format': inputAudioFormat!.toJson(),
    if (outputAudioFormat != null)
      'output_audio_format': outputAudioFormat!.toJson(),
    if (inputAudioTranscription != null)
      'input_audio_transcription': inputAudioTranscription!.toJson(),
    if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (maxResponseOutputTokens != null)
      'max_response_output_tokens': maxResponseOutputTokens!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUpdateConfig && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(modalities, voice, temperature);

  @override
  String toString() => 'SessionUpdateConfig(...)';
}

/// Input audio transcription configuration.
@immutable
class InputAudioTranscription {
  /// Creates an [InputAudioTranscription].
  const InputAudioTranscription({this.model});

  /// Creates an [InputAudioTranscription] from JSON.
  factory InputAudioTranscription.fromJson(Map<String, dynamic> json) {
    return InputAudioTranscription(model: json['model'] as String?);
  }

  /// The transcription model (e.g., "whisper-1").
  final String? model;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (model != null) 'model': model};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAudioTranscription &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'InputAudioTranscription(model: $model)';
}

/// Turn detection configuration.
@immutable
class TurnDetection {
  /// Creates a [TurnDetection].
  const TurnDetection({
    this.type,
    this.threshold,
    this.prefixPaddingMs,
    this.silenceDurationMs,
    this.createResponse,
  });

  /// Creates a [TurnDetection] from JSON.
  factory TurnDetection.fromJson(Map<String, dynamic> json) {
    return TurnDetection(
      type: json['type'] != null
          ? TurnDetectionType.fromJson(json['type'] as String)
          : null,
      threshold: (json['threshold'] as num?)?.toDouble(),
      prefixPaddingMs: json['prefix_padding_ms'] as int?,
      silenceDurationMs: json['silence_duration_ms'] as int?,
      createResponse: json['create_response'] as bool?,
    );
  }

  /// The type of turn detection.
  final TurnDetectionType? type;

  /// Voice activity detection threshold (0.0 to 1.0).
  final double? threshold;

  /// Audio to include before speech starts (ms).
  final int? prefixPaddingMs;

  /// Duration of silence to detect end of speech (ms).
  final int? silenceDurationMs;

  /// Whether to automatically create a response.
  final bool? createResponse;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type!.toJson(),
    if (threshold != null) 'threshold': threshold,
    if (prefixPaddingMs != null) 'prefix_padding_ms': prefixPaddingMs,
    if (silenceDurationMs != null) 'silence_duration_ms': silenceDurationMs,
    if (createResponse != null) 'create_response': createResponse,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnDetection &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TurnDetection(type: $type)';
}

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTool &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RealtimeTool(name: $name)';
}
