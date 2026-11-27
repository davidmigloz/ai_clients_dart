import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../metadata/completion_args.dart';
import '../moderations/guardrail_config.dart';
import '../tools/tool.dart';

/// Request to create a new agent.
@immutable
class CreateAgentRequest {
  /// The name of the agent.
  final String name;

  /// Description of what the agent does.
  final String? description;

  /// The model to use for the agent.
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

  /// Completion settings for generated messages.
  final CompletionArgs? completionArgs;

  /// IDs of agents this agent can hand off to.
  final List<String>? handoffs;

  /// Creates a [CreateAgentRequest].
  const CreateAgentRequest({
    required this.name,
    this.description,
    required this.model,
    this.instructions,
    this.tools,
    this.metadata,
    this.guardrails,
    this.versionMessage,
    this.completionArgs,
    this.handoffs,
  });

  /// Creates a [CreateAgentRequest] from JSON.
  factory CreateAgentRequest.fromJson(Map<String, dynamic> json) =>
      CreateAgentRequest(
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
        completionArgs: json['completion_args'] == null
            ? null
            : CompletionArgs.fromJson(
                json['completion_args'] as Map<String, dynamic>,
              ),
        handoffs: (json['handoffs'] as List?)?.cast<String>(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    'model': model,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
    if (guardrails != null)
      'guardrails': guardrails!.map((e) => e.toJson()).toList(),
    if (versionMessage != null) 'version_message': versionMessage,
    'completion_args': ?completionArgs?.toJson(),
    'handoffs': ?handoffs,
  };

  /// Creates a copy with the specified fields replaced.
  CreateAgentRequest copyWith({
    String? name,
    String? description,
    String? model,
    String? instructions,
    List<Tool>? tools,
    Map<String, dynamic>? metadata,
    List<GuardrailConfig>? guardrails,
    String? versionMessage,
    Object? completionArgs = unsetCopyWithValue,
    Object? handoffs = unsetCopyWithValue,
  }) => CreateAgentRequest(
    name: name ?? this.name,
    description: description ?? this.description,
    model: model ?? this.model,
    instructions: instructions ?? this.instructions,
    tools: tools ?? this.tools,
    metadata: metadata ?? this.metadata,
    guardrails: guardrails ?? this.guardrails,
    versionMessage: versionMessage ?? this.versionMessage,
    completionArgs: completionArgs == unsetCopyWithValue
        ? this.completionArgs
        : completionArgs as CompletionArgs?,
    handoffs: handoffs == unsetCopyWithValue
        ? this.handoffs
        : (handoffs as List?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAgentRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          model == other.model;

  @override
  int get hashCode => Object.hash(name, model);

  @override
  String toString() => 'CreateAgentRequest(name: $name, model: $model)';
}
