import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';
import 'audio_voice.dart';

/// A request to generate speech from text.
///
/// Uses the text-to-speech API to convert text into spoken audio.
///
/// ## Example
///
/// ```dart
/// final request = SpeechRequest(
///   model: 'tts-1',
///   input: 'Hello, world!',
///   voice: SpeechVoice.alloy,
/// );
/// ```
@immutable
class SpeechRequest {
  /// Creates a [SpeechRequest].
  const SpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
    this.instructions,
    this.responseFormat,
    this.speed,
    this.streamFormat,
  });

  /// Creates a [SpeechRequest] from JSON.
  factory SpeechRequest.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'SpeechRequest',
      knownKeys: _knownKeys,
    );
    requireClosedAudioJson(snapshot, _knownKeys, 'SpeechRequest');
    final voiceValue = snapshot['voice'];
    final parsedVoice = AudioVoice.fromJson(
      voiceValue is String
          ? voiceValue
          : requireJsonObject(voiceValue, 'SpeechRequest.voice'),
    );
    final voice = parsedVoice is NamedAudioVoice
        ? _knownVoice(parsedVoice.name) ?? parsedVoice
        : parsedVoice;
    final input = requireJsonString(snapshot['input'], 'SpeechRequest.input');
    final instructions = optionalJsonString(
      snapshot,
      'instructions',
      'SpeechRequest',
    );
    _validateLength(input, 'SpeechRequest.input');
    if (instructions != null) {
      _validateLength(instructions, 'SpeechRequest.instructions');
    }
    return SpeechRequest(
      model: requireJsonString(snapshot['model'], 'SpeechRequest.model'),
      input: input,
      voice: voice,
      instructions: instructions,
      responseFormat: snapshot.containsKey('response_format')
          ? _parseResponseFormat(
              snapshot['response_format'],
              'SpeechRequest.response_format',
            )
          : null,
      speed: snapshot.containsKey('speed')
          ? _parseSpeed(snapshot['speed'])
          : null,
      streamFormat: snapshot.containsKey('stream_format')
          ? _parseStreamFormat(
              snapshot['stream_format'],
              'SpeechRequest.stream_format',
            )
          : null,
    );
  }

  /// The TTS model to use.
  ///
  /// Accepts current and future provider model IDs. Some options are model-specific.
  final String model;

  /// The text to generate audio for.
  ///
  /// Maximum length is 4096 characters.
  final String input;

  /// The voice to use for speech generation.
  /// Existing [SpeechVoice] values, open names and custom ID references are supported.
  final AudioVoice voice;

  /// Optional instructions for voice delivery, limited to 4,096 Unicode characters.
  ///
  /// Unsupported by `tts-1` and `tts-1-hd`; omitted when null.
  final String? instructions;

  /// The audio format for the output.
  ///
  /// Defaults to `mp3`.
  final SpeechResponseFormat? responseFormat;

  /// The speed of the generated audio.
  ///
  /// Range: 0.25 to 4.0. Default is 1.0.
  final double? speed;

  /// Audio byte streaming or SSE events; the server defaults to audio when omitted.
  ///
  /// SSE is unsupported by `tts-1` and `tts-1-hd`.
  final SpeechStreamFormat? streamFormat;

  static const _knownKeys = {
    'model',
    'input',
    'voice',
    'instructions',
    'response_format',
    'speed',
    'stream_format',
  };

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    _validateLength(input, 'SpeechRequest.input');
    if (instructions != null) {
      _validateLength(instructions!, 'SpeechRequest.instructions');
    }
    if (speed != null) _parseSpeed(speed);
    // An interface implementation must still produce one exact writable branch.
    final voiceJson = AudioVoice.fromJson(voice.toJson()).toJson();
    return {
      'model': model,
      'input': input,
      'voice': voiceJson,
      if (instructions != null) 'instructions': instructions,
      if (responseFormat != null) 'response_format': responseFormat!.toJson(),
      if (speed != null) 'speed': speed,
      if (streamFormat != null) 'stream_format': streamFormat!.toJson(),
    };
  }

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  SpeechRequest copyWith({
    String? model,
    String? input,
    AudioVoice? voice,
    Object? instructions = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? speed = unsetCopyWithValue,
    Object? streamFormat = unsetCopyWithValue,
  }) {
    return SpeechRequest(
      model: model ?? this.model,
      input: input ?? this.input,
      voice: voice ?? this.voice,
      instructions: identical(instructions, unsetCopyWithValue)
          ? this.instructions
          : instructions == null
          ? null
          : requireJsonString(instructions, 'SpeechRequest.instructions'),
      responseFormat: identical(responseFormat, unsetCopyWithValue)
          ? this.responseFormat
          : _copyResponseFormat(responseFormat),
      speed: identical(speed, unsetCopyWithValue)
          ? this.speed
          : speed == null
          ? null
          : _parseSpeed(speed),
      streamFormat: identical(streamFormat, unsetCopyWithValue)
          ? this.streamFormat
          : _copyStreamFormat(streamFormat),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechRequest &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() =>
      'SpeechRequest(model: [REDACTED], input: ${input.runes.length} chars, '
      'voice: [REDACTED], instructions: ${audioPresence(instructions)}, '
      'responseFormat: $responseFormat, speed: $speed, streamFormat: $streamFormat)';
}

/// Available voices for text-to-speech.
enum SpeechVoice implements AudioVoice {
  /// Alloy voice.
  alloy._('alloy'),

  /// Echo voice.
  echo._('echo'),

  /// Fable voice.
  fable._('fable'),

  /// Onyx voice.
  onyx._('onyx'),

  /// Nova voice.
  nova._('nova'),

  /// Shimmer voice.
  shimmer._('shimmer'),

  /// Ash voice.
  ash._('ash'),

  /// Ballad voice.
  ballad._('ballad'),

  /// Coral voice.
  coral._('coral'),

  /// Sage voice.
  sage._('sage'),

  /// Verse voice.
  verse._('verse'),

  /// Marin voice.
  marin._('marin'),

  /// Cedar voice.
  cedar._('cedar');

  const SpeechVoice._(this._value);

  /// Creates from JSON string.
  factory SpeechVoice.fromJson(String json) {
    final voice = _knownVoice(json);
    if (voice == null) {
      throw const FormatException(
        'SpeechVoice: expected a supported named voice',
      );
    }
    return voice;
  }

  final String _value;

  /// Converts to JSON string.
  @override
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Audio output formats for speech generation.
enum SpeechResponseFormat {
  /// MP3 format (default).
  mp3._('mp3'),

  /// Opus format.
  opus._('opus'),

  /// AAC format.
  aac._('aac'),

  /// FLAC format.
  flac._('flac'),

  /// WAV format.
  wav._('wav'),

  /// PCM format.
  pcm._('pcm');

  const SpeechResponseFormat._(this._value);

  /// Creates from JSON string.
  factory SpeechResponseFormat.fromJson(String json) {
    return _parseResponseFormat(json, 'SpeechResponseFormat');
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Wire representation of streamed speech output.
enum SpeechStreamFormat {
  /// Stream binary audio bytes.
  audio._('audio'),

  /// Stream typed Server-Sent Events.
  sse._('sse');

  const SpeechStreamFormat._(this._value);

  /// Parses an exact, closed stream format.
  factory SpeechStreamFormat.fromJson(String json) =>
      _parseStreamFormat(json, 'SpeechStreamFormat');

  final String _value;

  /// Serializes the wire value.
  String toJson() => _value;

  @override
  String toString() => _value;
}

SpeechVoice? _knownVoice(String value) {
  for (final voice in SpeechVoice.values) {
    if (voice.toJson() == value) return voice;
  }
  return null;
}

SpeechResponseFormat _parseResponseFormat(Object? value, String context) {
  final string = requireJsonString(value, context);
  for (final format in SpeechResponseFormat.values) {
    if (format.toJson() == string) return format;
  }
  throw FormatException('$context: expected a supported audio format');
}

SpeechStreamFormat _parseStreamFormat(Object? value, String context) {
  final string = requireJsonString(value, context);
  for (final format in SpeechStreamFormat.values) {
    if (format.toJson() == string) return format;
  }
  throw FormatException('$context: expected audio or sse');
}

SpeechResponseFormat? _copyResponseFormat(Object? value) {
  if (value == null || value is SpeechResponseFormat) {
    return value as SpeechResponseFormat?;
  }
  throw const FormatException(
    'SpeechRequest.response_format: expected a SpeechResponseFormat',
  );
}

SpeechStreamFormat? _copyStreamFormat(Object? value) {
  if (value == null || value is SpeechStreamFormat) {
    return value as SpeechStreamFormat?;
  }
  throw const FormatException(
    'SpeechRequest.stream_format: expected a SpeechStreamFormat',
  );
}

void _validateLength(String value, String context) {
  if (value.runes.length > 4096) {
    throw FormatException('$context: expected at most 4096 Unicode characters');
  }
}

double _parseSpeed(Object? value) {
  final speed = requireAudioNumber(value, 'SpeechRequest.speed');
  if (speed < 0.25 || speed > 4) {
    throw const FormatException('SpeechRequest.speed: expected 0.25 through 4');
  }
  return speed;
}
