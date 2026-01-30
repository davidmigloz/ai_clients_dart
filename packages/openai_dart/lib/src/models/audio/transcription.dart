import 'dart:typed_data';

import 'package:meta/meta.dart';

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
///   model: 'whisper-1',
/// );
/// ```
@immutable
class TranscriptionRequest {
  /// Creates a [TranscriptionRequest].
  const TranscriptionRequest({
    required this.file,
    required this.filename,
    required this.model,
    this.language,
    this.prompt,
    this.responseFormat,
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
  /// Currently only `whisper-1` is available.
  final String model;

  /// The language of the audio in ISO-639-1 format.
  ///
  /// If not provided, the language is auto-detected.
  final String? language;

  /// Optional text to guide the model's style.
  ///
  /// The prompt should match the audio language and can include
  /// example phrases or proper nouns to improve accuracy.
  final String? prompt;

  /// The format of the transcription output.
  ///
  /// Defaults to `json`.
  final TranscriptionResponseFormat? responseFormat;

  /// The sampling temperature, between 0 and 1.
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  /// The granularities for timestamp information.
  ///
  /// Requires `responseFormat` to be `verbose_json`.
  final List<TimestampGranularity>? timestampGranularities;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionRequest &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          model == other.model &&
          language == other.language;

  @override
  int get hashCode => Object.hash(filename, model, language);

  @override
  String toString() =>
      'TranscriptionRequest(filename: $filename, model: $model)';
}

/// The response format for transcription.
enum TranscriptionResponseFormat {
  /// JSON format with just the text.
  json._('json'),

  /// Plain text format.
  text._('text'),

  /// SubRip subtitle format.
  srt._('srt'),

  /// Verbose JSON with timestamps and metadata.
  verboseJson._('verbose_json'),

  /// WebVTT subtitle format.
  vtt._('vtt');

  const TranscriptionResponseFormat._(this._value);

  /// Creates from JSON string.
  factory TranscriptionResponseFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown format: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

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

/// A transcription response.
///
/// Contains the transcribed text from the audio input.
@immutable
class TranscriptionResponse {
  /// Creates a [TranscriptionResponse].
  const TranscriptionResponse({required this.text});

  /// Creates a [TranscriptionResponse] from JSON.
  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(text: json['text'] as String);
  }

  /// The transcribed text.
  final String text;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionResponse &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TranscriptionResponse(${text.length} chars)';
}

/// A verbose transcription response with additional metadata.
///
/// Includes word and segment-level timestamps when requested.
@immutable
class TranscriptionVerboseResponse {
  /// Creates a [TranscriptionVerboseResponse].
  const TranscriptionVerboseResponse({
    required this.task,
    required this.language,
    required this.duration,
    required this.text,
    this.segments,
    this.words,
  });

  /// Creates a [TranscriptionVerboseResponse] from JSON.
  factory TranscriptionVerboseResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionVerboseResponse(
      task: json['task'] as String,
      language: json['language'] as String,
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      words: (json['words'] as List<dynamic>?)
          ?.map((e) => TranscriptionWord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The task performed (always "transcribe").
  final String task;

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

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task': task,
    'language': language,
    'duration': duration,
    'text': text,
    if (segments != null) 'segments': segments!.map((s) => s.toJson()).toList(),
    if (words != null) 'words': words!.map((w) => w.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionVerboseResponse &&
          runtimeType == other.runtimeType &&
          task == other.task &&
          language == other.language &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(task, language, duration);

  @override
  String toString() =>
      'TranscriptionVerboseResponse(language: $language, ${text.length} chars)';
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
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(id, start, end);

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
          start == other.start;

  @override
  int get hashCode => Object.hash(word, start);

  @override
  String toString() => 'TranscriptionWord($word, $start-$end)';
}
