import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single log record emitted by a workflow execution.
@immutable
class ExecutionLogRecord {
  /// The log timestamp (ISO 8601).
  final String timestamp;

  /// The trace identifier.
  final String traceId;

  /// The span identifier.
  final String spanId;

  /// The severity text of the log entry.
  final String severityText;

  /// The log message body.
  final String body;

  /// Additional log attributes.
  final Map<String, String> logAttributes;

  /// Creates an [ExecutionLogRecord].
  ExecutionLogRecord({
    required this.timestamp,
    required this.traceId,
    required this.spanId,
    required this.severityText,
    required this.body,
    required Map<String, String> logAttributes,
  }) : logAttributes = Map.unmodifiable(logAttributes);

  /// Creates an [ExecutionLogRecord] from JSON.
  factory ExecutionLogRecord.fromJson(Map<String, dynamic> json) =>
      ExecutionLogRecord(
        timestamp: json['timestamp'] as String? ?? '',
        traceId: json['trace_id'] as String? ?? '',
        spanId: json['span_id'] as String? ?? '',
        severityText: json['severity_text'] as String? ?? '',
        body: json['body'] as String? ?? '',
        logAttributes:
            (json['log_attributes'] as Map?)?.map(
              (key, value) => MapEntry(key as String, value as String),
            ) ??
            const {},
      );

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
  ExecutionLogRecord copyWith({
    String? timestamp,
    String? traceId,
    String? spanId,
    String? severityText,
    String? body,
    Map<String, String>? logAttributes,
  }) {
    return ExecutionLogRecord(
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
    if (other is! ExecutionLogRecord) return false;
    if (runtimeType != other.runtimeType) return false;
    return timestamp == other.timestamp &&
        traceId == other.traceId &&
        spanId == other.spanId &&
        severityText == other.severityText &&
        body == other.body &&
        mapsDeepEqual(logAttributes, other.logAttributes);
  }

  @override
  int get hashCode => Object.hash(
    timestamp,
    traceId,
    spanId,
    severityText,
    body,
    mapDeepHashCode(logAttributes),
  );

  @override
  String toString() =>
      'ExecutionLogRecord('
      'timestamp: $timestamp, '
      'traceId: $traceId, '
      'spanId: $spanId, '
      'severityText: $severityText, '
      'body: $body, '
      'logAttributes: ${logAttributes.length}'
      ')';
}
