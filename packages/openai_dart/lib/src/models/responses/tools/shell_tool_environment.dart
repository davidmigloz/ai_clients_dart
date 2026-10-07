import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';
import '../../containers/container_memory_limit.dart';
import '../../containers/container_network_policy.dart';
import '../../containers/container_skill.dart';

/// Environment configured on a shell tool definition.
///
/// Supports [ContainerAutoShellToolEnvironment], [LocalShellToolEnvironment],
/// [ContainerReferenceShellToolEnvironment], and [UnknownShellToolEnvironment].
/// The returned shell-call environment has a separate contract.
sealed class ShellToolEnvironment {
  /// Creates a [ShellToolEnvironment].
  const ShellToolEnvironment();

  /// Automatically creates a hosted container with optional files and skills.
  factory ShellToolEnvironment.containerAuto({
    List<String>? fileIds,
    ContainerMemoryLimit? memoryLimit,
    ContainerNetworkPolicy? networkPolicy,
    List<ContainerSkill>? skills,
  }) = ContainerAutoShellToolEnvironment;

  /// Uses a local computer, optionally describing locally available skills.
  factory ShellToolEnvironment.local({List<ShellLocalSkill>? skills}) =
      LocalShellToolEnvironment;

  /// Uses a previously created container.
  const factory ShellToolEnvironment.containerReference({
    required String containerId,
  }) = ContainerReferenceShellToolEnvironment;

  /// Parses known environments strictly and preserves future variants.
  factory ShellToolEnvironment.fromJson(Map<String, dynamic> json) {
    final type = requireJsonString(json['type'], 'ShellToolEnvironment.type');
    return switch (type) {
      'container_auto' => ContainerAutoShellToolEnvironment.fromJson(json),
      'local' => LocalShellToolEnvironment.fromJson(json),
      'container_reference' => ContainerReferenceShellToolEnvironment.fromJson(
        json,
      ),
      _ => UnknownShellToolEnvironment(json),
    };
  }

  /// The environment's API discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Automatically creates a hosted container for shell execution.
@immutable
class ContainerAutoShellToolEnvironment extends ShellToolEnvironment {
  /// Creates a configuration, taking immutable snapshots of supplied lists.
  ContainerAutoShellToolEnvironment({
    List<String>? fileIds,
    this.memoryLimit,
    this.networkPolicy,
    List<ContainerSkill>? skills,
  }) : fileIds = fileIds == null ? null : List.unmodifiable(fileIds),
       skills = skills == null ? null : List.unmodifiable(skills);

  /// Parses an automatic environment without adding server defaults.
  factory ContainerAutoShellToolEnvironment.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ContainerAutoShellToolEnvironment';
    requireJsonType(json, 'container_auto', context);
    return ContainerAutoShellToolEnvironment(
      fileIds: json.containsKey('file_ids')
          ? _readShellEnvironmentStrings(json['file_ids'], '$context.file_ids')
          : null,
      memoryLimit: json['memory_limit'] == null
          ? null
          : ContainerMemoryLimit.fromJson(
              requireJsonString(json['memory_limit'], '$context.memory_limit'),
            ),
      networkPolicy: json.containsKey('network_policy')
          ? _parseShellEnvironmentObject(
              json['network_policy'],
              '$context.network_policy',
              ContainerNetworkPolicy.fromJson,
            )
          : null,
      skills: json.containsKey('skills')
          ? _parseShellEnvironmentObjects(
              json['skills'],
              '$context.skills',
              ContainerSkill.fromJson,
            )
          : null,
    );
  }

  /// Uploaded files available to the container. The server permits at most 50.
  final List<String>? fileIds;

  /// Optional memory tier. Parsed explicit null is normalized to omission.
  final ContainerMemoryLimit? memoryLimit;

  /// Optional outbound network access policy.
  final ContainerNetworkPolicy? networkPolicy;

  /// Hosted skill references or inline bundles. The server permits at most 200.
  final List<ContainerSkill>? skills;

