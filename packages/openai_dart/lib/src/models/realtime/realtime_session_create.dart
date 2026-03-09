import 'package:meta/meta.dart';

import '../common/auto_or_value.dart';
import 'realtime_enums.dart';
import 'realtime_session.dart';

// =============================================================================
// ClientSecret
// =============================================================================

/// An ephemeral client secret for realtime API authentication.
///
/// Client secrets are short-lived tokens that can be used to authenticate
/// WebSocket connections without exposing your main API key.
@immutable
class ClientSecret {
  /// Creates a [ClientSecret].
  const ClientSecret({required this.value, required this.expiresAt});

  /// Creates a [ClientSecret] from JSON.
  factory ClientSecret.fromJson(Map<String, dynamic> json) {
    return ClientSecret(
      value: json['value'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }

  /// The client secret value (starts with "ek_").
  final String value;

  /// Unix timestamp when the secret expires.
  final int expiresAt;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'value': value, 'expires_at': expiresAt};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientSecret &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ClientSecret(expiresAt: $expiresAt)';
}

// =============================================================================
// NoiseReductionConfig
// =============================================================================

/// Configuration for input audio noise reduction.
@immutable
class NoiseReductionConfig {
  /// Creates a [NoiseReductionConfig].
  const NoiseReductionConfig({this.type});

  /// Creates a [NoiseReductionConfig] from JSON.
  factory NoiseReductionConfig.fromJson(Map<String, dynamic> json) {
    return NoiseReductionConfig(type: json['type'] as String?);
  }

  /// The noise reduction type (e.g., "near_field", "far_field").
  final String? type;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (type != null) 'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoiseReductionConfig &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'NoiseReductionConfig(type: $type)';
}

// =============================================================================
// RealtimeSessionCreateRequest
// =============================================================================

/// Request for creating a realtime session via HTTP.
///
/// This endpoint creates an ephemeral API key that can be used to
/// authenticate a WebSocket connection to the Realtime API.
///
/// ## Example
///
/// ```dart
/// final response = await client.realtimeSessions.create(
///   RealtimeSessionCreateRequest(
///     model: 'gpt-realtime-1.5',
///     voice: RealtimeVoice.alloy,
///     instructions: 'You are a helpful assistant.',
///   ),
/// );
///
/// // Use the client secret for WebSocket auth
/// print('Client secret: ${response.clientSecret.value}');
/// ```
@immutable
class RealtimeSessionCreateRequest {
  /// Creates a [RealtimeSessionCreateRequest].
  ///
  /// The [type] field is used as a discriminator when the API needs to
  /// distinguish between realtime and transcription sessions (e.g., when
  /// creating client secrets). Set to `"realtime"` for realtime sessions.
  const RealtimeSessionCreateRequest({
    this.type,
    required this.model,
    this.modalities,
    this.instructions,
    this.voice,
    this.inputAudioFormat,
    this.outputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.inputAudioNoiseReduction,
    this.tools,
    this.toolChoice,
    this.temperature,
    this.maxResponseOutputTokens,
  });

  /// Creates a [RealtimeSessionCreateRequest] from JSON.
  factory RealtimeSessionCreateRequest.fromJson(Map<String, dynamic> json) {
    return RealtimeSessionCreateRequest(
      type: json['type'] as String?,
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
      inputAudioNoiseReduction: json['input_audio_noise_reduction'] != null
          ? NoiseReductionConfig.fromJson(
              json['input_audio_noise_reduction'] as Map<String, dynamic>,
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

  /// The session type discriminator.
  ///
  /// This field is used by the API to distinguish between realtime sessions
  /// and transcription sessions when creating client secrets. Set to `"realtime"`
  /// for realtime sessions. Only needed for certain endpoints like client secrets.
  final String? type;

  /// The model to use (required for HTTP, e.g., 'gpt-realtime-1.5').
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

  /// Input audio noise reduction configuration.
  final NoiseReductionConfig? inputAudioNoiseReduction;

  /// Tools available to the model.
  final List<RealtimeTool>? tools;

  /// Tool choice setting.
  final RealtimeToolChoice? toolChoice;

  /// Sampling temperature (0.6-1.2).
  final double? temperature;

  /// Maximum output tokens ("inf" or a specific integer).
  final InfOrInt? maxResponseOutputTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
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
    if (inputAudioNoiseReduction != null)
      'input_audio_noise_reduction': inputAudioNoiseReduction!.toJson(),
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (maxResponseOutputTokens != null)
      'max_response_output_tokens': maxResponseOutputTokens!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeSessionCreateRequest &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;

  @override
  String toString() => 'RealtimeSessionCreateRequest(model: $model)';
}

// =============================================================================
// RealtimeSessionCreateResponse
// =============================================================================

/// Response from creating a realtime session via HTTP.
///
/// Contains the session configuration and an ephemeral client secret
/// for authenticating WebSocket connections.
@immutable
class RealtimeSessionCreateResponse {
  /// Creates a [RealtimeSessionCreateResponse].
  const RealtimeSessionCreateResponse({
    required this.id,
    required this.object,
    required this.model,
    this.clientSecret,
    this.modalities,
    this.instructions,
    this.voice,
    this.inputAudioFormat,
    this.outputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.inputAudioNoiseReduction,
    this.tools,
    this.toolChoice,
    this.temperature,
    this.maxResponseOutputTokens,
  });

  /// Creates a [RealtimeSessionCreateResponse] from JSON.
  factory RealtimeSessionCreateResponse.fromJson(Map<String, dynamic> json) {
    return RealtimeSessionCreateResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      model: json['model'] as String,
      clientSecret: json['client_secret'] != null
          ? ClientSecret.fromJson(json['client_secret'] as Map<String, dynamic>)
          : null,
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
      inputAudioNoiseReduction: json['input_audio_noise_reduction'] != null
          ? NoiseReductionConfig.fromJson(
              json['input_audio_noise_reduction'] as Map<String, dynamic>,
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

  /// The ephemeral client secret for WebSocket authentication.
  ///
  /// This field is present when the session is created via the HTTP endpoint,
  /// but may be null when the session is returned as part of another response.
  final ClientSecret? clientSecret;

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

  /// Input audio noise reduction configuration.
  final NoiseReductionConfig? inputAudioNoiseReduction;

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
    if (clientSecret != null) 'client_secret': clientSecret!.toJson(),
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
    if (inputAudioNoiseReduction != null)
      'input_audio_noise_reduction': inputAudioNoiseReduction!.toJson(),
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (maxResponseOutputTokens != null)
      'max_response_output_tokens': maxResponseOutputTokens!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeSessionCreateResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RealtimeSessionCreateResponse(id: $id, model: $model)';
}
