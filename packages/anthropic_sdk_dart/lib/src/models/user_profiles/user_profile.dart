import 'package:meta/meta.dart';

import '../beta_timestamp.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile_relationship.dart';
import 'user_profile_trust_grant.dart';

/// A user profile representing an end-user of a platform built on Claude.
///
/// User profiles let a platform register end-users with Anthropic, attach
/// metadata and an external ID, and track trust-grant status for feature
/// areas that require per-user enrollment (e.g., `cyber`).
@immutable
class UserProfile {
  /// Unique identifier for this user profile, prefixed `uprof_`.
  final String id;

  /// Object type. Always `user_profile`.
  final String type;

  /// Platform's own identifier for this user. Not enforced unique.
  final String? externalId;

  /// Display name of the entity this profile represents.
  ///
  /// Required when [relationship] is `resold` (the resold-to company's name);
  /// optional otherwise. Maximum 255 characters.
  final String? name;

  /// How the entity relates to the platform.
  ///
  /// `external` (default): an individual end-user. `resold`: a company the
  /// platform resells Claude access to. `internal`: the platform's own usage.
  final BetaUserProfileRelationship relationship;

  /// Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars,
  /// values up to 512 chars. Always present; may be empty.
  final Map<String, String> metadata;

  /// Trust grants for this profile, keyed by grant name (e.g., `cyber`).
  ///
  /// Keys are omitted when no grant is active or in flight for that area.
  final Map<String, UserProfileTrustGrant> trustGrants;

  /// When this user profile was created.
  final BetaTimestamp createdAt;

  /// When this user profile was last updated.
  ///
  /// Bumped when trust grants change or metadata is updated.
  final BetaTimestamp updatedAt;

  /// Creates a [UserProfile].
  const UserProfile({
    required this.id,
    this.type = 'user_profile',
    this.externalId,
    this.name,
    required this.relationship,
    required this.metadata,
    required this.trustGrants,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [UserProfile] from JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final trustGrantsJson = json['trust_grants'] as Map<String, dynamic>?;
    return UserProfile(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'user_profile',
      externalId: json['external_id'] as String?,
      name: json['name'] as String?,
      relationship: BetaUserProfileRelationship.fromJson(
        json['relationship'] as String,
      ),
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          const {},
      trustGrants:
          trustGrantsJson?.map(
            (k, v) => MapEntry(
              k,
              UserProfileTrustGrant.fromJson(v as Map<String, dynamic>),
            ),
          ) ??
          const {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'external_id': externalId,
    'name': name,
    'relationship': relationship.toJson(),
    'metadata': metadata,
    'trust_grants': trustGrants.map((k, v) => MapEntry(k, v.toJson())),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([externalId], [name]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  UserProfile copyWith({
    String? id,
    String? type,
    Object? externalId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    BetaUserProfileRelationship? relationship,
    Map<String, String>? metadata,
    Map<String, UserProfileTrustGrant>? trustGrants,
    BetaTimestamp? createdAt,
    BetaTimestamp? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      type: type ?? this.type,
      externalId: externalId == unsetCopyWithValue
          ? this.externalId
          : externalId as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      relationship: relationship ?? this.relationship,
      metadata: metadata ?? this.metadata,
      trustGrants: trustGrants ?? this.trustGrants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          externalId == other.externalId &&
          name == other.name &&
          relationship == other.relationship &&
          mapsEqual(metadata, other.metadata) &&
          mapsEqual(trustGrants, other.trustGrants) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    externalId,
    name,
    relationship,
    mapHash(metadata),
    mapHash(trustGrants),
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'UserProfile('
      'id: $id, '
      'type: $type, '
      'externalId: $externalId, '
      'name: $name, '
      'relationship: $relationship, '
      'metadata: $metadata, '
      'trustGrants: $trustGrants, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}
