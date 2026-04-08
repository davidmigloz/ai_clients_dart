import 'package:meta/meta.dart';

import 'scalar_metric.dart';
import 'time_series_metric.dart';

/// Metrics for a workflow.
@immutable
class WorkflowMetrics {
  /// Total execution count.
  final ScalarMetric executionCount;

  /// Successful execution count.
  final ScalarMetric successCount;

  /// Error count.
  final ScalarMetric errorCount;

  /// Average latency in milliseconds.
  final ScalarMetric averageLatencyMs;

  /// Latency over time series.
  final TimeSeriesMetric latencyOverTime;

  /// Retry rate.
  final ScalarMetric retryRate;

  /// Creates a [WorkflowMetrics].
  const WorkflowMetrics({
    required this.executionCount,
    required this.successCount,
    required this.errorCount,
    required this.averageLatencyMs,
    required this.latencyOverTime,
    required this.retryRate,
  });

  /// Creates a [WorkflowMetrics] from JSON.
  factory WorkflowMetrics.fromJson(Map<String, dynamic> json) =>
      WorkflowMetrics(
        executionCount: ScalarMetric.fromJson(
          json['execution_count'] as Map<String, dynamic>,
        ),
        successCount: ScalarMetric.fromJson(
          json['success_count'] as Map<String, dynamic>,
        ),
        errorCount: ScalarMetric.fromJson(
          json['error_count'] as Map<String, dynamic>,
        ),
        averageLatencyMs: ScalarMetric.fromJson(
          json['average_latency_ms'] as Map<String, dynamic>,
        ),
        latencyOverTime: TimeSeriesMetric.fromJson(
          json['latency_over_time'] as Map<String, dynamic>,
        ),
        retryRate: ScalarMetric.fromJson(
          json['retry_rate'] as Map<String, dynamic>,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'execution_count': executionCount.toJson(),
    'success_count': successCount.toJson(),
    'error_count': errorCount.toJson(),
    'average_latency_ms': averageLatencyMs.toJson(),
    'latency_over_time': latencyOverTime.toJson(),
    'retry_rate': retryRate.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowMetrics copyWith({
    ScalarMetric? executionCount,
    ScalarMetric? successCount,
    ScalarMetric? errorCount,
    ScalarMetric? averageLatencyMs,
    TimeSeriesMetric? latencyOverTime,
    ScalarMetric? retryRate,
  }) {
    return WorkflowMetrics(
      executionCount: executionCount ?? this.executionCount,
      successCount: successCount ?? this.successCount,
      errorCount: errorCount ?? this.errorCount,
      averageLatencyMs: averageLatencyMs ?? this.averageLatencyMs,
      latencyOverTime: latencyOverTime ?? this.latencyOverTime,
      retryRate: retryRate ?? this.retryRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowMetrics) return false;
    if (runtimeType != other.runtimeType) return false;
    return executionCount == other.executionCount &&
        successCount == other.successCount &&
        errorCount == other.errorCount &&
        averageLatencyMs == other.averageLatencyMs &&
        latencyOverTime == other.latencyOverTime &&
        retryRate == other.retryRate;
  }

  @override
  int get hashCode => Object.hash(
    executionCount,
    successCount,
    errorCount,
    averageLatencyMs,
    latencyOverTime,
    retryRate,
  );

  @override
  String toString() =>
      'WorkflowMetrics('
      'executionCount: $executionCount, '
      'successCount: $successCount, '
      'errorCount: $errorCount, '
      'averageLatencyMs: $averageLatencyMs, '
      'latencyOverTime: $latencyOverTime, '
      'retryRate: $retryRate'
      ')';
}
