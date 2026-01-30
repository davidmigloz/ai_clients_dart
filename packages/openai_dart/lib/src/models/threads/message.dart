import 'package:meta/meta.dart';

import 'thread.dart';

/// A message in a thread.
///
/// Messages contain the content of a conversation between the user
/// and an assistant.
@immutable
class Message {
  /// Creates a [Message].
  const Message({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.threadId,
    this.status,
    this.incompleteDetails,
    this.completedAt,
    this.incompleteAt,
    required this.role,
    required this.content,
    this.assistantId,
    this.runId,
    required this.attachments,
    required this.metadata,
  });

  /// Creates a [Message] from JSON.
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      threadId: json['thread_id'] as String,
      status: json['status'] != null
          ? MessageStatus.fromJson(json['status'] as String)
          : null,
      incompleteDetails: json['incomplete_details'] != null
          ? IncompleteDetails.fromJson(
              json['incomplete_details'] as Map<String, dynamic>,
            )
          : null,
      completedAt: json['completed_at'] as int?,
      incompleteAt: json['incomplete_at'] as int?,
      role: json['role'] as String,
      content: (json['content'] as List<dynamic>)
          .map((e) => MessageContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      assistantId: json['assistant_id'] as String?,
      runId: json['run_id'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map(
                (e) => MessageAttachment.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
    );
  }

  /// The message identifier.
  final String id;

  /// The object type (always "thread.message").
  final String object;

  /// The Unix timestamp when the message was created.
  final int createdAt;

  /// The thread ID this message belongs to.
  final String threadId;

  /// The status of the message.
  final MessageStatus? status;

  /// Details about why the message is incomplete.
  final IncompleteDetails? incompleteDetails;

  /// The Unix timestamp when the message was completed.
  final int? completedAt;

  /// The Unix timestamp when the message became incomplete.
  final int? incompleteAt;

  /// The role of the message author ("user" or "assistant").
  final String role;

  /// The content of the message.
  final List<MessageContent> content;

  /// The assistant ID if this is an assistant message.
  final String? assistantId;

  /// The run ID that generated this message.
  final String? runId;

  /// File attachments.
  final List<MessageAttachment> attachments;

  /// Custom metadata.
  final Map<String, String> metadata;

  /// Whether this is a user message.
  bool get isUser => role == 'user';

  /// Whether this is an assistant message.
  bool get isAssistant => role == 'assistant';

  /// Whether the message is complete.
  bool get isComplete => status == MessageStatus.completed;

  /// Gets the text content of the message.
  String get text =>
      content.whereType<TextMessageContent>().map((c) => c.text.value).join();

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'thread_id': threadId,
    if (status != null) 'status': status!.toJson(),
    if (incompleteDetails != null)
      'incomplete_details': incompleteDetails!.toJson(),
    if (completedAt != null) 'completed_at': completedAt,
    if (incompleteAt != null) 'incomplete_at': incompleteAt,
    'role': role,
    'content': content.map((c) => c.toJson()).toList(),
    if (assistantId != null) 'assistant_id': assistantId,
    if (runId != null) 'run_id': runId,
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Message(id: $id, role: $role)';
}

/// A list of messages.
@immutable
class MessageList {
  /// Creates a [MessageList].
  const MessageList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [MessageList] from JSON.
  factory MessageList.fromJson(Map<String, dynamic> json) {
    return MessageList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of messages.
  final List<Message> data;

  /// The ID of the first message.
  final String? firstId;

  /// The ID of the last message.
  final String? lastId;

  /// Whether there are more messages.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((m) => m.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'MessageList(${data.length} messages)';
}

/// A request to create a message.
@immutable
class CreateMessageRequest {
  /// Creates a [CreateMessageRequest].
  const CreateMessageRequest({
    required this.role,
    required this.content,
    this.attachments,
    this.metadata,
  });

