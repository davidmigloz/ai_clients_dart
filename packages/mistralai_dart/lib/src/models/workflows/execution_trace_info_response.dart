import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Trace availability info for a workflow execution.
@immutable
class ExecutionTraceInfoResponse {
  /// Whether trace data is available in the trace backend for this execution.
  final bool hasTraceData;

  /// The OpenTelemetry trace ID, if available.
  final String? otelTraceId;

  /// Creates an [ExecutionTraceInfoResponse].
  const ExecutionTraceInfoResponse({
    this.hasTraceData = false,
    this.otelTraceId,
  });

  /// Creates an [ExecutionTraceInfoResponse] from JSON.
  factory ExecutionTraceInfoResponse.fromJson(Map<String, dynamic> json) =>
      ExecutionTraceInfoResponse(
        hasTraceData: json['has_trace_data'] as bool? ?? false,
        otelTraceId: json['otel_trace_id'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'has_trace_data': hasTraceData,
    if (otelTraceId != null) 'otel_trace_id': otelTraceId,
  };

  /// Creates a copy with replaced values.
  ExecutionTraceInfoResponse copyWith({
    bool? hasTraceData,
    Object? otelTraceId = unsetCopyWithValue,
  }) {
    return ExecutionTraceInfoResponse(
      hasTraceData: hasTraceData ?? this.hasTraceData,
      otelTraceId: otelTraceId == unsetCopyWithValue
          ? this.otelTraceId
          : otelTraceId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExecutionTraceInfoResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return hasTraceData == other.hasTraceData &&
        otelTraceId == other.otelTraceId;
  }

  @override
  int get hashCode => Object.hash(hasTraceData, otelTraceId);

  @override
  String toString() =>
      'ExecutionTraceInfoResponse('
      'hasTraceData: $hasTraceData, '
      'otelTraceId: $otelTraceId'
      ')';
}
