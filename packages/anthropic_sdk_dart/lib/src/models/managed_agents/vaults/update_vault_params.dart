import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a vault.
///
/// Omit a field to preserve its current value.
/// For [metadata], set a key to a string to upsert it, or to null to delete it.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateVaultParams {
  /// Updated human-readable name for the vault. 1-255 characters.
  String? get displayName =>
      _displayName == _notSet ? null : _displayName as String?;
  final Object? _displayName;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omitted keys are preserved.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Creates an [UpdateVaultParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateVaultParams({
    Object? displayName = _notSet,
    Object? metadata = _notSet,
  }) : _displayName = displayName,
       _metadata = metadata;

  /// Creates an [UpdateVaultParams] from JSON.
  factory UpdateVaultParams.fromJson(Map<String, dynamic> json) {
    return UpdateVaultParams(
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
    if (_displayName != _notSet) 'display_name': _displayName,
    if (_metadata != _notSet) 'metadata': _metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([displayName], [metadata]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  UpdateVaultParams copyWith({
    Object? displayName = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateVaultParams(
      displayName: displayName == unsetCopyWithValue
          ? _displayName
          : displayName,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateVaultParams &&
          runtimeType == other.runtimeType &&
          _displayName == other._displayName &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    _displayName,
    _metadata == _notSet ? _notSet : mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateVaultParams('
      'displayName: $displayName, '
      'metadata: $metadata)';
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
