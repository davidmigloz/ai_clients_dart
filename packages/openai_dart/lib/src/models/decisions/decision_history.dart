part of 'decision_input.dart';

/// An ordered Decisions message, function call, custom call, or tool result.
///
/// Message variants are [DecisionInputMessage], [DeveloperDecisionInputMessage],
/// [SystemDecisionInputMessage], and [AssistantDecisionInputMessage]. Tool history
/// uses [DecisionFunctionCall], [DecisionFunctionCallOutput],
/// [DecisionCustomToolCall], and [DecisionCustomToolCallOutput].
@immutable
sealed class DecisionInputItem {
  const DecisionInputItem();

  /// Reads a supported history item; a message discriminator may be omitted.
  factory DecisionInputItem.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        null || 'message' => switch (json['role']) {
          'user' => DecisionInputMessage.fromJson(json),
          'developer' => DeveloperDecisionInputMessage.fromJson(json),
          'system' => SystemDecisionInputMessage.fromJson(json),
          'assistant' => AssistantDecisionInputMessage.fromJson(json),
          _ => throw const FormatException(
            'DecisionInputItem: unsupported message role',
          ),
        },
        'function_call' => DecisionFunctionCall.fromJson(json),
        'function_call_output' => DecisionFunctionCallOutput.fromJson(json),
        'custom_tool_call' => DecisionCustomToolCall.fromJson(json),
        'custom_tool_call_output' => DecisionCustomToolCallOutput.fromJson(
          json,
        ),
        _ => throw const FormatException(
          'DecisionInputItem: unsupported item type',
        ),
      };

  /// The item discriminator.
  String get type;

  /// Converts the item to API JSON.
  Map<String, dynamic> toJson();
}

/// The lifecycle status retained in Decisions tool history.
enum DecisionToolStatus {
  /// The call is in progress.
  inProgress('in_progress'),

  /// The call completed.
  completed('completed'),

  /// The call is incomplete.
  incomplete('incomplete');

  const DecisionToolStatus(this.value);

  /// The wire value.
  final String value;

  /// Reads an admitted request status.
  factory DecisionToolStatus.fromJson(String value) => switch (value) {
    'in_progress' => inProgress,
    'completed' => completed,
    'incomplete' => incomplete,
    _ => throw const FormatException(
      'DecisionToolStatus: invalid request status',
    ),
  };

  /// Converts to JSON.
  String toJson() => value;
}

/// The phase of an assistant message retained as evidence.
enum DecisionMessagePhase {
  /// Intermediate assistant commentary.
  commentary('commentary'),

  /// A final assistant answer.
  finalAnswer('final_answer');

  const DecisionMessagePhase(this.value);

  /// The wire value.
  final String value;

  /// Reads an admitted message phase.
  factory DecisionMessagePhase.fromJson(String value) => switch (value) {
    'commentary' => commentary,
    'final_answer' => finalAnswer,
    _ => throw const FormatException('DecisionMessagePhase: invalid phase'),
  };

  /// Converts to JSON.
  String toJson() => value;
}

/// String or typed content parts in a developer or system message.
///
/// Variants are [TextDecisionDeveloperContent] and [PartsDecisionDeveloperContent].
@immutable
sealed class DecisionDeveloperContent {
  const DecisionDeveloperContent();

  /// Creates string content.
  const factory DecisionDeveloperContent.text(String text) =
      TextDecisionDeveloperContent;

  /// Copies the supplied content parts.
  factory DecisionDeveloperContent.parts(List<TextDecisionInputPart> parts) =
      PartsDecisionDeveloperContent;

  /// Reads string content or an array of admitted parts.
  factory DecisionDeveloperContent.fromJson(Object? json) {
    if (json is String) return TextDecisionDeveloperContent(json);
    return PartsDecisionDeveloperContent(
      parseDecisionObjects(
        json,
        _decisionTextPart,
        'DecisionDeveloperContent.parts',
      ),
    );
  }

