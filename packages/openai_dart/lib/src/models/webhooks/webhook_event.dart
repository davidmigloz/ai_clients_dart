import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

part 'webhook_payloads.dart';
part 'webhook_json_helpers.dart';

/// Received notification, parsed independently of signature verification.
///
/// Subtypes:
/// - [AgentSessionActionRequiredWebhookEvent]
/// - [AgentSessionCreatedWebhookEvent]
/// - [AgentSessionFailedWebhookEvent]
/// - [AgentSessionIdleWebhookEvent]
/// - [AgentSessionInProgressWebhookEvent]
/// - [BatchCancelledWebhookEvent]
/// - [BatchCompletedWebhookEvent]
/// - [BatchExpiredWebhookEvent]
/// - [BatchFailedWebhookEvent]
/// - [EvalRunCanceledWebhookEvent]
/// - [EvalRunFailedWebhookEvent]
/// - [EvalRunSucceededWebhookEvent]
/// - [FineTuningJobCancelledWebhookEvent]
/// - [FineTuningJobFailedWebhookEvent]
/// - [FineTuningJobSucceededWebhookEvent]
/// - [LiveCallIncomingWebhookEvent]
/// - [LiveTransportIncomingWebhookEvent]
/// - [RealtimeCallIncomingWebhookEvent]
/// - [ResponseCancelledWebhookEvent]
/// - [ResponseCompletedWebhookEvent]
/// - [ResponseFailedWebhookEvent]
/// - [ResponseIncompleteWebhookEvent]
/// - [SafetyAlertCreatedWebhookEvent]
/// - [SafetyDeactivationIssuedWebhookEvent]
/// - [SafetyOrgAlertCreatedWebhookEvent]
/// - [SafetyWarningIssuedWebhookEvent]
/// - [UnknownWebhookEvent]
///
/// Known envelopes validate all declared fields. Future metadata is a receive-only
/// extension and does not establish canonical admission to closed objects.
@immutable
sealed class WebhookEvent with _WebhookValue {
  /// Creates a notification base.
  WebhookEvent();

  /// Delivery event ID, distinct from the affected resource ID in data.
  String? get id;

  /// Event creation timestamp; signature header policy does not constrain it.
  int? get createdAt;

  /// Received event discriminator.
  String get type;

  /// Optional envelope object; known Agent and safety envelopes require event.
  String? get object;

  /// Typed known payload or arbitrary raw future payload.
  Object? get data;

  /// Parses finite received JSON. This method never authenticates a signature.
  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'WebhookEvent');
    final type = requireJsonString(snapshot['type'], 'WebhookEvent.type');
    return switch (type) {
      'agent.session.action_required' =>
        AgentSessionActionRequiredWebhookEvent.fromJson(snapshot),
      'agent.session.created' => AgentSessionCreatedWebhookEvent.fromJson(
        snapshot,
      ),
      'agent.session.failed' => AgentSessionFailedWebhookEvent.fromJson(
        snapshot,
      ),
      'agent.session.idle' => AgentSessionIdleWebhookEvent.fromJson(snapshot),
      'agent.session.in_progress' =>
        AgentSessionInProgressWebhookEvent.fromJson(snapshot),
      'batch.cancelled' => BatchCancelledWebhookEvent.fromJson(snapshot),
      'batch.completed' => BatchCompletedWebhookEvent.fromJson(snapshot),
      'batch.expired' => BatchExpiredWebhookEvent.fromJson(snapshot),
      'batch.failed' => BatchFailedWebhookEvent.fromJson(snapshot),
      'eval.run.canceled' => EvalRunCanceledWebhookEvent.fromJson(snapshot),
      'eval.run.failed' => EvalRunFailedWebhookEvent.fromJson(snapshot),
      'eval.run.succeeded' => EvalRunSucceededWebhookEvent.fromJson(snapshot),
      'fine_tuning.job.cancelled' =>
        FineTuningJobCancelledWebhookEvent.fromJson(snapshot),
      'fine_tuning.job.failed' => FineTuningJobFailedWebhookEvent.fromJson(
        snapshot,
      ),
      'fine_tuning.job.succeeded' =>
        FineTuningJobSucceededWebhookEvent.fromJson(snapshot),
      'live.call.incoming' => LiveCallIncomingWebhookEvent.fromJson(snapshot),
      'live.transport.incoming' => LiveTransportIncomingWebhookEvent.fromJson(
        snapshot,
      ),
      'realtime.call.incoming' => RealtimeCallIncomingWebhookEvent.fromJson(
        snapshot,
      ),
      'response.cancelled' => ResponseCancelledWebhookEvent.fromJson(snapshot),
      'response.completed' => ResponseCompletedWebhookEvent.fromJson(snapshot),
      'response.failed' => ResponseFailedWebhookEvent.fromJson(snapshot),
      'response.incomplete' => ResponseIncompleteWebhookEvent.fromJson(
        snapshot,
      ),
      'safety.alert.created' => SafetyAlertCreatedWebhookEvent.fromJson(
        snapshot,
      ),
      'safety.deactivation_issued' =>
        SafetyDeactivationIssuedWebhookEvent.fromJson(snapshot),
      'safety.org_alert.created' => SafetyOrgAlertCreatedWebhookEvent.fromJson(
        snapshot,
      ),
      'safety.warning_issued' => SafetyWarningIssuedWebhookEvent.fromJson(
        snapshot,
      ),
      _ => UnknownWebhookEvent(rawJson: snapshot),
    };
  }
}

