import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../errors/exceptions.dart';
import '../../models/audio/transcription_request.dart';
import '../../models/audio/transcription_response.dart';
import '../../models/audio/transcription_stream_event.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for audio transcription operations.
///
/// Provides speech-to-text transcription with optional streaming. Requests
/// are sent as `multipart/form-data`, so the audio can be passed inline as
/// bytes, as a URL, or as the ID of a file uploaded to `/v1/files`.
///
/// Example usage:
/// ```dart
/// final bytes = await File('recording.wav').readAsBytes();
/// final response = await client.audio.transcriptions.create(
///   request: TranscriptionRequest(
///     fileBytes: bytes,
///     fileName: 'recording.wav',
///     model: 'voxtral-mini-latest',
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
    super.ensureNotClosed,
  });

  static const _endpoint = '/v1/audio/transcriptions';

  /// Creates an audio transcription.
  ///
  /// The [request] must carry exactly one audio source: [TranscriptionRequest.fileBytes]
  /// (with [TranscriptionRequest.fileName]), [TranscriptionRequest.fileUrl]
  /// or [TranscriptionRequest.file].
  ///
  /// Returns a [TranscriptionResponse] containing the transcribed text.
  ///
  /// Throws [ValidationException] if the audio source is missing or
  /// ambiguous, and [MistralException] if the request fails.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await File('recording.wav').readAsBytes();
  /// final response = await client.audio.transcriptions.create(
  ///   request: TranscriptionRequest(
  ///     fileBytes: bytes,
  ///     fileName: 'recording.wav',
  ///     model: 'voxtral-mini-latest',
  ///     language: 'en',
  ///   ),
  /// );
  /// print(response.text);
  /// ```
  Future<TranscriptionResponse> create({
    required TranscriptionRequest request,
  }) async {
    final httpRequest = _buildRequest(request, stream: false);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionResponse.fromJson(responseBody);
  }

  /// Creates an audio transcription with streaming.
  ///
  /// The [request] follows the same rules as [create].
  ///
  /// Returns a stream of [TranscriptionStreamEvent] chunks as the
  /// transcription progresses.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.audio.transcriptions.createStream(
  ///   request: TranscriptionRequest(
  ///     fileBytes: bytes,
  ///     fileName: 'recording.wav',
  ///     model: 'voxtral-mini-latest',
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
    var httpRequest = _buildRequest(request, stream: true);

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingMultipartRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream
    await for (final json in parseSSE(streamedResponse.stream)) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      yield TranscriptionStreamEvent.fromJson(json);
    }
  }

  http.MultipartRequest _buildRequest(
    TranscriptionRequest request, {
    required bool stream,
  }) {
    _validateAudioSource(request);

    final httpRequest =
        http.MultipartRequest('POST', requestBuilder.buildUrl(_endpoint))
          ..headers.addAll(requestBuilder.buildHeaders())
          ..fields['model'] = request.model;
    final fields = httpRequest.fields;
    final parts = httpRequest.files;

    final fileBytes = request.fileBytes;
    if (fileBytes != null) {
      parts.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: request.fileName,
        ),
      );
    }
    final fileId = request.file;
    if (fileId != null) {
      fields['file_id'] = fileId;
    }
    final fileUrl = request.fileUrl;
    if (fileUrl != null) {
      fields['file_url'] = fileUrl;
    }
    final language = request.language;
    if (language != null) {
      fields['language'] = language;
    }
    final responseFormat = request.responseFormat;
    if (responseFormat != null) {
      fields['response_format'] = responseFormat;
    }
    final prompt = request.prompt;
    if (prompt != null) {
      fields['prompt'] = prompt;
    }
    final temperature = request.temperature;
    if (temperature != null) {
      fields['temperature'] = temperature.toString();
    }
    final diarize = request.diarize;
    if (diarize != null) {
      fields['diarize'] = diarize.toString();
    }
    // Repeated form fields (arrays) cannot be expressed through `fields`,
    // which is a map; a part without a filename is a plain form value.
    if (request.timestampGranularities ?? false) {
      for (final granularity in const ['segment', 'word']) {
        parts.add(
          http.MultipartFile.fromString('timestamp_granularities', granularity),
        );
      }
    }
    for (final term in request.contextBias ?? const <String>[]) {
      parts.add(http.MultipartFile.fromString('context_bias', term));
    }
    if (stream) {
      fields['stream'] = 'true';
    }
    return httpRequest;
  }

  void _validateAudioSource(TranscriptionRequest request) {
    if (!request.hasSingleAudioSource) {
      throw const ValidationException(
        message: 'Exactly one of file, fileUrl, or fileBytes must be provided',
        fieldErrors: {
          'file': ['Provide exactly one of: file (ID), fileUrl, or fileBytes'],
        },
      );
    }
    if (request.fileBytes != null && request.fileName == null) {
      throw const ValidationException(
        message: 'fileName is required when using fileBytes',
        fieldErrors: {
          'fileName': ['fileName must be provided with fileBytes'],
        },
      );
    }
  }
}
