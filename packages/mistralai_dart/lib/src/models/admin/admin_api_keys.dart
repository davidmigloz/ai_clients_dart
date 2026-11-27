import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative api key list.
@immutable
class AdminApiKeyList {
  /// Creates a [AdminApiKeyList].
  const AdminApiKeyList({required this.keys});

  /// API keys for the Organization.
  final List<AdminApiKeySummary> keys;

  /// Parses a [AdminApiKeyList] from JSON.
  factory AdminApiKeyList.fromJson(Map<String, dynamic> json) {
    if (json['keys'] == null) {
      throw const FormatException('AdminApiKeyList: missing keys');
    }
    return AdminApiKeyList(
      keys: (json['keys'] as List)
          .map(
            (item) => AdminApiKeySummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'keys': keys.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AdminApiKeyList copyWith({List<AdminApiKeySummary>? keys}) =>
      AdminApiKeyList(keys: keys ?? this.keys);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminApiKeyList &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(keys, other.keys);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(keys)]);

  @override
  String toString() =>
      'AdminApiKeyList('
      'keys: ${keys.length})';
}

/// Administrative create admin api key request.
@immutable
class CreateAdminApiKeyRequest {
  /// Creates a [CreateAdminApiKeyRequest].
  const CreateAdminApiKeyRequest({
    this.expiration,
    this.name,
    required this.userId,
    required this.workspaceUuid,
  });

  /// Date when the API key should expire.
  final String? expiration;

  /// Optional name for the API key.
  final String? name;

  /// ID of the user the API key is created for.
  final String userId;

  /// Workspace ID for the API key.
  final String workspaceUuid;

