import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_attribute.dart';
import 'tempo_trace_event.dart';
import 'tempo_trace_scope_kind.dart';

/// A trace span.
@immutable
class TempoTraceSpan {
  /// The trace identifier.
  final String traceId;

  /// The span identifier.
  final String spanId;

  /// The span name.
  final String name;

  /// The span kind.
  final TempoTraceScopeKind kind;

  /// Start time in nanoseconds.
  final String startTimeUnixNano;

  /// End time in nanoseconds.
  final String endTimeUnixNano;

  /// Parent span identifier.
  final String? parentSpanId;

  /// Span attributes.
  final List<TempoTraceAttribute>? attributes;

  /// Span events.
  final List<TempoTraceEvent>? events;

  /// Creates a [TempoTraceSpan].
  TempoTraceSpan({
    required this.traceId,
    required this.spanId,
    required this.name,
    required this.kind,
    required this.startTimeUnixNano,
    required this.endTimeUnixNano,
    this.parentSpanId,
    List<TempoTraceAttribute>? attributes,
    List<TempoTraceEvent>? events,
  }) : attributes = attributes != null ? List.unmodifiable(attributes) : null,
       events = events != null ? List.unmodifiable(events) : null;

  /// Creates a [TempoTraceSpan] from JSON.
  factory TempoTraceSpan.fromJson(Map<String, dynamic> json) => TempoTraceSpan(
    traceId: json['traceId'] as String? ?? '',
    spanId: json['spanId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    kind: TempoTraceScopeKind.fromJson(json['kind'] as String?),
    startTimeUnixNano: json['startTimeUnixNano'] as String? ?? '',
    endTimeUnixNano: json['endTimeUnixNano'] as String? ?? '',
    parentSpanId: json['parentSpanId'] as String?,
    attributes: (json['attributes'] as List?)
        ?.map((e) => TempoTraceAttribute.fromJson(e as Map<String, dynamic>))
        .toList(),
    events: (json['events'] as List?)
        ?.map((e) => TempoTraceEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'traceId': traceId,
    'spanId': spanId,
    'name': name,
    'kind': kind.toJson(),
    'startTimeUnixNano': startTimeUnixNano,
    'endTimeUnixNano': endTimeUnixNano,
    if (parentSpanId != null) 'parentSpanId': parentSpanId,
    if (attributes != null)
      'attributes': attributes?.map((e) => e.toJson()).toList(),
    if (events != null) 'events': events?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoTraceSpan copyWith({
    String? traceId,
    String? spanId,
    String? name,
    TempoTraceScopeKind? kind,
    String? startTimeUnixNano,
    String? endTimeUnixNano,
    Object? parentSpanId = unsetCopyWithValue,
    Object? attributes = unsetCopyWithValue,
    Object? events = unsetCopyWithValue,
  }) {
    return TempoTraceSpan(
      traceId: traceId ?? this.traceId,
      spanId: spanId ?? this.spanId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      startTimeUnixNano: startTimeUnixNano ?? this.startTimeUnixNano,
      endTimeUnixNano: endTimeUnixNano ?? this.endTimeUnixNano,
      parentSpanId: parentSpanId == unsetCopyWithValue
          ? this.parentSpanId
          : parentSpanId as String?,
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as List<TempoTraceAttribute>?,
      events: events == unsetCopyWithValue
          ? this.events
          : events as List<TempoTraceEvent>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceSpan) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(attributes, other.attributes)) return false;
    if (!listsEqual(events, other.events)) return false;
    return traceId == other.traceId &&
        spanId == other.spanId &&
        name == other.name &&
        kind == other.kind &&
        startTimeUnixNano == other.startTimeUnixNano &&
        endTimeUnixNano == other.endTimeUnixNano &&
        parentSpanId == other.parentSpanId;
  }

  @override
  int get hashCode => Object.hash(
    traceId,
    spanId,
    name,
    kind,
    startTimeUnixNano,
    endTimeUnixNano,
    parentSpanId,
    listHash(attributes),
    listHash(events),
  );

  @override
  String toString() =>
      'TempoTraceSpan('
      'traceId: $traceId, '
      'spanId: $spanId, '
      'name: $name, '
      'kind: $kind, '
      'startTimeUnixNano: $startTimeUnixNano, '
      'endTimeUnixNano: $endTimeUnixNano, '
      'parentSpanId: $parentSpanId, '
      'attributes: ${attributes?.length ?? 'null'}, '
      'events: ${events?.length ?? 'null'}'
      ')';
}
