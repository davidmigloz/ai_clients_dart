import 'dart:convert';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Audio in a speech context turn, represented as base64 in JSON.
@immutable
final class SpeechTurnAudio {
  /// Base64-encoded audio.
  final String data;

  /// Creates speech context audio from base64 data.
  const SpeechTurnAudio({required this.data});

  /// Encodes audio bytes for a speech context turn.
  factory SpeechTurnAudio.fromBytes(List<int> bytes) =>
      SpeechTurnAudio(data: base64Encode(bytes));

  /// Decodes speech context audio from JSON.
  factory SpeechTurnAudio.fromJson(Map<String, dynamic> json) =>
      SpeechTurnAudio(data: json['data'] as String);

  /// Encodes this value for the API.
  Map<String, dynamic> toJson() => {'data': data};

  /// Creates a copy with replacement audio.
  SpeechTurnAudio copyWith({String? data}) =>
      SpeechTurnAudio(data: data ?? this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SpeechTurnAudio && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'SpeechTurnAudio(data: ${data.length} chars)';
}

/// An audio turn used to condition a speech response.
///
/// Variants are [SpeechUserTurn], [SpeechAssistantTurn] and
/// [UnknownSpeechTurn].
@immutable
sealed class SpeechTurn {
  const SpeechTurn();

  /// Creates a user audio turn.
  const factory SpeechTurn.user({required SpeechTurnAudio audio}) =
      SpeechUserTurn;

  /// Creates an assistant turn with audio and the text it spoke.
  const factory SpeechTurn.assistant({
    required String text,
    required SpeechTurnAudio audio,
  }) = SpeechAssistantTurn;

  /// The wire role for the turn.
  String get role;

  /// Decodes the turn, preserving unrecognized roles for forward compatibility.
  factory SpeechTurn.fromJson(Map<String, dynamic> json) =>
      switch (json['role']) {
        'user' => SpeechUserTurn.fromJson(json),
        'assistant' => SpeechAssistantTurn.fromJson(json),
        _ => UnknownSpeechTurn(rawJson: json),
      };

  /// Encodes the turn for the API.
  Map<String, dynamic> toJson();
}

/// A user audio turn.
final class SpeechUserTurn extends SpeechTurn {
  /// The user's audio.
  final SpeechTurnAudio audio;

  /// Creates a user audio turn.
  const SpeechUserTurn({required this.audio});

  /// Decodes a user turn.
  factory SpeechUserTurn.fromJson(Map<String, dynamic> json) {
    if (json['role'] != 'user') {
      throw FormatException('Expected speech user turn, got ${json['role']}');
    }
    return SpeechUserTurn(
      audio: SpeechTurnAudio.fromJson(json['audio'] as Map<String, dynamic>),
    );
  }

  /// Creates a copy with replacement audio.
  SpeechUserTurn copyWith({SpeechTurnAudio? audio}) =>
      SpeechUserTurn(audio: audio ?? this.audio);

  @override
  String get role => 'user';

  @override
  Map<String, dynamic> toJson() => {'role': role, 'audio': audio.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SpeechUserTurn && audio == other.audio;

  @override
  int get hashCode => Object.hash(role, audio);

  @override
  String toString() => 'SpeechUserTurn(audio: $audio)';
}

/// An assistant speech turn with its source text and the audio it produced.
final class SpeechAssistantTurn extends SpeechTurn {
  /// The text spoken during the turn.
  final String text;

  /// The audio produced during the turn.
  final SpeechTurnAudio audio;

  /// Creates an assistant speech turn.
  const SpeechAssistantTurn({required this.text, required this.audio});

  /// Decodes an assistant turn.
  factory SpeechAssistantTurn.fromJson(Map<String, dynamic> json) {
    if (json['role'] != 'assistant') {
      throw FormatException(
        'Expected speech assistant turn, got ${json['role']}',
      );
    }
    return SpeechAssistantTurn(
      text: json['text'] as String,
      audio: SpeechTurnAudio.fromJson(json['audio'] as Map<String, dynamic>),
    );
  }

  /// Creates a copy with replacement fields.
  SpeechAssistantTurn copyWith({String? text, SpeechTurnAudio? audio}) =>
      SpeechAssistantTurn(text: text ?? this.text, audio: audio ?? this.audio);

  @override
  String get role => 'assistant';

  @override
  Map<String, dynamic> toJson() => {
    'role': role,
    'text': text,
    'audio': audio.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAssistantTurn &&
          text == other.text &&
          audio == other.audio;

  @override
  int get hashCode => Object.hash(role, text, audio);

  @override
  String toString() =>
      'SpeechAssistantTurn(text: ${text.length} chars, audio: $audio)';
}

/// A speech history turn with an unrecognized role.
final class UnknownSpeechTurn extends SpeechTurn {
  /// The original wire object.
  final Map<String, dynamic> rawJson;

  /// Creates an unknown speech turn.
  const UnknownSpeechTurn({required this.rawJson});

  @override
  String get role => rawJson['role'] as String? ?? 'unknown';

  @override
  Map<String, dynamic> toJson() => {...rawJson};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSpeechTurn && mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSpeechTurn(role: $role)';
}
