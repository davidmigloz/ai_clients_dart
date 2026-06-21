import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A log record captured by the observability system.
@immutable
class GetLog {
  /// The `body` value.
  final String body;

  /// The `customer_id` value.
  final String customerId;

  /// The `event_name` value.
  final String eventName;

  /// The `log_attributes` value.
  final Map<String, dynamic> logAttributes;

  /// The `organization_id` value.
  final String organizationId;

  /// The `resource_attributes` value.
  final Map<String, dynamic> resourceAttributes;

  /// The `resource_schema_url` value.
  final String resourceSchemaUrl;

  /// The `scope_attributes` value.
  final Map<String, dynamic> scopeAttributes;

  /// The `scope_name` value.
  final String scopeName;

  /// The `scope_schema_url` value.
  final String scopeSchemaUrl;

  /// The `scope_version` value.
  final String scopeVersion;

  /// The `service_name` value.
  final String serviceName;

  /// The `severity_number` value.
  final int severityNumber;

  /// The `severity_text` value.
  final String severityText;

  /// The `span_id` value.
  final String spanId;

  /// The `timestamp` value.
  final String timestamp;

  /// The `trace_flags` value.
  final int traceFlags;

  /// The `trace_id` value.
  final String traceId;

  /// The `user_id` value.
  final String userId;

  /// The `workspace_id` value.
  final String workspaceId;

  /// Creates a [GetLog].
  const GetLog({
    required this.body,
    required this.customerId,
    required this.eventName,
    required this.logAttributes,
    required this.organizationId,
    required this.resourceAttributes,
    required this.resourceSchemaUrl,
    required this.scopeAttributes,
    required this.scopeName,
    required this.scopeSchemaUrl,
    required this.scopeVersion,
    required this.serviceName,
    required this.severityNumber,
    required this.severityText,
    required this.spanId,
    required this.timestamp,
    required this.traceFlags,
    required this.traceId,
    required this.userId,
    required this.workspaceId,
  });

