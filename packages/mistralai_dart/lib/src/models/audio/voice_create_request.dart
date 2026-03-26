import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to create a custom voice with base64 audio.
@immutable
class VoiceCreateRequest {
  /// The voice name.
  final String name;

  /// Base64-encoded audio file.
  final String sampleAudio;

  /// The voice slug identifier.
  final String? slug;

  /// The voice gender.
  final String? gender;

  /// The voice age.
  final int? age;

  /// The voice color/theme.
  final String? color;

  /// Languages supported by this voice.
  final List<String>? languages;

  /// Tags associated with this voice.
  final List<String>? tags;

  /// Retention notice period in days.
  final int? retentionNotice;

  /// Original filename for extension detection.
  final String? sampleFilename;

  /// Creates a [VoiceCreateRequest].
  const VoiceCreateRequest({
    required this.name,
    required this.sampleAudio,
    this.slug,
    this.gender,
    this.age,
    this.color,
    this.languages,
    this.tags,
    this.retentionNotice,
    this.sampleFilename,
  });

  /// Creates a [VoiceCreateRequest] from JSON.
  factory VoiceCreateRequest.fromJson(Map<String, dynamic> json) =>
      VoiceCreateRequest(
        name: json['name'] as String? ?? '',
        sampleAudio: json['sample_audio'] as String? ?? '',
        slug: json['slug'] as String?,
        gender: json['gender'] as String?,
        age: json['age'] as int?,
        color: json['color'] as String?,
        languages: (json['languages'] as List?)?.cast<String>(),
        tags: (json['tags'] as List?)?.cast<String>(),
        retentionNotice: json['retention_notice'] as int?,
        sampleFilename: json['sample_filename'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'sample_audio': sampleAudio,
    if (slug != null) 'slug': slug,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (color != null) 'color': color,
    if (languages != null) 'languages': languages,
    if (tags != null) 'tags': tags,
    if (retentionNotice != null) 'retention_notice': retentionNotice,
    if (sampleFilename != null) 'sample_filename': sampleFilename,
  };

  /// Creates a copy with replaced values.
  VoiceCreateRequest copyWith({
    String? name,
    String? sampleAudio,
    Object? slug = unsetCopyWithValue,
    Object? gender = unsetCopyWithValue,
    Object? age = unsetCopyWithValue,
    Object? color = unsetCopyWithValue,
    Object? languages = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
    Object? retentionNotice = unsetCopyWithValue,
    Object? sampleFilename = unsetCopyWithValue,
  }) {
    return VoiceCreateRequest(
      name: name ?? this.name,
      sampleAudio: sampleAudio ?? this.sampleAudio,
      slug: slug == unsetCopyWithValue ? this.slug : slug as String?,
      gender: gender == unsetCopyWithValue ? this.gender : gender as String?,
      age: age == unsetCopyWithValue ? this.age : age as int?,
      color: color == unsetCopyWithValue ? this.color : color as String?,
      languages: languages == unsetCopyWithValue
          ? this.languages
          : languages as List<String>?,
      tags: tags == unsetCopyWithValue ? this.tags : tags as List<String>?,
      retentionNotice: retentionNotice == unsetCopyWithValue
          ? this.retentionNotice
          : retentionNotice as int?,
      sampleFilename: sampleFilename == unsetCopyWithValue
          ? this.sampleFilename
          : sampleFilename as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceCreateRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          sampleAudio == other.sampleAudio &&
          slug == other.slug &&
          gender == other.gender &&
          age == other.age &&
          color == other.color &&
          listsEqual(languages, other.languages) &&
          listsEqual(tags, other.tags) &&
          retentionNotice == other.retentionNotice &&
          sampleFilename == other.sampleFilename;

  @override
  int get hashCode => Object.hash(
    name,
    sampleAudio,
    slug,
    gender,
    age,
    color,
    listHash(languages),
    listHash(tags),
    retentionNotice,
    sampleFilename,
  );

  @override
  String toString() =>
      'VoiceCreateRequest(name: $name, '
      'sampleAudio: ${sampleAudio.length} chars, '
      'slug: $slug, '
      'gender: $gender, '
      'age: $age, '
      'color: $color, '
      'languages: $languages, '
      'tags: $tags, '
      'retentionNotice: $retentionNotice, '
      'sampleFilename: $sampleFilename)';
}
