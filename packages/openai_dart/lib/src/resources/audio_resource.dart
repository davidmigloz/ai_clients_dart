import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/audio/audio.dart';
import 'base_resource.dart';

/// Resource for audio operations.
///
/// Provides text-to-speech and speech-to-text capabilities.
///
/// Access this resource through [OpenAIClient.audio].
///
/// ## Example
///
/// ```dart
/// // Text-to-speech
/// final audioData = await client.audio.speech.create(
///   SpeechRequest(
///     model: 'tts-1',
///     input: 'Hello, world!',
///     voice: SpeechVoice.alloy,
///   ),
/// );
///
/// // Speech-to-text
/// final transcript = await client.audio.transcriptions.create(
///   TranscriptionRequest(
///     file: audioBytes,
///     filename: 'audio.mp3',
///     model: 'whisper-1',
///   ),
/// );
/// ```
class AudioResource extends ResourceBase {
  /// Creates an [AudioResource].
  AudioResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  SpeechResource? _speech;
  TranscriptionsResource? _transcriptions;
  TranslationsResource? _translations;

  /// Access to text-to-speech operations.
  SpeechResource get speech => _speech ??= SpeechResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Access to speech-to-text (transcription) operations.
  TranscriptionsResource get transcriptions =>
      _transcriptions ??= TranscriptionsResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );

  /// Access to audio translation operations.
  TranslationsResource get translations =>
      _translations ??= TranslationsResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );
}

/// Resource for text-to-speech operations.
///
/// Converts text into natural-sounding speech audio.
class SpeechResource extends ResourceBase {
  /// Creates a [SpeechResource].
  SpeechResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/audio/speech';

  /// Generates audio from text.
  ///
  /// Returns the raw audio data as bytes. The format depends on the
  /// [SpeechResponseFormat] specified in the request (defaults to MP3).
  ///
  /// ## Parameters
  ///
  /// - [request] - The speech generation request.
  ///
  /// ## Returns
  ///
  /// A [Uint8List] containing the generated audio data.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final audioBytes = await client.audio.speech.create(
  ///   SpeechRequest(
  ///     model: 'tts-1',
  ///     input: 'Hello! How are you today?',
  ///     voice: SpeechVoice.nova,
  ///     speed: 1.0,
  ///   ),
  /// );
  ///
  /// // Save to file
  /// File('output.mp3').writeAsBytesSync(audioBytes);
  /// ```
  Future<Uint8List> create(SpeechRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    // ErrorInterceptor handles error responses, so we can return bodyBytes directly
    final response = await interceptorChain.execute(httpRequest);
    return response.bodyBytes;
  }
}

/// Resource for transcription (speech-to-text) operations.
///
/// Transcribes audio into text in the original language.
class TranscriptionsResource extends ResourceBase {
  /// Creates a [TranscriptionsResource].
  TranscriptionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/audio/transcriptions';

  /// Transcribes audio into text.
  ///
  /// Supports multiple audio formats including MP3, MP4, MPEG, MPGA,
  /// M4A, WAV, and WebM.
  ///
  /// ## Parameters
  ///
  /// - [request] - The transcription request with audio file.
  ///
  /// ## Returns
  ///
  /// A [TranscriptionResponse] with the transcribed text.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final audioBytes = File('audio.mp3').readAsBytesSync();
  ///
  /// final response = await client.audio.transcriptions.create(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'whisper-1',
  ///     language: 'en',
  ///   ),
  /// );
  ///
  /// print(response.text);
  /// ```
  Future<TranscriptionResponse> create(TranscriptionRequest request) async {
    ensureNotClosed?.call();
    final httpRequest = _createMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionResponse.fromJson(json);
  }

