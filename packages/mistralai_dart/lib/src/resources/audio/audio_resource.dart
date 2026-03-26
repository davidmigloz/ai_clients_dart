import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'speech_resource.dart';
import 'transcriptions_resource.dart';
import 'voices_resource.dart';

/// Resource for Audio API operations.
///
/// Provides audio processing capabilities including transcription, speech
/// synthesis, and voice management.
///
/// Example usage:
/// ```dart
/// // Transcribe audio
/// final response = await client.audio.transcriptions.create(
///   request: TranscriptionRequest(
///     file: audioFile.id,
///     model: 'mistral-audio-latest',
///   ),
/// );
/// print(response.text);
///
/// // Generate speech
/// final speech = await client.audio.speech.create(
///   request: SpeechRequest(
///     input: 'Hello, world!',
///     voiceId: 'voice-123',
///   ),
/// );
///
/// // List voices
/// final voices = await client.audio.voices.list();
/// ```
class AudioResource {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client httpClient;

  /// Interceptor chain.
  final InterceptorChain interceptorChain;

  /// Request builder.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Sub-resource for audio transcriptions.
  late final TranscriptionsResource transcriptions;

  /// Sub-resource for speech synthesis.
  late final SpeechResource speech;

  /// Sub-resource for voice management.
  late final VoicesResource voices;

  /// Creates an [AudioResource].
  AudioResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  }) {
    transcriptions = TranscriptionsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    speech = SpeechResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    voices = VoicesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
