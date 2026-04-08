import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';

/// A Managed Agents agent.
@immutable
class Agent {
  /// Unique identifier for the agent.
  final String id;

  /// Object type. Always "agent".
  final String type;

  /// The agent's current version.
  final int version;

  /// Human-readable name for the agent.
  final String name;

  /// Description of what the agent does.
  final String? description;

  /// Model configuration.
  final ModelConfig model;

  /// System prompt for the agent.
  final String? system;

  /// Tool configurations available to the agent.
  final List<AgentTool> tools;

  /// MCP servers this agent connects to.
  final List<MCPServer> mcpServers;

  /// Skills available to the agent.
  final List<AgentSkill> skills;

  /// Arbitrary key-value metadata.
  final Map<String, String>? metadata;

  /// ISO 8601 timestamp of when the agent was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the agent was last updated.
  final DateTime updatedAt;

  /// ISO 8601 timestamp of when the agent was archived, or null.
  final DateTime? archivedAt;

  /// Creates an [Agent].
  const Agent({
    required this.id,
    this.type = 'agent',
    required this.version,
    required this.name,
    required this.description,
    required this.model,
    required this.system,
    required this.tools,
    required this.mcpServers,
    required this.skills,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
  });

  /// Creates an [Agent] from JSON.
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'agent',
      version: json['version'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      model: ModelConfig.fromJson(json['model'] as Map<String, dynamic>),
      system: json['system'] as String?,
      tools: (json['tools'] as List)
          .map((e) => AgentTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcp_servers'] as List)
          .map((e) => MCPServer.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List)
          .map((e) => AgentSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'version': version,
    'name': name,
    'description': description,
    'model': model.toJson(),
    'system': system,
    'tools': tools.map((e) => e.toJson()).toList(),
    'mcp_servers': mcpServers.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([description], [system], [metadata], [archivedAt]),
  /// pass the sentinel value [unsetCopyWithValue] (or omit) to keep the
  /// original value, or pass `null` explicitly to set the field to null.
  Agent copyWith({
    String? id,
    String? type,
    int? version,
    String? name,
    Object? description = unsetCopyWithValue,
    ModelConfig? model,
    Object? system = unsetCopyWithValue,
    List<AgentTool>? tools,
    List<MCPServer>? mcpServers,
    List<AgentSkill>? skills,
    Object? metadata = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return Agent(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version ?? this.version,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      model: model ?? this.model,
      system: system == unsetCopyWithValue ? this.system : system as String?,
      tools: tools ?? this.tools,
      mcpServers: mcpServers ?? this.mcpServers,
      skills: skills ?? this.skills,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Agent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          version == other.version &&
          name == other.name &&
          description == other.description &&
          model == other.model &&
          system == other.system &&
          listsEqual(tools, other.tools) &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills) &&
          mapsEqual(metadata, other.metadata) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    version,
    name,
    description,
    model,
    system,
    listHash(tools),
    listHash(mcpServers),
    listHash(skills),
    mapHash(metadata),
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'Agent('
      'id: $id, '
      'type: $type, '
      'version: $version, '
      'name: $name, '
      'description: $description, '
      'model: $model, '
      'system: $system, '
      'tools: $tools, '
      'mcpServers: $mcpServers, '
      'skills: $skills, '
      'metadata: $metadata, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}
