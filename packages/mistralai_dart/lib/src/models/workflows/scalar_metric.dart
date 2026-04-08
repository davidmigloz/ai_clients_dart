import 'package:meta/meta.dart';

/// A scalar metric value.
@immutable
class ScalarMetric {
  /// The metric value.
  final num value;

  /// Creates a [ScalarMetric].
  const ScalarMetric({required this.value});

  /// Creates a [ScalarMetric] from JSON.
  factory ScalarMetric.fromJson(Map<String, dynamic> json) =>
      ScalarMetric(value: json['value'] as num? ?? 0);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'value': value};

  /// Creates a copy with replaced values.
  ScalarMetric copyWith({num? value}) {
    return ScalarMetric(value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScalarMetric) return false;
    if (runtimeType != other.runtimeType) return false;
    return value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ScalarMetric(value: $value)';
}
