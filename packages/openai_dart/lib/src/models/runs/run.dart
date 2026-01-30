import 'package:meta/meta.dart';

import '../assistants/assistant_tool.dart';
import '../common/response_format.dart';
import '../common/usage.dart';
import '../tools/tool_choice.dart';

/// Parses response_format which can be either a string (like "auto") or an object.
ResponseFormat? _parseResponseFormat(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    // API returns "auto" as a string - treat as text format
    return const TextResponseFormat();
  }
  if (value is Map<String, dynamic>) {
    return ResponseFormat.fromJson(value);
  }
  return null;
}

/// A run representing the execution of an assistant on a thread.
///
/// Runs process the messages in a thread and may invoke tools.
///
/// ## Example
///
/// ```dart
/// final run = await client.threads.runs.create(
///   threadId: thread.id,
///   assistantId: assistant.id,
/// );
///
/// // Poll until complete
/// while (run.status != RunStatus.completed) {
///   await Future.delayed(Duration(seconds: 1));
///   run = await client.threads.runs.retrieve(thread.id, run.id);
/// }
/// ```
@immutable
class Run {
  /// Creates a [Run].
  const Run({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.threadId,
    required this.assistantId,
    required this.status,
    this.requiredAction,
    this.lastError,
    this.expiresAt,
    this.startedAt,
    this.cancelledAt,
    this.failedAt,
    this.completedAt,
    this.incompleteDetails,
    required this.model,
    this.instructions,
    required this.tools,
    required this.metadata,
    this.usage,
    this.temperature,
    this.topP,
    this.maxPromptTokens,
    this.maxCompletionTokens,
    this.truncationStrategy,
    this.toolChoice,
    this.parallelToolCalls,
    this.responseFormat,
  });

  /// Creates a [Run] from JSON.
  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      threadId: json['thread_id'] as String,
      assistantId: json['assistant_id'] as String,
      status: RunStatus.fromJson(json['status'] as String),
      requiredAction: json['required_action'] != null
          ? RequiredAction.fromJson(
              json['required_action'] as Map<String, dynamic>,
            )
          : null,
      lastError: json['last_error'] != null
          ? RunError.fromJson(json['last_error'] as Map<String, dynamic>)
          : null,
      expiresAt: json['expires_at'] as int?,
      startedAt: json['started_at'] as int?,
      cancelledAt: json['cancelled_at'] as int?,
      failedAt: json['failed_at'] as int?,
      completedAt: json['completed_at'] as int?,
      incompleteDetails: json['incomplete_details'] != null
          ? RunIncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            )
          : null,
      model: json['model'] as String,
      instructions: json['instructions'] as String?,
      tools: (json['tools'] as List<dynamic>)
          .map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      maxPromptTokens: json['max_prompt_tokens'] as int?,
      maxCompletionTokens: json['max_completion_tokens'] as int?,
      truncationStrategy: json['truncation_strategy'] != null
          ? TruncationStrategy.fromJson(
              json['truncation_strategy'] as Map<String, dynamic>,
            )
          : null,
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      responseFormat: _parseResponseFormat(json['response_format']),
    );
  }

  /// The run identifier.
  final String id;

  /// The object type (always "thread.run").
  final String object;

  /// The Unix timestamp when the run was created.
  final int createdAt;

  /// The thread ID this run belongs to.
  final String threadId;

  /// The assistant ID for this run.
  final String assistantId;

  /// The status of the run.
  final RunStatus status;

  /// Required action if the run is waiting for tool outputs.
  final RequiredAction? requiredAction;

  /// The last error if the run failed.
  final RunError? lastError;

  /// The Unix timestamp when the run will expire.
  final int? expiresAt;

  /// The Unix timestamp when the run started.
  final int? startedAt;

  /// The Unix timestamp when the run was cancelled.
  final int? cancelledAt;

  /// The Unix timestamp when the run failed.
  final int? failedAt;

  /// The Unix timestamp when the run completed.
  final int? completedAt;

  /// Details about why the run is incomplete.
  final RunIncompleteDetails? incompleteDetails;

  /// The model used for this run.
  final String model;

  /// The instructions for the assistant.
  final String? instructions;

  /// The tools available for this run.
  final List<AssistantTool> tools;

  /// Custom metadata.
  final Map<String, String> metadata;

  /// Token usage statistics.
  final Usage? usage;

  /// The sampling temperature.
  final double? temperature;

  /// The nucleus sampling parameter.
  final double? topP;

  /// Maximum prompt tokens.
  final int? maxPromptTokens;

  /// Maximum completion tokens.
  final int? maxCompletionTokens;

  /// The truncation strategy.
  final TruncationStrategy? truncationStrategy;

  /// The tool choice setting.
  final ToolChoice? toolChoice;

  /// Whether parallel tool calls are enabled.
  final bool? parallelToolCalls;

  /// The response format.
  final ResponseFormat? responseFormat;

  /// Whether the run is still processing.
  bool get isProcessing =>
      status == RunStatus.queued ||
      status == RunStatus.inProgress ||
      status == RunStatus.cancelling;

  /// Whether the run requires action.
  bool get requiresAction => status == RunStatus.requiresAction;

  /// Whether the run is complete.
  bool get isComplete => status == RunStatus.completed;

  /// Whether the run failed.
  bool get isFailed => status == RunStatus.failed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'thread_id': threadId,
    'assistant_id': assistantId,
    'status': status.toJson(),
    if (requiredAction != null) 'required_action': requiredAction!.toJson(),
    if (lastError != null) 'last_error': lastError!.toJson(),
    if (expiresAt != null) 'expires_at': expiresAt,
    if (startedAt != null) 'started_at': startedAt,
    if (cancelledAt != null) 'cancelled_at': cancelledAt,
    if (failedAt != null) 'failed_at': failedAt,
    if (completedAt != null) 'completed_at': completedAt,
    if (incompleteDetails != null)
      'incomplete_details': incompleteDetails!.toJson(),
    'model': model,
    if (instructions != null) 'instructions': instructions,
    'tools': tools.map((t) => t.toJson()).toList(),
    'metadata': metadata,
    if (usage != null) 'usage': usage!.toJson(),
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (maxPromptTokens != null) 'max_prompt_tokens': maxPromptTokens,
    if (maxCompletionTokens != null)
      'max_completion_tokens': maxCompletionTokens,
    if (truncationStrategy != null)
      'truncation_strategy': truncationStrategy!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Run && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Run(id: $id, status: $status)';
}