  /// Creates a [CreateMessageRequest] from JSON.
  factory CreateMessageRequest.fromJson(Map<String, dynamic> json) {
    return CreateMessageRequest(
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
  factory CreateMessageRequest.user(
    Object content, {
    List<MessageAttachment>? attachments,
    Map<String, String>? metadata,
  }) {
    return CreateMessageRequest(
      role: 'user',
      content: content,
      attachments: attachments,
      metadata: metadata,
    );
  }

  /// The role of the message author (must be "user").
  final String role;

  /// The content of the message.
  final Object content;

  /// File attachments.
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
      other is CreateMessageRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(role, content);

  @override
  String toString() => 'CreateMessageRequest(role: $role)';
}

/// A request to modify a message.
@immutable
class ModifyMessageRequest {
  /// Creates a [ModifyMessageRequest].
  const ModifyMessageRequest({this.metadata});

  /// Creates a [ModifyMessageRequest] from JSON.
  factory ModifyMessageRequest.fromJson(Map<String, dynamic> json) {
    return ModifyMessageRequest(
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (metadata != null) 'metadata': metadata};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModifyMessageRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => metadata.hashCode;

  @override
  String toString() => 'ModifyMessageRequest()';
}

/// The response from deleting a message.
@immutable
class DeleteMessageResponse {
  /// Creates a [DeleteMessageResponse].
  const DeleteMessageResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteMessageResponse] from JSON.
  factory DeleteMessageResponse.fromJson(Map<String, dynamic> json) {
    return DeleteMessageResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted message.
  final String id;

  /// The object type.
  final String object;

  /// Whether the message was deleted.
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
      other is DeleteMessageResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteMessageResponse(id: $id, deleted: $deleted)';
}

/// Message status values.
enum MessageStatus {
  /// Message is in progress.
  inProgress._('in_progress'),

  /// Message is incomplete.
  incomplete._('incomplete'),

  /// Message is completed.
  completed._('completed');

  const MessageStatus._(this._value);

  /// Creates from JSON string.
  factory MessageStatus.fromJson(String json) {
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

/// Details about why a message is incomplete.
@immutable
class IncompleteDetails {
  /// Creates an [IncompleteDetails].
  const IncompleteDetails({required this.reason});

  /// Creates an [IncompleteDetails] from JSON.
  factory IncompleteDetails.fromJson(Map<String, dynamic> json) {
    return IncompleteDetails(reason: json['reason'] as String);
  }

  /// The reason for incompleteness.
  final String reason;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'reason': reason};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncompleteDetails &&
          runtimeType == other.runtimeType &&
          reason == other.reason;

  @override
  int get hashCode => reason.hashCode;

  @override
  String toString() => 'IncompleteDetails(reason: $reason)';
}

/// Content of a message.
sealed class MessageContent {
  /// Creates a [MessageContent] from JSON.
  factory MessageContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => TextMessageContent.fromJson(json),
      'image_url' => ImageUrlMessageContent.fromJson(json),
      'image_file' => ImageFileMessageContent.fromJson(json),
      'refusal' => RefusalMessageContent.fromJson(json),
      _ => throw FormatException('Unknown content type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text content in a message.
@immutable
class TextMessageContent implements MessageContent {
  /// Creates a [TextMessageContent].
  const TextMessageContent({required this.text});

  /// Creates a [TextMessageContent] from JSON.
  factory TextMessageContent.fromJson(Map<String, dynamic> json) {
    return TextMessageContent(
      text: TextContent.fromJson(json['text'] as Map<String, dynamic>),
    );
  }

  /// The text content.
  final TextContent text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextMessageContent &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextMessageContent(${text.value.length} chars)';
}

/// Text content with annotations.
@immutable
class TextContent {
  /// Creates a [TextContent].
  const TextContent({required this.value, required this.annotations});

  /// Creates a [TextContent] from JSON.
  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      value: json['value'] as String,
      annotations: (json['annotations'] as List<dynamic>)
          .map((e) => TextAnnotation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The text value.
  final String value;

  /// Annotations in the text.
  final List<TextAnnotation> annotations;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'value': value,
    'annotations': annotations.map((a) => a.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContent &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'TextContent(${value.length} chars)';
}

/// An annotation in text content.
sealed class TextAnnotation {
  /// Creates a [TextAnnotation] from JSON.
  factory TextAnnotation.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'file_citation' => FileCitationAnnotation.fromJson(json),
      'file_path' => FilePathAnnotation.fromJson(json),
      _ => throw FormatException('Unknown annotation type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A file citation annotation.
@immutable
class FileCitationAnnotation implements TextAnnotation {
  /// Creates a [FileCitationAnnotation].
  const FileCitationAnnotation({
    required this.text,
    required this.fileCitation,
    required this.startIndex,
    required this.endIndex,
  });

  /// Creates a [FileCitationAnnotation] from JSON.
  factory FileCitationAnnotation.fromJson(Map<String, dynamic> json) {
    return FileCitationAnnotation(
      text: json['text'] as String,
      fileCitation: FileCitation.fromJson(
        json['file_citation'] as Map<String, dynamic>,
      ),
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
    );
  }

  /// The text being annotated.
  final String text;

  /// The file citation details.
  final FileCitation fileCitation;

  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_citation',
    'text': text,
    'file_citation': fileCitation.toJson(),
    'start_index': startIndex,
    'end_index': endIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCitationAnnotation &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'FileCitationAnnotation($startIndex-$endIndex)';
}

/// A file citation.
@immutable
class FileCitation {
  /// Creates a [FileCitation].
  const FileCitation({required this.fileId, this.quote});

  /// Creates a [FileCitation] from JSON.
  factory FileCitation.fromJson(Map<String, dynamic> json) {
    return FileCitation(
      fileId: json['file_id'] as String,
      quote: json['quote'] as String?,
    );
  }

  /// The file ID.
  final String fileId;

  /// The quote from the file.
  final String? quote;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    if (quote != null) 'quote': quote,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCitation &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FileCitation(fileId: $fileId)';
}

/// A file path annotation.
@immutable
class FilePathAnnotation implements TextAnnotation {
  /// Creates a [FilePathAnnotation].
  const FilePathAnnotation({
    required this.text,
    required this.filePath,
    required this.startIndex,
    required this.endIndex,
  });

  /// Creates a [FilePathAnnotation] from JSON.
  factory FilePathAnnotation.fromJson(Map<String, dynamic> json) {
    return FilePathAnnotation(
      text: json['text'] as String,
      filePath: FilePath.fromJson(json['file_path'] as Map<String, dynamic>),
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
    );
  }

  /// The text being annotated.
  final String text;

  /// The file path details.
  final FilePath filePath;

  /// The start index in the text.
  final int startIndex;

  /// The end index in the text.
  final int endIndex;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'file_path',
    'text': text,
    'file_path': filePath.toJson(),
    'start_index': startIndex,
    'end_index': endIndex,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilePathAnnotation &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'FilePathAnnotation($startIndex-$endIndex)';
}

/// A file path reference.
@immutable
class FilePath {
  /// Creates a [FilePath].
  const FilePath({required this.fileId});

  /// Creates a [FilePath] from JSON.
  factory FilePath.fromJson(Map<String, dynamic> json) {
    return FilePath(fileId: json['file_id'] as String);
  }

  /// The file ID.
  final String fileId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'file_id': fileId};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilePath &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'FilePath(fileId: $fileId)';
}

/// Image URL content in a message.
@immutable
class ImageUrlMessageContent implements MessageContent {
  /// Creates an [ImageUrlMessageContent].
  const ImageUrlMessageContent({required this.imageUrl});

  /// Creates an [ImageUrlMessageContent] from JSON.
  factory ImageUrlMessageContent.fromJson(Map<String, dynamic> json) {
    return ImageUrlMessageContent(
      imageUrl: ImageUrl.fromJson(json['image_url'] as Map<String, dynamic>),
    );
  }

  /// The image URL details.
  final ImageUrl imageUrl;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_url',
    'image_url': imageUrl.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUrlMessageContent &&
          runtimeType == other.runtimeType &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => imageUrl.hashCode;

  @override
  String toString() => 'ImageUrlMessageContent(${imageUrl.url})';
}

/// An image URL.
@immutable
class ImageUrl {
  /// Creates an [ImageUrl].
  const ImageUrl({required this.url, this.detail});

  /// Creates an [ImageUrl] from JSON.
  factory ImageUrl.fromJson(Map<String, dynamic> json) {
    return ImageUrl(
      url: json['url'] as String,
      detail: json['detail'] as String?,
    );
  }

  /// The URL of the image.
  final String url;

  /// The detail level for the image.
  final String? detail;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'url': url,
    if (detail != null) 'detail': detail,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageUrl && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'ImageUrl($url)';
}

/// Image file content in a message.
@immutable
class ImageFileMessageContent implements MessageContent {
  /// Creates an [ImageFileMessageContent].
  const ImageFileMessageContent({required this.imageFile});

  /// Creates an [ImageFileMessageContent] from JSON.
  factory ImageFileMessageContent.fromJson(Map<String, dynamic> json) {
    return ImageFileMessageContent(
      imageFile: ImageFile.fromJson(json['image_file'] as Map<String, dynamic>),
    );
  }

  /// The image file details.
  final ImageFile imageFile;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_file',
    'image_file': imageFile.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageFileMessageContent &&
          runtimeType == other.runtimeType &&
          imageFile == other.imageFile;

  @override
  int get hashCode => imageFile.hashCode;

  @override
  String toString() => 'ImageFileMessageContent(${imageFile.fileId})';
}

/// An image file reference.
@immutable
class ImageFile {
  /// Creates an [ImageFile].
  const ImageFile({required this.fileId, this.detail});

  /// Creates an [ImageFile] from JSON.
  factory ImageFile.fromJson(Map<String, dynamic> json) {
    return ImageFile(
      fileId: json['file_id'] as String,
      detail: json['detail'] as String?,
    );
  }

  /// The file ID.
  final String fileId;

  /// The detail level for the image.
  final String? detail;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    if (detail != null) 'detail': detail,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageFile &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'ImageFile(fileId: $fileId)';
}

/// Refusal content in a message.
@immutable
class RefusalMessageContent implements MessageContent {
  /// Creates a [RefusalMessageContent].
  const RefusalMessageContent({required this.refusal});

  /// Creates a [RefusalMessageContent] from JSON.
  factory RefusalMessageContent.fromJson(Map<String, dynamic> json) {
    return RefusalMessageContent(refusal: json['refusal'] as String);
  }

  /// The refusal message.
  final String refusal;

  @override
  Map<String, dynamic> toJson() => {'type': 'refusal', 'refusal': refusal};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefusalMessageContent &&
          runtimeType == other.runtimeType &&
          refusal == other.refusal;

  @override
  int get hashCode => refusal.hashCode;

  @override
  String toString() => 'RefusalMessageContent(${refusal.length} chars)';
}
