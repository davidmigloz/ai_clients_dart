import 'package:meta/meta.dart';

import '../assistants/tool_resources.dart';
import '../common/copy_with_sentinel.dart';
import '../responses/common/equality_helpers.dart';

/// A thread representing a conversation with an assistant.
///
/// Threads store the message history and can be used across multiple runs.
///
/// ## Example
///
/// ```dart
/// final thread = await client.threads.create(
///   CreateThreadRequest(
///     messages: [
///       ThreadMessage.user('Hello!'),
///     ],
///   ),
/// );
/// ```
@immutable
class Thread {
  /// Creates a [Thread].
  const Thread({
    required this.id,
    required this.object,
    required this.createdAt,
    this.toolResources,
    required this.metadata,
  });

  /// Creates a [Thread] from JSON.
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
    );
  }

  /// The thread identifier.
  final String id;

  /// The object type (always "thread").
  final String object;

  /// The Unix timestamp when the thread was created.
  final int createdAt;

  /// Tool resources available to the thread.
  final ToolResources? toolResources;

  /// Custom metadata for the thread.
  final Map<String, String> metadata;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// Creates a copy with the given fields replaced.
  Thread copyWith({
    String? id,
    String? object,
    int? createdAt,
    Object? toolResources = unsetCopyWithValue,
    Map<String, String>? metadata,
  }) {
    return Thread(
      id: id ?? this.id,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      toolResources: toolResources == unsetCopyWithValue
          ? this.toolResources
          : toolResources as ToolResources?,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Thread &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          toolResources == other.toolResources &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    id,
    object,
    createdAt,
    toolResources,
    Object.hashAll(metadata.entries),
  );

  @override
  String toString() =>
      'Thread(id: $id, object: $object, createdAt: $createdAt, '
      'toolResources: $toolResources, metadata: ${metadata.length} entries)';
}

/// A request to create a thread.
@immutable
class CreateThreadRequest {
  /// Creates a [CreateThreadRequest].
  const CreateThreadRequest({this.messages, this.toolResources, this.metadata});

  /// Creates a [CreateThreadRequest] from JSON.
  factory CreateThreadRequest.fromJson(Map<String, dynamic> json) {
    return CreateThreadRequest(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ThreadMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Initial messages to add to the thread.
  final List<ThreadMessage>? messages;

  /// Tool resources for the thread.
  final ToolResources? toolResources;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (messages != null) 'messages': messages!.map((m) => m.toJson()).toList(),
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateThreadRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(messages, metadata);

  @override
  String toString() => 'CreateThreadRequest(${messages?.length ?? 0} messages)';
}

/// A request to modify a thread.
@immutable
class ModifyThreadRequest {
  /// Creates a [ModifyThreadRequest].
  const ModifyThreadRequest({this.toolResources, this.metadata});

  /// Creates a [ModifyThreadRequest] from JSON.
  factory ModifyThreadRequest.fromJson(Map<String, dynamic> json) {
    return ModifyThreadRequest(
      toolResources: json['tool_resources'] != null
          ? ToolResources.fromJson(
              json['tool_resources'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Tool resources for the thread.
  final ToolResources? toolResources;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (toolResources != null) 'tool_resources': toolResources!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModifyThreadRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(toolResources, metadata);

  @override
  String toString() => 'ModifyThreadRequest()';
}

/// The response from deleting a thread.
@immutable
class DeleteThreadResponse {
  /// Creates a [DeleteThreadResponse].
  const DeleteThreadResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteThreadResponse] from JSON.
  factory DeleteThreadResponse.fromJson(Map<String, dynamic> json) {
    return DeleteThreadResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted thread.
  final String id;

  /// The object type.
  final String object;

  /// Whether the thread was deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteThreadResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteThreadResponse(id: $id, deleted: $deleted)';
}

/// A message to add to a thread during creation.
@immutable
class ThreadMessage {
  /// Creates a [ThreadMessage].
  const ThreadMessage({
    required this.role,
    required this.content,
    this.attachments,
    this.metadata,
  });

  /// Creates a [ThreadMessage] from JSON.
  factory ThreadMessage.fromJson(Map<String, dynamic> json) {
    return ThreadMessage(
      role: json['role'] as String,
      content: json['content'],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Creates a user message.
  factory ThreadMessage.user(
    Object content, {
    List<MessageAttachment>? attachments,
    Map<String, String>? metadata,
  }) {
    return ThreadMessage(
      role: 'user',
      content: content,
      attachments: attachments,
      metadata: metadata,
    );
  }

  /// Creates an assistant message.
  factory ThreadMessage.assistant(
    Object content, {
    List<MessageAttachment>? attachments,
    Map<String, String>? metadata,
  }) {
    return ThreadMessage(
      role: 'assistant',
      content: content,
      attachments: attachments,
      metadata: metadata,
    );
  }

  /// The role of the message author.
  final String role;

  /// The content of the message.
  ///
  /// Can be a string or an array of content parts.
  final Object content;

  /// File attachments for this message.
  final List<MessageAttachment>? attachments;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    if (attachments != null)
      'attachments': attachments!.map((a) => a.toJson()).toList(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadMessage &&
          runtimeType == other.runtimeType &&
          role == other.role;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'ThreadMessage(role: $role)';
}

/// A file attachment for a message.
@immutable
class MessageAttachment {
  /// Creates a [MessageAttachment].
  const MessageAttachment({required this.fileId, this.tools});

  /// Creates a [MessageAttachment] from JSON.
  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      fileId: json['file_id'] as String,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => AttachmentTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The file ID.
  final String fileId;

  /// Tools that can use this file.
  final List<AttachmentTool>? tools;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    if (tools != null) 'tools': tools!.map((t) => t.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAttachment &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'MessageAttachment(fileId: $fileId)';
}

/// A tool specification for a message attachment.
sealed class AttachmentTool {
  /// Creates an [AttachmentTool] from JSON.
  factory AttachmentTool.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'code_interpreter' => const CodeInterpreterAttachmentTool(),
      'file_search' => const FileSearchAttachmentTool(),
      _ => throw FormatException('Unknown tool type: $type'),
    };
  }

  /// Creates a code interpreter tool.
  static AttachmentTool codeInterpreter() =>
      const CodeInterpreterAttachmentTool();

  /// Creates a file search tool.
  static AttachmentTool fileSearch() => const FileSearchAttachmentTool();

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Code interpreter tool for attachments.
@immutable
class CodeInterpreterAttachmentTool implements AttachmentTool {
  /// Creates a [CodeInterpreterAttachmentTool].
  const CodeInterpreterAttachmentTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'code_interpreter'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterAttachmentTool &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => 'code_interpreter'.hashCode;

  @override
  String toString() => 'CodeInterpreterAttachmentTool()';
}

/// File search tool for attachments.
@immutable
class FileSearchAttachmentTool implements AttachmentTool {
  /// Creates a [FileSearchAttachmentTool].
  const FileSearchAttachmentTool();

  @override
  Map<String, dynamic> toJson() => {'type': 'file_search'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileSearchAttachmentTool && runtimeType == other.runtimeType;

  @override
  int get hashCode => 'file_search'.hashCode;

  @override
  String toString() => 'FileSearchAttachmentTool()';
}
