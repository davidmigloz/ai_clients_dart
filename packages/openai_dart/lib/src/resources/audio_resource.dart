import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../errors/exceptions.dart';
import '../models/audio/audio.dart';
import 'audio_file_stream_transport.dart';
import 'base_resource.dart';
import 'speech_stream_transport.dart';
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
    streamClientFactory: streamClientFactory,
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
class SpeechResource extends ResourceBase with StreamingResource {
  /// Creates a [SpeechResource].
  SpeechResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
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
  Future<Uint8List> create(
    SpeechRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final body = _speechBody(request, SpeechStreamFormat.audio);
    await checkSpeechAbort(abortTrigger);
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {
        'Accept': 'application/octet-stream',
        'Content-Type': 'application/json',
      },
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..headers['Accept'] = 'application/octet-stream'
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);
    // ErrorInterceptor handles error responses, so we can return bodyBytes directly
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseSpeechError(
        http.Response.bytes(
          response.bodyBytes,
          response.statusCode,
          headers: response.headers,
          request: response.request ?? httpRequest,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
        ),
      );
    }
    if (_isSseContentType(response.headers['content-type'])) {
      throw const ParseException(
        message: 'Speech response media type does not match audio mode',
      );
    }
    return response.bodyBytes;
  }

  /// Generates audio as raw response byte chunks.
  ///
  /// Selects `stream_format: audio`. An explicitly incompatible request is
  /// rejected before authentication. No chunk has a data URL or SSE envelope,
  /// and chunks are not independently complete audio files.
  ///
  /// A supplied stream-client factory creates an owned client per subscription.
  /// Without a factory the HTTP client is borrowed and never closed here.
  /// Cancellation releases this request and never retries consumed audio.
  Stream<Uint8List> createByteStream(
    SpeechRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final body = _speechBody(request, SpeechStreamFormat.audio);
    return _openSpeechBytes(
      body,
      accept: 'application/octet-stream',
      abortTrigger: abortTrigger,
    );
  }

  /// Generates typed audio delta and final usage events through SSE.
  ///
  /// Selects `stream_format: sse`. An explicitly incompatible request is rejected
  /// before authentication. The provider must send [SpeechAudioDoneEvent] before
  /// normal termination. A valid done event completes the stream and releases
  /// its transport; cancellation does not fabricate a completion event.
  /// Unknown received event types retain their complete JSON.
  Stream<SpeechStreamEvent> createStream(
    SpeechRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final body = _speechBody(request, SpeechStreamFormat.sse);
    return _consumeSpeechEvents(
      _openSpeechBytes(
        body,
        accept: 'text/event-stream',
        abortTrigger: abortTrigger,
      ),
    );
  }

  Map<String, dynamic> _speechBody(
    SpeechRequest request,
    SpeechStreamFormat mode,
  ) {
    if (request.streamFormat != null && request.streamFormat != mode) {
      throw ArgumentError(
        'SpeechRequest.streamFormat is incompatible with this speech method',
      );
    }
    return {...request.toJson(), 'stream_format': mode.toJson()};
  }

  Stream<Uint8List> _openSpeechBytes(
    Map<String, dynamic> body, {
    required String accept,
    Future<void>? abortTrigger,
  }) => openSpeechByteStream(
    httpClient: httpClient,
    streamClientFactory: streamClientFactory,
    requestBuilder: requestBuilder,
    body: body,
    accept: accept,
    timeout: config.timeout,
    ensureNotClosed: ensureNotClosed,
    abortTrigger: abortTrigger,
    parseError: _parseSpeechError,
  );

  ApiException _parseSpeechError(http.Response response) {
    String responseText;
    try {
      responseText = response.body;
    } on FormatException {
      responseText = utf8.decode(response.bodyBytes, allowMalformed: true);
    }
    return parseStreamError(
      response.statusCode,
      responseText,
      response.headers['x-request-id'] ??
          response.request?.headers['X-Request-ID'] ??
          'unknown',
      headers: response.headers,
      cause: response,
    );
  }

  Stream<SpeechStreamEvent> _consumeSpeechEvents(Stream<Uint8List> bytes) =>
      decodeSpeechEvents(bytes);
}

