import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// A work item for a self-hosted Managed Agents environment.
@immutable
final class EnvironmentWorkItem {
  /// The wire discriminator.
  String get type => 'work';

  /// Work identifier.
  final String id;

  /// Identifier of the self-hosted environment.
  final String environmentId;

  /// Wire state, including any state added by the server.
  final String state;

  /// The work to perform.
  final EnvironmentWorkData data;

  /// User-provided metadata.
  final Map<String, String> metadata;

  /// When the work item was created.
  final DateTime createdAt;

  /// When the item was acknowledged.
  final DateTime? acknowledgedAt;

  /// When the most recent heartbeat was recorded.
  final DateTime? latestHeartbeatAt;

  /// When execution began.
  final DateTime? startedAt;

  /// When stopping was requested.
  final DateTime? stopRequestedAt;

  /// When execution ended.
  final DateTime? stoppedAt;

  /// Sensitive encoded credentials, available only when supplied by polling.
  final String? secret;

  /// Creates a [EnvironmentWorkItem].
  const EnvironmentWorkItem({
    required this.id,
    required this.environmentId,
    required this.state,
    required this.data,
    required this.metadata,
    required this.createdAt,
    required this.acknowledgedAt,
    required this.latestHeartbeatAt,
    required this.startedAt,
    required this.stopRequestedAt,
    required this.stoppedAt,
    required this.secret,
  });

