import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'connector_locale.dart';
import 'resource_visibility.dart';

/// A tool exposed by a connector.
@immutable
class ConnectorTool {
  /// The unique identifier of the tool.
  final String id;

  /// The tool name.
  final String name;

  /// The tool description.
  final String description;

  /// The execution configuration for the tool (freeform).
  final Map<String, dynamic>? executionConfig;

  /// The tool visibility.
  final ResourceVisibility visibility;

  /// When the tool was created.
  final DateTime createdAt;

  /// When the tool was last modified.
  final DateTime modifiedAt;

  /// An optional system prompt scoped to this tool.
  final String? systemPrompt;

  /// Localized strings for the tool.
  final ConnectorLocale? locale;

  /// The JSON schema of the tool's input.
  final Map<String, dynamic>? jsonschema;

  /// Whether the tool is active.
  final bool? active;

  /// Creates a [ConnectorTool].
  const ConnectorTool({
    required this.id,
    required this.name,
    required this.description,
    required this.executionConfig,
    required this.visibility,
    required this.createdAt,
    required this.modifiedAt,
    this.systemPrompt,
    this.locale,
    this.jsonschema,
    this.active,
  });

  /// Creates a [ConnectorTool] from JSON.
  factory ConnectorTool.fromJson(Map<String, dynamic> json) => ConnectorTool(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    executionConfig: json['execution_config'] as Map<String, dynamic>?,
    visibility: ResourceVisibility.fromJson(json['visibility'] as String?),
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.utc(1970),
    modifiedAt:
        DateTime.tryParse(json['modified_at'] as String? ?? '') ??
        DateTime.utc(1970),
    systemPrompt: json['system_prompt'] as String?,
    locale: json['locale'] != null
        ? ConnectorLocale.fromJson(json['locale'] as Map<String, dynamic>)
        : null,
    jsonschema: json['jsonschema'] as Map<String, dynamic>?,
    active: json['active'] as bool?,
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'execution_config': executionConfig,
    'visibility': visibility.toJson(),
    'created_at': createdAt.toIso8601String(),
    'modified_at': modifiedAt.toIso8601String(),
    if (systemPrompt != null) 'system_prompt': systemPrompt,
    if (locale != null) 'locale': locale!.toJson(),
    if (jsonschema != null) 'jsonschema': jsonschema,
    if (active != null) 'active': active,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  ConnectorTool copyWith({
    String? id,
    String? name,
    String? description,
    Object? executionConfig = unsetCopyWithValue,
    ResourceVisibility? visibility,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Object? systemPrompt = unsetCopyWithValue,
    Object? locale = unsetCopyWithValue,
    Object? jsonschema = unsetCopyWithValue,
    Object? active = unsetCopyWithValue,
  }) => ConnectorTool(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    executionConfig: executionConfig == unsetCopyWithValue
        ? this.executionConfig
        : executionConfig as Map<String, dynamic>?,
    visibility: visibility ?? this.visibility,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    systemPrompt: systemPrompt == unsetCopyWithValue
        ? this.systemPrompt
        : systemPrompt as String?,
    locale: locale == unsetCopyWithValue
        ? this.locale
        : locale as ConnectorLocale?,
    jsonschema: jsonschema == unsetCopyWithValue
        ? this.jsonschema
        : jsonschema as Map<String, dynamic>?,
    active: active == unsetCopyWithValue ? this.active : active as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorTool &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          mapsDeepEqual(executionConfig, other.executionConfig) &&
          visibility == other.visibility &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          systemPrompt == other.systemPrompt &&
          locale == other.locale &&
          mapsDeepEqual(jsonschema, other.jsonschema) &&
          active == other.active;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    mapDeepHashCode(executionConfig),
    visibility,
    createdAt,
    modifiedAt,
    systemPrompt,
    locale,
    mapDeepHashCode(jsonschema),
    active,
  );

  @override
  String toString() =>
      'ConnectorTool('
      'id: $id, '
      'name: $name, '
      'description: $description, '
      'executionConfig: ${executionConfig?.length ?? 'null'} entries, '
      'visibility: $visibility, '
      'createdAt: $createdAt, '
      'modifiedAt: $modifiedAt, '
      'systemPrompt: $systemPrompt, '
      'locale: $locale, '
      'jsonschema: ${jsonschema?.length ?? 'null'} entries, '
      'active: $active)';
}
