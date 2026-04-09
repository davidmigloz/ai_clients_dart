import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../resources/session_resource_params.dart';

/// Agent parameter — either a plain agent ID string or an object with id,
/// type, and optional version.
///
/// Variants:
/// - [AgentParamsId] — a plain agent ID string.
/// - [AgentParamsObject] — an object with id, type, and optional version.
sealed class AgentParams {
  const AgentParams();

  /// Creates an [AgentParams] from JSON.
  ///
  /// If [json] is a [String], returns [AgentParamsId].
  /// Otherwise expects a [Map] and returns [AgentParamsObject].
  static AgentParams fromJson(Object json) {
    if (json is String) {
      return AgentParamsId(id: json);
    }
    return AgentParamsObject.fromJson(json as Map<String, dynamic>);
  }

  /// Converts to JSON.
  Object toJson();
}

/// A plain agent ID string.
@immutable
class AgentParamsId extends AgentParams {
  /// The agent identifier.
  final String id;

  /// Creates an [AgentParamsId].
  const AgentParamsId({required this.id});

  @override
  Object toJson() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentParamsId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AgentParamsId(id: $id)';
}

/// An agent specification with id, type, and optional version.
@immutable
class AgentParamsObject extends AgentParams {
  /// The agent ID.
  final String id;

  /// The object type. Always "agent".
  final String type;

  /// The specific agent version to use. Omit to use the latest.
  final int? version;

  /// Creates an [AgentParamsObject].
  const AgentParamsObject({
    required this.id,
    this.type = 'agent',
    this.version,
  });

  /// Creates an [AgentParamsObject] from JSON.
  factory AgentParamsObject.fromJson(Map<String, dynamic> json) {
    return AgentParamsObject(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'agent',
      version: json['version'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    if (version != null) 'version': version,
  };

  /// Creates a copy with replaced values.
  AgentParamsObject copyWith({
    String? id,
    String? type,
    Object? version = unsetCopyWithValue,
  }) {
    return AgentParamsObject(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version == unsetCopyWithValue ? this.version : version as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentParamsObject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          version == other.version;

  @override
  int get hashCode => Object.hash(id, type, version);

  @override
  String toString() =>
      'AgentParamsObject(id: $id, type: $type, version: $version)';
}

/// Request parameters for creating a session.
@immutable
class CreateSessionParams {
  /// Agent identifier — a plain agent ID string or an object with id/version.
  final AgentParams agent;

  /// ID of the environment defining the container configuration.
  final String environmentId;

  /// Human-readable session title.
  final String? title;

  /// Arbitrary key-value metadata.
  final Map<String, String>? metadata;

  /// Vault IDs for stored credentials.
  final List<String>? vaultIds;

  /// Resources to mount into the session's container.
  final List<SessionResourceParams>? resources;

  /// Creates a [CreateSessionParams].
  const CreateSessionParams({
    required this.agent,
    required this.environmentId,
    this.title,
    this.metadata,
    this.vaultIds,
    this.resources,
  });

  /// Creates a [CreateSessionParams] from JSON.
  factory CreateSessionParams.fromJson(Map<String, dynamic> json) {
    return CreateSessionParams(
      agent: AgentParams.fromJson(json['agent'] as Object),
      environmentId: json['environment_id'] as String,
      title: json['title'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      vaultIds: (json['vault_ids'] as List?)?.map((e) => e as String).toList(),
      resources: (json['resources'] as List?)
          ?.map(
            (e) => SessionResourceParams.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent': agent.toJson(),
    'environment_id': environmentId,
    if (title != null) 'title': title,
    if (metadata != null) 'metadata': metadata,
    if (vaultIds != null) 'vault_ids': vaultIds,
    if (resources != null)
      'resources': resources!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  CreateSessionParams copyWith({
    AgentParams? agent,
    String? environmentId,
    Object? title = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
    Object? resources = unsetCopyWithValue,
  }) {
    return CreateSessionParams(
      agent: agent ?? this.agent,
      environmentId: environmentId ?? this.environmentId,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      vaultIds: vaultIds == unsetCopyWithValue
          ? this.vaultIds
          : vaultIds as List<String>?,
      resources: resources == unsetCopyWithValue
          ? this.resources
          : resources as List<SessionResourceParams>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateSessionParams &&
          runtimeType == other.runtimeType &&
          agent == other.agent &&
          environmentId == other.environmentId &&
          title == other.title &&
          mapsEqual(metadata, other.metadata) &&
          listsEqual(vaultIds, other.vaultIds) &&
          listsEqual(resources, other.resources);

  @override
  int get hashCode => Object.hash(
    agent,
    environmentId,
    title,
    mapHash(metadata),
    listHash(vaultIds),
    listHash(resources),
  );

  @override
  String toString() =>
      'CreateSessionParams('
      'agent: $agent, '
      'environmentId: $environmentId, '
      'title: $title, '
      'metadata: $metadata, '
      'vaultIds: $vaultIds, '
      'resources: $resources)';
}
