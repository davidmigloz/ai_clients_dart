import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../config/agent_skill.dart';
import '../config/agent_tool.dart';
import '../config/mcp_server.dart';
import '../config/model_config.dart';
import '../events/telemetry.dart';
import '../resources/session_resource.dart';

/// Session status.
enum SessionStatus {
  /// Session is recovering from an error and rescheduled.
  rescheduling('rescheduling'),

  /// Session is actively running.
  running('running'),

  /// Session is idle, awaiting user input.
  idle('idle'),

  /// Session has terminated.
  terminated('terminated'),

  /// Unknown status — fallback for unrecognized values.
  unknown('unknown');

  const SessionStatus(this.value);

  /// JSON value for this status.
  final String value;

  /// Parses a [SessionStatus] from JSON.
  static SessionStatus fromJson(String value) => switch (value) {
    'rescheduling' => SessionStatus.rescheduling,
    'running' => SessionStatus.running,
    'idle' => SessionStatus.idle,
    'terminated' => SessionStatus.terminated,
    _ => SessionStatus.unknown,
  };

  /// Converts this status to JSON.
  String toJson() => value;
}

/// A Managed Agents session.
@immutable
class Session {
  /// Unique identifier for the session.
  final String id;

  /// Object type. Always "session".
  final String type;

  /// Current session status.
  final SessionStatus status;

  /// Resolved agent snapshot at session creation time.
  final SessionAgent agent;

  /// ID of the environment defining the container configuration.
  final String? environmentId;

  /// Human-readable session title.
  final String? title;

  /// Arbitrary key-value metadata attached to the session.
  final Map<String, String>? metadata;

  /// Resources mounted into the session.
  final List<SessionResource>? resources;

  /// Vault IDs attached to the session.
  final List<String>? vaultIds;

  /// Timing statistics for the session.
  final SessionStats? stats;

  /// Cumulative token usage for the session.
  final SessionUsage? usage;

  /// When the session was created.
  final DateTime createdAt;

  /// When the session was last updated.
  final DateTime updatedAt;

  /// When the session was archived. Null if not archived.
  final DateTime? archivedAt;

