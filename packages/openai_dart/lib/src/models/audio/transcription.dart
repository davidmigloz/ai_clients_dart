import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Formats a nullable list for `toString` — `null` when absent, otherwise
/// `'N items'` (never the full contents, to keep debug output short).
String? _listSummary(List<Object?>? list) =>
    list == null ? null : '${list.length} items';

/// A request to transcribe audio into text.
///
/// Converts audio in various formats to text in the original language.
///
/// ## Example
///
/// ```dart
/// final request = TranscriptionRequest(
///   file: audioBytes,
///   filename: 'recording.mp3',
///   model: 'gpt-4o-transcribe',
/// );
/// ```
@immutable
class TranscriptionRequest {
  /// Creates a [TranscriptionRequest].
  const TranscriptionRequest({
    required this.file,
    required this.filename,
    required this.model,
    this.chunkingStrategy,
    this.include,
    this.keywords,
    this.knownSpeakerNames,
    this.knownSpeakerReferences,
    this.language,
    this.languages,
    this.prompt,
    this.responseFormat,
    this.stream,
    this.temperature,
    this.timestampGranularities,
  });

  /// The audio file to transcribe.
  ///
  /// Supported formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.
  final Uint8List file;

  /// The filename of the audio file.
  ///
  /// Must include the file extension for proper format detection.
  final String filename;

  /// The model to use for transcription.
  ///
  /// One of `gpt-transcribe`, `gpt-4o-transcribe`, `gpt-4o-mini-transcribe`,
  /// `gpt-4o-mini-transcribe-2025-12-15`, `whisper-1`, or
  /// `gpt-4o-transcribe-diarize`.
  final String model;

  /// Controls how the audio is cut into chunks before transcription.
  ///
  /// When set to [TranscriptionChunkingStrategy.auto], the server normalizes
  /// loudness and uses voice activity detection (VAD) to choose boundaries.
  /// [TranscriptionChunkingStrategy.serverVad] lets you tune the VAD
  /// parameters manually. If unset, the audio is transcribed as a single
  /// block. Required when using `gpt-4o-transcribe-diarize` for inputs
  /// longer than 30 seconds.
  final TranscriptionChunkingStrategy? chunkingStrategy;

  /// Additional information to include in the transcription response.
  ///
  /// [TranscriptionInclude.logprobs] returns the log probabilities of the
  /// tokens to help understand the model's confidence. Only works with
  /// `responseFormat` set to `json` and only with the `gpt-4o-transcribe`,
  /// `gpt-4o-mini-transcribe`, and `gpt-4o-mini-transcribe-2025-12-15`
  /// models. Not supported when using `gpt-4o-transcribe-diarize`.
  final List<TranscriptionInclude>? include;

  /// Words or phrases to guide transcription of the input audio.
  ///
  /// Supported by `gpt-transcribe`.
  final List<String>? keywords;

  /// Speaker names that correspond to the audio samples in
  /// [knownSpeakerReferences].
  ///
  /// Each entry should be a short identifier (e.g. `customer` or `agent`).
  /// Up to 4 speakers are supported.
  final List<String>? knownSpeakerNames;

  /// Audio samples containing known speaker references matching
  /// [knownSpeakerNames].
  ///
  /// Each entry must be a [data URL](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URLs)
  /// in the form `data:<mediaType>;base64,<data>` — raw base64 without the
  /// `data:` prefix is not accepted. Each sample must be between 2 and 10
  /// seconds, and can use any of the input audio formats supported by
  /// [file]. Up to 4 references are supported.
  final List<String>? knownSpeakerReferences;

  /// The language of the input audio in ISO-639-1 format (e.g. `en`).
  ///
  /// Supplying this improves accuracy and latency. If not provided, the
  /// language is auto-detected.
  final String? language;

  /// Possible languages of the input audio, in ISO-639-1 format.
  ///
  /// Supported by `gpt-transcribe`.
  final List<String>? languages;

  /// Optional text to guide the model's style or continue a previous audio
  /// segment.
  ///
  /// The prompt should match the audio language. Not supported when using
  /// `gpt-4o-transcribe-diarize`.
  final String? prompt;

  /// The format of the transcription output.
  ///
  /// Defaults to [AudioResponseFormat.json]. For `gpt-4o-transcribe` and
  /// `gpt-4o-mini-transcribe`, the only supported format is `json`. For
  /// `gpt-4o-transcribe-diarize`, the supported formats are `json`, `text`,
  /// and `diarized_json` (required to receive speaker annotations).
  final AudioResponseFormat? responseFormat;

  /// Whether to stream the response using server-sent events.
  ///
  /// Streaming is not supported for the `whisper-1` model and is ignored.
  /// Use [TranscriptionsResource.createStream] rather than setting this
  /// directly.
  final bool? stream;

  /// The sampling temperature, between 0 and 1.
  ///
  /// Higher values make output more random, lower values more deterministic.
  /// If set to 0, the model uses log probability to automatically increase
  /// the temperature until certain thresholds are hit.
  final double? temperature;

  /// The timestamp granularities to populate for this transcription.
  ///
  /// `responseFormat` must be [AudioResponseFormat.verboseJson] to use
  /// timestamp granularities. Not available for `gpt-4o-transcribe-diarize`.
  final List<TimestampGranularity>? timestampGranularities;

