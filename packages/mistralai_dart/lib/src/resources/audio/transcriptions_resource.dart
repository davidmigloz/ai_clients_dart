import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/audio/transcription_request.dart';
import '../../models/audio/transcription_response.dart';
import '../../models/audio/transcription_stream_event.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for audio transcription operations.
///
/// Provides speech-to-text transcription with optional streaming.
///
/// Example usage:
/// ```dart
/// final response = await client.audio.transcriptions.create(
///   request: TranscriptionRequest(
///     file: audioFileId,
///     model: 'mistral-audio-latest',
///   ),
/// );
/// print(response.text);
/// ```
class TranscriptionsResource extends ResourceBase with StreamingResource {
  /// Creates a [TranscriptionsResource].
  TranscriptionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Creates an audio transcription.
  ///
  /// The [request] contains the audio file reference, model, and options.
  ///
  /// Returns a [TranscriptionResponse] containing the transcribed text.
  ///
  /// Throws [MistralException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// // Upload the audio file first
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
  ///     language: 'en',
  ///   ),
  /// );
  /// print(response.text);
  /// ```
  Future<TranscriptionResponse> create({
    required TranscriptionRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/audio/transcriptions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionResponse.fromJson(responseBody);
  }

  /// Creates an audio transcription with streaming.
  ///
  /// The [request] contains the audio file reference, model, and options.
  ///
  /// Returns a stream of [TranscriptionStreamEvent] chunks as the
  /// transcription progresses.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.audio.transcriptions.createStream(
  ///   request: TranscriptionRequest(
  ///     file: audioFileId,
  ///     model: 'mistral-audio-latest',
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   if (event.text != null) {
  ///     stdout.write(event.text);
  ///   }
  /// }
  /// ```
  Stream<TranscriptionStreamEvent> createStream({
    required TranscriptionRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/audio/transcriptions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Add stream: true to the request
    final requestData = <String, dynamic>{...request.toJson(), 'stream': true};

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData);

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream
    await for (final json in parseSSE(streamedResponse.stream)) {
      yield TranscriptionStreamEvent.fromJson(json);
    }
  }
}
