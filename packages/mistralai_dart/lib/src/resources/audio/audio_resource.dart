import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'transcriptions_resource.dart';

/// Resource for Audio API operations.
///
/// Provides audio processing capabilities including transcription.
///
/// Example usage:
/// ```dart
/// // Upload audio file
/// final file = await client.files.upload(
///   file: audioFile,
///   purpose: FilePurpose.audio,
/// );
///
/// // Transcribe the audio
/// final response = await client.audio.transcriptions.create(
///   request: TranscriptionRequest(
///     file: file.id,
///     model: 'mistral-audio-latest',
///   ),
/// );
/// print(response.text);
///
/// // Or stream the transcription
/// final stream = client.audio.transcriptions.createStream(
///   request: TranscriptionRequest(file: file.id),
/// );
///
/// await for (final event in stream) {
///   if (event.text != null) {
///     stdout.write(event.text);
///   }
/// }
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

  /// Sub-resource for audio transcriptions.
  late final TranscriptionsResource transcriptions;

  /// Creates an [AudioResource].
  AudioResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
  }) {
    transcriptions = TranscriptionsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }
}
