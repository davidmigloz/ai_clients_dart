import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'container_json_helpers.dart';

/// A skill configured in a container, referenced by ID or supplied inline.
///
/// This configuration is distinct from a Skills API resource.
sealed class ContainerSkill {
  /// Creates a [ContainerSkill].
  const ContainerSkill();

  /// Creates a reference to an uploaded skill.
  const factory ContainerSkill.reference({
    required String skillId,
    String? version,
  }) = ContainerSkillReference;

  /// Creates a skill supplied as an inline bundle.
  const factory ContainerSkill.inline({
    required String name,
    required String description,
    required ContainerSkillSource source,
  }) = InlineContainerSkill;

  /// Creates a skill from JSON, preserving future object variants.
  factory ContainerSkill.fromJson(Map<String, dynamic> json) {
    final type = requireContainerString(json['type'], 'ContainerSkill.type');
    return switch (type) {
      'skill_reference' => ContainerSkillReference.fromJson(json),
      'inline' => InlineContainerSkill.fromJson(json),
      _ => UnknownContainerSkill(json),
    };
  }

  /// The skill's API discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A reference to a skill uploaded through the Skills API.
@immutable
class ContainerSkillReference extends ContainerSkill {
  /// Creates a skill reference.
  const ContainerSkillReference({required this.skillId, this.version});

  /// Creates a skill reference from JSON.
  factory ContainerSkillReference.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'skill_reference', 'ContainerSkillReference');
    return ContainerSkillReference(
      skillId: requireContainerString(
        json['skill_id'],
        'ContainerSkillReference.skill_id',
      ),
      version: optionalContainerString(
        json,
        'version',
        'ContainerSkillReference',
      ),
    );
  }

  /// The skill ID. The server requires 1–64 characters.
  final String skillId;

  /// The version, such as `7` or `latest`; omission selects the default.
  ///
  /// Numeric versions are strings on the wire.
  final String? version;

  @override
  String get type => 'skill_reference';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'skill_id': skillId,
    if (version != null) 'version': version,
  };

  /// Creates a copy; pass `version: null` to select the default version.
  ContainerSkillReference copyWith({
    String? skillId,
    Object? version = unsetCopyWithValue,
  }) => ContainerSkillReference(
    skillId: skillId ?? this.skillId,
    version: version == unsetCopyWithValue ? this.version : version as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerSkillReference &&
          runtimeType == other.runtimeType &&
          skillId == other.skillId &&
          version == other.version;

  @override
  int get hashCode => Object.hash(skillId, version);

  @override
  String toString() =>
      'ContainerSkillReference(skillId: $skillId, version: $version)';
}

/// A skill supplied inline with its ZIP source.
@immutable
class InlineContainerSkill extends ContainerSkill {
  /// Creates an inline skill.
  const InlineContainerSkill({
    required this.name,
    required this.description,
    required this.source,
  });

  /// Creates an inline skill from JSON.
  factory InlineContainerSkill.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'inline', 'InlineContainerSkill');
    return InlineContainerSkill(
      name: requireContainerString(json['name'], 'InlineContainerSkill.name'),
      description: requireContainerString(
        json['description'],
        'InlineContainerSkill.description',
      ),
      source: ContainerSkillSource.fromJson(
        requireContainerMap(json['source'], 'InlineContainerSkill.source'),
      ),
    );
  }

  /// The skill name.
  final String name;

  /// The skill description.
  final String description;

  /// The inline bundle, whose data is excluded from string diagnostics.
  final ContainerSkillSource source;

  @override
  String get type => 'inline';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'source': source.toJson(),
  };

  /// Creates a copy with replaced values.
  InlineContainerSkill copyWith({
    String? name,
    String? description,
    ContainerSkillSource? source,
  }) => InlineContainerSkill(
    name: name ?? this.name,
    description: description ?? this.description,
    source: source ?? this.source,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineContainerSkill &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          source == other.source;

  @override
  int get hashCode => Object.hash(name, description, source);

  @override
  String toString() =>
      'InlineContainerSkill(name: $name, description: $description, '
      'source: $source)';
}

