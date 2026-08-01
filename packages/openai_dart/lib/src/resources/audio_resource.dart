import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/audio/audio.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

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
    super.streamClientFactory,
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
        streamClientFactory: streamClientFactory,
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
class TranscriptionsResource extends ResourceBase with StreamingResource {
  /// Creates a [TranscriptionsResource].
  TranscriptionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  static const _endpoint = '/audio/transcriptions';

  static const Set<AudioResponseFormat> _rawFormats = {
    AudioResponseFormat.text,
    AudioResponseFormat.srt,
    AudioResponseFormat.vtt,
  };

  /// Transcribes audio into text.
  ///
  /// Only supports the `json` response format (the default) — use
  /// [createVerbose] for `verbose_json`, [createDiarized] for
  /// `diarized_json`, or [createRaw] for `text`/`srt`/`vtt`.
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
  ///     model: 'gpt-4o-transcribe',
  ///     language: 'en',
  ///   ),
  /// );
  ///
  /// print(response.text);
  /// ```
  Future<TranscriptionResponse> create(TranscriptionRequest request) async {
    ensureNotClosed?.call();
    _rejectStream(request);
    _rejectNonJsonFormat(request);
    final httpRequest = _createMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionResponse.fromJson(json);
  }

  /// Transcribes audio with verbose output including timing.
  ///
  /// Forces `responseFormat: verbose_json`. Returns detailed information
  /// including segments and word-level timestamps if requested.
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
    _rejectStream(request);
    final verboseRequest = request.copyWith(
      responseFormat: AudioResponseFormat.verboseJson,
    );
    final httpRequest = _createMultipartRequest(verboseRequest);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionVerboseResponse.fromJson(json);
  }

  /// Transcribes audio with per-speaker diarization.
  ///
  /// Forces `responseFormat: diarized_json`. Typically used with the
  /// `gpt-4o-transcribe-diarize` model; pass [TranscriptionRequest.knownSpeakerNames]
  /// and [TranscriptionRequest.knownSpeakerReferences] to label known
  /// speakers instead of the default sequential letters (`A`, `B`, ...).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.audio.transcriptions.createDiarized(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'call.mp3',
  ///     model: 'gpt-4o-transcribe-diarize',
  ///   ),
  /// );
  ///
  /// for (final segment in response.segments) {
  ///   print('${segment.speaker}: ${segment.text}');
  /// }
  /// ```
  Future<TranscriptionDiarizedResponse> createDiarized(
    TranscriptionRequest request,
  ) async {
    ensureNotClosed?.call();
    _rejectStream(request);
    final diarizedRequest = request.copyWith(
      responseFormat: AudioResponseFormat.diarizedJson,
    );
    final httpRequest = _createMultipartRequest(diarizedRequest);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TranscriptionDiarizedResponse.fromJson(json);
  }

  /// Transcribes audio and returns the raw response body.
  ///
  /// Use this for the `text`, `srt`, and `vtt` response formats, which are
  /// plain strings rather than JSON — [request.responseFormat] must be set
  /// to one of [AudioResponseFormat.text], [AudioResponseFormat.srt], or
  /// [AudioResponseFormat.vtt].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final srt = await client.audio.transcriptions.createRaw(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'whisper-1',
  ///     responseFormat: AudioResponseFormat.srt,
  ///   ),
  /// );
  /// ```
  Future<String> createRaw(TranscriptionRequest request) async {
    ensureNotClosed?.call();
    _rejectStream(request);
    if (!_rawFormats.contains(request.responseFormat)) {
      throw ArgumentError(
        'createRaw() requires responseFormat to be text, srt, or vtt. Use '
        'create() for json, createVerbose() for verbose_json, or '
        'createDiarized() for diarized_json.',
      );
    }
    final httpRequest = _createMultipartRequest(request);
    httpRequest.headers.addAll(requestBuilder.buildMultipartHeaders());
    // response_format text/srt/vtt is not JSON — ErrorInterceptor still
    // handles non-2xx responses, so returning the raw body directly is safe.
    final response = await interceptorChain.execute(httpRequest);
    return response.body;
  }

  /// Streams a transcription as Server-Sent Events.
  ///
  /// Forces `stream: true` on the multipart request. Yields
  /// [TranscriptTextDeltaEvent]s as text is transcribed, a terminal
  /// [TranscriptTextDoneEvent], and (with `responseFormat: diarized_json`)
  /// [TranscriptTextSegmentEvent]s per completed diarized segment.
  ///
  /// Streaming is not supported for the `whisper-1` model.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.audio.transcriptions.createStream(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'gpt-4o-transcribe',
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   switch (event) {
  ///     case TranscriptTextDeltaEvent():
  ///       stdout.write(event.delta);
  ///     case TranscriptTextDoneEvent():
  ///       print('\ndone — ${event.usage?.totalTokens} tokens');
  ///     case TranscriptTextSegmentEvent():
  ///       print('${event.speaker}: ${event.text}');
  ///     case TranscriptTextUnknownEvent():
  ///       // Forward-compatibility fallback.
  ///   }
  /// }
  /// ```
  Stream<TranscriptionStreamEvent> createStream(
    TranscriptionRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final httpRequest = _createMultipartRequest(request, forceStream: true);
    return streamSseEventsForRequest(
      request: httpRequest,
      abortTrigger: abortTrigger,
    ).map((json) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      try {
        return TranscriptionStreamEvent.fromJson(json);
      } on FormatException catch (e) {
        throw ParseException(
          message: 'Failed to parse transcription stream event: $e',
          responseBody: json.toString(),
          cause: e,
        );
      } on TypeError catch (e) {
        throw ParseException(
          message: 'Failed to parse transcription stream event: $e',
          responseBody: json.toString(),
          cause: e,
        );
      }
    });
  }

  void _rejectStream(TranscriptionRequest request) {
    if (request.stream ?? false) {
      throw ArgumentError(
        'stream: true is not supported here. Use createStream() instead.',
      );
    }
  }

  void _rejectNonJsonFormat(TranscriptionRequest request) {
    const disallowed = {
      AudioResponseFormat.verboseJson,
      AudioResponseFormat.diarizedJson,
      AudioResponseFormat.text,
      AudioResponseFormat.srt,
      AudioResponseFormat.vtt,
    };
    if (disallowed.contains(request.responseFormat)) {
      throw ArgumentError(
        'create() only supports responseFormat json (or null/unset). Use '
        'createVerbose() for verbose_json, createDiarized() for '
        'diarized_json, or createRaw() for text/srt/vtt.',
      );
    }
  }

  http.MultipartRequest _createMultipartRequest(
    TranscriptionRequest request, {
    bool forceStream = false,
  }) {
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

    // Add optional scalar fields
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
    if (forceStream) {
      httpRequest.fields['stream'] = 'true';
    } else if (request.stream != null) {
      httpRequest.fields['stream'] = request.stream! ? 'true' : 'false';
    }

    // chunking_strategy is either the literal string "auto" or a
    // bracket-nested object (chunking_strategy[type], etc.) — both encode
    // as plain form fields.
    if (request.chunkingStrategy != null) {
      httpRequest.fields.addAll(request.chunkingStrategy!.toFormFields());
    }

    // Array parameters use the documented `qs`-style wire format: the same
    // key repeated with a `[]` suffix, e.g. `keywords[]=foo&keywords[]=bar`.
    // http.MultipartRequest.fields is a Map and can't hold repeated keys, so
    // these go through .files as filename-less MultipartFile parts, which
    // still read as plain form fields on the wire (no Content-Disposition
    // `filename=`).
    _addRepeatedField(
      httpRequest,
      'timestamp_granularities',
      request.timestampGranularities?.map((g) => g.toJson()),
    );
    _addRepeatedField(
      httpRequest,
      'include',
      request.include?.map((i) => i.toJson()),
    );
    _addRepeatedField(httpRequest, 'keywords', request.keywords);
    _addRepeatedField(httpRequest, 'languages', request.languages);
    _addRepeatedField(
      httpRequest,
      'known_speaker_names',
      request.knownSpeakerNames,
    );
    _addRepeatedField(
      httpRequest,
      'known_speaker_references',
      request.knownSpeakerReferences,
    );

    return httpRequest;
  }

  void _addRepeatedField(
    http.MultipartRequest request,
    String name,
    Iterable<String>? values,
  ) {
    if (values == null) return;
    for (final value in values) {
      request.files.add(http.MultipartFile.fromString('$name[]', value));
    }
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
