import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../content/input_content.dart';
import '../content/output_content.dart';
import '../content/reasoning_summary_content.dart';
import '../metadata/function_call_status.dart';
import '../metadata/item_status.dart';
import '../metadata/message_role.dart';

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
      'reasoning' => ReasoningInputItem.fromJson(json),
      'item_reference' => ItemReference.fromJson(json),
      _ => throw FormatException('Unknown Item type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A message item in a conversation.
///
/// This is a sealed class hierarchy dispatched by [role]:
/// - [UserMessageItem] — role `user`
/// - [SystemMessageItem] — role `system`
/// - [DeveloperMessageItem] — role `developer`
/// - [AssistantMessageItem] — role `assistant`
sealed class MessageItem extends Item {
  /// Unique identifier.
  String? get id;

  /// The role of the message.
  MessageRole get role;

  /// Item status (for output items).
  ItemStatus? get status;

  /// Creates a [MessageItem].
  const MessageItem();

  /// Creates a user message.
  static MessageItem user(
    List<InputContent> content, {
    String? id,
    ItemStatus? status,
  }) => UserMessageItem(
    content: UserMessagePartsContent(content),
    id: id,
    status: status,
  );

  /// Creates a user message with simple text.
  static MessageItem userText(String text, {String? id, ItemStatus? status}) =>
      UserMessageItem(
        content: UserMessageTextContent(text),
        id: id,
        status: status,
      );

  /// Creates a system message.
  static MessageItem system(
    List<InputTextContent> content, {
    String? id,
    ItemStatus? status,
  }) => SystemMessageItem(
    content: content.map((c) => c.text).join(),
    id: id,
    status: status,
  );

  /// Creates a system message with simple text.
  static MessageItem systemText(
    String text, {
    String? id,
    ItemStatus? status,
  }) => SystemMessageItem(content: text, id: id, status: status);

  /// Creates a developer message.
  static MessageItem developer(
    List<InputTextContent> content, {
    String? id,
    ItemStatus? status,
  }) => DeveloperMessageItem(
    content: content.map((c) => c.text).join(),
    id: id,
    status: status,
  );

  /// Creates a developer message with simple text.
  static MessageItem developerText(
    String text, {
    String? id,
    ItemStatus? status,
  }) => DeveloperMessageItem(content: text, id: id, status: status);

  /// Creates an assistant message.
  static MessageItem assistant(
    List<OutputContent> content, {
    String? id,
    ItemStatus? status,
  }) => AssistantMessageItem(
    content: AssistantMessagePartsContent(content),
    id: id,
    status: status,
  );

  /// Creates an assistant message with simple text.
  static MessageItem assistantText(
    String text, {
    String? id,
    ItemStatus? status,
  }) => AssistantMessageItem(
    content: AssistantMessageTextContent(text),
    id: id,
    status: status,
  );

  /// Creates a [MessageItem] from JSON.
  factory MessageItem.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String;
    return switch (role) {
      'user' => UserMessageItem.fromJson(json),
      'system' => SystemMessageItem.fromJson(json),
      'developer' => DeveloperMessageItem.fromJson(json),
      'assistant' => AssistantMessageItem.fromJson(json),
      _ => throw FormatException('Unknown MessageItem role: $role'),
    };
  }
}

/// Content for a user message.
///
/// Supports two representations internally ([UserMessageTextContent] and
/// [UserMessagePartsContent]), but always serializes to a list of content
/// parts in JSON. Use [fromJson] to deserialize from either a plain string
/// or a list of content objects.
sealed class UserMessageContent {
  /// Creates a [UserMessageContent].
  const UserMessageContent();

  /// Creates a text content.
  static UserMessageContent fromText(String text) =>
      UserMessageTextContent(text);

  /// Creates a parts content.
  static UserMessageContent parts(List<InputContent> parts) =>
      UserMessagePartsContent(parts);

  /// Extracts the text from this content.
  ///
  /// For [UserMessageTextContent], returns the text directly.
  /// For [UserMessagePartsContent], joins all [InputTextContent] parts.
  String? get text;

