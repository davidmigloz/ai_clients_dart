import 'admin_json.dart';

/// UpdateProjectApiKeyRequest
final class UpdateProjectApiKeyRequest extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  UpdateProjectApiKeyRequest({
    this.expiresInSeconds,
    List<String>? scopes,
    Map<String, dynamic> rawJson = const {},
  }) : scopes = scopes == null ? null : List<String>.unmodifiable(scopes),
       rawJson = adminExtras(rawJson, {
         'expires_in_seconds',
         'scopes',
       }, 'UpdateProjectApiKeyRequest') {
    validate();
  }

  /// Exact `expires_in_seconds` wire value.
  final int? expiresInSeconds;

  /// Exact `scopes` wire value.
  final List<String>? scopes;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory UpdateProjectApiKeyRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProjectApiKeyRequest(
      expiresInSeconds: adminOptional<int>(
        json,
        'expires_in_seconds',
        'UpdateProjectApiKeyRequest.expiresInSeconds',
        adminInt,
        nullable: false,
      ),
      scopes: adminOptional<List<String>>(
        json,
        'scopes',
        'UpdateProjectApiKeyRequest.scopes',
        (value, context) => [
          for (final item in adminList(value, context))
            adminString(item, context),
        ],
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (expiresInSeconds != null) {
      adminInt(expiresInSeconds, 'UpdateProjectApiKeyRequest.expiresInSeconds');
      if (expiresInSeconds! < 1 || expiresInSeconds! > 31536000) {
        throw const FormatException(
          'UpdateProjectApiKeyRequest.expiresInSeconds: out of range',
        );
      }
    }
    if (scopes == null && expiresInSeconds == null) {
      throw const FormatException(
        'UpdateProjectApiKeyRequest: supply scopes or expiresInSeconds',
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    if (expiresInSeconds != null) 'expires_in_seconds': expiresInSeconds,
    if (scopes != null) 'scopes': scopes,
  };

  /// Copies every field; clear flags omit optional nullable members.
  UpdateProjectApiKeyRequest copyWith({
    Object? expiresInSeconds = unsetCopyWithValue,
    Object? scopes = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => UpdateProjectApiKeyRequest(
    expiresInSeconds: adminCopy<int>(
      expiresInSeconds,
      this.expiresInSeconds,
      'UpdateProjectApiKeyRequest.expiresInSeconds',
    ),
    scopes: adminCopyList<String>(
      scopes,
      this.scopes,
      'UpdateProjectApiKeyRequest.scopes',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The user that owns a project API key.
final class ProjectApiKeyOwnerUser extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ProjectApiKeyOwnerUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'id',
         'email',
         'name',
         'created_at',
         'role',
       }, 'ProjectApiKeyOwnerUser') {
    validate();
  }

  /// Exact `id` wire value.
  final String id;

  /// Exact `email` wire value.
  final String email;

  /// Exact `name` wire value.
  final String name;

  /// Exact `created_at` wire value.
  final int createdAt;

  /// Exact `role` wire value.
  final String role;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ProjectApiKeyOwnerUser.fromJson(Map<String, dynamic> json) {
    return ProjectApiKeyOwnerUser(
      id: adminRequired<String>(
        json,
        'id',
        'ProjectApiKeyOwnerUser.id',
        adminString,
        nullable: false,
      )!,
      email: adminRequired<String>(
        json,
        'email',
        'ProjectApiKeyOwnerUser.email',
        adminString,
        nullable: false,
      )!,
      name: adminRequired<String>(
        json,
        'name',
        'ProjectApiKeyOwnerUser.name',
        adminString,
        nullable: false,
      )!,
      createdAt: adminRequired<int>(
        json,
        'created_at',
        'ProjectApiKeyOwnerUser.createdAt',
        adminInt,
        nullable: false,
      )!,
      role: adminRequired<String>(
        json,
        'role',
        'ProjectApiKeyOwnerUser.role',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    adminInt(createdAt, 'ProjectApiKeyOwnerUser.createdAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'email': email,
    'name': name,
    'created_at': createdAt,
    'role': role,
  };

  /// Copies every field; clear flags omit optional nullable members.
  ProjectApiKeyOwnerUser copyWith({
    String? id,
    String? email,
    String? name,
    int? createdAt,
    String? role,
    Map<String, dynamic>? rawJson,
  }) => ProjectApiKeyOwnerUser(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    role: role ?? this.role,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// The service account that owns a project API key.
final class ProjectApiKeyOwnerServiceAccount extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ProjectApiKeyOwnerServiceAccount({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.role,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'id',
         'name',
         'created_at',
         'role',
       }, 'ProjectApiKeyOwnerServiceAccount') {
    validate();
  }

  /// Exact `id` wire value.
  final String id;

  /// Exact `name` wire value.
  final String name;

  /// Exact `created_at` wire value.
  final int createdAt;

  /// Exact `role` wire value.
  final String role;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ProjectApiKeyOwnerServiceAccount.fromJson(Map<String, dynamic> json) {
    return ProjectApiKeyOwnerServiceAccount(
      id: adminRequired<String>(
        json,
        'id',
        'ProjectApiKeyOwnerServiceAccount.id',
        adminString,
        nullable: false,
      )!,
      name: adminRequired<String>(
        json,
        'name',
        'ProjectApiKeyOwnerServiceAccount.name',
        adminString,
        nullable: false,
      )!,
      createdAt: adminRequired<int>(
        json,
        'created_at',
        'ProjectApiKeyOwnerServiceAccount.createdAt',
        adminInt,
        nullable: false,
      )!,
      role: adminRequired<String>(
        json,
        'role',
        'ProjectApiKeyOwnerServiceAccount.role',
        adminString,
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    adminInt(createdAt, 'ProjectApiKeyOwnerServiceAccount.createdAt');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'name': name,
    'created_at': createdAt,
    'role': role,
  };

  /// Copies every field; clear flags omit optional nullable members.
  ProjectApiKeyOwnerServiceAccount copyWith({
    String? id,
    String? name,
    int? createdAt,
    String? role,
    Map<String, dynamic>? rawJson,
  }) => ProjectApiKeyOwnerServiceAccount(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    role: role ?? this.role,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// ProjectApiKeyOwner
final class ProjectApiKeyOwner extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ProjectApiKeyOwner({
    this.type,
    this.user,
    this.serviceAccount,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = adminExtras(rawJson, {
         'type',
         'user',
         'service_account',
       }, 'ProjectApiKeyOwner') {
    validate();
  }

  /// Exact `type` wire value.
  final String? type;

  /// Exact `user` wire value.
  final ProjectApiKeyOwnerUser? user;

  /// Exact `service_account` wire value.
  final ProjectApiKeyOwnerServiceAccount? serviceAccount;

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ProjectApiKeyOwner.fromJson(Map<String, dynamic> json) {
    return ProjectApiKeyOwner(
      type: adminOptional<String>(
        json,
        'type',
        'ProjectApiKeyOwner.type',
        adminString,
        nullable: false,
      ),
      user: adminOptional<ProjectApiKeyOwnerUser>(
        json,
        'user',
        'ProjectApiKeyOwner.user',
        (value, context) =>
            ProjectApiKeyOwnerUser.fromJson(adminObject(value, context)),
        nullable: false,
      ),
      serviceAccount: adminOptional<ProjectApiKeyOwnerServiceAccount>(
        json,
        'service_account',
        'ProjectApiKeyOwner.serviceAccount',
        (value, context) => ProjectApiKeyOwnerServiceAccount.fromJson(
          adminObject(value, context),
        ),
        nullable: false,
      ),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (user != null) {
      user!.validate();
    }
    if (serviceAccount != null) {
      serviceAccount!.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    if (type != null) 'type': type,
    if (user != null) 'user': user!.toJson(),
    if (serviceAccount != null) 'service_account': serviceAccount!.toJson(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  ProjectApiKeyOwner copyWith({
    Object? type = unsetCopyWithValue,
    Object? user = unsetCopyWithValue,
    Object? serviceAccount = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => ProjectApiKeyOwner(
    type: adminCopy<String>(type, this.type, 'ProjectApiKeyOwner.type'),
    user: adminCopy<ProjectApiKeyOwnerUser>(
      user,
      this.user,
      'ProjectApiKeyOwner.user',
    ),
    serviceAccount: adminCopy<ProjectApiKeyOwnerServiceAccount>(
      serviceAccount,
      this.serviceAccount,
      'ProjectApiKeyOwner.serviceAccount',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// Represents an individual API key in a project.
final class ProjectApiKey extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  ProjectApiKey({
    required this.redactedValue,
    required this.name,
    required this.createdAt,
    this.expiresAt,
    bool hasExpiresAt = false,
    required this.lastUsedAt,
    required this.id,
    required this.ownerProjectAccess,
    required this.owner,
    Map<String, dynamic> rawJson = const {},
  }) : hasExpiresAt = hasExpiresAt || expiresAt != null,
       rawJson = adminExtras(rawJson, {
         'object',
         'redacted_value',
         'name',
         'created_at',
         'expires_at',
         'last_used_at',
         'id',
         'owner_project_access',
         'owner',
       }, 'ProjectApiKey') {
    validate();
  }

  /// Exact `redacted_value` wire value.
  final String redactedValue;

  /// Exact `name` wire value.
  final String name;

  /// Exact `created_at` wire value.
  final int createdAt;

  /// Exact `expires_at` wire value.
  final int? expiresAt;

  /// Whether the optional nullable member is present, including null.
  final bool hasExpiresAt;

  /// Exact `last_used_at` wire value.
  final int? lastUsedAt;

  /// Exact `id` wire value.
  final String id;

  /// Exact `owner_project_access` wire value.
  final String ownerProjectAccess;

  /// Exact `owner` wire value.
  final ProjectApiKeyOwner owner;

  /// Fixed native discriminator.
  String get object => 'organization.project.api_key';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory ProjectApiKey.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'object', 'organization.project.api_key', 'ProjectApiKey');
    return ProjectApiKey(
      redactedValue: adminRequired<String>(
        json,
        'redacted_value',
        'ProjectApiKey.redactedValue',
        adminString,
        nullable: false,
      )!,
      name: adminRequired<String>(
        json,
        'name',
        'ProjectApiKey.name',
        adminString,
        nullable: false,
      )!,
      createdAt: adminRequired<int>(
        json,
        'created_at',
        'ProjectApiKey.createdAt',
        adminInt,
        nullable: false,
      )!,
      expiresAt: adminOptional<int>(
        json,
        'expires_at',
        'ProjectApiKey.expiresAt',
        adminInt,
        nullable: true,
      ),
      hasExpiresAt: json.containsKey('expires_at'),
      lastUsedAt: adminRequired<int>(
        json,
        'last_used_at',
        'ProjectApiKey.lastUsedAt',
        adminInt,
        nullable: true,
      ),
      id: adminRequired<String>(
        json,
        'id',
        'ProjectApiKey.id',
        adminString,
        nullable: false,
      )!,
      ownerProjectAccess: adminRequired<String>(
        json,
        'owner_project_access',
        'ProjectApiKey.ownerProjectAccess',
        adminString,
        nullable: false,
      )!,
      owner: adminRequired<ProjectApiKeyOwner>(
        json,
        'owner',
        'ProjectApiKey.owner',
        (value, context) =>
            ProjectApiKeyOwner.fromJson(adminObject(value, context)),
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    adminInt(createdAt, 'ProjectApiKey.createdAt');
    if (expiresAt != null) {
      adminInt(expiresAt, 'ProjectApiKey.expiresAt');
    }
    if (lastUsedAt != null) {
      adminInt(lastUsedAt, 'ProjectApiKey.lastUsedAt');
    }
    owner.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'redacted_value': redactedValue,
    'name': name,
    'created_at': createdAt,
    if (hasExpiresAt) 'expires_at': expiresAt,
    'last_used_at': lastUsedAt,
    'id': id,
    'owner_project_access': ownerProjectAccess,
    'owner': owner.toJson(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  ProjectApiKey copyWith({
    String? redactedValue,
    String? name,
    int? createdAt,
    Object? expiresAt = unsetCopyWithValue,
    bool clearExpiresAt = false,
    Object? lastUsedAt = unsetCopyWithValue,
    String? id,
    String? ownerProjectAccess,
    ProjectApiKeyOwner? owner,
    Map<String, dynamic>? rawJson,
  }) => ProjectApiKey(
    redactedValue: redactedValue ?? this.redactedValue,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: clearExpiresAt
        ? null
        : (adminCopy<int>(
            expiresAt,
            this.expiresAt,
            'ProjectApiKey.expiresAt',
          )),
    hasExpiresAt:
        !clearExpiresAt &&
        (!identical(expiresAt, unsetCopyWithValue) || hasExpiresAt),
    lastUsedAt: adminCopy<int>(
      lastUsedAt,
      this.lastUsedAt,
      'ProjectApiKey.lastUsedAt',
    ),
    id: id ?? this.id,
    ownerProjectAccess: ownerProjectAccess ?? this.ownerProjectAccess,
    owner: owner ?? this.owner,
    rawJson: rawJson ?? this.rawJson,
  );
}