bool _isSseContentType(String? value) =>
    value?.split(';').first.trim().toLowerCase() == 'text/event-stream';

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
  ///     model: 'gpt-transcribe',
  ///     languages: ['en'],
  ///   ),
  /// );
  ///
  /// print(response.text);
  /// ```
  Future<TranscriptionResponse> create(
    TranscriptionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    _rejectStream(request);
    _rejectNonJsonFormat(request);
    final response = await _execute(request, abortTrigger: abortTrigger);
    return _decodeAudioFileJson(response, TranscriptionResponse.fromJson);
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
    TranscriptionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    _rejectStream(request);
    final response = await _execute(
      request.copyWith(responseFormat: AudioResponseFormat.verboseJson),
      abortTrigger: abortTrigger,
    );
    return _decodeAudioFileJson(
      response,
      TranscriptionVerboseResponse.fromJson,
    );
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
    TranscriptionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    _rejectStream(request);
    final response = await _execute(
      request.copyWith(responseFormat: AudioResponseFormat.diarizedJson),
      abortTrigger: abortTrigger,
    );
    return _decodeAudioFileJson(
      response,
      TranscriptionDiarizedResponse.fromJson,
    );
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
  Future<String> createRaw(
    TranscriptionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    _rejectStream(request);
    if (!_rawFormats.contains(request.responseFormat)) {
      throw ArgumentError(
        'createRaw() requires responseFormat to be text, srt, or vtt. Use '
        'create() for json, createVerbose() for verbose_json, or '
        'createDiarized() for diarized_json.',
      );
    }
    final response = await _execute(
      request,
      accept: 'text/plain',
      abortTrigger: abortTrigger,
    );
    return _decodeAudioFileText(response);
  }

  /// Streams a transcription as Server-Sent Events.
  ///
  /// Forces `stream: true` on the multipart request. Yields
  /// [TranscriptTextDeltaEvent]s as text is transcribed, a terminal
  /// [TranscriptTextDoneEvent], and (with `responseFormat: diarized_json`)
  /// [TranscriptTextSegmentEvent]s per completed diarized segment.
  ///
  /// Streaming is not supported for the `whisper-1` model.
  /// A validated done event completes the stream and releases its owned client;
  /// an injected borrowed client remains usable. EOF before done is a stream
  /// failure. Consumed output is never retried or replayed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.audio.transcriptions.createStream(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'gpt-transcribe',
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
    request.validate();
    if (request.responseFormat != null &&
        request.responseFormat != AudioResponseFormat.json &&
        request.responseFormat != AudioResponseFormat.diarizedJson) {
      throw ArgumentError(
        'createStream() requires json, diarized_json or an unset responseFormat',
      );
    }
    final httpRequest = _createMultipartRequest(request, forceStream: true);
    return openTranscriptionStream(
      preparedRequest: httpRequest,
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
      requestBuilder: requestBuilder,
      timeout: config.timeout,
      parseError: _parseHttpError,
      ensureNotClosed: ensureNotClosed,
      abortTrigger: abortTrigger,
    );
  }

  Future<http.Response> _execute(
    TranscriptionRequest request, {
    String accept = 'application/json',
    Future<void>? abortTrigger,
  }) async {
    // Snapshot the upload and repeated fields before yielding to authentication.
    final httpRequest = _createMultipartRequest(request);
    await checkAudioFileAbort(abortTrigger);
    ensureNotClosed?.call();
    httpRequest.headers
      ..addAll(requestBuilder.buildMultipartHeaders())
      ..['Accept'] = accept;
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseHttpError(
        _audioFileResponseWithRequest(response, httpRequest),
      );
    }
    return response;
  }

  ApiException _parseHttpError(http.Response response) => parseStreamError(
    response.statusCode,
    _audioFileErrorText(response),
    response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown',
    headers: response.headers,
    cause: response,
  );

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
        List<int>.of(request.file),
        filename: request.filename,
        contentType: _audioFileContentType(request.fileContentType),
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
class TranslationsResource extends ResourceBase with StreamingResource {
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
  Future<TranslationResponse> create(
    TranslationRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    if (request.responseFormat != null &&
        request.responseFormat != TranslationResponseFormat.json) {
      throw ArgumentError(
        'create() requires json or an unset responseFormat; use createVerbose() '
        'for verbose_json or createRaw() for text, srt or vtt',
      );
    }
    final response = await _execute(request, abortTrigger: abortTrigger);
    return _decodeAudioFileJson(response, TranslationResponse.fromJson);
  }

