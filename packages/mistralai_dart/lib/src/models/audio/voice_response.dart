import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Response containing voice information.
@immutable
class VoiceResponse {
  /// The voice ID.
  final String id;

  /// The voice name.
  final String name;

  /// When the voice was created.
  final DateTime createdAt;

  /// The user who created the voice.
  final String? userId;

  /// The voice slug identifier.
  final String? slug;

  /// The voice gender.
  final String? gender;

  /// The voice age.
  final int? age;

  /// The voice color/theme.
  final String? color;

  /// Languages supported by this voice.
  final List<String> languages;

  /// Tags associated with this voice.
  final List<String>? tags;

  /// Retention notice period in days.
  final int retentionNotice;

  /// Creates a [VoiceResponse].
  const VoiceResponse({
    required this.id,
    required this.name,
    required this.createdAt,
    this.userId,
    this.slug,
    this.gender,
    this.age,
    this.color,
    this.languages = const [],
    this.tags,
    this.retentionNotice = 30,
  });

  /// Creates a [VoiceResponse] from JSON.
  factory VoiceResponse.fromJson(Map<String, dynamic> json) => VoiceResponse(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.utc(1970),
    userId: json['user_id'] as String?,
    slug: json['slug'] as String?,
    gender: json['gender'] as String?,
    age: json['age'] as int?,
    color: json['color'] as String?,
    languages: (json['languages'] as List?)?.cast<String>() ?? const [],
    tags: (json['tags'] as List?)?.cast<String>(),
    retentionNotice: json['retention_notice'] as int? ?? 30,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt.toIso8601String(),
    if (userId != null) 'user_id': userId,
    if (slug != null) 'slug': slug,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (color != null) 'color': color,
    'languages': languages,
    if (tags != null) 'tags': tags,
    'retention_notice': retentionNotice,
  };

  /// Creates a copy with the given fields replaced.
  VoiceResponse copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Object? userId = unsetCopyWithValue,
    Object? slug = unsetCopyWithValue,
    Object? gender = unsetCopyWithValue,
    Object? age = unsetCopyWithValue,
    Object? color = unsetCopyWithValue,
    List<String>? languages,
    Object? tags = unsetCopyWithValue,
    int? retentionNotice,
  }) => VoiceResponse(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
    slug: slug == unsetCopyWithValue ? this.slug : slug as String?,
    gender: gender == unsetCopyWithValue ? this.gender : gender as String?,
    age: age == unsetCopyWithValue ? this.age : age as int?,
    color: color == unsetCopyWithValue ? this.color : color as String?,
    languages: languages ?? this.languages,
    tags: tags == unsetCopyWithValue ? this.tags : tags as List<String>?,
    retentionNotice: retentionNotice ?? this.retentionNotice,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          userId == other.userId &&
          slug == other.slug &&
          gender == other.gender &&
          age == other.age &&
          color == other.color &&
          listsEqual(languages, other.languages) &&
          listsEqual(tags, other.tags) &&
          retentionNotice == other.retentionNotice;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    createdAt,
    userId,
    slug,
    gender,
    age,
    color,
    listHash(languages),
    listHash(tags),
    retentionNotice,
  );

  @override
  String toString() =>
      'VoiceResponse(id: $id, '
      'name: $name, '
      'createdAt: $createdAt, '
      'userId: $userId, '
      'slug: $slug, '
      'gender: $gender, '
      'age: $age, '
      'color: $color, '
      'languages: $languages, '
      'tags: $tags, '
      'retentionNotice: $retentionNotice)';
}