  /// Creates a copy with the given fields replaced.
  TranscriptionRequest copyWith({
    Uint8List? file,
    String? filename,
    String? model,
    Object? chunkingStrategy = unsetCopyWithValue,
    Object? include = unsetCopyWithValue,
    Object? keywords = unsetCopyWithValue,
    Object? knownSpeakerNames = unsetCopyWithValue,
    Object? knownSpeakerReferences = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? languages = unsetCopyWithValue,
    Object? prompt = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? timestampGranularities = unsetCopyWithValue,
  }) {
    return TranscriptionRequest(
      file: file ?? this.file,
      filename: filename ?? this.filename,
      model: model ?? this.model,
      chunkingStrategy: chunkingStrategy == unsetCopyWithValue
          ? this.chunkingStrategy
          : chunkingStrategy as TranscriptionChunkingStrategy?,
      include: include == unsetCopyWithValue
          ? this.include
          : include as List<TranscriptionInclude>?,
      keywords: keywords == unsetCopyWithValue
          ? this.keywords
          : keywords as List<String>?,
      knownSpeakerNames: knownSpeakerNames == unsetCopyWithValue
          ? this.knownSpeakerNames
          : knownSpeakerNames as List<String>?,
      knownSpeakerReferences: knownSpeakerReferences == unsetCopyWithValue
          ? this.knownSpeakerReferences
          : knownSpeakerReferences as List<String>?,
      language: language == unsetCopyWithValue
          ? this.language
          : language as String?,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<String>?,
      prompt: prompt == unsetCopyWithValue ? this.prompt : prompt as String?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as AudioResponseFormat?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      timestampGranularities: timestampGranularities == unsetCopyWithValue
          ? this.timestampGranularities
          : timestampGranularities as List<TimestampGranularity>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionRequest &&
          runtimeType == other.runtimeType &&
          listsEqual(file, other.file) &&
          filename == other.filename &&
          model == other.model &&
          chunkingStrategy == other.chunkingStrategy &&
          listsEqual(include, other.include) &&
          listsEqual(keywords, other.keywords) &&
          listsEqual(knownSpeakerNames, other.knownSpeakerNames) &&
          listsEqual(knownSpeakerReferences, other.knownSpeakerReferences) &&
          language == other.language &&
          listsEqual(languages, other.languages) &&
          prompt == other.prompt &&
          responseFormat == other.responseFormat &&
          stream == other.stream &&
          temperature == other.temperature &&
          listsEqual(timestampGranularities, other.timestampGranularities);

  @override
  int get hashCode => Object.hash(
    listHash(file),
    filename,
    model,
    chunkingStrategy,
    listHash(include),
    listHash(keywords),
    listHash(knownSpeakerNames),
    listHash(knownSpeakerReferences),
    language,
    listHash(languages),
    prompt,
    responseFormat,
    stream,
    temperature,
    listHash(timestampGranularities),
  );

  @override
  String toString() =>
      'TranscriptionRequest(file: ${file.length} bytes, filename: $filename, '
      'model: $model, chunkingStrategy: $chunkingStrategy, '
      'include: ${_listSummary(include)}, keywords: ${_listSummary(keywords)}, '
      'knownSpeakerNames: ${_listSummary(knownSpeakerNames)}, '
      'knownSpeakerReferences: ${_listSummary(knownSpeakerReferences)}, '
      'language: $language, languages: ${_listSummary(languages)}, '
      'prompt: $prompt, responseFormat: $responseFormat, stream: $stream, '
      'temperature: $temperature, '
      'timestampGranularities: ${_listSummary(timestampGranularities)})';
}

/// The format of the transcription/translation output.
///
/// Renamed from `TranscriptionResponseFormat` — see the `@Deprecated` typedef
/// below — and expanded with [diarizedJson] and the forward-compatibility
/// [unknown] fallback.
enum AudioResponseFormat {
  /// Unknown format — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

  /// JSON format with just the text.
  json._('json'),

  /// Plain text format.
  text._('text'),

  /// SubRip subtitle format.
  srt._('srt'),

  /// Verbose JSON with timestamps and metadata.
  verboseJson._('verbose_json'),

  /// WebVTT subtitle format.
  vtt._('vtt'),

  /// Diarized JSON with per-speaker segments (`gpt-4o-transcribe-diarize`).
  diarizedJson._('diarized_json');

  const AudioResponseFormat._(this._value);

  /// Creates from JSON string. Unknown values map to
  /// [AudioResponseFormat.unknown].
  factory AudioResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => AudioResponseFormat.unknown,
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Deprecated; use [AudioResponseFormat] instead.
///
/// Kept as a typedef so existing references to `TranscriptionResponseFormat`
/// keep compiling — it is the exact same type as [AudioResponseFormat].
@Deprecated('Use AudioResponseFormat instead.')
typedef TranscriptionResponseFormat = AudioResponseFormat;

/// Timestamp granularity options.
enum TimestampGranularity {
  /// Word-level timestamps.
  word._('word'),

  /// Segment-level timestamps.
  segment._('segment');

  const TimestampGranularity._(this._value);

  /// Creates from JSON string.
  factory TimestampGranularity.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown granularity: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Additional information that can be included in a transcription response.
enum TranscriptionInclude {
  /// Unknown value — forward-compat fallback for unrecognized server values.
  unknown._('unknown'),

  /// Include the log probabilities of the transcribed tokens.
  logprobs._('logprobs');

  const TranscriptionInclude._(this._value);

  /// Creates from JSON string. Unknown values map to
  /// [TranscriptionInclude.unknown].
  factory TranscriptionInclude.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => TranscriptionInclude.unknown,
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Controls how the audio is cut into chunks before transcription.
///
/// Request-only — never parsed from a server response, so there is no
/// `fromJson`/`Unknown` fallback variant. [toFormFields] produces the
/// multipart form fields for the strategy (bracket-nested keys per the
/// OpenAI multipart wire format).
@immutable
sealed class TranscriptionChunkingStrategy {
  const TranscriptionChunkingStrategy();

  /// Automatically choose chunking parameters based on the audio.
  const factory TranscriptionChunkingStrategy.auto() =
      TranscriptionChunkingStrategyAuto;

  /// Tune voice activity detection (VAD) chunking parameters manually.
  const factory TranscriptionChunkingStrategy.serverVad(
    TranscriptionVadConfig config,
  ) = TranscriptionChunkingStrategyServerVad;

  /// The multipart form fields that encode this strategy.
  Map<String, String> toFormFields();
}

/// Automatically choose chunking parameters based on the audio.
@immutable
class TranscriptionChunkingStrategyAuto extends TranscriptionChunkingStrategy {
  /// Creates a [TranscriptionChunkingStrategyAuto].
  const TranscriptionChunkingStrategyAuto();

  @override
  Map<String, String> toFormFields() => const {'chunking_strategy': 'auto'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionChunkingStrategyAuto &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TranscriptionChunkingStrategy.auto()';
}

/// Tune voice activity detection (VAD) chunking parameters manually.
@immutable
class TranscriptionChunkingStrategyServerVad
    extends TranscriptionChunkingStrategy {
  /// Creates a [TranscriptionChunkingStrategyServerVad].
  const TranscriptionChunkingStrategyServerVad(this.config);

  /// The VAD tuning parameters.
  final TranscriptionVadConfig config;

  @override
  Map<String, String> toFormFields() => {
    'chunking_strategy[type]': 'server_vad',
    if (config.prefixPaddingMs != null)
      'chunking_strategy[prefix_padding_ms]': config.prefixPaddingMs.toString(),
    if (config.silenceDurationMs != null)
      'chunking_strategy[silence_duration_ms]': config.silenceDurationMs
          .toString(),
    if (config.threshold != null)
      'chunking_strategy[threshold]': config.threshold.toString(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionChunkingStrategyServerVad &&
          runtimeType == other.runtimeType &&
          config == other.config;

  @override
  int get hashCode => config.hashCode;

  @override
  String toString() => 'TranscriptionChunkingStrategy.serverVad($config)';
}

/// Voice activity detection (VAD) tuning parameters for
/// [TranscriptionChunkingStrategy.serverVad].
@immutable
class TranscriptionVadConfig {
  /// Creates a [TranscriptionVadConfig].
  const TranscriptionVadConfig({
    this.prefixPaddingMs,
    this.silenceDurationMs,
    this.threshold,
  });

  /// Amount of audio to include before the VAD-detected speech, in
  /// milliseconds. Defaults to 300.
  final int? prefixPaddingMs;

  /// Duration of silence to detect speech stop, in milliseconds. Defaults
  /// to 200. Shorter values make the model respond more quickly, but may
  /// jump in on short pauses from the user.
  final int? silenceDurationMs;

  /// Sensitivity threshold (0.0 to 1.0) for voice activity detection.
  /// Defaults to 0.5. A higher threshold requires louder audio to activate
  /// the model, which may perform better in noisy environments.
  final double? threshold;

  /// Creates a copy with the given fields replaced.
  TranscriptionVadConfig copyWith({
    Object? prefixPaddingMs = unsetCopyWithValue,
    Object? silenceDurationMs = unsetCopyWithValue,
    Object? threshold = unsetCopyWithValue,
  }) {
    return TranscriptionVadConfig(
      prefixPaddingMs: prefixPaddingMs == unsetCopyWithValue
          ? this.prefixPaddingMs
          : prefixPaddingMs as int?,
      silenceDurationMs: silenceDurationMs == unsetCopyWithValue
          ? this.silenceDurationMs
          : silenceDurationMs as int?,
      threshold: threshold == unsetCopyWithValue
          ? this.threshold
          : threshold as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionVadConfig &&
          runtimeType == other.runtimeType &&
          prefixPaddingMs == other.prefixPaddingMs &&
          silenceDurationMs == other.silenceDurationMs &&
          threshold == other.threshold;

  @override
  int get hashCode =>
      Object.hash(prefixPaddingMs, silenceDurationMs, threshold);

  @override
  String toString() =>
      'TranscriptionVadConfig(prefixPaddingMs: $prefixPaddingMs, '
      'silenceDurationMs: $silenceDurationMs, threshold: $threshold)';
}

/// A transcription response.
///
/// Contains the transcribed text from the audio input.
@immutable
class TranscriptionResponse {
  /// Creates a [TranscriptionResponse].
  const TranscriptionResponse({
    required this.text,
    this.languages,
    this.logprobs,
    this.usage,
  });

  /// Creates a [TranscriptionResponse] from JSON.
  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      text: json['text'] as String,
      languages: (json['languages'] as List<dynamic>?)
          ?.map(
            (e) => TranscriptionLanguage.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      logprobs: (json['logprobs'] as List<dynamic>?)
          ?.map((e) => TranscriptionLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? TranscriptUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The transcribed text.
  final String text;

  /// The languages detected in the audio. Returned by `gpt-transcribe`. An
  /// empty list indicates that no language could be reliably detected.
  final List<TranscriptionLanguage>? languages;

  /// The log probabilities of the tokens in the transcription. Only
  /// returned with `gpt-4o-transcribe` and `gpt-4o-mini-transcribe` if
  /// `logprobs` was added to the request's `include` list.
  final List<TranscriptionLogprob>? logprobs;

  /// Token or duration usage statistics for the request.
  final TranscriptUsage? usage;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'text': text,
    if (languages != null)
      'languages': languages!.map((l) => l.toJson()).toList(),
    if (logprobs != null) 'logprobs': logprobs!.map((l) => l.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TranscriptionResponse copyWith({
    String? text,
    Object? languages = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
  }) {
    return TranscriptionResponse(
      text: text ?? this.text,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<TranscriptionLanguage>?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<TranscriptionLogprob>?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as TranscriptUsage?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listsEqual(languages, other.languages) &&
          listsEqual(logprobs, other.logprobs) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(text, listHash(languages), listHash(logprobs), usage);

  @override
  String toString() =>
      'TranscriptionResponse(${text.length} chars, '
      'languages: ${_listSummary(languages)}, '
      'logprobs: ${_listSummary(logprobs)}, usage: $usage)';
}

/// A verbose transcription response with additional metadata.
///
/// Includes word and segment-level timestamps when requested.
@immutable
class TranscriptionVerboseResponse {
  /// Creates a [TranscriptionVerboseResponse].
  const TranscriptionVerboseResponse({
    this.task,
    required this.language,
    required this.duration,
    required this.text,
    this.segments,
    this.words,
    this.usage,
  });

  /// Creates a [TranscriptionVerboseResponse] from JSON.
  factory TranscriptionVerboseResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionVerboseResponse(
      task: json['task'] as String?,
      language: json['language'] as String,
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      words: (json['words'] as List<dynamic>?)
          ?.map((e) => TranscriptionWord.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? TranscriptTextUsageDuration.fromJson(
              json['usage'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The task performed (always "transcribe" when present).
  ///
  /// Nullable because `task` is not a declared property of this response in
  /// the OpenAPI spec (nor in the official Python SDK types), even though
  /// real responses still send it — see the `x-oaiMeta` example.
  final String? task;

  /// The detected or specified language.
  final String language;

  /// The duration of the audio in seconds.
  final double duration;

  /// The full transcribed text.
  final String text;

  /// Segments with timestamps.
  final List<TranscriptionSegment>? segments;

  /// Individual words with timestamps.
  final List<TranscriptionWord>? words;

  /// Duration-based usage statistics for the request.
  final TranscriptTextUsageDuration? usage;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (task != null) 'task': task,
    'language': language,
    'duration': duration,
    'text': text,
    if (segments != null) 'segments': segments!.map((s) => s.toJson()).toList(),
    if (words != null) 'words': words!.map((w) => w.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TranscriptionVerboseResponse copyWith({
    Object? task = unsetCopyWithValue,
    String? language,
    double? duration,
    String? text,
    Object? segments = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
  }) {
    return TranscriptionVerboseResponse(
      task: task == unsetCopyWithValue ? this.task : task as String?,
      language: language ?? this.language,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      segments: segments == unsetCopyWithValue
          ? this.segments
          : segments as List<TranscriptionSegment>?,
      words: words == unsetCopyWithValue
          ? this.words
          : words as List<TranscriptionWord>?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as TranscriptTextUsageDuration?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionVerboseResponse &&
          runtimeType == other.runtimeType &&
          task == other.task &&
          language == other.language &&
          duration == other.duration &&
          text == other.text &&
          listsEqual(segments, other.segments) &&
          listsEqual(words, other.words) &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(
    task,
    language,
    duration,
    text,
    listHash(segments),
    listHash(words),
    usage,
  );

  @override
  String toString() =>
      'TranscriptionVerboseResponse(task: $task, language: $language, '
      'duration: $duration, ${text.length} chars, '
      'segments: ${_listSummary(segments)}, words: ${_listSummary(words)}, '
      'usage: $usage)';
}

/// A diarized transcription response.
///
/// Contains the combined transcript and per-speaker segment annotations.
/// Returned when `responseFormat` is [AudioResponseFormat.diarizedJson]
/// (typically with the `gpt-4o-transcribe-diarize` model).
@immutable
class TranscriptionDiarizedResponse {
  /// Creates a [TranscriptionDiarizedResponse].
  const TranscriptionDiarizedResponse({
    required this.task,
    required this.duration,
    required this.text,
    required this.segments,
    this.usage,
  });

  /// Creates a [TranscriptionDiarizedResponse] from JSON.
  factory TranscriptionDiarizedResponse.fromJson(Map<String, dynamic> json) {
    if (json['task'] != 'transcribe') {
      throw FormatException(
        'Expected task "transcribe", got "${json['task']}"',
      );
    }
    return TranscriptionDiarizedResponse(
      task: json['task'] as String,
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>)
          .map(
            (e) => TranscriptionDiarizedSegment.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
      usage: json['usage'] != null
          ? TranscriptUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The type of task that was run. Always `transcribe`.
  final String task;

  /// Duration of the input audio in seconds.
  final double duration;

  /// The concatenated transcript text for the entire audio input.
  final String text;

  /// Segments of the transcript annotated with timestamps and speaker
  /// labels.
  final List<TranscriptionDiarizedSegment> segments;

  /// Token or duration usage statistics for the request.
  final TranscriptUsage? usage;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task': task,
    'duration': duration,
    'text': text,
    'segments': segments.map((s) => s.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TranscriptionDiarizedResponse copyWith({
    String? task,
    double? duration,
    String? text,
    List<TranscriptionDiarizedSegment>? segments,
    Object? usage = unsetCopyWithValue,
  }) {
    return TranscriptionDiarizedResponse(
      task: task ?? this.task,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      segments: segments ?? this.segments,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as TranscriptUsage?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionDiarizedResponse &&
          runtimeType == other.runtimeType &&
          task == other.task &&
          duration == other.duration &&
          text == other.text &&
          listsEqual(segments, other.segments) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(task, duration, text, listHash(segments), usage);

  @override
  String toString() =>
      'TranscriptionDiarizedResponse(task: $task, duration: $duration, '
      '${text.length} chars, ${segments.length} segments, usage: $usage)';
}

/// A segment of diarized transcript text with speaker metadata.
@immutable
class TranscriptionDiarizedSegment {
  /// Creates a [TranscriptionDiarizedSegment].
  const TranscriptionDiarizedSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
  });

  /// Creates a [TranscriptionDiarizedSegment] from JSON.
  factory TranscriptionDiarizedSegment.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.segment') {
      throw FormatException(
        'Expected type "transcript.text.segment", got "${json['type']}"',
      );
    }
    return TranscriptionDiarizedSegment(
      id: json['id'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
      speaker: json['speaker'] as String,
    );
  }

  /// The type of the segment. Always `transcript.text.segment`.
  ///
  /// A fixed discriminator value, not a constructor parameter — matches the
  /// treatment of other constant/closed-value spec fields in this package.
  String get type => 'transcript.text.segment';

  /// Unique identifier for the segment.
  final String id;

  /// Start timestamp of the segment in seconds.
  final double start;

  /// End timestamp of the segment in seconds.
  final double end;

  /// Transcript text for this segment.
  final String text;

  /// Speaker label for this segment. When known speakers are provided, the
  /// label matches `knownSpeakerNames`. Otherwise speakers are labeled
  /// sequentially using capital letters (`A`, `B`, ...).
  final String speaker;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'start': start,
    'end': end,
    'text': text,
    'speaker': speaker,
  };

  /// Creates a copy with the given fields replaced.
  TranscriptionDiarizedSegment copyWith({
    String? id,
    double? start,
    double? end,
    String? text,
    String? speaker,
  }) {
    return TranscriptionDiarizedSegment(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      speaker: speaker ?? this.speaker,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionDiarizedSegment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          start == other.start &&
          end == other.end &&
          text == other.text &&
          speaker == other.speaker;

  @override
  int get hashCode => Object.hash(id, start, end, text, speaker);

  @override
  String toString() =>
      'TranscriptionDiarizedSegment(id: $id, speaker: $speaker, '
      '$start-$end, ${text.length} chars)';
}

/// A Server-Sent Event from a streaming transcription request.
///
/// Emitted by [TranscriptionsResource.createStream]. There are four
/// variants: [TranscriptTextDeltaEvent] (incremental text), the terminal
/// [TranscriptTextDoneEvent], [TranscriptTextSegmentEvent] (diarized
/// segments, only when `responseFormat` is `diarized_json`), and
/// [TranscriptTextUnknownEvent] as a forward-compatibility fallback.
@immutable
sealed class TranscriptionStreamEvent {
  const TranscriptionStreamEvent();

  /// Creates a [TranscriptionStreamEvent] from JSON, dispatching on `type`.
  factory TranscriptionStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'transcript.text.segment' => TranscriptTextSegmentEvent.fromJson(json),
      'transcript.text.delta' => TranscriptTextDeltaEvent.fromJson(json),
      'transcript.text.done' => TranscriptTextDoneEvent.fromJson(json),
      _ => TranscriptTextUnknownEvent.fromJson(json),
    };
  }

  /// The discriminator value.
  String get type;

  /// Serializes the event.
  Map<String, dynamic> toJson();
}

/// Emitted when a diarized transcription returns a completed segment with
/// speaker information.
///
/// Only emitted when streaming with `responseFormat` set to `diarized_json`.
@immutable
class TranscriptTextSegmentEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextSegmentEvent].
  const TranscriptTextSegmentEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
  });

  /// Creates a [TranscriptTextSegmentEvent] from JSON.
  factory TranscriptTextSegmentEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.segment') {
      throw FormatException(
        'Expected type "transcript.text.segment", got "${json['type']}"',
      );
    }
    return TranscriptTextSegmentEvent(
      id: json['id'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
      speaker: json['speaker'] as String,
    );
  }

  /// Unique identifier for the segment.
  final String id;

  /// Start timestamp of the segment in seconds.
  final double start;

  /// End timestamp of the segment in seconds.
  final double end;

  /// Transcript text for this segment.
  final String text;

  /// Speaker label for this segment.
  final String speaker;

  @override
  String get type => 'transcript.text.segment';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'start': start,
    'end': end,
    'text': text,
    'speaker': speaker,
  };

  /// Creates a copy with the given fields replaced.
  TranscriptTextSegmentEvent copyWith({
    String? id,
    double? start,
    double? end,
    String? text,
    String? speaker,
  }) {
    return TranscriptTextSegmentEvent(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      speaker: speaker ?? this.speaker,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextSegmentEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          start == other.start &&
          end == other.end &&
          text == other.text &&
          speaker == other.speaker;

  @override
  int get hashCode => Object.hash(id, start, end, text, speaker);

  @override
  String toString() =>
      'TranscriptTextSegmentEvent(id: $id, speaker: $speaker, $start-$end, '
      '${text.length} chars)';
}

/// Emitted for each additional text delta while streaming a transcription.
///
/// This is also the first event emitted once the transcription starts.
@immutable
class TranscriptTextDeltaEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextDeltaEvent].
  const TranscriptTextDeltaEvent({
    required this.delta,
    this.logprobs,
    this.segmentId,
  });

  /// Creates a [TranscriptTextDeltaEvent] from JSON.
  factory TranscriptTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.delta') {
      throw FormatException(
        'Expected type "transcript.text.delta", got "${json['type']}"',
      );
    }
    return TranscriptTextDeltaEvent(
      delta: json['delta'] as String,
      logprobs: (json['logprobs'] as List<dynamic>?)
          ?.map((e) => TranscriptionLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
      segmentId: json['segment_id'] as String?,
    );
  }

  /// The text delta that was additionally transcribed.
  final String delta;

  /// The log probabilities of the delta. Only included when the request's
  /// `include` list contains `logprobs`.
  final List<TranscriptionLogprob>? logprobs;

  /// Identifier of the diarized segment this delta belongs to. Only present
  /// when using `gpt-4o-transcribe-diarize`.
  final String? segmentId;

  @override
  String get type => 'transcript.text.delta';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'delta': delta,
    if (logprobs != null) 'logprobs': logprobs!.map((l) => l.toJson()).toList(),
    if (segmentId != null) 'segment_id': segmentId,
  };

  /// Creates a copy with the given fields replaced.
  TranscriptTextDeltaEvent copyWith({
    String? delta,
    Object? logprobs = unsetCopyWithValue,
    Object? segmentId = unsetCopyWithValue,
  }) {
    return TranscriptTextDeltaEvent(
      delta: delta ?? this.delta,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<TranscriptionLogprob>?,
      segmentId: segmentId == unsetCopyWithValue
          ? this.segmentId
          : segmentId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          delta == other.delta &&
          listsEqual(logprobs, other.logprobs) &&
          segmentId == other.segmentId;

  @override
  int get hashCode => Object.hash(delta, listHash(logprobs), segmentId);

  @override
  String toString() =>
      'TranscriptTextDeltaEvent(delta: $delta, '
      'logprobs: ${_listSummary(logprobs)}, segmentId: $segmentId)';
}

/// Emitted when a streaming transcription is complete.
///
/// Contains the complete transcription text.
@immutable
class TranscriptTextDoneEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextDoneEvent].
  const TranscriptTextDoneEvent({
    required this.text,
    this.languages,
    this.logprobs,
    this.usage,
  });

  /// Creates a [TranscriptTextDoneEvent] from JSON.
  factory TranscriptTextDoneEvent.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'transcript.text.done') {
      throw FormatException(
        'Expected type "transcript.text.done", got "${json['type']}"',
      );
    }
    return TranscriptTextDoneEvent(
      text: json['text'] as String,
      languages: (json['languages'] as List<dynamic>?)
          ?.map(
            (e) => TranscriptionLanguage.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      logprobs: (json['logprobs'] as List<dynamic>?)
          ?.map((e) => TranscriptionLogprob.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] != null
          ? TranscriptTextUsageTokens.fromJson(
              json['usage'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The text that was transcribed.
  final String text;

  /// The languages detected in the audio. Returned by `gpt-transcribe`. An
  /// empty list indicates that no language could be reliably detected.
  final List<TranscriptionLanguage>? languages;

  /// The log probabilities of the individual tokens in the transcription.
  /// Only included when the request's `include` list contains `logprobs`.
  final List<TranscriptionLogprob>? logprobs;

  /// Token usage statistics for the request.
  final TranscriptTextUsageTokens? usage;

  @override
  String get type => 'transcript.text.done';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    if (languages != null)
      'languages': languages!.map((l) => l.toJson()).toList(),
    if (logprobs != null) 'logprobs': logprobs!.map((l) => l.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TranscriptTextDoneEvent copyWith({
    String? text,
    Object? languages = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
  }) {
    return TranscriptTextDoneEvent(
      text: text ?? this.text,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<TranscriptionLanguage>?,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<TranscriptionLogprob>?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as TranscriptTextUsageTokens?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDoneEvent &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          listsEqual(languages, other.languages) &&
          listsEqual(logprobs, other.logprobs) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(text, listHash(languages), listHash(logprobs), usage);

  @override
  String toString() =>
      'TranscriptTextDoneEvent(${text.length} chars, '
      'languages: ${_listSummary(languages)}, '
      'logprobs: ${_listSummary(logprobs)}, usage: $usage)';
}

/// Forward-compatibility fallback for unrecognized transcription stream
/// events. Preserves the raw JSON so round-trip re-serialization does not
/// drop forward-compatible fields.
@immutable
class TranscriptTextUnknownEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextUnknownEvent].
  const TranscriptTextUnknownEvent({
    required this.rawType,
    required this.rawJson,
  });

  /// Creates a [TranscriptTextUnknownEvent] from JSON.
  factory TranscriptTextUnknownEvent.fromJson(Map<String, dynamic> json) {
    return TranscriptTextUnknownEvent(
      rawType: json['type'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// The unknown `type` value from the server.
  final String rawType;

  /// The original JSON payload (preserved verbatim).
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUnknownEvent &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'TranscriptTextUnknownEvent(type: $rawType)';
}

/// Token or duration usage statistics for a transcription request.
///
/// A synthetic union — the spec has no single named schema for this anyOf,
/// so this sealed type dispatches on `type` the same way a spec-declared
/// discriminated union would. Used directly (not via this union) for
/// [TranscriptionVerboseResponse.usage] ([TranscriptTextUsageDuration] only)
/// and [TranscriptTextDoneEvent.usage] ([TranscriptTextUsageTokens] only).
@immutable
sealed class TranscriptUsage {
  const TranscriptUsage();

  /// Creates a [TranscriptUsage] from JSON, dispatching on `type`.
  factory TranscriptUsage.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'tokens' => TranscriptTextUsageTokens.fromJson(json),
      'duration' => TranscriptTextUsageDuration.fromJson(json),
      _ => TranscriptUsageUnknown.fromJson(json),
    };
  }

  /// The discriminator value.
  String get type;

  /// Serializes the usage object.
  Map<String, dynamic> toJson();
}

/// Usage statistics for models billed by token usage.
@immutable
class TranscriptTextUsageTokens extends TranscriptUsage {
  /// Creates a [TranscriptTextUsageTokens].
  const TranscriptTextUsageTokens({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.inputTokenDetails,
  });

  /// Creates a [TranscriptTextUsageTokens] from JSON.
  factory TranscriptTextUsageTokens.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'tokens') {
      throw FormatException('Expected type "tokens", got "${json['type']}"');
    }
    return TranscriptTextUsageTokens(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      inputTokenDetails: json['input_token_details'] != null
          ? TranscriptUsageInputTokenDetails.fromJson(
              json['input_token_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Number of input tokens billed for this request.
  final int inputTokens;

  /// Number of output tokens generated.
  final int outputTokens;

  /// Total number of tokens used (input + output).
  final int totalTokens;

  /// Details about the input tokens billed for this request.
  final TranscriptUsageInputTokenDetails? inputTokenDetails;

  @override
  String get type => 'tokens';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'input_tokens': inputTokens,
    'output_tokens': outputTokens,
    'total_tokens': totalTokens,
    if (inputTokenDetails != null)
      'input_token_details': inputTokenDetails!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TranscriptTextUsageTokens copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
    Object? inputTokenDetails = unsetCopyWithValue,
  }) {
    return TranscriptTextUsageTokens(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      inputTokenDetails: inputTokenDetails == unsetCopyWithValue
          ? this.inputTokenDetails
          : inputTokenDetails as TranscriptUsageInputTokenDetails?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUsageTokens &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          totalTokens == other.totalTokens &&
          inputTokenDetails == other.inputTokenDetails;

  @override
  int get hashCode =>
      Object.hash(inputTokens, outputTokens, totalTokens, inputTokenDetails);

  @override
  String toString() =>
      'TranscriptTextUsageTokens(input: $inputTokens, output: '
      '$outputTokens, total: $totalTokens, '
      'inputTokenDetails: $inputTokenDetails)';
}

/// Details about the input tokens billed for a token-based transcription
/// request. Inline in the spec (no dedicated schema name).
@immutable
class TranscriptUsageInputTokenDetails {
  /// Creates a [TranscriptUsageInputTokenDetails].
  const TranscriptUsageInputTokenDetails({this.audioTokens, this.textTokens});

  /// Creates a [TranscriptUsageInputTokenDetails] from JSON.
  factory TranscriptUsageInputTokenDetails.fromJson(Map<String, dynamic> json) {
    return TranscriptUsageInputTokenDetails(
      audioTokens: json['audio_tokens'] as int?,
      textTokens: json['text_tokens'] as int?,
    );
  }

  /// Number of audio tokens billed for this request.
  final int? audioTokens;

  /// Number of text tokens billed for this request.
  final int? textTokens;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (audioTokens != null) 'audio_tokens': audioTokens,
    if (textTokens != null) 'text_tokens': textTokens,
  };

  /// Creates a copy with the given fields replaced.
  TranscriptUsageInputTokenDetails copyWith({
    Object? audioTokens = unsetCopyWithValue,
    Object? textTokens = unsetCopyWithValue,
  }) {
    return TranscriptUsageInputTokenDetails(
      audioTokens: audioTokens == unsetCopyWithValue
          ? this.audioTokens
          : audioTokens as int?,
      textTokens: textTokens == unsetCopyWithValue
          ? this.textTokens
          : textTokens as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptUsageInputTokenDetails &&
          runtimeType == other.runtimeType &&
          audioTokens == other.audioTokens &&
          textTokens == other.textTokens;

  @override
  int get hashCode => Object.hash(audioTokens, textTokens);

  @override
  String toString() =>
      'TranscriptUsageInputTokenDetails(audioTokens: $audioTokens, '
      'textTokens: $textTokens)';
}

/// Usage statistics for models billed by audio input duration.
@immutable
class TranscriptTextUsageDuration extends TranscriptUsage {
  /// Creates a [TranscriptTextUsageDuration].
  const TranscriptTextUsageDuration({required this.seconds});

  /// Creates a [TranscriptTextUsageDuration] from JSON.
  factory TranscriptTextUsageDuration.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'duration') {
      throw FormatException('Expected type "duration", got "${json['type']}"');
    }
    return TranscriptTextUsageDuration(
      seconds: (json['seconds'] as num).toDouble(),
    );
  }

  /// Duration of the input audio in seconds.
  final double seconds;

  @override
  String get type => 'duration';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'seconds': seconds};

  /// Creates a copy with the given fields replaced.
  TranscriptTextUsageDuration copyWith({double? seconds}) =>
      TranscriptTextUsageDuration(seconds: seconds ?? this.seconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUsageDuration &&
          runtimeType == other.runtimeType &&
          seconds == other.seconds;

  @override
  int get hashCode => seconds.hashCode;

  @override
  String toString() => 'TranscriptTextUsageDuration(seconds: $seconds)';
}

/// Forward-compatibility fallback for an unrecognized [TranscriptUsage]
/// variant. Preserves the raw JSON so round-trip re-serialization does not
/// drop forward-compatible fields.
@immutable
class TranscriptUsageUnknown extends TranscriptUsage {
  /// Creates a [TranscriptUsageUnknown].
  const TranscriptUsageUnknown({required this.rawType, required this.rawJson});

  /// Creates a [TranscriptUsageUnknown] from JSON.
  factory TranscriptUsageUnknown.fromJson(Map<String, dynamic> json) {
    return TranscriptUsageUnknown(
      rawType: json['type'] as String? ?? '',
      rawJson: Map<String, dynamic>.from(json),
    );
  }

  /// The unknown `type` value from the server.
  final String rawType;

  /// The original JSON payload (preserved verbatim).
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawType;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptUsageUnknown &&
          runtimeType == other.runtimeType &&
          rawType == other.rawType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(rawType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'TranscriptUsageUnknown(type: $rawType)';
}

/// A language detected in transcribed audio.
@immutable
class TranscriptionLanguage {
  /// Creates a [TranscriptionLanguage].
  const TranscriptionLanguage({required this.code});

  /// Creates a [TranscriptionLanguage] from JSON.
  factory TranscriptionLanguage.fromJson(Map<String, dynamic> json) {
    return TranscriptionLanguage(code: json['code'] as String);
  }

  /// The code of the language detected in the audio.
  final String code;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code};

  /// Creates a copy with the given fields replaced.
  TranscriptionLanguage copyWith({String? code}) =>
      TranscriptionLanguage(code: code ?? this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'TranscriptionLanguage(code: $code)';
}

/// The log probability of a single transcribed token.
///
/// Inline in the spec (no dedicated schema name) — one reusable class
/// covers the three occurrences ([TranscriptionResponse.logprobs],
/// [TranscriptTextDeltaEvent.logprobs], [TranscriptTextDoneEvent.logprobs]).
/// All fields are nullable, matching the official Python SDK. The spec is
/// inconsistent about `bytes`' item type (`number` in one inline
/// definition, `integer` in another), so it is typed `List<num>?` here.
@immutable
class TranscriptionLogprob {
  /// Creates a [TranscriptionLogprob].
  const TranscriptionLogprob({this.token, this.bytes, this.logprob});

  /// Creates a [TranscriptionLogprob] from JSON.
  factory TranscriptionLogprob.fromJson(Map<String, dynamic> json) {
    return TranscriptionLogprob(
      token: json['token'] as String?,
      bytes: (json['bytes'] as List<dynamic>?)?.map((e) => e as num).toList(),
      logprob: (json['logprob'] as num?)?.toDouble(),
    );
  }

  /// The token in the transcription.
  final String? token;

  /// The bytes that were used to generate the log probability.
  final List<num>? bytes;

  /// The log probability of the token.
  final double? logprob;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (token != null) 'token': token,
    if (bytes != null) 'bytes': bytes,
    if (logprob != null) 'logprob': logprob,
  };

  /// Creates a copy with the given fields replaced.
  TranscriptionLogprob copyWith({
    Object? token = unsetCopyWithValue,
    Object? bytes = unsetCopyWithValue,
    Object? logprob = unsetCopyWithValue,
  }) {
    return TranscriptionLogprob(
      token: token == unsetCopyWithValue ? this.token : token as String?,
      bytes: bytes == unsetCopyWithValue ? this.bytes : bytes as List<num>?,
      logprob: logprob == unsetCopyWithValue
          ? this.logprob
          : logprob as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionLogprob &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          listsEqual(bytes, other.bytes) &&
          logprob == other.logprob;

  @override
  int get hashCode => Object.hash(token, listHash(bytes), logprob);

  @override
  String toString() => 'TranscriptionLogprob(token: $token, logprob: $logprob)';
}

/// A segment in a verbose transcription response.
@immutable
class TranscriptionSegment {
  /// Creates a [TranscriptionSegment].
  const TranscriptionSegment({
    required this.id,
    required this.seek,
    required this.start,
    required this.end,
    required this.text,
    required this.tokens,
    required this.temperature,
    required this.avgLogprob,
    required this.compressionRatio,
    required this.noSpeechProb,
  });

  /// Creates a [TranscriptionSegment] from JSON.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] as int,
      seek: json['seek'] as int,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
      tokens: (json['tokens'] as List<dynamic>).cast<int>(),
      temperature: (json['temperature'] as num).toDouble(),
      avgLogprob: (json['avg_logprob'] as num).toDouble(),
      compressionRatio: (json['compression_ratio'] as num).toDouble(),
      noSpeechProb: (json['no_speech_prob'] as num).toDouble(),
    );
  }

  /// The segment ID.
  final int id;

  /// Seek offset of the audio.
  final int seek;

  /// Start time in seconds.
  final double start;

  /// End time in seconds.
  final double end;

  /// The text content of this segment.
  final String text;

  /// Token IDs for this segment.
  final List<int> tokens;

  /// Temperature used for this segment.
  final double temperature;

  /// Average log probability.
  final double avgLogprob;

  /// Compression ratio.
  final double compressionRatio;

  /// Probability of no speech.
  final double noSpeechProb;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'seek': seek,
    'start': start,
    'end': end,
    'text': text,
    'tokens': tokens,
    'temperature': temperature,
    'avg_logprob': avgLogprob,
    'compression_ratio': compressionRatio,
    'no_speech_prob': noSpeechProb,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          seek == other.seek &&
          start == other.start &&
          end == other.end &&
          text == other.text &&
          listsEqual(tokens, other.tokens) &&
          temperature == other.temperature &&
          avgLogprob == other.avgLogprob &&
          compressionRatio == other.compressionRatio &&
          noSpeechProb == other.noSpeechProb;

  @override
  int get hashCode => Object.hash(
    id,
    seek,
    start,
    end,
    text,
    listHash(tokens),
    temperature,
    avgLogprob,
    compressionRatio,
    noSpeechProb,
  );

  @override
  String toString() => 'TranscriptionSegment(id: $id, $start-$end)';
}

/// A word with timing information.
@immutable
class TranscriptionWord {
  /// Creates a [TranscriptionWord].
  const TranscriptionWord({
    required this.word,
    required this.start,
    required this.end,
  });

  /// Creates a [TranscriptionWord] from JSON.
  factory TranscriptionWord.fromJson(Map<String, dynamic> json) {
    return TranscriptionWord(
      word: json['word'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }

  /// The word text.
  final String word;

  /// Start time in seconds.
  final double start;

  /// End time in seconds.
  final double end;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'word': word, 'start': start, 'end': end};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionWord &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(word, start, end);

  @override
  String toString() => 'TranscriptionWord($word, $start-$end)';
}
