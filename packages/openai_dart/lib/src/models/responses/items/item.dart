import 'dart:convert';

import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../config/function_call_status.dart';
import '../config/item_status.dart';
import '../config/message_role.dart';
import '../content/input_content.dart';

/// Input item for a response request.
///
/// This is a sealed class hierarchy for different input item types.
sealed class Item {
  /// Creates an [Item].
  const Item();

  /// Creates an [Item] from JSON.
  factory Item.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'message' => MessageItem.fromJson(json),
      'function_call' => FunctionCallItem.fromJson(json),
      'function_call_output' => FunctionCallOutputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A message item in a conversation.
@immutable
class MessageItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The role of the message.
  final MessageRole role;

  /// The content of the message.
  final List<InputContent> content;

  /// Item status (for output items).
  final ItemStatus? status;

  /// Creates a [MessageItem].
  const MessageItem({
    this.id,
    required this.role,
    required this.content,
    this.status,
  });

  /// Creates a user message.
  factory MessageItem.user(List<InputContent> content) =>
      MessageItem(role: MessageRole.user, content: content);

  /// Creates a user message with simple text.
  factory MessageItem.userText(String text) =>
      MessageItem(role: MessageRole.user, content: [InputContent.text(text)]);

  /// Creates a system message.
  factory MessageItem.system(List<InputContent> content) =>
      MessageItem(role: MessageRole.system, content: content);

  /// Creates a system message with simple text.
  factory MessageItem.systemText(String text) =>
      MessageItem(role: MessageRole.system, content: [InputContent.text(text)]);

  /// Creates a developer message.
  factory MessageItem.developer(List<InputContent> content) =>
      MessageItem(role: MessageRole.developer, content: content);

  /// Creates a developer message with simple text.
  factory MessageItem.developerText(String text) => MessageItem(
    role: MessageRole.developer,
    content: [InputContent.text(text)],
  );

  /// Creates an assistant message.
  factory MessageItem.assistant(List<InputContent> content) =>
      MessageItem(role: MessageRole.assistant, content: content);

  /// Creates an assistant message with simple text.
  ///
  /// Uses [AssistantTextContent] which serializes as `output_text`,
  /// as required by the API for assistant messages in multi-turn conversations.
  factory MessageItem.assistantText(String text) => MessageItem(
    role: MessageRole.assistant,
    content: [InputContent.assistantText(text)],
  );

  /// Creates a [MessageItem] from JSON.
  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'] as String?,
      role: MessageRole.fromJson(json['role'] as String),
      content: (json['content'] as List)
          .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] != null
          ? ItemStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'message',
    if (id != null) 'id': id,
    'role': role.toJson(),
    'content': content.map((e) => e.toJson()).toList(),
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          role == other.role &&
          listsEqual(content, other.content) &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, role, Object.hashAll(content), status);

  @override
  String toString() =>
      'MessageItem(id: $id, role: $role, content: $content, status: $status)';
}

/// A function call item.
@immutable
class FunctionCallItem extends Item {
  /// Unique identifier.
  final String? id;

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
        'FunctionCallItem.arguments must be a JSON object',
      );
    }
    return decoded.cast<String, dynamic>();
  }

  /// Item status (for output items).
  final ItemStatus? status;

  /// Creates a [FunctionCallItem].
  const FunctionCallItem({
    this.id,
    required this.callId,
    required this.name,
    required this.arguments,
    this.status,
  });

  /// Creates a [FunctionCallItem] from JSON.
  factory FunctionCallItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallItem(
      id: json['id'] as String?,
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
    if (id != null) 'id': id,
    'call_id': callId,
    'name': name,
    'arguments': arguments,
    if (status != null) 'status': status!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallItem &&
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
      'FunctionCallItem(id: $id, callId: $callId, name: $name, arguments: $arguments, status: $status)';
}

/// The output of a function call.
///
/// Can be either a simple string or a list of content items.
sealed class FunctionCallOutput {
  /// Creates a [FunctionCallOutput].
  const FunctionCallOutput();

  /// Creates a [FunctionCallOutput] from JSON.
  factory FunctionCallOutput.fromJson(Object json) {
    if (json is String) {
      return FunctionCallOutputString(json);
    }
    if (json is List) {
      return FunctionCallOutputContent(
        json
            .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid FunctionCallOutput format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// A string output from a function call.
@immutable
class FunctionCallOutputString extends FunctionCallOutput {
  /// The string output.
  final String value;

  /// Creates a [FunctionCallOutputString].
  const FunctionCallOutputString(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'FunctionCallOutputString($value)';
}

/// A list of content items output from a function call.
@immutable
class FunctionCallOutputContent extends FunctionCallOutput {
  /// The content items.
  final List<InputContent> content;

  /// Creates a [FunctionCallOutputContent].
  const FunctionCallOutputContent(this.content);

  @override
  Object toJson() => content.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputContent &&
          runtimeType == other.runtimeType &&
          listsEqual(content, other.content);

  @override
  int get hashCode => Object.hashAll(content);

  @override
  String toString() => 'FunctionCallOutputContent($content)';
}

/// A function call output item.
@immutable
class FunctionCallOutputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The call ID this output corresponds to.
  final String callId;

  /// The output content.
  final FunctionCallOutput output;

  /// The status of the function call.
  final FunctionCallStatus? status;

  /// Creates a [FunctionCallOutputItem].
  const FunctionCallOutputItem({
    this.id,
    required this.callId,
    required this.output,
    this.status,
  });

  /// Creates a [FunctionCallOutputItem] with a simple string output.
  factory FunctionCallOutputItem.string({
    String? id,
    required String callId,
    required String output,
    FunctionCallStatus? status,
  }) {
    return FunctionCallOutputItem(
      id: id,
      callId: callId,
      output: FunctionCallOutputString(output),
      status: status,
    );
  }

  /// Creates a [FunctionCallOutputItem] from JSON.
  factory FunctionCallOutputItem.fromJson(Map<String, dynamic> json) {
    return FunctionCallOutputItem(
      id: json['id'] as String?,
      callId: json['call_id'] as String,
      output: FunctionCallOutput.fromJson(json['output']),
      status: json['status'] != null
          ? FunctionCallStatus.fromJson(json['status'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'function_call_output',
    if (id != null) 'id': id,
    'call_id': callId,
    'output': output.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with updated fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  FunctionCallOutputItem copyWith({
    Object? id = unsetCopyWithValue,
    String? callId,
    FunctionCallOutput? output,
    Object? status = unsetCopyWithValue,
  }) {
    return FunctionCallOutputItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      callId: callId ?? this.callId,
      output: output ?? this.output,
      status: status == unsetCopyWithValue
          ? this.status
          : status as FunctionCallStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCallOutputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          callId == other.callId &&
          output == other.output &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, callId, output, status);

  @override
  String toString() =>
      'FunctionCallOutputItem(id: $id, callId: $callId, output: $output, status: $status)';
}

/// Reference to a previously created item.
@immutable
class ItemReference extends Item {
  /// The ID of the referenced item.
  final String id;

  /// Creates an [ItemReference].
  const ItemReference({required this.id});

  /// Creates an [ItemReference] from JSON.
  factory ItemReference.fromJson(Map<String, dynamic> json) {
    return ItemReference(id: json['id'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': 'item_reference', 'id': id};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemReference &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ItemReference(id: $id)';
}
