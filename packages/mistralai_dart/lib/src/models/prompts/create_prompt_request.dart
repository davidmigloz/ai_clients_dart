import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../registry/registry_sharing_scope.dart';
import 'prompt_definition.dart';

/// Request body to create a new prompt.
@immutable
class CreatePromptRequest {
  /// Stable object name.
  final String name;

  /// Definition for the initial version.
  final PromptDefinition definition;

  /// Display title.
  final String? title;

  /// Display description.
  final String? description;

  /// Notes for this version.
  final String? notes;

  /// Registry sharing scope.
  final RegistrySharingScope? sharingScope;

  /// Aliases pointing to this version.
  final List<String>? aliases;

  /// Creates a [CreatePromptRequest].
  const CreatePromptRequest({
    required this.name,
    required this.definition,
    this.title,
    this.description,
    this.notes,
    this.sharingScope,
    this.aliases,
  });

  /// Creates a [CreatePromptRequest] from JSON.
  ///
  /// Throws a [FormatException] if [name] or [definition] are missing or
  /// null.
  factory CreatePromptRequest.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final definition = json['definition'];
    if (name is! String || definition is! Map<String, dynamic>) {
      throw FormatException(
        'Missing or invalid "name"/"definition" field: $json',
      );
    }
    return CreatePromptRequest(
      name: name,
      definition: PromptDefinition.fromJson(definition),
      title: json['title'] as String?,
      description: json['description'] as String?,
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
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (notes != null) 'notes': notes,
    if (sharingScope != null) 'sharingScope': sharingScope!.value,
    if (aliases != null) 'aliases': aliases,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  CreatePromptRequest copyWith({
    String? name,
    PromptDefinition? definition,
    Object? title = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? notes = unsetCopyWithValue,
    Object? sharingScope = unsetCopyWithValue,
    Object? aliases = unsetCopyWithValue,
  }) => CreatePromptRequest(
    name: name ?? this.name,
    definition: definition ?? this.definition,
    title: title == unsetCopyWithValue ? this.title : title as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
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
      other is CreatePromptRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          definition == other.definition &&
          title == other.title &&
          description == other.description &&
          notes == other.notes &&
          sharingScope == other.sharingScope &&
          listsEqual(aliases, other.aliases);

  @override
  int get hashCode => Object.hash(
    name,
    definition,
    title,
    description,
    notes,
    sharingScope,
    listHash(aliases),
  );

  @override
  String toString() =>
      'CreatePromptRequest(name: $name, definition: $definition, title: $title, '
      'description: $description, notes: $notes, sharingScope: $sharingScope, '
      'aliases: $aliases)';
}
