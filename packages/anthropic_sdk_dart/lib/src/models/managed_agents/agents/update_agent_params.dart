import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';

/// Request parameters for updating an agent.
///
/// Omit a field to preserve its current value.
@immutable
class UpdateAgentParams {
  /// The agent's current version — for optimistic concurrency.
  final int version;

  /// Human-readable name. Omit to preserve.
  final String? name;

  /// Description. Omit to preserve; send null to clear.
  final String? description;

  /// System prompt. Omit to preserve; send null to clear.
  final String? system;

  /// Model identifier. Omit to preserve.
  final ModelParams? model;

  /// Tool configurations. Full replacement. Omit to preserve; send null to
  /// clear.
  final List<AgentToolParams>? tools;

  /// MCP servers. Full replacement. Omit to preserve; send null to clear.
  final List<MCPServerParams>? mcpServers;

  /// Skills. Full replacement. Omit to preserve; send null to clear.
  final List<AgentSkillParams>? skills;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omit the field to preserve.
  final Map<String, String?>? metadata;

  /// Creates an [UpdateAgentParams].
  const UpdateAgentParams({
    required this.version,
    this.name,
    this.description,
    this.system,
    this.model,
    this.tools,
    this.mcpServers,
    this.skills,
    this.metadata,
  });

  /// Creates an [UpdateAgentParams] from JSON.
  factory UpdateAgentParams.fromJson(Map<String, dynamic> json) {
    return UpdateAgentParams(
      version: json['version'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
      system: json['system'] as String?,
      model: json['model'] != null
          ? ModelParams.fromJson(json['model'] as Object)
          : null,
      tools: (json['tools'] as List?)
          ?.map((e) => AgentToolParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcp_servers'] as List?)
          ?.map((e) => MCPServerParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List?)
          ?.map((e) => AgentSkillParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map?)?.cast<String, String?>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'version': version,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (system != null) 'system': system,
    if (model != null) 'model': model!.toJson(),
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (mcpServers != null)
      'mcp_servers': mcpServers!.map((e) => e.toJson()).toList(),
    if (skills != null) 'skills': skills!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  UpdateAgentParams copyWith({
    int? version,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? mcpServers = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateAgentParams(
      version: version ?? this.version,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      system: system == unsetCopyWithValue ? this.system : system as String?,
      model: model == unsetCopyWithValue ? this.model : model as ModelParams?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<AgentToolParams>?,
      mcpServers: mcpServers == unsetCopyWithValue
          ? this.mcpServers
          : mcpServers as List<MCPServerParams>?,
      skills: skills == unsetCopyWithValue
          ? this.skills
          : skills as List<AgentSkillParams>?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String?>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAgentParams &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          name == other.name &&
          description == other.description &&
          system == other.system &&
          model == other.model &&
          listsEqual(tools, other.tools) &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills) &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    version,
    name,
    description,
    system,
    model,
    listHash(tools),
    listHash(mcpServers),
    listHash(skills),
    mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateAgentParams('
      'version: $version, '
      'name: $name, '
      'description: $description, '
      'system: $system, '
      'model: $model, '
      'tools: $tools, '
      'mcpServers: $mcpServers, '
      'skills: $skills, '
      'metadata: $metadata)';
}
