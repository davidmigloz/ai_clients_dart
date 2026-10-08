part of 'webhook_event.dart';

/// Closed summary of the action an Agent session requires.
enum AgentSessionRequiredActionTypeResource {
  /// The session needs approval for computer use.
  computerUseApprovalRequest('computer_use_approval_request'),

  /// The session needs a function result.
  functionCall('function_call'),

  /// The session needs an environment connection.
  environmentConnection('environment_connection');

  /// Canonical wire spelling.
  final String value;
  const AgentSessionRequiredActionTypeResource(this.value);

  /// Parses one of the three declared action summaries.
  static AgentSessionRequiredActionTypeResource fromJson(Object? json) {
    for (final value in values) {
      if (json == value.value) return value;
    }
    throw const FormatException(
      'AgentSessionRequiredActionTypeResource.type: expected a declared action type',
    );
  }

  /// Serializes the canonical spelling.
  String toJson() => value;
}

/// Notification payload for `WebhookIdData`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class WebhookIdData with _WebhookValue {
  /// id received from the provider.
  final String id;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates WebhookIdData.
  WebhookIdData({required this.id, Map<String, dynamic> rawJson = const {}})
    : rawJson = _snapshotWebhookJson(rawJson, 'WebhookIdData.rawJson') {
    _snapshotWebhookJson(_valueJson(), 'WebhookIdData');
  }

  /// Parses a received WebhookIdData, without authenticating a signature.
  factory WebhookIdData.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'WebhookIdData');
    return WebhookIdData(
      id: requireJsonString(snapshot['id'], 'WebhookIdData.id'),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() =>
      _mergeWebhookJson(rawJson, {'id'}, {'id': id});

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  WebhookIdData copyWith({String? id, Map<String, dynamic>? rawJson}) =>
      WebhookIdData(id: id ?? this.id, rawJson: rawJson ?? this.rawJson);
  @override
  String toString() =>
      'WebhookIdData(id: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `WebhookSafetyAlertData`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class WebhookSafetyAlertData with _WebhookValue {
  /// id received from the provider.
  final String id;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates WebhookSafetyAlertData.
  WebhookSafetyAlertData({
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'WebhookSafetyAlertData.rawJson',
       ) {
    _requireAlertId(id, 'WebhookSafetyAlertData.id');
    _snapshotWebhookJson(_valueJson(), 'WebhookSafetyAlertData');
  }

  /// Parses a received WebhookSafetyAlertData, without authenticating a signature.
  factory WebhookSafetyAlertData.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'WebhookSafetyAlertData');
    return WebhookSafetyAlertData(
      id: requireJsonString(snapshot['id'], 'WebhookSafetyAlertData.id'),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() =>
      _mergeWebhookJson(rawJson, {'id'}, {'id': id});

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  WebhookSafetyAlertData copyWith({
    String? id,
    Map<String, dynamic>? rawJson,
  }) => WebhookSafetyAlertData(
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'WebhookSafetyAlertData(id: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `WebhookSipHeader`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class WebhookSipHeader with _WebhookValue {
  /// name received from the provider.
  final String name;

  /// value received from the provider.
  final String value;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates WebhookSipHeader.
  WebhookSipHeader({
    required this.name,
    required this.value,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(rawJson, 'WebhookSipHeader.rawJson') {
    _snapshotWebhookJson(_valueJson(), 'WebhookSipHeader');
  }

  /// Parses a received WebhookSipHeader, without authenticating a signature.
  factory WebhookSipHeader.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'WebhookSipHeader');
    return WebhookSipHeader(
      name: requireJsonString(snapshot['name'], 'WebhookSipHeader.name'),
      value: requireJsonString(snapshot['value'], 'WebhookSipHeader.value'),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'name', 'value'},
    {'name': name, 'value': value},
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  WebhookSipHeader copyWith({
    String? name,
    String? value,
    Map<String, dynamic>? rawJson,
  }) => WebhookSipHeader(
    name: name ?? this.name,
    value: value ?? this.value,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'WebhookSipHeader(name: [REDACTED], value: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `AgentSessionRequiredActionPayloadResource`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionRequiredActionPayloadResource with _WebhookValue {
  /// type received from the provider.
  final AgentSessionRequiredActionTypeResource type;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionRequiredActionPayloadResource.
  AgentSessionRequiredActionPayloadResource({
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionRequiredActionPayloadResource.rawJson',
       ) {
    _snapshotWebhookJson(
      _valueJson(),
      'AgentSessionRequiredActionPayloadResource',
    );
  }

  /// Parses a received AgentSessionRequiredActionPayloadResource, without authenticating a signature.
  factory AgentSessionRequiredActionPayloadResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionRequiredActionPayloadResource',
    );
    return AgentSessionRequiredActionPayloadResource(
      type: AgentSessionRequiredActionTypeResource.fromJson(snapshot['type']),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() =>
      _mergeWebhookJson(rawJson, {'type'}, {'type': type.toJson()});

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionRequiredActionPayloadResource copyWith({
    AgentSessionRequiredActionTypeResource? type,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionRequiredActionPayloadResource(
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionRequiredActionPayloadResource(type: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `AgentSessionConnectPayloadResource`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionConnectPayloadResource with _WebhookValue {
  /// remote_url received from the provider.
  final String remoteUrl;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionConnectPayloadResource.
  AgentSessionConnectPayloadResource({
    required this.remoteUrl,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionConnectPayloadResource.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionConnectPayloadResource');
  }

  /// Parses a received AgentSessionConnectPayloadResource, without authenticating a signature.
  factory AgentSessionConnectPayloadResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionConnectPayloadResource',
    );
    return AgentSessionConnectPayloadResource(
      remoteUrl: requireJsonString(
        snapshot['remote_url'],
        'AgentSessionConnectPayloadResource.remote_url',
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() =>
      _mergeWebhookJson(rawJson, {'remote_url'}, {'remote_url': remoteUrl});

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionConnectPayloadResource copyWith({
    String? remoteUrl,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionConnectPayloadResource(
    remoteUrl: remoteUrl ?? this.remoteUrl,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionConnectPayloadResource(remoteUrl: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `AgentSessionActionRequiredPayloadResource`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionActionRequiredPayloadResource with _WebhookValue {
  /// id received from the provider.
  final String id;

  /// required_action received from the provider.
  final AgentSessionRequiredActionPayloadResource requiredAction;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionActionRequiredPayloadResource.
  AgentSessionActionRequiredPayloadResource({
    required this.id,
    required this.requiredAction,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionActionRequiredPayloadResource.rawJson',
       ) {
    _snapshotWebhookJson(
      _valueJson(),
      'AgentSessionActionRequiredPayloadResource',
    );
  }

  /// Parses a received AgentSessionActionRequiredPayloadResource, without authenticating a signature.
  factory AgentSessionActionRequiredPayloadResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionActionRequiredPayloadResource',
    );
    return AgentSessionActionRequiredPayloadResource(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionActionRequiredPayloadResource.id',
      ),
      requiredAction: AgentSessionRequiredActionPayloadResource.fromJson(
        requireJsonObject(
          snapshot['required_action'],
          'AgentSessionActionRequiredPayloadResource.required_action',
        ),
      ),
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'required_action'},
    {'id': id, 'required_action': requiredAction.toJson()},
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionActionRequiredPayloadResource copyWith({
    String? id,
    AgentSessionRequiredActionPayloadResource? requiredAction,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionActionRequiredPayloadResource(
    id: id ?? this.id,
    requiredAction: requiredAction ?? this.requiredAction,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionActionRequiredPayloadResource(id: [REDACTED], requiredAction: [REDACTED], rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `AgentSessionCreatedPayloadResource`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionCreatedPayloadResource with _WebhookValue {
  /// id received from the provider.
  final String id;

  /// environment_type received from the provider.
  final String environmentType;

  /// environment_id received from the provider.
  final String? environmentId;

  /// connect received from the provider.
  final AgentSessionConnectPayloadResource? connect;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionCreatedPayloadResource.
  AgentSessionCreatedPayloadResource({
    required this.id,
    required this.environmentType,
    this.environmentId,
    this.connect,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionCreatedPayloadResource.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'AgentSessionCreatedPayloadResource');
  }

  /// Parses a received AgentSessionCreatedPayloadResource, without authenticating a signature.
  factory AgentSessionCreatedPayloadResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionCreatedPayloadResource',
    );
    return AgentSessionCreatedPayloadResource(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionCreatedPayloadResource.id',
      ),
      environmentType: requireJsonString(
        snapshot['environment_type'],
        'AgentSessionCreatedPayloadResource.environment_type',
      ),
      environmentId: snapshot.containsKey('environment_id')
          ? requireJsonString(
              snapshot['environment_id'],
              'AgentSessionCreatedPayloadResource.environment_id',
            )
          : null,
      connect: snapshot.containsKey('connect')
          ? AgentSessionConnectPayloadResource.fromJson(
              requireJsonObject(
                snapshot['connect'],
                'AgentSessionCreatedPayloadResource.connect',
              ),
            )
          : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'environment_type', 'environment_id', 'connect'},
    {
      'id': id,
      'environment_type': environmentType,
      if (environmentId != null) 'environment_id': environmentId,
      if (connect != null) 'connect': connect!.toJson(),
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionCreatedPayloadResource copyWith({
    String? id,
    String? environmentType,
    Object? environmentId = unsetCopyWithValue,
    Object? connect = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionCreatedPayloadResource(
    id: id ?? this.id,
    environmentType: environmentType ?? this.environmentType,
    environmentId: identical(environmentId, unsetCopyWithValue)
        ? this.environmentId
        : environmentId as String?,
    connect: identical(connect, unsetCopyWithValue)
        ? this.connect
        : connect as AgentSessionConnectPayloadResource?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionCreatedPayloadResource(id: [REDACTED], environmentType: [REDACTED], environmentId: ${environmentId == null ? null : "[REDACTED]"}, connect: ${connect == null ? null : "[REDACTED]"}, rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `AgentSessionEnvironmentPayloadResource`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class AgentSessionEnvironmentPayloadResource with _WebhookValue {
  /// id received from the provider.
  final String id;

  /// environment_type received from the provider.
  final String environmentType;

  /// environment_id received from the provider.
  final String? environmentId;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates AgentSessionEnvironmentPayloadResource.
  AgentSessionEnvironmentPayloadResource({
    required this.id,
    required this.environmentType,
    this.environmentId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = _snapshotWebhookJson(
         rawJson,
         'AgentSessionEnvironmentPayloadResource.rawJson',
       ) {
    _snapshotWebhookJson(
      _valueJson(),
      'AgentSessionEnvironmentPayloadResource',
    );
  }

  /// Parses a received AgentSessionEnvironmentPayloadResource, without authenticating a signature.
  factory AgentSessionEnvironmentPayloadResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final snapshot = _snapshotWebhookJson(
      json,
      'AgentSessionEnvironmentPayloadResource',
    );
    return AgentSessionEnvironmentPayloadResource(
      id: requireJsonString(
        snapshot['id'],
        'AgentSessionEnvironmentPayloadResource.id',
      ),
      environmentType: requireJsonString(
        snapshot['environment_type'],
        'AgentSessionEnvironmentPayloadResource.environment_type',
      ),
      environmentId: snapshot.containsKey('environment_id')
          ? requireJsonString(
              snapshot['environment_id'],
              'AgentSessionEnvironmentPayloadResource.environment_id',
            )
          : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'id', 'environment_type', 'environment_id'},
    {
      'id': id,
      'environment_type': environmentType,
      if (environmentId != null) 'environment_id': environmentId,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  AgentSessionEnvironmentPayloadResource copyWith({
    String? id,
    String? environmentType,
    Object? environmentId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionEnvironmentPayloadResource(
    id: id ?? this.id,
    environmentType: environmentType ?? this.environmentType,
    environmentId: identical(environmentId, unsetCopyWithValue)
        ? this.environmentId
        : environmentId as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'AgentSessionEnvironmentPayloadResource(id: [REDACTED], environmentType: [REDACTED], environmentId: ${environmentId == null ? null : "[REDACTED]"}, rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `LiveCallIncomingWebhookData`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class LiveCallIncomingWebhookData with _WebhookValue {
  /// session_id received from the provider.
  final String sessionId;

  /// sip_headers received from the provider.
  final List<WebhookSipHeader> sipHeaders;

  /// sip_media_security received from the provider.
  final String? sipMediaSecurity;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates LiveCallIncomingWebhookData.
  LiveCallIncomingWebhookData({
    required this.sessionId,
    required List<WebhookSipHeader> sipHeaders,
    this.sipMediaSecurity,
    Map<String, dynamic> rawJson = const {},
  }) : sipHeaders = List<WebhookSipHeader>.unmodifiable(sipHeaders),
       rawJson = _snapshotWebhookJson(
         rawJson,
         'LiveCallIncomingWebhookData.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'LiveCallIncomingWebhookData');
  }

  /// Parses a received LiveCallIncomingWebhookData, without authenticating a signature.
  factory LiveCallIncomingWebhookData.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(json, 'LiveCallIncomingWebhookData');
    return LiveCallIncomingWebhookData(
      sessionId: requireJsonString(
        snapshot['session_id'],
        'LiveCallIncomingWebhookData.session_id',
      ),
      sipHeaders: _sipHeaders(
        snapshot['sip_headers'],
        'LiveCallIncomingWebhookData.sip_headers',
      ),
      sipMediaSecurity: snapshot.containsKey('sip_media_security')
          ? requireJsonString(
              snapshot['sip_media_security'],
              'LiveCallIncomingWebhookData.sip_media_security',
            )
          : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'session_id', 'sip_headers', 'sip_media_security'},
    {
      'session_id': sessionId,
      'sip_headers': sipHeaders.map((entry) => entry.toJson()).toList(),
      if (sipMediaSecurity != null) 'sip_media_security': sipMediaSecurity,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  LiveCallIncomingWebhookData copyWith({
    String? sessionId,
    List<WebhookSipHeader>? sipHeaders,
    Object? sipMediaSecurity = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => LiveCallIncomingWebhookData(
    sessionId: sessionId ?? this.sessionId,
    sipHeaders: sipHeaders ?? this.sipHeaders,
    sipMediaSecurity: identical(sipMediaSecurity, unsetCopyWithValue)
        ? this.sipMediaSecurity
        : sipMediaSecurity as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'LiveCallIncomingWebhookData(sessionId: [REDACTED], sipHeaders: ${sipHeaders.length} items, sipMediaSecurity: ${sipMediaSecurity == null ? null : "[REDACTED]"}, rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `LiveTransportIncomingWebhookData`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class LiveTransportIncomingWebhookData with _WebhookValue {
  /// session_id received from the provider.
  final String sessionId;

  /// sip_headers received from the provider.
  final List<WebhookSipHeader> sipHeaders;

  /// sip_media_security received from the provider.
  final String? sipMediaSecurity;

  /// Fixed incoming transport discriminator.
  String get type => 'sip';

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates LiveTransportIncomingWebhookData.
  LiveTransportIncomingWebhookData({
    required this.sessionId,
    required List<WebhookSipHeader> sipHeaders,
    this.sipMediaSecurity,
    Map<String, dynamic> rawJson = const {},
  }) : sipHeaders = List<WebhookSipHeader>.unmodifiable(sipHeaders),
       rawJson = _snapshotWebhookJson(
         rawJson,
         'LiveTransportIncomingWebhookData.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'LiveTransportIncomingWebhookData');
  }

  /// Parses a received LiveTransportIncomingWebhookData, without authenticating a signature.
  factory LiveTransportIncomingWebhookData.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'LiveTransportIncomingWebhookData',
    );
    requireJsonType(snapshot, 'sip', 'LiveTransportIncomingWebhookData');
    return LiveTransportIncomingWebhookData(
      sessionId: requireJsonString(
        snapshot['session_id'],
        'LiveTransportIncomingWebhookData.session_id',
      ),
      sipHeaders: _sipHeaders(
        snapshot['sip_headers'],
        'LiveTransportIncomingWebhookData.sip_headers',
      ),
      sipMediaSecurity: snapshot.containsKey('sip_media_security')
          ? requireJsonString(
              snapshot['sip_media_security'],
              'LiveTransportIncomingWebhookData.sip_media_security',
            )
          : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'session_id', 'sip_headers', 'sip_media_security', 'type'},
    {
      'session_id': sessionId,
      'sip_headers': sipHeaders.map((entry) => entry.toJson()).toList(),
      if (sipMediaSecurity != null) 'sip_media_security': sipMediaSecurity,
      'type': type,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  LiveTransportIncomingWebhookData copyWith({
    String? sessionId,
    List<WebhookSipHeader>? sipHeaders,
    Object? sipMediaSecurity = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => LiveTransportIncomingWebhookData(
    sessionId: sessionId ?? this.sessionId,
    sipHeaders: sipHeaders ?? this.sipHeaders,
    sipMediaSecurity: identical(sipMediaSecurity, unsetCopyWithValue)
        ? this.sipMediaSecurity
        : sipMediaSecurity as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'LiveTransportIncomingWebhookData(sessionId: [REDACTED], sipHeaders: ${sipHeaders.length} items, sipMediaSecurity: ${sipMediaSecurity == null ? null : "[REDACTED]"}, rawJson: ${rawJson.length} entries)';
}

/// Notification payload for `RealtimeCallIncomingWebhookData`.
///
/// Future received metadata is preserved as a finite immutable JSON snapshot.
/// Replacing a child uses that child's complete JSON; cleared metadata is not
/// inherited from a prior parent snapshot. Diagnostics redact payload values.
@immutable
class RealtimeCallIncomingWebhookData with _WebhookValue {
  /// call_id received from the provider.
  final String callId;

  /// sip_headers received from the provider.
  final List<WebhookSipHeader> sipHeaders;

  /// sip_media_security received from the provider.
  final String? sipMediaSecurity;

  /// Finite, deeply immutable received metadata.
  @override
  final Map<String, dynamic> rawJson;

  /// Creates RealtimeCallIncomingWebhookData.
  RealtimeCallIncomingWebhookData({
    required this.callId,
    required List<WebhookSipHeader> sipHeaders,
    this.sipMediaSecurity,
    Map<String, dynamic> rawJson = const {},
  }) : sipHeaders = List<WebhookSipHeader>.unmodifiable(sipHeaders),
       rawJson = _snapshotWebhookJson(
         rawJson,
         'RealtimeCallIncomingWebhookData.rawJson',
       ) {
    _snapshotWebhookJson(_valueJson(), 'RealtimeCallIncomingWebhookData');
  }

  /// Parses a received RealtimeCallIncomingWebhookData, without authenticating a signature.
  factory RealtimeCallIncomingWebhookData.fromJson(Map<String, dynamic> json) {
    final snapshot = _snapshotWebhookJson(
      json,
      'RealtimeCallIncomingWebhookData',
    );
    return RealtimeCallIncomingWebhookData(
      callId: requireJsonString(
        snapshot['call_id'],
        'RealtimeCallIncomingWebhookData.call_id',
      ),
      sipHeaders: _sipHeaders(
        snapshot['sip_headers'],
        'RealtimeCallIncomingWebhookData.sip_headers',
      ),
      sipMediaSecurity: snapshot.containsKey('sip_media_security')
          ? requireJsonString(
              snapshot['sip_media_security'],
              'RealtimeCallIncomingWebhookData.sip_media_security',
            )
          : null,
      rawJson: snapshot,
    );
  }
  @override
  Map<String, dynamic> _valueJson() => _mergeWebhookJson(
    rawJson,
    {'call_id', 'sip_headers', 'sip_media_security'},
    {
      'call_id': callId,
      'sip_headers': sipHeaders.map((entry) => entry.toJson()).toList(),
      if (sipMediaSecurity != null) 'sip_media_security': sipMediaSecurity,
    },
  );

  /// Copies fields; explicit null removes optional keys and rawJson replaces
  /// all future metadata. Complete child replacement never retains stale keys.
  RealtimeCallIncomingWebhookData copyWith({
    String? callId,
    List<WebhookSipHeader>? sipHeaders,
    Object? sipMediaSecurity = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => RealtimeCallIncomingWebhookData(
    callId: callId ?? this.callId,
    sipHeaders: sipHeaders ?? this.sipHeaders,
    sipMediaSecurity: identical(sipMediaSecurity, unsetCopyWithValue)
        ? this.sipMediaSecurity
        : sipMediaSecurity as String?,
    rawJson: rawJson ?? this.rawJson,
  );
  @override
  String toString() =>
      'RealtimeCallIncomingWebhookData(callId: [REDACTED], sipHeaders: ${sipHeaders.length} items, sipMediaSecurity: ${sipMediaSecurity == null ? null : "[REDACTED]"}, rawJson: ${rawJson.length} entries)';
}