  /// Creates a [Session].
  const Session({
    required this.id,
    this.type = 'session',
    required this.status,
    required this.agent,
    this.environmentId,
    this.title,
    this.metadata,
    this.resources,
    this.vaultIds,
    this.stats,
    this.usage,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  /// Creates a [Session] from JSON.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'session',
      status: SessionStatus.fromJson(json['status'] as String),
      agent: SessionAgent.fromJson(json['agent'] as Map<String, dynamic>),
      environmentId: json['environment_id'] as String?,
      title: json['title'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      resources: (json['resources'] as List?)
          ?.map((e) => SessionResource.fromJson(e as Map<String, dynamic>))
          .toList(),
      vaultIds: (json['vault_ids'] as List?)?.map((e) => e as String).toList(),
      stats: json['stats'] != null
          ? SessionStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      usage: json['usage'] != null
          ? SessionUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
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
    'status': status.toJson(),
    'agent': agent.toJson(),
    if (environmentId != null) 'environment_id': environmentId,
    'title': title,
    if (metadata != null) 'metadata': metadata,
    if (resources != null)
      'resources': resources!.map((e) => e.toJson()).toList(),
    if (vaultIds != null) 'vault_ids': vaultIds,
    if (stats != null) 'stats': stats!.toJson(),
    if (usage != null) 'usage': usage!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  Session copyWith({
    String? id,
    String? type,
    SessionStatus? status,
    SessionAgent? agent,
    Object? environmentId = unsetCopyWithValue,
    Object? title = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? resources = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
    Object? stats = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return Session(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      agent: agent ?? this.agent,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      title: title == unsetCopyWithValue ? this.title : title as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      resources: resources == unsetCopyWithValue
          ? this.resources
          : resources as List<SessionResource>?,
      vaultIds: vaultIds == unsetCopyWithValue
          ? this.vaultIds
          : vaultIds as List<String>?,
      stats: stats == unsetCopyWithValue ? this.stats : stats as SessionStats?,
      usage: usage == unsetCopyWithValue ? this.usage : usage as SessionUsage?,
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
      other is Session &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          status == other.status &&
          agent == other.agent &&
          environmentId == other.environmentId &&
          title == other.title &&
          mapsEqual(metadata, other.metadata) &&
          listsEqual(resources, other.resources) &&
          listsEqual(vaultIds, other.vaultIds) &&
          stats == other.stats &&
          usage == other.usage &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    status,
    agent,
    environmentId,
    title,
    mapHash(metadata),
    listHash(resources),
    listHash(vaultIds),
    stats,
    usage,
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'Session('
      'id: $id, '
      'type: $type, '
      'status: $status, '
      'agent: $agent, '
      'environmentId: $environmentId, '
      'title: $title, '
      'metadata: $metadata, '
      'resources: $resources, '
      'vaultIds: $vaultIds, '
      'stats: $stats, '
      'usage: $usage, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}

/// Resolved agent definition for a session — snapshot at session creation time.
@immutable
class SessionAgent {
  /// Agent identifier.
  final String id;

  /// Object type. Always "agent".
  final String type;

  /// Agent version.
  final int version;

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

  /// Creates a [SessionAgent].
  const SessionAgent({
    required this.id,
    this.type = 'agent',
    required this.version,
    required this.name,
    this.description,
    this.system,
    required this.model,
    required this.mcpServers,
    required this.skills,
    required this.tools,
  });

  /// Creates a [SessionAgent] from JSON.
  factory SessionAgent.fromJson(Map<String, dynamic> json) {
    return SessionAgent(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'agent',
      version: json['version'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      system: json['system'] as String?,
      model: ModelConfig.fromJson(json['model'] as Map<String, dynamic>),
      mcpServers:
          (json['mcp_servers'] as List?)
              ?.map((e) => MCPServer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      skills:
          (json['skills'] as List?)
              ?.map((e) => AgentSkill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tools:
          (json['tools'] as List?)
              ?.map((e) => AgentTool.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'version': version,
    'name': name,
    'description': description,
    'system': system,
    'model': model.toJson(),
    'mcp_servers': mcpServers.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'tools': tools.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  SessionAgent copyWith({
    String? id,
    String? type,
    int? version,
    String? name,
    Object? description = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    ModelConfig? model,
    List<MCPServer>? mcpServers,
    List<AgentSkill>? skills,
    List<AgentTool>? tools,
  }) {
    return SessionAgent(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version ?? this.version,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      system: system == unsetCopyWithValue ? this.system : system as String?,
      model: model ?? this.model,
      mcpServers: mcpServers ?? this.mcpServers,
      skills: skills ?? this.skills,
      tools: tools ?? this.tools,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAgent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          version == other.version &&
          name == other.name &&
          description == other.description &&
          system == other.system &&
          model == other.model &&
          listsEqual(mcpServers, other.mcpServers) &&
          listsEqual(skills, other.skills) &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(
    id,
    type,
    version,
    name,
    description,
    system,
    model,
    listHash(mcpServers),
    listHash(skills),
    listHash(tools),
  );

  @override
  String toString() =>
      'SessionAgent('
      'id: $id, '
      'type: $type, '
      'version: $version, '
      'name: $name, '
      'description: $description, '
      'system: $system, '
      'model: $model, '
      'mcpServers: $mcpServers, '
      'skills: $skills, '
      'tools: $tools)';
}

/// Timing statistics for a session.
@immutable
class SessionStats {
  /// Cumulative time in seconds the session spent in running status.
  final double? activeSeconds;

  /// Elapsed time since session creation in seconds.
  final double? durationSeconds;

  /// Creates a [SessionStats].
  const SessionStats({this.activeSeconds, this.durationSeconds});

  /// Creates a [SessionStats] from JSON.
  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      activeSeconds: (json['active_seconds'] as num?)?.toDouble(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (activeSeconds != null) 'active_seconds': activeSeconds,
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
  };

  /// Creates a copy with replaced values.
  SessionStats copyWith({
    Object? activeSeconds = unsetCopyWithValue,
    Object? durationSeconds = unsetCopyWithValue,
  }) {
    return SessionStats(
      activeSeconds: activeSeconds == unsetCopyWithValue
          ? this.activeSeconds
          : activeSeconds as double?,
      durationSeconds: durationSeconds == unsetCopyWithValue
          ? this.durationSeconds
          : durationSeconds as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStats &&
          runtimeType == other.runtimeType &&
          activeSeconds == other.activeSeconds &&
          durationSeconds == other.durationSeconds;

  @override
  int get hashCode => Object.hash(activeSeconds, durationSeconds);

  @override
  String toString() =>
      'SessionStats('
      'activeSeconds: $activeSeconds, '
      'durationSeconds: $durationSeconds)';
}

/// Cumulative token usage for a session across all turns.
@immutable
class SessionUsage {
  /// Total input tokens consumed across all turns.
  final int? inputTokens;

  /// Total output tokens generated across all turns.
  final int? outputTokens;

  /// Total tokens read from prompt cache.
  final int? cacheReadInputTokens;

  /// Tokens used to create prompt cache entries.
  final CacheCreationUsage? cacheCreation;

  /// Creates a [SessionUsage].
  const SessionUsage({
    this.inputTokens,
    this.outputTokens,
    this.cacheReadInputTokens,
    this.cacheCreation,
  });

  /// Creates a [SessionUsage] from JSON.
  factory SessionUsage.fromJson(Map<String, dynamic> json) {
    return SessionUsage(
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
      cacheReadInputTokens: json['cache_read_input_tokens'] as int?,
      cacheCreation: json['cache_creation'] != null
          ? CacheCreationUsage.fromJson(
              json['cache_creation'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (inputTokens != null) 'input_tokens': inputTokens,
    if (outputTokens != null) 'output_tokens': outputTokens,
    if (cacheReadInputTokens != null)
      'cache_read_input_tokens': cacheReadInputTokens,
    if (cacheCreation != null) 'cache_creation': cacheCreation!.toJson(),
  };

  /// Creates a copy with replaced values.
  SessionUsage copyWith({
    Object? inputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? cacheCreation = unsetCopyWithValue,
  }) {
    return SessionUsage(
      inputTokens: inputTokens == unsetCopyWithValue
          ? this.inputTokens
          : inputTokens as int?,
      outputTokens: outputTokens == unsetCopyWithValue
          ? this.outputTokens
          : outputTokens as int?,
      cacheReadInputTokens: cacheReadInputTokens == unsetCopyWithValue
          ? this.cacheReadInputTokens
          : cacheReadInputTokens as int?,
      cacheCreation: cacheCreation == unsetCopyWithValue
          ? this.cacheCreation
          : cacheCreation as CacheCreationUsage?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUsage &&
          runtimeType == other.runtimeType &&
          inputTokens == other.inputTokens &&
          outputTokens == other.outputTokens &&
          cacheReadInputTokens == other.cacheReadInputTokens &&
          cacheCreation == other.cacheCreation;

  @override
  int get hashCode => Object.hash(
    inputTokens,
    outputTokens,
    cacheReadInputTokens,
    cacheCreation,
  );

  @override
  String toString() =>
      'SessionUsage('
      'inputTokens: $inputTokens, '
      'outputTokens: $outputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'cacheCreation: $cacheCreation)';
}

/// Confirmation that a session has been permanently deleted.
@immutable
class DeletedSession {
  /// Session identifier.
  final String id;

  /// Object type. Always "session_deleted".
  final String type;

  /// Creates a [DeletedSession].
  const DeletedSession({required this.id, this.type = 'session_deleted'});

  /// Creates a [DeletedSession] from JSON.
  factory DeletedSession.fromJson(Map<String, dynamic> json) {
    return DeletedSession(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'session_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedSession copyWith({String? id, String? type}) {
    return DeletedSession(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedSession(id: $id, type: $type)';
}