/// A list of runs.
@immutable
class RunList {
  /// Creates a [RunList].
  const RunList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [RunList] from JSON.
  factory RunList.fromJson(Map<String, dynamic> json) {
    return RunList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Run.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of runs.
  final List<Run> data;

  /// The ID of the first run.
  final String? firstId;

  /// The ID of the last run.
  final String? lastId;

  /// Whether there are more runs.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((r) => r.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'RunList(${data.length} runs)';
}

/// A request to create a run.
@immutable
class CreateRunRequest {
  /// Creates a [CreateRunRequest].
  const CreateRunRequest({
    required this.assistantId,
    this.model,
    this.instructions,
    this.additionalInstructions,
    this.additionalMessages,
    this.tools,
    this.metadata,
    this.temperature,
    this.topP,
    this.stream,
    this.maxPromptTokens,
    this.maxCompletionTokens,
    this.truncationStrategy,
    this.toolChoice,
    this.parallelToolCalls,
    this.responseFormat,
  });

  /// Creates a [CreateRunRequest] from JSON.
  factory CreateRunRequest.fromJson(Map<String, dynamic> json) {
    return CreateRunRequest(
      assistantId: json['assistant_id'] as String,
      model: json['model'] as String?,
      instructions: json['instructions'] as String?,
      additionalInstructions: json['additional_instructions'] as String?,
      additionalMessages: (json['additional_messages'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      stream: json['stream'] as bool?,
      maxPromptTokens: json['max_prompt_tokens'] as int?,
      maxCompletionTokens: json['max_completion_tokens'] as int?,
      truncationStrategy: json['truncation_strategy'] != null
          ? TruncationStrategy.fromJson(
              json['truncation_strategy'] as Map<String, dynamic>,
            )
          : null,
      toolChoice: json['tool_choice'] != null
          ? ToolChoice.fromJson(json['tool_choice'])
          : null,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      responseFormat: _parseResponseFormat(json['response_format']),
    );
  }

  /// The assistant ID.
  final String assistantId;

  /// The model to use (overrides assistant's model).
  final String? model;

  /// Instructions to override the assistant's instructions.
  final String? instructions;

  /// Additional instructions appended to the assistant's instructions.
  final String? additionalInstructions;

  /// Additional messages to add before the run.
  final List<Map<String, dynamic>>? additionalMessages;

  /// Tools to override the assistant's tools.
  final List<AssistantTool>? tools;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// The sampling temperature.
  final double? temperature;

  /// The nucleus sampling parameter.
  final double? topP;

  /// Whether to stream the response.
  final bool? stream;

  /// Maximum prompt tokens.
  final int? maxPromptTokens;

  /// Maximum completion tokens.
  final int? maxCompletionTokens;

  /// The truncation strategy.
  final TruncationStrategy? truncationStrategy;

  /// The tool choice setting.
  final ToolChoice? toolChoice;

  /// Whether parallel tool calls are enabled.
  final bool? parallelToolCalls;

  /// The response format.
  final ResponseFormat? responseFormat;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'assistant_id': assistantId,
    if (model != null) 'model': model,
    if (instructions != null) 'instructions': instructions,
    if (additionalInstructions != null)
      'additional_instructions': additionalInstructions,
    if (additionalMessages != null) 'additional_messages': additionalMessages,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'top_p': topP,
    if (stream != null) 'stream': stream,
    if (maxPromptTokens != null) 'max_prompt_tokens': maxPromptTokens,
    if (maxCompletionTokens != null)
      'max_completion_tokens': maxCompletionTokens,
    if (truncationStrategy != null)
      'truncation_strategy': truncationStrategy!.toJson(),
    if (toolChoice != null) 'tool_choice': toolChoice!.toJson(),
    if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRunRequest &&
          runtimeType == other.runtimeType &&
          assistantId == other.assistantId;

  @override
  int get hashCode => assistantId.hashCode;

  @override
  String toString() => 'CreateRunRequest(assistantId: $assistantId)';
}

/// Run status values.
enum RunStatus {
  /// The run is queued.
  queued._('queued'),

  /// The run is in progress.
  inProgress._('in_progress'),

  /// The run requires action (tool outputs).
  requiresAction._('requires_action'),

  /// The run is cancelling.
  cancelling._('cancelling'),

  /// The run was cancelled.
  cancelled._('cancelled'),

  /// The run failed.
  failed._('failed'),

  /// The run completed successfully.
  completed._('completed'),

  /// The run is incomplete.
  incomplete._('incomplete'),

  /// The run expired.
  expired._('expired');

  const RunStatus._(this._value);

  /// Creates from JSON string.
  factory RunStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// A required action for a run.
@immutable
class RequiredAction {
  /// Creates a [RequiredAction].
  const RequiredAction({required this.type, required this.submitToolOutputs});

  /// Creates a [RequiredAction] from JSON.
  factory RequiredAction.fromJson(Map<String, dynamic> json) {
    return RequiredAction(
      type: json['type'] as String,
      submitToolOutputs: SubmitToolOutputs.fromJson(
        json['submit_tool_outputs'] as Map<String, dynamic>,
      ),
    );
  }

  /// The type of required action.
  final String type;

  /// The tool outputs to submit.
  final SubmitToolOutputs submitToolOutputs;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'submit_tool_outputs': submitToolOutputs.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequiredAction && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'RequiredAction(type: $type)';
}

/// Tool outputs that need to be submitted.
@immutable
class SubmitToolOutputs {
  /// Creates a [SubmitToolOutputs].
  const SubmitToolOutputs({required this.toolCalls});

  /// Creates a [SubmitToolOutputs] from JSON.
  factory SubmitToolOutputs.fromJson(Map<String, dynamic> json) {
    return SubmitToolOutputs(
      toolCalls: (json['tool_calls'] as List<dynamic>)
          .map((e) => RunToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The tool calls requiring outputs.
  final List<RunToolCall> toolCalls;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tool_calls': toolCalls.map((tc) => tc.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitToolOutputs && runtimeType == other.runtimeType;

  @override
  int get hashCode => toolCalls.length.hashCode;

  @override
  String toString() => 'SubmitToolOutputs(${toolCalls.length} calls)';
}

/// A tool call in a run.
@immutable
class RunToolCall {
  /// Creates a [RunToolCall].
  const RunToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  /// Creates a [RunToolCall] from JSON.
  factory RunToolCall.fromJson(Map<String, dynamic> json) {
    return RunToolCall(
      id: json['id'] as String,
      type: json['type'] as String,
      function: RunFunctionCall.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
    );
  }

  /// The tool call ID.
  final String id;

  /// The type of tool call.
  final String type;

  /// The function call details.
  final RunFunctionCall function;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'function': function.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunToolCall &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RunToolCall(id: $id, function: ${function.name})';
}

/// A function call in a run.
@immutable
class RunFunctionCall {
  /// Creates a [RunFunctionCall].
  const RunFunctionCall({required this.name, required this.arguments});

  /// Creates a [RunFunctionCall] from JSON.
  factory RunFunctionCall.fromJson(Map<String, dynamic> json) {
    return RunFunctionCall(
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );
  }

  /// The function name.
  final String name;

  /// The function arguments as a JSON string.
  final String arguments;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name, 'arguments': arguments};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunFunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'RunFunctionCall(name: $name)';
}

/// A run error.
@immutable
class RunError {
  /// Creates a [RunError].
  const RunError({required this.code, required this.message});

  /// Creates a [RunError] from JSON.
  factory RunError.fromJson(Map<String, dynamic> json) {
    return RunError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'RunError(code: $code)';
}

/// Details about why a run is incomplete.
@immutable
class RunIncompleteDetails {
  /// Creates a [RunIncompleteDetails].
  const RunIncompleteDetails({this.reason});

  /// Creates a [RunIncompleteDetails] from JSON.
  factory RunIncompleteDetails.fromJson(Map<String, dynamic> json) {
    return RunIncompleteDetails(reason: json['reason'] as String?);
  }

  /// The reason for incompleteness.
  final String? reason;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (reason != null) 'reason': reason};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunIncompleteDetails &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'RunIncompleteDetails(reason: $reason)';
}

/// The truncation strategy for a run.
@immutable
class TruncationStrategy {
  /// Creates a [TruncationStrategy].
  const TruncationStrategy({required this.type, this.lastMessages});

  /// Creates a [TruncationStrategy] from JSON.
  factory TruncationStrategy.fromJson(Map<String, dynamic> json) {
    return TruncationStrategy(
      type: json['type'] as String,
      lastMessages: json['last_messages'] as int?,
    );
  }

  /// The truncation type ("auto" or "last_messages").
  final String type;

  /// The number of most recent messages to include.
  final int? lastMessages;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (lastMessages != null) 'last_messages': lastMessages,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TruncationStrategy &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'TruncationStrategy(type: $type)';
}

/// A tool output to submit.
@immutable
class ToolOutput {
  /// Creates a [ToolOutput].
  const ToolOutput({required this.toolCallId, required this.output});

  /// Creates a [ToolOutput] from JSON.
  factory ToolOutput.fromJson(Map<String, dynamic> json) {
    return ToolOutput(
      toolCallId: json['tool_call_id'] as String,
      output: json['output'] as String,
    );
  }

  /// The tool call ID.
  final String toolCallId;

  /// The output to submit.
  final String output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tool_call_id': toolCallId,
    'output': output,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolOutput &&
          runtimeType == other.runtimeType &&
          toolCallId == other.toolCallId;

  @override
  int get hashCode => toolCallId.hashCode;

  @override
  String toString() => 'ToolOutput(toolCallId: $toolCallId)';
}

/// A request to submit tool outputs.
@immutable
class SubmitToolOutputsRequest {
  /// Creates a [SubmitToolOutputsRequest].
  const SubmitToolOutputsRequest({required this.toolOutputs, this.stream});

  /// Creates a [SubmitToolOutputsRequest] from JSON.
  factory SubmitToolOutputsRequest.fromJson(Map<String, dynamic> json) {
    return SubmitToolOutputsRequest(
      toolOutputs: (json['tool_outputs'] as List<dynamic>)
          .map((e) => ToolOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      stream: json['stream'] as bool?,
    );
  }

  /// The tool outputs.
  final List<ToolOutput> toolOutputs;

  /// Whether to stream the response.
  final bool? stream;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'tool_outputs': toolOutputs.map((o) => o.toJson()).toList(),
    if (stream != null) 'stream': stream,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitToolOutputsRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => toolOutputs.length.hashCode;

  @override
  String toString() =>
      'SubmitToolOutputsRequest(${toolOutputs.length} outputs)';
}
