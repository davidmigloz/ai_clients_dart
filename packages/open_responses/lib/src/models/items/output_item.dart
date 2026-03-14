import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../content/output_content.dart';
import '../content/reasoning_summary_content.dart';
import '../metadata/item_status.dart';
import '../metadata/message_role.dart';
import 'item.dart';

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
      'reasoning' => ReasoningItem.fromJson(json),
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

  /// Combined text from all [OutputTextContent] parts.
  ///
  /// Returns `null` if there are no text content parts.
  String? get text {
    final texts = content.whereType<OutputTextContent>().map((c) => c.text);
    return texts.isEmpty ? null : texts.join();
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
  int get hashCode => Object.hash(id, role, Object.hashAll(content), status);

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