  /// Converts to API content.
  Object toJson();
}

/// String content in a developer or system message.
@immutable
class TextDecisionDeveloperContent extends DecisionDeveloperContent {
  /// Creates string content.
  const TextDecisionDeveloperContent(this.text);

  /// The text evidence.
  final String text;
  @override
  String toJson() => text;

  /// Copies the text evidence.
  TextDecisionDeveloperContent copyWith({String? text}) =>
      TextDecisionDeveloperContent(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      other is TextDecisionDeveloperContent &&
      runtimeType == other.runtimeType &&
      text == other.text;
  @override
  int get hashCode => Object.hash(runtimeType, text);
  @override
  String toString() =>
      'TextDecisionDeveloperContent(text: ${text.length} chars)';
}

/// Ordered typed content parts in a developer or system message.
@immutable
class PartsDecisionDeveloperContent extends DecisionDeveloperContent {
  /// Copies the parts to an unmodifiable list.
  PartsDecisionDeveloperContent(List<TextDecisionInputPart> parts)
    : parts = List.unmodifiable(parts);

  /// The ordered evidence parts.
  final List<TextDecisionInputPart> parts;
  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  /// Copies with replacement parts.
  PartsDecisionDeveloperContent copyWith({
    List<TextDecisionInputPart>? parts,
  }) => PartsDecisionDeveloperContent(parts ?? this.parts);
  @override
  bool operator ==(Object other) =>
      other is PartsDecisionDeveloperContent &&
      runtimeType == other.runtimeType &&
      listsEqual(parts, other.parts);
  @override
  int get hashCode => Object.hash(runtimeType, listHash(parts));
  @override
  String toString() =>
      'PartsDecisionDeveloperContent(parts: ${parts.length} items)';
}

/// String or typed content parts in an assistant message.
///
/// Variants are [TextDecisionAssistantContent] and [PartsDecisionAssistantContent].
@immutable
sealed class DecisionAssistantContent {
  const DecisionAssistantContent();

  /// Creates string content.
  const factory DecisionAssistantContent.text(String text) =
      TextDecisionAssistantContent;

  /// Copies the supplied content parts.
  factory DecisionAssistantContent.parts(List<DecisionAssistantPart> parts) =
      PartsDecisionAssistantContent;

  /// Reads string content or an array of admitted parts.
  factory DecisionAssistantContent.fromJson(Object? json) {
    if (json is String) return TextDecisionAssistantContent(json);
    return PartsDecisionAssistantContent(
      parseDecisionObjects(
        json,
        DecisionAssistantPart.fromJson,
        'DecisionAssistantContent.parts',
      ),
    );
  }

  /// Converts to API content.
  Object toJson();
}

/// String content in a assistant message.
@immutable
class TextDecisionAssistantContent extends DecisionAssistantContent {
  /// Creates string content.
  const TextDecisionAssistantContent(this.text);

  /// The text evidence.
  final String text;
  @override
  String toJson() => text;

  /// Copies the text evidence.
  TextDecisionAssistantContent copyWith({String? text}) =>
      TextDecisionAssistantContent(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      other is TextDecisionAssistantContent &&
      runtimeType == other.runtimeType &&
      text == other.text;
  @override
  int get hashCode => Object.hash(runtimeType, text);
  @override
  String toString() =>
      'TextDecisionAssistantContent(text: ${text.length} chars)';
}

/// Ordered typed content parts in a assistant message.
@immutable
class PartsDecisionAssistantContent extends DecisionAssistantContent {
  /// Copies the parts to an unmodifiable list.
  PartsDecisionAssistantContent(List<DecisionAssistantPart> parts)
    : parts = List.unmodifiable(parts);

