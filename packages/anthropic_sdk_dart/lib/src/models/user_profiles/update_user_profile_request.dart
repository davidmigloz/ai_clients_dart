import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

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

  /// Metadata patch: keys to upsert into the stored metadata.
  ///
  /// Set a key's value to the empty string to delete it server-side.
  /// Keys not included are preserved.
  Map<String, String>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String>?;

  /// Whether a metadata update was provided.
  bool get hasMetadata => _metadata != _notSet;
  final Object? _metadata;

  /// Creates an [UpdateUserProfileRequest].
  ///
  /// Omit a field to leave its stored value unchanged. Pass `null` explicitly
  /// for [externalId] to clear it. [metadata] is not nullable per the spec —
  /// to delete a stored key, include it in [metadata] with an empty-string
  /// value; to leave metadata entirely unchanged, omit the parameter.
  const UpdateUserProfileRequest({
    Object? externalId = _notSet,
    Object? metadata = _notSet,
  }) : assert(
         metadata == _notSet || metadata is Map<String, String>,
         'metadata must be a Map<String, String> when provided; use empty-string values to remove keys, or omit the metadata parameter to leave it unchanged',
       ),
       _externalId = externalId,
       _metadata = metadata;

  /// Creates an [UpdateUserProfileRequest] from JSON.
  factory UpdateUserProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserProfileRequest(
      externalId: json.containsKey('external_id')
          ? json['external_id'] as String?
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
    if (_metadata != _notSet) 'metadata': _metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass the sentinel value [unsetCopyWithValue] (or omit) to keep the
  /// original value, or pass `null` explicitly to set the field to null.
  UpdateUserProfileRequest copyWith({
    Object? externalId = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateUserProfileRequest(
      externalId: externalId == unsetCopyWithValue ? _externalId : externalId,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserProfileRequest &&
          runtimeType == other.runtimeType &&
          _externalId == other._externalId &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    _externalId,
    _metadata == _notSet ? _notSet : mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateUserProfileRequest('
      'externalId: $externalId, '
      'metadata: $metadata)';
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
