import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// An evaluation result for a span.
@immutable
class GetSpanEvaluation {
  /// The `conversation_id` value.
  final String conversationId;

  /// The `customer_id` value.
  final String customerId;

  /// The `evaluation_name` value.
  final String evaluationName;

  /// The `explanation` value.
  final String explanation;

  /// The `metadata` value.
  final Map<String, dynamic> metadata;

  /// The `organization_id` value.
  final String organizationId;

  /// The `response_id` value.
  final String responseId;

  /// The `score_label` value.
  final String scoreLabel;

  /// The `score_value` value.
  final double scoreValue;

  /// The `span_id` value.
  final String spanId;

  /// The `timestamp` value.
  final String timestamp;

  /// The `trace_id` value.
  final String traceId;

  /// The `user_id` value.
  final String userId;

  /// The `workspace_id` value.
  final String workspaceId;

  /// Creates a [GetSpanEvaluation].
  const GetSpanEvaluation({
    required this.conversationId,
    required this.customerId,
    required this.evaluationName,
    required this.explanation,
    required this.metadata,
    required this.organizationId,
    required this.responseId,
    required this.scoreLabel,
    required this.scoreValue,
    required this.spanId,
    required this.timestamp,
    required this.traceId,
    required this.userId,
    required this.workspaceId,
  });

  /// Creates a [GetSpanEvaluation] from JSON.
  factory GetSpanEvaluation.fromJson(Map<String, dynamic> json) =>
      GetSpanEvaluation(
        conversationId: json['conversation_id'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        evaluationName: json['evaluation_name'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
        organizationId: json['organization_id'] as String? ?? '',
        responseId: json['response_id'] as String? ?? '',
        scoreLabel: json['score_label'] as String? ?? '',
        scoreValue: (json['score_value'] as num?)?.toDouble() ?? 0,
        spanId: json['span_id'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        traceId: json['trace_id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        workspaceId: json['workspace_id'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'conversation_id': conversationId,
    'customer_id': customerId,
    'evaluation_name': evaluationName,
    'explanation': explanation,
    'metadata': metadata,
    'organization_id': organizationId,
    'response_id': responseId,
    'score_label': scoreLabel,
    'score_value': scoreValue,
    'span_id': spanId,
    'timestamp': timestamp,
    'trace_id': traceId,
    'user_id': userId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  GetSpanEvaluation copyWith({
    String? conversationId,
    String? customerId,
    String? evaluationName,
    String? explanation,
    Map<String, dynamic>? metadata,
    String? organizationId,
    String? responseId,
    String? scoreLabel,
    double? scoreValue,
    String? spanId,
    String? timestamp,
    String? traceId,
    String? userId,
    String? workspaceId,
  }) {
    return GetSpanEvaluation(
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
      evaluationName: evaluationName ?? this.evaluationName,
      explanation: explanation ?? this.explanation,
      metadata: metadata ?? this.metadata,
      organizationId: organizationId ?? this.organizationId,
      responseId: responseId ?? this.responseId,
      scoreLabel: scoreLabel ?? this.scoreLabel,
      scoreValue: scoreValue ?? this.scoreValue,
      spanId: spanId ?? this.spanId,
      timestamp: timestamp ?? this.timestamp,
      traceId: traceId ?? this.traceId,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpanEvaluation) return false;
    if (runtimeType != other.runtimeType) return false;
    return conversationId == other.conversationId &&
        customerId == other.customerId &&
        evaluationName == other.evaluationName &&
        explanation == other.explanation &&
        mapsDeepEqual(metadata, other.metadata) &&
        organizationId == other.organizationId &&
        responseId == other.responseId &&
        scoreLabel == other.scoreLabel &&
        scoreValue == other.scoreValue &&
        spanId == other.spanId &&
        timestamp == other.timestamp &&
        traceId == other.traceId &&
        userId == other.userId &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hashAll([
    conversationId,
    customerId,
    evaluationName,
    explanation,
    mapDeepHashCode(metadata),
    organizationId,
    responseId,
    scoreLabel,
    scoreValue,
    spanId,
    timestamp,
    traceId,
    userId,
    workspaceId,
  ]);

  @override
  String toString() =>
      'GetSpanEvaluation(conversationId: $conversationId, customerId: $customerId, '
      'evaluationName: $evaluationName, explanation: $explanation, '
      'metadata: ${metadata.length} keys, '
      'organizationId: $organizationId, responseId: $responseId, '
      'scoreLabel: $scoreLabel, scoreValue: $scoreValue, '
      'spanId: $spanId, timestamp: $timestamp, traceId: $traceId, '
      'userId: $userId, workspaceId: $workspaceId)';
}
