import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../common/usage.dart';

/// A step in a run's execution.
///
/// Run steps track the individual actions taken during a run, such as
/// tool calls and message creation.
@immutable
class RunStep {
  /// Creates a [RunStep].
  const RunStep({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.runId,
    required this.assistantId,
    required this.threadId,
    required this.type,
    required this.status,
    required this.stepDetails,
    this.lastError,
    this.expiredAt,
    this.cancelledAt,
    this.failedAt,
    this.completedAt,
    required this.metadata,
    this.usage,
  });

  /// Creates a [RunStep] from JSON.
  factory RunStep.fromJson(Map<String, dynamic> json) {
    return RunStep(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      runId: json['run_id'] as String,
      assistantId: json['assistant_id'] as String,
      threadId: json['thread_id'] as String,
      type: RunStepType.fromJson(json['type'] as String),
      status: RunStepStatus.fromJson(json['status'] as String),
      stepDetails: StepDetails.fromJson(
        json['step_details'] as Map<String, dynamic>,
      ),
      lastError: json['last_error'] != null
          ? StepError.fromJson(json['last_error'] as Map<String, dynamic>)
          : null,
      expiredAt: json['expired_at'] as int?,
      cancelledAt: json['cancelled_at'] as int?,
      failedAt: json['failed_at'] as int?,
      completedAt: json['completed_at'] as int?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
      usage: json['usage'] != null
          ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The run step identifier.
  final String id;

  /// The object type (always "thread.run.step").
  final String object;

  /// The Unix timestamp when the step was created.
  final int createdAt;

  /// The run ID this step belongs to.
  final String runId;

  /// The assistant ID.
  final String assistantId;

  /// The thread ID.
  final String threadId;

  /// The type of step.
  final RunStepType type;

  /// The status of the step.
  final RunStepStatus status;

  /// The step details.
  final StepDetails stepDetails;

  /// The last error if the step failed.
  final StepError? lastError;

  /// The Unix timestamp when the step expired.
  final int? expiredAt;

  /// The Unix timestamp when the step was cancelled.
  final int? cancelledAt;

  /// The Unix timestamp when the step failed.
  final int? failedAt;

  /// The Unix timestamp when the step completed.
  final int? completedAt;

  /// Custom metadata.
  final Map<String, String> metadata;

  /// Token usage statistics.
  final Usage? usage;

  /// Whether the step is a tool call.
  bool get isToolCall => type == RunStepType.toolCalls;

  /// Whether the step is a message creation.
  bool get isMessageCreation => type == RunStepType.messageCreation;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'run_id': runId,
    'assistant_id': assistantId,
    'thread_id': threadId,
    'type': type.toJson(),
    'status': status.toJson(),
    'step_details': stepDetails.toJson(),
    if (lastError != null) 'last_error': lastError!.toJson(),
    if (expiredAt != null) 'expired_at': expiredAt,
    if (cancelledAt != null) 'cancelled_at': cancelledAt,
    if (failedAt != null) 'failed_at': failedAt,
    if (completedAt != null) 'completed_at': completedAt,
    'metadata': metadata,
    if (usage != null) 'usage': usage!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunStep && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RunStep(id: $id, type: $type, status: $status)';
}

/// A list of run steps.
@immutable
class RunStepList {
  /// Creates a [RunStepList].
  const RunStepList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [RunStepList] from JSON.
  factory RunStepList.fromJson(Map<String, dynamic> json) {
    return RunStepList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => RunStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of run steps.
  final List<RunStep> data;

  /// The ID of the first step.
  final String? firstId;

  /// The ID of the last step.
  final String? lastId;

  /// Whether there are more steps.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((s) => s.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunStepList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'RunStepList(${data.length} steps)';
}

/// Run step type values.
enum RunStepType {
  /// A message creation step.
  messageCreation._('message_creation'),

  /// A tool calls step.
  toolCalls._('tool_calls');

  const RunStepType._(this._value);

  /// Creates from JSON string.
  factory RunStepType.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown type: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Run step status values.
enum RunStepStatus {
  /// The step is in progress.
  inProgress._('in_progress'),

  /// The step was cancelled.
  cancelled._('cancelled'),

  /// The step failed.
  failed._('failed'),

  /// The step completed.
  completed._('completed'),

  /// The step expired.
  expired._('expired');

  const RunStepStatus._(this._value);

  /// Creates from JSON string.
  factory RunStepStatus.fromJson(String json) {
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

/// Details about a run step.
sealed class StepDetails {
  /// Creates a [StepDetails] from JSON.
  factory StepDetails.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message_creation' => MessageCreationDetails.fromJson(json),
      'tool_calls' => ToolCallsDetails.fromJson(json),
      _ => throw FormatException('Unknown step type: $type'),
    };
  }

  /// The type of step detail.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Details for a message creation step.
@immutable
class MessageCreationDetails implements StepDetails {
  /// Creates a [MessageCreationDetails].
  const MessageCreationDetails({required this.messageId});

  /// Creates a [MessageCreationDetails] from JSON.
  factory MessageCreationDetails.fromJson(Map<String, dynamic> json) {
    final creation = json['message_creation'] as Map<String, dynamic>;
    return MessageCreationDetails(messageId: creation['message_id'] as String);
  }

  /// The ID of the created message.
  final String messageId;

  /// Creates a copy with the given fields replaced.
  MessageCreationDetails copyWith({String? messageId}) {
    return MessageCreationDetails(messageId: messageId ?? this.messageId);
  }

  @override
  String get type => 'message_creation';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message_creation',
    'message_creation': {'message_id': messageId},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageCreationDetails &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId;

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() => 'MessageCreationDetails(messageId: $messageId)';
}

/// Details for a tool calls step.
@immutable
class ToolCallsDetails implements StepDetails {
  /// Creates a [ToolCallsDetails].
  const ToolCallsDetails({required this.toolCalls});

  /// Creates a [ToolCallsDetails] from JSON.
  factory ToolCallsDetails.fromJson(Map<String, dynamic> json) {
    return ToolCallsDetails(
      toolCalls: (json['tool_calls'] as List<dynamic>)
          .map((e) => StepToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The tool calls made.
  final List<StepToolCall> toolCalls;

  @override
  String get type => 'tool_calls';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'tool_calls',
    'tool_calls': toolCalls.map((tc) => tc.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ToolCallsDetails copyWith({List<StepToolCall>? toolCalls}) {
    return ToolCallsDetails(toolCalls: toolCalls ?? this.toolCalls);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolCallsDetails &&
          runtimeType == other.runtimeType &&
          listsEqual(toolCalls, other.toolCalls);

  @override
  int get hashCode => Object.hashAll(toolCalls);

  @override
  String toString() => 'ToolCallsDetails(toolCalls: $toolCalls)';
}

/// A tool call in a run step.
sealed class StepToolCall {
  /// Creates a [StepToolCall] from JSON.
  factory StepToolCall.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'code_interpreter' => CodeInterpreterStepCall.fromJson(json),
      'file_search' => FileSearchStepCall.fromJson(json),
      'function' => FunctionStepCall.fromJson(json),
      _ => throw FormatException('Unknown tool call type: $type'),
    };
  }

  /// The type of tool call.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A code interpreter tool call.
@immutable
class CodeInterpreterStepCall implements StepToolCall {
  /// Creates a [CodeInterpreterStepCall].
  const CodeInterpreterStepCall({
    required this.id,
    required this.input,
    required this.outputs,
  });

  /// Creates a [CodeInterpreterStepCall] from JSON.
  factory CodeInterpreterStepCall.fromJson(Map<String, dynamic> json) {
    final ci = json['code_interpreter'] as Map<String, dynamic>;
    return CodeInterpreterStepCall(
      id: json['id'] as String,
      input: ci['input'] as String,
      outputs: (ci['outputs'] as List<dynamic>)
          .map((e) => CodeInterpreterOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The tool call ID.
  final String id;

  /// The input code.
  final String input;

  /// The outputs.
  final List<CodeInterpreterOutput> outputs;

  /// Creates a copy with the given fields replaced.
  CodeInterpreterStepCall copyWith({
    String? id,
    String? input,
    List<CodeInterpreterOutput>? outputs,
  }) {
    return CodeInterpreterStepCall(
      id: id ?? this.id,
      input: input ?? this.input,
      outputs: outputs ?? this.outputs,
    );
  }

  @override
  String get type => 'code_interpreter';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'code_interpreter',
    'code_interpreter': {
      'input': input,
      'outputs': outputs.map((o) => o.toJson()).toList(),
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterStepCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          input == other.input &&
          listsEqual(outputs, other.outputs);

  @override
  int get hashCode => Object.hash(id, input, Object.hashAll(outputs));

  @override
  String toString() {
    final inputPreview = input.length > 50
        ? '${input.substring(0, 50)}...'
        : input;
    return 'CodeInterpreterStepCall(id: $id, input: $inputPreview)';
  }
}

/// A code interpreter output.
sealed class CodeInterpreterOutput {
  /// Creates a [CodeInterpreterOutput] from JSON.
  factory CodeInterpreterOutput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'logs' => LogsOutput.fromJson(json),
      'image' => ImageOutput.fromJson(json),
      _ => throw FormatException('Unknown output type: $type'),
    };
  }

  /// The type of output.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Logs output from code interpreter.
@immutable
class LogsOutput implements CodeInterpreterOutput {
  /// Creates a [LogsOutput].
  const LogsOutput({required this.logs});

  /// Creates a [LogsOutput] from JSON.
  factory LogsOutput.fromJson(Map<String, dynamic> json) {
    return LogsOutput(logs: json['logs'] as String);
  }

  /// The log output.
  final String logs;

  @override
  String get type => 'logs';

  @override
  Map<String, dynamic> toJson() => {'type': 'logs', 'logs': logs};

  /// Creates a copy with the given fields replaced.
  LogsOutput copyWith({String? logs}) {
    return LogsOutput(logs: logs ?? this.logs);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogsOutput &&
          runtimeType == other.runtimeType &&
          logs == other.logs;

  @override
  int get hashCode => logs.hashCode;

  @override
  String toString() => 'LogsOutput(logs: $logs)';
}

/// Image output from code interpreter.
@immutable
class ImageOutput implements CodeInterpreterOutput {
  /// Creates an [ImageOutput].
  const ImageOutput({required this.fileId});

  /// Creates an [ImageOutput] from JSON.
  factory ImageOutput.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>;
    return ImageOutput(fileId: image['file_id'] as String);
  }

  /// The file ID of the image.
  final String fileId;

  /// Creates a copy with the given fields replaced.
  ImageOutput copyWith({String? fileId}) {
    return ImageOutput(fileId: fileId ?? this.fileId);
  }

  @override
  String get type => 'image';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image',
    'image': {'file_id': fileId},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageOutput &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'ImageOutput(fileId: $fileId)';
}

/// A file search tool call.
@immutable
class FileSearchStepCall implements StepToolCall {
  /// Creates a [FileSearchStepCall].
  const FileSearchStepCall({required this.id, required this.fileSearch});

  /// Creates a [FileSearchStepCall] from JSON.
  factory FileSearchStepCall.fromJson(Map<String, dynamic> json) {
    return FileSearchStepCall(
      id: json['id'] as String,
      fileSearch: json['file_search'] as Map<String, dynamic>,
    );
  }

  /// The tool call ID.
  final String id;

  /// The file search results.
  final Map<String, dynamic> fileSearch;

  @override
  String get type => 'file_search';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'file_search',
    'file_search': fileSearch,
  };

  /// Creates a copy with the given fields replaced.
  FileSearchStepCall copyWith({String? id, Map<String, dynamic>? fileSearch}) {
    return FileSearchStepCall(
      id: id ?? this.id,
      fileSearch: fileSearch ?? this.fileSearch,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchStepCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mapsDeepEqual(fileSearch, other.fileSearch);

  @override
  int get hashCode => Object.hash(id, mapDeepHashCode(fileSearch));

  @override
  String toString() => 'FileSearchStepCall(id: $id, fileSearch: $fileSearch)';
}

/// A function tool call.
@immutable
class FunctionStepCall implements StepToolCall {
  /// Creates a [FunctionStepCall].
  const FunctionStepCall({
    required this.id,
    required this.name,
    required this.arguments,
    this.output,
  });

  /// Creates a [FunctionStepCall] from JSON.
  factory FunctionStepCall.fromJson(Map<String, dynamic> json) {
    final fn = json['function'] as Map<String, dynamic>;
    return FunctionStepCall(
      id: json['id'] as String,
      name: fn['name'] as String,
      arguments: fn['arguments'] as String,
      output: fn['output'] as String?,
    );
  }

  /// The tool call ID.
  final String id;

  /// The function name.
  final String name;

  /// The function arguments.
  final String arguments;

  /// The function output (after submission).
  final String? output;

  /// Creates a copy with the given fields replaced.
  FunctionStepCall copyWith({
    String? id,
    String? name,
    String? arguments,
    Object? output = unsetCopyWithValue,
  }) {
    return FunctionStepCall(
      id: id ?? this.id,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      output: output == unsetCopyWithValue ? this.output : output as String?,
    );
  }

  @override
  String get type => 'function';

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': 'function',
    'function': {
      'name': name,
      'arguments': arguments,
      if (output != null) 'output': output,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionStepCall &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          arguments == other.arguments &&
          output == other.output;

  @override
  int get hashCode => Object.hash(id, name, arguments, output);

  @override
  String toString() => 'FunctionStepCall(id: $id, name: $name)';
}

/// A run step error.
@immutable
class StepError {
  /// Creates a [StepError].
  const StepError({required this.code, required this.message});

  /// Creates a [StepError] from JSON.
  factory StepError.fromJson(Map<String, dynamic> json) {
    return StepError(
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
      other is StepError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'StepError(code: $code)';
}
