import 'package:meta/meta.dart';

import '../metadata/completion_args.dart';
import '../moderations/guardrail_config.dart';
import '../tools/tool.dart';

/// An AI agent configuration.
@immutable
class Agent {
  /// Unique identifier for the agent.
  final String id;

  /// Object type.
  final String object;

  /// The name of the agent.
  final String name;

  /// Description of what the agent does.
  final String? description;

  /// The model used by the agent.
  final String model;

  /// System instructions for the agent.
  final String? instructions;

  /// Tools available to the agent.
  final List<Tool>? tools;

  /// Custom metadata for the agent.
  final Map<String, dynamic>? metadata;

  /// Guardrail configurations for content moderation.
  final List<GuardrailConfig>? guardrails;

  /// Message describing the changes in this version.
  final String? versionMessage;

  /// Current version number.
  final int version;

  /// When the agent was created.
  final DateTime? createdAt;

  /// When the agent was last updated.
  final DateTime? updatedAt;

  /// Completion settings for generated messages.
  final CompletionArgs? completionArgs;

  /// IDs of agents this agent can hand off to.
  final List<String>? handoffs;

  /// Whether the agent is available for chat deployments.
  final bool? deploymentChat;

  /// ID of the agent owner, when available.
  final String? ownerId;

  /// Origin of the agent configuration.
  final String? source;

  /// Version numbers available for this agent.
  final List<int>? versions;

  /// Creates an [Agent].
  const Agent({
    required this.id,
    this.object = 'agent',
    required this.name,
    this.description,
    required this.model,
    this.instructions,
    this.tools,
    this.metadata,
    this.guardrails,
    this.versionMessage,
    this.version = 1,
    this.createdAt,
    this.updatedAt,
    this.completionArgs,
    this.handoffs,
    this.deploymentChat,
    this.ownerId,
    this.source,
    this.versions,
  });

  /// Creates an [Agent] from JSON.
  factory Agent.fromJson(Map<String, dynamic> json) => Agent(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'agent',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    model: json['model'] as String? ?? '',
    instructions: json['instructions'] as String?,
    tools: (json['tools'] as List?)
        ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
        .toList(),
    metadata: json['metadata'] as Map<String, dynamic>?,
    guardrails: (json['guardrails'] as List?)
        ?.map((e) => GuardrailConfig.fromJson(e as Map<String, dynamic>))
        .toList(),
    versionMessage: json['version_message'] as String?,
    version: json['version'] as int? ?? 1,
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
    completionArgs: json['completion_args'] == null
        ? null
        : CompletionArgs.fromJson(
            json['completion_args'] as Map<String, dynamic>,
          ),
    handoffs: (json['handoffs'] as List?)?.cast<String>(),
    deploymentChat: json['deployment_chat'] as bool?,
    ownerId: json['owner_id'] as String?,
    source: json['source'] as String?,
    versions: (json['versions'] as List?)?.cast<int>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'name': name,
    if (description != null) 'description': description,
    'model': model,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
    if (guardrails != null)
      'guardrails': guardrails!.map((e) => e.toJson()).toList(),
    if (versionMessage != null) 'version_message': versionMessage,
    'version': version,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    'completion_args': ?completionArgs?.toJson(),
    'handoffs': ?handoffs,
    'deployment_chat': ?deploymentChat,
    'owner_id': ?ownerId,
    'source': ?source,
    'versions': ?versions,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Agent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Agent(id: $id, name: $name, model: $model)';
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
