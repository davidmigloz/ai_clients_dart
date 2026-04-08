import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating an agent.
///
/// Omit a field to preserve its current value.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateAgentParams {
  /// The agent's current version — for optimistic concurrency.
  final int version;

  /// Human-readable name. Omit to preserve.
  String? get name => _name == _notSet ? null : _name as String?;
  final Object? _name;

  /// Description. Omit to preserve; send null to clear.
  String? get description =>
      _description == _notSet ? null : _description as String?;
  final Object? _description;

  /// System prompt. Omit to preserve; send null to clear.
  String? get system => _system == _notSet ? null : _system as String?;
  final Object? _system;

  /// Model identifier. Omit to preserve.
  ModelParams? get model => _model == _notSet ? null : _model as ModelParams?;
  final Object? _model;

  /// Tool configurations. Full replacement. Omit to preserve; send null to
  /// clear.
  List<AgentToolParams>? get tools =>
      _tools == _notSet ? null : _tools as List<AgentToolParams>?;
  final Object? _tools;

  /// MCP servers. Full replacement. Omit to preserve; send null to clear.
  List<MCPServerParams>? get mcpServers =>
      _mcpServers == _notSet ? null : _mcpServers as List<MCPServerParams>?;
  final Object? _mcpServers;

  /// Skills. Full replacement. Omit to preserve; send null to clear.
  List<AgentSkillParams>? get skills =>
      _skills == _notSet ? null : _skills as List<AgentSkillParams>?;
  final Object? _skills;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omit the field to preserve.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Creates an [UpdateAgentParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateAgentParams({
    required this.version,
    Object? name = _notSet,
    Object? description = _notSet,
    Object? system = _notSet,
    Object? model = _notSet,
    Object? tools = _notSet,
    Object? mcpServers = _notSet,
    Object? skills = _notSet,
    Object? metadata = _notSet,
  }) : _name = name,
       _description = description,
       _system = system,
       _model = model,
       _tools = tools,
       _mcpServers = mcpServers,
       _skills = skills,
       _metadata = metadata;

  /// Creates an [UpdateAgentParams] from JSON.
  factory UpdateAgentParams.fromJson(Map<String, dynamic> json) {
    return UpdateAgentParams(
      version: json['version'] as int,
      name: json.containsKey('name') ? json['name'] as String? : _notSet,
      description: json.containsKey('description')
          ? json['description'] as String?
          : _notSet,
      system: json.containsKey('system') ? json['system'] as String? : _notSet,
      model: json.containsKey('model')
          ? json['model'] != null
                ? ModelParams.fromJson(json['model'] as Object)
                : null
          : _notSet,
      tools: json.containsKey('tools')
          ? (json['tools'] as List?)
                ?.map(
                  (e) => AgentToolParams.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : _notSet,
      mcpServers: json.containsKey('mcp_servers')
          ? (json['mcp_servers'] as List?)
                ?.map(
                  (e) => MCPServerParams.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : _notSet,
      skills: json.containsKey('skills')
          ? (json['skills'] as List?)
                ?.map(
                  (e) => AgentSkillParams.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map?)?.cast<String, String?>()
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Fields that were not set (left as default) are omitted.
  /// Fields explicitly set to `null` are included as `null` to clear
  /// the value on the server.
  Map<String, dynamic> toJson() => {
    'version': version,
    if (_name != _notSet) 'name': _name,
    if (_description != _notSet) 'description': _description,
    if (_system != _notSet) 'system': _system,
    if (_model != _notSet) 'model': (_model as ModelParams?)?.toJson(),
    if (_tools != _notSet)
      'tools': (_tools as List<AgentToolParams>?)
          ?.map((e) => e.toJson())
          .toList(),
    if (_mcpServers != _notSet)
      'mcp_servers': (_mcpServers as List<MCPServerParams>?)
          ?.map((e) => e.toJson())
          .toList(),
    if (_skills != _notSet)
      'skills': (_skills as List<AgentSkillParams>?)
          ?.map((e) => e.toJson())
          .toList(),
    if (_metadata != _notSet) 'metadata': _metadata,
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
      name: name == unsetCopyWithValue ? _name : name,
      description: description == unsetCopyWithValue
          ? _description
          : description,
      system: system == unsetCopyWithValue ? _system : system,
      model: model == unsetCopyWithValue ? _model : model,
      tools: tools == unsetCopyWithValue ? _tools : tools,
      mcpServers: mcpServers == unsetCopyWithValue ? _mcpServers : mcpServers,
      skills: skills == unsetCopyWithValue ? _skills : skills,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAgentParams &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          _name == other._name &&
          _description == other._description &&
          _system == other._system &&
          _model == other._model &&
          _listsEqualOrBothSentinel(_tools, other._tools) &&
          _listsEqualOrBothSentinel(_mcpServers, other._mcpServers) &&
          _listsEqualOrBothSentinel(_skills, other._skills) &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    version,
    _name,
    _description,
    _system,
    _model,
    _tools == _notSet ? _notSet : listHash(tools),
    _mcpServers == _notSet ? _notSet : listHash(mcpServers),
    _skills == _notSet ? _notSet : listHash(skills),
    _metadata == _notSet ? _notSet : mapHash(metadata),
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

bool _listsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return listsEqual(a as List?, b as List?);
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
