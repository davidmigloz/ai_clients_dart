import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';
import '../resources/session_resource_params.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Agent parameter for a session — a plain agent ID string, an agent
/// reference, or an agent reference with per-session overrides.
///
/// Variants:
/// - [AgentParamsId] — a plain agent ID string.
/// - [AgentParamsObject] — an object with id, type, and optional version.
/// - [AgentParamsWithOverrides] — an agent reference whose model, system
///   prompt, tools, MCP servers, or skills are overridden for this session.
sealed class AgentParams {
  const AgentParams();

  /// Creates an [AgentParams] from JSON.
  ///
  /// If [json] is a [String], returns [AgentParamsId]. Otherwise dispatches on
  /// the `type` discriminator: `agent_with_overrides` yields
  /// [AgentParamsWithOverrides], anything else yields [AgentParamsObject].
  static AgentParams fromJson(Object json) {
    if (json is String) {
      return AgentParamsId(id: json);
    }
    final map = json as Map<String, dynamic>;
    return switch (map['type'] as String?) {
      'agent_with_overrides' => AgentParamsWithOverrides.fromJson(map),
      _ => AgentParamsObject.fromJson(map),
    };
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

/// An agent reference with per-session configuration overrides.
///
/// Replaces the agent's model, system prompt, tools, MCP servers, or skills
/// for a single session. The agent itself is unchanged. Omit an override to
/// keep the agent's configured value; set [system] to `null` to clear the
/// agent's system prompt for the session.
@immutable
class AgentParamsWithOverrides extends AgentParams {
  /// The agent ID.
  final String id;

  /// The object type. Always "agent_with_overrides".
  final String type;

  /// The specific agent version to use. Omit to use the latest.
  final int? version;

  /// Replacement model. Omit to keep the agent's model.
  final ModelParams? model;

  /// Replacement system prompt (up to 100,000 characters).
  ///
  /// Omit to keep the agent's system prompt; set to `null` to clear it.
  String? get system => _system == _notSet ? null : _system as String?;
  final Object? _system;

  /// Replacement tool list. Full replacement. Omit to keep the agent's tools.
  final List<AgentToolParams>? tools;

  /// Replacement MCP server list. Full replacement. Omit to keep the agent's
  /// MCP servers.
  final List<MCPServerParams>? mcpServers;

  /// Replacement skill list. Full replacement. Omit to keep the agent's skills.
  final List<AgentSkillParams>? skills;

  /// Creates an [AgentParamsWithOverrides].
  const AgentParamsWithOverrides({
    required this.id,
    this.type = 'agent_with_overrides',
    this.version,
    this.model,
    Object? system = _notSet,
    this.tools,
    this.mcpServers,
    this.skills,
  }) : _system = system;

  /// Creates an [AgentParamsWithOverrides] from JSON.
  factory AgentParamsWithOverrides.fromJson(Map<String, dynamic> json) {
    return AgentParamsWithOverrides(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'agent_with_overrides',
      version: json['version'] as int?,
      model: json['model'] != null
          ? ModelParams.fromJson(json['model'] as Object)
          : null,
      system: json.containsKey('system') ? json['system'] as String? : _notSet,
      tools: (json['tools'] as List?)
          ?.map((e) => AgentToolParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcp_servers'] as List?)
          ?.map((e) => MCPServerParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List?)
          ?.map((e) => AgentSkillParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    if (version != null) 'version': version,
    if (model != null) 'model': model!.toJson(),
    if (_system != _notSet) 'system': _system,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (mcpServers != null)
      'mcp_servers': mcpServers!.map((e) => e.toJson()).toList(),
    if (skills != null) 'skills': skills!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  AgentParamsWithOverrides copyWith({
    String? id,
    String? type,
    Object? version = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? mcpServers = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
  }) {
    return AgentParamsWithOverrides(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version == unsetCopyWithValue ? this.version : version as int?,
      model: model == unsetCopyWithValue ? this.model : model as ModelParams?,
      system: system == unsetCopyWithValue ? _system : system,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<AgentToolParams>?,
      mcpServers: mcpServers == unsetCopyWithValue
          ? this.mcpServers
          : mcpServers as List<MCPServerParams>?,
      skills: skills == unsetCopyWithValue
          ? this.skills
          : skills as List<AgentSkillParams>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentParamsWithOverrides &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          version == other.version &&
          model == other.model &&
          _system == other._system &&
          listsEqual(tools, other.tools) &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills);

  @override
  int get hashCode => Object.hash(
    id,
    type,
    version,
    model,
    _system,
    listHash(tools),
    listHash(mcpServers),
    listHash(skills),
  );

  @override
  String toString() =>
      'AgentParamsWithOverrides('
      'id: $id, '
      'type: $type, '
      'version: $version, '
      'model: $model, '
      'system: $system, '
      'tools: $tools, '
      'mcpServers: $mcpServers, '
      'skills: $skills)';
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
