import 'dart:collection';

import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

part 'webhook_endpoint_json_helpers.dart';

/// Exact writable project webhook subscription and test event choices.
///
/// This closed enum includes video notifications. Received notifications and
/// discovery responses use their separate, open string contracts.
enum WebhookEventType {
  /// The `batch.completed` project notification.
  batchCompleted('batch.completed'),

  /// The `batch.failed` project notification.
  batchFailed('batch.failed'),

  /// The `batch.expired` project notification.
  batchExpired('batch.expired'),

  /// The `batch.cancelled` project notification.
  batchCancelled('batch.cancelled'),

  /// The `response.completed` project notification.
  responseCompleted('response.completed'),

  /// The `response.failed` project notification.
  responseFailed('response.failed'),

  /// The `response.cancelled` project notification.
  responseCancelled('response.cancelled'),

  /// The `response.incomplete` project notification.
  responseIncomplete('response.incomplete'),

  /// The `eval.run.succeeded` project notification.
  evalRunSucceeded('eval.run.succeeded'),

  /// The `eval.run.failed` project notification.
  evalRunFailed('eval.run.failed'),

  /// The `eval.run.canceled` project notification.
  evalRunCanceled('eval.run.canceled'),

  /// The `fine_tuning.job.succeeded` project notification.
  fineTuningJobSucceeded('fine_tuning.job.succeeded'),

  /// The `fine_tuning.job.failed` project notification.
  fineTuningJobFailed('fine_tuning.job.failed'),

  /// The `fine_tuning.job.cancelled` project notification.
  fineTuningJobCancelled('fine_tuning.job.cancelled'),

  /// The `realtime.call.incoming` project notification.
  realtimeCallIncoming('realtime.call.incoming'),

  /// The `video.completed` project notification.
  videoCompleted('video.completed'),

  /// The `video.failed` project notification.
  videoFailed('video.failed'),

  /// The `agent.session.created` project notification.
  agentSessionCreated('agent.session.created'),

  /// The `agent.session.action_required` project notification.
  agentSessionActionRequired('agent.session.action_required'),

  /// The `agent.session.in_progress` project notification.
  agentSessionInProgress('agent.session.in_progress'),

  /// The `agent.session.idle` project notification.
  agentSessionIdle('agent.session.idle'),

  /// The `agent.session.failed` project notification.
  agentSessionFailed('agent.session.failed'),

  /// The `safety.alert.created` project notification.
  safetyAlertCreated('safety.alert.created');

  const WebhookEventType(this.value);

  /// Canonical JSON event type.
  final String value;

  /// Parses a canonical writable event type without accepting future values.
  static WebhookEventType fromJson(String value) => switch (value) {
    'batch.completed' => WebhookEventType.batchCompleted,
    'batch.failed' => WebhookEventType.batchFailed,
    'batch.expired' => WebhookEventType.batchExpired,
    'batch.cancelled' => WebhookEventType.batchCancelled,
    'response.completed' => WebhookEventType.responseCompleted,
    'response.failed' => WebhookEventType.responseFailed,
    'response.cancelled' => WebhookEventType.responseCancelled,
    'response.incomplete' => WebhookEventType.responseIncomplete,
    'eval.run.succeeded' => WebhookEventType.evalRunSucceeded,
    'eval.run.failed' => WebhookEventType.evalRunFailed,
    'eval.run.canceled' => WebhookEventType.evalRunCanceled,
    'fine_tuning.job.succeeded' => WebhookEventType.fineTuningJobSucceeded,
    'fine_tuning.job.failed' => WebhookEventType.fineTuningJobFailed,
    'fine_tuning.job.cancelled' => WebhookEventType.fineTuningJobCancelled,
    'realtime.call.incoming' => WebhookEventType.realtimeCallIncoming,
    'video.completed' => WebhookEventType.videoCompleted,
    'video.failed' => WebhookEventType.videoFailed,
    'agent.session.created' => WebhookEventType.agentSessionCreated,
    'agent.session.action_required' =>
      WebhookEventType.agentSessionActionRequired,
    'agent.session.in_progress' => WebhookEventType.agentSessionInProgress,
    'agent.session.idle' => WebhookEventType.agentSessionIdle,
    'agent.session.failed' => WebhookEventType.agentSessionFailed,
    'safety.alert.created' => WebhookEventType.safetyAlertCreated,
    _ => throw const FormatException(
      'WebhookEventType: expected a canonical project event type',
    ),
  };

