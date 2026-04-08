import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// A vault that stores credentials for use by agents during sessions.
@immutable
class Vault {
  /// Unique identifier for the vault.
  final String id;

  /// Object type. Always "vault".
  final String type;

  /// Human-readable name for the vault.
  final String displayName;

  /// Arbitrary key-value metadata attached to the vault.
  final Map<String, String> metadata;

  /// ISO 8601 timestamp of when the vault was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the vault was last updated.
  final DateTime updatedAt;

  /// When the vault was archived. Null if not archived.
  final DateTime? archivedAt;

  /// Creates a [Vault].
  const Vault({
    required this.id,
    this.type = 'vault',
    required this.displayName,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  /// Creates a [Vault] from JSON.
  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'vault',
      displayName: json['display_name'] as String,
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
    'display_name': displayName,
    'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'archived_at': archivedAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([archivedAt]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  Vault copyWith({
    String? id,
    String? type,
    String? displayName,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return Vault(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
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
      other is Vault &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          displayName == other.displayName &&
          mapsEqual(metadata, other.metadata) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    displayName,
    mapHash(metadata),
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'Vault('
      'id: $id, '
      'type: $type, '
      'displayName: $displayName, '
      'metadata: $metadata, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}

/// Confirmation of a deleted vault.
@immutable
class DeletedVault {
  /// Unique identifier of the deleted vault.
  final String id;

  /// Object type. Always "vault_deleted".
  final String type;

  /// Creates a [DeletedVault].
  const DeletedVault({required this.id, this.type = 'vault_deleted'});

  /// Creates a [DeletedVault] from JSON.
  factory DeletedVault.fromJson(Map<String, dynamic> json) {
    return DeletedVault(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'vault_deleted',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  DeletedVault copyWith({String? id, String? type}) {
    return DeletedVault(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedVault &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'DeletedVault(id: $id, type: $type)';
}