  /// The ordered evidence parts.
  final List<DecisionAssistantPart> parts;
  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  /// Copies with replacement parts.
  PartsDecisionAssistantContent copyWith({
    List<DecisionAssistantPart>? parts,
  }) => PartsDecisionAssistantContent(parts ?? this.parts);
  @override
  bool operator ==(Object other) =>
      other is PartsDecisionAssistantContent &&
      runtimeType == other.runtimeType &&
      listsEqual(parts, other.parts);
  @override
  int get hashCode => Object.hash(runtimeType, listHash(parts));
  @override
  String toString() =>
      'PartsDecisionAssistantContent(parts: ${parts.length} items)';
}

/// String or typed content parts in a tool result.
///
/// Variants are [TextDecisionToolOutput] and [PartsDecisionToolOutput].
@immutable
sealed class DecisionToolOutput {
  const DecisionToolOutput();

  /// Creates string content.
  const factory DecisionToolOutput.text(String text) = TextDecisionToolOutput;

  /// Copies the supplied content parts.
  factory DecisionToolOutput.parts(List<DecisionEvidencePart> parts) =
      PartsDecisionToolOutput;

  /// Reads string content or an array of admitted parts.
  factory DecisionToolOutput.fromJson(Object? json) {
    if (json is String) return TextDecisionToolOutput(json);
    return PartsDecisionToolOutput(
      parseDecisionObjects(
        json,
        DecisionEvidencePart.fromJson,
        'DecisionToolOutput.parts',
      ),
    );
  }

  /// Converts to API content.
  Object toJson();
}

/// String content in a tool result.
@immutable
class TextDecisionToolOutput extends DecisionToolOutput {
  /// Creates string content.
  const TextDecisionToolOutput(this.text);

  /// The text evidence.
  final String text;
  @override
  String toJson() => text;

  /// Copies the text evidence.
  TextDecisionToolOutput copyWith({String? text}) =>
      TextDecisionToolOutput(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      other is TextDecisionToolOutput &&
      runtimeType == other.runtimeType &&
      text == other.text;
  @override
  int get hashCode => Object.hash(runtimeType, text);
  @override
  String toString() => 'TextDecisionToolOutput(text: ${text.length} chars)';
}

/// Ordered typed content parts in a tool result.
@immutable
class PartsDecisionToolOutput extends DecisionToolOutput {
  /// Copies the parts to an unmodifiable list.
  PartsDecisionToolOutput(List<DecisionEvidencePart> parts)
    : parts = List.unmodifiable(parts);

  /// The ordered evidence parts.
  final List<DecisionEvidencePart> parts;
  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  /// Copies with replacement parts.
  PartsDecisionToolOutput copyWith({List<DecisionEvidencePart>? parts}) =>
      PartsDecisionToolOutput(parts ?? this.parts);
  @override
  bool operator ==(Object other) =>
      other is PartsDecisionToolOutput &&
      runtimeType == other.runtimeType &&
      listsEqual(parts, other.parts);
  @override
  int get hashCode => Object.hash(runtimeType, listHash(parts));
  @override
  String toString() => 'PartsDecisionToolOutput(parts: ${parts.length} items)';
}

TextDecisionInputPart _decisionTextPart(Map<String, dynamic> json) {
  if (json['type'] != 'input_text') {
    throw const FormatException(
      'DecisionDeveloperContent: expected input_text',
    );
  }
  return TextDecisionInputPart.fromJson(json);
}

/// Assistant output evidence, separate from user input parts.
///
/// Variants are [OutputTextDecisionPart] and [RefusalDecisionPart].
@immutable
sealed class DecisionAssistantPart {
  const DecisionAssistantPart();

  /// Creates assistant output text.
  const factory DecisionAssistantPart.text(String text) =
      OutputTextDecisionPart;

  /// Creates an assistant refusal.
  const factory DecisionAssistantPart.refusal(String refusal) =
      RefusalDecisionPart;

  /// Reads output text or a refusal.
  factory DecisionAssistantPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'output_text' => OutputTextDecisionPart.fromJson(json),
        'refusal' => RefusalDecisionPart.fromJson(json),
        _ => throw const FormatException(
          'DecisionAssistantPart: expected output_text or refusal',
        ),
      };

