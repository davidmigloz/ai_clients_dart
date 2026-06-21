import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A span captured by the observability system.
@immutable
class GetSpan {
  /// The `agent_description` value.
  final String agentDescription;

  /// The `agent_id` value.
  final String agentId;

  /// The `agent_name` value.
  final String agentName;

  /// The `agent_version` value.
  final String agentVersion;

  /// The `conversation_id` value.
  final String conversationId;

  /// The `customer_id` value.
  final String customerId;

  /// The `data_source_id` value.
  final String dataSourceId;

  /// The `duration_ns` value.
  final int durationNs;

  /// The `end_time` value.
  final String endTime;

  /// The `error_type` value.
  final String errorType;

  /// The `input_messages` value.
  final String inputMessages;

  /// The `operation_name` value.
  final String operationName;

  /// The `organization_id` value.
  final String organizationId;

  /// The `output_messages` value.
  final String outputMessages;

  /// The `output_type` value.
  final String outputType;

  /// The `parent_span_id` value.
  final String parentSpanId;

  /// The `prompt_name` value.
  final String promptName;

  /// The `provider_name` value.
  final String providerName;

  /// The `request_choice_count` value.
  final int requestChoiceCount;

  /// The `request_encoding_formats` value.
  final List<String> requestEncodingFormats;

  /// The `request_frequency_penalty` value.
  final double? requestFrequencyPenalty;

  /// The `request_max_tokens` value.
  final int requestMaxTokens;

  /// The `request_model` value.
  final String requestModel;

  /// The `request_presence_penalty` value.
  final double? requestPresencePenalty;

  /// The `request_seed` value.
  final int requestSeed;

  /// The `request_stop_sequences` value.
  final List<String> requestStopSequences;

  /// The `request_temperature` value.
  final double? requestTemperature;

  /// The `request_top_k` value.
  final double? requestTopK;

  /// The `request_top_p` value.
  final double? requestTopP;

  /// The `resource_attributes` value.
  final Map<String, dynamic> resourceAttributes;

  /// The `response_finish_reasons` value.
  final List<String> responseFinishReasons;

  /// The `response_id` value.
  final String responseId;

  /// The `response_model` value.
  final String responseModel;

  /// The `scope_name` value.
  final String scopeName;

  /// The `scope_version` value.
  final String scopeVersion;

  /// The `service_name` value.
  final String serviceName;

  /// The `span_attributes` value.
  final Map<String, dynamic> spanAttributes;

  /// The `span_id` value.
  final String spanId;

  /// The `span_kind` value.
  final String spanKind;

  /// The `span_name` value.
  final String spanName;

  /// The `start_time` value.
  final String startTime;

  /// The `status_code` value.
  final String statusCode;

  /// The `status_message` value.
  final String statusMessage;

  /// The `system_instructions` value.
  final String systemInstructions;

  /// The `tool_call_arguments` value.
  final String toolCallArguments;

  /// The `tool_call_id` value.
  final String toolCallId;

  /// The `tool_call_result` value.
  final String toolCallResult;

  /// The `tool_definitions` value.
  final String toolDefinitions;

  /// The `tool_name` value.
  final String toolName;

  /// The `tool_type` value.
  final String toolType;

  /// The `trace_id` value.
  final String traceId;

  /// The `trace_state` value.
  final String traceState;

  /// The `usage_cache_creation_input_tokens` value.
  final int usageCacheCreationInputTokens;

  /// The `usage_cache_read_input_tokens` value.
  final int usageCacheReadInputTokens;

  /// The `usage_input_tokens` value.
  final int usageInputTokens;

  /// The `usage_output_tokens` value.
  final int usageOutputTokens;

  /// The `user_id` value.
  final String userId;

  /// The `workflow_name` value.
  final String workflowName;

  /// The `workspace_id` value.
  final String workspaceId;

