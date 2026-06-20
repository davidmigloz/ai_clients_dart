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

  /// A description of the voice.
  final String? description;

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

  /// The duration in seconds the audio sample was trimmed to.
  final double? trimmedSeconds;

  /// Creates a [VoiceResponse].
  const VoiceResponse({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.userId,
    this.slug,
    this.gender,
    this.age,
    this.color,
    this.languages = const [],
    this.tags,
    this.retentionNotice = 30,
    this.trimmedSeconds,
  });

  /// Creates a [VoiceResponse] from JSON.
  factory VoiceResponse.fromJson(Map<String, dynamic> json) => VoiceResponse(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
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
    trimmedSeconds: (json['trimmed_seconds'] as num?)?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    'created_at': createdAt.toIso8601String(),
    if (userId != null) 'user_id': userId,
    if (slug != null) 'slug': slug,
    if (gender != null) 'gender': gender,
    if (age != null) 'age': age,
    if (color != null) 'color': color,
    'languages': languages,
    if (tags != null) 'tags': tags,
    'retention_notice': retentionNotice,
    if (trimmedSeconds != null) 'trimmed_seconds': trimmedSeconds,
  };

  /// Creates a copy with the given fields replaced.
  VoiceResponse copyWith({
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    DateTime? createdAt,
    Object? userId = unsetCopyWithValue,
    Object? slug = unsetCopyWithValue,
    Object? gender = unsetCopyWithValue,
    Object? age = unsetCopyWithValue,
    Object? color = unsetCopyWithValue,
    List<String>? languages,
    Object? tags = unsetCopyWithValue,
    int? retentionNotice,
    Object? trimmedSeconds = unsetCopyWithValue,
  }) => VoiceResponse(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    createdAt: createdAt ?? this.createdAt,
    userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
    slug: slug == unsetCopyWithValue ? this.slug : slug as String?,
    gender: gender == unsetCopyWithValue ? this.gender : gender as String?,
    age: age == unsetCopyWithValue ? this.age : age as int?,
    color: color == unsetCopyWithValue ? this.color : color as String?,
    languages: languages ?? this.languages,
    tags: tags == unsetCopyWithValue ? this.tags : tags as List<String>?,
    retentionNotice: retentionNotice ?? this.retentionNotice,
    trimmedSeconds: trimmedSeconds == unsetCopyWithValue
        ? this.trimmedSeconds
        : trimmedSeconds as double?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          userId == other.userId &&
          slug == other.slug &&
          gender == other.gender &&
          age == other.age &&
          color == other.color &&
          listsEqual(languages, other.languages) &&
          listsEqual(tags, other.tags) &&
          retentionNotice == other.retentionNotice &&
          trimmedSeconds == other.trimmedSeconds;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    userId,
    slug,
    gender,
    age,
    color,
    listHash(languages),
    listHash(tags),
    retentionNotice,
    trimmedSeconds,
  );

  @override
  String toString() =>
      'VoiceResponse(id: $id, '
      'name: $name, '
      'description: $description, '
      'createdAt: $createdAt, '
      'userId: $userId, '
      'slug: $slug, '
      'gender: $gender, '
      'age: $age, '
      'color: $color, '
      'languages: $languages, '
      'tags: $tags, '
      'retentionNotice: $retentionNotice, '
      'trimmedSeconds: $trimmedSeconds)';
}
