import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'transcription.dart';

/// A request to translate audio into English text.
///
/// Converts audio in various languages to English text.
///
/// ## Example
///
/// ```dart
/// final request = TranslationRequest(
///   file: audioBytes,
///   filename: 'german_audio.mp3',
///   model: 'whisper-1',
/// );
/// ```
@immutable
class TranslationRequest {
  /// Creates a [TranslationRequest].
  const TranslationRequest({
    required this.file,
    required this.filename,
    required this.model,
    this.prompt,
    this.responseFormat,
    this.temperature,
  });

  /// The audio file to translate.
  ///
  /// Supported formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.
  final Uint8List file;

  /// The filename of the audio file.
  ///
  /// Must include the file extension for proper format detection.
  final String filename;

  /// The model to use for translation.
  ///
  /// Currently only `whisper-1` is available.
  final String model;

  /// Optional text to guide the model's style.
  ///
  /// Should be in English and can include example phrases to improve accuracy.
  final String? prompt;

  /// The format of the translation output.
  ///
  /// Defaults to `json`.
  final TranscriptionResponseFormat? responseFormat;

  /// The sampling temperature, between 0 and 1.
  ///
  /// Higher values make output more random, lower values more deterministic.
  final double? temperature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationRequest &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          model == other.model;

  @override
  int get hashCode => Object.hash(filename, model);

  @override
  String toString() => 'TranslationRequest(filename: $filename, model: $model)';
}

/// A translation response.
///
/// Contains the translated English text from the audio input.
@immutable
class TranslationResponse {
  /// Creates a [TranslationResponse].
  const TranslationResponse({required this.text});

  /// Creates a [TranslationResponse] from JSON.
  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(text: json['text'] as String);
  }

  /// The translated English text.
  final String text;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationResponse &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TranslationResponse(${text.length} chars)';
}

/// A verbose translation response with additional metadata.
///
/// Includes segment-level timestamps.
@immutable
class TranslationVerboseResponse {
  /// Creates a [TranslationVerboseResponse].
  const TranslationVerboseResponse({
    required this.task,
    required this.language,
    required this.duration,
    required this.text,
    this.segments,
  });

  /// Creates a [TranslationVerboseResponse] from JSON.
  factory TranslationVerboseResponse.fromJson(Map<String, dynamic> json) {
    return TranslationVerboseResponse(
      task: json['task'] as String,
      language: json['language'] as String,
      duration: (json['duration'] as num).toDouble(),
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The task performed (always "translate").
  final String task;

  /// The detected source language.
  final String language;

  /// The duration of the audio in seconds.
  final double duration;

  /// The full translated text.
  final String text;

  /// Segments with timestamps.
  final List<TranscriptionSegment>? segments;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task': task,
    'language': language,
    'duration': duration,
    'text': text,
    if (segments != null) 'segments': segments!.map((s) => s.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationVerboseResponse &&
          runtimeType == other.runtimeType &&
          task == other.task &&
          language == other.language &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(task, language, duration);

  @override
  String toString() =>
      'TranslationVerboseResponse(language: $language, ${text.length} chars)';
}
