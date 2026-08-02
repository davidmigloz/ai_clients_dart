import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'prompt_definition.dart';

/// A single version of a registered prompt.
@immutable
class PromptVersion {
  /// The version number.
  final int? version;

  /// Definition of this version.
  final PromptDefinition? definition;

  /// Notes for this version.
  final String? notes;

  /// Aliases pointing to this version.
  final List<String>? aliases;

  /// Creation time.
  final String? createdAt;

  /// Creates a [PromptVersion].
  const PromptVersion({
    this.version,
    this.definition,
    this.notes,
    this.aliases,
    this.createdAt,
  });

  /// Creates a [PromptVersion] from JSON.
  factory PromptVersion.fromJson(Map<String, dynamic> json) => PromptVersion(
    version: json['version'] as int?,
    definition: json['definition'] != null
        ? PromptDefinition.fromJson(json['definition'] as Map<String, dynamic>)
        : null,
    notes: json['notes'] as String?,
    aliases: (json['aliases'] as List?)?.map((e) => e as String).toList(),
    createdAt: json['createdAt'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (version != null) 'version': version,
    if (definition != null) 'definition': definition!.toJson(),
    if (notes != null) 'notes': notes,
    if (aliases != null) 'aliases': aliases,
    if (createdAt != null) 'createdAt': createdAt,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  PromptVersion copyWith({
    Object? version = unsetCopyWithValue,
    Object? definition = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
    Object? aliases = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
  }) => PromptVersion(
    version: version == unsetCopyWithValue ? this.version : version as int?,
    definition: definition == unsetCopyWithValue
        ? this.definition
        : definition as PromptDefinition?,
    notes: notes == unsetCopyWithValue ? this.notes : notes as String?,
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as List<String>?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptVersion &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          definition == other.definition &&
          notes == other.notes &&
          listsEqual(aliases, other.aliases) &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(version, definition, notes, listHash(aliases), createdAt);

  @override
  String toString() =>
      'PromptVersion(version: $version, definition: $definition, '
      'notes: $notes, aliases: $aliases, createdAt: $createdAt)';
}