  /// Decodes the scoped session credential, if supplied by the server.
  ///
  /// The encoded payload itself is not a bearer token. The caller controls
  /// whether and where the extracted token is used.
  EnvironmentWorkSecret? get credentials {
    final value = secret;
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(value))),
      );
      if (decoded case {'sessions_token': final String token}
          when token.isNotEmpty) {
        return EnvironmentWorkSecret(
          sessionsToken: token,
          apiBaseUrl: switch (decoded) {
            {'api_base_url': final String url} => url,
            _ => null,
          },
        );
      }
    } on FormatException {
      // Missing or invalid work credentials are handled by the worker.
    }
    return null;
  }

  /// Reads a [EnvironmentWorkItem] from JSON.
  factory EnvironmentWorkItem.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'work');
    return EnvironmentWorkItem(
      id: json['id'] as String,
      environmentId: json['environment_id'] as String,
      state: json['state'] as String,
      data: EnvironmentWorkData.fromJson(json['data'] as Map<String, dynamic>),
      metadata: (json['metadata'] as Map).cast<String, String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      acknowledgedAt: json['acknowledged_at'] == null
          ? null
          : DateTime.parse(json['acknowledged_at'] as String),
      latestHeartbeatAt: json['latest_heartbeat_at'] == null
          ? null
          : DateTime.parse(json['latest_heartbeat_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      stopRequestedAt: json['stop_requested_at'] == null
          ? null
          : DateTime.parse(json['stop_requested_at'] as String),
      stoppedAt: json['stopped_at'] == null
          ? null
          : DateTime.parse(json['stopped_at'] as String),
      secret: json['secret'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'environment_id': environmentId,
    'state': state,
    'data': data.toJson(),
    'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'acknowledged_at': acknowledgedAt?.toUtc().toIso8601String(),
    'latest_heartbeat_at': latestHeartbeatAt?.toUtc().toIso8601String(),
    'started_at': startedAt?.toUtc().toIso8601String(),
    'stop_requested_at': stopRequestedAt?.toUtc().toIso8601String(),
    'stopped_at': stoppedAt?.toUtc().toIso8601String(),
    'secret': secret,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentWorkItem copyWith({
    String? id,
    String? environmentId,
    String? state,
    EnvironmentWorkData? data,
    Map<String, String>? metadata,
    DateTime? createdAt,
    Object? acknowledgedAt = unsetCopyWithValue,
    Object? latestHeartbeatAt = unsetCopyWithValue,
    Object? startedAt = unsetCopyWithValue,
    Object? stopRequestedAt = unsetCopyWithValue,
    Object? stoppedAt = unsetCopyWithValue,
    Object? secret = unsetCopyWithValue,
  }) => EnvironmentWorkItem(
    id: id ?? this.id,
    environmentId: environmentId ?? this.environmentId,
    state: state ?? this.state,
    data: data ?? this.data,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    acknowledgedAt: acknowledgedAt == unsetCopyWithValue
        ? this.acknowledgedAt
        : acknowledgedAt as DateTime?,
    latestHeartbeatAt: latestHeartbeatAt == unsetCopyWithValue
        ? this.latestHeartbeatAt
        : latestHeartbeatAt as DateTime?,
    startedAt: startedAt == unsetCopyWithValue
        ? this.startedAt
        : startedAt as DateTime?,
    stopRequestedAt: stopRequestedAt == unsetCopyWithValue
        ? this.stopRequestedAt
        : stopRequestedAt as DateTime?,
    stoppedAt: stoppedAt == unsetCopyWithValue
        ? this.stoppedAt
        : stoppedAt as DateTime?,
    secret: secret == unsetCopyWithValue ? this.secret : secret as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentWorkItem &&
          id == other.id &&
          environmentId == other.environmentId &&
          state == other.state &&
          data == other.data &&
          mapsEqual(metadata, other.metadata) &&
          createdAt == other.createdAt &&
          acknowledgedAt == other.acknowledgedAt &&
          latestHeartbeatAt == other.latestHeartbeatAt &&
          startedAt == other.startedAt &&
          stopRequestedAt == other.stopRequestedAt &&
          stoppedAt == other.stoppedAt &&
          secret == other.secret;

  @override
  int get hashCode => Object.hash(
    id,
    environmentId,
    state,
    data,
    mapHash(metadata),
    createdAt,
    acknowledgedAt,
    latestHeartbeatAt,
    startedAt,
    stopRequestedAt,
    stoppedAt,
    secret,
  );

  @override
  String toString() =>
      'EnvironmentWorkItem(id: $id, environmentId: $environmentId, state: $state, '
      'data: ${data.type}, metadata: ${metadata.length} entries, '
      'createdAt: $createdAt, acknowledgedAt: $acknowledgedAt, '
      'latestHeartbeatAt: $latestHeartbeatAt, startedAt: $startedAt, '
      'stopRequestedAt: $stopRequestedAt, stoppedAt: $stoppedAt, '
      'secret: ${secret == null ? null : "[REDACTED]"})';
}

/// The type of work assigned to a self-hosted environment.
@immutable
sealed class EnvironmentWorkData {
  const EnvironmentWorkData();

  /// Reads the configuration discriminator.
  factory EnvironmentWorkData.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'session' => SessionEnvironmentWork.fromJson(json),
        'healthcheck' || null => HealthCheckEnvironmentWork.fromJson(json),
        String() => UnknownEnvironmentWork(rawJson: deepUnmodifiableMap(json)),
        _ => throw const FormatException('Environment work data requires type'),
      };

  /// The wire discriminator.
  String get type;

  /// Serializes to API JSON.
  Map<String, dynamic> toJson();
}

/// A future configuration variant preserved as raw JSON.
@immutable
final class UnknownEnvironmentWork extends EnvironmentWorkData {
  /// Creates an [UnknownEnvironmentWork].
  const UnknownEnvironmentWork({required this.rawJson});

  /// The received configuration.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  bool operator ==(Object other) =>
      other is UnknownEnvironmentWork && mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownEnvironmentWork(type: $type)';
}

/// An assignment to run a Managed Agents session.
@immutable
final class SessionEnvironmentWork extends EnvironmentWorkData {
  /// The wire discriminator.
  @override
  String get type => 'session';

  /// Identifier of the session to run.
  final String id;

  /// Creates a [SessionEnvironmentWork].
  const SessionEnvironmentWork({required this.id});

  /// Reads a [SessionEnvironmentWork] from JSON.
  factory SessionEnvironmentWork.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'session');
    return SessionEnvironmentWork(id: json['id'] as String);
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this object with the selected values replaced.
  SessionEnvironmentWork copyWith({String? id}) =>
      SessionEnvironmentWork(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEnvironmentWork && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SessionEnvironmentWork(id: $id)';
}

/// An assignment to check the health of a self-hosted worker.
@immutable
final class HealthCheckEnvironmentWork extends EnvironmentWorkData {
  /// The wire discriminator.
  @override
  String get type => 'healthcheck';

  /// Health check identifier.
  final String id;

  /// Creates a [HealthCheckEnvironmentWork].
  const HealthCheckEnvironmentWork({required this.id});

  /// Reads a [HealthCheckEnvironmentWork] from JSON.
  factory HealthCheckEnvironmentWork.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'healthcheck');
    return HealthCheckEnvironmentWork(id: json['id'] as String);
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Copies this object with the selected values replaced.
  HealthCheckEnvironmentWork copyWith({String? id}) =>
      HealthCheckEnvironmentWork(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthCheckEnvironmentWork && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HealthCheckEnvironmentWork(id: $id)';
}

/// One cursor page of environment work items.
@immutable
final class EnvironmentWorkListResponse {
  /// The work items in this page.
  final List<EnvironmentWorkItem> data;

  /// Opaque cursor, or null when no results remain.
  final String? nextPage;

  /// Creates a [EnvironmentWorkListResponse].
  const EnvironmentWorkListResponse({
    required this.data,
    required this.nextPage,
  });

  /// Reads a [EnvironmentWorkListResponse] from JSON.
  factory EnvironmentWorkListResponse.fromJson(Map<String, dynamic> json) {
    return EnvironmentWorkListResponse(
      data: (json['data'] as List)
          .map(
            (item) =>
                EnvironmentWorkItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentWorkListResponse copyWith({
    List<EnvironmentWorkItem>? data,
    Object? nextPage = unsetCopyWithValue,
  }) => EnvironmentWorkListResponse(
    data: data ?? this.data,
    nextPage: nextPage == unsetCopyWithValue
        ? this.nextPage
        : nextPage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentWorkListResponse &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'EnvironmentWorkListResponse(data: ${data.length} items, nextPage: $nextPage)';
}

/// Result of extending a work item lease.
@immutable
final class EnvironmentWorkHeartbeat {
  /// The wire discriminator.
  String get type => 'work_heartbeat';

  /// Echo this opaque string on the next conditional heartbeat.
  final String lastHeartbeat;

  /// Whether the heartbeat extended the lease.
  final bool leaseExtended;

  /// Current wire state of the work item.
  final String state;

  /// Effective lease TTL in seconds.
  final int ttlSeconds;

  /// Creates a [EnvironmentWorkHeartbeat].
  const EnvironmentWorkHeartbeat({
    required this.lastHeartbeat,
    required this.leaseExtended,
    required this.state,
    required this.ttlSeconds,
  });

  /// Reads a [EnvironmentWorkHeartbeat] from JSON.
  factory EnvironmentWorkHeartbeat.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'work_heartbeat');
    return EnvironmentWorkHeartbeat(
      lastHeartbeat: json['last_heartbeat'] as String,
      leaseExtended: json['lease_extended'] as bool,
      state: json['state'] as String,
      ttlSeconds: json['ttl_seconds'] as int,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'last_heartbeat': lastHeartbeat,
    'lease_extended': leaseExtended,
    'state': state,
    'ttl_seconds': ttlSeconds,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentWorkHeartbeat copyWith({
    String? lastHeartbeat,
    bool? leaseExtended,
    String? state,
    int? ttlSeconds,
  }) => EnvironmentWorkHeartbeat(
    lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
    leaseExtended: leaseExtended ?? this.leaseExtended,
    state: state ?? this.state,
    ttlSeconds: ttlSeconds ?? this.ttlSeconds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentWorkHeartbeat &&
          lastHeartbeat == other.lastHeartbeat &&
          leaseExtended == other.leaseExtended &&
          state == other.state &&
          ttlSeconds == other.ttlSeconds;

  @override
  int get hashCode =>
      Object.hash(lastHeartbeat, leaseExtended, state, ttlSeconds);

  @override
  String toString() =>
      'EnvironmentWorkHeartbeat(lastHeartbeat: $lastHeartbeat, leaseExtended: $leaseExtended, state: $state, ttlSeconds: $ttlSeconds)';
}

/// The work lease state returned on a heartbeat conflict.
@immutable
final class EnvironmentWorkLeaseState {
  /// The last accepted heartbeat value.
  final String? lastHeartbeat;

  /// Whether the refused heartbeat extended the lease.
  final bool leaseExtended;

  /// Current wire state of the work item.
  final String state;

  /// Effective lease TTL in seconds.
  final int ttlSeconds;

  /// Creates a [EnvironmentWorkLeaseState].
  const EnvironmentWorkLeaseState({
    required this.lastHeartbeat,
    required this.leaseExtended,
    required this.state,
    required this.ttlSeconds,
  });

  /// Reads a [EnvironmentWorkLeaseState] from JSON.
  factory EnvironmentWorkLeaseState.fromJson(Map<String, dynamic> json) {
    return EnvironmentWorkLeaseState(
      lastHeartbeat: json['last_heartbeat'] as String?,
      leaseExtended: json['lease_extended'] as bool,
      state: json['state'] as String,
      ttlSeconds: json['ttl_seconds'] as int,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'last_heartbeat': lastHeartbeat,
    'lease_extended': leaseExtended,
    'state': state,
    'ttl_seconds': ttlSeconds,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentWorkLeaseState copyWith({
    Object? lastHeartbeat = unsetCopyWithValue,
    bool? leaseExtended,
    String? state,
    int? ttlSeconds,
  }) => EnvironmentWorkLeaseState(
    lastHeartbeat: lastHeartbeat == unsetCopyWithValue
        ? this.lastHeartbeat
        : lastHeartbeat as String?,
    leaseExtended: leaseExtended ?? this.leaseExtended,
    state: state ?? this.state,
    ttlSeconds: ttlSeconds ?? this.ttlSeconds,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentWorkLeaseState &&
          lastHeartbeat == other.lastHeartbeat &&
          leaseExtended == other.leaseExtended &&
          state == other.state &&
          ttlSeconds == other.ttlSeconds;

  @override
  int get hashCode =>
      Object.hash(lastHeartbeat, leaseExtended, state, ttlSeconds);

  @override
  String toString() =>
      'EnvironmentWorkLeaseState(lastHeartbeat: $lastHeartbeat, leaseExtended: $leaseExtended, state: $state, ttlSeconds: $ttlSeconds)';
}

/// Statistics for an environment work queue.
@immutable
final class EnvironmentWorkQueueStats {
  /// The wire discriminator.
  String get type => 'work_queue_stats';

  /// Number of queued work items.
  final int depth;

  /// When the oldest work item was queued.
  final DateTime? oldestQueuedAt;

  /// Number of pending work items.
  final int pending;

  /// Number of workers currently polling.
  final int? workersPolling;

  /// Creates a [EnvironmentWorkQueueStats].
  const EnvironmentWorkQueueStats({
    required this.depth,
    required this.oldestQueuedAt,
    required this.pending,
    required this.workersPolling,
  });

  /// Reads a [EnvironmentWorkQueueStats] from JSON.
  factory EnvironmentWorkQueueStats.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'work_queue_stats');
    return EnvironmentWorkQueueStats(
      depth: json['depth'] as int,
      oldestQueuedAt: json['oldest_queued_at'] == null
          ? null
          : DateTime.parse(json['oldest_queued_at'] as String),
      pending: json['pending'] as int,
      workersPolling: json['workers_polling'] as int?,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'depth': depth,
    'oldest_queued_at': oldestQueuedAt?.toUtc().toIso8601String(),
    'pending': pending,
    'workers_polling': workersPolling,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentWorkQueueStats copyWith({
    int? depth,
    Object? oldestQueuedAt = unsetCopyWithValue,
    int? pending,
    Object? workersPolling = unsetCopyWithValue,
  }) => EnvironmentWorkQueueStats(
    depth: depth ?? this.depth,
    oldestQueuedAt: oldestQueuedAt == unsetCopyWithValue
        ? this.oldestQueuedAt
        : oldestQueuedAt as DateTime?,
    pending: pending ?? this.pending,
    workersPolling: workersPolling == unsetCopyWithValue
        ? this.workersPolling
        : workersPolling as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentWorkQueueStats &&
          depth == other.depth &&
          oldestQueuedAt == other.oldestQueuedAt &&
          pending == other.pending &&
          workersPolling == other.workersPolling;

  @override
  int get hashCode =>
      Object.hash(depth, oldestQueuedAt, pending, workersPolling);

  @override
  String toString() =>
      'EnvironmentWorkQueueStats(depth: $depth, oldestQueuedAt: $oldestQueuedAt, pending: $pending, workersPolling: $workersPolling)';
}

/// Scoped credentials carried by an environment work item.
@immutable
final class EnvironmentWorkSecret {
  /// Creates a decoded work credential.
  const EnvironmentWorkSecret({required this.sessionsToken, this.apiBaseUrl});

  /// Sensitive bearer credential for session and work lifecycle calls.
  final String sessionsToken;

  /// API base URL hint from the provider. The SDK does not follow it automatically.
  final String? apiBaseUrl;

  @override
  String toString() => 'EnvironmentWorkSecret([REDACTED])';
}

void _validateType(Map<String, dynamic> json, String type) {
  if (json.containsKey('type') && json['type'] != type) {
    throw FormatException('Expected $type, got ${json['type']}');
  }
}
