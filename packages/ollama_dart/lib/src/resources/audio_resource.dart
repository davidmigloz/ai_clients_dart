import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/audio/audio_text_request.dart';
import '../models/audio/audio_text_response_format.dart';
import '../models/audio/speech_request.dart';
import '../models/audio/transcription_response.dart';
import '../models/audio/transcription_stream_event.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Speech generation, transcription, and translation through Ollama's
/// OpenAI-compatible audio endpoints.
///
/// Uses the configured server base URL, including any proxy path and query.
/// Ollama validates model capabilities and supported audio options.
class AudioResource extends ResourceBase with StreamingResource {
  /// Creates an audio resource.
  AudioResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Generates speech and collects the complete binary response.
  ///
  /// WAV is the server default. Its header uses maximum length fields because
  /// the server writes it before the audio length is known. PCM is headerless.
  Future<List<int>> createSpeech({
    required SpeechRequest request,
    Future<void>? abortTrigger,
  }) async {
    final response = await interceptorChain.execute(
      _speechRequest(request),
      abortTrigger: abortTrigger,
    );
    return response.bodyBytes;
  }

  /// Streams raw audio bytes as they arrive, without decoding or buffering.
  ///
  /// Chunk boundaries are transport boundaries and may split audio samples.
  /// Cancel the subscription or complete [abortTrigger] to stop generation.
  Stream<List<int>> createSpeechStream({
    required SpeechRequest request,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return streamBytes(
      createRequest: () => _speechRequest(request),
      abortTrigger: abortTrigger,
    );
  }

  http.Request _speechRequest(SpeechRequest request) =>
      http.Request('POST', requestBuilder.buildUrl('/v1/audio/speech'))
        ..headers.addAll(
          requestBuilder.buildHeaders(
            additionalHeaders: {
              'Content-Type': 'application/json',
              'Accept': '*/*',
            },
          ),
        )
        ..body = jsonEncode(request.toJson());

  /// Transcribes uploaded audio into text, with optional verbose metadata.
  ///
  /// Ollama accepts WAV audio; validates upload and recording limits; and
  /// splits long audio into clips. This method forces `stream: false`.
  Future<TranscriptionResponse> createTranscription({
    required TranscriptionRequest request,
    Future<void>? abortTrigger,
  }) => _createAudioText('/v1/audio/transcriptions', request, abortTrigger);

  /// Translates audio into text (Ollama 0.40.12+).
  ///
  /// Omit `toLanguage` to translate to English. This method forces
  /// `stream: false`; verbose metadata describes the output language.
  Future<TranscriptionResponse> createTranslation({
    required TranslationRequest request,
    Future<void>? abortTrigger,
  }) => _createAudioText('/v1/audio/translations', request, abortTrigger);

  /// Streams transcript delta and done events as audio clips finish.
  Stream<TranscriptionStreamEvent> createTranscriptionStream({
    required TranscriptionRequest request,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _streamAudioText('/v1/audio/transcriptions', request, abortTrigger);
  }

  /// Streams translated transcript delta and done events.
  Stream<TranscriptionStreamEvent> createTranslationStream({
    required TranslationRequest request,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _streamAudioText('/v1/audio/translations', request, abortTrigger);
  }

  Future<TranscriptionResponse> _createAudioText(
    String path,
    AudioTextRequest request,
    Future<void>? abortTrigger,
  ) async {
    ensureNotClosed?.call();
    final httpRequest = await _multipartRequest(path, request, stream: false);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    if (request.responseFormat == AudioTextResponseFormat.text) {
      return TranscriptionResponse(text: utf8.decode(response.bodyBytes));
    }
    return TranscriptionResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Stream<TranscriptionStreamEvent> _streamAudioText(
    String path,
    AudioTextRequest request,
    Future<void>? abortTrigger,
  ) async* {
    final httpRequest = await _multipartRequest(path, request, stream: true);
    yield* _parseTranscriptEvents(
      streamBytes(createRequest: () => httpRequest, abortTrigger: abortTrigger),
    );
  }

  Future<http.Request> _multipartRequest(
    String path,
    AudioTextRequest request, {
    required bool stream,
  }) async {
    final multipart =
        http.MultipartRequest('POST', requestBuilder.buildUrl(path))
          ..fields.addAll(request.toFields(streamOverride: stream))
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              request.file.bytes,
              filename: request.file.filename,
            ),
          );
    // Materialize once so the standard auth, request-ID, cancellation, and retry
    // pipeline can clone the complete multipart body without reusing a stream.
    final body = await multipart.finalize().toBytes();
    return http.Request(multipart.method, multipart.url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {
            ...multipart.headers,
            'Accept': stream
                ? 'text/event-stream'
                : request.responseFormat == AudioTextResponseFormat.text
                ? 'text/plain'
                : 'application/json',
          },
        ),
      )
      ..bodyBytes = body;
  }
}

Stream<TranscriptionStreamEvent> _parseTranscriptEvents(
  Stream<List<int>> bytes,
) {
  final data = <String>[];
  var finished = false;

  void emit(EventSink<TranscriptionStreamEvent> sink) {
    if (data.isEmpty || finished) return;
    final payload = data.join('\n');
    data.clear();
    if (payload == '[DONE]') {
      finished = true;
      sink.close();
      return;
    }
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      if (json['error'] case final Object error) {
        final message = error is Map
            ? error['message']?.toString() ?? 'Audio transcription failed'
            : error.toString();
        throw StreamException(message: message, partialData: payload);
      }
      final event = TranscriptionStreamEvent.fromJson(json);
      sink.add(event);
      if (event is TranscriptTextDone) {
        finished = true;
        sink.close();
      }
    } catch (error, trace) {
      finished = true;
      sink
        ..addError(error, trace)
        ..close();
    }
  }

  return bytes
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .transform(
        StreamTransformer<String, TranscriptionStreamEvent>.fromHandlers(
          handleData: (line, sink) {
            if (finished) return;
            if (line.isEmpty) {
              emit(sink);
            } else if (line.startsWith('data:')) {
              final value = line.substring(5);
              data.add(value.startsWith(' ') ? value.substring(1) : value);
            }
          },
          handleDone: (sink) {
            emit(sink);
            if (!finished) sink.close();
          },
        ),
      );
}
