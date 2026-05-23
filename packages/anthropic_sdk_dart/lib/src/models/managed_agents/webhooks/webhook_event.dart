import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/equality_helpers.dart';

/// A webhook event delivered to a configured endpoint (Beta).
///
/// Parse an inbound webhook request body with [WebhookEvent.fromJson]; the
/// typed payload is available via [data].
@immutable
class WebhookEvent {
  /// Object type. Always 'event'.
  final String type;

  /// Unique identifier for this event.
  final String id;

  /// When the event was created.
  final BetaTimestamp createdAt;

  /// The typed event payload.
  final WebhookEventData data;

  /// Creates a [WebhookEvent].
  const WebhookEvent({
    this.type = 'event',
    required this.id,
    required this.createdAt,
    required this.data,
  });

  /// Creates a [WebhookEvent] from JSON.
  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return WebhookEvent(
      type: json['type'] as String? ?? 'event',
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      data: WebhookEventData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'created_at': createdAt.toUtc().toIso8601String(),
    'data': data.toJson(),
  };

  /// Creates a copy with replaced values.
  WebhookEvent copyWith({
    String? type,
    String? id,
    BetaTimestamp? createdAt,
    WebhookEventData? data,
  }) {
    return WebhookEvent(
      type: type ?? this.type,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          createdAt == other.createdAt &&
          data == other.data;

  @override
  int get hashCode => Object.hash(type, id, createdAt, data);

  @override
  String toString() =>
      'WebhookEvent(type: $type, id: $id, createdAt: $createdAt, data: $data)';
}

/// Payload data for a [WebhookEvent], discriminated by `type`.
///
/// Variants:
/// - [WebhookSessionArchivedEventData] — `session.archived`.
/// - [WebhookSessionCreatedEventData] — `session.created`.
/// - [WebhookSessionDeletedEventData] — `session.deleted`.
/// - [WebhookSessionIdledEventData] — `session.idled`.
/// - [WebhookSessionOutcomeEvaluationEndedEventData] — `session.outcome_evaluation_ended`.
/// - [WebhookSessionPendingEventData] — `session.pending`.
/// - [WebhookSessionRequiresActionEventData] — `session.requires_action`.
/// - [WebhookSessionRunningEventData] — `session.running`.
/// - [WebhookSessionStatusIdledEventData] — `session.status_idled`.
/// - [WebhookSessionStatusRescheduledEventData] — `session.status_rescheduled`.
/// - [WebhookSessionStatusRunStartedEventData] — `session.status_run_started`.
/// - [WebhookSessionStatusTerminatedEventData] — `session.status_terminated`.
/// - [WebhookSessionThreadCreatedEventData] — `session.thread_created`.
/// - [WebhookSessionThreadIdledEventData] — `session.thread_idled`.
/// - [WebhookSessionThreadTerminatedEventData] — `session.thread_terminated`.
/// - [WebhookVaultCreatedEventData] — `vault.created`.
/// - [WebhookVaultArchivedEventData] — `vault.archived`.
/// - [WebhookVaultDeletedEventData] — `vault.deleted`.
/// - [WebhookVaultCredentialCreatedEventData] — `vault_credential.created`.
/// - [WebhookVaultCredentialArchivedEventData] — `vault_credential.archived`.
/// - [WebhookVaultCredentialDeletedEventData] — `vault_credential.deleted`.
/// - [WebhookVaultCredentialRefreshFailedEventData] — `vault_credential.refresh_failed`.
/// - [UnknownWebhookEventData] — unrecognized event-data type, for forward
///   compatibility.
sealed class WebhookEventData {
  const WebhookEventData();

  /// Creates a [WebhookEventData] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownWebhookEventData].
  factory WebhookEventData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'session.archived' => WebhookSessionArchivedEventData.fromJson(json),
      'session.created' => WebhookSessionCreatedEventData.fromJson(json),
      'session.deleted' => WebhookSessionDeletedEventData.fromJson(json),
      'session.idled' => WebhookSessionIdledEventData.fromJson(json),
      'session.outcome_evaluation_ended' =>
        WebhookSessionOutcomeEvaluationEndedEventData.fromJson(json),
      'session.pending' => WebhookSessionPendingEventData.fromJson(json),
      'session.requires_action' =>
        WebhookSessionRequiresActionEventData.fromJson(json),
      'session.running' => WebhookSessionRunningEventData.fromJson(json),
      'session.status_idled' => WebhookSessionStatusIdledEventData.fromJson(
        json,
      ),
      'session.status_rescheduled' =>
        WebhookSessionStatusRescheduledEventData.fromJson(json),
      'session.status_run_started' =>
        WebhookSessionStatusRunStartedEventData.fromJson(json),
      'session.status_terminated' =>
        WebhookSessionStatusTerminatedEventData.fromJson(json),
      'session.thread_created' => WebhookSessionThreadCreatedEventData.fromJson(
        json,
      ),
      'session.thread_idled' => WebhookSessionThreadIdledEventData.fromJson(
        json,
      ),
      'session.thread_terminated' =>
        WebhookSessionThreadTerminatedEventData.fromJson(json),
      'vault.created' => WebhookVaultCreatedEventData.fromJson(json),
      'vault.archived' => WebhookVaultArchivedEventData.fromJson(json),
      'vault.deleted' => WebhookVaultDeletedEventData.fromJson(json),
      'vault_credential.created' =>
        WebhookVaultCredentialCreatedEventData.fromJson(json),
      'vault_credential.archived' =>
        WebhookVaultCredentialArchivedEventData.fromJson(json),
      'vault_credential.deleted' =>
        WebhookVaultCredentialDeletedEventData.fromJson(json),
      'vault_credential.refresh_failed' =>
        WebhookVaultCredentialRefreshFailedEventData.fromJson(json),
      _ => UnknownWebhookEventData(rawJson: json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Webhook event data signalling a session was archived.
@immutable
class WebhookSessionArchivedEventData extends WebhookEventData {
  /// The event-data type, always 'session.archived'.
  String get type => 'session.archived';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionArchivedEventData].
  const WebhookSessionArchivedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionArchivedEventData] from JSON.
  factory WebhookSessionArchivedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionArchivedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionArchivedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionArchivedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionArchivedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionArchivedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session was created.
@immutable
class WebhookSessionCreatedEventData extends WebhookEventData {
  /// The event-data type, always 'session.created'.
  String get type => 'session.created';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionCreatedEventData].
  const WebhookSessionCreatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionCreatedEventData] from JSON.
  factory WebhookSessionCreatedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionCreatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionCreatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionCreatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionCreatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionCreatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session was deleted.
@immutable
class WebhookSessionDeletedEventData extends WebhookEventData {
  /// The event-data type, always 'session.deleted'.
  String get type => 'session.deleted';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionDeletedEventData].
  const WebhookSessionDeletedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionDeletedEventData] from JSON.
  factory WebhookSessionDeletedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionDeletedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionDeletedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionDeletedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionDeletedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionDeletedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session went idle.
@immutable
class WebhookSessionIdledEventData extends WebhookEventData {
  /// The event-data type, always 'session.idled'.
  String get type => 'session.idled';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionIdledEventData].
  const WebhookSessionIdledEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionIdledEventData] from JSON.
  factory WebhookSessionIdledEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionIdledEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionIdledEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionIdledEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionIdledEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionIdledEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling an outcome evaluation finished for a session.
