part of 'compliance_models.dart';

/// Sort keys supported by the list chats endpoint.
enum ComplianceChatOrderBy {
  /// Order by chat creation time.
  createdAt('created_at'),

  /// Order by last update time for organization-wide queries.
  updatedAt('updated_at');

  /// The query parameter value.
  final String wireValue;

  const ComplianceChatOrderBy(this.wireValue);
}

/// A chat in a linked Claude Enterprise organization.
class ComplianceChat extends ComplianceRecord {
  /// The chat's tagged ID.
  String get id => _required<String>('id');

  /// The chat title.
  String get name => _required<String>('name');

  /// The organization UUID.
  String get organizationUuid => _required<String>('organization_uuid');

  /// When the chat was created.
  DateTime get createdAt => _date('created_at');

  /// When the chat was last updated.
  DateTime get updatedAt => _date('updated_at');

  /// When the chat was deleted, if applicable.
  DateTime? get deletedAt => _optionalDate('deleted_at');

  /// The project containing the chat, if any.
  String? get projectId => _optional<String>('project_id');

  /// The model used by the chat, if available.
  String? get model => _optional<String>('model');

  /// Decodes chat metadata.
  ComplianceChat.fromJson(super.json) : super._();
}

/// A page of messages plus its chat's metadata.
final class ComplianceChatMessages extends ComplianceChat {
  /// The messages in the requested order.
  late final List<ComplianceChatMessage> messages;

  /// Cursor for backward pagination.
  late final String? firstId;

  /// Cursor for forward pagination.
  late final String? lastId;

  /// Whether more messages are available.
  late final bool hasMore;

  /// Decodes a message page and its chat's metadata.
  ComplianceChatMessages.fromJson(super.json) : super.fromJson() {
    firstId = _requiredNullable<String>('first_id');
    lastId = _requiredNullable<String>('last_id');
    hasMore = _required<bool>('has_more');
    if (hasMore && lastId?.isNotEmpty != true) {
      throw const FormatException('Missing Compliance forward cursor');
    }
    messages = _records('chat_messages', ComplianceChatMessage.fromJson);
  }
}

/// A chat message with its original content blocks and attachments.
final class ComplianceChatMessage extends ComplianceRecord {
  /// The message's tagged ID.
  String get id => _required<String>('id');

  /// The message role.
  String get role => _required<String>('role');

  /// When the message was created.
  DateTime get createdAt => _date('created_at');

  /// Content blocks in their original wire format.
  List<Object?> get content => _list<Object?>('content');

  /// Decodes a chat message.
  ComplianceChatMessage.fromJson(super.json) : super._();
}

/// Metadata common to uploaded files and Claude-generated files.
final class ComplianceFileMetadata extends ComplianceRecord {
  /// The tagged file ID.
  String get id => _required<String>('id');

  /// The original filename, if available.
  String? get filename => _optional<String>('filename');

  /// The file's media type, if available.
  String? get mimeType => _optional<String>('mime_type');

  /// The file size in bytes, if available.
  int? get sizeBytes => _optional<int>('size_bytes');

  /// The file's checksum, if available.
  String? get md5 => _optional<String>('md5');

  /// When the file was created, if known.
  DateTime? get createdAt => _optionalDate('created_at');

  /// Decodes file metadata.
  ComplianceFileMetadata.fromJson(super.json) : super._();
}

/// A Claude Enterprise project and its available metadata.
final class ComplianceProject extends ComplianceRecord {
  /// The project's tagged ID.
  String get id => _required<String>('id');

  /// The display name.
  String get name => _required<String>('name');

  /// The organization UUID.
  String get organizationUuid => _required<String>('organization_uuid');

  /// Whether the project is private.
  bool get isPrivate => _required<bool>('is_private');

  /// When the project was created.
  DateTime get createdAt => _date('created_at');

  /// When the project was last updated.
  DateTime get updatedAt => _date('updated_at');

  /// When the project was deleted, if applicable.
  DateTime? get deletedAt => _optionalDate('deleted_at');

  /// Project instructions, when returned by the details endpoint.
  String? get instructions => _optional<String>('instructions');

  /// Decodes project metadata.
  ComplianceProject.fromJson(super.json) : super._();
}

/// A file or document attached to a project.
final class ComplianceProjectAttachment extends ComplianceRecord {
  /// The attachment discriminator.
  String get type => _required<String>('type');

  /// The attached file or document's tagged ID.
  String get id => _required<String>('id');

  /// The attachment filename, when provided.
  String? get filename => _optional<String>('filename');

  /// Decodes an attachment and preserves variant-specific fields.
  ComplianceProjectAttachment.fromJson(super.json) : super._();
}

/// A person, group, organization, or other collaborator on a project.
final class ComplianceProjectCollaborator extends ComplianceRecord {
  /// The collaborator discriminator as sent by the service.
  String get type => _required<String>('type');

  /// The collaborator's assigned role, when present.
  String? get role => _optional<String>('role');

  /// Decodes a collaborator and preserves variant-specific fields.
  ComplianceProjectCollaborator.fromJson(super.json) : super._();
}

/// A project document with its text content.
final class ComplianceProjectDocument extends ComplianceRecord {
  /// The document's tagged ID.
  String get id => _required<String>('id');

  /// The document's filename.
  String get filename => _required<String>('filename');

  /// The document's text.
  String get content => _required<String>('content');

  /// When the document was created.
  DateTime get createdAt => _date('created_at');

  /// Decodes a document and its content.
  ComplianceProjectDocument.fromJson(super.json) : super._();
}

/// Metadata for a versioned artifact generated in a chat.
final class ComplianceArtifactVersion extends ComplianceRecord {
  /// The artifact version's tagged ID.
  String get id => _required<String>('id');

