import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The Aggregation wire payload.
@immutable
class Aggregation {
  /// Creates a [Aggregation].
  const Aggregation({required this.data, required this.meta});

  /// The data field.
  final List<AggregationRow> data;

  /// The meta field.
  final AggregationMeta meta;

  /// Parses a [Aggregation] from JSON.
  factory Aggregation.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('Aggregation: missing data');
    }
    if (json['meta'] == null) {
      throw const FormatException('Aggregation: missing meta');
    }
    return Aggregation(
      data: (json['data'] as List<Object?>)
          .map((item) => AggregationRow.fromJson(item! as Map<String, dynamic>))
          .toList(),
      meta: AggregationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'meta': meta.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  Aggregation copyWith({List<AggregationRow>? data, AggregationMeta? meta}) =>
      Aggregation(data: data ?? this.data, meta: meta ?? this.meta);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Aggregation &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          meta == other.meta;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(data), meta]);

  @override
  String toString() =>
      'Aggregation('
      'data: ${data.length}, '
      'meta: $meta)';
}

/// The AggregationMeta wire payload.
@immutable
class AggregationMeta {
  /// Creates a [AggregationMeta].
  const AggregationMeta({
    required this.fromTimestamp,
    this.granularitySeconds,
    required this.toTimestamp,
  });

  /// The from_timestamp field.
  final DateTime fromTimestamp;

  /// The granularity_seconds field.
  final int? granularitySeconds;

  /// The to_timestamp field.
  final DateTime toTimestamp;