  /// The part discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An output_text part of assistant evidence.
@immutable
class OutputTextDecisionPart extends DecisionAssistantPart {
  /// Creates the evidence part.
  const OutputTextDecisionPart(this.text);

  /// Reads a matching assistant evidence part.
  factory OutputTextDecisionPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'output_text', 'OutputTextDecisionPart');
    return OutputTextDecisionPart(
      requireDecisionString(json['text'], 'OutputTextDecisionPart.text'),
    );
  }

  /// The evidence text.
  final String text;
  @override
  String get type => 'output_text';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Copies the evidence text.
  OutputTextDecisionPart copyWith({String? text}) =>
      OutputTextDecisionPart(text ?? this.text);
  @override
  bool operator ==(Object other) =>
      other is OutputTextDecisionPart &&
      runtimeType == other.runtimeType &&
      text == other.text;
  @override
  int get hashCode => Object.hash(runtimeType, text);
  @override
  String toString() => 'OutputTextDecisionPart(text: ${text.length} chars)';
}

/// A refusal part of assistant evidence.
@immutable
class RefusalDecisionPart extends DecisionAssistantPart {
  /// Creates the evidence part.
  const RefusalDecisionPart(this.refusal);

  /// Reads a matching assistant evidence part.
  factory RefusalDecisionPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'refusal', 'RefusalDecisionPart');
    return RefusalDecisionPart(
      requireDecisionString(json['refusal'], 'RefusalDecisionPart.refusal'),
    );
  }

  /// The evidence text.
  final String refusal;
  @override
  String get type => 'refusal';
  @override
  Map<String, dynamic> toJson() => {'type': type, 'refusal': refusal};

  /// Copies the evidence text.
  RefusalDecisionPart copyWith({String? refusal}) =>
      RefusalDecisionPart(refusal ?? this.refusal);
  @override
  bool operator ==(Object other) =>
      other is RefusalDecisionPart &&
      runtimeType == other.runtimeType &&
      refusal == other.refusal;
  @override
  int get hashCode => Object.hash(runtimeType, refusal);
  @override
  String toString() => 'RefusalDecisionPart(refusal: ${refusal.length} chars)';
}

/// A developer message retained as Decisions evidence.
@immutable
class DeveloperDecisionInputMessage extends DecisionInputItem {
  /// Creates a typed developer message.
  const DeveloperDecisionInputMessage({required this.content});

  /// String or role-specific content parts.
  final DecisionDeveloperContent content;

  /// Always developer.
  String get role => 'developer';
  @override
  String get type => 'message';

  /// Reads an optional message discriminator and fixed role.
  factory DeveloperDecisionInputMessage.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'message',
      'DeveloperDecisionInputMessage',
      optional: true,
    );
    if (json['role'] != 'developer') {
      throw const FormatException(
        'DeveloperDecisionInputMessage: invalid role',
      );
    }
    return DeveloperDecisionInputMessage(
      content: DecisionDeveloperContent.fromJson(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': content.toJson(),
  };

  /// Copies content and optional metadata.
  DeveloperDecisionInputMessage copyWith({DecisionDeveloperContent? content}) =>
      DeveloperDecisionInputMessage(content: content ?? this.content);
  @override
  bool operator ==(Object other) =>
      other is DeveloperDecisionInputMessage &&
      runtimeType == other.runtimeType &&
      content == other.content;
  @override
  int get hashCode => Object.hash(runtimeType, content);
  @override
  String toString() => 'DeveloperDecisionInputMessage(content: $content)';
}

/// A system message retained as Decisions evidence.
@immutable
class SystemDecisionInputMessage extends DecisionInputItem {
  /// Creates a typed system message.
  const SystemDecisionInputMessage({required this.content});

  /// String or role-specific content parts.
  final DecisionDeveloperContent content;

  /// Always system.
  String get role => 'system';
  @override
  String get type => 'message';

