import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_attribute.dart';

/// A trace event.
@immutable
class TempoTraceEvent {
  /// The event name.
  final String name;

  /// The event timestamp in nanoseconds.
  final String timeUnixNano;

  /// Event attributes.
  final List<TempoTraceAttribute>? attributes;

  /// Creates a [TempoTraceEvent].
  TempoTraceEvent({
    required this.name,
    required this.timeUnixNano,
    List<TempoTraceAttribute>? attributes,
  }) : attributes = attributes != null ? List.unmodifiable(attributes) : null;

  /// Creates a [TempoTraceEvent] from JSON.
  factory TempoTraceEvent.fromJson(Map<String, dynamic> json) =>
      TempoTraceEvent(
        name: json['name'] as String? ?? '',
        timeUnixNano: json['timeUnixNano'] as String? ?? '',
        attributes: (json['attributes'] as List?)
            ?.map(
              (e) => TempoTraceAttribute.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'timeUnixNano': timeUnixNano,
    if (attributes != null)
      'attributes': attributes?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoTraceEvent copyWith({
    String? name,
    String? timeUnixNano,
    Object? attributes = unsetCopyWithValue,
  }) {
    return TempoTraceEvent(
      name: name ?? this.name,
      timeUnixNano: timeUnixNano ?? this.timeUnixNano,
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as List<TempoTraceAttribute>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceEvent) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(attributes, other.attributes)) return false;
    return name == other.name && timeUnixNano == other.timeUnixNano;
  }

  @override
  int get hashCode => Object.hash(name, timeUnixNano, listHash(attributes));

  @override
  String toString() =>
      'TempoTraceEvent(name: $name, timeUnixNano: $timeUnixNano, attributes: ${attributes?.length ?? 'null'})';
}
