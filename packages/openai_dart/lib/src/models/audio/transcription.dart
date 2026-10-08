import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_json_helpers.dart';
import 'file_audio_json_helpers.dart';

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
  TranscriptionRequest({
    required Uint8List file,
    required this.filename,
    required this.model,
    this.fileContentType,
    this.chunkingStrategy,
    List<TranscriptionInclude>? include,
    List<String>? keywords,
    List<String>? knownSpeakerNames,
    List<String>? knownSpeakerReferences,
    this.language,
    List<String>? languages,
    this.prompt,
    this.responseFormat,
    this.stream,
    this.temperature,
    List<TimestampGranularity>? timestampGranularities,
  }) : file = Uint8List.fromList(file).asUnmodifiableView(),
       include = immutableFileAudioList(include),
       keywords = immutableFileAudioList(keywords),
       knownSpeakerNames = immutableFileAudioList(knownSpeakerNames),
       knownSpeakerReferences = immutableFileAudioList(knownSpeakerReferences),
       languages = immutableFileAudioList(languages),
       timestampGranularities = immutableFileAudioList(timestampGranularities);

  /// The audio file to transcribe.
  ///
  /// Supported formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.
  final Uint8List file;

  /// The filename of the audio file.
  ///
  /// Provide enough format metadata for identification. An extension-bearing
  /// filename and an appropriate [fileContentType] are recommended.
  final String filename;

  /// Optional MIME metadata for the file part, separate from API form fields.
  final String? fileContentType;

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
  /// such as `data:<mediaType>;base64,<data>`. Percent-encoded data URLs are
  /// also accepted; raw Base64 without the `data:` prefix is invalid. The
  /// service validates supported audio formats and the 2–10 second duration.
  /// Up to 4 references are supported; original URL spelling is preserved.
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

  /// Validates writable admission before authentication or multipart dispatch.
  ///
  /// Unset/null chunking and stream values are omitted; false remains explicit.
  /// Model-specific guide restrictions apply only to `gpt-transcribe`.
  void validate() {
    if (responseFormat == AudioResponseFormat.unknown) {
      throw const FormatException(
        'TranscriptionRequest.responseFormat: unsupported writable value',
      );
    }
    if (include?.contains(TranscriptionInclude.unknown) ?? false) {
      throw const FormatException(
        'TranscriptionRequest.include: unsupported writable value',
      );
    }
    validateFileAudioTemperature(
      temperature,
      'TranscriptionRequest.temperature',
    );
    if (languages != null && languages!.isEmpty) {
      throw const FormatException(
        'TranscriptionRequest.languages: expected at least one item',
      );
    }
    for (final collection in [knownSpeakerNames, knownSpeakerReferences]) {
      if (collection != null && collection.length > 4) {
        throw const FormatException(
          'TranscriptionRequest.knownSpeakers: expected at most four items',
        );
      }
    }
    (knownSpeakerReferences ?? const <String>[]).forEach(
      validateFileAudioDataUrl,
    );
    if (model == 'gpt-transcribe') {
      if (language != null) {
        throw const FormatException(
          'TranscriptionRequest.language: use languages with gpt-transcribe',
        );
      }
      if (keywords?.any((keyword) => keyword.contains(RegExp(r'[<>\r\n]'))) ??
          false) {
        throw const FormatException(
          'TranscriptionRequest.keywords: angle brackets and line breaks are unsupported by gpt-transcribe',
        );
      }
    }
    chunkingStrategy?.toFormFields();
  }

  /// Creates a copy with the given fields replaced.
  TranscriptionRequest copyWith({
    Uint8List? file,
    String? filename,
    String? model,
    Object? fileContentType = unsetCopyWithValue,
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
      fileContentType: fileContentType == unsetCopyWithValue
          ? this.fileContentType
          : fileContentType as String?,
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
          : copyFileAudioNumber(
              temperature,
              'TranscriptionRequest.temperature',
            ),
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
          fileContentType == other.fileContentType &&
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
    fileContentType,
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
      'TranscriptionRequest(file: ${file.length} bytes, filename: [REDACTED], '
      'fileContentType: ${fileAudioPresence(fileContentType)}, model: [REDACTED], chunkingStrategy: $chunkingStrategy, '
      'include: ${_listSummary(include)}, keywords: ${_listSummary(keywords)}, '
      'knownSpeakerNames: ${_listSummary(knownSpeakerNames)}, '
      'knownSpeakerReferences: ${_listSummary(knownSpeakerReferences)}, '
      'language: ${fileAudioPresence(language)}, languages: ${_listSummary(languages)}, '
      'prompt: ${fileAudioPresence(prompt)}, responseFormat: $responseFormat, stream: $stream, '
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
      orElse: () => throw const FormatException(
        'TimestampGranularity: unsupported value',
      ),
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
/// Request-only; [fromJson] admits the exact writable union with no unknown
/// fallback. [toFormFields] produces the
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

  /// Parses the exact writable string/object union, without a future fallback.
  factory TranscriptionChunkingStrategy.fromJson(Object? json) {
    if (json == 'auto') return const TranscriptionChunkingStrategy.auto();
    return TranscriptionChunkingStrategy.serverVad(
      TranscriptionVadConfig.fromJson(
        requireFileAudioMap(json, 'TranscriptionChunkingStrategy'),
      ),
    );
  }

  /// The multipart form fields that encode this strategy.
  Map<String, String> toFormFields();

  /// The canonical writable union value; defaults are never materialized.
  Object toJson();
}

/// Automatically choose chunking parameters based on the audio.
@immutable
class TranscriptionChunkingStrategyAuto extends TranscriptionChunkingStrategy {
  /// Creates a [TranscriptionChunkingStrategyAuto].
  const TranscriptionChunkingStrategyAuto();

  @override
  Map<String, String> toFormFields() => const {'chunking_strategy': 'auto'};

  @override
  String toJson() => 'auto';

  /// Copies this fieldless literal variant.
  TranscriptionChunkingStrategyAuto copyWith() =>
      const TranscriptionChunkingStrategyAuto();

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
  Map<String, String> toFormFields() {
    config.validate();
    return {
      'chunking_strategy[type]': 'server_vad',
      if (config.prefixPaddingMs != null)
        'chunking_strategy[prefix_padding_ms]': config.prefixPaddingMs
            .toString(),
      if (config.silenceDurationMs != null)
        'chunking_strategy[silence_duration_ms]': config.silenceDurationMs
            .toString(),
      if (config.threshold != null)
        'chunking_strategy[threshold]': config.threshold.toString(),
    };
  }

  @override
  Map<String, dynamic> toJson() => config.toJson();

  /// Copies the typed VAD configuration.
  TranscriptionChunkingStrategyServerVad copyWith({
    TranscriptionVadConfig? config,
  }) => TranscriptionChunkingStrategyServerVad(config ?? this.config);

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

  /// Parses the closed canonical VAD configuration.
  factory TranscriptionVadConfig.fromJson(Map<String, dynamic> json) {
    const fields = {
      'type',
      'prefix_padding_ms',
      'silence_duration_ms',
      'threshold',
    };
    requireClosedAudioJson(json, fields, 'TranscriptionVadConfig');
    requireFileAudioType(json, 'type', 'server_vad', 'TranscriptionVadConfig');
    return TranscriptionVadConfig(
      prefixPaddingMs: optionalFileAudio(
        json,
        'prefix_padding_ms',
        'TranscriptionVadConfig',
        requireAudioInt,
      ),
      silenceDurationMs: optionalFileAudio(
        json,
        'silence_duration_ms',
        'TranscriptionVadConfig',
        requireAudioInt,
      ),
      threshold: optionalFileAudio(
        json,
        'threshold',
        'TranscriptionVadConfig',
        requireAudioNumber,
      ),
    );
  }

  /// Validates finite numeric fields without inventing schema bounds/defaults.
  void validate() {
    if (prefixPaddingMs != null) {
      requireAudioInt(
        prefixPaddingMs,
        'TranscriptionVadConfig.prefix_padding_ms',
      );
    }
    if (silenceDurationMs != null) {
      requireAudioInt(
        silenceDurationMs,
        'TranscriptionVadConfig.silence_duration_ms',
      );
    }
    if (threshold != null) {
      requireAudioNumber(threshold, 'TranscriptionVadConfig.threshold');
    }
  }

  /// Serializes the fixed discriminator and explicitly supplied fields only.
  Map<String, dynamic> toJson() {
    validate();
    return {
      'type': 'server_vad',
      if (prefixPaddingMs != null) 'prefix_padding_ms': prefixPaddingMs,
      if (silenceDurationMs != null) 'silence_duration_ms': silenceDurationMs,
      if (threshold != null) 'threshold': threshold,
    };
  }

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
          : copyFileAudioNumber(threshold, 'TranscriptionVadConfig.threshold'),
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

/// Typed TranscriptionResponse fields and immutable received future metadata.
@immutable
class TranscriptionResponse {
  /// Creates a [TranscriptionResponse] with owned snapshots.
  TranscriptionResponse({
    required this.text,
    List<TranscriptionLanguage>? languages,
    List<TranscriptionLogprob>? logprobs,
    this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : languages = immutableFileAudioList(languages),
       logprobs = immutableFileAudioList(logprobs),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionResponse',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'text', 'languages', 'logprobs', 'usage'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionResponse',
      knownKeys: _fields,
    );
    return TranscriptionResponse(
      text: requireFileAudioString(raw['text'], 'TranscriptionResponse.text'),
      languages: optionalFileAudio(
        raw,
        'languages',
        'TranscriptionResponse',
        (value, context) => requireFileAudioList<TranscriptionLanguage>(
          value,
          context,
          (value, context) => TranscriptionLanguage.fromJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      logprobs: optionalFileAudio(
        raw,
        'logprobs',
        'TranscriptionResponse',
        (value, context) => requireFileAudioList<TranscriptionLogprob>(
          value,
          context,
          (value, context) => TranscriptionLogprob.fromJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      usage: optionalFileAudio(
        raw,
        'usage',
        'TranscriptionResponse',
        (value, context) =>
            TranscriptUsage.fromJson(requireFileAudioMap(value, context)),
      ),
      rawJson: raw,
    );
  }

  /// The text field.
  final String text;

  /// The languages field when present.
  final List<TranscriptionLanguage>? languages;

  /// The logprobs field when present.
  final List<TranscriptionLogprob>? logprobs;

  /// The usage field when present.
  final TranscriptUsage? usage;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'text': text,
      if (languages != null)
        'languages': mergeFileAudioChildren(
          rawJson['languages'],
          languages!.map((value) => value.toJson()).toList(),
          const {'code'},
        ),
      if (logprobs != null)
        'logprobs': mergeFileAudioChildren(
          rawJson['logprobs'],
          logprobs!.map((value) => value.toJson()).toList(),
          const {'token', 'bytes', 'logprob'},
        ),
      if (usage != null)
        'usage': mergeFileAudioChild(
          rawJson['usage'],
          usage!.toJson(),
          fileAudioUsageFields(usage!.toJson()),
        ),
    }, 'TranscriptionResponse');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionResponse copyWith({
    String? text,
    Object? languages = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
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
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (languages != unsetCopyWithValue) 'languages',
        if (logprobs != unsetCopyWithValue) 'logprobs',
        if (usage != unsetCopyWithValue) 'usage',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionResponse(text: ${fileAudioPresence(text)}, languages: ${fileAudioListSummary(languages)}, logprobs: ${fileAudioListSummary(logprobs)}, usage: $usage, rawJson: [REDACTED])';
}

/// Transcription language, duration and text with optional word/segment timings.
///
/// [task] is optional legacy metadata. Parsed and constructed collections own
/// immutable snapshots; received future JSON remains available in [rawJson].
@immutable
class TranscriptionVerboseResponse {
  /// Creates a [TranscriptionVerboseResponse] with owned snapshots.
  TranscriptionVerboseResponse({
    this.task,
    required this.language,
    required this.duration,
    required this.text,
    List<TranscriptionSegment>? segments,
    List<TranscriptionWord>? words,
    this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : segments = immutableFileAudioList(segments),
       words = immutableFileAudioList(words),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionVerboseResponse',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'language',
    'duration',
    'text',
    'segments',
    'words',
    'usage',
    'task',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionVerboseResponse.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionVerboseResponse',
      knownKeys: _fields,
    );
    return TranscriptionVerboseResponse(
      task: optionalFileAudio(
        raw,
        'task',
        'TranscriptionVerboseResponse',
        requireFileAudioString,
      ),
      language: requireFileAudioString(
        raw['language'],
        'TranscriptionVerboseResponse.language',
      ),
      duration: requireAudioNumber(
        raw['duration'],
        'TranscriptionVerboseResponse.duration',
      ),
      text: requireFileAudioString(
        raw['text'],
        'TranscriptionVerboseResponse.text',
      ),
      segments: optionalFileAudio(
        raw,
        'segments',
        'TranscriptionVerboseResponse',
        (value, context) => requireFileAudioList<TranscriptionSegment>(
          value,
          context,
          (value, context) => TranscriptionSegment.fromJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      words: optionalFileAudio(
        raw,
        'words',
        'TranscriptionVerboseResponse',
        (value, context) => requireFileAudioList<TranscriptionWord>(
          value,
          context,
          (value, context) =>
              TranscriptionWord.fromJson(requireFileAudioMap(value, context)),
        ),
      ),
      usage: optionalFileAudio(
        raw,
        'usage',
        'TranscriptionVerboseResponse',
        (value, context) => TranscriptTextUsageDuration.fromJson(
          requireFileAudioMap(value, context),
        ),
      ),
      rawJson: raw,
    );
  }

  /// Optional legacy task metadata; absent in the canonical response.
  final String? task;

  /// The language field.
  final String language;

  /// The duration field.
  final double duration;

  /// The text field.
  final String text;

  /// The segments field when present.
  final List<TranscriptionSegment>? segments;

  /// The words field when present.
  final List<TranscriptionWord>? words;

  /// The usage field when present.
  final TranscriptTextUsageDuration? usage;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      if (task != null) 'task': task,
      'language': language,
      'duration': duration,
      'text': text,
      if (segments != null)
        'segments': mergeFileAudioChildren(
          rawJson['segments'],
          segments!.map((value) => value.toJson()).toList(),
          const {
            'id',
            'seek',
            'start',
            'end',
            'text',
            'tokens',
            'temperature',
            'avg_logprob',
            'compression_ratio',
            'no_speech_prob',
          },
        ),
      if (words != null)
        'words': mergeFileAudioChildren(
          rawJson['words'],
          words!.map((value) => value.toJson()).toList(),
          const {'word', 'start', 'end'},
        ),
      if (usage != null)
        'usage': mergeFileAudioChild(rawJson['usage'], usage!.toJson(), const {
          'seconds',
          'type',
        }),
    }, 'TranscriptionVerboseResponse');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionVerboseResponse copyWith({
    Object? task = unsetCopyWithValue,
    String? language,
    double? duration,
    String? text,
    Object? segments = unsetCopyWithValue,
    Object? words = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
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
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (segments != unsetCopyWithValue) 'segments',
        if (words != unsetCopyWithValue) 'words',
        if (usage != unsetCopyWithValue) 'usage',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionVerboseResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionVerboseResponse(task: ${fileAudioPresence(task)}, language: ${fileAudioPresence(language)}, duration: $duration, text: ${fileAudioPresence(text)}, segments: ${fileAudioListSummary(segments)}, words: ${fileAudioListSummary(words)}, usage: $usage, rawJson: [REDACTED])';
}

/// Typed TranscriptionDiarizedResponse fields and immutable received future metadata.
@immutable
class TranscriptionDiarizedResponse {
  /// Creates a [TranscriptionDiarizedResponse] with owned snapshots.
  TranscriptionDiarizedResponse({
    required this.task,
    required this.duration,
    required this.text,
    required List<TranscriptionDiarizedSegment> segments,
    this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : segments = List.unmodifiable(segments),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionDiarizedResponse',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'task',
    'duration',
    'text',
    'segments',
    'usage',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionDiarizedResponse.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionDiarizedResponse',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'task',
      'transcribe',
      'TranscriptionDiarizedResponse',
    );
    return TranscriptionDiarizedResponse(
      task: requireFileAudioString(
        raw['task'],
        'TranscriptionDiarizedResponse.task',
      ),
      duration: requireAudioNumber(
        raw['duration'],
        'TranscriptionDiarizedResponse.duration',
      ),
      text: requireFileAudioString(
        raw['text'],
        'TranscriptionDiarizedResponse.text',
      ),
      segments: requireFileAudioList<TranscriptionDiarizedSegment>(
        raw['segments'],
        'TranscriptionDiarizedResponse.segments',
        (value, context) => TranscriptionDiarizedSegment.fromJson(
          requireFileAudioMap(value, context),
        ),
      ),
      usage: optionalFileAudio(
        raw,
        'usage',
        'TranscriptionDiarizedResponse',
        (value, context) =>
            TranscriptUsage.fromJson(requireFileAudioMap(value, context)),
      ),
      rawJson: raw,
    );
  }

  /// The task field.
  final String task;

  /// The duration field.
  final double duration;

  /// The text field.
  final String text;

  /// The segments field.
  final List<TranscriptionDiarizedSegment> segments;

  /// The usage field when present.
  final TranscriptUsage? usage;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    if (task != 'transcribe') {
      throw const FormatException(
        'TranscriptionDiarizedResponse.task: unexpected discriminator',
      );
    }
    return fileAudioJson(rawJson, _fields, {
      'task': task,
      'duration': duration,
      'text': text,
      'segments': mergeFileAudioChildren(
        rawJson['segments'],
        segments.map((value) => value.toJson()).toList(),
        const {'id', 'start', 'end', 'text', 'speaker', 'type'},
      ),
      if (usage != null)
        'usage': mergeFileAudioChild(
          rawJson['usage'],
          usage!.toJson(),
          fileAudioUsageFields(usage!.toJson()),
        ),
    }, 'TranscriptionDiarizedResponse');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionDiarizedResponse copyWith({
    String? task,
    double? duration,
    String? text,
    List<TranscriptionDiarizedSegment>? segments,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionDiarizedResponse(
      task: task ?? this.task,
      duration: duration ?? this.duration,
      text: text ?? this.text,
      segments: segments ?? this.segments,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as TranscriptUsage?,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (segments != null) 'segments',
        if (usage != unsetCopyWithValue) 'usage',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionDiarizedResponse &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionDiarizedResponse(task: ${fileAudioPresence(task)}, duration: $duration, text: ${fileAudioPresence(text)}, segments: ${fileAudioListSummary(segments)}, usage: $usage, rawJson: [REDACTED])';
}

/// Typed TranscriptionDiarizedSegment fields and immutable received future metadata.
@immutable
class TranscriptionDiarizedSegment {
  /// Creates a [TranscriptionDiarizedSegment]; scalar const construction remains available.
  const TranscriptionDiarizedSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
  }) : rawJson = const {};

  TranscriptionDiarizedSegment._({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionDiarizedSegment',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'id',
    'start',
    'end',
    'text',
    'speaker',
    'type',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionDiarizedSegment.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionDiarizedSegment',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'type',
      'transcript.text.segment',
      'TranscriptionDiarizedSegment',
    );
    return TranscriptionDiarizedSegment._(
      id: requireFileAudioString(raw['id'], 'TranscriptionDiarizedSegment.id'),
      start: requireAudioNumber(
        raw['start'],
        'TranscriptionDiarizedSegment.start',
      ),
      end: requireAudioNumber(raw['end'], 'TranscriptionDiarizedSegment.end'),
      text: requireFileAudioString(
        raw['text'],
        'TranscriptionDiarizedSegment.text',
      ),
      speaker: requireFileAudioString(
        raw['speaker'],
        'TranscriptionDiarizedSegment.speaker',
      ),
      rawJson: raw,
    );
  }

  /// The id field.
  final String id;

  /// The start field.
  final double start;

  /// The end field.
  final double end;

  /// The text field.
  final String text;

  /// The speaker field.
  final String speaker;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// The fixed wire discriminator.
  String get type => 'transcript.text.segment';

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'id': id,
      'start': start,
      'end': end,
      'text': text,
      'speaker': speaker,
    }, 'TranscriptionDiarizedSegment');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionDiarizedSegment copyWith({
    String? id,
    double? start,
    double? end,
    String? text,
    String? speaker,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionDiarizedSegment._(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      speaker: speaker ?? this.speaker,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionDiarizedSegment &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionDiarizedSegment(type: $type, id: ${fileAudioPresence(id)}, start: $start, end: $end, text: ${fileAudioPresence(text)}, speaker: ${fileAudioPresence(speaker)}, rawJson: [REDACTED])';
}

/// Typed received variants; unknown strings preserve future metadata.
@immutable
sealed class TranscriptionStreamEvent {
  const TranscriptionStreamEvent();
  factory TranscriptionStreamEvent.fromJson(Map<String, dynamic> json) {
    final type = requireFileAudioString(
      json['type'],
      'TranscriptionStreamEvent.type',
    );
    return switch (type) {
      'transcript.text.delta' => TranscriptTextDeltaEvent.fromJson(json),
      'transcript.text.done' => TranscriptTextDoneEvent.fromJson(json),
      'transcript.text.segment' => TranscriptTextSegmentEvent.fromJson(json),
      _ => TranscriptTextUnknownEvent.fromJson(json),
    };
  }

  /// The validated wire discriminator.
  String get type;

  /// Serializes current typed values and received metadata.
  Map<String, dynamic> toJson();
}

/// Typed TranscriptTextSegmentEvent fields and immutable received future metadata.
@immutable
class TranscriptTextSegmentEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextSegmentEvent]; scalar const construction remains available.
  const TranscriptTextSegmentEvent({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
  }) : rawJson = const {};

  TranscriptTextSegmentEvent._({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.speaker,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptTextSegmentEvent',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'id',
    'start',
    'end',
    'text',
    'speaker',
    'type',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptTextSegmentEvent.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptTextSegmentEvent',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'type',
      'transcript.text.segment',
      'TranscriptTextSegmentEvent',
    );
    return TranscriptTextSegmentEvent._(
      id: requireFileAudioString(raw['id'], 'TranscriptTextSegmentEvent.id'),
      start: requireAudioNumber(
        raw['start'],
        'TranscriptTextSegmentEvent.start',
      ),
      end: requireAudioNumber(raw['end'], 'TranscriptTextSegmentEvent.end'),
      text: requireFileAudioString(
        raw['text'],
        'TranscriptTextSegmentEvent.text',
      ),
      speaker: requireFileAudioString(
        raw['speaker'],
        'TranscriptTextSegmentEvent.speaker',
      ),
      rawJson: raw,
    );
  }

  /// The id field.
  final String id;

  /// The start field.
  final double start;

  /// The end field.
  final double end;

  /// The text field.
  final String text;

  /// The speaker field.
  final String speaker;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'transcript.text.segment';

  /// Serializes current typed values and received future members.
  @override
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'id': id,
      'start': start,
      'end': end,
      'text': text,
      'speaker': speaker,
    }, 'TranscriptTextSegmentEvent');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptTextSegmentEvent copyWith({
    String? id,
    double? start,
    double? end,
    String? text,
    String? speaker,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptTextSegmentEvent._(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      speaker: speaker ?? this.speaker,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextSegmentEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptTextSegmentEvent(type: $type, id: ${fileAudioPresence(id)}, start: $start, end: $end, text: ${fileAudioPresence(text)}, speaker: ${fileAudioPresence(speaker)}, rawJson: [REDACTED])';
}

/// Typed TranscriptTextDeltaEvent fields and immutable received future metadata.
@immutable
class TranscriptTextDeltaEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextDeltaEvent] with owned snapshots.
  TranscriptTextDeltaEvent({
    required this.delta,
    List<TranscriptionLogprob>? logprobs,
    this.segmentId,
    Map<String, dynamic> rawJson = const {},
  }) : logprobs = immutableFileAudioList(logprobs),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptTextDeltaEvent',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'delta',
    'logprobs',
    'segment_id',
    'type',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptTextDeltaEvent.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptTextDeltaEvent',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'type',
      'transcript.text.delta',
      'TranscriptTextDeltaEvent',
    );
    return TranscriptTextDeltaEvent(
      delta: requireFileAudioString(
        raw['delta'],
        'TranscriptTextDeltaEvent.delta',
      ),
      logprobs: optionalFileAudio(
        raw,
        'logprobs',
        'TranscriptTextDeltaEvent',
        (value, context) => requireFileAudioList<TranscriptionLogprob>(
          value,
          context,
          (value, context) => TranscriptionLogprob.fromStreamJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      segmentId: optionalFileAudio(
        raw,
        'segment_id',
        'TranscriptTextDeltaEvent',
        requireFileAudioString,
      ),
      rawJson: raw,
    );
  }

  /// The delta field.
  final String delta;

  /// The logprobs field when present.
  final List<TranscriptionLogprob>? logprobs;

  /// The segment_id field when present.
  final String? segmentId;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'transcript.text.delta';

  /// Serializes current typed values and received future members.
  @override
  Map<String, dynamic> toJson() {
    for (final value in logprobs ?? const <TranscriptionLogprob>[]) {
      value.validateStreamBytes();
    }
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'delta': delta,
      if (logprobs != null)
        'logprobs': mergeFileAudioChildren(
          rawJson['logprobs'],
          logprobs!.map((value) => value.toJson()).toList(),
          const {'token', 'bytes', 'logprob'},
        ),
      if (segmentId != null) 'segment_id': segmentId,
    }, 'TranscriptTextDeltaEvent');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptTextDeltaEvent copyWith({
    String? delta,
    Object? logprobs = unsetCopyWithValue,
    Object? segmentId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptTextDeltaEvent(
      delta: delta ?? this.delta,
      logprobs: logprobs == unsetCopyWithValue
          ? this.logprobs
          : logprobs as List<TranscriptionLogprob>?,
      segmentId: segmentId == unsetCopyWithValue
          ? this.segmentId
          : segmentId as String?,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (logprobs != unsetCopyWithValue) 'logprobs',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDeltaEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptTextDeltaEvent(type: $type, delta: ${fileAudioPresence(delta)}, logprobs: ${fileAudioListSummary(logprobs)}, segmentId: ${fileAudioPresence(segmentId)}, rawJson: [REDACTED])';
}

/// Typed TranscriptTextDoneEvent fields and immutable received future metadata.
@immutable
class TranscriptTextDoneEvent extends TranscriptionStreamEvent {
  /// Creates a [TranscriptTextDoneEvent] with owned snapshots.
  TranscriptTextDoneEvent({
    required this.text,
    List<TranscriptionLanguage>? languages,
    List<TranscriptionLogprob>? logprobs,
    this.usage,
    Map<String, dynamic> rawJson = const {},
  }) : languages = immutableFileAudioList(languages),
       logprobs = immutableFileAudioList(logprobs),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptTextDoneEvent',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'text',
    'languages',
    'logprobs',
    'usage',
    'type',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptTextDoneEvent.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptTextDoneEvent',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'type',
      'transcript.text.done',
      'TranscriptTextDoneEvent',
    );
    return TranscriptTextDoneEvent(
      text: requireFileAudioString(raw['text'], 'TranscriptTextDoneEvent.text'),
      languages: optionalFileAudio(
        raw,
        'languages',
        'TranscriptTextDoneEvent',
        (value, context) => requireFileAudioList<TranscriptionLanguage>(
          value,
          context,
          (value, context) => TranscriptionLanguage.fromJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      logprobs: optionalFileAudio(
        raw,
        'logprobs',
        'TranscriptTextDoneEvent',
        (value, context) => requireFileAudioList<TranscriptionLogprob>(
          value,
          context,
          (value, context) => TranscriptionLogprob.fromStreamJson(
            requireFileAudioMap(value, context),
          ),
        ),
      ),
      usage: optionalFileAudio(
        raw,
        'usage',
        'TranscriptTextDoneEvent',
        (value, context) => TranscriptTextUsageTokens.fromJson(
          requireFileAudioMap(value, context),
        ),
      ),
      rawJson: raw,
    );
  }

  /// The text field.
  final String text;

  /// The languages field when present.
  final List<TranscriptionLanguage>? languages;

  /// The logprobs field when present.
  final List<TranscriptionLogprob>? logprobs;

  /// The usage field when present.
  final TranscriptTextUsageTokens? usage;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'transcript.text.done';

  /// Serializes current typed values and received future members.
  @override
  Map<String, dynamic> toJson() {
    for (final value in logprobs ?? const <TranscriptionLogprob>[]) {
      value.validateStreamBytes();
    }
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'text': text,
      if (languages != null)
        'languages': mergeFileAudioChildren(
          rawJson['languages'],
          languages!.map((value) => value.toJson()).toList(),
          const {'code'},
        ),
      if (logprobs != null)
        'logprobs': mergeFileAudioChildren(
          rawJson['logprobs'],
          logprobs!.map((value) => value.toJson()).toList(),
          const {'token', 'bytes', 'logprob'},
        ),
      if (usage != null)
        'usage': mergeFileAudioChild(rawJson['usage'], usage!.toJson(), const {
          'input_tokens',
          'output_tokens',
          'total_tokens',
          'input_token_details',
          'type',
        }),
    }, 'TranscriptTextDoneEvent');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptTextDoneEvent copyWith({
    String? text,
    Object? languages = unsetCopyWithValue,
    Object? logprobs = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
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
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (languages != unsetCopyWithValue) 'languages',
        if (logprobs != unsetCopyWithValue) 'logprobs',
        if (usage != unsetCopyWithValue) 'usage',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextDoneEvent &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptTextDoneEvent(type: $type, text: ${fileAudioPresence(text)}, languages: ${fileAudioListSummary(languages)}, logprobs: ${fileAudioListSummary(logprobs)}, usage: $usage, rawJson: [REDACTED])';
}

/// A deeply immutable receive-only fallback for a future discriminator.
@immutable
class TranscriptTextUnknownEvent extends TranscriptionStreamEvent {
  /// Copies and freezes the received future payload.
  TranscriptTextUnknownEvent({
    required this.rawType,
    required Map<String, dynamic> rawJson,
  }) : rawJson = snapshotAudioJson(rawJson, 'TranscriptTextUnknownEvent') {
    if (const <String>[
      'transcript.text.delta',
      'transcript.text.done',
      'transcript.text.segment',
    ].contains(rawType)) {
      throw const FormatException(
        'TranscriptTextUnknownEvent.rawType: expected a future discriminator',
      );
    }
  }

  /// Requires a future string discriminator and finite object payload.
  factory TranscriptTextUnknownEvent.fromJson(Map<String, dynamic> json) =>
      TranscriptTextUnknownEvent(
        rawType: requireFileAudioString(
          json['type'],
          'TranscriptTextUnknownEvent.type',
        ),
        rawJson: json,
      );

  /// The received future discriminator.
  final String rawType;

  /// Deeply immutable received JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawType;
  @override
  Map<String, dynamic> toJson() => fileAudioJson(
    rawJson,
    const {'type'},
    {'type': type},
    'TranscriptTextUnknownEvent',
  );

  /// Replaces the future discriminator or deeply snapshots a new payload.
  TranscriptTextUnknownEvent copyWith({
    String? rawType,
    Map<String, dynamic>? rawJson,
  }) => TranscriptTextUnknownEvent(
    rawType: rawType ?? this.rawType,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUnknownEvent &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => mapDeepHashCode(toJson());
  @override
  String toString() =>
      'TranscriptTextUnknownEvent(rawType: [REDACTED], rawJson: [REDACTED])';
}

/// Typed received variants; unknown strings preserve future metadata.
@immutable
sealed class TranscriptUsage {
  const TranscriptUsage();
  factory TranscriptUsage.fromJson(Map<String, dynamic> json) {
    final type = requireFileAudioString(json['type'], 'TranscriptUsage.type');
    return switch (type) {
      'tokens' => TranscriptTextUsageTokens.fromJson(json),
      'duration' => TranscriptTextUsageDuration.fromJson(json),
      _ => TranscriptUsageUnknown.fromJson(json),
    };
  }

  /// The validated wire discriminator.
  String get type;

  /// Serializes current typed values and received metadata.
  Map<String, dynamic> toJson();
}

/// Typed TranscriptTextUsageTokens fields and immutable received future metadata.
@immutable
class TranscriptTextUsageTokens extends TranscriptUsage {
  /// Creates a [TranscriptTextUsageTokens]; scalar const construction remains available.
  const TranscriptTextUsageTokens({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    this.inputTokenDetails,
  }) : rawJson = const {};

  TranscriptTextUsageTokens._({
    required this.inputTokens,
    required this.outputTokens,
    required this.totalTokens,
    required this.inputTokenDetails,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptTextUsageTokens',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'input_tokens',
    'output_tokens',
    'total_tokens',
    'input_token_details',
    'type',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptTextUsageTokens.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptTextUsageTokens',
      knownKeys: _fields,
    );
    requireFileAudioType(raw, 'type', 'tokens', 'TranscriptTextUsageTokens');
    return TranscriptTextUsageTokens._(
      inputTokens: requireAudioInt(
        raw['input_tokens'],
        'TranscriptTextUsageTokens.input_tokens',
      ),
      outputTokens: requireAudioInt(
        raw['output_tokens'],
        'TranscriptTextUsageTokens.output_tokens',
      ),
      totalTokens: requireAudioInt(
        raw['total_tokens'],
        'TranscriptTextUsageTokens.total_tokens',
      ),
      inputTokenDetails: optionalFileAudio(
        raw,
        'input_token_details',
        'TranscriptTextUsageTokens',
        (value, context) => TranscriptUsageInputTokenDetails.fromJson(
          requireFileAudioMap(value, context),
        ),
      ),
      rawJson: raw,
    );
  }

  /// The input_tokens field.
  final int inputTokens;

  /// The output_tokens field.
  final int outputTokens;

  /// The total_tokens field.
  final int totalTokens;

  /// The input_token_details field when present.
  final TranscriptUsageInputTokenDetails? inputTokenDetails;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'tokens';

  /// Serializes current typed values and received future members.
  @override
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'input_tokens': inputTokens,
      'output_tokens': outputTokens,
      'total_tokens': totalTokens,
      if (inputTokenDetails != null)
        'input_token_details': mergeFileAudioChild(
          rawJson['input_token_details'],
          inputTokenDetails!.toJson(),
          const {'audio_tokens', 'text_tokens'},
        ),
    }, 'TranscriptTextUsageTokens');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptTextUsageTokens copyWith({
    int? inputTokens,
    int? outputTokens,
    int? totalTokens,
    Object? inputTokenDetails = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptTextUsageTokens._(
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      inputTokenDetails: inputTokenDetails == unsetCopyWithValue
          ? this.inputTokenDetails
          : inputTokenDetails as TranscriptUsageInputTokenDetails?,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {
        if (inputTokenDetails != unsetCopyWithValue) 'input_token_details',
      }),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUsageTokens &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptTextUsageTokens(type: $type, inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens, inputTokenDetails: $inputTokenDetails, rawJson: [REDACTED])';
}

/// Typed TranscriptUsageInputTokenDetails fields and immutable received future metadata.
@immutable
class TranscriptUsageInputTokenDetails {
  /// Creates a [TranscriptUsageInputTokenDetails]; scalar const construction remains available.
  const TranscriptUsageInputTokenDetails({this.audioTokens, this.textTokens})
    : rawJson = const {};

  TranscriptUsageInputTokenDetails._({
    required this.audioTokens,
    required this.textTokens,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptUsageInputTokenDetails',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'audio_tokens', 'text_tokens'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptUsageInputTokenDetails.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptUsageInputTokenDetails',
      knownKeys: _fields,
    );
    return TranscriptUsageInputTokenDetails._(
      audioTokens: optionalFileAudio(
        raw,
        'audio_tokens',
        'TranscriptUsageInputTokenDetails',
        requireAudioInt,
      ),
      textTokens: optionalFileAudio(
        raw,
        'text_tokens',
        'TranscriptUsageInputTokenDetails',
        requireAudioInt,
      ),
      rawJson: raw,
    );
  }

  /// The audio_tokens field when present.
  final int? audioTokens;

  /// The text_tokens field when present.
  final int? textTokens;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      if (audioTokens != null) 'audio_tokens': audioTokens,
      if (textTokens != null) 'text_tokens': textTokens,
    }, 'TranscriptUsageInputTokenDetails');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptUsageInputTokenDetails copyWith({
    Object? audioTokens = unsetCopyWithValue,
    Object? textTokens = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptUsageInputTokenDetails._(
      audioTokens: audioTokens == unsetCopyWithValue
          ? this.audioTokens
          : audioTokens as int?,
      textTokens: textTokens == unsetCopyWithValue
          ? this.textTokens
          : textTokens as int?,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptUsageInputTokenDetails &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptUsageInputTokenDetails(audioTokens: $audioTokens, textTokens: $textTokens, rawJson: [REDACTED])';
}

/// Typed TranscriptTextUsageDuration fields and immutable received future metadata.
@immutable
class TranscriptTextUsageDuration extends TranscriptUsage {
  /// Creates a [TranscriptTextUsageDuration]; scalar const construction remains available.
  const TranscriptTextUsageDuration({required this.seconds})
    : rawJson = const {};

  TranscriptTextUsageDuration._({
    required this.seconds,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptTextUsageDuration',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'seconds', 'type'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptTextUsageDuration.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptTextUsageDuration',
      knownKeys: _fields,
    );
    requireFileAudioType(
      raw,
      'type',
      'duration',
      'TranscriptTextUsageDuration',
    );
    return TranscriptTextUsageDuration._(
      seconds: requireAudioNumber(
        raw['seconds'],
        'TranscriptTextUsageDuration.seconds',
      ),
      rawJson: raw,
    );
  }

  /// The seconds field.
  final double seconds;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  @override
  String get type => 'duration';

  /// Serializes current typed values and received future members.
  @override
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'type': type,
      'seconds': seconds,
    }, 'TranscriptTextUsageDuration');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptTextUsageDuration copyWith({
    double? seconds,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptTextUsageDuration._(
      seconds: seconds ?? this.seconds,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptTextUsageDuration &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptTextUsageDuration(type: $type, seconds: $seconds, rawJson: [REDACTED])';
}

/// A deeply immutable receive-only fallback for a future discriminator.
@immutable
class TranscriptUsageUnknown extends TranscriptUsage {
  /// Copies and freezes the received future payload.
  TranscriptUsageUnknown({
    required this.rawType,
    required Map<String, dynamic> rawJson,
  }) : rawJson = snapshotAudioJson(rawJson, 'TranscriptUsageUnknown') {
    if (const <String>['tokens', 'duration'].contains(rawType)) {
      throw const FormatException(
        'TranscriptUsageUnknown.rawType: expected a future discriminator',
      );
    }
  }

  /// Requires a future string discriminator and finite object payload.
  factory TranscriptUsageUnknown.fromJson(Map<String, dynamic> json) =>
      TranscriptUsageUnknown(
        rawType: requireFileAudioString(
          json['type'],
          'TranscriptUsageUnknown.type',
        ),
        rawJson: json,
      );

  /// The received future discriminator.
  final String rawType;

  /// Deeply immutable received JSON.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawType;
  @override
  Map<String, dynamic> toJson() => fileAudioJson(
    rawJson,
    const {'type'},
    {'type': type},
    'TranscriptUsageUnknown',
  );

  /// Replaces the future discriminator or deeply snapshots a new payload.
  TranscriptUsageUnknown copyWith({
    String? rawType,
    Map<String, dynamic>? rawJson,
  }) => TranscriptUsageUnknown(
    rawType: rawType ?? this.rawType,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptUsageUnknown &&
          mapsDeepEqual(toJson(), other.toJson());
  @override
  int get hashCode => mapDeepHashCode(toJson());
  @override
  String toString() =>
      'TranscriptUsageUnknown(rawType: [REDACTED], rawJson: [REDACTED])';
}

/// Typed TranscriptionLanguage fields and immutable received future metadata.
@immutable
class TranscriptionLanguage {
  /// Creates a [TranscriptionLanguage]; scalar const construction remains available.
  const TranscriptionLanguage({required this.code}) : rawJson = const {};

  TranscriptionLanguage._({
    required this.code,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionLanguage',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'code'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionLanguage.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionLanguage',
      knownKeys: _fields,
    );
    return TranscriptionLanguage._(
      code: requireFileAudioString(raw['code'], 'TranscriptionLanguage.code'),
      rawJson: raw,
    );
  }

  /// The code field.
  final String code;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'code': code,
    }, 'TranscriptionLanguage');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionLanguage copyWith({
    String? code,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionLanguage._(
      code: code ?? this.code,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionLanguage &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionLanguage(code: ${fileAudioPresence(code)}, rawJson: [REDACTED])';
}

/// A token log probability with immutable received future metadata.
///
/// All inline fields are optional nonnull. REST byte arrays admit finite
/// numbers; SSE delta/done byte arrays admit only integers. [fromStreamJson]
/// and SSE event serialization enforce that separate contract without rounding.
@immutable
class TranscriptionLogprob {
  /// Creates a [TranscriptionLogprob] with owned snapshots.
  TranscriptionLogprob({
    this.token,
    List<num>? bytes,
    this.logprob,
    Map<String, dynamic> rawJson = const {},
  }) : bytes = immutableFileAudioList(bytes),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionLogprob',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'token', 'bytes', 'logprob'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionLogprob.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionLogprob',
      knownKeys: _fields,
    );
    return TranscriptionLogprob(
      token: optionalFileAudio(
        raw,
        'token',
        'TranscriptionLogprob',
        requireFileAudioString,
      ),
      bytes: optionalFileAudio(
        raw,
        'bytes',
        'TranscriptionLogprob',
        (value, context) =>
            requireFileAudioList<num>(value, context, requireFileAudioNum),
      ),
      logprob: optionalFileAudio(
        raw,
        'logprob',
        'TranscriptionLogprob',
        requireAudioNumber,
      ),
      rawJson: raw,
    );
  }

  /// Parses the inline SSE form, whose byte elements are integers.
  factory TranscriptionLogprob.fromStreamJson(Map<String, dynamic> json) {
    final value = TranscriptionLogprob.fromJson(json);
    return value..validateStreamBytes();
  }

  /// Enforces the separate SSE byte contract without rounding.
  void validateStreamBytes() {
    for (final value in bytes ?? const <num>[]) {
      requireAudioInt(value, 'TranscriptionLogprob.bytes');
    }
  }

  /// The token field when present.
  final String? token;

  /// Token bytes: finite REST numbers, constrained to integers inside SSE events.
  final List<num>? bytes;

  /// The logprob field when present.
  final double? logprob;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      if (token != null) 'token': token,
      if (bytes != null) 'bytes': List<num>.of(bytes!),
      if (logprob != null) 'logprob': logprob,
    }, 'TranscriptionLogprob');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionLogprob copyWith({
    Object? token = unsetCopyWithValue,
    Object? bytes = unsetCopyWithValue,
    Object? logprob = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionLogprob(
      token: token == unsetCopyWithValue ? this.token : token as String?,
      bytes: bytes == unsetCopyWithValue ? this.bytes : bytes as List<num>?,
      logprob: logprob == unsetCopyWithValue
          ? this.logprob
          : copyFileAudioNumber(logprob, 'TranscriptionLogprob.logprob'),
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionLogprob &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionLogprob(token: ${fileAudioPresence(token)}, bytes: ${fileAudioListSummary(bytes)}, logprob: $logprob, rawJson: [REDACTED])';
}

/// Typed TranscriptionSegment fields and immutable received future metadata.
@immutable
class TranscriptionSegment {
  /// Creates a [TranscriptionSegment] with owned snapshots.
  TranscriptionSegment({
    required this.id,
    required this.seek,
    required this.start,
    required this.end,
    required this.text,
    required List<int> tokens,
    required this.temperature,
    required this.avgLogprob,
    required this.compressionRatio,
    required this.noSpeechProb,
    Map<String, dynamic> rawJson = const {},
  }) : tokens = List.unmodifiable(tokens),
       rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionSegment',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {
    'id',
    'seek',
    'start',
    'end',
    'text',
    'tokens',
    'temperature',
    'avg_logprob',
    'compression_ratio',
    'no_speech_prob',
  };

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionSegment',
      knownKeys: _fields,
    );
    return TranscriptionSegment(
      id: requireAudioInt(raw['id'], 'TranscriptionSegment.id'),
      seek: requireAudioInt(raw['seek'], 'TranscriptionSegment.seek'),
      start: requireAudioNumber(raw['start'], 'TranscriptionSegment.start'),
      end: requireAudioNumber(raw['end'], 'TranscriptionSegment.end'),
      text: requireFileAudioString(raw['text'], 'TranscriptionSegment.text'),
      tokens: requireFileAudioList<int>(
        raw['tokens'],
        'TranscriptionSegment.tokens',
        requireAudioInt,
      ),
      temperature: requireAudioNumber(
        raw['temperature'],
        'TranscriptionSegment.temperature',
      ),
      avgLogprob: requireAudioNumber(
        raw['avg_logprob'],
        'TranscriptionSegment.avg_logprob',
      ),
      compressionRatio: requireAudioNumber(
        raw['compression_ratio'],
        'TranscriptionSegment.compression_ratio',
      ),
      noSpeechProb: requireAudioNumber(
        raw['no_speech_prob'],
        'TranscriptionSegment.no_speech_prob',
      ),
      rawJson: raw,
    );
  }

  /// The id field.
  final int id;

  /// The seek field.
  final int seek;

  /// The start field.
  final double start;

  /// The end field.
  final double end;

  /// The text field.
  final String text;

  /// The tokens field.
  final List<int> tokens;

  /// The temperature field.
  final double temperature;

  /// The avg_logprob field.
  final double avgLogprob;

  /// The compression_ratio field.
  final double compressionRatio;

  /// The no_speech_prob field.
  final double noSpeechProb;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'id': id,
      'seek': seek,
      'start': start,
      'end': end,
      'text': text,
      'tokens': List<int>.of(tokens),
      'temperature': temperature,
      'avg_logprob': avgLogprob,
      'compression_ratio': compressionRatio,
      'no_speech_prob': noSpeechProb,
    }, 'TranscriptionSegment');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionSegment copyWith({
    int? id,
    int? seek,
    double? start,
    double? end,
    String? text,
    List<int>? tokens,
    double? temperature,
    double? avgLogprob,
    double? compressionRatio,
    double? noSpeechProb,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionSegment(
      id: id ?? this.id,
      seek: seek ?? this.seek,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      tokens: tokens ?? this.tokens,
      temperature: temperature ?? this.temperature,
      avgLogprob: avgLogprob ?? this.avgLogprob,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      noSpeechProb: noSpeechProb ?? this.noSpeechProb,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegment &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionSegment(id: $id, seek: $seek, start: $start, end: $end, text: ${fileAudioPresence(text)}, tokens: ${fileAudioListSummary(tokens)}, temperature: $temperature, avgLogprob: $avgLogprob, compressionRatio: $compressionRatio, noSpeechProb: $noSpeechProb, rawJson: [REDACTED])';
}

/// Typed TranscriptionWord fields and immutable received future metadata.
@immutable
class TranscriptionWord {
  /// Creates a [TranscriptionWord]; scalar const construction remains available.
  const TranscriptionWord({
    required this.word,
    required this.start,
    required this.end,
  }) : rawJson = const {};

  TranscriptionWord._({
    required this.word,
    required this.start,
    required this.end,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = snapshotAudioJson(
         rawJson,
         'TranscriptionWord',
         knownKeys: _fields,
       ) {
    toJson();
  }

  static const Set<String> _fields = {'word', 'start', 'end'};

  /// Parses schema-known fields with contextual, value-safe diagnostics.
  factory TranscriptionWord.fromJson(Map<String, dynamic> json) {
    final raw = snapshotAudioJson(
      json,
      'TranscriptionWord',
      knownKeys: _fields,
    );
    return TranscriptionWord._(
      word: requireFileAudioString(raw['word'], 'TranscriptionWord.word'),
      start: requireAudioNumber(raw['start'], 'TranscriptionWord.start'),
      end: requireAudioNumber(raw['end'], 'TranscriptionWord.end'),
      rawJson: raw,
    );
  }

  /// The word field.
  final String word;

  /// The start field.
  final double start;

  /// The end field.
  final double end;

  /// Deeply immutable original received JSON; known typed fields are authoritative.
  final Map<String, dynamic> rawJson;

  /// Serializes current typed values and received future members.
  Map<String, dynamic> toJson() {
    return fileAudioJson(rawJson, _fields, {
      'word': word,
      'start': start,
      'end': end,
    }, 'TranscriptionWord');
  }

  /// Copies every field; explicit null clears optional fields.
  /// Fresh child replacements discard stale nested metadata unless rawJson overrides it.
  TranscriptionWord copyWith({
    String? word,
    double? start,
    double? end,
    Map<String, dynamic>? rawJson,
  }) {
    return TranscriptionWord._(
      word: word ?? this.word,
      start: start ?? this.start,
      end: end ?? this.end,
      rawJson: copyFileAudioRaw(this.rawJson, rawJson, {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionWord &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => mapDeepHashCode(toJson());

  @override
  String toString() =>
      'TranscriptionWord(word: ${fileAudioPresence(word)}, start: $start, end: $end, rawJson: [REDACTED])';
}
