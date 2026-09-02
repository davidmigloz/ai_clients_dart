import 'package:meta/meta.dart';

import '../beta_timestamp.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile_access_type.dart';

/// Request parameters for creating a user profile.
@immutable
class CreateUserProfileRequest {
  /// Platform's own identifier for this user. Not enforced unique.
  /// Maximum 255 characters.
  final String? externalId;

  /// Real-world name of the entity this profile represents (company or
  /// individual); for a company the platform resells Claude access to
  /// ([UserProfileAccessType.passthrough]), that company's name where known.
  /// Maximum 255 characters.
  final String? name;

  /// How the platform uses the API for this entity.
  ///
  /// `application` (default): the profile represents an individual end-user
  /// of the platform's product. `passthrough`: the profile identifies a
  /// company the platform resells Claude access to.
  final UserProfileAccessType? accessType;

  /// When the entity this profile represents opened its account with the
  /// platform: for an `application` profile, when the end-user signed up;
  /// for a `passthrough` profile, when the company became the platform's
  /// customer. Must be a complete timestamp no more than 1 minute in the
  /// future.
  final BetaTimestamp? externalUserOnboardedAt;

  /// Free-form key-value metadata to attach to this user profile.
  ///
  /// Maximum 16 keys, keys up to 64 chars, and values must be non-empty
  /// strings up to 512 chars.
  final Map<String, String>? metadata;

  /// Creates a [CreateUserProfileRequest].
  const CreateUserProfileRequest({
    this.externalId,
    this.name,
    this.accessType,
    this.externalUserOnboardedAt,
    this.metadata,
  });

  /// Creates a [CreateUserProfileRequest] from JSON.
  factory CreateUserProfileRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserProfileRequest(
      externalId: json['external_id'] as String?,
      name: json['name'] as String?,
      accessType: json['access_type'] != null
          ? UserProfileAccessType.fromJson(json['access_type'] as String)
          : null,
      externalUserOnboardedAt: json['external_user_onboarded_at'] != null
          ? DateTime.parse(json['external_user_onboarded_at'] as String)
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (externalId != null) 'external_id': externalId,
    if (name != null) 'name': name,
    if (accessType != null) 'access_type': accessType!.toJson(),
    if (externalUserOnboardedAt != null)
      'external_user_onboarded_at': externalUserOnboardedAt!
          .toUtc()
          .toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([externalId], [name], [accessType],
  /// [externalUserOnboardedAt], [metadata]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  CreateUserProfileRequest copyWith({
    Object? externalId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? accessType = unsetCopyWithValue,
    Object? externalUserOnboardedAt = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateUserProfileRequest(
      externalId: externalId == unsetCopyWithValue
          ? this.externalId
          : externalId as String?,
      name: name == unsetCopyWithValue ? this.name : name as String?,
      accessType: accessType == unsetCopyWithValue
          ? this.accessType
          : accessType as UserProfileAccessType?,
      externalUserOnboardedAt: externalUserOnboardedAt == unsetCopyWithValue
          ? this.externalUserOnboardedAt
          : externalUserOnboardedAt as BetaTimestamp?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateUserProfileRequest &&
          runtimeType == other.runtimeType &&
          externalId == other.externalId &&
          name == other.name &&
          accessType == other.accessType &&
          externalUserOnboardedAt == other.externalUserOnboardedAt &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
    externalId,
    name,
    accessType,
    externalUserOnboardedAt,
    mapHash(metadata),
  );

  @override
  String toString() =>
      'CreateUserProfileRequest('
      'externalId: $externalId, '
      'name: $name, '
      'accessType: $accessType, '
      'externalUserOnboardedAt: $externalUserOnboardedAt, '
      'metadata: $metadata)';
}