  /// Translates audio into English with duration and optional segment timings.
  ///
  /// Forces `verbose_json` after validating the supplied request.
  Future<TranslationVerboseResponse> createVerbose(
    TranslationRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    final response = await _execute(
      request.copyWith(responseFormat: TranslationResponseFormat.verboseJson),
      abortTrigger: abortTrigger,
    );
    return _decodeAudioFileJson(response, TranslationVerboseResponse.fromJson);
  }

  /// Returns English text or subtitles without trimming server whitespace.
  ///
  /// Requires `text`, `srt` or `vtt`; JSON modes have their own typed methods.
  Future<String> createRaw(
    TranslationRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    request.validate();
    if (!const {
      TranslationResponseFormat.text,
      TranslationResponseFormat.srt,
      TranslationResponseFormat.vtt,
    }.contains(request.responseFormat)) {
      throw ArgumentError(
        'createRaw() requires text, srt or vtt responseFormat',
      );
    }
    final response = await _execute(
      request,
      accept: 'text/plain',
      abortTrigger: abortTrigger,
    );
    return _decodeAudioFileText(response);
  }

  Future<http.Response> _execute(
    TranslationRequest request, {
    String accept = 'application/json',
    Future<void>? abortTrigger,
  }) async {
    final httpRequest = _createMultipartRequest(request);
    await checkAudioFileAbort(abortTrigger);
    ensureNotClosed?.call();
    httpRequest.headers
      ..addAll(requestBuilder.buildMultipartHeaders())
      ..['Accept'] = accept;
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseHttpError(
        _audioFileResponseWithRequest(response, httpRequest),
      );
    }
    return response;
  }

  ApiException _parseHttpError(http.Response response) => parseStreamError(
    response.statusCode,
    _audioFileErrorText(response),
    response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown',
    headers: response.headers,
    cause: response,
  );

  http.MultipartRequest _createMultipartRequest(TranslationRequest request) {
    final url = requestBuilder.buildUrl(_endpoint);
    final httpRequest = http.MultipartRequest('POST', url);

    // Add file
    httpRequest.files.add(
      http.MultipartFile.fromBytes(
        'file',
        List<int>.of(request.file),
        filename: request.filename,
        contentType: _audioFileContentType(request.fileContentType),
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

MediaType? _audioFileContentType(String? contentType) {
  if (contentType == null) return null;
  try {
    return MediaType.parse(contentType);
  } on FormatException {
    throw const FormatException('Audio file content type must be a MIME type');
  }
}

String _audioFileErrorText(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}

String _decodeAudioFileText(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    throw ParseException(
      message: 'Invalid audio file response encoding',
      responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      cause: const FormatException('Expected a valid audio file text response'),
    );
  }
}

T _decodeAudioFileJson<T>(
  http.Response response,
  T Function(Map<String, dynamic>) parse,
) {
  final body = _decodeAudioFileText(response);
  try {
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected an audio file JSON object');
    }
    return parse(json);
  } on FormatException {
    throw ParseException(
      message: 'Invalid audio file JSON response',
      responseBody: body,
      cause: const FormatException('Expected a valid audio file JSON response'),
    );
  } on TypeError {
    throw ParseException(
      message: 'Invalid audio file JSON response',
      responseBody: body,
      cause: const FormatException('Expected a valid audio file JSON response'),
    );
  }
}

http.Response _audioFileResponseWithRequest(
  http.Response response,
  http.BaseRequest request,
) => response.request != null
    ? response
    : http.Response.bytes(
        response.bodyBytes,
        response.statusCode,
        headers: response.headers,
        request: request,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