  /// Returns the canonical JSON event type.
  String toJson() => value;
}

/// Configuration for creating a project webhook endpoint.
@immutable
class WebhookEndpointCreateRequest with _EndpointValue {
  /// Creates WebhookEndpointCreateRequest.
  WebhookEndpointCreateRequest({
    required this.name,
    required this.url,
    required List<WebhookEventType> eventTypes,
  }) : eventTypes = List.unmodifiable(eventTypes) {
    _validate();
  }

  /// A human-readable name for the webhook endpoint.
  final String name;

  /// The HTTPS URL that receives webhook deliveries.
  final String url;

  /// The event types that trigger deliveries to this endpoint.
  final List<WebhookEventType> eventTypes;

  /// Parses WebhookEndpointCreateRequest with contextual, redacted errors.
  factory WebhookEndpointCreateRequest.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointCreateRequest');
    return WebhookEndpointCreateRequest(
      name: requireJsonString(
        snapshot['name'],
        'WebhookEndpointCreateRequest.name',
      ),
      url: requireJsonString(
        snapshot['url'],
        'WebhookEndpointCreateRequest.url',
      ),
      eventTypes: _endpointWritableEvents(
        snapshot['event_types'],
        'WebhookEndpointCreateRequest.event_types',
      ),
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointCreateRequest copyWith({
    String? name,
    String? url,
    List<WebhookEventType>? eventTypes,
  }) => WebhookEndpointCreateRequest(
    name: name ?? this.name,
    url: url ?? this.url,
    eventTypes: eventTypes ?? this.eventTypes,
  );

  void _validate() {
    _endpointName(name, 'WebhookEndpointCreateRequest.name');
    _endpointUrl(url, 'WebhookEndpointCreateRequest.url');
    _endpointNonemptyEvents(
      eventTypes,
      'WebhookEndpointCreateRequest.event_types',
    );
  }

  @override
  Map<String, dynamic> _valueJson() {
    _validate();
    return {
      'name': name,
      'url': url,
      'event_types': eventTypes.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'WebhookEndpointCreateRequest('
      'name: [redacted], '
      'url: [redacted], '
      'eventTypes: ${eventTypes.length} items, '
      ')';
}

/// Configuration updates for a project webhook endpoint.
///
/// An empty request is valid. Supplied event types replace the complete set.
@immutable
class WebhookEndpointUpdateRequest with _EndpointValue {
  /// Creates WebhookEndpointUpdateRequest.
  WebhookEndpointUpdateRequest({
    this.name,
    this.url,
    List<WebhookEventType>? eventTypes,
  }) : eventTypes = eventTypes == null ? null : List.unmodifiable(eventTypes) {
    _validate();
  }

  /// A new human-readable name for the webhook endpoint.
  final String? name;

  /// A new HTTPS URL that receives webhook deliveries.
  final String? url;

  /// The complete set of event types that should trigger deliveries.
  final List<WebhookEventType>? eventTypes;

  /// Parses WebhookEndpointUpdateRequest with contextual, redacted errors.
  factory WebhookEndpointUpdateRequest.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointUpdateRequest');
    return WebhookEndpointUpdateRequest(
      name: optionalJsonString(
        snapshot,
        'name',
        'WebhookEndpointUpdateRequest',
      ),
      url: optionalJsonString(snapshot, 'url', 'WebhookEndpointUpdateRequest'),
      eventTypes: snapshot.containsKey('event_types')
          ? _endpointWritableEvents(
              snapshot['event_types'],
              'WebhookEndpointUpdateRequest.event_types',
            )
          : null,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointUpdateRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? url = unsetCopyWithValue,
    Object? eventTypes = unsetCopyWithValue,
  }) => WebhookEndpointUpdateRequest(
    name: identical(name, unsetCopyWithValue)
        ? this.name
        : _endpointCopyString(name, 'WebhookEndpointUpdateRequest.name'),
    url: identical(url, unsetCopyWithValue)
        ? this.url
        : _endpointCopyString(url, 'WebhookEndpointUpdateRequest.url'),
    eventTypes: identical(eventTypes, unsetCopyWithValue)
        ? this.eventTypes
        : _endpointCopyEvents(
            eventTypes,
            'WebhookEndpointUpdateRequest.eventTypes',
          ),
  );

  void _validate() {
    if (name != null) {
      _endpointName(name!, 'WebhookEndpointUpdateRequest.name');
    }
    if (url != null) {
      _endpointUrl(url!, 'WebhookEndpointUpdateRequest.url');
    }
    if (eventTypes != null) {
      _endpointNonemptyEvents(
        eventTypes!,
        'WebhookEndpointUpdateRequest.event_types',
      );
    }
  }

  @override
  Map<String, dynamic> _valueJson() {
    _validate();
    return {
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (eventTypes != null)
        'event_types': eventTypes!.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'WebhookEndpointUpdateRequest('
      'name: ${name == null ? null : '[redacted]'}, '
      'url: ${url == null ? null : '[redacted]'}, '
      'eventTypes: ${eventTypes == null ? null : '${eventTypes!.length} items'}, '
      ')';
}

/// Signing-secret rotation options for a project webhook endpoint.
///
/// Omitted or false overlap invalidates the previous secret immediately. True
/// retains it for 24 hours. Rotation does not change a local verifier secret.
@immutable
class WebhookEndpointRotateSecretRequest with _EndpointValue {
  /// Creates WebhookEndpointRotateSecretRequest.
  WebhookEndpointRotateSecretRequest({this.keepOldSecretActiveFor24Hours}) {
    _validate();
  }

  /// Whether to keep the previous signing secret valid for 24 hours after rotation. Defaults to false, which invalidates the previous secret immediately.
  final bool? keepOldSecretActiveFor24Hours;

  /// Parses WebhookEndpointRotateSecretRequest with contextual, redacted errors.
  factory WebhookEndpointRotateSecretRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _endpointSnapshot(
      json,
      'WebhookEndpointRotateSecretRequest',
    );
    return WebhookEndpointRotateSecretRequest(
      keepOldSecretActiveFor24Hours: optionalJsonBool(
        snapshot,
        'keep_old_secret_active_for_24_hours',
        'WebhookEndpointRotateSecretRequest',
      ),
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointRotateSecretRequest copyWith({
    Object? keepOldSecretActiveFor24Hours = unsetCopyWithValue,
  }) => WebhookEndpointRotateSecretRequest(
    keepOldSecretActiveFor24Hours:
        identical(keepOldSecretActiveFor24Hours, unsetCopyWithValue)
        ? this.keepOldSecretActiveFor24Hours
        : _endpointCopyBool(
            keepOldSecretActiveFor24Hours,
            'WebhookEndpointRotateSecretRequest.keepOldSecretActiveFor24Hours',
          ),
  );

  void _validate() {}

  @override
  Map<String, dynamic> _valueJson() {
    _validate();
    return {
      if (keepOldSecretActiveFor24Hours != null)
        'keep_old_secret_active_for_24_hours': keepOldSecretActiveFor24Hours,
    };
  }

  @override
  String toString() =>
      'WebhookEndpointRotateSecretRequest('
      'keepOldSecretActiveFor24Hours: $keepOldSecretActiveFor24Hours, '
      ')';
}

/// The project event type to send as a sample delivery.
@immutable
class WebhookEndpointTestRequest with _EndpointValue {
  /// Creates WebhookEndpointTestRequest.
  WebhookEndpointTestRequest({required this.eventType}) {
    _validate();
  }

  /// The event type to send as a sample delivery.
  final WebhookEventType eventType;

  /// Parses WebhookEndpointTestRequest with contextual, redacted errors.
  factory WebhookEndpointTestRequest.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointTestRequest');
    return WebhookEndpointTestRequest(
      eventType: _endpointEvent(
        snapshot['event_type'],
        'WebhookEndpointTestRequest.event_type',
      ),
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointTestRequest copyWith({WebhookEventType? eventType}) =>
      WebhookEndpointTestRequest(eventType: eventType ?? this.eventType);

  void _validate() {}

  @override
  Map<String, dynamic> _valueJson() {
    _validate();
    return {'event_type': eventType.toJson()};
  }

  @override
  String toString() =>
      'WebhookEndpointTestRequest('
      'eventType: $eventType, '
      ')';
}

/// A project webhook endpoint without its signing secret.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
@immutable
class WebhookEndpoint with _EndpointValue {
  /// Creates WebhookEndpoint.
  WebhookEndpoint({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.url,
    required List<String> eventTypes,
    required this.signingSecretHint,
    Map<String, dynamic> rawJson = const {},
  }) : eventTypes = List.unmodifiable(eventTypes),
       rawJson = _endpointSnapshot(rawJson, 'WebhookEndpoint.rawJson');

  /// The unique ID of the webhook endpoint.
  final String id;

  /// The Unix timestamp when the endpoint was created.
  final int createdAt;

  /// The Unix timestamp of the last endpoint configuration or signing-secret change. Initialized at creation; tests and unchanged updates do not advance it.
  final int? updatedAt;

  /// The human-readable name of the endpoint.
  final String name;

  /// The HTTPS URL that receives webhook deliveries.
  final String url;

  /// The event types that trigger deliveries to this endpoint.
  final List<String> eventTypes;

  /// Required nullable masked hint for the endpoint signing secret.
  final String? signingSecretHint;

  /// The fixed canonical object value.
  String get object => 'webhook_endpoint';

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses WebhookEndpoint with contextual, redacted errors.
  factory WebhookEndpoint.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpoint');
    if (snapshot['object'] != 'webhook_endpoint') {
      throw const FormatException(
        'WebhookEndpoint.object: expected the canonical fixed value',
      );
    }
    return WebhookEndpoint(
      id: requireJsonString(snapshot['id'], 'WebhookEndpoint.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'WebhookEndpoint.created_at',
      ),
      updatedAt: optionalJsonInt(snapshot, 'updated_at', 'WebhookEndpoint'),
      name: requireJsonString(snapshot['name'], 'WebhookEndpoint.name'),
      url: requireJsonString(snapshot['url'], 'WebhookEndpoint.url'),
      eventTypes: _endpointStrings(
        snapshot['event_types'],
        'WebhookEndpoint.event_types',
      ),
      signingSecretHint: _endpointNullableString(
        snapshot,
        'signing_secret_hint',
        'WebhookEndpoint',
      ),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpoint copyWith({
    String? id,
    int? createdAt,
    Object? updatedAt = unsetCopyWithValue,
    String? name,
    String? url,
    List<String>? eventTypes,
    Object? signingSecretHint = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => WebhookEndpoint(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: identical(updatedAt, unsetCopyWithValue)
        ? this.updatedAt
        : _endpointCopyInt(updatedAt, 'WebhookEndpoint.updatedAt'),
    name: name ?? this.name,
    url: url ?? this.url,
    eventTypes: eventTypes ?? this.eventTypes,
    signingSecretHint: identical(signingSecretHint, unsetCopyWithValue)
        ? this.signingSecretHint
        : _endpointCopyString(
            signingSecretHint,
            'WebhookEndpoint.signingSecretHint',
          ),
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {
        'id',
        'object',
        'created_at',
        'updated_at',
        'name',
        'url',
        'event_types',
        'signing_secret_hint',
      },
      {
        'object': object,
        'id': id,
        'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
        'name': name,
        'url': url,
        'event_types': eventTypes,
        'signing_secret_hint': signingSecretHint,
      },
    );
  }

  @override
  String toString() =>
      'WebhookEndpoint('
      'id: [redacted], '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'name: [redacted], '
      'url: [redacted], '
      'eventTypes: ${eventTypes.length} items, '
      'signingSecretHint: ${signingSecretHint == null ? null : '[redacted]'}, '
      'object: $object, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}

/// A project endpoint and its newly created or rotated signing secret.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
@immutable
class WebhookEndpointWithSecret with _EndpointValue {
  /// Creates WebhookEndpointWithSecret.
  WebhookEndpointWithSecret({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.name,
    required this.url,
    required List<String> eventTypes,
    required this.signingSecretHint,
    required this.signingSecret,
    Map<String, dynamic> rawJson = const {},
  }) : eventTypes = List.unmodifiable(eventTypes),
       rawJson = _endpointSnapshot(
         rawJson,
         'WebhookEndpointWithSecret.rawJson',
       );

  /// The unique ID of the webhook endpoint.
  final String id;

  /// The Unix timestamp when the endpoint was created.
  final int createdAt;

  /// The Unix timestamp of the last endpoint configuration or signing-secret change. Initialized at creation; tests and unchanged updates do not advance it.
  final int? updatedAt;

  /// The human-readable name of the endpoint.
  final String name;

  /// The HTTPS URL that receives webhook deliveries.
  final String url;

  /// The event types that trigger deliveries to this endpoint.
  final List<String> eventTypes;

  /// Required nullable masked hint for the endpoint signing secret.
  final String? signingSecretHint;

  /// The signing secret returned only at creation or rotation; store securely.
  final String signingSecret;

  /// The fixed canonical object value.
  String get object => 'webhook_endpoint';

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses WebhookEndpointWithSecret with contextual, redacted errors.
  factory WebhookEndpointWithSecret.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointWithSecret');
    if (snapshot['object'] != 'webhook_endpoint') {
      throw const FormatException(
        'WebhookEndpointWithSecret.object: expected the canonical fixed value',
      );
    }
    return WebhookEndpointWithSecret(
      id: requireJsonString(snapshot['id'], 'WebhookEndpointWithSecret.id'),
      createdAt: requireJsonInt(
        snapshot['created_at'],
        'WebhookEndpointWithSecret.created_at',
      ),
      updatedAt: optionalJsonInt(
        snapshot,
        'updated_at',
        'WebhookEndpointWithSecret',
      ),
      name: requireJsonString(
        snapshot['name'],
        'WebhookEndpointWithSecret.name',
      ),
      url: requireJsonString(snapshot['url'], 'WebhookEndpointWithSecret.url'),
      eventTypes: _endpointStrings(
        snapshot['event_types'],
        'WebhookEndpointWithSecret.event_types',
      ),
      signingSecretHint: _endpointNullableString(
        snapshot,
        'signing_secret_hint',
        'WebhookEndpointWithSecret',
      ),
      signingSecret: requireJsonString(
        snapshot['signing_secret'],
        'WebhookEndpointWithSecret.signing_secret',
      ),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointWithSecret copyWith({
    String? id,
    int? createdAt,
    Object? updatedAt = unsetCopyWithValue,
    String? name,
    String? url,
    List<String>? eventTypes,
    Object? signingSecretHint = unsetCopyWithValue,
    String? signingSecret,
    Map<String, dynamic>? rawJson,
  }) => WebhookEndpointWithSecret(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: identical(updatedAt, unsetCopyWithValue)
        ? this.updatedAt
        : _endpointCopyInt(updatedAt, 'WebhookEndpointWithSecret.updatedAt'),
    name: name ?? this.name,
    url: url ?? this.url,
    eventTypes: eventTypes ?? this.eventTypes,
    signingSecretHint: identical(signingSecretHint, unsetCopyWithValue)
        ? this.signingSecretHint
        : _endpointCopyString(
            signingSecretHint,
            'WebhookEndpointWithSecret.signingSecretHint',
          ),
    signingSecret: signingSecret ?? this.signingSecret,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {
        'id',
        'object',
        'created_at',
        'updated_at',
        'name',
        'url',
        'event_types',
        'signing_secret_hint',
        'signing_secret',
      },
      {
        'object': object,
        'id': id,
        'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
        'name': name,
        'url': url,
        'event_types': eventTypes,
        'signing_secret_hint': signingSecretHint,
        'signing_secret': signingSecret,
      },
    );
  }

  @override
  String toString() =>
      'WebhookEndpointWithSecret('
      'id: [redacted], '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'name: [redacted], '
      'url: [redacted], '
      'eventTypes: ${eventTypes.length} items, '
      'signingSecretHint: ${signingSecretHint == null ? null : '[redacted]'}, '
      'signingSecret: [redacted], '
      'object: $object, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}

/// A paginated list of project webhook endpoints.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
@immutable
class WebhookEndpointList with _EndpointValue {
  /// Creates WebhookEndpointList.
  WebhookEndpointList({
    required List<WebhookEndpoint> data,
    required this.firstId,
    required this.lastId,
    required this.hasMore,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = _endpointSnapshot(rawJson, 'WebhookEndpointList.rawJson');

  /// The endpoints in this page, with immutable list ownership.
  final List<WebhookEndpoint> data;

  /// Required nullable ID of the first endpoint in this page.
  final String? firstId;

  /// Required nullable ID of the last endpoint in this page.
  final String? lastId;

  /// Whether more webhook endpoints are available.
  final bool hasMore;

  /// The fixed canonical object value.
  String get object => 'list';

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses WebhookEndpointList with contextual, redacted errors.
  factory WebhookEndpointList.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointList');
    if (snapshot['object'] != 'list') {
      throw const FormatException(
        'WebhookEndpointList.object: expected the canonical fixed value',
      );
    }
    return WebhookEndpointList(
      data: _endpointItems(snapshot['data'], 'WebhookEndpointList.data'),
      firstId: _endpointNullableString(
        snapshot,
        'first_id',
        'WebhookEndpointList',
      ),
      lastId: _endpointNullableString(
        snapshot,
        'last_id',
        'WebhookEndpointList',
      ),
      hasMore: _endpointBool(
        snapshot['has_more'],
        'WebhookEndpointList.has_more',
      ),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointList copyWith({
    List<WebhookEndpoint>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
    Map<String, dynamic>? rawJson,
  }) => WebhookEndpointList(
    data: data ?? this.data,
    firstId: identical(firstId, unsetCopyWithValue)
        ? this.firstId
        : _endpointCopyString(firstId, 'WebhookEndpointList.firstId'),
    lastId: identical(lastId, unsetCopyWithValue)
        ? this.lastId
        : _endpointCopyString(lastId, 'WebhookEndpointList.lastId'),
    hasMore: hasMore ?? this.hasMore,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {'object', 'data', 'first_id', 'last_id', 'has_more'},
      {
        'object': object,
        'data': data.map((item) => item.toJson()).toList(),
        'first_id': firstId,
        'last_id': lastId,
        'has_more': hasMore,
      },
    );
  }

  @override
  String toString() =>
      'WebhookEndpointList('
      'data: ${data.length} items, '
      'firstId: ${firstId == null ? null : '[redacted]'}, '
      'lastId: ${lastId == null ? null : '[redacted]'}, '
      'hasMore: $hasMore, '
      'object: $object, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}

/// The deletion result for a project webhook endpoint.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
@immutable
class DeletedWebhookEndpoint with _EndpointValue {
  /// Creates DeletedWebhookEndpoint.
  DeletedWebhookEndpoint({
    required this.id,
    required this.deleted,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _endpointSnapshot(rawJson, 'DeletedWebhookEndpoint.rawJson');

  /// The ID of the deleted webhook endpoint.
  final String id;

  /// Whether the endpoint was deleted.
  final bool deleted;

  /// The fixed canonical object value.
  String get object => 'webhook_endpoint.deleted';

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses DeletedWebhookEndpoint with contextual, redacted errors.
  factory DeletedWebhookEndpoint.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'DeletedWebhookEndpoint');
    if (snapshot['object'] != 'webhook_endpoint.deleted') {
      throw const FormatException(
        'DeletedWebhookEndpoint.object: expected the canonical fixed value',
      );
    }
    return DeletedWebhookEndpoint(
      id: requireJsonString(snapshot['id'], 'DeletedWebhookEndpoint.id'),
      deleted: _endpointBool(
        snapshot['deleted'],
        'DeletedWebhookEndpoint.deleted',
      ),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  DeletedWebhookEndpoint copyWith({
    String? id,
    bool? deleted,
    Map<String, dynamic>? rawJson,
  }) => DeletedWebhookEndpoint(
    id: id ?? this.id,
    deleted: deleted ?? this.deleted,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {'id', 'object', 'deleted'},
      {'object': object, 'id': id, 'deleted': deleted},
    );
  }

  @override
  String toString() =>
      'DeletedWebhookEndpoint('
      'id: [redacted], '
      'deleted: $deleted, '
      'object: $object, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}

/// The receiver response to a sample project webhook delivery.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
///
/// Success means that the test request completed. Inspect statusCode separately
/// to assess the receiver response, including a possible 4xx or 5xx.
@immutable
class WebhookEndpointTestResult with _EndpointValue {
  /// Creates WebhookEndpointTestResult.
  WebhookEndpointTestResult({
    required this.webhookEndpointId,
    required this.eventType,
    required this.statusCode,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _endpointSnapshot(
         rawJson,
         'WebhookEndpointTestResult.rawJson',
       );

  /// The ID of the webhook endpoint that received the test.
  final String webhookEndpointId;

  /// The event type sent in the test.
  final String eventType;

  /// The HTTP status code returned by the endpoint.
  final int statusCode;

  /// The fixed canonical object value.
  String get object => 'webhook_endpoint.test';

  /// The fixed canonical success value.
  bool get success => true;

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses WebhookEndpointTestResult with contextual, redacted errors.
  factory WebhookEndpointTestResult.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEndpointTestResult');
    if (snapshot['object'] != 'webhook_endpoint.test') {
      throw const FormatException(
        'WebhookEndpointTestResult.object: expected the canonical fixed value',
      );
    }
    if (snapshot['success'] != true) {
      throw const FormatException(
        'WebhookEndpointTestResult.success: expected the canonical fixed value',
      );
    }
    return WebhookEndpointTestResult(
      webhookEndpointId: requireJsonString(
        snapshot['webhook_endpoint_id'],
        'WebhookEndpointTestResult.webhook_endpoint_id',
      ),
      eventType: requireJsonString(
        snapshot['event_type'],
        'WebhookEndpointTestResult.event_type',
      ),
      statusCode: requireJsonInt(
        snapshot['status_code'],
        'WebhookEndpointTestResult.status_code',
      ),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEndpointTestResult copyWith({
    String? webhookEndpointId,
    String? eventType,
    int? statusCode,
    Map<String, dynamic>? rawJson,
  }) => WebhookEndpointTestResult(
    webhookEndpointId: webhookEndpointId ?? this.webhookEndpointId,
    eventType: eventType ?? this.eventType,
    statusCode: statusCode ?? this.statusCode,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {'object', 'webhook_endpoint_id', 'event_type', 'status_code', 'success'},
      {
        'object': object,
        'success': success,
        'webhook_endpoint_id': webhookEndpointId,
        'event_type': eventType,
        'status_code': statusCode,
      },
    );
  }

  @override
  String toString() =>
      'WebhookEndpointTestResult('
      'webhookEndpointId: [redacted], '
      'eventType: [redacted], '
      'statusCode: $statusCode, '
      'object: $object, '
      'success: $success, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}

/// Available project webhook event types returned by discovery.
///
/// Finite future received metadata is preserved as an immutable snapshot.
/// Typed fields replace the corresponding raw values when serialized; replacing
/// a child uses that child's complete JSON. Diagnostics redact opaque values.
@immutable
class WebhookEventTypeList with _EndpointValue {
  /// Creates WebhookEventTypeList.
  WebhookEventTypeList({
    required List<String> data,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = _endpointSnapshot(rawJson, 'WebhookEventTypeList.rawJson');

  /// Available event type strings, preserving future values.
  final List<String> data;

  /// The fixed canonical object value.
  String get object => 'list';

  /// Finite, deeply immutable metadata received from the provider.
  final Map<String, dynamic> rawJson;

  /// Parses WebhookEventTypeList with contextual, redacted errors.
  factory WebhookEventTypeList.fromJson(Map<String, dynamic> json) {
    final snapshot = _endpointSnapshot(json, 'WebhookEventTypeList');
    if (snapshot['object'] != 'list') {
      throw const FormatException(
        'WebhookEventTypeList.object: expected the canonical fixed value',
      );
    }
    return WebhookEventTypeList(
      data: _endpointStrings(snapshot['data'], 'WebhookEventTypeList.data'),
      rawJson: snapshot,
    );
  }

  /// Copies the model; null clears optional or nullable fields.
  WebhookEventTypeList copyWith({
    List<String>? data,
    Map<String, dynamic>? rawJson,
  }) => WebhookEventTypeList(
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );

  @override
  Map<String, dynamic> _valueJson() {
    return _endpointMerge(
      rawJson,
      {'object', 'data'},
      {'object': object, 'data': data},
    );
  }

  @override
  String toString() =>
      'WebhookEventTypeList('
      'data: ${data.length} items, '
      'object: $object, '
      'rawJson: ${rawJson.length} entries, '
      ')';
}