  /// Creates a [UserMessageContent] from JSON.
  factory UserMessageContent.fromJson(Object json) {
    if (json is String) return UserMessageTextContent(json);
    if (json is List) {
      return UserMessagePartsContent(
        json
            .map((e) => InputContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid UserMessageContent format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// Simple text content for a user message.
@immutable
class UserMessageTextContent extends UserMessageContent {
  /// The text content.
  final String value;

  /// Creates a [UserMessageTextContent].
  const UserMessageTextContent(this.value);

  @override
  String get text => value;

  @override
  Object toJson() => [
    {'type': 'input_text', 'text': value},
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessageTextContent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'UserMessageTextContent($value)';
}

/// List of input content parts for a user message.
@immutable
class UserMessagePartsContent extends UserMessageContent {
  /// The content parts.
  final List<InputContent> parts;

  /// Creates a [UserMessagePartsContent].
  const UserMessagePartsContent(this.parts);

  @override
  String? get text {
    final texts = parts.whereType<InputTextContent>().map((c) => c.text);
    return texts.isEmpty ? null : texts.join();
  }

  @override
  Object toJson() => parts.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessagePartsContent &&
          runtimeType == other.runtimeType &&
          listsEqual(parts, other.parts);

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'UserMessagePartsContent($parts)';
}

/// Content for an assistant message.
///
/// Can be either a simple text string or a list of output content parts.
sealed class AssistantMessageContent {
  /// Creates an [AssistantMessageContent].
  const AssistantMessageContent();

  /// Creates a text content.
  static AssistantMessageContent fromText(String text) =>
      AssistantMessageTextContent(text);

  /// Creates a parts content.
  static AssistantMessageContent parts(List<OutputContent> parts) =>
      AssistantMessagePartsContent(parts);

  /// Extracts the text from this content.
  ///
  /// For [AssistantMessageTextContent], returns the text directly.
  /// For [AssistantMessagePartsContent], joins all [OutputTextContent] parts.
  String? get text;

  /// Creates an [AssistantMessageContent] from JSON.
  factory AssistantMessageContent.fromJson(Object json) {
    if (json is String) return AssistantMessageTextContent(json);
    if (json is List) {
      return AssistantMessagePartsContent(
        json
            .map((e) => OutputContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw FormatException('Invalid AssistantMessageContent format: $json');
  }

  /// Converts to JSON.
  Object toJson();
}

/// Simple text content for an assistant message.
@immutable
class AssistantMessageTextContent extends AssistantMessageContent {
  /// The text content.
  final String value;

  /// Creates an [AssistantMessageTextContent].
  const AssistantMessageTextContent(this.value);

  @override
  String get text => value;

  @override
  Object toJson() => [
    {'type': 'output_text', 'text': value},
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessageTextContent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AssistantMessageTextContent($value)';
}

/// List of output content parts for an assistant message.
@immutable
class AssistantMessagePartsContent extends AssistantMessageContent {
  /// The content parts.
  final List<OutputContent> parts;

  /// Creates an [AssistantMessagePartsContent].
  const AssistantMessagePartsContent(this.parts);

  @override
  String? get text {
    final texts = parts.whereType<OutputTextContent>().map((c) => c.text);
    return texts.isEmpty ? null : texts.join();
  }

  @override
  Object toJson() => parts.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessagePartsContent &&
          runtimeType == other.runtimeType &&
          listsEqual(parts, other.parts);

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'AssistantMessagePartsContent($parts)';
}

/// A user message item.
@immutable
class UserMessageItem extends MessageItem {
  @override
  final String? id;

  @override
  MessageRole get role => MessageRole.user;

  /// The content of the message.
  final UserMessageContent content;

  @override
  final ItemStatus? status;

  /// Creates a [UserMessageItem].
  const UserMessageItem({this.id, required this.content, this.status});

  /// Creates a [UserMessageItem] from JSON.
  factory UserMessageItem.fromJson(Map<String, dynamic> json) {
    return UserMessageItem(
      id: json['id'] as String?,
      content: UserMessageContent.fromJson(json['content']),
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
    'content': content.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with replaced values.
  UserMessageItem copyWith({
    Object? id = unsetCopyWithValue,
    UserMessageContent? content,
    Object? status = unsetCopyWithValue,
  }) {
    return UserMessageItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      content: content ?? this.content,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ItemStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, content, status);

  @override
  String toString() =>
      'UserMessageItem(id: $id, content: $content, status: $status)';
}

/// A system message item.
@immutable
class SystemMessageItem extends MessageItem {
  @override
  final String? id;

  @override
  MessageRole get role => MessageRole.system;

  /// The content of the message.
  ///
  /// System messages only support text content. When deserializing from JSON,
  /// a list of `input_text` items is joined into a single string.
  final String content;

  @override
  final ItemStatus? status;

  /// Creates a [SystemMessageItem].
  const SystemMessageItem({this.id, required this.content, this.status});

  /// Creates a [SystemMessageItem] from JSON.
  factory SystemMessageItem.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final String text;
    if (content is String) {
      text = content;
    } else if (content is List) {
      text = content.map((e) {
        final part = e as Map<String, dynamic>;
        final partText = part['text'] as String?;
        if (partText == null) {
          throw FormatException(
            'SystemMessageItem content part missing "text": $part',
          );
        }
        return partText;
      }).join();
    } else {
      throw FormatException('Invalid SystemMessageItem content: $content');
    }
    return SystemMessageItem(
      id: json['id'] as String?,
      content: text,
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
    'content': [
      {'type': 'input_text', 'text': content},
    ],
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with replaced values.
  SystemMessageItem copyWith({
    Object? id = unsetCopyWithValue,
    String? content,
    Object? status = unsetCopyWithValue,
  }) {
    return SystemMessageItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      content: content ?? this.content,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ItemStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, content, status);

  @override
  String toString() =>
      'SystemMessageItem(id: $id, content: $content, status: $status)';
}

/// A developer message item.
@immutable
class DeveloperMessageItem extends MessageItem {
  @override
  final String? id;

  @override
  MessageRole get role => MessageRole.developer;

  /// The content of the message.
  ///
  /// Developer messages only support text content. When deserializing from JSON,
  /// a list of `input_text` items is joined into a single string.
  final String content;

  @override
  final ItemStatus? status;

  /// Creates a [DeveloperMessageItem].
  const DeveloperMessageItem({this.id, required this.content, this.status});

  /// Creates a [DeveloperMessageItem] from JSON.
  factory DeveloperMessageItem.fromJson(Map<String, dynamic> json) {
    final content = json['content'];
    final String text;
    if (content is String) {
      text = content;
    } else if (content is List) {
      text = content.map((e) {
        final part = e as Map<String, dynamic>;
        final partText = part['text'] as String?;
        if (partText == null) {
          throw FormatException(
            'DeveloperMessageItem content part missing "text": $part',
          );
        }
        return partText;
      }).join();
    } else {
      throw FormatException('Invalid DeveloperMessageItem content: $content');
    }
    return DeveloperMessageItem(
      id: json['id'] as String?,
      content: text,
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
    'content': [
      {'type': 'input_text', 'text': content},
    ],
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with replaced values.
  DeveloperMessageItem copyWith({
    Object? id = unsetCopyWithValue,
    String? content,
    Object? status = unsetCopyWithValue,
  }) {
    return DeveloperMessageItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      content: content ?? this.content,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ItemStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeveloperMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, content, status);

  @override
  String toString() =>
      'DeveloperMessageItem(id: $id, content: $content, status: $status)';
}

/// An assistant message item.
@immutable
class AssistantMessageItem extends MessageItem {
  @override
  final String? id;

  @override
  MessageRole get role => MessageRole.assistant;

  /// The content of the message.
  final AssistantMessageContent content;

  @override
  final ItemStatus? status;

  /// Creates an [AssistantMessageItem].
  const AssistantMessageItem({this.id, required this.content, this.status});

  /// Creates an [AssistantMessageItem] from JSON.
  factory AssistantMessageItem.fromJson(Map<String, dynamic> json) {
    return AssistantMessageItem(
      id: json['id'] as String?,
      content: AssistantMessageContent.fromJson(json['content']),
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
    'content': content.toJson(),
    if (status != null) 'status': status!.toJson(),
  };

  /// Creates a copy with replaced values.
  AssistantMessageItem copyWith({
    Object? id = unsetCopyWithValue,
    AssistantMessageContent? content,
    Object? status = unsetCopyWithValue,
  }) {
    return AssistantMessageItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      content: content ?? this.content,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ItemStatus?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantMessageItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, content, status);

  @override
  String toString() =>
      'AssistantMessageItem(id: $id, content: $content, status: $status)';
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

  /// Creates a copy with replaced values.
  FunctionCallItem copyWith({
    Object? id = unsetCopyWithValue,
    String? callId,
    String? name,
    String? arguments,
    Object? status = unsetCopyWithValue,
  }) {
    return FunctionCallItem(
      id: id == unsetCopyWithValue ? this.id : id as String?,
      callId: callId ?? this.callId,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      status: status == unsetCopyWithValue
          ? this.status
          : status as ItemStatus?,
    );
  }

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

  /// Creates a copy with replaced values.
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

  /// Creates a copy with replaced values.
  ItemReference copyWith({String? id}) {
    return ItemReference(id: id ?? this.id);
  }

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

/// A reasoning item used as input for multi-turn conversations.
///
/// This allows passing reasoning output back as input to maintain
/// reasoning context across turns.
@immutable
class ReasoningInputItem extends Item {
  /// Unique identifier.
  final String? id;

  /// The reasoning summary content.
  final List<ReasoningSummaryContent> summary;

  /// Encrypted reasoning content for opaque context passing.
  final String? encryptedContent;

  /// Creates a [ReasoningInputItem].
  const ReasoningInputItem({
    this.id,
    required this.summary,
    this.encryptedContent,
  });

  /// Creates a [ReasoningInputItem] from JSON.
  factory ReasoningInputItem.fromJson(Map<String, dynamic> json) {
    return ReasoningInputItem(
      id: json['id'] as String?,
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
    if (id != null) 'id': id,
    'summary': summary.map((e) => e.toJson()).toList(),
    if (encryptedContent != null) 'encrypted_content': encryptedContent,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReasoningInputItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listsEqual(summary, other.summary) &&
          encryptedContent == other.encryptedContent;

  @override
  int get hashCode =>
      Object.hash(id, Object.hashAll(summary), encryptedContent);

  @override
  String toString() =>
      'ReasoningInputItem(id: $id, summary: $summary, encryptedContent: $encryptedContent)';
}
