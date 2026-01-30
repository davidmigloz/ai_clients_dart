import 'package:meta/meta.dart';

import 'realtime_enums.dart';
import 'realtime_session.dart';
import 'realtime_session_create.dart';

// =============================================================================
// RealtimeTranscriptionSessionCreateRequest
// =============================================================================

/// Request for creating a realtime transcription session via HTTP.
///
/// Transcription sessions are optimized for audio-to-text scenarios
/// without generating audio responses.
///
/// ## Example
///
/// ```dart
/// final response = await client.realtimeSessions.createTranscription(
///   RealtimeTranscriptionSessionCreateRequest(
///     inputAudioFormat: RealtimeAudioFormat.pcm16,
///     inputAudioTranscription: InputAudioTranscription(model: 'whisper-1'),
///   ),
/// );
///
/// print('Client secret: ${response.clientSecret.value}');
/// ```
@immutable
class RealtimeTranscriptionSessionCreateRequest {
  /// Creates a [RealtimeTranscriptionSessionCreateRequest].
  const RealtimeTranscriptionSessionCreateRequest({
    this.inputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.inputAudioNoiseReduction,
  });

  /// Creates a [RealtimeTranscriptionSessionCreateRequest] from JSON.
  factory RealtimeTranscriptionSessionCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranscriptionSessionCreateRequest(
      inputAudioFormat: json['input_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['input_audio_format'] as String)
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
    );
  }

  /// Input audio format.
  final RealtimeAudioFormat? inputAudioFormat;

  /// Configuration for input audio transcription.
  final InputAudioTranscription? inputAudioTranscription;

  /// Turn detection configuration.
  final TurnDetection? turnDetection;

  /// Input audio noise reduction configuration.
  final NoiseReductionConfig? inputAudioNoiseReduction;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (inputAudioFormat != null)
      'input_audio_format': inputAudioFormat!.toJson(),
    if (inputAudioTranscription != null)
      'input_audio_transcription': inputAudioTranscription!.toJson(),
    if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
    if (inputAudioNoiseReduction != null)
      'input_audio_noise_reduction': inputAudioNoiseReduction!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionSessionCreateRequest &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(inputAudioFormat, inputAudioTranscription);

  @override
  String toString() => 'RealtimeTranscriptionSessionCreateRequest(...)';
}

// =============================================================================
// RealtimeTranscriptionSessionCreateResponse
// =============================================================================

/// Response from creating a realtime transcription session via HTTP.
///
/// Contains the session configuration and an ephemeral client secret
/// for authenticating WebSocket connections.
@immutable
class RealtimeTranscriptionSessionCreateResponse {
  /// Creates a [RealtimeTranscriptionSessionCreateResponse].
  const RealtimeTranscriptionSessionCreateResponse({
    required this.clientSecret,
    this.modalities,
    this.inputAudioFormat,
    this.inputAudioTranscription,
    this.turnDetection,
    this.inputAudioNoiseReduction,
  });

  /// Creates a [RealtimeTranscriptionSessionCreateResponse] from JSON.
  factory RealtimeTranscriptionSessionCreateResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RealtimeTranscriptionSessionCreateResponse(
      clientSecret: ClientSecret.fromJson(
        json['client_secret'] as Map<String, dynamic>,
      ),
      modalities: (json['modalities'] as List<dynamic>?)?.cast<String>(),
      inputAudioFormat: json['input_audio_format'] != null
          ? RealtimeAudioFormat.fromJson(json['input_audio_format'] as String)
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
    );
  }

  /// The ephemeral client secret for WebSocket authentication.
  final ClientSecret clientSecret;

  /// The modalities enabled.
  final List<String>? modalities;

  /// Input audio format.
  final RealtimeAudioFormat? inputAudioFormat;

  /// Configuration for input audio transcription.
  final InputAudioTranscription? inputAudioTranscription;

  /// Turn detection configuration.
  final TurnDetection? turnDetection;

  /// Input audio noise reduction configuration.
  final NoiseReductionConfig? inputAudioNoiseReduction;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'client_secret': clientSecret.toJson(),
    if (modalities != null) 'modalities': modalities,
    if (inputAudioFormat != null)
      'input_audio_format': inputAudioFormat!.toJson(),
    if (inputAudioTranscription != null)
      'input_audio_transcription': inputAudioTranscription!.toJson(),
    if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
    if (inputAudioNoiseReduction != null)
      'input_audio_noise_reduction': inputAudioNoiseReduction!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RealtimeTranscriptionSessionCreateResponse &&
          runtimeType == other.runtimeType &&
          clientSecret == other.clientSecret;

  @override
  int get hashCode => clientSecret.hashCode;

  @override
  String toString() =>
      'RealtimeTranscriptionSessionCreateResponse(clientSecret: ${clientSecret.value.substring(0, 10)}...)';
}
