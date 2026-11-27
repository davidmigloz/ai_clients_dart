import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'tempo_trace_attribute_double_value.dart';

/// A trace attribute key-value pair.
@immutable
class TempoTraceAttribute {
  /// The attribute key.
  final String key;

  /// The attribute value.
  final Map<String, dynamic> value;

  /// Floating-point value when the attribute has a double representation.
  double? get doubleValue => value['doubleValue'] == null
      ? null
      : TempoTraceAttributeDoubleValue.fromJson(value).doubleValue;

  /// Array elements when the attribute has an array representation.
  List<TempoTraceAttributeArrayElement>? get arrayElements {
    final array = value['arrayValue'] as Map<String, dynamic>?;
    return (array?['values'] as List<dynamic>?)
        ?.map(
          (element) => TempoTraceAttributeArrayElement.fromJson(
            element as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Creates a [TempoTraceAttribute].
  const TempoTraceAttribute({required this.key, required this.value});

  /// Creates a [TempoTraceAttribute] from JSON.
  factory TempoTraceAttribute.fromJson(Map<String, dynamic> json) =>
      TempoTraceAttribute(
        key: json['key'] as String? ?? '',
        value: json['value'] as Map<String, dynamic>? ?? {},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  /// Creates a copy with replaced values.
  TempoTraceAttribute copyWith({String? key, Map<String, dynamic>? value}) {
    return TempoTraceAttribute(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceAttribute) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(value, other.value)) return false;
    return key == other.key;
  }

  @override
  int get hashCode => Object.hash(key, mapDeepHashCode(value));

  @override
  String toString() => 'TempoTraceAttribute(key: $key, value: ${value.length})';
}
