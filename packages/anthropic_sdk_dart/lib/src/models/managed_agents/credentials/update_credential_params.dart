import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'credential_auth.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a credential.
///
/// Omit a field to preserve its current value.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateCredentialParams {
  /// Updated authentication configuration.
  ///
  /// The `type` is immutable; the variant sent must match the stored
  /// credential's type.
  CredentialUpdateAuth? get auth =>
      _auth == _notSet ? null : _auth as CredentialUpdateAuth?;
  final Object? _auth;

  /// Updated human-readable name for the credential. 1-255 characters.
  String? get displayName =>
      _displayName == _notSet ? null : _displayName as String?;
  final Object? _displayName;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omitted keys are preserved.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Creates an [UpdateCredentialParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateCredentialParams({
    Object? auth = _notSet,
    Object? displayName = _notSet,
    Object? metadata = _notSet,
  }) : _auth = auth,
       _displayName = displayName,
       _metadata = metadata;

  /// Creates an [UpdateCredentialParams] from JSON.
  factory UpdateCredentialParams.fromJson(Map<String, dynamic> json) {
    return UpdateCredentialParams(
      auth: json.containsKey('auth')
          ? json['auth'] != null
                ? CredentialUpdateAuth.fromJson(
                    json['auth'] as Map<String, dynamic>,
                  )
                : null
          : _notSet,
      displayName: json.containsKey('display_name')
          ? json['display_name'] as String?
          : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String?),
            )
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Fields that were not set (left as default) are omitted.
  /// Fields explicitly set to `null` are included as `null` to clear
  /// the value on the server.
  Map<String, dynamic> toJson() => {
    if (_auth != _notSet) 'auth': (_auth as CredentialUpdateAuth?)?.toJson(),
    if (_displayName != _notSet) 'display_name': _displayName,
    if (_metadata != _notSet) 'metadata': _metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([auth], [displayName], [metadata]), pass the sentinel
  /// value [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  UpdateCredentialParams copyWith({
    Object? auth = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateCredentialParams(
      auth: auth == unsetCopyWithValue ? _auth : auth,
      displayName: displayName == unsetCopyWithValue
          ? _displayName
          : displayName,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCredentialParams &&
          runtimeType == other.runtimeType &&
          _auth == other._auth &&
          _displayName == other._displayName &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    _auth,
    _displayName,
    _metadata == _notSet ? _notSet : mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateCredentialParams('
      'auth: $auth, '
      'displayName: $displayName, '
      'metadata: $metadata)';
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
