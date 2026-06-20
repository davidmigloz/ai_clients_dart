import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A trace captured by the observability system.
@immutable
class GetTrace {
  /// The `agent_id` value.
  final String agentId;

  /// The `agent_name` value.
  final String agentName;

  /// The `cache_creation_input_tokens` value.
  final int cacheCreationInputTokens;

  /// The `cache_read_input_tokens` value.
  final int cacheReadInputTokens;

  /// The `conversation_id` value.
  final String conversationId;

  /// The `customer_id` value.
  final String customerId;

  /// The `duration_ns` value.
  final int durationNs;

  /// The `end_time` value.
  final String endTime;

  /// The `environment` value.
  final String environment;

  /// The `error_count` value.
  final int errorCount;

  /// The `evaluation_count` value.
  final int evaluationCount;

  /// The `first_turn_last_input_message` value.
  final String firstTurnLastInputMessage;

  /// The `first_turn_last_output_message` value.
  final String firstTurnLastOutputMessage;

  /// The `gen_ai_span_count` value.
  final int genAiSpanCount;

  /// The `input_tokens` value.
  final int inputTokens;

  /// The `last_turn_last_input_message` value.
  final String lastTurnLastInputMessage;

  /// The `last_turn_last_output_message` value.
  final String lastTurnLastOutputMessage;

  /// The `llm_call_count` value.
  final int llmCallCount;

  /// The `models_used` value.
  final List<String> modelsUsed;

  /// The `organization_id` value.
  final String organizationId;

  /// The `output_tokens` value.
  final int outputTokens;

  /// The `retrieval_count` value.
  final int retrievalCount;

  /// The `root_span_id` value.
  final String rootSpanId;

  /// The `root_span_name` value.
  final String rootSpanName;

  /// The `service_name` value.
  final String serviceName;

  /// The `span_count` value.
  final int spanCount;

  /// The `start_time` value.
  final String startTime;

  /// The `status_code` value.
  final String statusCode;

  /// The `tool_call_count` value.
  final int toolCallCount;

  /// The `tools_used` value.
  final List<String> toolsUsed;

  /// The `trace_id` value.
  final String traceId;

  /// The `user_id` value.
  final String userId;

  /// The `workflow_name` value.
  final String workflowName;

  /// The `workspace_id` value.
  final String workspaceId;

  /// Creates a [GetTrace].
  GetTrace({
    required this.agentId,
    required this.agentName,
    required this.cacheCreationInputTokens,
    required this.cacheReadInputTokens,
    required this.conversationId,
    required this.customerId,
    required this.durationNs,
    required this.endTime,
    required this.environment,
    required this.errorCount,
    required this.evaluationCount,
    required this.firstTurnLastInputMessage,
    required this.firstTurnLastOutputMessage,
    required this.genAiSpanCount,
    required this.inputTokens,
    required this.lastTurnLastInputMessage,
    required this.lastTurnLastOutputMessage,
    required this.llmCallCount,
    required List<String> modelsUsed,
    required this.organizationId,
    required this.outputTokens,
    required this.retrievalCount,
    required this.rootSpanId,
    required this.rootSpanName,
    required this.serviceName,
    required this.spanCount,
    required this.startTime,
    required this.statusCode,
    required this.toolCallCount,
    required List<String> toolsUsed,
    required this.traceId,
    required this.userId,
    required this.workflowName,
    required this.workspaceId,
  }) : modelsUsed = List.unmodifiable(modelsUsed),
       toolsUsed = List.unmodifiable(toolsUsed);

