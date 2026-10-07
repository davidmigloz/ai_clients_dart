import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'container.dart';
import 'container_json_helpers.dart';
import 'container_memory_limit.dart';
import 'container_network_policy.dart';
import 'container_skill.dart';

/// Request to create a new container.
///
/// ## Example
///
/// ```dart
/// final container = await client.containers.create(
///   CreateContainerRequest(
///     name: 'my-container',
///     fileIds: ['file-abc123'],
///     expiresAfter: ContainerExpiration(
///       anchor: 'last_active_at',
///       minutes: 60,
///     ),
///   ),
/// );
/// ```
@immutable
class CreateContainerRequest {
  /// Creates a [CreateContainerRequest].
  ///
  /// Takes defensive, unmodifiable copies of [fileIds] and [skills].
  CreateContainerRequest({
    required this.name,
    List<String>? fileIds,
    this.expiresAfter,
    this.memoryLimit,
    this.networkPolicy,
    List<ContainerSkill>? skills,
  }) : fileIds = fileIds == null ? null : List.unmodifiable(fileIds),
       skills = skills == null ? null : List.unmodifiable(skills);

  /// Creates a [CreateContainerRequest] from JSON.
  factory CreateContainerRequest.fromJson(Map<String, dynamic> json) {
    final expiration = optionalContainerMap(
      json,
      'expires_after',
      'CreateContainerRequest',
    );
    final memory = optionalContainerString(
      json,
      'memory_limit',
      'CreateContainerRequest',
    );
    final policy = optionalContainerMap(
      json,
      'network_policy',
      'CreateContainerRequest',
    );
    return CreateContainerRequest(
      name: requireContainerString(json['name'], 'CreateContainerRequest.name'),
      fileIds: optionalContainerStrings(
        json,
        'file_ids',
        'CreateContainerRequest',
      ),
      expiresAfter: expiration == null
          ? null
          : ContainerExpiration.fromJson(expiration),
      memoryLimit: memory == null
          ? null
          : ContainerMemoryLimit.fromJson(memory),
      networkPolicy: policy == null
          ? null
          : ContainerNetworkPolicy.fromJson(policy),
      skills: json.containsKey('skills')
          ? parseContainerObjects(
              json['skills'],
              ContainerSkill.fromJson,
              'CreateContainerRequest.skills',
            )
          : null,
    );
  }

  /// Name of the container to create.
  final String name;

  /// IDs of files to copy to the container.
  final List<String>? fileIds;

  /// Container expiration time configuration.
  final ContainerExpiration? expiresAfter;

  /// Memory limit for the container.
  ///
  /// Omitted by default so the server selects its creation default of `1g`.
  final ContainerMemoryLimit? memoryLimit;

  /// Network access policy for the container.
  final ContainerNetworkPolicy? networkPolicy;

  /// Ordered skill references or inline skill bundles for the container.
  final List<ContainerSkill>? skills;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (fileIds != null) 'file_ids': fileIds!.toList(),
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    if (memoryLimit != null) 'memory_limit': memoryLimit!.toJson(),
    if (networkPolicy != null) 'network_policy': networkPolicy!.toJson(),
    if (skills != null)
      'skills': skills!.map((skill) => skill.toJson()).toList(),
  };

  /// Creates a copy with replaced fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  CreateContainerRequest copyWith({
    String? name,
    Object? fileIds = unsetCopyWithValue,
    Object? expiresAfter = unsetCopyWithValue,
    Object? memoryLimit = unsetCopyWithValue,
    Object? networkPolicy = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
  }) => CreateContainerRequest(
    name: name ?? this.name,
    fileIds: fileIds == unsetCopyWithValue
        ? this.fileIds
        : fileIds == null
        ? null
        : List<String>.from(fileIds as List),
    expiresAfter: expiresAfter == unsetCopyWithValue
        ? this.expiresAfter
        : expiresAfter as ContainerExpiration?,
    memoryLimit: memoryLimit == unsetCopyWithValue
        ? this.memoryLimit
        : memoryLimit as ContainerMemoryLimit?,
    networkPolicy: networkPolicy == unsetCopyWithValue
        ? this.networkPolicy
        : networkPolicy as ContainerNetworkPolicy?,
    skills: skills == unsetCopyWithValue
        ? this.skills
        : skills == null
        ? null
        : List<ContainerSkill>.from(skills as List),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateContainerRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listsEqual(fileIds, other.fileIds) &&
          expiresAfter == other.expiresAfter &&
          memoryLimit == other.memoryLimit &&
          networkPolicy == other.networkPolicy &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => Object.hash(
    name,
    listHash(fileIds),
    expiresAfter,
    memoryLimit,
    networkPolicy,
    listHash(skills),
  );

  @override
  String toString() =>
      'CreateContainerRequest(name: $name, '
      'fileIds: ${fileIds == null ? null : '${fileIds!.length} files'}, '
      'expiresAfter: $expiresAfter, memoryLimit: $memoryLimit, '
      'networkPolicy: $networkPolicy, '
      'skills: ${skills == null ? null : '${skills!.length} skills'})';
}