  @override
  String get type => 'container_auto';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (fileIds != null) 'file_ids': fileIds,
    if (memoryLimit != null) 'memory_limit': memoryLimit!.toJson(),
    if (networkPolicy != null) 'network_policy': networkPolicy!.toJson(),
    if (skills != null)
      'skills': skills!.map((skill) => skill.toJson()).toList(),
  };

  /// Creates a copy; explicit null clears any optional setting.
  ContainerAutoShellToolEnvironment copyWith({
    Object? fileIds = unsetCopyWithValue,
    Object? memoryLimit = unsetCopyWithValue,
    Object? networkPolicy = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
  }) => ContainerAutoShellToolEnvironment(
    fileIds: identical(fileIds, unsetCopyWithValue)
        ? this.fileIds
        : fileIds == null
        ? null
        : List<String>.from(fileIds as List),
    memoryLimit: identical(memoryLimit, unsetCopyWithValue)
        ? this.memoryLimit
        : memoryLimit as ContainerMemoryLimit?,
    networkPolicy: identical(networkPolicy, unsetCopyWithValue)
        ? this.networkPolicy
        : networkPolicy as ContainerNetworkPolicy?,
    skills: identical(skills, unsetCopyWithValue)
        ? this.skills
        : skills == null
        ? null
        : List<ContainerSkill>.from(skills as List),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerAutoShellToolEnvironment &&
          runtimeType == other.runtimeType &&
          listsEqual(fileIds, other.fileIds) &&
          memoryLimit == other.memoryLimit &&
          networkPolicy == other.networkPolicy &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => Object.hash(
    listHash(fileIds),
    memoryLimit,
    networkPolicy,
    listHash(skills),
  );

  @override
  String toString() =>
      'ContainerAutoShellToolEnvironment('
      'fileIds: ${_shellEnvironmentListSummary(fileIds)}, '
      'memoryLimit: $memoryLimit, '
      'networkPolicy: ${networkPolicy?.type}, '
      'skills: ${_shellEnvironmentListSummary(skills)})';
}

/// A local computer environment with optional local skill descriptions.
@immutable
class LocalShellToolEnvironment extends ShellToolEnvironment {
  /// Creates a local environment, snapshotting the supplied skill list.
  LocalShellToolEnvironment({List<ShellLocalSkill>? skills})
    : skills = skills == null ? null : List.unmodifiable(skills);

  /// Parses a local environment, retaining absent and empty skill lists.
  factory LocalShellToolEnvironment.fromJson(Map<String, dynamic> json) {
    const context = 'LocalShellToolEnvironment';
    requireJsonType(json, 'local', context);
    return LocalShellToolEnvironment(
      skills: json.containsKey('skills')
          ? _parseShellEnvironmentObjects(
              json['skills'],
              '$context.skills',
              ShellLocalSkill.fromJson,
            )
          : null,
    );
  }

  /// Local skills available to the model. The server permits at most 200.
  final List<ShellLocalSkill>? skills;

  @override
  String get type => 'local';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (skills != null)
      'skills': skills!.map((skill) => skill.toJson()).toList(),
  };

  /// Creates a copy; explicit null clears the local skills.
  LocalShellToolEnvironment copyWith({Object? skills = unsetCopyWithValue}) =>
      LocalShellToolEnvironment(
        skills: identical(skills, unsetCopyWithValue)
            ? this.skills
            : skills == null
            ? null
            : List<ShellLocalSkill>.from(skills as List),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellToolEnvironment &&
          runtimeType == other.runtimeType &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => listHash(skills);

  @override
  String toString() =>
      'LocalShellToolEnvironment(skills: ${_shellEnvironmentListSummary(skills)})';
}

/// An existing hosted container referenced by ID.
@immutable
class ContainerReferenceShellToolEnvironment extends ShellToolEnvironment {
  /// Creates an existing-container reference.
  const ContainerReferenceShellToolEnvironment({required this.containerId});

  /// Parses a reference with a required container ID.
  factory ContainerReferenceShellToolEnvironment.fromJson(
    Map<String, dynamic> json,
  ) {
    const context = 'ContainerReferenceShellToolEnvironment';
    requireJsonType(json, 'container_reference', context);
    return ContainerReferenceShellToolEnvironment(
      containerId: requireJsonString(
        json['container_id'],
        '$context.container_id',
      ),
    );
  }

