import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';
import '../events/telemetry.dart';
import 'session.dart' show SessionAgent, SessionStatus;

/// A thread within a Managed Agents session.
///
/// A session may be segmented into multiple threads — for example, a parent
/// orchestrator agent and one or more sub-agent threads. The thread carries
/// its own status, usage, and stats independent of the parent session.
@immutable
class SessionThread {
  /// Unique identifier for the thread.
  final String id;

  /// Object type. Always "session_thread".
  final String type;

  /// Identifier of the session this thread belongs to.
  final String sessionId;

  /// Current thread status.
  final SessionStatus status;

  /// Resolved agent snapshot at thread creation time.
  final SessionAgent agent;

  /// Identifier of the parent thread, when this thread was spawned by another.
  /// `null` for top-level threads.
  final String? parentThreadId;

  /// When the thread was created.
  final BetaTimestamp createdAt;

  /// When the thread was last updated.
  final BetaTimestamp updatedAt;

  /// When the thread was archived. `null` if not archived.
  final BetaTimestamp? archivedAt;

  /// Cumulative token usage for the thread. `null` if not yet available.
  final SessionThreadUsage? usage;

  /// Timing statistics for the thread. `null` if not yet available.
  final SessionThreadStats? stats;

  /// Creates a [SessionThread].
  const SessionThread({
    required this.id,
    this.type = 'session_thread',
    required this.sessionId,
    required this.status,
    required this.agent,
    required this.parentThreadId,
    required this.createdAt,
    required this.updatedAt,
    required this.archivedAt,
    required this.usage,
    required this.stats,
  });

  /// Creates a [SessionThread] from JSON.
  factory SessionThread.fromJson(Map<String, dynamic> json) {
    return SessionThread(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'session_thread',
      sessionId: json['session_id'] as String,
      status: SessionStatus.fromJson(json['status'] as String),
      agent: SessionAgent.fromJson(json['agent'] as Map<String, dynamic>),
      parentThreadId: json['parent_thread_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      usage: json['usage'] != null
          ? SessionThreadUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? SessionThreadStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'session_id': sessionId,
    'status': status.toJson(),
    'agent': agent.toJson(),
    'parent_thread_id': parentThreadId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
    'usage': usage?.toJson(),
    'stats': stats?.toJson(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([parentThreadId], [archivedAt], [usage], [stats]),
  /// pass the sentinel value [unsetCopyWithValue] (or omit) to keep the
  /// original value, or pass `null` explicitly to set the field to null.
  SessionThread copyWith({
    String? id,
    String? type,
    String? sessionId,
    SessionStatus? status,
    SessionAgent? agent,
    Object? parentThreadId = unsetCopyWithValue,
    BetaTimestamp? createdAt,
    BetaTimestamp? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? stats = unsetCopyWithValue,
  }) {
    return SessionThread(
      id: id ?? this.id,
      type: type ?? this.type,
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      agent: agent ?? this.agent,
      parentThreadId: parentThreadId == unsetCopyWithValue
          ? this.parentThreadId
          : parentThreadId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as BetaTimestamp?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as SessionThreadUsage?,
      stats: stats == unsetCopyWithValue
          ? this.stats
          : stats as SessionThreadStats?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThread &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          sessionId == other.sessionId &&
          status == other.status &&
          agent == other.agent &&
          parentThreadId == other.parentThreadId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt &&
          usage == other.usage &&
          stats == other.stats;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    sessionId,
    status,
    agent,
    parentThreadId,
    createdAt,
    updatedAt,
    archivedAt,
    usage,
    stats,
  );

  @override
  String toString() =>
      'SessionThread('
      'id: $id, '
      'type: $type, '
      'sessionId: $sessionId, '
      'status: $status, '
      'agent: $agent, '
      'parentThreadId: $parentThreadId, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt, '
      'usage: $usage, '
      'stats: $stats)';
}

/// Timing statistics for a session thread.
@immutable
class SessionThreadStats {
  /// Cumulative time in seconds the thread spent in running status.
  final double? activeSeconds;

  /// Elapsed time since thread creation in seconds.
  final double? durationSeconds;

  /// Time the thread spent starting up before its first agent turn.
  final double? startupSeconds;

  /// Creates a [SessionThreadStats].
  const SessionThreadStats({
    this.activeSeconds,
    this.durationSeconds,
    this.startupSeconds,
  });

  /// Creates a [SessionThreadStats] from JSON.
  factory SessionThreadStats.fromJson(Map<String, dynamic> json) {
    return SessionThreadStats(
      activeSeconds: (json['active_seconds'] as num?)?.toDouble(),
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble(),
      startupSeconds: (json['startup_seconds'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (activeSeconds != null) 'active_seconds': activeSeconds,
    if (durationSeconds != null) 'duration_seconds': durationSeconds,
    if (startupSeconds != null) 'startup_seconds': startupSeconds,
  };

  /// Creates a copy with replaced values.
  SessionThreadStats copyWith({
    Object? activeSeconds = unsetCopyWithValue,
    Object? durationSeconds = unsetCopyWithValue,
    Object? startupSeconds = unsetCopyWithValue,
  }) {
    return SessionThreadStats(
      activeSeconds: activeSeconds == unsetCopyWithValue
          ? this.activeSeconds
          : activeSeconds as double?,
      durationSeconds: durationSeconds == unsetCopyWithValue
          ? this.durationSeconds
          : durationSeconds as double?,
      startupSeconds: startupSeconds == unsetCopyWithValue
          ? this.startupSeconds
          : startupSeconds as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionThreadStats &&
          runtimeType == other.runtimeType &&
          activeSeconds == other.activeSeconds &&
          durationSeconds == other.durationSeconds &&
          startupSeconds == other.startupSeconds;

  @override
  int get hashCode =>
      Object.hash(activeSeconds, durationSeconds, startupSeconds);

  @override
  String toString() =>
      'SessionThreadStats('
      'activeSeconds: $activeSeconds, '
      'durationSeconds: $durationSeconds, '
      'startupSeconds: $startupSeconds)';
}

/// Cumulative token usage for a session thread.
@immutable
class SessionThreadUsage {
  /// Total input tokens consumed across all thread turns.
  final int? inputTokens;

  /// Total output tokens generated across all thread turns.
  final int? outputTokens;

  /// Total tokens read from prompt cache.
  final int? cacheReadInputTokens;

  /// Tokens used to create prompt cache entries.
  final CacheCreationUsage? cacheCreation;

  /// Creates a [SessionThreadUsage].
  const SessionThreadUsage({
    this.inputTokens,
    this.outputTokens,
    this.cacheReadInputTokens,
    this.cacheCreation,
  });

  /// Creates a [SessionThreadUsage] from JSON.
  factory SessionThreadUsage.fromJson(Map<String, dynamic> json) {
    return SessionThreadUsage(
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
  SessionThreadUsage copyWith({
    Object? inputTokens = unsetCopyWithValue,
    Object? outputTokens = unsetCopyWithValue,
    Object? cacheReadInputTokens = unsetCopyWithValue,
    Object? cacheCreation = unsetCopyWithValue,
  }) {
    return SessionThreadUsage(
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
      other is SessionThreadUsage &&
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
      'SessionThreadUsage('
      'inputTokens: $inputTokens, '
      'outputTokens: $outputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'cacheCreation: $cacheCreation)';
}
