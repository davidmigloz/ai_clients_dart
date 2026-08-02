import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../registry/registry_sharing_scope.dart';
import 'prompt_definition.dart';

/// A registered prompt object.
@immutable
class Prompt {
  /// Unique identifier for the prompt.
  final String id;

  /// Stable object name.
  final String? name;

  /// Display title.
  final String? title;

  /// Display description.
  final String? description;

  /// Latest version number.
  final int? latestVersion;

  /// The version returned by this response.
  final int? version;

  /// Definition of this version.
  final PromptDefinition? definition;

  /// Notes for this version.
  final String? notes;

  /// Aliases pointing to this version.
  final List<String>? aliases;

  /// Registry sharing scope.
  final RegistrySharingScope? sharingScope;

  /// Creation time.
  final String? createdAt;

  /// Last update time.
  final String? updatedAt;

  /// Creates a [Prompt].
  const Prompt({
    required this.id,
    this.name,
    this.title,
    this.description,
    this.latestVersion,
    this.version,
    this.definition,
    this.notes,
    this.aliases,
    this.sharingScope,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [Prompt] from JSON.
  factory Prompt.fromJson(Map<String, dynamic> json) => Prompt(
    id: json['id'] as String? ?? '',
    name: json['name'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    latestVersion: json['latestVersion'] as int?,
    version: json['version'] as int?,
    definition: json['definition'] != null
        ? PromptDefinition.fromJson(json['definition'] as Map<String, dynamic>)
        : null,
    notes: json['notes'] as String?,
    aliases: (json['aliases'] as List?)?.map((e) => e as String).toList(),
    sharingScope: RegistrySharingScope.fromString(
      json['sharingScope'] as String?,
    ),
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (name != null) 'name': name,
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (latestVersion != null) 'latestVersion': latestVersion,
    if (version != null) 'version': version,
    if (definition != null) 'definition': definition!.toJson(),
    if (notes != null) 'notes': notes,
    if (aliases != null) 'aliases': aliases,
    if (sharingScope != null) 'sharingScope': sharingScope!.value,
    if (createdAt != null) 'createdAt': createdAt,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  Prompt copyWith({
    String? id,
    Object? name = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? latestVersion = unsetCopyWithValue,
    Object? version = unsetCopyWithValue,
    Object? definition = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
    Object? aliases = unsetCopyWithValue,
    Object? sharingScope = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? updatedAt = unsetCopyWithValue,
  }) => Prompt(
    id: id ?? this.id,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    title: title == unsetCopyWithValue ? this.title : title as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    latestVersion: latestVersion == unsetCopyWithValue
        ? this.latestVersion
        : latestVersion as int?,
    version: version == unsetCopyWithValue ? this.version : version as int?,
    definition: definition == unsetCopyWithValue
        ? this.definition
        : definition as PromptDefinition?,
    notes: notes == unsetCopyWithValue ? this.notes : notes as String?,
    aliases: aliases == unsetCopyWithValue
        ? this.aliases
        : aliases as List<String>?,
    sharingScope: sharingScope == unsetCopyWithValue
        ? this.sharingScope
        : sharingScope as RegistrySharingScope?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    updatedAt: updatedAt == unsetCopyWithValue
        ? this.updatedAt
        : updatedAt as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prompt &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          title == other.title &&
          description == other.description &&
          latestVersion == other.latestVersion &&
          version == other.version &&
          definition == other.definition &&
          notes == other.notes &&
          listsEqual(aliases, other.aliases) &&
          sharingScope == other.sharingScope &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    title,
    description,
    latestVersion,
    version,
    definition,
    notes,
    listHash(aliases),
    sharingScope,
    Object.hash(createdAt, updatedAt),
  );

  @override
  String toString() =>
      'Prompt(id: $id, name: $name, title: $title, description: $description, '
      'latestVersion: $latestVersion, version: $version, definition: $definition, '
      'notes: $notes, aliases: $aliases, sharingScope: $sharingScope, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}
