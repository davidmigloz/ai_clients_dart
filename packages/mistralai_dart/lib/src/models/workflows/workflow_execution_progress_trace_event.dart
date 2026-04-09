import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'event_progress_status.dart';
import 'event_type.dart';

/// A workflow execution progress trace event.
@immutable
class WorkflowExecutionProgressTraceEvent {
  /// The event name.
  final String name;

  /// The event identifier.
  final String id;

  /// Timestamp in nanoseconds.
  final int timestampUnixNano;

  /// Event attributes.
  final Map<String, dynamic> attributes;

  /// Start time in milliseconds.
  final int startTimeUnixMs;

  /// End time in milliseconds.
  final int? endTimeUnixMs;

  /// Error message.
  final String? error;

  /// The event type.
  final EventType? type;

  /// The progress status.
  final EventProgressStatus? status;

  /// Whether this is an internal event.
  final bool internal;

  /// Creates a [WorkflowExecutionProgressTraceEvent].
  const WorkflowExecutionProgressTraceEvent({
    required this.name,
    required this.id,
    required this.timestampUnixNano,
    required this.attributes,
    required this.startTimeUnixMs,
    this.endTimeUnixMs,
    this.error,
    this.type,
    this.status,
    this.internal = false,
  });

  /// Creates a [WorkflowExecutionProgressTraceEvent] from JSON.
  factory WorkflowExecutionProgressTraceEvent.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionProgressTraceEvent(
    name: json['name'] as String? ?? '',
    id: json['id'] as String? ?? '',
    timestampUnixNano: json['timestamp_unix_nano'] as int? ?? 0,
    attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    startTimeUnixMs: json['start_time_unix_ms'] as int? ?? 0,
    endTimeUnixMs: json['end_time_unix_ms'] as int?,
    error: json['error'] as String?,
    type: json['type'] != null
        ? EventType.fromJson(json['type'] as String)
        : null,
    status: json['status'] != null
        ? EventProgressStatus.fromJson(json['status'] as String)
        : null,
    internal: json['internal'] as bool? ?? false,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'timestamp_unix_nano': timestampUnixNano,
    'attributes': attributes,
    'start_time_unix_ms': startTimeUnixMs,
    if (endTimeUnixMs != null) 'end_time_unix_ms': endTimeUnixMs,
    if (error != null) 'error': error,
    if (type != null) 'type': type?.toJson(),
    if (status != null) 'status': status?.toJson(),
    'internal': internal,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionProgressTraceEvent copyWith({
    String? name,
    String? id,
    int? timestampUnixNano,
    Map<String, dynamic>? attributes,
    int? startTimeUnixMs,
    Object? endTimeUnixMs = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    bool? internal,
  }) {
    return WorkflowExecutionProgressTraceEvent(
      name: name ?? this.name,
      id: id ?? this.id,
      timestampUnixNano: timestampUnixNano ?? this.timestampUnixNano,
      attributes: attributes ?? this.attributes,
      startTimeUnixMs: startTimeUnixMs ?? this.startTimeUnixMs,
      endTimeUnixMs: endTimeUnixMs == unsetCopyWithValue
          ? this.endTimeUnixMs
          : endTimeUnixMs as int?,
      error: error == unsetCopyWithValue ? this.error : error as String?,
      type: type == unsetCopyWithValue ? this.type : type as EventType?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as EventProgressStatus?,
      internal: internal ?? this.internal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionProgressTraceEvent) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(attributes, other.attributes)) return false;
    return name == other.name &&
        id == other.id &&
        timestampUnixNano == other.timestampUnixNano &&
        startTimeUnixMs == other.startTimeUnixMs &&
        endTimeUnixMs == other.endTimeUnixMs &&
        error == other.error &&
        type == other.type &&
        status == other.status &&
        internal == other.internal;
  }

  @override
  int get hashCode => Object.hash(
    name,
    id,
    timestampUnixNano,
    mapDeepHashCode(attributes),
    startTimeUnixMs,
    endTimeUnixMs,
    error,
    type,
    status,
    internal,
  );

  @override
  String toString() =>
      'WorkflowExecutionProgressTraceEvent('
      'name: $name, '
      'id: $id, '
      'timestampUnixNano: $timestampUnixNano, '
      'attributes: ${attributes.length}, '
      'startTimeUnixMs: $startTimeUnixMs, '
      'endTimeUnixMs: $endTimeUnixMs, '
      'error: $error, '
      'type: $type, '
      'status: $status, '
      'internal: $internal'
      ')';
}