  /// Creates a [GetLog] from JSON.
  factory GetLog.fromJson(Map<String, dynamic> json) => GetLog(
    body: json['body'] as String? ?? '',
    customerId: json['customer_id'] as String? ?? '',
    eventName: json['event_name'] as String? ?? '',
    logAttributes: json['log_attributes'] as Map<String, dynamic>? ?? const {},
    organizationId: json['organization_id'] as String? ?? '',
    resourceAttributes:
        json['resource_attributes'] as Map<String, dynamic>? ?? const {},
    resourceSchemaUrl: json['resource_schema_url'] as String? ?? '',
    scopeAttributes:
        json['scope_attributes'] as Map<String, dynamic>? ?? const {},
    scopeName: json['scope_name'] as String? ?? '',
    scopeSchemaUrl: json['scope_schema_url'] as String? ?? '',
    scopeVersion: json['scope_version'] as String? ?? '',
    serviceName: json['service_name'] as String? ?? '',
    severityNumber: json['severity_number'] as int? ?? 0,
    severityText: json['severity_text'] as String? ?? '',
    spanId: json['span_id'] as String? ?? '',
    timestamp: json['timestamp'] as String? ?? '',
    traceFlags: json['trace_flags'] as int? ?? 0,
    traceId: json['trace_id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    workspaceId: json['workspace_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'body': body,
    'customer_id': customerId,
    'event_name': eventName,
    'log_attributes': logAttributes,
    'organization_id': organizationId,
    'resource_attributes': resourceAttributes,
    'resource_schema_url': resourceSchemaUrl,
    'scope_attributes': scopeAttributes,
    'scope_name': scopeName,
    'scope_schema_url': scopeSchemaUrl,
    'scope_version': scopeVersion,
    'service_name': serviceName,
    'severity_number': severityNumber,
    'severity_text': severityText,
    'span_id': spanId,
    'timestamp': timestamp,
    'trace_flags': traceFlags,
    'trace_id': traceId,
    'user_id': userId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  GetLog copyWith({
    String? body,
    String? customerId,
    String? eventName,
    Map<String, dynamic>? logAttributes,
    String? organizationId,
    Map<String, dynamic>? resourceAttributes,
    String? resourceSchemaUrl,
    Map<String, dynamic>? scopeAttributes,
    String? scopeName,
    String? scopeSchemaUrl,
    String? scopeVersion,
    String? serviceName,
    int? severityNumber,
    String? severityText,
    String? spanId,
    String? timestamp,
    int? traceFlags,
    String? traceId,
    String? userId,
    String? workspaceId,
  }) {
    return GetLog(
      body: body ?? this.body,
      customerId: customerId ?? this.customerId,
      eventName: eventName ?? this.eventName,
      logAttributes: logAttributes ?? this.logAttributes,
      organizationId: organizationId ?? this.organizationId,
      resourceAttributes: resourceAttributes ?? this.resourceAttributes,
      resourceSchemaUrl: resourceSchemaUrl ?? this.resourceSchemaUrl,
      scopeAttributes: scopeAttributes ?? this.scopeAttributes,
      scopeName: scopeName ?? this.scopeName,
      scopeSchemaUrl: scopeSchemaUrl ?? this.scopeSchemaUrl,
      scopeVersion: scopeVersion ?? this.scopeVersion,
      serviceName: serviceName ?? this.serviceName,
      severityNumber: severityNumber ?? this.severityNumber,
      severityText: severityText ?? this.severityText,
      spanId: spanId ?? this.spanId,
      timestamp: timestamp ?? this.timestamp,
      traceFlags: traceFlags ?? this.traceFlags,
      traceId: traceId ?? this.traceId,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetLog) return false;
    if (runtimeType != other.runtimeType) return false;
    return body == other.body &&
        customerId == other.customerId &&
        eventName == other.eventName &&
        mapsDeepEqual(logAttributes, other.logAttributes) &&
        organizationId == other.organizationId &&
        mapsDeepEqual(resourceAttributes, other.resourceAttributes) &&
        resourceSchemaUrl == other.resourceSchemaUrl &&
        mapsDeepEqual(scopeAttributes, other.scopeAttributes) &&
        scopeName == other.scopeName &&
        scopeSchemaUrl == other.scopeSchemaUrl &&
        scopeVersion == other.scopeVersion &&
        serviceName == other.serviceName &&
        severityNumber == other.severityNumber &&
        severityText == other.severityText &&
        spanId == other.spanId &&
        timestamp == other.timestamp &&
        traceFlags == other.traceFlags &&
        traceId == other.traceId &&
        userId == other.userId &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hashAll([
    body,
    customerId,
    eventName,
    mapDeepHashCode(logAttributes),
    organizationId,
    mapDeepHashCode(resourceAttributes),
    resourceSchemaUrl,
    mapDeepHashCode(scopeAttributes),
    scopeName,
    scopeSchemaUrl,
    scopeVersion,
    serviceName,
    severityNumber,
    severityText,
    spanId,
    timestamp,
    traceFlags,
    traceId,
    userId,
    workspaceId,
  ]);

  @override
  String toString() =>
      'GetLog(body: $body, customerId: $customerId, eventName: $eventName, '
      'logAttributes: ${logAttributes.length} keys, '
      'organizationId: $organizationId, '
      'resourceAttributes: ${resourceAttributes.length} keys, '
      'resourceSchemaUrl: $resourceSchemaUrl, '
      'scopeAttributes: ${scopeAttributes.length} keys, '
      'scopeName: $scopeName, scopeSchemaUrl: $scopeSchemaUrl, '
      'scopeVersion: $scopeVersion, serviceName: $serviceName, '
      'severityNumber: $severityNumber, severityText: $severityText, '
      'spanId: $spanId, timestamp: $timestamp, traceFlags: $traceFlags, '
      'traceId: $traceId, userId: $userId, workspaceId: $workspaceId)';
}
