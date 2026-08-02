import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../registry/registry_sharing_scope.dart';
import 'skill_definition.dart';

/// Request body to create a new skill.
@immutable
class CreateSkillRequest {
  /// Stable object name.
  final String name;

  /// Definition for the initial version.
  final SkillDefinition definition;

  /// Notes for this version.
  final String? notes;

  /// Registry sharing scope.
  final RegistrySharingScope? sharingScope;

  /// Aliases pointing to this version.
  final List<String>? aliases;

  /// Creates a [CreateSkillRequest].
  const CreateSkillRequest({
    required this.name,
    required this.definition,
    this.notes,
    this.sharingScope,
    this.aliases,
  });

  /// Creates a [CreateSkillRequest] from JSON.
  ///
  /// Throws a [FormatException] if [name] or [definition] are missing or
  /// null.
  factory CreateSkillRequest.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final definition = json['definition'];
    if (name is! String || definition is! Map<String, dynamic>) {
      throw FormatException(
        'Missing or invalid "name"/"definition" field: $json',
      );
    }
    return CreateSkillRequest(
      name: name,
      definition: SkillDefinition.fromJson(definition),
      notes: json['notes'] as String?,
      sharingScope: RegistrySharingScope.fromString(
        json['sharingScope'] as String?,
      ),
      aliases: (json['aliases'] as List?)?.map((e) => e as String).toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'definition': definition.toJson(),
    if (notes != null) 'notes': notes,
    if (sharingScope != null) 'sharingScope': sharingScope!.value,
    if (aliases != null) 'aliases': aliases,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  CreateSkillRequest copyWith({
    String? name,
    SkillDefinition? definition,
    Object? notes = unsetCopyWithValue,
    Object? sharingScope = unsetCopyWithValue,
    Object? aliases = unsetCopyWithValue,
  }) => CreateSkillRequest(
    name: name ?? this.name,
    definition: definition ?? this.definition,
    notes: notes == unsetCopyWithValue ? this.notes : notes as String?,
    sharingScope: sharingScope == unsetCopyWithValue
        ? this.sharingScope
        : sharingScope as RegistrySharingScope?,
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSkillRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          definition == other.definition &&
          notes == other.notes &&
          sharingScope == other.sharingScope &&
          listsEqual(aliases, other.aliases);

  @override
  int get hashCode =>
      Object.hash(name, definition, notes, sharingScope, listHash(aliases));

  @override
  String toString() =>
      'CreateSkillRequest(name: $name, definition: $definition, notes: $notes, '
      'sharingScope: $sharingScope, aliases: $aliases)';
}
