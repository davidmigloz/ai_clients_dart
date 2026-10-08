import 'package:meta/meta.dart';

import '../common/json_helpers.dart';
import 'audio_json_helpers.dart';

/// Typed audio voice selection: an open name or a closed custom ID reference.
///
/// Built-in `SpeechVoice` values also implement this interface. Wire consumers
/// validate the returned shape even for caller-defined implementations.
@immutable
abstract interface class AudioVoice {
  /// Selects a named voice, preserving future provider names.
  const factory AudioVoice.named(String name) = NamedAudioVoice;

  /// References an existing custom voice by its opaque ID.
  const factory AudioVoice.custom(String id) = CustomAudioVoice;

  /// Parses a voice name or an exact custom `{id: string}` object.
  factory AudioVoice.fromJson(Object? json) {
    if (json is String) return NamedAudioVoice(json);
    return CustomAudioVoice.fromJson(requireJsonObject(json, 'AudioVoice'));
  }

  /// Returns a name string or a custom voice reference object.
  Object toJson();
}

/// A named voice, including names introduced by future models.
@immutable
final class NamedAudioVoice implements AudioVoice {
  /// Selects [name] without imposing a closed list or an invented length limit.
  const NamedAudioVoice(this.name);

  /// Parses an open string voice name.
  factory NamedAudioVoice.fromJson(Object? json) =>
      NamedAudioVoice(requireJsonString(json, 'NamedAudioVoice.name'));

  /// The provider's open voice name.
  final String name;

  @override
  String toJson() => name;

  /// Copies the voice name.
  NamedAudioVoice copyWith({String? name}) =>
      NamedAudioVoice(name ?? this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NamedAudioVoice && name == other.name;

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() => 'NamedAudioVoice(name: [REDACTED])';
}

/// A closed writable reference to a previously created custom voice.
@immutable
final class CustomAudioVoice implements AudioVoice {
  /// References [id]; the Speech/Chat reference imposes no ID prefix or length.
  const CustomAudioVoice(this.id);

  /// Requires an exact object containing a nonnull string ID.
  factory CustomAudioVoice.fromJson(Map<String, dynamic> json) {
    final snapshot = snapshotAudioJson(
      json,
      'CustomAudioVoice',
      knownKeys: const {'id'},
    );
    requireClosedAudioJson(snapshot, const {'id'}, 'CustomAudioVoice');
    return CustomAudioVoice(
      requireJsonString(snapshot['id'], 'CustomAudioVoice.id'),
    );
  }

  /// The opaque custom voice ID.
  final String id;

  @override
  Map<String, dynamic> toJson() => {'id': id};

  /// Copies the custom reference ID.
  CustomAudioVoice copyWith({String? id}) => CustomAudioVoice(id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CustomAudioVoice && id == other.id;

  @override
  int get hashCode => Object.hash(runtimeType, id);

  @override
  String toString() => 'CustomAudioVoice(id: [REDACTED])';
}