@immutable
class WebhookSessionOutcomeEvaluationEndedEventData extends WebhookEventData {
  /// The event-data type, always 'session.outcome_evaluation_ended'.
  String get type => 'session.outcome_evaluation_ended';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionOutcomeEvaluationEndedEventData].
  const WebhookSessionOutcomeEvaluationEndedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionOutcomeEvaluationEndedEventData] from JSON.
  factory WebhookSessionOutcomeEvaluationEndedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionOutcomeEvaluationEndedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionOutcomeEvaluationEndedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionOutcomeEvaluationEndedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionOutcomeEvaluationEndedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionOutcomeEvaluationEndedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session became pending.
@immutable
class WebhookSessionPendingEventData extends WebhookEventData {
  /// The event-data type, always 'session.pending'.
  String get type => 'session.pending';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionPendingEventData].
  const WebhookSessionPendingEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionPendingEventData] from JSON.
  factory WebhookSessionPendingEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionPendingEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionPendingEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionPendingEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionPendingEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionPendingEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session requires action.
@immutable
class WebhookSessionRequiresActionEventData extends WebhookEventData {
  /// The event-data type, always 'session.requires_action'.
  String get type => 'session.requires_action';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionRequiresActionEventData].
  const WebhookSessionRequiresActionEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionRequiresActionEventData] from JSON.
  factory WebhookSessionRequiresActionEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionRequiresActionEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionRequiresActionEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionRequiresActionEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionRequiresActionEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionRequiresActionEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session started running.
