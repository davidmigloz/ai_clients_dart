import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single log record emitted by a deployment worker.
@immutable
class DeploymentLogRecord {
  /// When the log was recorded.
  final String timestamp;

  /// The trace ID associated with the log.
  final String traceId;

  /// The span ID associated with the log.
  final String spanId;

  /// The log severity (e.g. `INFO`, `ERROR`).
  final String severityText;

  /// The log message body.
  final String body;

  /// Additional structured log attributes.
  final Map<String, String> logAttributes;

  /// Creates a [DeploymentLogRecord].
  DeploymentLogRecord({
    required this.timestamp,
    required this.traceId,
    required this.spanId,
    required this.severityText,
    required this.body,
    required Map<String, String> logAttributes,
  }) : logAttributes = Map.unmodifiable(logAttributes);

  /// Creates a [DeploymentLogRecord] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing.
  factory DeploymentLogRecord.fromJson(Map<String, dynamic> json) {
    String require(String key) {
      final value = json[key];
      if (value is! String) {
        throw FormatException(
          'DeploymentLogRecord: missing required field "$key"',
        );
      }
      return value;
    }

    final logAttributesJson = json['log_attributes'];
    if (logAttributesJson is! Map<String, dynamic>) {
      throw const FormatException(
        'DeploymentLogRecord: missing required field "log_attributes"',
      );
    }
    return DeploymentLogRecord(
      timestamp: require('timestamp'),
      traceId: require('trace_id'),
      spanId: require('span_id'),
      severityText: require('severity_text'),
      body: require('body'),
      logAttributes: logAttributesJson.map((k, v) => MapEntry(k, v as String)),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'trace_id': traceId,
    'span_id': spanId,
    'severity_text': severityText,
    'body': body,
    'log_attributes': logAttributes,
  };

  /// Creates a copy with replaced values.
  DeploymentLogRecord copyWith({
    String? timestamp,
    String? traceId,
    String? spanId,
    String? severityText,
    String? body,
    Map<String, String>? logAttributes,
  }) {
    return DeploymentLogRecord(
      timestamp: timestamp ?? this.timestamp,
      traceId: traceId ?? this.traceId,
      spanId: spanId ?? this.spanId,
      severityText: severityText ?? this.severityText,
      body: body ?? this.body,
      logAttributes: logAttributes ?? this.logAttributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeploymentLogRecord) return false;
    if (runtimeType != other.runtimeType) return false;
    return timestamp == other.timestamp &&
        traceId == other.traceId &&
        spanId == other.spanId &&
        severityText == other.severityText &&
        body == other.body &&
        mapsEqual(logAttributes, other.logAttributes);
  }

  @override
  int get hashCode => Object.hash(
    timestamp,
    traceId,
    spanId,
    severityText,
    body,
    mapHash(logAttributes),
  );

  @override
  String toString() =>
      'DeploymentLogRecord('
      'timestamp: $timestamp, '
      'traceId: $traceId, '
      'spanId: $spanId, '
      'severityText: $severityText, '
      'body: $body, '
      'logAttributes: $logAttributes'
      ')';
}
