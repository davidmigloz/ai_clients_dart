import 'package:meta/meta.dart';

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

  /// Current version number.
  final int version;

  /// When the agent was created.
  final DateTime? createdAt;

  /// When the agent was last updated.
  final DateTime? updatedAt;

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
    this.version = 1,
    this.createdAt,
    this.updatedAt,
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
    version: json['version'] as int? ?? 1,
    createdAt: _parseDateTime(json['created_at']),
    updatedAt: _parseDateTime(json['updated_at']),
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
    'version': version,
    if (createdAt != null)
      'created_at': createdAt!.millisecondsSinceEpoch ~/ 1000,
    if (updatedAt != null)
      'updated_at': updatedAt!.millisecondsSinceEpoch ~/ 1000,
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
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