@immutable
class WebhookSessionRunningEventData extends WebhookEventData {
  /// The event-data type, always 'session.running'.
  String get type => 'session.running';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionRunningEventData].
  const WebhookSessionRunningEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionRunningEventData] from JSON.
  factory WebhookSessionRunningEventData.fromJson(Map<String, dynamic> json) {
    return WebhookSessionRunningEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionRunningEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionRunningEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionRunningEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionRunningEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session run status changed to idled.
@immutable
class WebhookSessionStatusIdledEventData extends WebhookEventData {
  /// The event-data type, always 'session.status_idled'.
  String get type => 'session.status_idled';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionStatusIdledEventData].
  const WebhookSessionStatusIdledEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionStatusIdledEventData] from JSON.
  factory WebhookSessionStatusIdledEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionStatusIdledEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionStatusIdledEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionStatusIdledEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionStatusIdledEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionStatusIdledEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session run status changed to rescheduled.
@immutable
class WebhookSessionStatusRescheduledEventData extends WebhookEventData {
  /// The event-data type, always 'session.status_rescheduled'.
  String get type => 'session.status_rescheduled';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionStatusRescheduledEventData].
  const WebhookSessionStatusRescheduledEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionStatusRescheduledEventData] from JSON.
  factory WebhookSessionStatusRescheduledEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionStatusRescheduledEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionStatusRescheduledEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionStatusRescheduledEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionStatusRescheduledEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionStatusRescheduledEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session run status changed to run-started.
@immutable
class WebhookSessionStatusRunStartedEventData extends WebhookEventData {
  /// The event-data type, always 'session.status_run_started'.
  String get type => 'session.status_run_started';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionStatusRunStartedEventData].
  const WebhookSessionStatusRunStartedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionStatusRunStartedEventData] from JSON.
  factory WebhookSessionStatusRunStartedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionStatusRunStartedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionStatusRunStartedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionStatusRunStartedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionStatusRunStartedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionStatusRunStartedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session run status changed to terminated.
@immutable
class WebhookSessionStatusTerminatedEventData extends WebhookEventData {
  /// The event-data type, always 'session.status_terminated'.
  String get type => 'session.status_terminated';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionStatusTerminatedEventData].
  const WebhookSessionStatusTerminatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionStatusTerminatedEventData] from JSON.
  factory WebhookSessionStatusTerminatedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionStatusTerminatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionStatusTerminatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionStatusTerminatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionStatusTerminatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionStatusTerminatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session thread was created.
@immutable
class WebhookSessionThreadCreatedEventData extends WebhookEventData {
  /// The event-data type, always 'session.thread_created'.
  String get type => 'session.thread_created';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionThreadCreatedEventData].
  const WebhookSessionThreadCreatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionThreadCreatedEventData] from JSON.
  factory WebhookSessionThreadCreatedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionThreadCreatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionThreadCreatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionThreadCreatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionThreadCreatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionThreadCreatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session thread went idle.