/// A future skill variant retaining its complete immutable JSON payload.
@immutable
class UnknownContainerSkill extends ContainerSkill {
  /// Creates an unknown skill with a defensive JSON snapshot.
  UnknownContainerSkill(Map<String, dynamic> rawJson)
    : type = requireContainerString(
        rawJson['type'],
        'UnknownContainerSkill.type',
      ),
      rawJson = freezeContainerJsonMap(rawJson);

  /// Creates an unknown skill from JSON.
  factory UnknownContainerSkill.fromJson(Map<String, dynamic> json) =>
      UnknownContainerSkill(json);

  @override
  final String type;

  /// The recursively unmodifiable original JSON.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with a replaced raw payload.
  UnknownContainerSkill copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownContainerSkill(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownContainerSkill &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownContainerSkill(type: $type)';
}

/// The source of an inline skill bundle.
sealed class ContainerSkillSource {
  /// Creates a [ContainerSkillSource].
  const ContainerSkillSource();

  /// Creates a ZIP source from an already base64-encoded string.
  const factory ContainerSkillSource.base64({required String data}) =
      Base64ContainerSkillSource;

  /// Creates a source from JSON, preserving future object variants.
  factory ContainerSkillSource.fromJson(Map<String, dynamic> json) {
    final type = requireContainerString(
      json['type'],
      'ContainerSkillSource.type',
    );
    return switch (type) {
      'base64' => Base64ContainerSkillSource.fromJson(json),
      _ => UnknownContainerSkillSource(json),
    };
  }

  /// The source's API discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An inline skill ZIP bundle represented as raw base64 data.
@immutable
class Base64ContainerSkillSource extends ContainerSkillSource {
  /// Creates a source without decoding or rewriting [data].
  const Base64ContainerSkillSource({required this.data});

  /// Creates a base64 ZIP source from JSON.
  factory Base64ContainerSkillSource.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'base64', 'Base64ContainerSkillSource');
    if (json['media_type'] != 'application/zip') {
      throw const FormatException(
        'Base64ContainerSkillSource.media_type: expected "application/zip"',
      );
    }
    return Base64ContainerSkillSource(
      data: requireContainerString(
        json['data'],
        'Base64ContainerSkillSource.data',
      ),
    );
  }

  /// The exact base64-encoded ZIP bundle, excluded from string diagnostics.
  ///
  /// The server requires 1–70,254,592 characters.
  final String data;

  @override
  String get type => 'base64';

  /// The fixed media type of the bundle.
  String get mediaType => 'application/zip';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'media_type': mediaType,
    'data': data,
  };

  /// Creates a copy with replaced bundle data.
  Base64ContainerSkillSource copyWith({String? data}) =>
      Base64ContainerSkillSource(data: data ?? this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Base64ContainerSkillSource &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Base64ContainerSkillSource(data: [REDACTED])';
}

/// A future skill source retaining its complete immutable JSON payload.
@immutable
class UnknownContainerSkillSource extends ContainerSkillSource {
  /// Creates an unknown source with a defensive JSON snapshot.
  UnknownContainerSkillSource(Map<String, dynamic> rawJson)
    : type = requireContainerString(
        rawJson['type'],
        'UnknownContainerSkillSource.type',
      ),
      rawJson = freezeContainerJsonMap(rawJson);

  /// Creates an unknown source from JSON.
  factory UnknownContainerSkillSource.fromJson(Map<String, dynamic> json) =>
      UnknownContainerSkillSource(json);

  @override
  final String type;

  /// The recursively unmodifiable original JSON.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with a replaced raw payload.
  UnknownContainerSkillSource copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownContainerSkillSource(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownContainerSkillSource &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownContainerSkillSource(type: $type)';
}
