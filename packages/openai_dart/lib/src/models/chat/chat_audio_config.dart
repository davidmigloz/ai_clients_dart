import 'package:meta/meta.dart';

// =============================================================================
// ChatModality
// =============================================================================

/// Output modality for chat completions.
///
/// Specifies what types of output the model should generate.
/// When using audio models, you can request both text and audio output.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o-audio-preview',
///   messages: [...],
///   modalities: [ChatModality.text, ChatModality.audio],
///   audio: ChatAudioConfig(
///     voice: ChatAudioVoice.alloy,
///     format: ChatAudioFormat.mp3,
///   ),
/// );
/// ```
enum ChatModality {
  /// Text output.
  text._('text'),

  /// Audio output.
  audio._('audio');

  const ChatModality._(this._value);

  /// Creates from JSON string.
  factory ChatModality.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown ChatModality: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// ChatAudioVoice
// =============================================================================

/// Voice options for chat audio output.
///
/// These voices are available for the `gpt-4o-audio-preview` model
/// when generating audio responses.
enum ChatAudioVoice {
  /// Alloy voice.
  alloy._('alloy'),

  /// Ash voice.
  ash._('ash'),

  /// Ballad voice.
  ballad._('ballad'),

  /// Coral voice.
  coral._('coral'),

  /// Echo voice.
  echo._('echo'),

  /// Fable voice.
  fable._('fable'),

  /// Nova voice.
  nova._('nova'),

  /// Onyx voice.
  onyx._('onyx'),

  /// Sage voice.
  sage._('sage'),

  /// Shimmer voice.
  shimmer._('shimmer'),

  /// Verse voice.
  verse._('verse');

  const ChatAudioVoice._(this._value);

  /// Creates from JSON string.
  factory ChatAudioVoice.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown ChatAudioVoice: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// ChatAudioFormat
// =============================================================================

/// Audio format options for chat audio output.
///
/// Specifies the encoding format for audio responses.
enum ChatAudioFormat {
  /// WAV format (uncompressed).
  wav._('wav'),

  /// MP3 format (compressed).
  mp3._('mp3'),

  /// FLAC format (lossless compression).
  flac._('flac'),

  /// Opus format (compressed).
  opus._('opus'),

  /// 16-bit PCM format (raw audio).
  pcm16._('pcm16');

  const ChatAudioFormat._(this._value);

  /// Creates from JSON string.
  factory ChatAudioFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown ChatAudioFormat: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

// =============================================================================
// ChatAudioConfig
// =============================================================================

/// Configuration for audio output in chat completions.
///
/// Used with `gpt-4o-audio-preview` to configure how audio responses
/// are generated.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o-audio-preview',
///   messages: [ChatMessage.user('Tell me a story.')],
///   modalities: [ChatModality.text, ChatModality.audio],
///   audio: ChatAudioConfig(
///     voice: ChatAudioVoice.alloy,
///     format: ChatAudioFormat.mp3,
///   ),
/// );
/// ```
@immutable
class ChatAudioConfig {
  /// Creates a [ChatAudioConfig].
  const ChatAudioConfig({required this.voice, required this.format});

  /// Creates a [ChatAudioConfig] from JSON.
  factory ChatAudioConfig.fromJson(Map<String, dynamic> json) {
    return ChatAudioConfig(
      voice: ChatAudioVoice.fromJson(json['voice'] as String),
      format: ChatAudioFormat.fromJson(json['format'] as String),
    );
  }

  /// The voice to use for audio generation.
  final ChatAudioVoice voice;

  /// The audio format to output.
  final ChatAudioFormat format;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'voice': voice.toJson(),
    'format': format.toJson(),
  };

  /// Creates a copy with replaced values.
  ChatAudioConfig copyWith({ChatAudioVoice? voice, ChatAudioFormat? format}) {
    return ChatAudioConfig(
      voice: voice ?? this.voice,
      format: format ?? this.format,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAudioConfig &&
          runtimeType == other.runtimeType &&
          voice == other.voice &&
          format == other.format;

  @override
  int get hashCode => Object.hash(voice, format);

  @override
  String toString() => 'ChatAudioConfig(voice: $voice, format: $format)';
}