@immutable
class WebhookSessionThreadIdledEventData extends WebhookEventData {
  /// The event-data type, always 'session.thread_idled'.
  String get type => 'session.thread_idled';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionThreadIdledEventData].
  const WebhookSessionThreadIdledEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionThreadIdledEventData] from JSON.
  factory WebhookSessionThreadIdledEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionThreadIdledEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionThreadIdledEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionThreadIdledEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionThreadIdledEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionThreadIdledEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a session thread was terminated.
@immutable
class WebhookSessionThreadTerminatedEventData extends WebhookEventData {
  /// The event-data type, always 'session.thread_terminated'.
  String get type => 'session.thread_terminated';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookSessionThreadTerminatedEventData].
  const WebhookSessionThreadTerminatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookSessionThreadTerminatedEventData] from JSON.
  factory WebhookSessionThreadTerminatedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookSessionThreadTerminatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookSessionThreadTerminatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookSessionThreadTerminatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSessionThreadTerminatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookSessionThreadTerminatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a vault was created.
@immutable
class WebhookVaultCreatedEventData extends WebhookEventData {
  /// The event-data type, always 'vault.created'.
  String get type => 'vault.created';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookVaultCreatedEventData].
  const WebhookVaultCreatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookVaultCreatedEventData] from JSON.
  factory WebhookVaultCreatedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookVaultCreatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultCreatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookVaultCreatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultCreatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookVaultCreatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a vault was archived.
@immutable
class WebhookVaultArchivedEventData extends WebhookEventData {
  /// The event-data type, always 'vault.archived'.
  String get type => 'vault.archived';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookVaultArchivedEventData].
  const WebhookVaultArchivedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookVaultArchivedEventData] from JSON.
  factory WebhookVaultArchivedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookVaultArchivedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultArchivedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookVaultArchivedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultArchivedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookVaultArchivedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a vault was deleted.
@immutable
class WebhookVaultDeletedEventData extends WebhookEventData {
  /// The event-data type, always 'vault.deleted'.
  String get type => 'vault.deleted';

  /// ID of the resource this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// Creates a [WebhookVaultDeletedEventData].
  const WebhookVaultDeletedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
  });

  /// Creates a [WebhookVaultDeletedEventData] from JSON.
  factory WebhookVaultDeletedEventData.fromJson(Map<String, dynamic> json) {
    return WebhookVaultDeletedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultDeletedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
  }) {
    return WebhookVaultDeletedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultDeletedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId);

  @override
  String toString() =>
      'WebhookVaultDeletedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId)';
}

/// Webhook event data signalling a vault credential was created.
@immutable
class WebhookVaultCredentialCreatedEventData extends WebhookEventData {
  /// The event-data type, always 'vault_credential.created'.
  String get type => 'vault_credential.created';

  /// ID of the credential this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// ID of the vault the credential belongs to.
  final String vaultId;

  /// Creates a [WebhookVaultCredentialCreatedEventData].
  const WebhookVaultCredentialCreatedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
    required this.vaultId,
  });

  /// Creates a [WebhookVaultCredentialCreatedEventData] from JSON.
  factory WebhookVaultCredentialCreatedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookVaultCredentialCreatedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
      vaultId: json['vault_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
    'vault_id': vaultId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultCredentialCreatedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
    String? vaultId,
  }) {
    return WebhookVaultCredentialCreatedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
      vaultId: vaultId ?? this.vaultId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultCredentialCreatedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId &&
          vaultId == other.vaultId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId, vaultId);

  @override
  String toString() =>
      'WebhookVaultCredentialCreatedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId, vaultId: $vaultId)';
}

/// Webhook event data signalling a vault credential was archived.
@immutable
class WebhookVaultCredentialArchivedEventData extends WebhookEventData {
  /// The event-data type, always 'vault_credential.archived'.
  String get type => 'vault_credential.archived';

  /// ID of the credential this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// ID of the vault the credential belongs to.
  final String vaultId;

