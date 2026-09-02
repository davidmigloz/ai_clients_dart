import 'package:meta/meta.dart';

import '../beta_timestamp.dart';
import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile_access_type.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a user profile.
///
/// Omit a field to leave its stored value unchanged. Pass `null` explicitly
/// to clear a nullable field.
///
/// For [metadata], keys you pass overwrite existing values; set a key's
/// value to an empty string to remove it from the stored metadata. Keys
/// you don't include are preserved.
@immutable
class UpdateUserProfileRequest {
  /// Updated external identifier, or `null` to clear it.
  ///
  /// Returns `null` both when omitted and when explicitly set to `null`.
  /// Use [hasExternalId] to disambiguate if needed.
  String? get externalId =>
      _externalId == _notSet ? null : _externalId as String?;

  /// Whether an external id update was provided (set to a value or to null).
  bool get hasExternalId => _externalId != _notSet;
  final Object? _externalId;

  /// Updated display name, or `null` to clear it.
  ///
  /// Returns `null` both when omitted and when explicitly set to `null`.
  /// Use [hasName] to disambiguate if needed.
  String? get name => _name == _notSet ? null : _name as String?;

  /// Whether a name update was provided (set to a value or to null).
  bool get hasName => _name != _notSet;
  final Object? _name;

  /// Updated access type, or `null` to clear it.
  ///
  /// Returns `null` both when omitted and when explicitly set to `null`.
  /// Use [hasAccessType] to disambiguate if needed.
  UserProfileAccessType? get accessType =>
      _accessType == _notSet ? null : _accessType as UserProfileAccessType?;

  /// Whether an access type update was provided.
  bool get hasAccessType => _accessType != _notSet;
  final Object? _accessType;

  /// Updated account-creation time.
  ///
  /// Once set, this value cannot be cleared: the API rejects an explicit
  /// `null`, so this field only supports being left unset or set to a
  /// timestamp. Returns `null` when omitted. Use
  /// [hasExternalUserOnboardedAt] to disambiguate.
  BetaTimestamp? get externalUserOnboardedAt =>
      _externalUserOnboardedAt == _notSet
      ? null
      : _externalUserOnboardedAt as BetaTimestamp?;

  /// Whether an account-creation-time update was provided.
  bool get hasExternalUserOnboardedAt => _externalUserOnboardedAt != _notSet;
  final Object? _externalUserOnboardedAt;

  /// Metadata patch: keys to upsert into the stored metadata.
  ///
  /// Set a key's value to the empty string to delete it server-side.
  /// Keys not included are preserved.
  Map<String, String>? get metadata =>
      _metadata == _notSet ? null : (_metadata as Map?)?.cast<String, String>();

  /// Whether a metadata update was provided.
  bool get hasMetadata => _metadata != _notSet;
  final Object? _metadata;

  /// Creates an [UpdateUserProfileRequest].
  ///
  /// Omit a field to leave its stored value unchanged. Pass `null`
  /// explicitly for [externalId], [name], or [accessType] to clear them.
  /// [externalUserOnboardedAt] cannot be cleared once set — the API rejects
  /// an explicit `null` for it — so only omit it or pass a timestamp.
  /// [metadata] is not nullable per the spec — to delete a stored key,
  /// include it in [metadata] with an empty-string value; to leave metadata
  /// entirely unchanged, omit the parameter.
  const UpdateUserProfileRequest({
    Object? externalId = _notSet,
    Object? name = _notSet,
    Object? accessType = _notSet,
    Object? externalUserOnboardedAt = _notSet,
    Object? metadata = _notSet,
  }) : assert(
         metadata == _notSet || metadata is Map<String, String>,
         'metadata must be a Map<String, String> when provided; use empty-string values to remove keys, or omit the metadata parameter to leave it unchanged',
       ),
       assert(
         externalUserOnboardedAt == _notSet ||
             externalUserOnboardedAt is DateTime,
         'externalUserOnboardedAt cannot be cleared with null once set; omit '
         'it to leave it unchanged, or pass a DateTime',
       ),
       _externalId = externalId,
       _name = name,
       _accessType = accessType,
       _externalUserOnboardedAt = externalUserOnboardedAt,
       _metadata = metadata;

  /// Creates an [UpdateUserProfileRequest] from JSON.
  factory UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserProfileRequest(
      externalId: json.containsKey('external_id')
          ? json['external_id'] as String?
          : _notSet,
      name: json.containsKey('name') ? json['name'] as String? : _notSet,
      accessType: json.containsKey('access_type')
          ? (json['access_type'] != null
                ? UserProfileAccessType.fromJson(json['access_type'] as String)
                : null)
          : _notSet,
      externalUserOnboardedAt: json.containsKey('external_user_onboarded_at')
          ? (json['external_user_onboarded_at'] != null
                ? DateTime.parse(json['external_user_onboarded_at'] as String)
                : throw const FormatException(
                    'UpdateUserProfileRequest: '
                    '"external_user_onboarded_at" cannot be null',
                  ))
          : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String),
            )
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Fields that were not set (left as default) are omitted. Fields
  /// explicitly set to `null` are included as `null` to clear the value
  /// on the server.
  Map<String, dynamic> toJson() => {
    if (_externalId != _notSet) 'external_id': _externalId,
    if (_name != _notSet) 'name': _name,
    if (_accessType != _notSet)
      'access_type': (_accessType as UserProfileAccessType?)?.toJson(),
    if (_externalUserOnboardedAt != _notSet)
      'external_user_onboarded_at': (_externalUserOnboardedAt as DateTime?)
          ?.toUtc()
          .toIso8601String(),
    if (_metadata != _notSet) 'metadata': _metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass the sentinel value [unsetCopyWithValue] (or omit) to keep the
  /// original value, or pass `null` explicitly to set the field to null.
  UpdateUserProfileRequest copyWith({
    Object? externalId = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? accessType = unsetCopyWithValue,
    Object? externalUserOnboardedAt = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateUserProfileRequest(
      externalId: externalId == unsetCopyWithValue ? _externalId : externalId,
      name: name == unsetCopyWithValue ? _name : name,
      accessType: accessType == unsetCopyWithValue ? _accessType : accessType,
      externalUserOnboardedAt: externalUserOnboardedAt == unsetCopyWithValue
          ? _externalUserOnboardedAt
          : externalUserOnboardedAt,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserProfileRequest &&
          runtimeType == other.runtimeType &&
          _externalId == other._externalId &&
          _name == other._name &&
          _accessType == other._accessType &&
          _externalUserOnboardedAt == other._externalUserOnboardedAt &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    _externalId,
    _name,
    _accessType,
    _externalUserOnboardedAt,
    _metadata == _notSet ? _notSet : mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateUserProfileRequest('
      'externalId: $externalId, '
      'name: $name, '
      'accessType: $accessType, '
      'externalUserOnboardedAt: $externalUserOnboardedAt, '
      'metadata: $metadata)';
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
