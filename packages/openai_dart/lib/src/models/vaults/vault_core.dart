part of 'vault_models.dart';

/// Parameters for storing a credential for an MCP server or an OpenAI-hosted environment.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultCredentialRequest extends AgentJsonModel {
  /// Creates a validated [CreateVaultCredentialRequest].
  CreateVaultCredentialRequest({
    required this.auth,
    Map<String, String>? metadata,
    required this.name,
  }) : metadata = ownAgentValue<Map<String, String>>(
         metadata,
         Map<String, String>.unmodifiable,
       ) {
    validate();
  }

  /// The authentication method and write-only secret values to store.
  final CreateVaultCredentialAuth auth;

  /// Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters. Defaults to an empty map.
  final Map<String, String>? metadata;

  /// The name is trimmed before storage. It must contain 1 to 256 UTF-8 bytes after trimming.
  final String name;

  /// Parses [CreateVaultCredentialRequest] with contextual, payload-free errors.
  factory CreateVaultCredentialRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'auth',
      'metadata',
      'name',
    ], 'CreateVaultCredentialRequest');
    return CreateVaultCredentialRequest(
      auth: requiredAgentValue(
        json,
        'auth',
        'CreateVaultCredentialRequest.auth',
        (value, context) => CreateVaultCredentialAuth.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      metadata: optionalAgentValue(
        json,
        'metadata',
        'CreateVaultCredentialRequest.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
      name: requiredAgentValue(
        json,
        'name',
        'CreateVaultCredentialRequest.name',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    _validateVaultName(name, 'CreateVaultCredentialRequest.name');
    auth.validate();
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'CreateVaultCredentialRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'CreateVaultCredentialRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'CreateVaultCredentialRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    validateAgentLength(
      name,
      'CreateVaultCredentialRequest.name',
      min: 1,
      max: 1048576,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'auth': auth.toJson(),
    'metadata': ?metadata,
    'name': name,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultCredentialRequest copyWith({
    CreateVaultCredentialAuth? auth,
    Object? metadata = unsetCopyWithValue,
    String? name,
  }) => CreateVaultCredentialRequest(
    auth: auth ?? this.auth,
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'CreateVaultCredentialRequest.metadata',
    ),
    name: name ?? this.name,
  );
}

/// Parameters for creating a vault to store credentials used by agent tools.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class CreateVaultRequest extends AgentJsonModel {
  /// Creates a validated [CreateVaultRequest].
  CreateVaultRequest({
    Map<String, String>? metadata,
    bool clearMetadata = false,
    this.name,
  }) : clearMetadata = clearMetadata,
       metadata = ownAgentValue<Map<String, String>>(
         clearMetadata ? null : metadata,
         Map<String, String>.unmodifiable,
       ) {
    validate();
  }

  /// Key-value pairs to associate with the vault, such as an application or team identifier.
  final Map<String, String>? metadata;

  /// Sends `metadata: null`, rather than omitting it.
  final bool clearMetadata;

  /// The name is trimmed before storage. It must contain 1 to 256 UTF-8 bytes after trimming.
  final String? name;

  /// Parses [CreateVaultRequest] with contextual, payload-free errors.
  factory CreateVaultRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'metadata',
      'name',
    ], 'CreateVaultRequest');
    return CreateVaultRequest(
      metadata: optionalAgentValue(
        json,
        'metadata',
        'CreateVaultRequest.metadata',
        requireAgentStringMap,
        nullable: true,
      ),
      clearMetadata: json.containsKey('metadata') && json['metadata'] == null,
      name: optionalAgentValue(
        json,
        'name',
        'CreateVaultRequest.name',
        requireAgentString,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    if (name != null) _validateVaultName(name!, 'CreateVaultRequest.name');
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'CreateVaultRequest.metadata',
        min: 0,
        max: 1024,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'CreateVaultRequest.metadata',
          min: 1,
          max: 256,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'CreateVaultRequest.metadata',
          min: 0,
          max: 1048576,
        );
      }
    }
    if (name != null) {
      validateAgentLength(
        name!,
        'CreateVaultRequest.name',
        min: 1,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (clearMetadata) 'metadata': null else 'metadata': ?metadata,
    'name': ?name,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  CreateVaultRequest copyWith({
    Object? metadata = unsetCopyWithValue,
    bool? clearMetadata,
    Object? name = unsetCopyWithValue,
  }) => CreateVaultRequest(
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'CreateVaultRequest.metadata',
    ),
    clearMetadata:
        clearMetadata ??
        (identical(metadata, unsetCopyWithValue)
            ? this.clearMetadata
            : metadata == null),
    name: copyAgentValue<String>(name, this.name, 'CreateVaultRequest.name'),
  );
}

