import 'package:meta/meta.dart';

import '../audio/audio_voice.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

export '../audio/audio_voice.dart';

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
///   model: 'gpt-audio-1.5',
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
/// Preserves existing named conveniences and adds current named choices.
/// Availability depends on the provider and model; open names and custom IDs
/// are also admitted by the request contract.
enum ChatAudioVoice implements AudioVoice {
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
  verse._('verse'),

  /// Marin voice.
  marin._('marin'),

  /// Cedar voice.
  cedar._('cedar');

  const ChatAudioVoice._(this._value);

  /// Creates from JSON string.
  factory ChatAudioVoice.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw const FormatException(
        'ChatAudioVoice: expected a supported named voice',
      ),
    );
  }

  final String _value;

  /// Converts to JSON string.
  @override
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
  pcm16._('pcm16'),

  /// AAC format (compressed).
  aac._('aac');

  const ChatAudioFormat._(this._value);

  /// Creates from JSON string.
  factory ChatAudioFormat.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw const FormatException(
        'ChatAudioFormat: expected a supported audio format',
      ),
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
/// Used with `gpt-audio-1.5` to configure how audio responses
/// are generated.
///
/// ## Example
///
/// ```dart
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-audio-1.5',
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
    final parsedVoice = AudioVoice.fromJson(json['voice']);
    final voice = parsedVoice is NamedAudioVoice
        ? _knownChatVoice(parsedVoice.name) ?? parsedVoice
        : parsedVoice;
    return ChatAudioConfig(
      voice: voice,
      format: ChatAudioFormat.fromJson(
        requireJsonString(json['format'], 'ChatAudioConfig.format'),
      ),
    );
  }

  /// The voice to use for audio generation.
  ///
  /// Accepts built-in [ChatAudioVoice] constants, open names through
  /// [AudioVoice.named], or an existing custom ID through [AudioVoice.custom].
  /// Custom voice creation and eligibility are separate provider workflows.
  final AudioVoice voice;

  /// The audio format to output.
  final ChatAudioFormat format;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    // Caller-defined interface implementations must produce an exact branch.
    'voice': AudioVoice.fromJson(voice.toJson()).toJson(),
    'format': format.toJson(),
  };

  /// Creates a copy with replaced values.
  ChatAudioConfig copyWith({AudioVoice? voice, ChatAudioFormat? format}) {
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
          mapsDeepEqual(toJson(), other.toJson());

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(toJson()));

  @override
  String toString() => 'ChatAudioConfig(voice: [REDACTED], format: $format)';
}

ChatAudioVoice? _knownChatVoice(String value) {
  for (final voice in ChatAudioVoice.values) {
    if (voice.toJson() == value) return voice;
  }
  return null;
}