  /// The version identifier.
  String get versionId => _required<String>('version_id');

  /// The artifact's title, if available.
  String? get title => _optional<String>('title');

  /// The artifact's type, if available.
  String? get artifactType => _optional<String>('artifact_type');

  /// The chat containing the artifact.
  String get chatId => _required<String>('claude_chat_id');

  /// The size of the artifact in bytes.
  int get sizeBytes => _required<int>('size_bytes');

  /// Decodes metadata for an artifact version.
  ComplianceArtifactVersion.fromJson(super.json) : super._();
}

/// Text and descriptive fields for a chat artifact version.
final class ComplianceArtifactContent extends ComplianceRecord {
  /// The version's full text.
  String get content => _required<String>('content');

  /// The artifact's title, if available.
  String? get title => _optional<String>('title');

  /// The artifact's type, if available.
  String? get artifactType => _optional<String>('artifact_type');

  /// Decodes a chat artifact version's text and descriptive fields.
  ComplianceArtifactContent.fromJson(super.json) : super._();
}

/// Metadata about a local or remote session in a Claude application.
final class ComplianceSession extends ComplianceRecord {
  /// The session ID.
  String get id => _required<String>('id');

  /// The organization UUID.
  String get organizationUuid => _required<String>('organization_uuid');

  /// The Claude application that generated the session, if known.
  String? get productSurface => _optional<String>('product_surface');

  /// When the session started.
  DateTime get createdAt => _date('created_at');

  /// When the session was last updated.
  DateTime get updatedAt => _date('updated_at');

  /// The remote session's status, when available.
  String? get status => _optional<String>('status');

  /// Whether the local session was truncated, when available.
  bool? get truncated => _optional<bool>('truncated');

  /// Decodes session metadata.
  ComplianceSession.fromJson(super.json) : super._();
}

/// A message in a Claude application session transcript.
final class ComplianceSessionMessage extends ComplianceRecord {
  /// The message identifier.
  String get id => _required<String>('id');

  /// The message role.
  String get role => _required<String>('role');

  /// When the message was created.
  DateTime get createdAt => _date('created_at');

  /// The content blocks exposed by the Compliance API.
  List<Object?> get content => _list<Object?>('content');

  /// Whether the remote message's content is unavailable, when reported.
  bool? get contentUnavailable => _optional<bool>('content_unavailable');

  /// Decodes a transcript message.
  ComplianceSessionMessage.fromJson(super.json) : super._();
}

/// A transcript page and its enclosing local or remote session.
final class ComplianceSessionMessages
    extends ComplianceCursorPage<ComplianceSessionMessage> {
  /// Metadata for the session whose transcript was fetched.
  ComplianceSession get session =>
      ComplianceSession.fromJson(_required('session'));

  /// Decodes a page of transcript messages.
  ComplianceSessionMessages.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, ComplianceSessionMessage.fromJson);
}

/// An Artifact published from Claude Code or a built-in Artifact type.
final class ComplianceCodeArtifact extends ComplianceRecord {
  /// The Artifact's tagged ID.
  String get id => _required<String>('id');

  /// The Artifact type as sent by the server.
  String get artifactType => _required<String>('artifact_type');

  /// The organization UUID.
  String get organizationUuid => _required<String>('organization_uuid');

  /// The published version ID, if applicable.
  String? get publishedVersionId => _optional<String>('published_version_id');

  /// The read mode as sent by the server.
  String get readMode => _required<String>('read_mode');

  /// Last update time, if recorded.
  DateTime? get updatedAt => _optionalDate('updated_at');

  /// Metadata for retained versions.
  List<ComplianceCodeArtifactVersion> get versions =>
      _records('versions', ComplianceCodeArtifactVersion.fromJson);

  /// Decodes a Code Artifact.
  ComplianceCodeArtifact.fromJson(super.json) : super._();
}

/// Metadata for a retained Code Artifact version.
final class ComplianceCodeArtifactVersion extends ComplianceRecord {
  /// The opaque version ID.
  String get id => _required<String>('id');

  /// The Artifact title at this version.
  String get name => _required<String>('name');

  /// When this version was published, if known.
  DateTime? get createdAt => _optionalDate('created_at');

  /// Decodes metadata for a Code Artifact version.
  ComplianceCodeArtifactVersion.fromJson(super.json) : super._();
}

/// Confirmation that a Compliance content deletion was accepted.
final class ComplianceDeletion extends ComplianceRecord {
  /// The deleted object's ID.
  String get id => _required<String>('id');

  /// The deletion discriminator, when included.
  String? get type => _optional<String>('type');

  /// Decodes a JSON deletion receipt.
  ComplianceDeletion.fromJson(super.json) : super._();
}

/// Headers supplied before a Compliance download's body begins.
@immutable
final class ComplianceDownloadHeaders {
  /// The response media type, when provided.
  final String? contentType;

  /// The raw Content-Disposition header, which may include a filename.
  final String? contentDisposition;

  /// The server's checksum, when provided.
  final String? contentMd5;

  /// The provider's request ID, when provided.
  final String? requestId;

  /// Creates headers for a Compliance download.
  const ComplianceDownloadHeaders({
    this.contentType,
    this.contentDisposition,
    this.contentMd5,
    this.requestId,
  });

  /// Reads the supported headers with case-insensitive matching.
  factory ComplianceDownloadHeaders.fromHeaders(Map<String, String> headers) {
    final normalized = {
      for (final entry in headers.entries) entry.key.toLowerCase(): entry.value,
    };
    return ComplianceDownloadHeaders(
      contentType: normalized['content-type'],
      contentDisposition: normalized['content-disposition'],
      contentMd5: normalized['content-md5'],
      requestId: normalized['request-id'],
    );
  }
}
