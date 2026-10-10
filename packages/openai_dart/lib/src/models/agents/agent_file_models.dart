/// Mutable workspace file views and immutable published session artifacts.
library;

import '../common/copy_with_sentinel.dart';
import 'agent_json_helpers.dart';

/// Confirmation that an immutable session artifact was deleted.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedAgentSessionArtifact extends AgentJsonModel {
  /// Creates a validated [DeletedAgentSessionArtifact].
  DeletedAgentSessionArtifact({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedAgentSessionArtifact') {
    validate();
  }

  /// Whether the session artifact was deleted. Always `true`.
  final bool deleted;

  /// The ID of the deleted session artifact.
  final String id;

  /// The object type. Always `agent.session.artifact.deleted`.
  String get object => 'agent.session.artifact.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedAgentSessionArtifact] with contextual, payload-free errors.
  factory DeletedAgentSessionArtifact.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.session.artifact.deleted',
      'DeletedAgentSessionArtifact',
    );
    return DeletedAgentSessionArtifact(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedAgentSessionArtifact.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedAgentSessionArtifact.id',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['deleted', 'id', 'object'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(id, 'DeletedAgentSessionArtifact.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedAgentSessionArtifact copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedAgentSessionArtifact(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A paginated list of live execution environment files.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironmentFileList extends AgentJsonModel {
  /// Creates a validated [AgentEnvironmentFileList].
  AgentEnvironmentFileList({
    required List<AgentEnvironmentFile> data,
    required this.hasMore,
    required this.next,
    required this.object,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'data',
         'has_more',
         'next',
         'object',
       ], 'AgentEnvironmentFileList') {
    validate();
  }

  /// Files available on the current page.
  final List<AgentEnvironmentFile> data;

  /// Whether more files follow this page.
  final bool hasMore;

  /// The opaque cursor to use when requesting the next page, if any.
  final String? next;

  /// The object type. Always `page`.
  final AgentEnvironmentFilePageObject object;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentEnvironmentFileList] with contextual, payload-free errors.
  factory AgentEnvironmentFileList.fromJson(Map<String, dynamic> json) {
    return AgentEnvironmentFileList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentEnvironmentFileList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentEnvironmentFile.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentEnvironmentFileList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      next: requiredAgentValue(
        json,
        'next',
        'AgentEnvironmentFileList.next',
        requireAgentString,
        nullable: true,
      ),
      object: requiredAgentValue(
        json,
        'object',
        'AgentEnvironmentFileList.object',
        (value, context) => AgentEnvironmentFilePageObject.fromJson(value),
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['data', 'has_more', 'next', 'object'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      data.length,
      'AgentEnvironmentFileList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (next != null) {
      validateAgentLength(next!, 'AgentEnvironmentFileList.next', min: 0);
    }
    validateAgentEnum(object.value, [
      'page',
    ], 'AgentEnvironmentFileList.object');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((value) => value.toJson()).toList(),
    'has_more': hasMore,
    'next': next,
    'object': object.toJson(),
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentEnvironmentFileList copyWith({
    List<AgentEnvironmentFile>? data,
    bool? hasMore,
    Object? next = unsetCopyWithValue,
    AgentEnvironmentFilePageObject? object,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironmentFileList(
    data: data ?? this.data,
    hasMore: hasMore ?? this.hasMore,
    next: copyAgentValue<String>(
      next,
      this.next,
      'AgentEnvironmentFileList.next',
    ),
    object: object ?? this.object,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The object type for a page of files in an execution environment.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class AgentEnvironmentFilePageObject extends AgentJsonModel {
  const AgentEnvironmentFilePageObject._(this.value);

  /// The `page` wire value.
  static const AgentEnvironmentFilePageObject page =
      AgentEnvironmentFilePageObject._('page');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory AgentEnvironmentFilePageObject.fromJson(Object? json) {
    final value = requireAgentString(json, 'AgentEnvironmentFilePageObject');
    return switch (value) {
      'page' => page,
      _ => AgentEnvironmentFilePageObject._(value),
    };
  }

  /// Copies the exact known or future string value.
  AgentEnvironmentFilePageObject copyWith({String? value}) =>
      AgentEnvironmentFilePageObject.fromJson(value ?? this.value);

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['page'].contains(value);

  @override
  String toJson() => value;
}

/// A live file in an execution environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentEnvironmentFile extends AgentJsonModel {
  /// Creates a validated [AgentEnvironmentFile].
  AgentEnvironmentFile({
    required this.environmentId,
    required this.path,
    required this.sizeBytes,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'environment_id',
         'object',
         'path',
         'size_bytes',
       ], 'AgentEnvironmentFile') {
    validate();
  }

  /// The ID of the environment containing this file.
  final String environmentId;

  /// The object type. Always `agent.environment.file`.
  String get object => 'agent.environment.file';

  /// The absolute file path inside the environment's workspace.
  final String path;

  /// The file size in bytes.
  final int sizeBytes;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentEnvironmentFile] with contextual, payload-free errors.
  factory AgentEnvironmentFile.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.environment.file',
      'AgentEnvironmentFile',
    );
    return AgentEnvironmentFile(
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentEnvironmentFile.environmentId',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentEnvironmentFile.path',
        requireAgentString,
        nullable: false,
      )!,
      sizeBytes: requiredAgentValue(
        json,
        'size_bytes',
        'AgentEnvironmentFile.sizeBytes',
        requireAgentInt,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'environment_id',
            'object',
            'path',
            'size_bytes',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      environmentId,
      'AgentEnvironmentFile.environmentId',
      min: 0,
    );
    validateAgentLength(path, 'AgentEnvironmentFile.path', min: 0);
    validateAgentInt(sizeBytes, 'AgentEnvironmentFile.sizeBytes', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'environment_id': environmentId,
    'object': object,
    'path': path,
    'size_bytes': sizeBytes,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentEnvironmentFile copyWith({
    String? environmentId,
    String? path,
    int? sizeBytes,
    Map<String, dynamic>? rawJson,
  }) => AgentEnvironmentFile(
    environmentId: environmentId ?? this.environmentId,
    path: path ?? this.path,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionArtifactList extends AgentJsonModel {
  /// Creates a validated [AgentSessionArtifactList].
  AgentSessionArtifactList({
    required List<AgentSessionArtifact> data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'data',
         'first_id',
         'has_more',
         'last_id',
         'object',
       ], 'AgentSessionArtifactList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<AgentSessionArtifact> data;

  /// The ID of the first resource in `data`, or `null` if the page is empty.
  final String? firstId;

  /// Whether there are more resources to retrieve after this page.
  final bool hasMore;

  /// The ID of the last resource in `data`, or `null` if the page is empty. Pass this as `after` with the same order and filters.
  final String? lastId;

  /// The object type, which is always `list`.
  String get object => 'list';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionArtifactList] with contextual, payload-free errors.
  factory AgentSessionArtifactList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionArtifactList');
    return AgentSessionArtifactList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionArtifactList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionArtifact.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionArtifactList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionArtifactList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionArtifactList.lastId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'data',
            'first_id',
            'has_more',
            'last_id',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      data.length,
      'AgentSessionArtifactList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentSessionArtifactList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentSessionArtifactList.lastId', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((value) => value.toJson()).toList(),
    'first_id': firstId,
    'has_more': hasMore,
    'last_id': lastId,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionArtifactList copyWith({
    List<AgentSessionArtifact>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionArtifactList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentSessionArtifactList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentSessionArtifactList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// An immutable file published by a completed hosted session turn.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionArtifact extends AgentJsonModel {
  /// Creates a validated [AgentSessionArtifact].
  AgentSessionArtifact({
    required this.createdAt,
    required this.environmentId,
    required this.id,
    required this.path,
    required this.sessionId,
    required this.sizeBytes,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'created_at',
         'environment_id',
         'id',
         'object',
         'path',
         'session_id',
         'size_bytes',
         'turn_id',
       ], 'AgentSessionArtifact') {
    validate();
  }

  /// The Unix timestamp, in seconds, when the artifact was published.
  final int createdAt;

  /// The ID of the environment that produced the artifact.
  final String environmentId;

  /// The immutable artifact ID.
  final String id;

  /// The object type. Always `agent.session.artifact`.
  String get object => 'agent.session.artifact';

  /// The original absolute file path in the execution environment.
  final String path;

  /// The ID of the session that owns the artifact.
  final String sessionId;

  /// The immutable artifact size in bytes.
  final int sizeBytes;

  /// The ID of the completed turn that published the artifact.
  final String turnId;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionArtifact] with contextual, payload-free errors.
  factory AgentSessionArtifact.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'agent.session.artifact',
      'AgentSessionArtifact',
    );
    return AgentSessionArtifact(
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'AgentSessionArtifact.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      environmentId: requiredAgentValue(
        json,
        'environment_id',
        'AgentSessionArtifact.environmentId',
        requireAgentString,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionArtifact.id',
        requireAgentString,
        nullable: false,
      )!,
      path: requiredAgentValue(
        json,
        'path',
        'AgentSessionArtifact.path',
        requireAgentString,
        nullable: false,
      )!,
      sessionId: requiredAgentValue(
        json,
        'session_id',
        'AgentSessionArtifact.sessionId',
        requireAgentString,
        nullable: false,
      )!,
      sizeBytes: requiredAgentValue(
        json,
        'size_bytes',
        'AgentSessionArtifact.sizeBytes',
        requireAgentInt,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionArtifact.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'created_at',
            'environment_id',
            'id',
            'object',
            'path',
            'session_id',
            'size_bytes',
            'turn_id',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(createdAt, 'AgentSessionArtifact.createdAt');
    validateAgentLength(
      environmentId,
      'AgentSessionArtifact.environmentId',
      min: 0,
    );
    validateAgentLength(id, 'AgentSessionArtifact.id', min: 0);
    validateAgentLength(path, 'AgentSessionArtifact.path', min: 0);
    validateAgentLength(sessionId, 'AgentSessionArtifact.sessionId', min: 0);
    validateAgentInt(sizeBytes, 'AgentSessionArtifact.sizeBytes', min: 0);
    validateAgentLength(turnId, 'AgentSessionArtifact.turnId', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'created_at': createdAt,
    'environment_id': environmentId,
    'id': id,
    'object': object,
    'path': path,
    'session_id': sessionId,
    'size_bytes': sizeBytes,
    'turn_id': turnId,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionArtifact copyWith({
    int? createdAt,
    String? environmentId,
    String? id,
    String? path,
    String? sessionId,
    int? sizeBytes,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionArtifact(
    createdAt: createdAt ?? this.createdAt,
    environmentId: environmentId ?? this.environmentId,
    id: id ?? this.id,
    path: path ?? this.path,
    sessionId: sessionId ?? this.sessionId,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}
