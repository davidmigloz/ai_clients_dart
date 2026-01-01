import 'package:meta/meta.dart';

import '../tools/tool.dart';

/// Request to update an existing agent.
@immutable
class UpdateAgentRequest {
  /// The new name for the agent.
  final String? name;

  /// New description for the agent.
  final String? description;

  /// New model to use.
  final String? model;

  /// New system instructions.
  final String? instructions;

  /// New tools configuration.
  final List<Tool>? tools;

  /// New metadata.
  final Map<String, dynamic>? metadata;

  /// Creates an [UpdateAgentRequest].
  const UpdateAgentRequest({
    this.name,
    this.description,
    this.model,
    this.instructions,
    this.tools,
    this.metadata,
  });

  /// Creates an [UpdateAgentRequest] from JSON.
  factory UpdateAgentRequest.fromJson(Map<String, dynamic> json) =>
      UpdateAgentRequest(
        name: json['name'] as String?,
        description: json['description'] as String?,
        model: json['model'] as String?,
        instructions: json['instructions'] as String?,
        tools: (json['tools'] as List?)
            ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
            .toList(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (model != null) 'model': model,
    if (instructions != null) 'instructions': instructions,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with the specified fields replaced.
  UpdateAgentRequest copyWith({
    String? name,
    String? description,
    String? model,
    String? instructions,
    List<Tool>? tools,
    Map<String, dynamic>? metadata,
  }) => UpdateAgentRequest(
    name: name ?? this.name,
    description: description ?? this.description,
    model: model ?? this.model,
    instructions: instructions ?? this.instructions,
    tools: tools ?? this.tools,
    metadata: metadata ?? this.metadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAgentRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() =>
      'UpdateAgentRequest(name: $name, model: $model, instructions: ${instructions?.length ?? 0} chars)';
}
