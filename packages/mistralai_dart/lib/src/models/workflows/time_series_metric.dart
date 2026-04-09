import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A time series metric.
@immutable
class TimeSeriesMetric {
  /// The time series data points.
  final List<List<dynamic>> value;

  /// Creates a [TimeSeriesMetric].
  TimeSeriesMetric({required List<List<dynamic>> value})
    : value = List.unmodifiable(value);

  /// Creates a [TimeSeriesMetric] from JSON.
  factory TimeSeriesMetric.fromJson(Map<String, dynamic> json) =>
      TimeSeriesMetric(
        value:
            (json['value'] as List?)
                ?.map((e) => (e as List).cast<dynamic>())
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'value': value};

  /// Creates a copy with replaced values.
  TimeSeriesMetric copyWith({List<List<dynamic>>? value}) {
    return TimeSeriesMetric(value: value ?? this.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TimeSeriesMetric) return false;
    if (runtimeType != other.runtimeType) return false;
    return valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode => valueDeepHashCode(value);

  @override
  String toString() => 'TimeSeriesMetric(value: ${value.length})';
}
