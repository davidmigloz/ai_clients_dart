import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile_access_type.dart';
import 'user_profile_external_user_details.dart';

/// Request to create a generally available user profile.
@immutable
class CreateCurrentUserProfileRequest {
  /// Name supplied by the platform, if available.
  final String? name;

  /// How the platform uses the API for this entity.
  ///
  /// Omit to use the server's application default.
  final UserProfileAccessType? accessType;

  /// Details the platform supplies about the end customer.
  final UserProfileExternalUserDetails? externalUserDetails;

  /// Free-form metadata. New values must be nonempty strings.
  final Map<String, String>? metadata;

  /// Creates a [CreateCurrentUserProfileRequest].
  const CreateCurrentUserProfileRequest({
    this.name,
    this.accessType,
    this.externalUserDetails,
    this.metadata,
  });

  /// Parses a create request.
  factory CreateCurrentUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      CreateCurrentUserProfileRequest(
        name: json['name'] as String?,
        accessType: json.containsKey('access_type')
            ? _parseAccessType(json['access_type'])
            : null,
        externalUserDetails: _parseExternalDetails(json),
        metadata: _parseMetadata(json),
      );

  /// Converts to the create request body.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (accessType != null) 'access_type': _writeAccessType(accessType),
    if (externalUserDetails != null)
      'external_user_details': externalUserDetails!.toRequestJson(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  CreateCurrentUserProfileRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? accessType = unsetCopyWithValue,
    Object? externalUserDetails = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => CreateCurrentUserProfileRequest(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    accessType: accessType == unsetCopyWithValue
        ? this.accessType
        : accessType as UserProfileAccessType?,
    externalUserDetails: externalUserDetails == unsetCopyWithValue
        ? this.externalUserDetails
        : externalUserDetails as UserProfileExternalUserDetails?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : copyWithMap<String, String>(metadata),
  );

  @override
  bool operator ==(Object other) =>
      other is CreateCurrentUserProfileRequest &&
      name == other.name &&
      accessType == other.accessType &&
      externalUserDetails == other.externalUserDetails &&
      mapsEqual(metadata, other.metadata);

  @override
  int get hashCode =>
      Object.hash(name, accessType, externalUserDetails, mapHash(metadata));

  @override
  String toString() =>
      'CreateCurrentUserProfileRequest(accessType: $accessType, '
      'metadataKeys: ${metadata?.length})';
}

/// Request to update a generally available user profile.
///
/// Omit a field to leave it unchanged. Explicit null is supported for [name]
/// and [accessType]. Individual external user details can be replaced once
/// known. Omit their fields to keep existing values.
@immutable
class UpdateCurrentUserProfileRequest {
  final Object? _name;
  final Object? _accessType;

  /// The updated name, or null if omitted or cleared.
  String? get name => hasName ? _name as String? : null;

  /// Whether a name update was supplied.
  bool get hasName => _name != unsetCopyWithValue;

  /// The updated access type, or null if omitted or cleared.
  UserProfileAccessType? get accessType =>
      hasAccessType ? _accessType as UserProfileAccessType? : null;

  /// Whether an access type update was supplied.
  bool get hasAccessType => _accessType != unsetCopyWithValue;

  /// External details to update. Omitted keys are preserved.
  final UserProfileExternalUserDetails? externalUserDetails;

  /// Metadata keys to set. Send an empty string to delete a key.
  final Map<String, String>? metadata;

  /// Creates an update. Omit [name] or [accessType] to leave it unchanged.
  const UpdateCurrentUserProfileRequest({
    this._name = unsetCopyWithValue,
    this._accessType = unsetCopyWithValue,
    this.externalUserDetails,
    this.metadata,
  });

  /// Parses an update request.
  factory UpdateCurrentUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      UpdateCurrentUserProfileRequest(
        name: json.containsKey('name')
            ? json['name'] as String?
            : unsetCopyWithValue,
        accessType: json.containsKey('access_type')
            ? json['access_type'] == null
                  ? null
                  : _parseAccessType(json['access_type'])
            : unsetCopyWithValue,
        externalUserDetails: _parseExternalDetails(json, updating: true),
        metadata: _parseMetadata(json),
      );

  /// Converts to the update request body.
  Map<String, dynamic> toJson() => {
    if (hasName) 'name': name,
    if (hasAccessType) 'access_type': _writeAccessType(accessType),
    if (externalUserDetails != null)
      'external_user_details': externalUserDetails!.toRequestJson(),
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// Setting [name] or [accessType] to null explicitly sends a null update.
  /// Construct a fresh request to omit an update that was previously present.
  UpdateCurrentUserProfileRequest copyWith({
    Object? name = unsetCopyWithValue,
    Object? accessType = unsetCopyWithValue,
    Object? externalUserDetails = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => UpdateCurrentUserProfileRequest(
    name: name == unsetCopyWithValue ? _name : name,
    accessType: accessType == unsetCopyWithValue ? _accessType : accessType,
    externalUserDetails: externalUserDetails == unsetCopyWithValue
        ? this.externalUserDetails
        : externalUserDetails as UserProfileExternalUserDetails?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : copyWithMap<String, String>(metadata),
  );

  @override
  bool operator ==(Object other) =>
      other is UpdateCurrentUserProfileRequest &&
      _name == other._name &&
      _accessType == other._accessType &&
      externalUserDetails == other.externalUserDetails &&
      mapsEqual(metadata, other.metadata);

  @override
  int get hashCode =>
      Object.hash(_name, _accessType, externalUserDetails, mapHash(metadata));

  @override
  String toString() =>
      'UpdateCurrentUserProfileRequest(hasName: $hasName, '
      'hasAccessType: $hasAccessType, metadataKeys: ${metadata?.length})';
}

UserProfileAccessType _parseAccessType(Object? value) {
  return switch (value) {
    'application' => UserProfileAccessType.application,
    'passthrough' => UserProfileAccessType.passthrough,
    _ => throw const FormatException(
      'Invalid access_type for a user profile write',
    ),
  };
}

String? _writeAccessType(UserProfileAccessType? value) {
  if (value == UserProfileAccessType.unknown) {
    throw ArgumentError('User profile writes require a known access type');
  }
  return value?.value;
}

UserProfileExternalUserDetails? _parseExternalDetails(
  Map<String, dynamic> json, {
  bool updating = false,
}) {
  if (!json.containsKey('external_user_details')) return null;
  final value = json['external_user_details'];
  if (value is! Map<String, dynamic>) {
    throw const FormatException('external_user_details must be a JSON object');
  }
  return UserProfileExternalUserDetails.fromRequestJson(
    value,
    updating: updating,
  );
}

Map<String, String>? _parseMetadata(Map<String, dynamic> json) {
  if (!json.containsKey('metadata')) return null;
  final value = json['metadata'];
  if (value is! Map<String, dynamic>) {
    throw const FormatException('metadata must be a JSON object');
  }
  return Map<String, String>.unmodifiable(value.cast<String, String>());
}