  /// Creates a [GetSpan].
  GetSpan({
    required this.agentDescription,
    required this.agentId,
    required this.agentName,
    required this.agentVersion,
    required this.conversationId,
    required this.customerId,
    required this.dataSourceId,
    required this.durationNs,
    required this.endTime,
    required this.errorType,
    required this.inputMessages,
    required this.operationName,
    required this.organizationId,
    required this.outputMessages,
    required this.outputType,
    required this.parentSpanId,
    required this.promptName,
    required this.providerName,
    required this.requestChoiceCount,
    required List<String> requestEncodingFormats,
    this.requestFrequencyPenalty,
    required this.requestMaxTokens,
    required this.requestModel,
    this.requestPresencePenalty,
    required this.requestSeed,
    required List<String> requestStopSequences,
    this.requestTemperature,
    this.requestTopK,
    this.requestTopP,
    required this.resourceAttributes,
    required List<String> responseFinishReasons,
    required this.responseId,
    required this.responseModel,
    required this.scopeName,
    required this.scopeVersion,
    required this.serviceName,
    required this.spanAttributes,
    required this.spanId,
    required this.spanKind,
    required this.spanName,
    required this.startTime,
    required this.statusCode,
    required this.statusMessage,
    required this.systemInstructions,
    required this.toolCallArguments,
    required this.toolCallId,
    required this.toolCallResult,
    required this.toolDefinitions,
    required this.toolName,
    required this.toolType,
    required this.traceId,
    required this.traceState,
    required this.usageCacheCreationInputTokens,
    required this.usageCacheReadInputTokens,
    required this.usageInputTokens,
    required this.usageOutputTokens,
    required this.userId,
    required this.workflowName,
    required this.workspaceId,
  }) : requestEncodingFormats = List.unmodifiable(requestEncodingFormats),
       requestStopSequences = List.unmodifiable(requestStopSequences),
       responseFinishReasons = List.unmodifiable(responseFinishReasons);

