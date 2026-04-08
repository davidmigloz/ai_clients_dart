import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'credential_auth.dart';

/// A credential stored in a vault.
///
/// Sensitive fields are never returned in responses.
@immutable
class Credential {
  /// Unique identifier for the credential.
  final String id;

  /// Object type. Always "vault_credential".
  final String type;

  /// Identifier of the vault this credential belongs to.
  final String vaultId;

  /// Human-readable name for the credential.
  final String? displayName;

  /// Authentication configuration for this credential.
  final CredentialAuth auth;

  /// Arbitrary key-value metadata attached to the credential.
  final Map<String, String> metadata;

  /// ISO 8601 timestamp of when the credential was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the credential was last updated.
  final DateTime updatedAt;

  /// When the credential was archived. Null if not archived.
  final DateTime? archivedAt;

  /// Creates a [Credential].
  const Credential({
    required this.id,
    this.type = 'vault_credential',
    required this.vaultId,
    this.displayName,
    required this.auth,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  /// Creates a [Credential] from JSON.
  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'vault_credential',
      vaultId: json['vault_id'] as String,
      displayName: json['display_name'] as String?,
      auth: CredentialAuth.fromJson(json['auth'] as Map<String, dynamic>),
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'vault_id': vaultId,
    if (displayName != null) 'display_name': displayName,
    'auth': auth.toJson(),
    'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([displayName], [archivedAt]), pass the sentinel
  /// value [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  Credential copyWith({
    String? id,
    String? type,
    String? vaultId,
    Object? displayName = unsetCopyWithValue,
    CredentialAuth? auth,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return Credential(
      id: id ?? this.id,
      type: type ?? this.type,
      vaultId: vaultId ?? this.vaultId,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      auth: auth ?? this.auth,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Credential &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          vaultId == other.vaultId &&
          displayName == other.displayName &&
          auth == other.auth &&
          mapsEqual(metadata, other.metadata) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    vaultId,
    displayName,
    auth,
    mapHash(metadata),
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'Credential('
      'id: $id, '
      'type: $type, '
      'vaultId: $vaultId, '
      'displayName: $displayName, '
      'auth: $auth, '
      'metadata: $metadata, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}

/// Confirmation of a deleted credential.
@immutable
class DeletedCredential {
  /// Unique identifier of the deleted credential.
  final String id;

  /// Object type. Always "vault_credential_deleted".
  final String type;

  /// Creates a [DeletedCredential].
  const DeletedCredential({
    required this.id,
    this.type = 'vault_credential_deleted',
  });

  /// Creates a [DeletedCredential] from JSON.
  factory DeletedCredential.fromJson(Map<String, dynamic> json) {
    return DeletedCredential(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'vault_credential_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedCredential copyWith({String? id, String? type}) {
    return DeletedCredential(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedCredential &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedCredential(id: $id, type: $type)';
}
