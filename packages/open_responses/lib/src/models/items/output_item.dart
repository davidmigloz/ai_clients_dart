import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../content/input_content.dart';
import '../content/message_content_part.dart';
import '../content/output_content.dart';
import '../content/reasoning_summary_content.dart';
import '../metadata/function_call_status.dart';
import '../metadata/item_status.dart';
import '../metadata/message_phase.dart';
import '../metadata/message_role.dart';
import 'item.dart';

/// Parses a single content part of a response-side `Message`.
///
/// Dispatches to [InputContent] for `input_*` types and to [OutputContent]
/// for everything else (`output_text`, `reasoning_text`, `summary_text`,
/// `refusal`).
MessageContentPart _parseMessageContentPart(Map<String, dynamic> json) {
  final type = json['type'] as String;
  if (type.startsWith('input_')) {
    return InputContent.fromJson(json);
  }
  return OutputContent.fromJson(json);
}

/// Output item from a response.
///
/// This is a sealed class hierarchy for different output item types.
sealed class OutputItem {
  /// Creates an [OutputItem].
  const OutputItem();

  /// Creates an [OutputItem] from JSON.
  factory OutputItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageOutputItem.fromJson(json),
      'function_call' => FunctionCallOutputItemResponse.fromJson(json),
      'function_call_output' => FunctionCallOutputResponseItem.fromJson(json),
      'reasoning' => ReasoningItem.fromJson(json),
      'compaction' => CompactionOutputItem.fromJson(json),
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
  ///
  /// Per the spec's `Message.content` union, response messages may carry both
  /// [InputContent] parts (e.g. `input_text` for echoed-back user messages in
  /// stored or compacted history) and [OutputContent] parts (e.g.
  /// `output_text` for model responses). Use type guards on the leaf types to
  /// inspect specific content kinds.
  final List<MessageContentPart> content;

  /// Item status.
  final ItemStatus? status;

  /// Labels this assistant message as intermediate commentary or the final
  /// answer.
  ///
  /// Preserve and resend on follow-up requests for compatible models — see
  /// [MessagePhase] for details. Not used for non-assistant messages.
  final MessagePhase? phase;

  /// Creates a [MessageOutputItem].
  const MessageOutputItem({
    required this.id,
    required this.role,
    required this.content,
    this.status,
    this.phase,
  });

  /// Creates a [MessageOutputItem] from JSON.
  factory MessageOutputItem.fromJson(Map<String, dynamic> json) {
    return MessageOutputItem(
      id: json['id'] as String,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => _parseMessageContentPart(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
      phase: json['phase'] != null
          ? MessagePhase.fromJson(json['phase'] as String)
          : null,
    );
  }

  /// Combined text from all text content parts in this message.
  ///
  /// Includes both [OutputTextContent] (model output) and [InputTextContent]
  /// (echoed user input in stored or compacted history). Returns `null` if
  /// there are no text content parts.
  String? get text {
    final buffer = StringBuffer();
    for (final part in content) {
      if (part is OutputTextContent) {
        buffer.write(part.text);
      } else if (part is InputTextContent) {
        buffer.write(part.text);
      }
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  /// Whether any content part is a refusal.
  bool get hasRefusal => content.any((c) => c is RefusalContent);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    'id': id,
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
    if (phase != null) 'phase': phase!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status &&
          phase == other.phase;

  @override
  int get hashCode =>
      Object.hash(id, role, Object.hashAll(content), status, phase);

  @override
  String toString() =>
      'MessageOutputItem(id: $id, role: $role, content: $content, status: $status, phase: $phase)';
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

  /// Whether this function call is completed.
  bool get isCompleted => status == ItemStatus.completed;

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
  /// Contains a list of content parts that make up the reasoning. Each item
  /// can be of various types (text, image, file, etc.) based on the model's
  /// reasoning output.
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
          listOfMapsDeepEqual(content, other.content) &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode => Object.hash(
    id,
    listOfMapsHashCode(content),
    Object.hashAll(summary),
    encryptedContent,
  );

  @override
  String toString() =>
      'ReasoningItem(id: $id, content: $content, summary: $summary, encryptedContent: $encryptedContent)';
}

/// A compaction item produced by the `/responses/compact` endpoint.
///
/// Carries the encrypted summary that can be replayed in a new request via
/// [CompactionItem] to preserve previous turns without resending the full
/// transcript.
@immutable
class CompactionOutputItem extends OutputItem {
  /// Unique identifier of the compaction item.
  final String id;

  /// The encrypted content produced by compaction.
  final String encryptedContent;

  /// The identifier of the actor that created the item.
  final String? createdBy;

  /// Creates a [CompactionOutputItem].
  const CompactionOutputItem({
    required this.id,
    required this.encryptedContent,
    this.createdBy,
  });

  /// Creates a [CompactionOutputItem] from JSON.
  factory CompactionOutputItem.fromJson(Map<String, dynamic> json) {
    return CompactionOutputItem(
      id: json['id'] as String,
      encryptedContent: json['encrypted_content'] as String,
      createdBy: json['created_by'] as String?,
    );
  }

  /// Converts to a [CompactionItem] for use as input in subsequent requests.
  CompactionItem toCompactionItem() =>
      CompactionItem(id: id, encryptedContent: encryptedContent);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'compaction',
    'id': id,
    'encrypted_content': encryptedContent,
    if (createdBy != null) 'created_by': createdBy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          encryptedContent == other.encryptedContent &&
          createdBy == other.createdBy;

  @override
  int get hashCode => Object.hash(id, encryptedContent, createdBy);

  @override
  String toString() =>
      'CompactionOutputItem(id: $id, encryptedContent: [${encryptedContent.length} chars], createdBy: $createdBy)';
}

/// A function call output item echoed back as part of a response's output.
///
/// Carries the result of a previously-submitted function call (the same shape
/// as the user-sent [FunctionCallOutputItem]) so it can appear in stored or
/// compacted response history.
@immutable
class FunctionCallOutputResponseItem extends OutputItem {
  /// Unique identifier.
  final String id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final FunctionCallOutput output;

  /// The status of the function call output.
  final FunctionCallStatus? status;

  /// Creates a [FunctionCallOutputResponseItem].
  const FunctionCallOutputResponseItem({
    required this.id,
    required this.callId,
    required this.output,
    this.status,
  });

  /// Creates a [FunctionCallOutputResponseItem] from JSON.
  factory FunctionCallOutputResponseItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputResponseItem(
      id: json['id'] as String,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? FunctionCallStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  /// Converts to a [FunctionCallOutputItem] for use as input.
  FunctionCallOutputItem toFunctionCallOutputItem() => FunctionCallOutputItem(
    id: id,
    callId: callId,
    output: output,
    status: status,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call_output',
    'id': id,
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputResponseItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          output == other.output &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, output, status);

  @override
  String toString() =>
      'FunctionCallOutputResponseItem(id: $id, callId: $callId, output: $output, status: $status)';
}
