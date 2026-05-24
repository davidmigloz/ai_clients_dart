import '../../copy_with_sentinel.dart';
import '../environments/environments.dart';
import '../tools/tools.dart';

/// A reusable agent definition for the Interactions API.
///
/// Agents bundle a base agent, environment, system instruction, and a set of
/// tools that can be referenced when creating an interaction.
class Agent {
  /// A unique identifier for the agent.
  final String? id;

  /// The base agent this agent derives from.
  final String? baseAgent;

  /// The environment configuration for the agent.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// string reference ([EnvironmentIdRef]) — an existing environment id, or a
  /// literal such as `"remote"`.
  final EnvironmentConfigOrId? baseEnvironment;

  /// A human-readable description of the agent.
  final String? description;

  /// System instruction applied to the agent.
  final String? systemInstruction;

  /// The tools the agent may use.
  ///
  /// Agents support the [CodeExecutionTool], [GoogleSearchTool],
  /// [UrlContextTool], and [McpServerTool] variants of [InteractionTool].
  final List<InteractionTool>? tools;

  /// Creates an [Agent].
  const Agent({
    this.id,
    this.baseAgent,
    this.baseEnvironment,
    this.description,
    this.systemInstruction,
    this.tools,
  });

  /// Creates an [Agent] from JSON.
  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    id: json['id'] as String?,
    baseAgent: json['base_agent'] as String?,
    baseEnvironment: json['base_environment'] != null
        ? EnvironmentConfigOrId.fromJson(json['base_environment'] as Object)
        : null,
    description: json['description'] as String?,
    systemInstruction: json['system_instruction'] as String?,
    tools: (json['tools'] as List<dynamic>?)
        ?.map((e) => InteractionTool.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (baseAgent != null) 'base_agent': baseAgent,
    if (baseEnvironment != null) 'base_environment': baseEnvironment!.toJson(),
    if (description != null) 'description': description,
    if (systemInstruction != null) 'system_instruction': systemInstruction,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  Agent copyWith({
    Object? id = unsetCopyWithValue,
    Object? baseAgent = unsetCopyWithValue,
    Object? baseEnvironment = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? systemInstruction = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
  }) {
    return Agent(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      baseAgent: baseAgent == unsetCopyWithValue
          ? this.baseAgent
          : baseAgent as String?,
      baseEnvironment: baseEnvironment == unsetCopyWithValue
          ? this.baseEnvironment
          : baseEnvironment as EnvironmentConfigOrId?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      systemInstruction: systemInstruction == unsetCopyWithValue
          ? this.systemInstruction
          : systemInstruction as String?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<InteractionTool>?,
    );
  }
}
