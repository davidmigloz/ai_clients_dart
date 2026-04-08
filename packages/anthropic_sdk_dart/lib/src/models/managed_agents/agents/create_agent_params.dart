import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';

/// Request parameters for creating an agent.
@immutable
class CreateAgentParams {
  /// Human-readable name for the agent.
  final String name;

  /// Model identifier — a plain string or a [ModelParams] object.
  final ModelParams model;

  /// Description of what the agent does.
  final String? description;

  /// System prompt for the agent.
  final String? system;

  /// Tool configurations available to the agent.
  final List<AgentToolParams>? tools;

  /// MCP servers this agent connects to.
  final List<MCPServerParams>? mcpServers;

  /// Skills available to the agent.
  final List<AgentSkillParams>? skills;

  /// Arbitrary key-value metadata.
  final Map<String, String>? metadata;

  /// Creates a [CreateAgentParams].
  const CreateAgentParams({
    required this.name,
    required this.model,
    this.description,
    this.system,
    this.tools,
    this.mcpServers,
    this.skills,
    this.metadata,
  });

  /// Creates a [CreateAgentParams] from JSON.
  factory CreateAgentParams.fromJson(Map<String, dynamic> json) {
    return CreateAgentParams(
      name: json['name'] as String,
      model: ModelParams.fromJson(json['model'] as Object),
      description: json['description'] as String?,
      system: json['system'] as String?,
      tools: (json['tools'] as List?)
          ?.map((e) => AgentToolParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      mcpServers: (json['mcp_servers'] as List?)
          ?.map((e) => MCPServerParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      skills: (json['skills'] as List?)
          ?.map((e) => AgentSkillParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map?)?.cast<String, String>(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'model': model.toJson(),
    if (description != null) 'description': description,
    if (system != null) 'system': system,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (mcpServers != null)
      'mcp_servers': mcpServers!.map((e) => e.toJson()).toList(),
    if (skills != null) 'skills': skills!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  CreateAgentParams copyWith({
    String? name,
    ModelParams? model,
    Object? description = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? mcpServers = unsetCopyWithValue,
    Object? skills = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateAgentParams(
      name: name ?? this.name,
      model: model ?? this.model,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      system: system == unsetCopyWithValue ? this.system : system as String?,
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
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAgentParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          model == other.model &&
          description == other.description &&
          system == other.system &&
          listsEqual(tools, other.tools) &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills) &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    name,
    model,
    description,
    system,
    listHash(tools),
    listHash(mcpServers),
    listHash(skills),
    mapHash(metadata),
  );

  @override
  String toString() =>
      'CreateAgentParams('
      'name: $name, '
      'model: $model, '
      'description: $description, '
      'system: $system, '
      'tools: $tools, '
      'mcpServers: $mcpServers, '
      'skills: $skills, '
      'metadata: $metadata)';
}
