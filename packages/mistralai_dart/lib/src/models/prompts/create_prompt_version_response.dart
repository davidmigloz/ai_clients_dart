import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response returned after creating a new prompt version.
@immutable
class CreatePromptVersionResponse {
  /// The version number assigned to the new (or deduplicated) version.
  final int? version;

  /// Whether the version was deduplicated against an existing identical
  /// version rather than newly created.
  final bool? deduplicated;

  /// Creates a [CreatePromptVersionResponse].
  const CreatePromptVersionResponse({this.version, this.deduplicated});

  /// Creates a [CreatePromptVersionResponse] from JSON.
  factory CreatePromptVersionResponse.fromJson(Map<String, dynamic> json) =>
      CreatePromptVersionResponse(
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
  CreatePromptVersionResponse copyWith({
    Object? version = unsetCopyWithValue,
    Object? deduplicated = unsetCopyWithValue,
  }) => CreatePromptVersionResponse(
    version: version == unsetCopyWithValue ? this.version : version as int?,
    deduplicated: deduplicated == unsetCopyWithValue
        ? this.deduplicated
        : deduplicated as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatePromptVersionResponse &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          deduplicated == other.deduplicated;

  @override
  int get hashCode => Object.hash(version, deduplicated);

  @override
  String toString() =>
      'CreatePromptVersionResponse(version: $version, deduplicated: $deduplicated)';
}