  /// Reads an optional message discriminator and fixed role.
  factory SystemDecisionInputMessage.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'message',
      'SystemDecisionInputMessage',
      optional: true,
    );
    if (json['role'] != 'system') {
      throw const FormatException('SystemDecisionInputMessage: invalid role');
    }
    return SystemDecisionInputMessage(
      content: DecisionDeveloperContent.fromJson(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': content.toJson(),
  };

  /// Copies content and optional metadata.
  SystemDecisionInputMessage copyWith({DecisionDeveloperContent? content}) =>
      SystemDecisionInputMessage(content: content ?? this.content);
  @override
  bool operator ==(Object other) =>
      other is SystemDecisionInputMessage &&
      runtimeType == other.runtimeType &&
      content == other.content;
  @override
  int get hashCode => Object.hash(runtimeType, content);
  @override
  String toString() => 'SystemDecisionInputMessage(content: $content)';
}

/// A assistant message retained as Decisions evidence.
@immutable
class AssistantDecisionInputMessage extends DecisionInputItem {
  /// Creates a typed assistant message.
  const AssistantDecisionInputMessage({required this.content, this.phase});

  /// String or role-specific content parts.
  final DecisionAssistantContent content;

  /// Optional assistant message phase.
  final DecisionMessagePhase? phase;

  /// Always assistant.
  String get role => 'assistant';
  @override
  String get type => 'message';

  /// Reads an optional message discriminator and fixed role.
  factory AssistantDecisionInputMessage.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'message',
      'AssistantDecisionInputMessage',
      optional: true,
    );
    if (json['role'] != 'assistant') {
      throw const FormatException(
        'AssistantDecisionInputMessage: invalid role',
      );
    }
    return AssistantDecisionInputMessage(
      content: DecisionAssistantContent.fromJson(json['content']),
      phase: json['phase'] == null
          ? null
          : DecisionMessagePhase.fromJson(
              requireDecisionString(
                json['phase'],
                'AssistantDecisionInputMessage.phase',
              ),
            ),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'role': role,
    'content': content.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  /// Copies content and optional metadata.
  AssistantDecisionInputMessage copyWith({
    DecisionAssistantContent? content,
    Object? phase = unsetCopyWithValue,
  }) => AssistantDecisionInputMessage(
    content: content ?? this.content,
    phase: identical(phase, unsetCopyWithValue)
        ? this.phase
        : phase as DecisionMessagePhase?,
  );
  @override
  bool operator ==(Object other) =>
      other is AssistantDecisionInputMessage &&
      runtimeType == other.runtimeType &&
      content == other.content &&
      phase == other.phase;
  @override
  int get hashCode => Object.hash(runtimeType, content, phase);
  @override
  String toString() =>
      'AssistantDecisionInputMessage(content: $content, phase: $phase)';
}

/// Typed function_call evidence; no tool is executed by the client.
@immutable
class DecisionFunctionCall extends DecisionInputItem {
  /// Creates captured tool history.
  DecisionFunctionCall({
    required this.callId,
    required this.name,
    required this.arguments,
    this.id,
    this.namespace,
    this.status,
  }) {
    _validateDecisionHistoryString(callId, 'callId', min: 1, max: 64);
    _validateDecisionHistoryString(
      name,
      'name',
      min: 1,
      max: 128,
      pattern: r'^[a-zA-Z0-9_.-]+$',
    );
    if (namespace != null) {
      _validateDecisionHistoryString(
        namespace!,
        'namespace',
        min: 1,
        max: 64,
        pattern: r'^[a-zA-Z0-9_-]+$',
      );
    }
    _validateDecisionHistoryString(arguments, 'arguments', max: 1048576);
    if (id != null) _validateDecisionHistoryString(id!, 'id', max: 1048576);
  }

  /// The call_id history field.
  final String callId;

  /// The name history field.
  final String name;

  /// The arguments history field.
  final String arguments;

  /// The id history field.
  final String? id;

  /// The namespace history field.
  final String? namespace;

