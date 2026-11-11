part of 'session.dart';

/// An unsaved agent defined by a workflow or when spawning a thread.
@immutable
final class SessionInlineAgent extends SessionRosterEntry {
  /// Object type, always 'inline'.
  String get type => 'inline';

  /// Agent name.
  final String name;

  /// Agent description.
  final String? description;

  /// System prompt.
  final String? system;

  /// Model configuration.
  final ModelConfig model;

  /// MCP servers connected to this agent.
  final List<MCPServer> mcpServers;

  /// Skills attached to this agent.
  final List<AgentSkill> skills;

  /// Tool configurations for this agent.
  final List<AgentTool> tools;

  /// Execution principal used by this agent.
  final AgentExecutionIdentity executionIdentity;

  /// Creates an inline agent snapshot.
  const SessionInlineAgent({
    required this.name,
    this.description,
    this.system,
    required this.model,
    required this.mcpServers,
    required this.skills,
    required this.tools,
    required this.executionIdentity,
  });

  /// Creates an inline agent snapshot from JSON.
  factory SessionInlineAgent.fromJson(Map<String, dynamic> json) =>
      SessionInlineAgent(
        name: json['name'] as String,
        description: json['description'] as String?,
        system: json['system'] as String?,
        model: ModelConfig.fromJson(json['model'] as Map<String, dynamic>),
        mcpServers: List.unmodifiable(
          (json['mcp_servers'] as List<Object?>)
              .cast<Map<String, dynamic>>()
              .map(MCPServer.fromJson),
        ),
        skills: List.unmodifiable(
          (json['skills'] as List<Object?>).cast<Map<String, dynamic>>().map(
            AgentSkill.fromJson,
          ),
        ),
        tools: List.unmodifiable(
          (json['tools'] as List<Object?>).cast<Map<String, dynamic>>().map(
            AgentTool.fromJson,
          ),
        ),
        executionIdentity: AgentExecutionIdentity.fromJson(
          json['execution_identity'] as Map<String, dynamic>,
        ),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'system': system,
    'model': model.toJson(),
    'mcp_servers': mcpServers.map((server) => server.toJson()).toList(),
    'skills': skills.map((skill) => skill.toJson()).toList(),
    'tools': tools.map((tool) => tool.toJson()).toList(),
    'execution_identity': executionIdentity.toJson(),
  };

  /// Creates a copy with replaced values.
  SessionInlineAgent copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    ModelConfig? model,
    List<MCPServer>? mcpServers,
    List<AgentSkill>? skills,
    List<AgentTool>? tools,
    AgentExecutionIdentity? executionIdentity,
  }) => SessionInlineAgent(
    name: name ?? this.name,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    system: system == unsetCopyWithValue ? this.system : system as String?,
    model: model ?? this.model,
    mcpServers: mcpServers ?? this.mcpServers,
    skills: skills ?? this.skills,
    tools: tools ?? this.tools,
    executionIdentity: executionIdentity ?? this.executionIdentity,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionInlineAgent &&
          name == other.name &&
          description == other.description &&
          system == other.system &&
          model == other.model &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills) &&
          listsEqual(tools, other.tools) &&
          executionIdentity == other.executionIdentity;

  @override
  int get hashCode => Object.hash(
    name,
    description,
    system,
    model,
    listHash(mcpServers),
    listHash(skills),
    listHash(tools),
    executionIdentity,
  );

  @override
  String toString() => 'SessionInlineAgent(name: $name, model: $model)';
}
