import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A trace attribute key-value pair.
@immutable
class TempoTraceAttribute {
  /// The attribute key.
  final String key;

  /// The attribute value.
  final Map<String, dynamic> value;

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