/// Confirmation that a vault credential was deleted.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedVaultCredential extends AgentJsonModel {
  /// Creates a validated [DeletedVaultCredential].
  DeletedVaultCredential({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedVaultCredential') {
    validate();
  }

  /// Whether the resource was deleted. Always `true`.
  final bool deleted;

  /// The ID of the deleted credential.
  final String id;

  /// The object type. Always `vault.credential.deleted`.
  String get object => 'vault.credential.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedVaultCredential] with contextual, payload-free errors.
  factory DeletedVaultCredential.fromJson(Map<String, dynamic> json) {
    requireAgentTag(
      json,
      'object',
      'vault.credential.deleted',
      'DeletedVaultCredential',
    );
    return DeletedVaultCredential(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedVaultCredential.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedVaultCredential.id',
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
    validateAgentLength(id, 'DeletedVaultCredential.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedVaultCredential copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedVaultCredential(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Confirmation that a vault was deleted.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class DeletedVault extends AgentJsonModel {
  /// Creates a validated [DeletedVault].
  DeletedVault({
    required this.deleted,
    required this.id,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'deleted',
         'id',
         'object',
       ], 'DeletedVault') {
    validate();
  }

  /// Whether the resource was deleted. Always `true`.
  final bool deleted;

  /// The ID of the deleted vault.
  final String id;

  /// The object type. Always `vault.deleted`.
  String get object => 'vault.deleted';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [DeletedVault] with contextual, payload-free errors.
  factory DeletedVault.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'vault.deleted', 'DeletedVault');
    return DeletedVault(
      deleted: requiredAgentValue(
        json,
        'deleted',
        'DeletedVault.deleted',
        requireAgentBool,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'DeletedVault.id',
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
    validateAgentLength(id, 'DeletedVault.id', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'deleted': deleted,
    'id': id,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  DeletedVault copyWith({
    bool? deleted,
    String? id,
    Map<String, dynamic>? rawJson,
  }) => DeletedVault(
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Metadata, secret, expiry, and OAuth refresh scope updates for an existing vault credential. Supply at least one of `auth` or `metadata`.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class RotateVaultCredentialRequest extends AgentJsonModel {
  /// Creates a validated [RotateVaultCredentialRequest].
  RotateVaultCredentialRequest({this.auth, Map<String, String>? metadata})
    : metadata = ownAgentValue<Map<String, String>>(
        metadata,
        Map<String, String>.unmodifiable,
      ) {
    validate();
  }

  /// Replacement values for the credential's existing authentication method.
  final RotateVaultCredentialAuth? auth;

  /// Replaces all metadata. Omit to preserve it, or pass {} to clear it. Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters.
  final Map<String, String>? metadata;

  /// Parses [RotateVaultCredentialRequest] with contextual, payload-free errors.
  factory RotateVaultCredentialRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'auth',
      'metadata',
    ], 'RotateVaultCredentialRequest');
    return RotateVaultCredentialRequest(
      auth: optionalAgentValue(
        json,
        'auth',
        'RotateVaultCredentialRequest.auth',
        (value, context) => RotateVaultCredentialAuth.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      ),
      metadata: optionalAgentValue(
        json,
        'metadata',
        'RotateVaultCredentialRequest.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
    );
  }
  @override
  void validate() {
    if (auth == null && metadata == null) {
      throw const FormatException(
        'Credential rotation requires auth or metadata',
      );
    }
    if (auth != null) {
      auth!.validate();
    }
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'RotateVaultCredentialRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'RotateVaultCredentialRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'RotateVaultCredentialRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    if (auth != null) 'auth': auth!.toJson(),
    'metadata': ?metadata,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  RotateVaultCredentialRequest copyWith({
    Object? auth = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => RotateVaultCredentialRequest(
    auth: copyAgentValue<RotateVaultCredentialAuth>(
      auth,
      this.auth,
      'RotateVaultCredentialRequest.auth',
    ),
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'RotateVaultCredentialRequest.metadata',
    ),
  );
}

/// Fields to replace on an active vault.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class UpdateVaultRequest extends AgentJsonModel {
  /// Creates a validated [UpdateVaultRequest].
  UpdateVaultRequest({
    Map<String, String>? metadata,
    String? name,
    bool clearName = false,
  }) : metadata = ownAgentValue<Map<String, String>>(
         metadata,
         Map<String, String>.unmodifiable,
       ),
       clearName = clearName,
       name = clearName ? null : name {
    validate();
  }

  /// Replaces all metadata. Omit to leave unchanged, or pass {} to clear it. Up to 16 string key-value pairs, with keys up to 64 and values up to 512 characters.
  final Map<String, String>? metadata;

  /// A replacement name. Omit to leave unchanged, or pass null to clear it. The name is trimmed before storage. It must contain 1 to 256 UTF-8 bytes after trimming.
  final String? name;

  /// Sends `name: null`, rather than omitting it.
  final bool clearName;

  /// Parses [UpdateVaultRequest] with contextual, payload-free errors.
  factory UpdateVaultRequest.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'metadata',
      'name',
    ], 'UpdateVaultRequest');
    return UpdateVaultRequest(
      metadata: optionalAgentValue(
        json,
        'metadata',
        'UpdateVaultRequest.metadata',
        requireAgentStringMap,
        nullable: false,
      ),
      name: optionalAgentValue(
        json,
        'name',
        'UpdateVaultRequest.name',
        requireAgentString,
        nullable: true,
      ),
      clearName: json.containsKey('name') && json['name'] == null,
    );
  }
  @override
  void validate() {
    if (name != null) _validateVaultName(name!, 'UpdateVaultRequest.name');
    if (metadata != null) {
      validateAgentCount(
        metadata!.length,
        'UpdateVaultRequest.metadata',
        min: 0,
        max: 16,
      );
      for (final key in metadata!.keys) {
        validateAgentLength(
          key,
          'UpdateVaultRequest.metadata',
          min: 1,
          max: 64,
        );
      }
      for (final item in metadata!.values) {
        validateAgentLength(
          item,
          'UpdateVaultRequest.metadata',
          min: 0,
          max: 512,
        );
      }
    }
    if (name != null) {
      validateAgentLength(
        name!,
        'UpdateVaultRequest.name',
        min: 1,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'metadata': ?metadata,
    if (clearName) 'name': null else 'name': ?name,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  UpdateVaultRequest copyWith({
    Object? metadata = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    bool? clearName,
  }) => UpdateVaultRequest(
    metadata: copyAgentValue<Map<String, String>>(
      metadata,
      this.metadata,
      'UpdateVaultRequest.metadata',
    ),
    name: copyAgentValue<String>(name, this.name, 'UpdateVaultRequest.name'),
    clearName:
        clearName ??
        (identical(name, unsetCopyWithValue) ? this.clearName : name == null),
  );
}

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultCredentialList extends AgentJsonModel {
  /// Creates a validated [VaultCredentialList].
  VaultCredentialList({
    required List<VaultCredential> data,
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
       ], 'VaultCredentialList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<VaultCredential> data;

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

  /// Parses [VaultCredentialList] with contextual, payload-free errors.
  factory VaultCredentialList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'VaultCredentialList');
    return VaultCredentialList(
      data: requiredAgentValue(
        json,
        'data',
        'VaultCredentialList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) =>
                  VaultCredential.fromJson(requireAgentObject(value, context)),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'VaultCredentialList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'VaultCredentialList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'VaultCredentialList.lastId',
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
      'VaultCredentialList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'VaultCredentialList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'VaultCredentialList.lastId', min: 0);
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
  VaultCredentialList copyWith({
    List<VaultCredential>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => VaultCredentialList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'VaultCredentialList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'VaultCredentialList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Metadata for a stored credential. Secret values are never returned.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultCredential extends AgentJsonModel {
  /// Creates a validated [VaultCredential].
  VaultCredential({
    required this.auth,
    required this.createdAt,
    required this.id,
    required Map<String, String> metadata,
    required this.name,
    required this.updatedAt,
    required this.vaultId,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       rawJson = _vaultReceivedExtras(rawJson, const [
         'auth',
         'created_at',
         'id',
         'metadata',
         'name',
         'object',
         'updated_at',
         'vault_id',
       ], 'VaultCredential') {
    validate();
  }

  /// The authentication method and non-secret configuration of the credential.
  final VaultCredentialAuth auth;

  /// The Unix timestamp, in seconds, when the credential was created.
  final int createdAt;

  /// The ID of the credential.
  final String id;

  /// Application-defined key-value pairs associated with this credential.
  final Map<String, String> metadata;

  /// The human-readable name of the credential.
  final String name;

  /// The object type. Always `vault.credential`.
  String get object => 'vault.credential';

  /// The Unix timestamp, in seconds, when the credential was last updated.
  final int updatedAt;

  /// The ID of the vault containing this credential.
  final String vaultId;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [VaultCredential] with contextual, payload-free errors.
  factory VaultCredential.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'vault.credential', 'VaultCredential');
    return VaultCredential(
      auth: requiredAgentValue(
        json,
        'auth',
        'VaultCredential.auth',
        (value, context) =>
            VaultCredentialAuth.fromJson(requireAgentObject(value, context)),
        nullable: false,
      )!,
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'VaultCredential.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'VaultCredential.id',
        requireAgentString,
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'VaultCredential.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'VaultCredential.name',
        requireAgentString,
        nullable: false,
      )!,
      updatedAt: requiredAgentValue(
        json,
        'updated_at',
        'VaultCredential.updatedAt',
        requireAgentInt,
        nullable: false,
      )!,
      vaultId: requiredAgentValue(
        json,
        'vault_id',
        'VaultCredential.vaultId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'auth',
            'created_at',
            'id',
            'metadata',
            'name',
            'object',
            'updated_at',
            'vault_id',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    auth.validate();
    validateAgentInt(createdAt, 'VaultCredential.createdAt');
    validateAgentLength(id, 'VaultCredential.id', min: 0);
    validateAgentCount(metadata.length, 'VaultCredential.metadata', min: 0);
    for (final key in metadata.keys) {
      validateAgentLength(key, 'VaultCredential.metadata', min: 0);
    }
    for (final item in metadata.values) {
      validateAgentLength(item, 'VaultCredential.metadata', min: 0);
    }
    validateAgentLength(name, 'VaultCredential.name', min: 0);
    validateAgentInt(updatedAt, 'VaultCredential.updatedAt');
    validateAgentLength(vaultId, 'VaultCredential.vaultId', min: 0);
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'auth': auth.toJson(),
    'created_at': createdAt,
    'id': id,
    'metadata': metadata,
    'name': name,
    'object': object,
    'updated_at': updatedAt,
    'vault_id': vaultId,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  VaultCredential copyWith({
    VaultCredentialAuth? auth,
    int? createdAt,
    String? id,
    Map<String, String>? metadata,
    String? name,
    int? updatedAt,
    String? vaultId,
    Map<String, dynamic>? rawJson,
  }) => VaultCredential(
    auth: auth ?? this.auth,
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    name: name ?? this.name,
    updatedAt: updatedAt ?? this.updatedAt,
    vaultId: vaultId ?? this.vaultId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class VaultList extends AgentJsonModel {
  /// Creates a validated [VaultList].
  VaultList({
    required List<Vault> data,
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
       ], 'VaultList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<Vault> data;

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

  /// Parses [VaultList] with contextual, payload-free errors.
  factory VaultList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'VaultList');
    return VaultList(
      data: requiredAgentValue(
        json,
        'data',
        'VaultList.data',
        (value, context) => requireAgentList(value, context)
            .map((value) => Vault.fromJson(requireAgentObject(value, context)))
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'VaultList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'VaultList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'VaultList.lastId',
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
    validateAgentCount(data.length, 'VaultList.data', min: 0, max: 2000);
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'VaultList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'VaultList.lastId', min: 0);
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
  VaultList copyWith({
    List<Vault>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => VaultList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(firstId, this.firstId, 'VaultList.firstId'),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(lastId, this.lastId, 'VaultList.lastId'),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A collection of credentials for MCP servers and OpenAI-hosted environments.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class Vault extends AgentJsonModel {
  /// Creates a validated [Vault].
  Vault({
    required this.createdAt,
    required this.id,
    required Map<String, String> metadata,
    required this.name,
    Map<String, dynamic> rawJson = const {},
  }) : metadata = Map<String, String>.unmodifiable(metadata),
       rawJson = agentExtras(rawJson, const [
         'created_at',
         'id',
         'metadata',
         'name',
         'object',
       ], 'Vault') {
    validate();
  }

  /// The Unix timestamp, in seconds, when the vault was created.
  final int createdAt;

  /// The ID of the vault.
  final String id;

  /// Key-value pairs associated with the vault, such as an application or team identifier.
  final Map<String, String> metadata;

  /// The human-readable name of the vault, if set.
  final String? name;

  /// The object type. Always `vault`.
  String get object => 'vault';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [Vault] with contextual, payload-free errors.
  factory Vault.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'vault', 'Vault');
    return Vault(
      createdAt: requiredAgentValue(
        json,
        'created_at',
        'Vault.createdAt',
        requireAgentInt,
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'Vault.id',
        requireAgentString,
        nullable: false,
      )!,
      metadata: requiredAgentValue(
        json,
        'metadata',
        'Vault.metadata',
        requireAgentStringMap,
        nullable: false,
      )!,
      name: requiredAgentValue(
        json,
        'name',
        'Vault.name',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'created_at',
            'id',
            'metadata',
            'name',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentInt(createdAt, 'Vault.createdAt');
    validateAgentLength(id, 'Vault.id', min: 0);
    validateAgentCount(metadata.length, 'Vault.metadata', min: 0);
    for (final key in metadata.keys) {
      validateAgentLength(key, 'Vault.metadata', min: 0);
    }
    for (final item in metadata.values) {
      validateAgentLength(item, 'Vault.metadata', min: 0);
    }
    if (name != null) {
      validateAgentLength(name!, 'Vault.name', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'created_at': createdAt,
    'id': id,
    'metadata': metadata,
    'name': name,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  Vault copyWith({
    int? createdAt,
    String? id,
    Map<String, String>? metadata,
    Object? name = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => Vault(
    createdAt: createdAt ?? this.createdAt,
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    name: copyAgentValue<String>(name, this.name, 'Vault.name'),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Whether a vault or credential is active or archived.
///
/// Future received values retain their original string. Request models reject
/// values outside the pinned set before authentication or dispatch.
final class VaultStatus extends AgentJsonModel {
  const VaultStatus._(this.value);

  /// The `active` wire value.
  static const VaultStatus active = VaultStatus._('active');

  /// The `archived` wire value.
  static const VaultStatus archived = VaultStatus._('archived');

  /// The exact wire value.
  final String value;

  /// Parses a known or future string without normalization.
  factory VaultStatus.fromJson(Object? json) {
    final value = requireAgentString(json, 'VaultStatus');
    return switch (value) {
      'active' => active,
      'archived' => archived,
      _ => VaultStatus._(value),
    };
  }

  /// Whether the value belongs to the pinned source enum.
  bool get isKnown => const ['active', 'archived'].contains(value);

  @override
  String toJson() => value;

  /// Copies the exact known or future received string.
  VaultStatus copyWith({String? value}) =>
      VaultStatus.fromJson(value ?? this.value);
}

/// A scalar [VaultSingleStatus] or array [VaultMultipleStatuses] query filter.
/// Omission includes both statuses; arrays preserve order and duplicates.
sealed class VaultStatusFilter extends AgentJsonModel {
  const VaultStatusFilter();

  /// Sends `status=active` or `status=archived`.
  factory VaultStatusFilter.single(VaultStatus status) = VaultSingleStatus;

  /// Sends repeated `status[]` keys; an empty array remains an array value.
  factory VaultStatusFilter.multiple(List<VaultStatus> statuses) =
      VaultMultipleStatuses;

  /// Parses the source scalar/array union without coercing either shape.
  factory VaultStatusFilter.fromJson(Object? json) {
    if (json is String) return VaultSingleStatus(VaultStatus.fromJson(json));
    return VaultMultipleStatuses(
      requireAgentList(
        json,
        'VaultStatusFilter',
      ).map(VaultStatus.fromJson).toList(),
    );
  }
}

/// A single canonical status query value.
final class VaultSingleStatus extends VaultStatusFilter {
  /// Creates a validated scalar filter.
  VaultSingleStatus(this.status) {
    validate();
  }

  /// The scalar status.
  final VaultStatus status;
  @override
  void validate() => validateAgentEnum(status.value, const [
    'active',
    'archived',
  ], 'Vault status');
  @override
  String toJson() => status.value;

  /// Copies the scalar status.
  VaultSingleStatus copyWith({VaultStatus? status}) =>
      VaultSingleStatus(status ?? this.status);
}

/// A detached array of canonical statuses, including empty or duplicate values.
final class VaultMultipleStatuses extends VaultStatusFilter {
  /// Creates an immutable array filter with the source 16,384-item bound.
  VaultMultipleStatuses(List<VaultStatus> statuses)
    : statuses = List.unmodifiable(statuses) {
    validate();
  }

  /// The statuses in caller order.
  final List<VaultStatus> statuses;
  @override
  void validate() {
    validateAgentCount(statuses.length, 'Vault statuses', max: 16384);
    for (final status in statuses) {
      validateAgentEnum(status.value, const [
        'active',
        'archived',
      ], 'Vault status');
    }
  }

  @override
  List<String> toJson() => statuses.map((value) => value.value).toList();

  /// Copies and detaches an array filter.
  VaultMultipleStatuses copyWith({List<VaultStatus>? statuses}) =>
      VaultMultipleStatuses(statuses ?? this.statuses);
}
