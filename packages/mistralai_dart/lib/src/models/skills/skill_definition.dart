import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'skill_asset_content.dart';

/// Versioned skill content.
@immutable
class SkillDefinition {
  /// Skill body content.
  final String? body;

  /// Model-facing trigger and usage description.
  final String? description;

  /// Additional files available to the skill, keyed by file path.
  final Map<String, SkillAssetContent>? assets;

  /// Creates a [SkillDefinition].
  const SkillDefinition({this.body, this.description, this.assets});

  /// Creates a [SkillDefinition] from JSON.
  factory SkillDefinition.fromJson(Map<String, dynamic> json) =>
      SkillDefinition(
        body: json['body'] as String?,
        description: json['description'] as String?,
        assets: (json['assets'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            key,
            SkillAssetContent.fromJson(value as Map<String, dynamic>),
          ),
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (body != null) 'body': body,
    if (description != null) 'description': description,
    if (assets != null)
      'assets': assets!.map((key, value) => MapEntry(key, value.toJson())),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  SkillDefinition copyWith({
    Object? body = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? assets = unsetCopyWithValue,
  }) => SkillDefinition(
    body: body == unsetCopyWithValue ? this.body : body as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    assets: assets == unsetCopyWithValue
        ? this.assets
        : assets as Map<String, SkillAssetContent>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillDefinition &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          description == other.description &&
          mapsEqual(assets, other.assets);

  @override
  int get hashCode => Object.hash(body, description, mapHash(assets));

  @override
  String toString() =>
      'SkillDefinition(body: ${body?.length} chars, description: $description, '
      'assets: ${assets?.length})';
}