  /// Parses a [CreateAdminApiKeyRequest] from JSON.
  factory CreateAdminApiKeyRequest.fromJson(Map<String, dynamic> json) {
    if (json['user_id'] == null) {
      throw const FormatException('CreateAdminApiKeyRequest: missing user_id');
    }
    if (json['workspace_uuid'] == null) {
      throw const FormatException(
        'CreateAdminApiKeyRequest: missing workspace_uuid',
      );
    }
    return CreateAdminApiKeyRequest(
      expiration: json['expiration'] == null
          ? null
          : json['expiration'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      userId: json['user_id'] as String,
      workspaceUuid: json['workspace_uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'expiration': ?expiration,
    'name': ?name,
    'user_id': userId,
    'workspace_uuid': workspaceUuid,
  };

  /// Creates a copy with the given fields replaced.
  CreateAdminApiKeyRequest copyWith({
    Object? expiration = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    String? userId,
    String? workspaceUuid,
  }) => CreateAdminApiKeyRequest(
    expiration: expiration == unsetCopyWithValue
        ? this.expiration
        : expiration as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    userId: userId ?? this.userId,
    workspaceUuid: workspaceUuid ?? this.workspaceUuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateAdminApiKeyRequest &&
          runtimeType == other.runtimeType &&
          expiration == other.expiration &&
          name == other.name &&
          userId == other.userId &&
          workspaceUuid == other.workspaceUuid;

  @override
  int get hashCode => Object.hashAll([expiration, name, userId, workspaceUuid]);

  @override
  String toString() =>
      'CreateAdminApiKeyRequest('
      'expiration: $expiration, '
      'name: $name, '
      'userId: $userId, '
      'workspaceUuid: $workspaceUuid)';
}

/// Administrative created api key.
@immutable
class AdminCreatedApiKey {
  /// Creates a [AdminCreatedApiKey].
  const AdminCreatedApiKey({
    required this.actions,
    required this.createdAt,
    required this.expirationDate,
    required this.hiddenKey,
    required this.key,
    required this.keyId,
    required this.name,
  });

  /// Per-action availability for this API key (e.g. whether it can be rotated or deleted).
  final AdminApiKeyActions actions;

  /// Time when the API key was created.
  final String? createdAt;

  /// Date when the API key expires.
  final String? expirationDate;

  /// Masked API key value for display.
  final String hiddenKey;

  /// Plaintext API key value. Only returned at creation time.
  final String? key;

  /// API key ID.
  final String keyId;

  /// Name of the API key.
  final String? name;

  /// Parses a [AdminCreatedApiKey] from JSON.
  factory AdminCreatedApiKey.fromJson(Map<String, dynamic> json) {
    if (json['actions'] == null) {
      throw const FormatException('AdminCreatedApiKey: missing actions');
    }
    if (!json.containsKey('created_at')) {
      throw const FormatException('AdminCreatedApiKey: missing created_at');
    }
    if (!json.containsKey('expiration_date')) {
      throw const FormatException(
        'AdminCreatedApiKey: missing expiration_date',
      );
    }
    if (json['hidden_key'] == null) {
      throw const FormatException('AdminCreatedApiKey: missing hidden_key');
    }
    if (!json.containsKey('key')) {
      throw const FormatException('AdminCreatedApiKey: missing key');
    }
    if (json['key_id'] == null) {
      throw const FormatException('AdminCreatedApiKey: missing key_id');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminCreatedApiKey: missing name');
    }
    return AdminCreatedApiKey(
      actions: AdminApiKeyActions.fromJson(
        json['actions'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] == null
          ? null
          : json['created_at'] as String,
      expirationDate: json['expiration_date'] == null
          ? null
          : json['expiration_date'] as String,
      hiddenKey: json['hidden_key'] as String,
      key: json['key'] == null ? null : json['key'] as String,
      keyId: json['key_id'] as String,
      name: json['name'] == null ? null : json['name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'actions': actions.toJson(),
    'created_at': createdAt,
    'expiration_date': expirationDate,
    'hidden_key': hiddenKey,
    'key': key,
    'key_id': keyId,
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  AdminCreatedApiKey copyWith({
    AdminApiKeyActions? actions,
    Object? createdAt = unsetCopyWithValue,
    Object? expirationDate = unsetCopyWithValue,
    String? hiddenKey,
    Object? key = unsetCopyWithValue,
    String? keyId,
    Object? name = unsetCopyWithValue,
  }) => AdminCreatedApiKey(
    actions: actions ?? this.actions,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    expirationDate: expirationDate == unsetCopyWithValue
        ? this.expirationDate
        : expirationDate as String?,
    hiddenKey: hiddenKey ?? this.hiddenKey,
    key: key == unsetCopyWithValue ? this.key : key as String?,
    keyId: keyId ?? this.keyId,
    name: name == unsetCopyWithValue ? this.name : name as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminCreatedApiKey &&
          runtimeType == other.runtimeType &&
          actions == other.actions &&
          createdAt == other.createdAt &&
          expirationDate == other.expirationDate &&
          hiddenKey == other.hiddenKey &&
          key == other.key &&
          keyId == other.keyId &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([
    actions,
    createdAt,
    expirationDate,
    hiddenKey,
    key,
    keyId,
    name,
  ]);

  @override
  String toString() =>
      'AdminCreatedApiKey('
      'actions: $actions, '
      'createdAt: $createdAt, '
      'expirationDate: $expirationDate, '
      'hiddenKey: [REDACTED], '
      'key: [REDACTED], '
      'keyId: $keyId, '
      'name: $name)';
}

/// Administrative deleted api key.
@immutable
class AdminDeletedApiKey {
  /// Creates a [AdminDeletedApiKey].
  const AdminDeletedApiKey({required this.detail});

  /// API key deletion result message.
  final String detail;

  /// Parses a [AdminDeletedApiKey] from JSON.
  factory AdminDeletedApiKey.fromJson(Map<String, dynamic> json) {
    if (json['detail'] == null) {
      throw const FormatException('AdminDeletedApiKey: missing detail');
    }
    return AdminDeletedApiKey(detail: json['detail'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'detail': detail};

  /// Creates a copy with the given fields replaced.
  AdminDeletedApiKey copyWith({String? detail}) =>
      AdminDeletedApiKey(detail: detail ?? this.detail);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDeletedApiKey &&
          runtimeType == other.runtimeType &&
          detail == other.detail;

  @override
  int get hashCode => Object.hashAll([detail]);

  @override
  String toString() =>
      'AdminDeletedApiKey('
      'detail: $detail)';
}

/// Administrative api key summary.
@immutable
class AdminApiKeySummary {
  /// Creates a [AdminApiKeySummary].
  const AdminApiKeySummary({
    required this.actions,
    required this.canDelete,
    required this.createdAt,
    required this.createdBy,
    required this.expirationDate,
    required this.hiddenKey,
    required this.key,
    required this.keyId,
    required this.lastUsed,
    required this.name,
    required this.product,
    this.serviceAccountId,
    this.userId,
    required this.workspaceId,
    required this.workspaceName,
  });

  /// Per-action availability for this API key (e.g. whether it can be rotated or deleted).
  final AdminApiKeyActions actions;

  /// Whether you can delete this API key.
  final bool? canDelete;

  /// Time when the API key was created.
  final String? createdAt;

  /// User or API key that created this API key.
  final String? createdBy;

  /// Date when the API key expires.
  final String? expirationDate;

  /// Masked API key value for display.
  final String hiddenKey;

  /// Plaintext API key value. Only returned at creation time.
  final String? key;

  /// API key ID.
  final String keyId;

  /// Date when the API key was last used.
  final String? lastUsed;

  /// Name of the API key.
  final String? name;

  /// Product the API key belongs to.
  final AdminApiKeyProduct? product;

  /// ID of the service account that owns the API key. Null for keys not owned by a service account.
  final String? serviceAccountId;

  /// ID of the user who owns the API key. Null for keys not owned by a user.
  final String? userId;

  /// Workspace ID for the API key.
  final String? workspaceId;

  /// Name of the Workspace for the API key.
  final String? workspaceName;

  /// Parses a [AdminApiKeySummary] from JSON.
  factory AdminApiKeySummary.fromJson(Map<String, dynamic> json) {
    if (json['actions'] == null) {
      throw const FormatException('AdminApiKeySummary: missing actions');
    }
    if (!json.containsKey('can_delete')) {
      throw const FormatException('AdminApiKeySummary: missing can_delete');
    }
    if (!json.containsKey('created_at')) {
      throw const FormatException('AdminApiKeySummary: missing created_at');
    }
    if (!json.containsKey('created_by')) {
      throw const FormatException('AdminApiKeySummary: missing created_by');
    }
    if (!json.containsKey('expiration_date')) {
      throw const FormatException(
        'AdminApiKeySummary: missing expiration_date',
      );
    }
    if (json['hidden_key'] == null) {
      throw const FormatException('AdminApiKeySummary: missing hidden_key');
    }
    if (!json.containsKey('key')) {
      throw const FormatException('AdminApiKeySummary: missing key');
    }
    if (json['key_id'] == null) {
      throw const FormatException('AdminApiKeySummary: missing key_id');
    }
    if (!json.containsKey('last_used')) {
      throw const FormatException('AdminApiKeySummary: missing last_used');
    }
    if (!json.containsKey('name')) {
      throw const FormatException('AdminApiKeySummary: missing name');
    }
    if (!json.containsKey('product')) {
      throw const FormatException('AdminApiKeySummary: missing product');
    }
    if (!json.containsKey('workspace_id')) {
      throw const FormatException('AdminApiKeySummary: missing workspace_id');
    }
    if (!json.containsKey('workspace_name')) {
      throw const FormatException('AdminApiKeySummary: missing workspace_name');
    }
    return AdminApiKeySummary(
      actions: AdminApiKeyActions.fromJson(
        json['actions'] as Map<String, dynamic>,
      ),
      canDelete: json['can_delete'] == null ? null : json['can_delete'] as bool,
      createdAt: json['created_at'] == null
          ? null
          : json['created_at'] as String,
      createdBy: json['created_by'] == null
          ? null
          : json['created_by'] as String,
      expirationDate: json['expiration_date'] == null
          ? null
          : json['expiration_date'] as String,
      hiddenKey: json['hidden_key'] as String,
      key: json['key'] == null ? null : json['key'] as String,
      keyId: json['key_id'] as String,
      lastUsed: json['last_used'] == null ? null : json['last_used'] as String,
      name: json['name'] == null ? null : json['name'] as String,
      product: json['product'] == null
          ? null
          : AdminApiKeyProduct.fromJson(json['product'] as String),
      serviceAccountId: json['service_account_id'] == null
          ? null
          : json['service_account_id'] as String,
      userId: json['user_id'] == null ? null : json['user_id'] as String,
      workspaceId: json['workspace_id'] == null
          ? null
          : json['workspace_id'] as String,
      workspaceName: json['workspace_name'] == null
          ? null
          : json['workspace_name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'actions': actions.toJson(),
    'can_delete': canDelete,
    'created_at': createdAt,
    'created_by': createdBy,
    'expiration_date': expirationDate,
    'hidden_key': hiddenKey,
    'key': key,
    'key_id': keyId,
    'last_used': lastUsed,
    'name': name,
    'product': product?.toJson(),
    'service_account_id': ?serviceAccountId,
    'user_id': ?userId,
    'workspace_id': workspaceId,
    'workspace_name': workspaceName,
  };

  /// Creates a copy with the given fields replaced.
  AdminApiKeySummary copyWith({
    AdminApiKeyActions? actions,
    Object? canDelete = unsetCopyWithValue,
    Object? createdAt = unsetCopyWithValue,
    Object? createdBy = unsetCopyWithValue,
    Object? expirationDate = unsetCopyWithValue,
    String? hiddenKey,
    Object? key = unsetCopyWithValue,
    String? keyId,
    Object? lastUsed = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? product = unsetCopyWithValue,
    Object? serviceAccountId = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? workspaceId = unsetCopyWithValue,
    Object? workspaceName = unsetCopyWithValue,
  }) => AdminApiKeySummary(
    actions: actions ?? this.actions,
    canDelete: canDelete == unsetCopyWithValue
        ? this.canDelete
        : canDelete as bool?,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    createdBy: createdBy == unsetCopyWithValue
        ? this.createdBy
        : createdBy as String?,
    expirationDate: expirationDate == unsetCopyWithValue
        ? this.expirationDate
        : expirationDate as String?,
    hiddenKey: hiddenKey ?? this.hiddenKey,
    key: key == unsetCopyWithValue ? this.key : key as String?,
    keyId: keyId ?? this.keyId,
    lastUsed: lastUsed == unsetCopyWithValue
        ? this.lastUsed
        : lastUsed as String?,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    product: product == unsetCopyWithValue
        ? this.product
        : product as AdminApiKeyProduct?,
    serviceAccountId: serviceAccountId == unsetCopyWithValue
        ? this.serviceAccountId
        : serviceAccountId as String?,
    userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
    workspaceId: workspaceId == unsetCopyWithValue
        ? this.workspaceId
        : workspaceId as String?,
    workspaceName: workspaceName == unsetCopyWithValue
        ? this.workspaceName
        : workspaceName as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminApiKeySummary &&
          runtimeType == other.runtimeType &&
          actions == other.actions &&
          canDelete == other.canDelete &&
          createdAt == other.createdAt &&
          createdBy == other.createdBy &&
          expirationDate == other.expirationDate &&
          hiddenKey == other.hiddenKey &&
          key == other.key &&
          keyId == other.keyId &&
          lastUsed == other.lastUsed &&
          name == other.name &&
          product == other.product &&
          serviceAccountId == other.serviceAccountId &&
          userId == other.userId &&
          workspaceId == other.workspaceId &&
          workspaceName == other.workspaceName;

  @override
  int get hashCode => Object.hashAll([
    actions,
    canDelete,
    createdAt,
    createdBy,
    expirationDate,
    hiddenKey,
    key,
    keyId,
    lastUsed,
    name,
    product,
    serviceAccountId,
    userId,
    workspaceId,
    workspaceName,
  ]);

  @override
  String toString() =>
      'AdminApiKeySummary('
      'actions: $actions, '
      'canDelete: $canDelete, '
      'createdAt: $createdAt, '
      'createdBy: $createdBy, '
      'expirationDate: $expirationDate, '
      'hiddenKey: [REDACTED], '
      'key: [REDACTED], '
      'keyId: $keyId, '
      'lastUsed: $lastUsed, '
      'name: $name, '
      'product: $product, '
      'serviceAccountId: $serviceAccountId, '
      'userId: $userId, '
      'workspaceId: $workspaceId, '
      'workspaceName: $workspaceName)';
}

/// Per-action availability for an API key, keyed by action name. This is the generic, reusable shape for surfacing what a viewer may do with a resource on get/list endpoints: each action maps to a value that is either available or unavailable with an optional reason code. Add fields here as more actions are exposed. Every action is opt-in: fields default to ``None`` (the action is absent), and an absent action means "unavailable, with no specified reason". An action is only available when a producer explicitly sets it to ``ActionAvailable``. This keeps permissions opt-in rather than opt-out, so forgetting to populate an action can never accidentally expose it.
@immutable
class AdminApiKeyActions {
  /// Creates a [AdminApiKeyActions].
  const AdminApiKeyActions({this.delete, this.rotate});

  /// The delete field.
  final AdminApiKeyAction? delete;

  /// The rotate field.
  final AdminApiKeyAction? rotate;

  /// Parses a [AdminApiKeyActions] from JSON.
  factory AdminApiKeyActions.fromJson(Map<String, dynamic> json) {
    return AdminApiKeyActions(
      delete: json['delete'] == null
          ? null
          : AdminApiKeyAction.fromJson(json['delete'] as Map<String, dynamic>),
      rotate: json['rotate'] == null
          ? null
          : AdminApiKeyAction.fromJson(json['rotate'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (delete != null) 'delete': delete!.toJson(),
    if (rotate != null) 'rotate': rotate!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminApiKeyActions copyWith({
    Object? delete = unsetCopyWithValue,
    Object? rotate = unsetCopyWithValue,
  }) => AdminApiKeyActions(
    delete: delete == unsetCopyWithValue
        ? this.delete
        : delete as AdminApiKeyAction?,
    rotate: rotate == unsetCopyWithValue
        ? this.rotate
        : rotate as AdminApiKeyAction?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminApiKeyActions &&
          runtimeType == other.runtimeType &&
          delete == other.delete &&
          rotate == other.rotate;

  @override
  int get hashCode => Object.hashAll([delete, rotate]);

  @override
  String toString() =>
      'AdminApiKeyActions('
      'delete: $delete, '
      'rotate: $rotate)';
}

/// Values for AdminApiKeyProduct.
enum AdminApiKeyProduct {
  /// Represents API.
  api('API'),

  /// Represents Mistral Code.
  mistralCode('Mistral Code'),

  /// Represents Vibe.
  vibe('Vibe'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminApiKeyProduct(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminApiKeyProduct fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for AdminApiKeyUnavailableReason.
enum AdminApiKeyUnavailableReason {
  /// Represents unsupported_scope.
  unsupportedScope('unsupported_scope'),

  /// Represents key_expired.
  keyExpired('key_expired'),

  /// Represents not_allowed.
  notAllowed('not_allowed'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminApiKeyUnavailableReason(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminApiKeyUnavailableReason fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Whether a caller can take an action on an API key.
///
/// Unknown statuses retain their original payload for forward compatibility.
@immutable
sealed class AdminApiKeyAction {
  const AdminApiKeyAction();

  /// Parses the action status and optional unavailability reason.
  factory AdminApiKeyAction.fromJson(Map<String, dynamic> json) =>
      switch (json['status']) {
        'available' => const AdminApiKeyActionAvailable(),
        'unavailable' => AdminApiKeyActionUnavailable(
          reason: json['reason'] as String?,
        ),
        _ => UnknownAdminApiKeyAction(json),
      };

  /// Recreates the original wire shape.
  Map<String, dynamic> toJson();
}

/// The action is available to the caller.
final class AdminApiKeyActionAvailable extends AdminApiKeyAction {
  /// Creates an available status.
  const AdminApiKeyActionAvailable();

  @override
  Map<String, dynamic> toJson() => const {'status': 'available'};
}

/// The action is unavailable to the caller.
final class AdminApiKeyActionUnavailable extends AdminApiKeyAction {
  /// Creates an unavailable status with an optional server reason.
  const AdminApiKeyActionUnavailable({this.reason});

  /// The server reason, including any newly added reason code.
  final String? reason;

  /// The recognized reason, if present.
  AdminApiKeyUnavailableReason? get knownReason =>
      reason == null ? null : AdminApiKeyUnavailableReason.fromJson(reason!);

  @override
  Map<String, dynamic> toJson() => {'status': 'unavailable', 'reason': ?reason};

  @override
  bool operator ==(Object other) =>
      other is AdminApiKeyActionUnavailable && reason == other.reason;

  @override
  int get hashCode => Object.hash(runtimeType, reason);
}

/// An action status introduced after this client was released.
final class UnknownAdminApiKeyAction extends AdminApiKeyAction {
  /// Creates a fallback preserving the original wire object.
  UnknownAdminApiKeyAction(Map<String, dynamic> raw)
    : _raw = Map.unmodifiable(raw);

  final Map<String, dynamic> _raw;

  @override
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownAdminApiKeyAction && valuesDeepEqual(_raw, other._raw);

  @override
  int get hashCode => valueDeepHashCode(_raw);
}