  /// The status history field.
  final DecisionToolStatus? status;
  @override
  String get type => 'function_call';

  /// Reads a complete tool-history item.
  factory DecisionFunctionCall.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'function_call', 'DecisionFunctionCall');
    try {
      return DecisionFunctionCall(
        callId: requireDecisionString(
          json['call_id'],
          'DecisionFunctionCall.call_id',
        ),
        name: requireDecisionString(json['name'], 'DecisionFunctionCall.name'),
        arguments: requireDecisionString(
          json['arguments'],
          'DecisionFunctionCall.arguments',
        ),
        id: json['id'] == null
            ? null
            : requireDecisionString(json['id'], 'DecisionFunctionCall.id'),
        namespace: json['namespace'] == null
            ? null
            : requireDecisionString(
                json['namespace'],
                'DecisionFunctionCall.namespace',
              ),
        status: json['status'] == null
            ? null
            : DecisionToolStatus.fromJson(
                requireDecisionString(
                  json['status'],
                  'DecisionFunctionCall.status',
                ),
              ),
      );
    } on ArgumentError {
      throw const FormatException(
        'DecisionFunctionCall: invalid tool-history field',
      );
    }
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (id != null) 'id': id,
    if (namespace != null) 'namespace': namespace,
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies fields, with explicit null clearing optional metadata.
  DecisionFunctionCall copyWith({
    String? callId,
    String? name,
    String? arguments,
    Object? id = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => DecisionFunctionCall(
    callId: callId ?? this.callId,
    name: name ?? this.name,
    arguments: arguments ?? this.arguments,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    namespace: identical(namespace, unsetCopyWithValue)
        ? this.namespace
        : namespace as String?,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as DecisionToolStatus?,
  );
  @override
  bool operator ==(Object other) =>
      other is DecisionFunctionCall &&
      runtimeType == other.runtimeType &&
      callId == other.callId &&
      name == other.name &&
      arguments == other.arguments &&
      id == other.id &&
      namespace == other.namespace &&
      status == other.status;
  @override
  int get hashCode =>
      Object.hash(runtimeType, callId, name, arguments, id, namespace, status);
  @override
  String toString() =>
      'DecisionFunctionCall(callId: [${callId.length} chars], name: [${name.length} chars], arguments: [${arguments.length} chars], id: ${id == null ? null : "[${id!.length} chars]"}, namespace: ${namespace == null ? null : "[${namespace!.length} chars]"}, status: $status)';
}

/// Typed custom_tool_call evidence; no tool is executed by the client.
@immutable
class DecisionCustomToolCall extends DecisionInputItem {
  /// Creates captured tool history.
  DecisionCustomToolCall({
    required this.callId,
    required this.name,
    required this.input,
    this.id,
    this.namespace,
    this.status,
  }) {
    _validateDecisionHistoryString(callId, 'callId', min: 1, max: 64);
    _validateDecisionHistoryString(
      name,
      'name',
      min: 1,
      max: 64,
      pattern: r'^[a-zA-Z0-9_-]+$',
    );
    if (namespace != null) {
      _validateDecisionHistoryString(
        namespace!,
        'namespace',
        min: 1,
        max: 64,
        pattern: r'^[a-zA-Z0-9_-]+$',
      );
    }
    _validateDecisionHistoryString(input, 'input', max: 1048576);
    if (id != null) _validateDecisionHistoryString(id!, 'id', max: 1048576);
  }

  /// The call_id history field.
  final String callId;

  /// The name history field.
  final String name;

  /// The input history field.
  final String input;

  /// The id history field.
  final String? id;

  /// The namespace history field.
  final String? namespace;

  /// The status history field.
  final DecisionToolStatus? status;
  @override
  String get type => 'custom_tool_call';

  /// Reads a complete tool-history item.
  factory DecisionCustomToolCall.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'custom_tool_call', 'DecisionCustomToolCall');
    try {
      return DecisionCustomToolCall(
        callId: requireDecisionString(
          json['call_id'],
          'DecisionCustomToolCall.call_id',
        ),
        name: requireDecisionString(
          json['name'],
          'DecisionCustomToolCall.name',
        ),
        input: requireDecisionString(
          json['input'],
          'DecisionCustomToolCall.input',
        ),
        id: json['id'] == null
            ? null
            : requireDecisionString(json['id'], 'DecisionCustomToolCall.id'),
        namespace: json['namespace'] == null
            ? null
            : requireDecisionString(
                json['namespace'],
                'DecisionCustomToolCall.namespace',
              ),
        status: json['status'] == null
            ? null
            : DecisionToolStatus.fromJson(
                requireDecisionString(
                  json['status'],
                  'DecisionCustomToolCall.status',
                ),
              ),
      );
    } on ArgumentError {
      throw const FormatException(
        'DecisionCustomToolCall: invalid tool-history field',
      );
    }
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'name': name,
    'input': input,
    if (id != null) 'id': id,
    if (namespace != null) 'namespace': namespace,
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies fields, with explicit null clearing optional metadata.
  DecisionCustomToolCall copyWith({
    String? callId,
    String? name,
    String? input,
    Object? id = unsetCopyWithValue,
    Object? namespace = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => DecisionCustomToolCall(
    callId: callId ?? this.callId,
    name: name ?? this.name,
    input: input ?? this.input,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    namespace: identical(namespace, unsetCopyWithValue)
        ? this.namespace
        : namespace as String?,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as DecisionToolStatus?,
  );
  @override
  bool operator ==(Object other) =>
      other is DecisionCustomToolCall &&
      runtimeType == other.runtimeType &&
      callId == other.callId &&
      name == other.name &&
      input == other.input &&
      id == other.id &&
      namespace == other.namespace &&
      status == other.status;
  @override
  int get hashCode =>
      Object.hash(runtimeType, callId, name, input, id, namespace, status);
  @override
  String toString() =>
      'DecisionCustomToolCall(callId: [${callId.length} chars], name: [${name.length} chars], input: [${input.length} chars], id: ${id == null ? null : "[${id!.length} chars]"}, namespace: ${namespace == null ? null : "[${namespace!.length} chars]"}, status: $status)';
}

/// Typed function_call_output evidence; no tool is executed by the client.
@immutable
class DecisionFunctionCallOutput extends DecisionInputItem {
  /// Creates captured tool history.
  DecisionFunctionCallOutput({
    required this.callId,
    required this.output,
    this.id,
    this.status,
  }) {
    _validateDecisionHistoryString(callId, 'callId', min: 1, max: 64);
    if (id != null) _validateDecisionHistoryString(id!, 'id', max: 1048576);
  }

  /// The call_id history field.
  final String callId;

  /// The output history field.
  final DecisionToolOutput output;

  /// The id history field.
  final String? id;

  /// The status history field.
  final DecisionToolStatus? status;
  @override
  String get type => 'function_call_output';

  /// Reads a complete tool-history item.
  factory DecisionFunctionCallOutput.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'function_call_output',
      'DecisionFunctionCallOutput',
    );
    try {
      return DecisionFunctionCallOutput(
        callId: requireDecisionString(
          json['call_id'],
          'DecisionFunctionCallOutput.call_id',
        ),
        output: DecisionToolOutput.fromJson(json['output']),
        id: json['id'] == null
            ? null
            : requireDecisionString(
                json['id'],
                'DecisionFunctionCallOutput.id',
              ),
        status: json['status'] == null
            ? null
            : DecisionToolStatus.fromJson(
                requireDecisionString(
                  json['status'],
                  'DecisionFunctionCallOutput.status',
                ),
              ),
      );
    } on ArgumentError {
      throw const FormatException(
        'DecisionFunctionCallOutput: invalid tool-history field',
      );
    }
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'output': output.toJson(),
    if (id != null) 'id': id,
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies fields, with explicit null clearing optional metadata.
  DecisionFunctionCallOutput copyWith({
    String? callId,
    DecisionToolOutput? output,
    Object? id = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => DecisionFunctionCallOutput(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as DecisionToolStatus?,
  );
  @override
  bool operator ==(Object other) =>
      other is DecisionFunctionCallOutput &&
      runtimeType == other.runtimeType &&
      callId == other.callId &&
      output == other.output &&
      id == other.id &&
      status == other.status;
  @override
  int get hashCode => Object.hash(runtimeType, callId, output, id, status);
  @override
  String toString() =>
      'DecisionFunctionCallOutput(callId: [${callId.length} chars], output: $output, id: ${id == null ? null : "[${id!.length} chars]"}, status: $status)';
}

/// Typed custom_tool_call_output evidence; no tool is executed by the client.
@immutable
class DecisionCustomToolCallOutput extends DecisionInputItem {
  /// Creates captured tool history.
  DecisionCustomToolCallOutput({
    required this.callId,
    required this.output,
    this.id,
    this.status,
  }) {
    _validateDecisionHistoryString(callId, 'callId', min: 1, max: 64);
    if (id != null) _validateDecisionHistoryString(id!, 'id', max: 1048576);
  }

  /// The call_id history field.
  final String callId;

  /// The output history field.
  final DecisionToolOutput output;

  /// The id history field.
  final String? id;

  /// The status history field.
  final DecisionToolStatus? status;
  @override
  String get type => 'custom_tool_call_output';

  /// Reads a complete tool-history item.
  factory DecisionCustomToolCallOutput.fromJson(Map<String, dynamic> json) {
    requireDecisionType(
      json,
      'custom_tool_call_output',
      'DecisionCustomToolCallOutput',
    );
    try {
      return DecisionCustomToolCallOutput(
        callId: requireDecisionString(
          json['call_id'],
          'DecisionCustomToolCallOutput.call_id',
        ),
        output: DecisionToolOutput.fromJson(json['output']),
        id: json['id'] == null
            ? null
            : requireDecisionString(
                json['id'],
                'DecisionCustomToolCallOutput.id',
              ),
        status: json['status'] == null
            ? null
            : DecisionToolStatus.fromJson(
                requireDecisionString(
                  json['status'],
                  'DecisionCustomToolCallOutput.status',
                ),
              ),
      );
    } on ArgumentError {
      throw const FormatException(
        'DecisionCustomToolCallOutput: invalid tool-history field',
      );
    }
  }
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'call_id': callId,
    'output': output.toJson(),
    if (id != null) 'id': id,
    if (status != null) 'status': status!.toJson(),
  };

  /// Copies fields, with explicit null clearing optional metadata.
  DecisionCustomToolCallOutput copyWith({
    String? callId,
    DecisionToolOutput? output,
    Object? id = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) => DecisionCustomToolCallOutput(
    callId: callId ?? this.callId,
    output: output ?? this.output,
    id: identical(id, unsetCopyWithValue) ? this.id : id as String?,
    status: identical(status, unsetCopyWithValue)
        ? this.status
        : status as DecisionToolStatus?,
  );
  @override
  bool operator ==(Object other) =>
      other is DecisionCustomToolCallOutput &&
      runtimeType == other.runtimeType &&
      callId == other.callId &&
      output == other.output &&
      id == other.id &&
      status == other.status;
  @override
  int get hashCode => Object.hash(runtimeType, callId, output, id, status);
  @override
  String toString() =>
      'DecisionCustomToolCallOutput(callId: [${callId.length} chars], output: $output, id: ${id == null ? null : "[${id!.length} chars]"}, status: $status)';
}

void _validateDecisionHistoryString(
  String value,
  String field, {
  int min = 0,
  required int max,
  String? pattern,
}) {
  final length = value.runes.length;
  if (length < min ||
      length > max ||
      (pattern != null && !RegExp(pattern).hasMatch(value))) {
    throw ArgumentError('Decisions $field: invalid length or characters');
  }
}