  /// The ID of the referenced container.
  final String containerId;

  @override
  String get type => 'container_reference';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'container_id': containerId};

  /// Creates a copy with a replaced container ID.
  ContainerReferenceShellToolEnvironment copyWith({String? containerId}) =>
      ContainerReferenceShellToolEnvironment(
        containerId: containerId ?? this.containerId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerReferenceShellToolEnvironment &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId;

  @override
  int get hashCode => containerId.hashCode;

  @override
  String toString() =>
      'ContainerReferenceShellToolEnvironment(containerId: [${containerId.length} chars])';
}

/// A local skill directory described to the model.
///
/// This is distinct from hosted [ContainerSkill] references and inline bundles.
@immutable
class ShellLocalSkill {
  /// Creates a local skill without reading or executing files at [path].
  const ShellLocalSkill({
    required this.name,
    required this.description,
    required this.path,
  });

  /// Parses all three required string fields.
  factory ShellLocalSkill.fromJson(Map<String, dynamic> json) =>
      ShellLocalSkill(
        name: requireJsonString(json['name'], 'ShellLocalSkill.name'),
        description: requireJsonString(
          json['description'],
          'ShellLocalSkill.description',
        ),
        path: requireJsonString(json['path'], 'ShellLocalSkill.path'),
      );

  /// The skill name.
  final String name;

  /// The skill description.
  final String description;

  /// The path to the directory containing the skill.
  final String path;

  /// Converts to JSON without adding a hosted skill discriminator.
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'path': path,
  };

  /// Creates a copy with replaced values.
  ShellLocalSkill copyWith({String? name, String? description, String? path}) =>
      ShellLocalSkill(
        name: name ?? this.name,
        description: description ?? this.description,
        path: path ?? this.path,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellLocalSkill &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          path == other.path;

  @override
  int get hashCode => Object.hash(name, description, path);

  @override
  String toString() =>
      'ShellLocalSkill(name: [${name.length} chars], '
      'description: [${description.length} chars], path: [${path.length} chars])';
}

/// A future shell-definition environment retaining its immutable raw JSON.
@immutable
class UnknownShellToolEnvironment extends ShellToolEnvironment {
  /// Creates an unknown environment with a recursive JSON snapshot.
  UnknownShellToolEnvironment(Map<String, dynamic> rawJson)
    : type = requireJsonString(
        rawJson['type'],
        'UnknownShellToolEnvironment.type',
      ),
      rawJson = freezeJsonObject(rawJson);

  /// Parses a future environment discriminator.
  factory UnknownShellToolEnvironment.fromJson(Map<String, dynamic> json) =>
      UnknownShellToolEnvironment(json);

  @override
  final String type;

  /// The recursively unmodifiable original JSON payload.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => {...rawJson, 'type': type};

  /// Creates a copy with a replaced raw payload, including its discriminator.
  UnknownShellToolEnvironment copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownShellToolEnvironment(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownShellToolEnvironment &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(type, mapDeepHashCode(rawJson));

  @override
  String toString() =>
      'UnknownShellToolEnvironment(type: $type, rawJson: ${rawJson.length} entries)';
}

String _shellEnvironmentListSummary(List<Object?>? value) =>
    value == null ? 'null' : '${value.length} items';

List<Object?> _readShellEnvironmentList(Object? value, String context) {
  if (value is! List) throw FormatException('$context: expected an array');
  return value;
}

List<String> _readShellEnvironmentStrings(Object? value, String context) {
  final list = _readShellEnvironmentList(value, context);
  return [
    for (var i = 0; i < list.length; i++)
      requireJsonString(list[i], '$context[$i]'),
  ];
}

T _parseShellEnvironmentObject<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) parse,
) {
  final json = requireJsonObject(value, context);
  try {
    return parse(json);
  } on FormatException catch (error) {
    throw FormatException('$context: ${error.message}');
  }
}

List<T> _parseShellEnvironmentObjects<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) parse,
) {
  final list = _readShellEnvironmentList(value, context);
  return [
    for (var i = 0; i < list.length; i++)
      _parseShellEnvironmentObject(list[i], '$context[$i]', parse),
  ];
}