  /// Creates a [GetSpan] from JSON.
  factory GetSpan.fromJson(Map<String, dynamic> json) => GetSpan(
    agentDescription: json['agent_description'] as String? ?? '',
    agentId: json['agent_id'] as String? ?? '',
    agentName: json['agent_name'] as String? ?? '',
    agentVersion: json['agent_version'] as String? ?? '',
    conversationId: json['conversation_id'] as String? ?? '',
    customerId: json['customer_id'] as String? ?? '',
    dataSourceId: json['data_source_id'] as String? ?? '',
    durationNs: json['duration_ns'] as int? ?? 0,
    endTime: json['end_time'] as String? ?? '',
    errorType: json['error_type'] as String? ?? '',
    inputMessages: json['input_messages'] as String? ?? '',
    operationName: json['operation_name'] as String? ?? '',
    organizationId: json['organization_id'] as String? ?? '',
    outputMessages: json['output_messages'] as String? ?? '',
    outputType: json['output_type'] as String? ?? '',
    parentSpanId: json['parent_span_id'] as String? ?? '',
    promptName: json['prompt_name'] as String? ?? '',
    providerName: json['provider_name'] as String? ?? '',
    requestChoiceCount: json['request_choice_count'] as int? ?? 0,
    requestEncodingFormats:
        (json['request_encoding_formats'] as List?)?.cast<String>() ?? [],
    requestFrequencyPenalty: (json['request_frequency_penalty'] as num?)
        ?.toDouble(),
    requestMaxTokens: json['request_max_tokens'] as int? ?? 0,
    requestModel: json['request_model'] as String? ?? '',
    requestPresencePenalty: (json['request_presence_penalty'] as num?)
        ?.toDouble(),
    requestSeed: json['request_seed'] as int? ?? 0,
    requestStopSequences:
        (json['request_stop_sequences'] as List?)?.cast<String>() ?? [],
    requestTemperature: (json['request_temperature'] as num?)?.toDouble(),
    requestTopK: (json['request_top_k'] as num?)?.toDouble(),
    requestTopP: (json['request_top_p'] as num?)?.toDouble(),
    resourceAttributes:
        json['resource_attributes'] as Map<String, dynamic>? ?? const {},
    responseFinishReasons:
        (json['response_finish_reasons'] as List?)?.cast<String>() ?? [],
    responseId: json['response_id'] as String? ?? '',
    responseModel: json['response_model'] as String? ?? '',
    scopeName: json['scope_name'] as String? ?? '',
    scopeVersion: json['scope_version'] as String? ?? '',
    serviceName: json['service_name'] as String? ?? '',
    spanAttributes:
        json['span_attributes'] as Map<String, dynamic>? ?? const {},
    spanId: json['span_id'] as String? ?? '',
    spanKind: json['span_kind'] as String? ?? '',
    spanName: json['span_name'] as String? ?? '',
    startTime: json['start_time'] as String? ?? '',
    statusCode: json['status_code'] as String? ?? '',
    statusMessage: json['status_message'] as String? ?? '',
    systemInstructions: json['system_instructions'] as String? ?? '',
    toolCallArguments: json['tool_call_arguments'] as String? ?? '',
    toolCallId: json['tool_call_id'] as String? ?? '',
    toolCallResult: json['tool_call_result'] as String? ?? '',
    toolDefinitions: json['tool_definitions'] as String? ?? '',
    toolName: json['tool_name'] as String? ?? '',
    toolType: json['tool_type'] as String? ?? '',
    traceId: json['trace_id'] as String? ?? '',
    traceState: json['trace_state'] as String? ?? '',
    usageCacheCreationInputTokens:
        json['usage_cache_creation_input_tokens'] as int? ?? 0,
    usageCacheReadInputTokens:
        json['usage_cache_read_input_tokens'] as int? ?? 0,
    usageInputTokens: json['usage_input_tokens'] as int? ?? 0,
    usageOutputTokens: json['usage_output_tokens'] as int? ?? 0,
    userId: json['user_id'] as String? ?? '',
    workflowName: json['workflow_name'] as String? ?? '',
    workspaceId: json['workspace_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent_description': agentDescription,
    'agent_id': agentId,
    'agent_name': agentName,
    'agent_version': agentVersion,
    'conversation_id': conversationId,
    'customer_id': customerId,
    'data_source_id': dataSourceId,
    'duration_ns': durationNs,
    'end_time': endTime,
    'error_type': errorType,
    'input_messages': inputMessages,
    'operation_name': operationName,
    'organization_id': organizationId,
    'output_messages': outputMessages,
    'output_type': outputType,
    'parent_span_id': parentSpanId,
    'prompt_name': promptName,
    'provider_name': providerName,
    'request_choice_count': requestChoiceCount,
    'request_encoding_formats': requestEncodingFormats,
    if (requestFrequencyPenalty != null)
      'request_frequency_penalty': requestFrequencyPenalty,
    'request_max_tokens': requestMaxTokens,
    'request_model': requestModel,
    if (requestPresencePenalty != null)
      'request_presence_penalty': requestPresencePenalty,
    'request_seed': requestSeed,
    'request_stop_sequences': requestStopSequences,
    if (requestTemperature != null) 'request_temperature': requestTemperature,
    if (requestTopK != null) 'request_top_k': requestTopK,
    if (requestTopP != null) 'request_top_p': requestTopP,
    'resource_attributes': resourceAttributes,
    'response_finish_reasons': responseFinishReasons,
    'response_id': responseId,
    'response_model': responseModel,
    'scope_name': scopeName,
    'scope_version': scopeVersion,
    'service_name': serviceName,
    'span_attributes': spanAttributes,
    'span_id': spanId,
    'span_kind': spanKind,
    'span_name': spanName,
    'start_time': startTime,
    'status_code': statusCode,
    'status_message': statusMessage,
    'system_instructions': systemInstructions,
    'tool_call_arguments': toolCallArguments,
    'tool_call_id': toolCallId,
    'tool_call_result': toolCallResult,
    'tool_definitions': toolDefinitions,
    'tool_name': toolName,
    'tool_type': toolType,
    'trace_id': traceId,
    'trace_state': traceState,
    'usage_cache_creation_input_tokens': usageCacheCreationInputTokens,
    'usage_cache_read_input_tokens': usageCacheReadInputTokens,
    'usage_input_tokens': usageInputTokens,
    'usage_output_tokens': usageOutputTokens,
    'user_id': userId,
    'workflow_name': workflowName,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  GetSpan copyWith({
    String? agentDescription,
    String? agentId,
    String? agentName,
    String? agentVersion,
    String? conversationId,
    String? customerId,
    String? dataSourceId,
    int? durationNs,
    String? endTime,
    String? errorType,
    String? inputMessages,
    String? operationName,
    String? organizationId,
    String? outputMessages,
    String? outputType,
    String? parentSpanId,
    String? promptName,
    String? providerName,
    int? requestChoiceCount,
    List<String>? requestEncodingFormats,
    Object? requestFrequencyPenalty = unsetCopyWithValue,
    int? requestMaxTokens,
    String? requestModel,
    Object? requestPresencePenalty = unsetCopyWithValue,
    int? requestSeed,
    List<String>? requestStopSequences,
    Object? requestTemperature = unsetCopyWithValue,
    Object? requestTopK = unsetCopyWithValue,
    Object? requestTopP = unsetCopyWithValue,
    Map<String, dynamic>? resourceAttributes,
    List<String>? responseFinishReasons,
    String? responseId,
    String? responseModel,
    String? scopeName,
    String? scopeVersion,
    String? serviceName,
    Map<String, dynamic>? spanAttributes,
    String? spanId,
    String? spanKind,
    String? spanName,
    String? startTime,
    String? statusCode,
    String? statusMessage,
    String? systemInstructions,
    String? toolCallArguments,
    String? toolCallId,
    String? toolCallResult,
    String? toolDefinitions,
    String? toolName,
    String? toolType,
    String? traceId,
    String? traceState,
    int? usageCacheCreationInputTokens,
    int? usageCacheReadInputTokens,
    int? usageInputTokens,
    int? usageOutputTokens,
    String? userId,
    String? workflowName,
    String? workspaceId,
  }) {
    return GetSpan(
      agentDescription: agentDescription ?? this.agentDescription,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentVersion: agentVersion ?? this.agentVersion,
      conversationId: conversationId ?? this.conversationId,
      customerId: customerId ?? this.customerId,
      dataSourceId: dataSourceId ?? this.dataSourceId,
      durationNs: durationNs ?? this.durationNs,
      endTime: endTime ?? this.endTime,
      errorType: errorType ?? this.errorType,
      inputMessages: inputMessages ?? this.inputMessages,
      operationName: operationName ?? this.operationName,
      organizationId: organizationId ?? this.organizationId,
      outputMessages: outputMessages ?? this.outputMessages,
      outputType: outputType ?? this.outputType,
      parentSpanId: parentSpanId ?? this.parentSpanId,
      promptName: promptName ?? this.promptName,
      providerName: providerName ?? this.providerName,
      requestChoiceCount: requestChoiceCount ?? this.requestChoiceCount,
      requestEncodingFormats:
          requestEncodingFormats ?? this.requestEncodingFormats,
      requestFrequencyPenalty: requestFrequencyPenalty == unsetCopyWithValue
          ? this.requestFrequencyPenalty
          : requestFrequencyPenalty as double?,
      requestMaxTokens: requestMaxTokens ?? this.requestMaxTokens,
      requestModel: requestModel ?? this.requestModel,
      requestPresencePenalty: requestPresencePenalty == unsetCopyWithValue
          ? this.requestPresencePenalty
          : requestPresencePenalty as double?,
      requestSeed: requestSeed ?? this.requestSeed,
      requestStopSequences: requestStopSequences ?? this.requestStopSequences,
      requestTemperature: requestTemperature == unsetCopyWithValue
          ? this.requestTemperature
          : requestTemperature as double?,
      requestTopK: requestTopK == unsetCopyWithValue
          ? this.requestTopK
          : requestTopK as double?,
      requestTopP: requestTopP == unsetCopyWithValue
          ? this.requestTopP
          : requestTopP as double?,
      resourceAttributes: resourceAttributes ?? this.resourceAttributes,
      responseFinishReasons:
          responseFinishReasons ?? this.responseFinishReasons,
      responseId: responseId ?? this.responseId,
      responseModel: responseModel ?? this.responseModel,
      scopeName: scopeName ?? this.scopeName,
      scopeVersion: scopeVersion ?? this.scopeVersion,
      serviceName: serviceName ?? this.serviceName,
      spanAttributes: spanAttributes ?? this.spanAttributes,
      spanId: spanId ?? this.spanId,
      spanKind: spanKind ?? this.spanKind,
      spanName: spanName ?? this.spanName,
      startTime: startTime ?? this.startTime,
      statusCode: statusCode ?? this.statusCode,
      statusMessage: statusMessage ?? this.statusMessage,
      systemInstructions: systemInstructions ?? this.systemInstructions,
      toolCallArguments: toolCallArguments ?? this.toolCallArguments,
      toolCallId: toolCallId ?? this.toolCallId,
      toolCallResult: toolCallResult ?? this.toolCallResult,
      toolDefinitions: toolDefinitions ?? this.toolDefinitions,
      toolName: toolName ?? this.toolName,
      toolType: toolType ?? this.toolType,
      traceId: traceId ?? this.traceId,
      traceState: traceState ?? this.traceState,
      usageCacheCreationInputTokens:
          usageCacheCreationInputTokens ?? this.usageCacheCreationInputTokens,
      usageCacheReadInputTokens:
          usageCacheReadInputTokens ?? this.usageCacheReadInputTokens,
      usageInputTokens: usageInputTokens ?? this.usageInputTokens,
      usageOutputTokens: usageOutputTokens ?? this.usageOutputTokens,
      userId: userId ?? this.userId,
      workflowName: workflowName ?? this.workflowName,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpan) return false;
    if (runtimeType != other.runtimeType) return false;
    return agentDescription == other.agentDescription &&
        agentId == other.agentId &&
        agentName == other.agentName &&
        agentVersion == other.agentVersion &&
        conversationId == other.conversationId &&
        customerId == other.customerId &&
        dataSourceId == other.dataSourceId &&
        durationNs == other.durationNs &&
        endTime == other.endTime &&
        errorType == other.errorType &&
        inputMessages == other.inputMessages &&
        operationName == other.operationName &&
        organizationId == other.organizationId &&
        outputMessages == other.outputMessages &&
        outputType == other.outputType &&
        parentSpanId == other.parentSpanId &&
        promptName == other.promptName &&
        providerName == other.providerName &&
        requestChoiceCount == other.requestChoiceCount &&
        listsEqual(requestEncodingFormats, other.requestEncodingFormats) &&
        requestFrequencyPenalty == other.requestFrequencyPenalty &&
        requestMaxTokens == other.requestMaxTokens &&
        requestModel == other.requestModel &&
        requestPresencePenalty == other.requestPresencePenalty &&
        requestSeed == other.requestSeed &&
        listsEqual(requestStopSequences, other.requestStopSequences) &&
        requestTemperature == other.requestTemperature &&
        requestTopK == other.requestTopK &&
        requestTopP == other.requestTopP &&
        mapsDeepEqual(resourceAttributes, other.resourceAttributes) &&
        listsEqual(responseFinishReasons, other.responseFinishReasons) &&
        responseId == other.responseId &&
        responseModel == other.responseModel &&
        scopeName == other.scopeName &&
        scopeVersion == other.scopeVersion &&
        serviceName == other.serviceName &&
        mapsDeepEqual(spanAttributes, other.spanAttributes) &&
        spanId == other.spanId &&
        spanKind == other.spanKind &&
        spanName == other.spanName &&
        startTime == other.startTime &&
        statusCode == other.statusCode &&
        statusMessage == other.statusMessage &&
        systemInstructions == other.systemInstructions &&
        toolCallArguments == other.toolCallArguments &&
        toolCallId == other.toolCallId &&
        toolCallResult == other.toolCallResult &&
        toolDefinitions == other.toolDefinitions &&
        toolName == other.toolName &&
        toolType == other.toolType &&
        traceId == other.traceId &&
        traceState == other.traceState &&
        usageCacheCreationInputTokens == other.usageCacheCreationInputTokens &&
        usageCacheReadInputTokens == other.usageCacheReadInputTokens &&
        usageInputTokens == other.usageInputTokens &&
        usageOutputTokens == other.usageOutputTokens &&
        userId == other.userId &&
        workflowName == other.workflowName &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hashAll([
    agentDescription,
    agentId,
    agentName,
    agentVersion,
    conversationId,
    customerId,
    dataSourceId,
    durationNs,
    endTime,
    errorType,
    inputMessages,
    operationName,
    organizationId,
    outputMessages,
    outputType,
    parentSpanId,
    promptName,
    providerName,
    requestChoiceCount,
    listHash(requestEncodingFormats),
    requestFrequencyPenalty,
    requestMaxTokens,
    requestModel,
    requestPresencePenalty,
    requestSeed,
    listHash(requestStopSequences),
    requestTemperature,
    requestTopK,
    requestTopP,
    mapDeepHashCode(resourceAttributes),
    listHash(responseFinishReasons),
    responseId,
    responseModel,
    scopeName,
    scopeVersion,
    serviceName,
    mapDeepHashCode(spanAttributes),
    spanId,
    spanKind,
    spanName,
    startTime,
    statusCode,
    statusMessage,
    systemInstructions,
    toolCallArguments,
    toolCallId,
    toolCallResult,
    toolDefinitions,
    toolName,
    toolType,
    traceId,
    traceState,
    usageCacheCreationInputTokens,
    usageCacheReadInputTokens,
    usageInputTokens,
    usageOutputTokens,
    userId,
    workflowName,
    workspaceId,
  ]);

  @override
  String toString() =>
      'GetSpan(agentDescription: $agentDescription, agentId: $agentId, '
      'agentName: $agentName, agentVersion: $agentVersion, '
      'conversationId: $conversationId, customerId: $customerId, '
      'dataSourceId: $dataSourceId, durationNs: $durationNs, '
      'endTime: $endTime, errorType: $errorType, '
      'inputMessages: $inputMessages, operationName: $operationName, '
      'organizationId: $organizationId, outputMessages: $outputMessages, '
      'outputType: $outputType, parentSpanId: $parentSpanId, '
      'promptName: $promptName, providerName: $providerName, '
      'requestChoiceCount: $requestChoiceCount, '
      'requestEncodingFormats: ${requestEncodingFormats.length} items, '
      'requestFrequencyPenalty: $requestFrequencyPenalty, '
      'requestMaxTokens: $requestMaxTokens, requestModel: $requestModel, '
      'requestPresencePenalty: $requestPresencePenalty, '
      'requestSeed: $requestSeed, '
      'requestStopSequences: ${requestStopSequences.length} items, '
      'requestTemperature: $requestTemperature, '
      'requestTopK: $requestTopK, requestTopP: $requestTopP, '
      'resourceAttributes: ${resourceAttributes.length} keys, '
      'responseFinishReasons: ${responseFinishReasons.length} items, '
      'responseId: $responseId, responseModel: $responseModel, '
      'scopeName: $scopeName, scopeVersion: $scopeVersion, '
      'serviceName: $serviceName, '
      'spanAttributes: ${spanAttributes.length} keys, spanId: $spanId, '
      'spanKind: $spanKind, spanName: $spanName, startTime: $startTime, '
      'statusCode: $statusCode, statusMessage: $statusMessage, '
      'systemInstructions: $systemInstructions, '
      'toolCallArguments: $toolCallArguments, toolCallId: $toolCallId, '
      'toolCallResult: $toolCallResult, '
      'toolDefinitions: $toolDefinitions, toolName: $toolName, '
      'toolType: $toolType, traceId: $traceId, traceState: $traceState, '
      'usageCacheCreationInputTokens: $usageCacheCreationInputTokens, '
      'usageCacheReadInputTokens: $usageCacheReadInputTokens, '
      'usageInputTokens: $usageInputTokens, '
      'usageOutputTokens: $usageOutputTokens, userId: $userId, '
      'workflowName: $workflowName, workspaceId: $workspaceId)';
}
