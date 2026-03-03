import 'dart:convert';

import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../config/item_status.dart';
import '../config/message_role.dart';
import '../content/output_content.dart';
import 'item.dart';

/// Output item from a response.
///
/// This is a sealed class hierarchy for different output item types.
///
/// ## Supported Types
///
/// - [MessageOutputItem] - Text messages from the assistant
/// - [FunctionCallOutputItemResponse] - Custom function calls
/// - [ReasoningItem] - Reasoning content from reasoning models
/// - [CompactionOutputItem] - Compacted conversation history
/// - [WebSearchCallOutputItem] - Web search tool calls
/// - [FileSearchCallOutputItem] - File search tool calls
/// - [CodeInterpreterCallOutputItem] - Code interpreter tool calls
/// - [ImageGenerationCallOutputItem] - Image generation tool calls
/// - [LocalShellCallOutputItem] - Local shell tool calls
/// - [LocalShellCallOutputResultItem] - Local shell tool call results
/// - [ShellCallOutputItem] - Shell tool calls
/// - [ShellCallOutputResultItem] - Shell tool call results
/// - [McpCallOutputItem] - MCP (Model Context Protocol) tool calls
sealed class OutputItem {
  /// Creates an [OutputItem].
  const OutputItem();

  /// Creates an [OutputItem] from JSON.
  factory OutputItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageOutputItem.fromJson(json),
      'function_call' => FunctionCallOutputItemResponse.fromJson(json),
      'reasoning' => ReasoningItem.fromJson(json),
      'compaction' => CompactionOutputItem.fromJson(json),
      'web_search_call' => WebSearchCallOutputItem.fromJson(json),
      'file_search_call' => FileSearchCallOutputItem.fromJson(json),
      'code_interpreter_call' => CodeInterpreterCallOutputItem.fromJson(json),
      'image_generation_call' => ImageGenerationCallOutputItem.fromJson(json),
      'local_shell_call' => LocalShellCallOutputItem.fromJson(json),
      'local_shell_call_output' => LocalShellCallOutputResultItem.fromJson(
        json,
      ),
      'shell_call' => ShellCallOutputItem.fromJson(json),
      'shell_call_output' => ShellCallOutputResultItem.fromJson(json),
      'mcp_call' => McpCallOutputItem.fromJson(json),
      _ => throw FormatException('Unknown OutputItem type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A message output item.
@immutable
class MessageOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<OutputContent> content;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [MessageOutputItem].
  const MessageOutputItem({
    required this.id,
    required this.role,
    required this.content,
    this.status,
  });

  /// Creates a [MessageOutputItem] from JSON.
  factory MessageOutputItem.fromJson(Map<String, dynamic> json) {
    return MessageOutputItem(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => OutputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    'id': id,
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, role, content, status);

  @override
  String toString() =>
      'MessageOutputItem(id: $id, role: $role, content: $content, status: $status)';
}

/// A function call output item in the response.
@immutable
class FunctionCallOutputItemResponse extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The call ID for this function call.
  final String callId;

  /// The function name.
  final String name;

  /// The function arguments as JSON string.
  final String arguments;

  /// The arguments parsed as a JSON map.
  ///
  /// Throws [FormatException] if [arguments] is not valid JSON or does not
  /// decode to a JSON object.
  Map<String, dynamic> get argumentsMap {
    final decoded = jsonDecode(arguments);
    if (decoded is! Map) {
      throw const FormatException(
        'Function call arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// Item status.
  final ItemStatus? status;

  /// Creates a [FunctionCallOutputItemResponse].
  const FunctionCallOutputItemResponse({
    required this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
  });

  /// Creates a [FunctionCallOutputItemResponse] from JSON.
  factory FunctionCallOutputItemResponse.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItemResponse(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call',
    'id': id,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  /// Converts to a [FunctionCallItem] for use as input.
  FunctionCallItem toFunctionCallItem() => FunctionCallItem(
    id: id,
    callId: callId,
    name: name,
    arguments: arguments,
    status: status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItemResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          name == other.name &&
          arguments == other.arguments &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, name, arguments, status);

  @override
  String toString() =>
      'FunctionCallOutputItemResponse(id: $id, callId: $callId, name: $name, arguments: $arguments, status: $status)';
}

/// A reasoning item from reasoning models.
@immutable
class ReasoningItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The reasoning content that was generated.
  ///
  /// Contains a list of content parts that make up the reasoning.
  final List<Map<String, dynamic>>? content;

  /// The reasoning summary content.
  final List<ReasoningSummaryContent> summary;

  /// Encrypted reasoning content (if requested via include).
  final String? encryptedContent;

  /// Creates a [ReasoningItem].
  const ReasoningItem({
    required this.id,
    this.content,
    required this.summary,
    this.encryptedContent,
  });

  /// Creates a [ReasoningItem] from JSON.
  factory ReasoningItem.fromJson(Map<String, dynamic> json) {
    return ReasoningItem(
      id: json['id'] as String,
      content: (json['content'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      summary: (json['summary'] as List)
          .map(
            (e) => ReasoningSummaryContent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      encryptedContent: json['encrypted_content'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'reasoning',
    'id': id,
    if (content != null) 'content': content,
    'summary': summary.map((e) => e.toJson()).toList(),
    if (encryptedContent != null) 'encrypted_content': encryptedContent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode => Object.hash(id, summary, encryptedContent);

  @override
  String toString() =>
      'ReasoningItem(id: $id, content: $content, summary: $summary, encryptedContent: $encryptedContent)';
}

/// Content within a reasoning summary.
@immutable
class ReasoningSummaryContent {
  /// The summary text.
  final String text;

  /// Creates a [ReasoningSummaryContent].
  const ReasoningSummaryContent({required this.text});

  /// Creates a [ReasoningSummaryContent] from JSON.
  factory ReasoningSummaryContent.fromJson(Map<String, dynamic> json) {
    return ReasoningSummaryContent(text: json['text'] as String);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': 'summary_text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningSummaryContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ReasoningSummaryContent(text: $text)';
}

/// A compaction item emitted by `responses.compact`.
@immutable
class CompactionOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// Encrypted compaction payload.
  final String encryptedContent;

  /// Creates a [CompactionOutputItem].
  const CompactionOutputItem({
    required this.id,
    required this.encryptedContent,
  });

  /// Creates a [CompactionOutputItem] from JSON.
  factory CompactionOutputItem.fromJson(Map<String, dynamic> json) {
    return CompactionOutputItem(
      id: json['id'] as String,
      encryptedContent: json['encrypted_content'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction',
    'id': id,
    'encrypted_content': encryptedContent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode => Object.hash(id, encryptedContent);

  @override
  String toString() =>
      'CompactionOutputItem(id: $id, encryptedContent: ${encryptedContent.length} chars)';
}

// ============================================================
// Built-in Tool Output Items
// ============================================================

/// A web search call output item.
///
/// Returned when the model uses the [WebSearchTool].
@immutable
class WebSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [WebSearchCallOutputItem].
  const WebSearchCallOutputItem({required this.id, this.status});

  /// Creates a [WebSearchCallOutputItem] from JSON.
  factory WebSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return WebSearchCallOutputItem(
      id: json['id'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'web_search_call',
    'id': id,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, status);

  @override
  String toString() => 'WebSearchCallOutputItem(id: $id, status: $status)';
}

/// A file search call output item.
///
/// Returned when the model uses the [FileSearchTool].
@immutable
class FileSearchCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The search queries performed.
  final List<String>? queries;

  /// The search results.
  final List<Map<String, dynamic>>? results;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [FileSearchCallOutputItem].
  const FileSearchCallOutputItem({
    required this.id,
    this.queries,
    this.results,
    this.status,
  });

  /// Creates a [FileSearchCallOutputItem] from JSON.
  factory FileSearchCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FileSearchCallOutputItem(
      id: json['id'] as String,
      queries: (json['queries'] as List?)?.cast<String>(),
      results: (json['results'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_search_call',
    'id': id,
    if (queries != null) 'queries': queries,
    if (results != null) 'results': results,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(queries, other.queries) &&
          listsEqual(results, other.results) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, queries, results, status);

  @override
  String toString() =>
      'FileSearchCallOutputItem(id: $id, queries: $queries, results: $results, status: $status)';
}

/// Output from a code interpreter execution.
///
/// See [CodeInterpreterLogsOutput] and [CodeInterpreterImageOutput].
sealed class CodeInterpreterOutput {
  /// Creates a [CodeInterpreterOutput].
  const CodeInterpreterOutput();

  /// Creates a [CodeInterpreterOutput] from JSON.
  factory CodeInterpreterOutput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'logs' => CodeInterpreterLogsOutput.fromJson(json),
      'image' => CodeInterpreterImageOutput.fromJson(json),
      _ => throw FormatException('Unknown CodeInterpreterOutput type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Log output from code interpreter execution.
@immutable
class CodeInterpreterLogsOutput extends CodeInterpreterOutput {
  /// The log text output.
  final String logs;

  /// Creates a [CodeInterpreterLogsOutput].
  const CodeInterpreterLogsOutput({required this.logs});

  /// Creates a [CodeInterpreterLogsOutput] from JSON.
  factory CodeInterpreterLogsOutput.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterLogsOutput(logs: json['logs'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'logs', 'logs': logs};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterLogsOutput &&
          runtimeType == other.runtimeType &&
          logs == other.logs;

  @override
  int get hashCode => logs.hashCode;

  @override
  String toString() => 'CodeInterpreterLogsOutput(logs: $logs)';
}

/// Image output from code interpreter execution.
@immutable
class CodeInterpreterImageOutput extends CodeInterpreterOutput {
  /// The URL of the generated image.
  final String url;

  /// Creates a [CodeInterpreterImageOutput].
  const CodeInterpreterImageOutput({required this.url});

  /// Creates a [CodeInterpreterImageOutput] from JSON.
  factory CodeInterpreterImageOutput.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterImageOutput(url: json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'image', 'url': url};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterImageOutput &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'CodeInterpreterImageOutput(url: $url)';
}

/// A code interpreter call output item.
///
/// Returned when the model uses the [CodeInterpreterTool].
@immutable
class CodeInterpreterCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The code that was executed.
  final String? code;

  /// The programming language (typically "python").
  final String? language;

  /// The execution outputs.
  final List<CodeInterpreterOutput>? outputs;

  /// Item status.
  final ItemStatus? status;

  /// Creates a [CodeInterpreterCallOutputItem].
  const CodeInterpreterCallOutputItem({
    required this.id,
    this.code,
    this.language,
    this.outputs,
    this.status,
  });

  /// Creates a [CodeInterpreterCallOutputItem] from JSON.
  factory CodeInterpreterCallOutputItem.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterCallOutputItem(
      id: json['id'] as String,
      code: json['code'] as String?,
      language: json['language'] as String?,
      outputs: (json['outputs'] as List?)
          ?.map(
            (e) => CodeInterpreterOutput.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'code_interpreter_call',
    'id': id,
    if (code != null) 'code': code,
    if (language != null) 'language': language,
    if (outputs != null) 'outputs': outputs!.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          language == other.language &&
          listsEqual(outputs, other.outputs) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, code, language, outputs, status);

  @override
  String toString() =>
      'CodeInterpreterCallOutputItem(id: $id, code: $code, language: $language, outputs: $outputs, status: $status)';
}

/// An image generation call output item.
///
/// Returned when the model uses the [ImageGenerationTool].
@immutable
class ImageGenerationCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The original prompt used for generation.
  final String? prompt;

  /// The revised prompt (may be modified by the model).
  final String? revisedPrompt;

  /// The generated image result (base64 or URL depending on configuration).
  final String? result;

  /// Item status.
  final ItemStatus? status;

  /// Creates an [ImageGenerationCallOutputItem].
  const ImageGenerationCallOutputItem({
    required this.id,
    this.prompt,
    this.revisedPrompt,
    this.result,
    this.status,
  });

  /// Creates an [ImageGenerationCallOutputItem] from JSON.
  factory ImageGenerationCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ImageGenerationCallOutputItem(
      id: json['id'] as String,
      prompt: json['prompt'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
      result: json['result'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_generation_call',
    'id': id,
    if (prompt != null) 'prompt': prompt,
    if (revisedPrompt != null) 'revised_prompt': revisedPrompt,
    if (result != null) 'result': result,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageGenerationCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          prompt == other.prompt &&
          revisedPrompt == other.revisedPrompt &&
          result == other.result &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, prompt, revisedPrompt, result, status);

  @override
  String toString() =>
      'ImageGenerationCallOutputItem(id: $id, prompt: $prompt, revisedPrompt: $revisedPrompt, result: ${result != null ? "[${result!.length} chars]" : null}, status: $status)';
}

/// A local shell call output item.
@immutable
class LocalShellCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The local shell call ID.
  final String callId;

  /// Typed action payload to execute locally.
  final LocalShellExecAction action;

  /// Item status.
  final ItemStatus status;

  /// Creates a [LocalShellCallOutputItem].
  const LocalShellCallOutputItem({
    required this.id,
    required this.callId,
    required this.action,
    required this.status,
  });

  /// Creates a [LocalShellCallOutputItem] from JSON.
  factory LocalShellCallOutputItem.fromJson(Map<String, dynamic> json) {
    return LocalShellCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      action: LocalShellExecAction.fromJson(
        json['action'] as Map<String, dynamic>,
      ),
      status: ItemStatus.fromJson(json['status'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call',
    'id': id,
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          action == other.action &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, action, status);

  @override
  String toString() =>
      'LocalShellCallOutputItem(id: $id, callId: $callId, status: $status)';
}

/// Typed action for a local shell call.
///
/// Matches the OpenAPI `LocalShellExecAction` schema and the Python SDK's
/// `LocalShellCallAction`.
@immutable
class LocalShellExecAction {
  /// Commands to execute.
  final List<String> command;

  /// Environment variables for the command.
  final Map<String, String> env;

  /// Optional timeout in milliseconds.
  final int? timeoutMs;

  /// Optional working directory.
  final String? workingDirectory;

  /// Optional user to execute as.
  final String? user;

  /// Creates a [LocalShellExecAction].
  const LocalShellExecAction({
    required this.command,
    this.env = const {},
    this.timeoutMs,
    this.workingDirectory,
    this.user,
  });

  /// Creates a [LocalShellExecAction] from JSON.
  factory LocalShellExecAction.fromJson(Map<String, dynamic> json) {
    return LocalShellExecAction(
      command: (json['command'] as List<dynamic>).cast<String>(),
      env: (json['env'] as Map<String, dynamic>).cast<String, String>(),
      timeoutMs: json['timeout_ms'] as int?,
      workingDirectory: json['working_directory'] as String?,
      user: json['user'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'exec',
    'command': command,
    'env': env,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (workingDirectory != null) 'working_directory': workingDirectory,
    if (user != null) 'user': user,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellExecAction &&
          runtimeType == other.runtimeType &&
          listsEqual(command, other.command) &&
          mapsEqual(env, other.env) &&
          timeoutMs == other.timeoutMs &&
          workingDirectory == other.workingDirectory &&
          user == other.user;

  @override
  int get hashCode =>
      Object.hash(command, env, timeoutMs, workingDirectory, user);

  @override
  String toString() =>
      'LocalShellExecAction(command: $command, env: $env, timeoutMs: $timeoutMs, workingDirectory: $workingDirectory, user: $user)';
}

/// A shell call output item.
@immutable
class ShellCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The shell call ID.
  final String callId;

  /// Commands and execution options for this call.
  final ShellCallAction action;

  /// Item status.
  final ItemStatus status;

  /// The environment in which the shell call was executed.
  ///
  /// Can be a [LocalShellEnvironment], [ContainerReferenceEnvironment],
  /// or `null`.
  final ShellEnvironment? environment;

  /// Creates a [ShellCallOutputItem].
  const ShellCallOutputItem({
    required this.id,
    required this.callId,
    required this.action,
    required this.status,
    this.environment,
  });

  /// Creates a [ShellCallOutputItem] from JSON.
  factory ShellCallOutputItem.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      action: ShellCallAction.fromJson(json['action'] as Map<String, dynamic>),
      status: ItemStatus.fromJson(json['status'] as String),
      environment: json['environment'] != null
          ? ShellEnvironment.fromJson(
              json['environment'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'shell_call',
    'id': id,
    'call_id': callId,
    'action': action.toJson(),
    'status': status.toJson(),
    if (environment != null) 'environment': environment!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          action == other.action &&
          status == other.status &&
          environment == other.environment;

  @override
  int get hashCode => Object.hash(id, callId, action, status, environment);

  @override
  String toString() =>
      'ShellCallOutputItem(id: $id, callId: $callId, status: $status, environment: $environment)';
}

/// Shell call action payload.
@immutable
class ShellCallAction {
  /// Commands to execute.
  final List<String> commands;

  /// Optional timeout in milliseconds.
  final int? timeoutMs;

  /// Optional max output length.
  final int? maxOutputLength;

  /// Creates a [ShellCallAction].
  const ShellCallAction({
    required this.commands,
    this.timeoutMs,
    this.maxOutputLength,
  });

  /// Creates a [ShellCallAction] from JSON.
  factory ShellCallAction.fromJson(Map<String, dynamic> json) {
    return ShellCallAction(
      commands: (json['commands'] as List<dynamic>).cast<String>(),
      timeoutMs: json['timeout_ms'] as int?,
      maxOutputLength: json['max_output_length'] as int?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'commands': commands,
    if (timeoutMs != null) 'timeout_ms': timeoutMs,
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallAction &&
          runtimeType == other.runtimeType &&
          listsEqual(commands, other.commands) &&
          timeoutMs == other.timeoutMs &&
          maxOutputLength == other.maxOutputLength;

  @override
  int get hashCode => Object.hash(commands, timeoutMs, maxOutputLength);

  @override
  String toString() =>
      'ShellCallAction(commands: $commands, timeoutMs: $timeoutMs, maxOutputLength: $maxOutputLength)';
}

/// The execution environment for a shell call.
///
/// See [LocalShellEnvironment] and [ContainerReferenceEnvironment].
sealed class ShellEnvironment {
  /// Creates a [ShellEnvironment].
  const ShellEnvironment();

  /// Creates a [ShellEnvironment] from JSON.
  factory ShellEnvironment.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'local' => const LocalShellEnvironment(),
      'container_reference' => ContainerReferenceEnvironment.fromJson(json),
      final type => throw FormatException(
        'Unknown ShellEnvironment type: $type',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A local environment for shell execution.
@immutable
class LocalShellEnvironment extends ShellEnvironment {
  /// Creates a [LocalShellEnvironment].
  const LocalShellEnvironment();

  /// Creates a [LocalShellEnvironment] from JSON.
  // ignore: avoid_unused_constructor_parameters
  factory LocalShellEnvironment.fromJson(Map<String, dynamic> json) =>
      const LocalShellEnvironment();

  @override
  Map<String, dynamic> toJson() => const {'type': 'local'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocalShellEnvironment;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'LocalShellEnvironment()';
}

/// A container reference environment for shell execution.
@immutable
class ContainerReferenceEnvironment extends ShellEnvironment {
  /// The container ID.
  final String containerId;

  /// Creates a [ContainerReferenceEnvironment].
  const ContainerReferenceEnvironment({required this.containerId});

  /// Creates a [ContainerReferenceEnvironment] from JSON.
  factory ContainerReferenceEnvironment.fromJson(Map<String, dynamic> json) {
    return ContainerReferenceEnvironment(
      containerId: json['container_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'container_reference',
    'container_id': containerId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerReferenceEnvironment &&
          runtimeType == other.runtimeType &&
          containerId == other.containerId;

  @override
  int get hashCode => containerId.hashCode;

  @override
  String toString() =>
      'ContainerReferenceEnvironment(containerId: $containerId)';
}

/// A shell call output result item.
@immutable
class ShellCallOutputResultItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The shell call ID.
  final String callId;

  /// The status of the shell call output.
  final ItemStatus? status;

  /// Structured output chunks from the call.
  final List<ShellCallOutputContent> output;

  /// The max output length to preserve for follow-up turns.
  final int? maxOutputLength;

  /// Creates a [ShellCallOutputResultItem].
  const ShellCallOutputResultItem({
    required this.id,
    required this.callId,
    this.status,
    required this.output,
    required this.maxOutputLength,
  });

  /// Creates a [ShellCallOutputResultItem] from JSON.
  factory ShellCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputResultItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      output: (json['output'] as List<dynamic>)
          .map(
            (e) => ShellCallOutputContent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      maxOutputLength: json['max_output_length'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'shell_call_output',
    'id': id,
    'call_id': callId,
    if (status != null) 'status': status!.toJson(),
    'output': output.map((e) => e.toJson()).toList(),
    if (maxOutputLength != null) 'max_output_length': maxOutputLength,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          status == other.status &&
          listsEqual(output, other.output) &&
          maxOutputLength == other.maxOutputLength;

  @override
  int get hashCode => Object.hash(id, callId, status, output, maxOutputLength);

  @override
  String toString() =>
      'ShellCallOutputResultItem(id: $id, callId: $callId, status: $status, output: ${output.length} chunks)';
}

/// A single shell output chunk.
@immutable
class ShellCallOutputContent {
  /// Captured stdout.
  final String stdout;

  /// Captured stderr.
  final String stderr;

  /// Execution outcome for this chunk.
  final ShellCallOutcome outcome;

  /// Creates a [ShellCallOutputContent].
  const ShellCallOutputContent({
    required this.stdout,
    required this.stderr,
    required this.outcome,
  });

  /// Creates a [ShellCallOutputContent] from JSON.
  factory ShellCallOutputContent.fromJson(Map<String, dynamic> json) {
    return ShellCallOutputContent(
      stdout: json['stdout'] as String,
      stderr: json['stderr'] as String,
      outcome: ShellCallOutcome.fromJson(
        json['outcome'] as Map<String, dynamic>,
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'stdout': stdout,
    'stderr': stderr,
    'outcome': outcome.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallOutputContent &&
          runtimeType == other.runtimeType &&
          stdout == other.stdout &&
          stderr == other.stderr &&
          outcome == other.outcome;

  @override
  int get hashCode => Object.hash(stdout, stderr, outcome);

  @override
  String toString() =>
      'ShellCallOutputContent(stdout: ${stdout.length} chars, stderr: ${stderr.length} chars, outcome: $outcome)';
}

/// Execution outcome for a shell call output chunk.
sealed class ShellCallOutcome {
  /// Creates a [ShellCallOutcome].
  const ShellCallOutcome();

  /// Creates a [ShellCallOutcome] from JSON.
  factory ShellCallOutcome.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'exit' => ShellCallExitOutcome.fromJson(json),
      'timeout' => ShellCallTimeoutOutcome.fromJson(json),
      _ => throw FormatException('Unknown ShellCallOutcome type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Normal shell call completion with an exit code.
@immutable
class ShellCallExitOutcome extends ShellCallOutcome {
  /// Exit code of the command.
  final int exitCode;

  /// Creates a [ShellCallExitOutcome].
  const ShellCallExitOutcome({required this.exitCode});

  /// Creates a [ShellCallExitOutcome] from JSON.
  factory ShellCallExitOutcome.fromJson(Map<String, dynamic> json) {
    return ShellCallExitOutcome(exitCode: json['exit_code'] as int);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'exit', 'exit_code': exitCode};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShellCallExitOutcome &&
          runtimeType == other.runtimeType &&
          exitCode == other.exitCode;

  @override
  int get hashCode => exitCode.hashCode;

  @override
  String toString() => 'ShellCallExitOutcome(exitCode: $exitCode)';
}

/// Shell call timeout outcome.
@immutable
class ShellCallTimeoutOutcome extends ShellCallOutcome {
  /// Creates a [ShellCallTimeoutOutcome].
  const ShellCallTimeoutOutcome();

  /// Creates a [ShellCallTimeoutOutcome] from JSON.
  factory ShellCallTimeoutOutcome.fromJson(Map<String, dynamic> json) {
    if ((json['type'] as String?) != 'timeout') {
      throw const FormatException('Invalid type for ShellCallTimeoutOutcome');
    }
    return const ShellCallTimeoutOutcome();
  }

  @override
  Map<String, dynamic> toJson() => const {'type': 'timeout'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShellCallTimeoutOutcome;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ShellCallTimeoutOutcome()';
}

/// A local shell call output result item.
@immutable
class LocalShellCallOutputResultItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The local shell call ID.
  final String? callId;

  /// The serialized local shell output payload.
  final String output;

  /// The status of the local shell call output.
  final ItemStatus? status;

  /// Creates a [LocalShellCallOutputResultItem].
  const LocalShellCallOutputResultItem({
    required this.id,
    required this.output,
    this.callId,
    this.status,
  });

  /// Creates a [LocalShellCallOutputResultItem] from JSON.
  factory LocalShellCallOutputResultItem.fromJson(Map<String, dynamic> json) {
    return LocalShellCallOutputResultItem(
      id: json['id'] as String,
      callId: json['call_id'] as String?,
      output: json['output'] as String,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'local_shell_call_output',
    'id': id,
    if (callId != null) 'call_id': callId,
    'output': output,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalShellCallOutputResultItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          output == other.output &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, output, status);

  @override
  String toString() =>
      'LocalShellCallOutputResultItem(id: $id, callId: $callId, status: $status)';
}

/// An MCP (Model Context Protocol) call output item.
///
/// Returned when the model uses the [McpTool].
@immutable
class McpCallOutputItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The call ID for this MCP call.
  final String callId;

  /// The server label identifying the MCP server.
  final String? serverLabel;

  /// The name of the MCP tool called.
  final String? name;

  /// The arguments passed to the tool (JSON string).
  final String? arguments;

  /// The output from the tool call.
  final String? output;

  /// Error message if the call failed.
  final String? error;

  /// Item status.
  final ItemStatus? status;

  /// Creates an [McpCallOutputItem].
  const McpCallOutputItem({
    required this.id,
    required this.callId,
    this.serverLabel,
    this.name,
    this.arguments,
    this.output,
    this.error,
    this.status,
  });

  /// Creates an [McpCallOutputItem] from JSON.
  factory McpCallOutputItem.fromJson(Map<String, dynamic> json) {
    return McpCallOutputItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      serverLabel: json['server_label'] as String?,
      name: json['name'] as String?,
      arguments: json['arguments'] as String?,
      output: json['output'] as String?,
      error: json['error'] as String?,
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mcp_call',
    'id': id,
    'call_id': callId,
    if (serverLabel != null) 'server_label': serverLabel,
    if (name != null) 'name': name,
    if (arguments != null) 'arguments': arguments,
    if (output != null) 'output': output,
    if (error != null) 'error': error,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          serverLabel == other.serverLabel &&
          name == other.name &&
          arguments == other.arguments &&
          output == other.output &&
          error == other.error &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    id,
    callId,
    serverLabel,
    name,
    arguments,
    output,
    error,
    status,
  );

  @override
  String toString() =>
      'McpCallOutputItem(id: $id, callId: $callId, serverLabel: $serverLabel, name: $name, arguments: $arguments, output: $output, error: $error, status: $status)';
}
