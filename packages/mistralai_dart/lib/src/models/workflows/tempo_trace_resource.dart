import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_attribute.dart';

/// A trace resource.
@immutable
class TempoTraceResource {
  /// Resource attributes.
  final List<TempoTraceAttribute>? attributes;

  /// Creates a [TempoTraceResource].
  TempoTraceResource({List<TempoTraceAttribute>? attributes})
    : attributes = attributes != null ? List.unmodifiable(attributes) : null;

  /// Creates a [TempoTraceResource] from JSON.
  factory TempoTraceResource.fromJson(Map<String, dynamic> json) =>
      TempoTraceResource(
        attributes: (json['attributes'] as List?)
            ?.map(
              (e) => TempoTraceAttribute.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (attributes != null)
      'attributes': attributes?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoTraceResource copyWith({Object? attributes = unsetCopyWithValue}) {
    return TempoTraceResource(
      attributes: attributes == unsetCopyWithValue
          ? this.attributes
          : attributes as List<TempoTraceAttribute>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceResource) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(attributes, other.attributes)) return false;
    return true;
  }

  @override
  int get hashCode => listHash(attributes);

  @override
  String toString() =>
      'TempoTraceResource(attributes: ${attributes?.length ?? 'null'})';
}
