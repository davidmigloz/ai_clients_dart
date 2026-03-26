import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/audio/speech_request.dart';
import '../../models/audio/speech_response.dart';
import '../../models/audio/speech_stream_event.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for speech synthesis (text-to-speech) operations.
///
/// Provides text-to-speech capabilities with optional streaming.
///
/// Example usage:
/// ```dart
/// // Generate speech
/// final response = await client.audio.speech.create(
///   request: SpeechRequest(
///     input: 'Hello, world!',
///     model: 'mistral-speech-latest',
///     voiceId: 'voice-123',
///   ),
/// );
/// print(response.audioData.length);
///
/// // Stream speech
/// final stream = client.audio.speech.createStream(
///   request: SpeechRequest(input: 'Hello!'),
/// );
///
/// await for (final event in stream) {
///   if (event is SpeechStreamAudioDelta) {
///     // Process audio chunk
///   }
/// }
/// ```
class SpeechResource extends ResourceBase with StreamingResource {
  /// Creates a [SpeechResource].
  SpeechResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates speech from text.
  ///
  /// The [request] contains the input text, model, and options.
  ///
  /// Returns a [SpeechResponse] containing base64-encoded audio data.
  ///
  /// Throws [MistralException] if the request fails.
  Future<SpeechResponse> create({required SpeechRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/audio/speech');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SpeechResponse.fromJson(responseBody);
  }

  /// Creates speech from text with streaming.
  ///
  /// The [request] contains the input text, model, and options.
  ///
  /// Returns a stream of [SpeechStreamEvent] chunks as the audio is generated.
  Stream<SpeechStreamEvent> createStream({
    required SpeechRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/audio/speech');

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
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      yield SpeechStreamEvent.fromJson(json);
    }
  }
}
