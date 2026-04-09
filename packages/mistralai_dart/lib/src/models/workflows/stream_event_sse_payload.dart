import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'stream_event_workflow_context.dart';

/// SSE payload for workflow stream events.
@immutable
class StreamEventSsePayload {
  /// The stream identifier.
  final String stream;

  /// The event data.
  final Map<String, dynamic> data;

  /// The workflow context.
  final StreamEventWorkflowContext workflowContext;

  /// The broker sequence number.
  final int brokerSequence;

  /// Optional metadata.
  final Map<String, dynamic>? metadata;

  /// The event timestamp.
  final String? timestamp;

  /// Creates a [StreamEventSsePayload].
  const StreamEventSsePayload({
    required this.stream,
    required this.data,
    required this.workflowContext,
    required this.brokerSequence,
    this.metadata,
    this.timestamp,
  });

  /// Creates a [StreamEventSsePayload] from JSON.
  factory StreamEventSsePayload.fromJson(Map<String, dynamic> json) =>
      StreamEventSsePayload(
        stream: json['stream'] as String? ?? '',
        data: json['data'] as Map<String, dynamic>? ?? {},
        workflowContext: StreamEventWorkflowContext.fromJson(
          json['workflow_context'] as Map<String, dynamic>,
        ),
        brokerSequence: json['broker_sequence'] as int? ?? 0,
        metadata: json['metadata'] as Map<String, dynamic>?,
        timestamp: json['timestamp'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'stream': stream,
    'data': data,
    'workflow_context': workflowContext.toJson(),
    'broker_sequence': brokerSequence,
    if (metadata != null) 'metadata': metadata,
    if (timestamp != null) 'timestamp': timestamp,
  };

  /// Creates a copy with replaced values.
  StreamEventSsePayload copyWith({
    String? stream,
    Map<String, dynamic>? data,
    StreamEventWorkflowContext? workflowContext,
    int? brokerSequence,
    Object? metadata = unsetCopyWithValue,
    Object? timestamp = unsetCopyWithValue,
  }) {
    return StreamEventSsePayload(
      stream: stream ?? this.stream,
      data: data ?? this.data,
      workflowContext: workflowContext ?? this.workflowContext,
      brokerSequence: brokerSequence ?? this.brokerSequence,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      timestamp: timestamp == unsetCopyWithValue
          ? this.timestamp
          : timestamp as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StreamEventSsePayload) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(data, other.data)) return false;
    if (!mapsDeepEqual(metadata, other.metadata)) return false;
    return stream == other.stream &&
        workflowContext == other.workflowContext &&
        brokerSequence == other.brokerSequence &&
        timestamp == other.timestamp;
  }

  @override
  int get hashCode => Object.hash(
    stream,
    mapDeepHashCode(data),
    workflowContext,
    brokerSequence,
    mapDeepHashCode(metadata),
    timestamp,
  );

  @override
  String toString() =>
      'StreamEventSsePayload('
      'stream: $stream, '
      'data: ${data.length}, '
      'workflowContext: $workflowContext, '
      'brokerSequence: $brokerSequence, '
      'metadata: ${metadata?.length ?? 'null'}, '
      'timestamp: $timestamp'
      ')';
}