  /// Creates a [GetTrace] from JSON.
  factory GetTrace.fromJson(Map<String, dynamic> json) => GetTrace(
    agentId: json['agent_id'] as String? ?? '',
    agentName: json['agent_name'] as String? ?? '',
    cacheCreationInputTokens: json['cache_creation_input_tokens'] as int? ?? 0,
    cacheReadInputTokens: json['cache_read_input_tokens'] as int? ?? 0,
    conversationId: json['conversation_id'] as String? ?? '',
    customerId: json['customer_id'] as String? ?? '',
    durationNs: json['duration_ns'] as int? ?? 0,
    endTime: json['end_time'] as String? ?? '',
    environment: json['environment'] as String? ?? '',
    errorCount: json['error_count'] as int? ?? 0,
    evaluationCount: json['evaluation_count'] as int? ?? 0,
    firstTurnLastInputMessage:
        json['first_turn_last_input_message'] as String? ?? '',
    firstTurnLastOutputMessage:
        json['first_turn_last_output_message'] as String? ?? '',
    genAiSpanCount: json['gen_ai_span_count'] as int? ?? 0,
    inputTokens: json['input_tokens'] as int? ?? 0,
    lastTurnLastInputMessage:
        json['last_turn_last_input_message'] as String? ?? '',
    lastTurnLastOutputMessage:
        json['last_turn_last_output_message'] as String? ?? '',
    llmCallCount: json['llm_call_count'] as int? ?? 0,
    modelsUsed: (json['models_used'] as List?)?.cast<String>() ?? [],
    organizationId: json['organization_id'] as String? ?? '',
    outputTokens: json['output_tokens'] as int? ?? 0,
    retrievalCount: json['retrieval_count'] as int? ?? 0,
    rootSpanId: json['root_span_id'] as String? ?? '',
    rootSpanName: json['root_span_name'] as String? ?? '',
    serviceName: json['service_name'] as String? ?? '',
    spanCount: json['span_count'] as int? ?? 0,
    startTime: json['start_time'] as String? ?? '',
    statusCode: json['status_code'] as String? ?? '',
    toolCallCount: json['tool_call_count'] as int? ?? 0,
    toolsUsed: (json['tools_used'] as List?)?.cast<String>() ?? [],
    traceId: json['trace_id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    workflowName: json['workflow_name'] as String? ?? '',
    workspaceId: json['workspace_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'agent_name': agentName,
    'cache_creation_input_tokens': cacheCreationInputTokens,
    'cache_read_input_tokens': cacheReadInputTokens,
    'conversation_id': conversationId,
    'customer_id': customerId,
    'duration_ns': durationNs,
    'end_time': endTime,
    'environment': environment,
    'error_count': errorCount,
    'evaluation_count': evaluationCount,
    'first_turn_last_input_message': firstTurnLastInputMessage,
    'first_turn_last_output_message': firstTurnLastOutputMessage,
    'gen_ai_span_count': genAiSpanCount,
    'input_tokens': inputTokens,
    'last_turn_last_input_message': lastTurnLastInputMessage,
    'last_turn_last_output_message': lastTurnLastOutputMessage,
    'llm_call_count': llmCallCount,
    'models_used': modelsUsed,
    'organization_id': organizationId,
    'output_tokens': outputTokens,
    'retrieval_count': retrievalCount,
    'root_span_id': rootSpanId,
    'root_span_name': rootSpanName,
    'service_name': serviceName,
    'span_count': spanCount,
    'start_time': startTime,
    'status_code': statusCode,
    'tool_call_count': toolCallCount,
    'tools_used': toolsUsed,
    'trace_id': traceId,
    'user_id': userId,
    'workflow_name': workflowName,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  GetTrace copyWith({
    String? agentId,
    String? agentName,
    int? cacheCreationInputTokens,
    int? cacheReadInputTokens,
    String? conversationId,
    String? customerId,
    int? durationNs,
    String? endTime,
    String? environment,
    int? errorCount,
    int? evaluationCount,
    String? firstTurnLastInputMessage,
    String? firstTurnLastOutputMessage,
    int? genAiSpanCount,
    int? inputTokens,
    String? lastTurnLastInputMessage,
    String? lastTurnLastOutputMessage,
    int? llmCallCount,
    List<String>? modelsUsed,
    String? organizationId,
    int? outputTokens,
    int? retrievalCount,
    String? rootSpanId,
    String? rootSpanName,
    String? serviceName,
    int? spanCount,
    String? startTime,
    String? statusCode,
    int? toolCallCount,
    List<String>? toolsUsed,
    String? traceId,
    String? userId,
    String? workflowName,
    String? workspaceId,
  }) {
    return GetTrace(
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      cacheCreationInputTokens:
          cacheCreationInputTokens ?? this.cacheCreationInputTokens,
      cacheReadInputTokens: cacheReadInputTokens ?? this.cacheReadInputTokens,
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
      durationNs: durationNs ?? this.durationNs,
      endTime: endTime ?? this.endTime,
      environment: environment ?? this.environment,
      errorCount: errorCount ?? this.errorCount,
      evaluationCount: evaluationCount ?? this.evaluationCount,
      firstTurnLastInputMessage:
          firstTurnLastInputMessage ?? this.firstTurnLastInputMessage,
      firstTurnLastOutputMessage:
          firstTurnLastOutputMessage ?? this.firstTurnLastOutputMessage,
      genAiSpanCount: genAiSpanCount ?? this.genAiSpanCount,
      inputTokens: inputTokens ?? this.inputTokens,
      lastTurnLastInputMessage:
          lastTurnLastInputMessage ?? this.lastTurnLastInputMessage,
      lastTurnLastOutputMessage:
          lastTurnLastOutputMessage ?? this.lastTurnLastOutputMessage,
      llmCallCount: llmCallCount ?? this.llmCallCount,
      modelsUsed: modelsUsed ?? this.modelsUsed,
      organizationId: organizationId ?? this.organizationId,
      outputTokens: outputTokens ?? this.outputTokens,
      retrievalCount: retrievalCount ?? this.retrievalCount,
      rootSpanId: rootSpanId ?? this.rootSpanId,
      rootSpanName: rootSpanName ?? this.rootSpanName,
      serviceName: serviceName ?? this.serviceName,
      spanCount: spanCount ?? this.spanCount,
      startTime: startTime ?? this.startTime,
      statusCode: statusCode ?? this.statusCode,
      toolCallCount: toolCallCount ?? this.toolCallCount,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      traceId: traceId ?? this.traceId,
      userId: userId ?? this.userId,
      workflowName: workflowName ?? this.workflowName,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetTrace) return false;
    if (runtimeType != other.runtimeType) return false;
    return agentId == other.agentId &&
        agentName == other.agentName &&
        cacheCreationInputTokens == other.cacheCreationInputTokens &&
        cacheReadInputTokens == other.cacheReadInputTokens &&
        conversationId == other.conversationId &&
        customerId == other.customerId &&
        durationNs == other.durationNs &&
        endTime == other.endTime &&
        environment == other.environment &&
        errorCount == other.errorCount &&
        evaluationCount == other.evaluationCount &&
        firstTurnLastInputMessage == other.firstTurnLastInputMessage &&
        firstTurnLastOutputMessage == other.firstTurnLastOutputMessage &&
        genAiSpanCount == other.genAiSpanCount &&
        inputTokens == other.inputTokens &&
        lastTurnLastInputMessage == other.lastTurnLastInputMessage &&
        lastTurnLastOutputMessage == other.lastTurnLastOutputMessage &&
        llmCallCount == other.llmCallCount &&
        listsEqual(modelsUsed, other.modelsUsed) &&
        organizationId == other.organizationId &&
        outputTokens == other.outputTokens &&
        retrievalCount == other.retrievalCount &&
        rootSpanId == other.rootSpanId &&
        rootSpanName == other.rootSpanName &&
        serviceName == other.serviceName &&
        spanCount == other.spanCount &&
        startTime == other.startTime &&
        statusCode == other.statusCode &&
        toolCallCount == other.toolCallCount &&
        listsEqual(toolsUsed, other.toolsUsed) &&
        traceId == other.traceId &&
        userId == other.userId &&
        workflowName == other.workflowName &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hashAll([
    agentId,
    agentName,
    cacheCreationInputTokens,
    cacheReadInputTokens,
    conversationId,
    customerId,
    durationNs,
    endTime,
    environment,
    errorCount,
    evaluationCount,
    firstTurnLastInputMessage,
    firstTurnLastOutputMessage,
    genAiSpanCount,
    inputTokens,
    lastTurnLastInputMessage,
    lastTurnLastOutputMessage,
    llmCallCount,
    listHash(modelsUsed),
    organizationId,
    outputTokens,
    retrievalCount,
    rootSpanId,
    rootSpanName,
    serviceName,
    spanCount,
    startTime,
    statusCode,
    toolCallCount,
    listHash(toolsUsed),
    traceId,
    userId,
    workflowName,
    workspaceId,
  ]);

  @override
  String toString() =>
      'GetTrace(agentId: $agentId, agentName: $agentName, '
      'cacheCreationInputTokens: $cacheCreationInputTokens, '
      'cacheReadInputTokens: $cacheReadInputTokens, '
      'conversationId: $conversationId, customerId: $customerId, '
      'durationNs: $durationNs, endTime: $endTime, '
      'environment: $environment, errorCount: $errorCount, '
      'evaluationCount: $evaluationCount, '
      'firstTurnLastInputMessage: $firstTurnLastInputMessage, '
      'firstTurnLastOutputMessage: $firstTurnLastOutputMessage, '
      'genAiSpanCount: $genAiSpanCount, inputTokens: $inputTokens, '
      'lastTurnLastInputMessage: $lastTurnLastInputMessage, '
      'lastTurnLastOutputMessage: $lastTurnLastOutputMessage, '
      'llmCallCount: $llmCallCount, '
      'modelsUsed: ${modelsUsed.length} items, '
      'organizationId: $organizationId, outputTokens: $outputTokens, '
      'retrievalCount: $retrievalCount, rootSpanId: $rootSpanId, '
      'rootSpanName: $rootSpanName, serviceName: $serviceName, '
      'spanCount: $spanCount, startTime: $startTime, '
      'statusCode: $statusCode, toolCallCount: $toolCallCount, '
      'toolsUsed: ${toolsUsed.length} items, traceId: $traceId, '
      'userId: $userId, workflowName: $workflowName, '
      'workspaceId: $workspaceId)';
}
