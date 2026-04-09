import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'event_type.dart';

/// A workflow execution trace event.
@immutable
class WorkflowExecutionTraceEvent {
  /// The event name.
  final String name;

  /// The event identifier.
  final String id;

  /// Timestamp in nanoseconds.
  final int timestampUnixNano;

  /// Event attributes.
  final Map<String, dynamic> attributes;

  /// The event type.
  final EventType? type;

  /// Whether this is an internal event.
  final bool internal;

  /// Creates a [WorkflowExecutionTraceEvent].
  const WorkflowExecutionTraceEvent({
    required this.name,
    required this.id,
    required this.timestampUnixNano,
    required this.attributes,
    this.type,
    this.internal = false,
  });

  /// Creates a [WorkflowExecutionTraceEvent] from JSON.
  factory WorkflowExecutionTraceEvent.fromJson(Map<String, dynamic> json) =>
      WorkflowExecutionTraceEvent(
        name: json['name'] as String? ?? '',
        id: json['id'] as String? ?? '',
        timestampUnixNano: json['timestamp_unix_nano'] as int? ?? 0,
        attributes: json['attributes'] as Map<String, dynamic>? ?? {},
        type: json['type'] != null
            ? EventType.fromJson(json['type'] as String)
            : null,
        internal: json['internal'] as bool? ?? false,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'timestamp_unix_nano': timestampUnixNano,
    'attributes': attributes,
    if (type != null) 'type': type?.toJson(),
    'internal': internal,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionTraceEvent copyWith({
    String? name,
    String? id,
    int? timestampUnixNano,
    Map<String, dynamic>? attributes,
    Object? type = unsetCopyWithValue,
    bool? internal,
  }) {
    return WorkflowExecutionTraceEvent(
      name: name ?? this.name,
      id: id ?? this.id,
      timestampUnixNano: timestampUnixNano ?? this.timestampUnixNano,
      attributes: attributes ?? this.attributes,
      type: type == unsetCopyWithValue ? this.type : type as EventType?,
      internal: internal ?? this.internal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionTraceEvent) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(attributes, other.attributes)) return false;
    return name == other.name &&
        id == other.id &&
        timestampUnixNano == other.timestampUnixNano &&
        type == other.type &&
        internal == other.internal;
  }

  @override
  int get hashCode => Object.hash(
    name,
    id,
    timestampUnixNano,
    mapDeepHashCode(attributes),
    type,
    internal,
  );

  @override
  String toString() =>
      'WorkflowExecutionTraceEvent('
      'name: $name, '
      'id: $id, '
      'timestampUnixNano: $timestampUnixNano, '
      'attributes: ${attributes.length}, '
      'type: $type, '
      'internal: $internal'
      ')';
}