  /// Parses a [AggregationMeta] from JSON.
  factory AggregationMeta.fromJson(Map<String, dynamic> json) {
    if (json['from_timestamp'] == null) {
      throw const FormatException('AggregationMeta: missing from_timestamp');
    }
    if (json['to_timestamp'] == null) {
      throw const FormatException('AggregationMeta: missing to_timestamp');
    }
    return AggregationMeta(
      fromTimestamp: DateTime.parse(json['from_timestamp'] as String),
      granularitySeconds: json['granularity_seconds'] == null
          ? null
          : json['granularity_seconds'] as int,
      toTimestamp: DateTime.parse(json['to_timestamp'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'from_timestamp': fromTimestamp.toIso8601String(),
    'granularity_seconds': ?granularitySeconds,
    'to_timestamp': toTimestamp.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  AggregationMeta copyWith({
    DateTime? fromTimestamp,
    Object? granularitySeconds = unsetCopyWithValue,
    DateTime? toTimestamp,
  }) => AggregationMeta(
    fromTimestamp: fromTimestamp ?? this.fromTimestamp,
    granularitySeconds: granularitySeconds == unsetCopyWithValue
        ? this.granularitySeconds
        : granularitySeconds as int?,
    toTimestamp: toTimestamp ?? this.toTimestamp,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationMeta &&
          runtimeType == other.runtimeType &&
          fromTimestamp == other.fromTimestamp &&
          granularitySeconds == other.granularitySeconds &&
          toTimestamp == other.toTimestamp;

  @override
  int get hashCode =>
      Object.hashAll([fromTimestamp, granularitySeconds, toTimestamp]);

  @override
  String toString() =>
      'AggregationMeta('
      'fromTimestamp: $fromTimestamp, '
      'granularitySeconds: $granularitySeconds, '
      'toTimestamp: $toTimestamp)';
}

/// The AggregationRequest wire payload.
@immutable
class AggregationRequest {
  /// Creates a [AggregationRequest].
  const AggregationRequest({
    this.dimensions,
    this.limit,
    required this.metric,
    this.orderBy,
    this.searchExpression,
    this.timeDimension,
  });

  /// The dimensions field.
  final List<String>? dimensions;

  /// The limit field.
  final int? limit;

  /// The metric field.
  final AggregationMetric metric;

  /// The order_by field.
  final List<AggregationOrder>? orderBy;

  /// The search_expression field.
  final String? searchExpression;

  /// The time_dimension field.
  final AggregationTimeDimension? timeDimension;

  /// Parses a [AggregationRequest] from JSON.
  factory AggregationRequest.fromJson(Map<String, dynamic> json) {
    if (json['metric'] == null) {
      throw const FormatException('AggregationRequest: missing metric');
    }
    return AggregationRequest(
      dimensions: json['dimensions'] == null
          ? null
          : (json['dimensions'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      limit: json['limit'] == null ? null : json['limit'] as int,
      metric: AggregationMetric.fromJson(
        json['metric'] as Map<String, dynamic>,
      ),
      orderBy: json['order_by'] == null
          ? null
          : (json['order_by'] as List<Object?>)
                .map(
                  (item) =>
                      AggregationOrder.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      searchExpression: json['search_expression'] == null
          ? null
          : json['search_expression'] as String,
      timeDimension: json['time_dimension'] == null
          ? null
          : AggregationTimeDimension.fromJson(
              json['time_dimension'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'dimensions': ?dimensions,
    'limit': ?limit,
    'metric': metric.toJson(),
    if (orderBy != null)
      'order_by': orderBy!.map((item) => item.toJson()).toList(),
    'search_expression': ?searchExpression,
    if (timeDimension != null) 'time_dimension': timeDimension!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AggregationRequest copyWith({
    Object? dimensions = unsetCopyWithValue,
    Object? limit = unsetCopyWithValue,
    AggregationMetric? metric,
    Object? orderBy = unsetCopyWithValue,
    Object? searchExpression = unsetCopyWithValue,
    Object? timeDimension = unsetCopyWithValue,
  }) => AggregationRequest(
    dimensions: dimensions == unsetCopyWithValue
        ? this.dimensions
        : (dimensions as List<Object?>?)?.cast<String>(),
    limit: limit == unsetCopyWithValue ? this.limit : limit as int?,
    metric: metric ?? this.metric,
    orderBy: orderBy == unsetCopyWithValue
        ? this.orderBy
        : (orderBy as List<Object?>?)?.cast<AggregationOrder>(),
    searchExpression: searchExpression == unsetCopyWithValue
        ? this.searchExpression
        : searchExpression as String?,
    timeDimension: timeDimension == unsetCopyWithValue
        ? this.timeDimension
        : timeDimension as AggregationTimeDimension?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(dimensions, other.dimensions) &&
          limit == other.limit &&
          metric == other.metric &&
          valuesDeepEqual(orderBy, other.orderBy) &&
          searchExpression == other.searchExpression &&
          timeDimension == other.timeDimension;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(dimensions),
    limit,
    metric,
    valueDeepHashCode(orderBy),
    searchExpression,
    timeDimension,
  ]);

  @override
  String toString() =>
      'AggregationRequest('
      'dimensions: ${dimensions?.length}, '
      'limit: $limit, '
      'metric: $metric, '
      'orderBy: ${orderBy?.length}, '
      'searchExpression: $searchExpression, '
      'timeDimension: $timeDimension)';
}

/// The AggregationRow wire payload.
@immutable
class AggregationRow {
  /// Creates a [AggregationRow].
  const AggregationRow({
    this.dimensions,
    required this.metricName,
    this.metricValue,
    this.timeBucket,
  });

  /// The dimensions field.
  final Map<String, dynamic>? dimensions;

  /// The metric_name field.
  final String metricName;

  /// The metric_value field.
  final Object? metricValue;

  /// The time_bucket field.
  final DateTime? timeBucket;

  /// Parses a [AggregationRow] from JSON.
  factory AggregationRow.fromJson(Map<String, dynamic> json) {
    if (json['metric_name'] == null) {
      throw const FormatException('AggregationRow: missing metric_name');
    }
    return AggregationRow(
      dimensions: json['dimensions'] == null
          ? null
          : json['dimensions'] as Map<String, dynamic>,
      metricName: json['metric_name'] as String,
      metricValue: json['metric_value'],
      timeBucket: json['time_bucket'] == null
          ? null
          : DateTime.parse(json['time_bucket'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'dimensions': ?dimensions,
    'metric_name': metricName,
    'metric_value': ?metricValue,
    if (timeBucket != null) 'time_bucket': timeBucket!.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  AggregationRow copyWith({
    Object? dimensions = unsetCopyWithValue,
    String? metricName,
    Object? metricValue = unsetCopyWithValue,
    Object? timeBucket = unsetCopyWithValue,
  }) => AggregationRow(
    dimensions: dimensions == unsetCopyWithValue
        ? this.dimensions
        : (dimensions as Map?)?.cast<String, dynamic>(),
    metricName: metricName ?? this.metricName,
    metricValue: metricValue == unsetCopyWithValue
        ? this.metricValue
        : metricValue,
    timeBucket: timeBucket == unsetCopyWithValue
        ? this.timeBucket
        : timeBucket as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationRow &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(dimensions, other.dimensions) &&
          metricName == other.metricName &&
          valuesDeepEqual(metricValue, other.metricValue) &&
          timeBucket == other.timeBucket;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(dimensions),
    metricName,
    valueDeepHashCode(metricValue),
    timeBucket,
  ]);

  @override
  String toString() =>
      'AggregationRow('
      'dimensions: ${dimensions?.length}, '
      'metricName: $metricName, '
      'metricValue: $metricValue, '
      'timeBucket: $timeBucket)';
}

/// Values for AggregationGranularity.
enum AggregationGranularity {
  /// Represents auto.
  auto('auto'),

  /// Represents second.
  second('second'),

  /// Represents minute.
  minute('minute'),

  /// Represents hour.
  hour('hour'),

  /// Represents day.
  day('day'),

  /// Represents week.
  week('week'),

  /// Represents month.
  month('month'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AggregationGranularity(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AggregationGranularity fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for MetricAggregation.
enum MetricAggregation {
  /// Represents count.
  count('count'),

  /// Represents count_distinct.
  countDistinct('count_distinct'),

  /// Represents sum.
  sum('sum'),

  /// Represents avg.
  avg('avg'),

  /// Represents min.
  min('min'),

  /// Represents max.
  max('max'),

  /// Represents p50.
  p50('p50'),

  /// Represents p90.
  p90('p90'),

  /// Represents p95.
  p95('p95'),

  /// Represents p99.
  p99('p99'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const MetricAggregation(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static MetricAggregation fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The MetricDefinition wire payload.
@immutable
class AggregationMetric {
  /// Creates a [AggregationMetric].
  const AggregationMetric({required this.aggregation, required this.measure});

  /// The aggregation field.
  final MetricAggregation aggregation;

  /// The measure field.
  final String measure;

  /// Parses a [AggregationMetric] from JSON.
  factory AggregationMetric.fromJson(Map<String, dynamic> json) {
    if (json['aggregation'] == null) {
      throw const FormatException('AggregationMetric: missing aggregation');
    }
    if (json['measure'] == null) {
      throw const FormatException('AggregationMetric: missing measure');
    }
    return AggregationMetric(
      aggregation: MetricAggregation.fromJson(json['aggregation'] as String),
      measure: json['measure'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'aggregation': aggregation.toJson(),
    'measure': measure,
  };

  /// Creates a copy with the given fields replaced.
  AggregationMetric copyWith({
    MetricAggregation? aggregation,
    String? measure,
  }) => AggregationMetric(
    aggregation: aggregation ?? this.aggregation,
    measure: measure ?? this.measure,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationMetric &&
          runtimeType == other.runtimeType &&
          aggregation == other.aggregation &&
          measure == other.measure;

  @override
  int get hashCode => Object.hashAll([aggregation, measure]);

  @override
  String toString() =>
      'AggregationMetric('
      'aggregation: $aggregation, '
      'measure: $measure)';
}

/// The OrderByClause wire payload.
@immutable
class AggregationOrder {
  /// Creates a [AggregationOrder].
  const AggregationOrder({this.direction, required this.field});

  /// The direction field.
  final String? direction;

  /// The field field.
  final String field;

  /// Parses a [AggregationOrder] from JSON.
  factory AggregationOrder.fromJson(Map<String, dynamic> json) {
    if (json['field'] == null) {
      throw const FormatException('AggregationOrder: missing field');
    }
    return AggregationOrder(
      direction: json['direction'] == null ? null : json['direction'] as String,
      field: json['field'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'direction': ?direction, 'field': field};

  /// Creates a copy with the given fields replaced.
  AggregationOrder copyWith({
    Object? direction = unsetCopyWithValue,
    String? field,
  }) => AggregationOrder(
    direction: direction == unsetCopyWithValue
        ? this.direction
        : direction as String?,
    field: field ?? this.field,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationOrder &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          field == other.field;

  @override
  int get hashCode => Object.hashAll([direction, field]);

  @override
  String toString() =>
      'AggregationOrder('
      'direction: $direction, '
      'field: $field)';
}

/// The TimeDimension wire payload.
@immutable
class AggregationTimeDimension {
  /// Creates a [AggregationTimeDimension].
  const AggregationTimeDimension({this.granularity});

  /// The granularity field.
  final AggregationGranularity? granularity;

  /// Parses a [AggregationTimeDimension] from JSON.
  factory AggregationTimeDimension.fromJson(Map<String, dynamic> json) {
    return AggregationTimeDimension(
      granularity: json['granularity'] == null
          ? null
          : AggregationGranularity.fromJson(json['granularity'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (granularity != null) 'granularity': granularity!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AggregationTimeDimension copyWith({
    Object? granularity = unsetCopyWithValue,
  }) => AggregationTimeDimension(
    granularity: granularity == unsetCopyWithValue
        ? this.granularity
        : granularity as AggregationGranularity?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AggregationTimeDimension &&
          runtimeType == other.runtimeType &&
          granularity == other.granularity;

  @override
  int get hashCode => Object.hashAll([granularity]);

  @override
  String toString() =>
      'AggregationTimeDimension('
      'granularity: $granularity)';
}
