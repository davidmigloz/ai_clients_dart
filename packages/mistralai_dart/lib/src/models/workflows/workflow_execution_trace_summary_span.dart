import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_execution_trace_event.dart';

/// A summary span in a workflow execution trace.
@immutable
class WorkflowExecutionTraceSummarySpan {
  /// The span identifier.
  final String spanId;

  /// The span name.
  final String name;

  /// Start time in nanoseconds.
  final int startTimeUnixNano;

  /// End time in nanoseconds.
  final int? endTimeUnixNano;

  /// Span attributes.
  final Map<String, dynamic> attributes;

  /// Span events.
  final List<WorkflowExecutionTraceEvent> events;

  /// Child spans.
  final List<WorkflowExecutionTraceSummarySpan>? children;

  /// Creates a [WorkflowExecutionTraceSummarySpan].
  WorkflowExecutionTraceSummarySpan({
    required this.spanId,
    required this.name,
    required this.startTimeUnixNano,
    required this.endTimeUnixNano,
    required this.attributes,
    required List<WorkflowExecutionTraceEvent> events,
    List<WorkflowExecutionTraceSummarySpan>? children,
  }) : events = List.unmodifiable(events),
       children = children != null ? List.unmodifiable(children) : null;

  /// Creates a [WorkflowExecutionTraceSummarySpan] from JSON.
  factory WorkflowExecutionTraceSummarySpan.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionTraceSummarySpan(
    spanId: json['span_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    startTimeUnixNano: json['start_time_unix_nano'] as int? ?? 0,
    endTimeUnixNano: json['end_time_unix_nano'] as int?,
    attributes: json['attributes'] as Map<String, dynamic>? ?? {},
    events:
        (json['events'] as List?)
            ?.map(
              (e) => WorkflowExecutionTraceEvent.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [],
    children: (json['children'] as List?)
        ?.map(
          (e) => WorkflowExecutionTraceSummarySpan.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'span_id': spanId,
    'name': name,
    'start_time_unix_nano': startTimeUnixNano,
    'end_time_unix_nano': endTimeUnixNano,
    'attributes': attributes,
    'events': events.map((e) => e.toJson()).toList(),
    if (children != null) 'children': children?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionTraceSummarySpan copyWith({
    String? spanId,
    String? name,
    int? startTimeUnixNano,
    Object? endTimeUnixNano = unsetCopyWithValue,
    Map<String, dynamic>? attributes,
    List<WorkflowExecutionTraceEvent>? events,
    Object? children = unsetCopyWithValue,
  }) {
    return WorkflowExecutionTraceSummarySpan(
      spanId: spanId ?? this.spanId,
      name: name ?? this.name,
      startTimeUnixNano: startTimeUnixNano ?? this.startTimeUnixNano,
      endTimeUnixNano: endTimeUnixNano == unsetCopyWithValue
          ? this.endTimeUnixNano
          : endTimeUnixNano as int?,
      attributes: attributes ?? this.attributes,
      events: events ?? this.events,
      children: children == unsetCopyWithValue
          ? this.children
          : children as List<WorkflowExecutionTraceSummarySpan>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionTraceSummarySpan) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(attributes, other.attributes)) return false;
    if (!listsEqual(events, other.events)) return false;
    if (!listsEqual(children, other.children)) return false;
    return spanId == other.spanId &&
        name == other.name &&
        startTimeUnixNano == other.startTimeUnixNano &&
        endTimeUnixNano == other.endTimeUnixNano;
  }

  @override
  int get hashCode => Object.hash(
    spanId,
    name,
    startTimeUnixNano,
    endTimeUnixNano,
    mapDeepHashCode(attributes),
    listHash(events),
    listHash(children),
  );

  @override
  String toString() =>
      'WorkflowExecutionTraceSummarySpan('
      'spanId: $spanId, '
      'name: $name, '
      'startTimeUnixNano: $startTimeUnixNano, '
      'endTimeUnixNano: $endTimeUnixNano, '
      'attributes: ${attributes.length}, '
      'events: ${events.length}, '
      'children: ${children?.length ?? 'null'}'
      ')';
}