  /// Transcribes audio with verbose output including timing.
  ///
  /// Returns detailed information including segments and word-level
  /// timestamps if requested.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.audio.transcriptions.createVerbose(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'whisper-1',
  ///     timestampGranularities: [
  ///       TimestampGranularity.word,
  ///       TimestampGranularity.segment,
  ///     ],
  ///   ),
  /// );
  ///
  /// for (final word in response.words ?? []) {
  ///   print('${word.word}: ${word.start}s - ${word.end}s');
  /// }
  /// ```
  Future<TranscriptionVerboseResponse> createVerbose(
    TranscriptionRequest request,
  ) async {
    ensureNotClosed?.call();
    // Force verbose_json format
    final verboseRequest = TranscriptionRequest(
      file: request.file,
      filename: request.filename,
      model: request.model,
      language: request.language,
      prompt: request.prompt,
      responseFormat: TranscriptionResponseFormat.verboseJson,
      temperature: request.temperature,
      timestampGranularities: request.timestampGranularities,
    );

    final httpRequest = _createMultipartRequest(verboseRequest);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionVerboseResponse.fromJson(json);
  }

  http.MultipartRequest _createMultipartRequest(TranscriptionRequest request) {
    final url = requestBuilder.buildUrl(_endpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add file
    httpRequest.files.add(
      http.MultipartFile.fromBytes(
        'file',
        request.file,
        filename: request.filename,
      ),
    );

    // Add required fields
    httpRequest.fields['model'] = request.model;

    // Add optional fields
    if (request.language != null) {
      httpRequest.fields['language'] = request.language!;
    }
    if (request.prompt != null) {
      httpRequest.fields['prompt'] = request.prompt!;
    }
    if (request.responseFormat != null) {
      httpRequest.fields['response_format'] = request.responseFormat!.toJson();
    }
    if (request.temperature != null) {
      httpRequest.fields['temperature'] = request.temperature.toString();
    }
    if (request.timestampGranularities != null) {
      // OpenAI API expects repeated form fields for array parameters.
      // Using indexed field names (timestamp_granularities[0], etc.) is a
      // common pattern that servers typically understand for repeated fields.
      for (var i = 0; i < request.timestampGranularities!.length; i++) {
        httpRequest.fields['timestamp_granularities[$i]'] = request
            .timestampGranularities![i]
            .toJson();
      }
    }

    return httpRequest;
  }
}

/// Resource for audio translation operations.
///
/// Translates audio from any supported language into English text.
class TranslationsResource extends ResourceBase {
  /// Creates a [TranslationsResource].
  TranslationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/audio/translations';

  /// Translates audio into English text.
  ///
  /// The model will automatically detect the source language and
  /// translate it to English.
  ///
  /// ## Parameters
  ///
  /// - [request] - The translation request with audio file.
  ///
  /// ## Returns
  ///
  /// A [TranslationResponse] with the translated English text.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final audioBytes = File('spanish_audio.mp3').readAsBytesSync();
  ///
  /// final response = await client.audio.translations.create(
  ///   TranslationRequest(
  ///     file: audioBytes,
  ///     filename: 'spanish_audio.mp3',
  ///     model: 'whisper-1',
  ///   ),
  /// );
  ///
  /// print(response.text); // English translation
  /// ```
  Future<TranslationResponse> create(TranslationRequest request) async {
    ensureNotClosed?.call();
    final httpRequest = _createMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranslationResponse.fromJson(json);
  }

  http.MultipartRequest _createMultipartRequest(TranslationRequest request) {
    final url = requestBuilder.buildUrl(_endpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add file
    httpRequest.files.add(
      http.MultipartFile.fromBytes(
        'file',
        request.file,
        filename: request.filename,
      ),
    );

    // Add required fields
    httpRequest.fields['model'] = request.model;

    // Add optional fields
    if (request.prompt != null) {
      httpRequest.fields['prompt'] = request.prompt!;
    }
    if (request.responseFormat != null) {
      httpRequest.fields['response_format'] = request.responseFormat!.toJson();
    }
    if (request.temperature != null) {
      httpRequest.fields['temperature'] = request.temperature.toString();
    }

    return httpRequest;
  }
}
