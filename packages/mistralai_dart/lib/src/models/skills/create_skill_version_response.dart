import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response returned after creating a new skill version.
@immutable
class CreateSkillVersionResponse {
  /// The version number assigned to the new (or deduplicated) version.
  final int? version;

  /// Whether the version was deduplicated against an existing identical
  /// version rather than newly created.
  final bool? deduplicated;

  /// Creates a [CreateSkillVersionResponse].
  const CreateSkillVersionResponse({this.version, this.deduplicated});

  /// Creates a [CreateSkillVersionResponse] from JSON.
  factory CreateSkillVersionResponse.fromJson(Map<String, dynamic> json) =>
      CreateSkillVersionResponse(
        version: json['version'] as int?,
        deduplicated: json['deduplicated'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (version != null) 'version': version,
    if (deduplicated != null) 'deduplicated': deduplicated,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  CreateSkillVersionResponse copyWith({
    Object? version = unsetCopyWithValue,
    Object? deduplicated = unsetCopyWithValue,
  }) => CreateSkillVersionResponse(
    version: version == unsetCopyWithValue ? this.version : version as int?,
    deduplicated: deduplicated == unsetCopyWithValue
        ? this.deduplicated
        : deduplicated as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSkillVersionResponse &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          deduplicated == other.deduplicated;

  @override
  int get hashCode => Object.hash(version, deduplicated);

  @override
  String toString() =>
      'CreateSkillVersionResponse(version: $version, deduplicated: $deduplicated)';
}