/// Required envelope shared by canonical Agent session notifications.
///
/// Its subtypes are [AgentSessionActionRequiredWebhookEvent],
/// [AgentSessionCreatedWebhookEvent], [AgentSessionFailedWebhookEvent],
/// [AgentSessionIdleWebhookEvent] and [AgentSessionInProgressWebhookEvent].
@immutable
sealed class WebhookAgentSessionEnvelope extends WebhookEvent {
  /// Creates a canonical Agent session envelope.
  WebhookAgentSessionEnvelope();

  @override
  String get id;
  @override
  int get createdAt;
  @override
  String get object => 'event';
}

/// Received notification for `agent.session.action_required`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionActionRequiredWebhookEvent
    extends WebhookAgentSessionEnvelope {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final AgentSessionActionRequiredPayloadResource data;
  @override
  String get type => 'agent.session.action_required';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionActionRequiredWebhookEvent.
  AgentSessionActionRequiredWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionActionRequiredWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(
      _valueJson(),
      'AgentSessionActionRequiredWebhookEvent',
    );
  }

  /// Parses a received AgentSessionActionRequiredWebhookEvent, without authenticating a signature.
  factory AgentSessionActionRequiredWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionActionRequiredWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'agent.session.action_required',
      'AgentSessionActionRequiredWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'AgentSessionActionRequiredWebhookEvent',
      required: true,
    );
    return AgentSessionActionRequiredWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionActionRequiredWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'AgentSessionActionRequiredWebhookEvent.created_at',
      ),
      data: AgentSessionActionRequiredPayloadResource.fromJson(
        requireJsonObject(
          snapshot['data'],
          'AgentSessionActionRequiredWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionActionRequiredWebhookEvent copyWith({
    String? id,
    int? createdAt,
    AgentSessionActionRequiredPayloadResource? data,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionActionRequiredWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionActionRequiredWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `agent.session.created`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionCreatedWebhookEvent extends WebhookAgentSessionEnvelope {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final AgentSessionCreatedPayloadResource data;
  @override
  String get type => 'agent.session.created';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionCreatedWebhookEvent.
  AgentSessionCreatedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionCreatedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionCreatedWebhookEvent');
  }

  /// Parses a received AgentSessionCreatedWebhookEvent, without authenticating a signature.
  factory AgentSessionCreatedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionCreatedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'agent.session.created',
      'AgentSessionCreatedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'AgentSessionCreatedWebhookEvent',
      required: true,
    );
    return AgentSessionCreatedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionCreatedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'AgentSessionCreatedWebhookEvent.created_at',
      ),
      data: AgentSessionCreatedPayloadResource.fromJson(
        requireJsonObject(
          snapshot['data'],
          'AgentSessionCreatedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionCreatedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    AgentSessionCreatedPayloadResource? data,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCreatedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionCreatedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `agent.session.failed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionFailedWebhookEvent extends WebhookAgentSessionEnvelope {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final AgentSessionEnvironmentPayloadResource data;
  @override
  String get type => 'agent.session.failed';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionFailedWebhookEvent.
  AgentSessionFailedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionFailedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionFailedWebhookEvent');
  }

  /// Parses a received AgentSessionFailedWebhookEvent, without authenticating a signature.
  factory AgentSessionFailedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionFailedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'agent.session.failed',
      'AgentSessionFailedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'AgentSessionFailedWebhookEvent',
      required: true,
    );
    return AgentSessionFailedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionFailedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'AgentSessionFailedWebhookEvent.created_at',
      ),
      data: AgentSessionEnvironmentPayloadResource.fromJson(
        requireJsonObject(
          snapshot['data'],
          'AgentSessionFailedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionFailedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    AgentSessionEnvironmentPayloadResource? data,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionFailedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionFailedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `agent.session.idle`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionIdleWebhookEvent extends WebhookAgentSessionEnvelope {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final AgentSessionEnvironmentPayloadResource data;
  @override
  String get type => 'agent.session.idle';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionIdleWebhookEvent.
  AgentSessionIdleWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionIdleWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionIdleWebhookEvent');
  }

  /// Parses a received AgentSessionIdleWebhookEvent, without authenticating a signature.
  factory AgentSessionIdleWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'AgentSessionIdleWebhookEvent');
    requireJsonType(
      snapshot,
      'agent.session.idle',
      'AgentSessionIdleWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'AgentSessionIdleWebhookEvent',
      required: true,
    );
    return AgentSessionIdleWebhookEvent(
      id: requireJsonString(snapshot['id'], 'AgentSessionIdleWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'AgentSessionIdleWebhookEvent.created_at',
      ),
      data: AgentSessionEnvironmentPayloadResource.fromJson(
        requireJsonObject(
          snapshot['data'],
          'AgentSessionIdleWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionIdleWebhookEvent copyWith({
    String? id,
    int? createdAt,
    AgentSessionEnvironmentPayloadResource? data,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionIdleWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionIdleWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `agent.session.in_progress`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionInProgressWebhookEvent extends WebhookAgentSessionEnvelope {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final AgentSessionEnvironmentPayloadResource data;
  @override
  String get type => 'agent.session.in_progress';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionInProgressWebhookEvent.
  AgentSessionInProgressWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionInProgressWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionInProgressWebhookEvent');
  }

  /// Parses a received AgentSessionInProgressWebhookEvent, without authenticating a signature.
  factory AgentSessionInProgressWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionInProgressWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'agent.session.in_progress',
      'AgentSessionInProgressWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'AgentSessionInProgressWebhookEvent',
      required: true,
    );
    return AgentSessionInProgressWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionInProgressWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'AgentSessionInProgressWebhookEvent.created_at',
      ),
      data: AgentSessionEnvironmentPayloadResource.fromJson(
        requireJsonObject(
          snapshot['data'],
          'AgentSessionInProgressWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionInProgressWebhookEvent copyWith({
    String? id,
    int? createdAt,
    AgentSessionEnvironmentPayloadResource? data,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionInProgressWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionInProgressWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `batch.cancelled`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class BatchCancelledWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'batch.cancelled';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates BatchCancelledWebhookEvent.
  BatchCancelledWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'BatchCancelledWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'BatchCancelledWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'BatchCancelledWebhookEvent');
  }

  /// Parses a received BatchCancelledWebhookEvent, without authenticating a signature.
  factory BatchCancelledWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'BatchCancelledWebhookEvent');
    requireJsonType(snapshot, 'batch.cancelled', 'BatchCancelledWebhookEvent');
    _requireEventObject(
      snapshot,
      'BatchCancelledWebhookEvent',
      required: false,
    );
    return BatchCancelledWebhookEvent(
      id: requireJsonString(snapshot['id'], 'BatchCancelledWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'BatchCancelledWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'BatchCancelledWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  BatchCancelledWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => BatchCancelledWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'BatchCancelledWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `batch.completed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class BatchCompletedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'batch.completed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates BatchCompletedWebhookEvent.
  BatchCompletedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'BatchCompletedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'BatchCompletedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'BatchCompletedWebhookEvent');
  }

  /// Parses a received BatchCompletedWebhookEvent, without authenticating a signature.
  factory BatchCompletedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'BatchCompletedWebhookEvent');
    requireJsonType(snapshot, 'batch.completed', 'BatchCompletedWebhookEvent');
    _requireEventObject(
      snapshot,
      'BatchCompletedWebhookEvent',
      required: false,
    );
    return BatchCompletedWebhookEvent(
      id: requireJsonString(snapshot['id'], 'BatchCompletedWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'BatchCompletedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'BatchCompletedWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  BatchCompletedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => BatchCompletedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'BatchCompletedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `batch.expired`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class BatchExpiredWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'batch.expired';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates BatchExpiredWebhookEvent.
  BatchExpiredWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'BatchExpiredWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'BatchExpiredWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'BatchExpiredWebhookEvent');
  }

  /// Parses a received BatchExpiredWebhookEvent, without authenticating a signature.
  factory BatchExpiredWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'BatchExpiredWebhookEvent');
    requireJsonType(snapshot, 'batch.expired', 'BatchExpiredWebhookEvent');
    _requireEventObject(snapshot, 'BatchExpiredWebhookEvent', required: false);
    return BatchExpiredWebhookEvent(
      id: requireJsonString(snapshot['id'], 'BatchExpiredWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'BatchExpiredWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'BatchExpiredWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  BatchExpiredWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => BatchExpiredWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'BatchExpiredWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `batch.failed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class BatchFailedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'batch.failed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates BatchFailedWebhookEvent.
  BatchFailedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'BatchFailedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'BatchFailedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'BatchFailedWebhookEvent');
  }

  /// Parses a received BatchFailedWebhookEvent, without authenticating a signature.
  factory BatchFailedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'BatchFailedWebhookEvent');
    requireJsonType(snapshot, 'batch.failed', 'BatchFailedWebhookEvent');
    _requireEventObject(snapshot, 'BatchFailedWebhookEvent', required: false);
    return BatchFailedWebhookEvent(
      id: requireJsonString(snapshot['id'], 'BatchFailedWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'BatchFailedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'BatchFailedWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  BatchFailedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => BatchFailedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'BatchFailedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `eval.run.canceled`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class EvalRunCanceledWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'eval.run.canceled';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates EvalRunCanceledWebhookEvent.
  EvalRunCanceledWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'EvalRunCanceledWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'EvalRunCanceledWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'EvalRunCanceledWebhookEvent');
  }

  /// Parses a received EvalRunCanceledWebhookEvent, without authenticating a signature.
  factory EvalRunCanceledWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'EvalRunCanceledWebhookEvent');
    requireJsonType(
      snapshot,
      'eval.run.canceled',
      'EvalRunCanceledWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'EvalRunCanceledWebhookEvent',
      required: false,
    );
    return EvalRunCanceledWebhookEvent(
      id: requireJsonString(snapshot['id'], 'EvalRunCanceledWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'EvalRunCanceledWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'EvalRunCanceledWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  EvalRunCanceledWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => EvalRunCanceledWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'EvalRunCanceledWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `eval.run.failed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class EvalRunFailedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'eval.run.failed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates EvalRunFailedWebhookEvent.
  EvalRunFailedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'EvalRunFailedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'EvalRunFailedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'EvalRunFailedWebhookEvent');
  }

  /// Parses a received EvalRunFailedWebhookEvent, without authenticating a signature.
  factory EvalRunFailedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'EvalRunFailedWebhookEvent');
    requireJsonType(snapshot, 'eval.run.failed', 'EvalRunFailedWebhookEvent');
    _requireEventObject(snapshot, 'EvalRunFailedWebhookEvent', required: false);
    return EvalRunFailedWebhookEvent(
      id: requireJsonString(snapshot['id'], 'EvalRunFailedWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'EvalRunFailedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'EvalRunFailedWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  EvalRunFailedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => EvalRunFailedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'EvalRunFailedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `eval.run.succeeded`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class EvalRunSucceededWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'eval.run.succeeded';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates EvalRunSucceededWebhookEvent.
  EvalRunSucceededWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'EvalRunSucceededWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'EvalRunSucceededWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'EvalRunSucceededWebhookEvent');
  }

  /// Parses a received EvalRunSucceededWebhookEvent, without authenticating a signature.
  factory EvalRunSucceededWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'EvalRunSucceededWebhookEvent');
    requireJsonType(
      snapshot,
      'eval.run.succeeded',
      'EvalRunSucceededWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'EvalRunSucceededWebhookEvent',
      required: false,
    );
    return EvalRunSucceededWebhookEvent(
      id: requireJsonString(snapshot['id'], 'EvalRunSucceededWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'EvalRunSucceededWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'EvalRunSucceededWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  EvalRunSucceededWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => EvalRunSucceededWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'EvalRunSucceededWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `fine_tuning.job.cancelled`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class FineTuningJobCancelledWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'fine_tuning.job.cancelled';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates FineTuningJobCancelledWebhookEvent.
  FineTuningJobCancelledWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'FineTuningJobCancelledWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'FineTuningJobCancelledWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'FineTuningJobCancelledWebhookEvent');
  }

  /// Parses a received FineTuningJobCancelledWebhookEvent, without authenticating a signature.
  factory FineTuningJobCancelledWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'FineTuningJobCancelledWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'fine_tuning.job.cancelled',
      'FineTuningJobCancelledWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'FineTuningJobCancelledWebhookEvent',
      required: false,
    );
    return FineTuningJobCancelledWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'FineTuningJobCancelledWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'FineTuningJobCancelledWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'FineTuningJobCancelledWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  FineTuningJobCancelledWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => FineTuningJobCancelledWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'FineTuningJobCancelledWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `fine_tuning.job.failed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class FineTuningJobFailedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'fine_tuning.job.failed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates FineTuningJobFailedWebhookEvent.
  FineTuningJobFailedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'FineTuningJobFailedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'FineTuningJobFailedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'FineTuningJobFailedWebhookEvent');
  }

  /// Parses a received FineTuningJobFailedWebhookEvent, without authenticating a signature.
  factory FineTuningJobFailedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'FineTuningJobFailedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'fine_tuning.job.failed',
      'FineTuningJobFailedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'FineTuningJobFailedWebhookEvent',
      required: false,
    );
    return FineTuningJobFailedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'FineTuningJobFailedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'FineTuningJobFailedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'FineTuningJobFailedWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  FineTuningJobFailedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => FineTuningJobFailedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'FineTuningJobFailedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `fine_tuning.job.succeeded`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class FineTuningJobSucceededWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'fine_tuning.job.succeeded';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates FineTuningJobSucceededWebhookEvent.
  FineTuningJobSucceededWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'FineTuningJobSucceededWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'FineTuningJobSucceededWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'FineTuningJobSucceededWebhookEvent');
  }

  /// Parses a received FineTuningJobSucceededWebhookEvent, without authenticating a signature.
  factory FineTuningJobSucceededWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'FineTuningJobSucceededWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'fine_tuning.job.succeeded',
      'FineTuningJobSucceededWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'FineTuningJobSucceededWebhookEvent',
      required: false,
    );
    return FineTuningJobSucceededWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'FineTuningJobSucceededWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'FineTuningJobSucceededWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'FineTuningJobSucceededWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  FineTuningJobSucceededWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => FineTuningJobSucceededWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'FineTuningJobSucceededWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `live.call.incoming`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@Deprecated(
  'Use LiveTransportIncomingWebhookEvent for current Live notifications.',
)
@immutable
class LiveCallIncomingWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final LiveCallIncomingWebhookData data;
  @override
  String get type => 'live.call.incoming';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates LiveCallIncomingWebhookEvent.
  @Deprecated(
    'Use LiveTransportIncomingWebhookEvent for current Live notifications.',
  )
  LiveCallIncomingWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'LiveCallIncomingWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'LiveCallIncomingWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'LiveCallIncomingWebhookEvent');
  }

  /// Parses a received LiveCallIncomingWebhookEvent, without authenticating a signature.
  @Deprecated(
    'Use LiveTransportIncomingWebhookEvent for current Live notifications.',
  )
  factory LiveCallIncomingWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'LiveCallIncomingWebhookEvent');
    requireJsonType(
      snapshot,
      'live.call.incoming',
      'LiveCallIncomingWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'LiveCallIncomingWebhookEvent',
      required: false,
    );
    return LiveCallIncomingWebhookEvent(
      id: requireJsonString(snapshot['id'], 'LiveCallIncomingWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'LiveCallIncomingWebhookEvent.created_at',
      ),
      data: LiveCallIncomingWebhookData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'LiveCallIncomingWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  LiveCallIncomingWebhookEvent copyWith({
    String? id,
    int? createdAt,
    LiveCallIncomingWebhookData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => LiveCallIncomingWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'LiveCallIncomingWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `live.transport.incoming`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class LiveTransportIncomingWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final LiveTransportIncomingWebhookData data;
  @override
  String get type => 'live.transport.incoming';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates LiveTransportIncomingWebhookEvent.
  LiveTransportIncomingWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'LiveTransportIncomingWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'LiveTransportIncomingWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'LiveTransportIncomingWebhookEvent');
  }

  /// Parses a received LiveTransportIncomingWebhookEvent, without authenticating a signature.
  factory LiveTransportIncomingWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'LiveTransportIncomingWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'live.transport.incoming',
      'LiveTransportIncomingWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'LiveTransportIncomingWebhookEvent',
      required: false,
    );
    return LiveTransportIncomingWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'LiveTransportIncomingWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'LiveTransportIncomingWebhookEvent.created_at',
      ),
      data: LiveTransportIncomingWebhookData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'LiveTransportIncomingWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  LiveTransportIncomingWebhookEvent copyWith({
    String? id,
    int? createdAt,
    LiveTransportIncomingWebhookData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => LiveTransportIncomingWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'LiveTransportIncomingWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `realtime.call.incoming`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class RealtimeCallIncomingWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final RealtimeCallIncomingWebhookData data;
  @override
  String get type => 'realtime.call.incoming';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates RealtimeCallIncomingWebhookEvent.
  RealtimeCallIncomingWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'RealtimeCallIncomingWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'RealtimeCallIncomingWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'RealtimeCallIncomingWebhookEvent');
  }

  /// Parses a received RealtimeCallIncomingWebhookEvent, without authenticating a signature.
  factory RealtimeCallIncomingWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'RealtimeCallIncomingWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'realtime.call.incoming',
      'RealtimeCallIncomingWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'RealtimeCallIncomingWebhookEvent',
      required: false,
    );
    return RealtimeCallIncomingWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'RealtimeCallIncomingWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'RealtimeCallIncomingWebhookEvent.created_at',
      ),
      data: RealtimeCallIncomingWebhookData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'RealtimeCallIncomingWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  RealtimeCallIncomingWebhookEvent copyWith({
    String? id,
    int? createdAt,
    RealtimeCallIncomingWebhookData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => RealtimeCallIncomingWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'RealtimeCallIncomingWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `response.cancelled`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class ResponseCancelledWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'response.cancelled';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates ResponseCancelledWebhookEvent.
  ResponseCancelledWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'ResponseCancelledWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'ResponseCancelledWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'ResponseCancelledWebhookEvent');
  }

  /// Parses a received ResponseCancelledWebhookEvent, without authenticating a signature.
  factory ResponseCancelledWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'ResponseCancelledWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'response.cancelled',
      'ResponseCancelledWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'ResponseCancelledWebhookEvent',
      required: false,
    );
    return ResponseCancelledWebhookEvent(
      id: requireJsonString(snapshot['id'], 'ResponseCancelledWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'ResponseCancelledWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'ResponseCancelledWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  ResponseCancelledWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseCancelledWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'ResponseCancelledWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `response.completed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class ResponseCompletedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'response.completed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates ResponseCompletedWebhookEvent.
  ResponseCompletedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'ResponseCompletedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'ResponseCompletedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'ResponseCompletedWebhookEvent');
  }

  /// Parses a received ResponseCompletedWebhookEvent, without authenticating a signature.
  factory ResponseCompletedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'ResponseCompletedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'response.completed',
      'ResponseCompletedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'ResponseCompletedWebhookEvent',
      required: false,
    );
    return ResponseCompletedWebhookEvent(
      id: requireJsonString(snapshot['id'], 'ResponseCompletedWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'ResponseCompletedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'ResponseCompletedWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  ResponseCompletedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseCompletedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'ResponseCompletedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `response.failed`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class ResponseFailedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'response.failed';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates ResponseFailedWebhookEvent.
  ResponseFailedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'ResponseFailedWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'ResponseFailedWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'ResponseFailedWebhookEvent');
  }

  /// Parses a received ResponseFailedWebhookEvent, without authenticating a signature.
  factory ResponseFailedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'ResponseFailedWebhookEvent');
    requireJsonType(snapshot, 'response.failed', 'ResponseFailedWebhookEvent');
    _requireEventObject(
      snapshot,
      'ResponseFailedWebhookEvent',
      required: false,
    );
    return ResponseFailedWebhookEvent(
      id: requireJsonString(snapshot['id'], 'ResponseFailedWebhookEvent.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'ResponseFailedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(snapshot['data'], 'ResponseFailedWebhookEvent.data'),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  ResponseFailedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseFailedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'ResponseFailedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `response.incomplete`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class ResponseIncompleteWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'response.incomplete';

  /// Fixed `event` when present, otherwise absent from the wire.
  @override
  final String? object;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates ResponseIncompleteWebhookEvent.
  ResponseIncompleteWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    this.object,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'ResponseIncompleteWebhookEvent.rawJson',
       ) {
    if (object != null && object != 'event') {
      throw const FormatException(
        'ResponseIncompleteWebhookEvent.object: expected event',
      );
    }
    _snapshotWebhookJson(_valueJson(), 'ResponseIncompleteWebhookEvent');
  }

  /// Parses a received ResponseIncompleteWebhookEvent, without authenticating a signature.
  factory ResponseIncompleteWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'ResponseIncompleteWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'response.incomplete',
      'ResponseIncompleteWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'ResponseIncompleteWebhookEvent',
      required: false,
    );
    return ResponseIncompleteWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'ResponseIncompleteWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'ResponseIncompleteWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'ResponseIncompleteWebhookEvent.data',
        ),
      ),
      object: snapshot.containsKey('object') ? 'event' : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      if (object != null) 'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  ResponseIncompleteWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Object? object = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ResponseIncompleteWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    object: identical(object, unsetCopyWithValue)
        ? this.object
        : object as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'ResponseIncompleteWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `safety.alert.created`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class SafetyAlertCreatedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookSafetyAlertData data;
  @override
  String get type => 'safety.alert.created';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates SafetyAlertCreatedWebhookEvent.
  SafetyAlertCreatedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'SafetyAlertCreatedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'SafetyAlertCreatedWebhookEvent');
  }

  /// Parses a received SafetyAlertCreatedWebhookEvent, without authenticating a signature.
  factory SafetyAlertCreatedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'SafetyAlertCreatedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'safety.alert.created',
      'SafetyAlertCreatedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'SafetyAlertCreatedWebhookEvent',
      required: true,
    );
    return SafetyAlertCreatedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'SafetyAlertCreatedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyAlertCreatedWebhookEvent.created_at',
      ),
      data: WebhookSafetyAlertData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'SafetyAlertCreatedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  SafetyAlertCreatedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookSafetyAlertData? data,
    Map<String, dynamic>? rawJson,
  }) => SafetyAlertCreatedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'SafetyAlertCreatedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `safety.deactivation_issued`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class SafetyDeactivationIssuedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'safety.deactivation_issued';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates SafetyDeactivationIssuedWebhookEvent.
  SafetyDeactivationIssuedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'SafetyDeactivationIssuedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'SafetyDeactivationIssuedWebhookEvent');
  }

  /// Parses a received SafetyDeactivationIssuedWebhookEvent, without authenticating a signature.
  factory SafetyDeactivationIssuedWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'SafetyDeactivationIssuedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'safety.deactivation_issued',
      'SafetyDeactivationIssuedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'SafetyDeactivationIssuedWebhookEvent',
      required: true,
    );
    return SafetyDeactivationIssuedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'SafetyDeactivationIssuedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyDeactivationIssuedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'SafetyDeactivationIssuedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  SafetyDeactivationIssuedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Map<String, dynamic>? rawJson,
  }) => SafetyDeactivationIssuedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'SafetyDeactivationIssuedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `safety.org_alert.created`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class SafetyOrgAlertCreatedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookSafetyAlertData data;
  @override
  String get type => 'safety.org_alert.created';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates SafetyOrgAlertCreatedWebhookEvent.
  SafetyOrgAlertCreatedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'SafetyOrgAlertCreatedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'SafetyOrgAlertCreatedWebhookEvent');
  }

  /// Parses a received SafetyOrgAlertCreatedWebhookEvent, without authenticating a signature.
  factory SafetyOrgAlertCreatedWebhookEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'SafetyOrgAlertCreatedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'safety.org_alert.created',
      'SafetyOrgAlertCreatedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'SafetyOrgAlertCreatedWebhookEvent',
      required: true,
    );
    return SafetyOrgAlertCreatedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'SafetyOrgAlertCreatedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyOrgAlertCreatedWebhookEvent.created_at',
      ),
      data: WebhookSafetyAlertData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'SafetyOrgAlertCreatedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  SafetyOrgAlertCreatedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookSafetyAlertData? data,
    Map<String, dynamic>? rawJson,
  }) => SafetyOrgAlertCreatedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'SafetyOrgAlertCreatedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}

/// Received notification for `safety.warning_issued`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class SafetyWarningIssuedWebhookEvent extends WebhookEvent {
  /// id received from the provider.
  @override
  final String id;

  /// created_at received from the provider.
  @override
  final int createdAt;

  /// data received from the provider.
  @override
  final WebhookIdData data;
  @override
  String get type => 'safety.warning_issued';
  @override
  String get object => 'event';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates SafetyWarningIssuedWebhookEvent.
  SafetyWarningIssuedWebhookEvent({
    required this.id,
    required this.createdAt,
    required this.data,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'SafetyWarningIssuedWebhookEvent.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'SafetyWarningIssuedWebhookEvent');
  }

  /// Parses a received SafetyWarningIssuedWebhookEvent, without authenticating a signature.
  factory SafetyWarningIssuedWebhookEvent.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'SafetyWarningIssuedWebhookEvent',
    );
    requireJsonType(
      snapshot,
      'safety.warning_issued',
      'SafetyWarningIssuedWebhookEvent',
    );
    _requireEventObject(
      snapshot,
      'SafetyWarningIssuedWebhookEvent',
      required: true,
    );
    return SafetyWarningIssuedWebhookEvent(
      id: requireJsonString(
        snapshot['id'],
        'SafetyWarningIssuedWebhookEvent.id',
      ),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'SafetyWarningIssuedWebhookEvent.created_at',
      ),
      data: WebhookIdData.fromJson(
        requireJsonObject(
          snapshot['data'],
          'SafetyWarningIssuedWebhookEvent.data',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'created_at', 'data', 'type', 'object'},
    {
      'id': id,
      'created_at': createdAt,
      'data': data.toJson(),
      'type': type,
      'object': object,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  SafetyWarningIssuedWebhookEvent copyWith({
    String? id,
    int? createdAt,
    WebhookIdData? data,
    Map<String, dynamic>? rawJson,
  }) => SafetyWarningIssuedWebhookEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'SafetyWarningIssuedWebhookEvent(id: [REDACTED], createdAt: [REDACTED], data: [REDACTED], object: $object, rawJson: ${rawJson.length} entries)';
}
// Unknown fallback

/// A future discriminator with arbitrary finite, deeply immutable received JSON.
///
/// Missing or differently shaped future envelope members are not normalized.
/// The optional projections expose only values of their named Dart types.
@immutable
class UnknownWebhookEvent extends WebhookEvent {
  @override
  final Map<String, dynamic> rawJson;

  /// Takes an owned finite snapshot. Only the discriminator must be a string.
  UnknownWebhookEvent({required Map<String, dynamic> rawJson})
    : rawJson = _snapshotWebhookJson(rawJson, 'UnknownWebhookEvent') {
    requireJsonString(this.rawJson['type'], 'UnknownWebhookEvent.type');
  }

  /// Parses a raw future notification without authenticating it.
  factory UnknownWebhookEvent.fromJson(Map<String, dynamic> json) =>
      UnknownWebhookEvent(rawJson: json);

  @override
  String get type => rawJson['type'] as String;
  @override
  String? get id => rawJson['id'] is String ? rawJson['id'] as String : null;
  @override
  int? get createdAt =>
      rawJson['created_at'] is int ? rawJson['created_at'] as int : null;
  @override
  String? get object =>
      rawJson['object'] is String ? rawJson['object'] as String : null;
  @override
  Object? get data => rawJson['data'];

  @override
  Map<String, dynamic> _valueJson() => Map<String, dynamic>.from(rawJson);

  /// Replaces raw JSON completely, or edits arbitrary future members.
  /// Explicit null remains a JSON null; removeKeys removes a key completely.
  UnknownWebhookEvent copyWith({
    String? type,
    Object? id = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? data = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
    Set<String> removeKeys = const {},
  }) => UnknownWebhookEvent(
    rawJson: {
      for (final entry in (rawJson ?? this.rawJson).entries)
        if (!removeKeys.contains(entry.key)) entry.key: entry.value,
      'type': ?type,
      if (!identical(id, unsetCopyWithValue)) 'id': id,
      if (!identical(createdAt, unsetCopyWithValue)) 'created_at': createdAt,
      if (!identical(object, unsetCopyWithValue)) 'object': object,
      if (!identical(data, unsetCopyWithValue)) 'data': data,
    },
  );

  @override
  String toString() =>
      'UnknownWebhookEvent(type: [REDACTED], id: ${id == null ? null : "[REDACTED]"}, createdAt: ${createdAt == null ? null : "[REDACTED]"}, object: ${object == null ? null : "[REDACTED]"}, data: ${rawJson.containsKey("data") ? "[REDACTED]" : null}, rawJson: ${rawJson.length} entries)';
}
