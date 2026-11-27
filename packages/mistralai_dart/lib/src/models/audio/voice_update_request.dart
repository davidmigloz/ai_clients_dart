import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A nullable field that can be explicitly cleared in a voice update.
enum VoiceUpdateField {
  /// The display name.
  name('name'),

  /// The voice description.
  description('description'),

  /// The gender label.
  gender('gender'),

  /// The age of the voice.
  age('age'),

  /// Supported language labels.
  languages('languages'),

  /// Voice tags.
  tags('tags'),

  /// Retention period in days.
  retentionNotice('retention_notice');

  const VoiceUpdateField(this.value);

  /// The corresponding JSON key.
  final String value;
}

/// Request to partially update voice metadata.
@immutable
class VoiceUpdateRequest {
  /// The voice name.
  final String? name;

  /// A description of the voice.
  final String? description;

  /// The voice gender.
  final String? gender;

  /// The voice age.
  final int? age;

  /// Languages supported by this voice.
  final List<String>? languages;

  /// Tags associated with this voice.
  final List<String>? tags;

  /// Retention notice period in days.
  final int? retentionNotice;

  /// Fields to send as explicit JSON null. A supplied non-null value takes
  /// precedence over the corresponding entry in this set.
  final Set<VoiceUpdateField> clearFields;

  /// Creates a [VoiceUpdateRequest].
  const VoiceUpdateRequest({
    this.name,
    this.description,
    this.gender,
    this.age,
    this.languages,
    this.tags,
    this.retentionNotice,
    this.clearFields = const {},
  });

  /// Creates a [VoiceUpdateRequest] from JSON.
  factory VoiceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      VoiceUpdateRequest(
        name: json['name'] as String?,
        description: json['description'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        languages: (json['languages'] as List?)?.cast<String>(),
        tags: (json['tags'] as List?)?.cast<String>(),
        retentionNotice: json['retention_notice'] as int?,
        clearFields: {
          for (final field in VoiceUpdateField.values)
            if (json.containsKey(field.value) && json[field.value] == null)
              field,
        },
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    for (final field in clearFields) field.value: null,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (languages != null) 'languages': languages,
    if (tags != null) 'tags': tags,
    if (retentionNotice != null) 'retention_notice': retentionNotice,
  };

  /// Creates a copy with replaced values.
  VoiceUpdateRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? gender = unsetCopyWithValue,
    Object? age = unsetCopyWithValue,
    Object? languages = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
    Object? retentionNotice = unsetCopyWithValue,
    Set<VoiceUpdateField>? clearFields,
  }) {
    return VoiceUpdateRequest(
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      gender: gender == unsetCopyWithValue ? this.gender : gender as String?,
      age: age == unsetCopyWithValue ? this.age : age as int?,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<String>?,
      tags: tags == unsetCopyWithValue ? this.tags : tags as List<String>?,
      retentionNotice: retentionNotice == unsetCopyWithValue
          ? this.retentionNotice
          : retentionNotice as int?,
      clearFields: clearFields ?? this.clearFields,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceUpdateRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          gender == other.gender &&
          age == other.age &&
          listsEqual(languages, other.languages) &&
          listsEqual(tags, other.tags) &&
          retentionNotice == other.retentionNotice &&
          clearFields.length == other.clearFields.length &&
          clearFields.containsAll(other.clearFields);

  @override
  int get hashCode => Object.hash(
    name,
    description,
    gender,
    age,
    listHash(languages),
    listHash(tags),
    retentionNotice,
    Object.hashAllUnordered(clearFields),
  );

  @override
  String toString() =>
      'VoiceUpdateRequest(name: $name, '
      'description: $description, '
      'gender: $gender, '
      'age: $age, '
      'languages: $languages, '
      'tags: $tags, '
      'retentionNotice: $retentionNotice, clearFields: $clearFields)';
}
