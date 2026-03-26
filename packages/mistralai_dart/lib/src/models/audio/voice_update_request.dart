import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to partially update voice metadata.
@immutable
class VoiceUpdateRequest {
  /// The voice name.
  final String? name;

  /// The voice gender.
  final String? gender;

  /// The voice age.
  final int? age;

  /// Languages supported by this voice.
  final List<String>? languages;

  /// Tags associated with this voice.
  final List<String>? tags;

  /// Creates a [VoiceUpdateRequest].
  const VoiceUpdateRequest({
    this.name,
    this.gender,
    this.age,
    this.languages,
    this.tags,
  });

  /// Creates a [VoiceUpdateRequest] from JSON.
  factory VoiceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      VoiceUpdateRequest(
        name: json['name'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        languages: (json['languages'] as List?)?.cast<String>(),
        tags: (json['tags'] as List?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (languages != null) 'languages': languages,
    if (tags != null) 'tags': tags,
  };

  /// Creates a copy with replaced values.
  VoiceUpdateRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? gender = unsetCopyWithValue,
    Object? age = unsetCopyWithValue,
    Object? languages = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
  }) {
    return VoiceUpdateRequest(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      gender: gender == unsetCopyWithValue ? this.gender : gender as String?,
      age: age == unsetCopyWithValue ? this.age : age as int?,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<String>?,
      tags: tags == unsetCopyWithValue ? this.tags : tags as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceUpdateRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          gender == other.gender &&
          age == other.age &&
          listsEqual(languages, other.languages) &&
          listsEqual(tags, other.tags);

  @override
  int get hashCode =>
      Object.hash(name, gender, age, listHash(languages), listHash(tags));

  @override
  String toString() =>
      'VoiceUpdateRequest(name: $name, '
      'gender: $gender, '
      'age: $age, '
      'languages: $languages, '
      'tags: $tags)';
}