  /// Creates a [WebhookVaultCredentialArchivedEventData].
  const WebhookVaultCredentialArchivedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
    required this.vaultId,
  });

  /// Creates a [WebhookVaultCredentialArchivedEventData] from JSON.
  factory WebhookVaultCredentialArchivedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookVaultCredentialArchivedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
      vaultId: json['vault_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
    'vault_id': vaultId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultCredentialArchivedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
    String? vaultId,
  }) {
    return WebhookVaultCredentialArchivedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
      vaultId: vaultId ?? this.vaultId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultCredentialArchivedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId &&
          vaultId == other.vaultId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId, vaultId);

  @override
  String toString() =>
      'WebhookVaultCredentialArchivedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId, vaultId: $vaultId)';
}

/// Webhook event data signalling a vault credential was deleted.
@immutable
class WebhookVaultCredentialDeletedEventData extends WebhookEventData {
  /// The event-data type, always 'vault_credential.deleted'.
  String get type => 'vault_credential.deleted';

  /// ID of the credential this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// ID of the vault the credential belongs to.
  final String vaultId;

  /// Creates a [WebhookVaultCredentialDeletedEventData].
  const WebhookVaultCredentialDeletedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
    required this.vaultId,
  });

  /// Creates a [WebhookVaultCredentialDeletedEventData] from JSON.
  factory WebhookVaultCredentialDeletedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookVaultCredentialDeletedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
      vaultId: json['vault_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
    'vault_id': vaultId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultCredentialDeletedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
    String? vaultId,
  }) {
    return WebhookVaultCredentialDeletedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
      vaultId: vaultId ?? this.vaultId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultCredentialDeletedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId &&
          vaultId == other.vaultId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId, vaultId);

  @override
  String toString() =>
      'WebhookVaultCredentialDeletedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId, vaultId: $vaultId)';
}

/// Webhook event data signalling a vault credential refresh failed.
@immutable
class WebhookVaultCredentialRefreshFailedEventData extends WebhookEventData {
  /// The event-data type, always 'vault_credential.refresh_failed'.
  String get type => 'vault_credential.refresh_failed';

  /// ID of the credential this event concerns.
  final String id;

  /// ID of the organization that owns the resource.
  final String organizationId;

  /// ID of the workspace that owns the resource.
  final String workspaceId;

  /// ID of the vault the credential belongs to.
  final String vaultId;

  /// Creates a [WebhookVaultCredentialRefreshFailedEventData].
  const WebhookVaultCredentialRefreshFailedEventData({
    required this.id,
    required this.organizationId,
    required this.workspaceId,
    required this.vaultId,
  });

  /// Creates a [WebhookVaultCredentialRefreshFailedEventData] from JSON.
  factory WebhookVaultCredentialRefreshFailedEventData.fromJson(
    Map<String, dynamic> json,
  ) {
    return WebhookVaultCredentialRefreshFailedEventData(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      workspaceId: json['workspace_id'] as String,
      vaultId: json['vault_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'organization_id': organizationId,
    'workspace_id': workspaceId,
    'vault_id': vaultId,
  };

  /// Creates a copy with replaced values.
  WebhookVaultCredentialRefreshFailedEventData copyWith({
    String? id,
    String? organizationId,
    String? workspaceId,
    String? vaultId,
  }) {
    return WebhookVaultCredentialRefreshFailedEventData(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      workspaceId: workspaceId ?? this.workspaceId,
      vaultId: vaultId ?? this.vaultId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookVaultCredentialRefreshFailedEventData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          organizationId == other.organizationId &&
          workspaceId == other.workspaceId &&
          vaultId == other.vaultId;

  @override
  int get hashCode => Object.hash(id, organizationId, workspaceId, vaultId);

  @override
  String toString() =>
      'WebhookVaultCredentialRefreshFailedEventData(id: $id, organizationId: $organizationId, '
      'workspaceId: $workspaceId, vaultId: $vaultId)';
}

/// Unrecognized webhook event-data type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownWebhookEventData extends WebhookEventData {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownWebhookEventData].
  const UnknownWebhookEventData({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownWebhookEventData &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownWebhookEventData(rawJson: $rawJson)';
}
