import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a session.
///
/// Omit a field to preserve its current value.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateSessionParams {
  /// Human-readable session title.
  String? get title => _title == _notSet ? null : _title as String?;
  final Object? _title;

  /// Metadata patch. Set a key to a string to upsert, or to null to delete.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Vault IDs to attach to the session.
  List<String>? get vaultIds =>
      _vaultIds == _notSet ? null : _vaultIds as List<String>?;
  final Object? _vaultIds;

  /// Creates an [UpdateSessionParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateSessionParams({
    Object? title = _notSet,
    Object? metadata = _notSet,
    Object? vaultIds = _notSet,
  }) : _title = title,
       _metadata = metadata,
       _vaultIds = vaultIds;

  /// Creates an [UpdateSessionParams] from JSON.
  factory UpdateSessionParams.fromJson(Map<String, dynamic> json) {
    return UpdateSessionParams(
      title: json.containsKey('title') ? json['title'] as String? : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String?),
            )
          : _notSet,
      vaultIds: json.containsKey('vault_ids')
          ? (json['vault_ids'] as List?)?.map((e) => e as String).toList()
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Fields that were not set (left as default) are omitted.
  /// Fields explicitly set to `null` are included as `null` to clear
  /// the value on the server.
  Map<String, dynamic> toJson() => {
    if (_title != _notSet) 'title': _title,
    if (_metadata != _notSet) 'metadata': _metadata,
    if (_vaultIds != _notSet) 'vault_ids': _vaultIds,
  };

  /// Creates a copy with replaced values.
  UpdateSessionParams copyWith({
    Object? title = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
  }) {
    return UpdateSessionParams(
      title: title == unsetCopyWithValue ? _title : title,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
      vaultIds: vaultIds == unsetCopyWithValue ? _vaultIds : vaultIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSessionParams &&
          runtimeType == other.runtimeType &&
          _title == other._title &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata) &&
          _listsEqualOrBothSentinel(_vaultIds, other._vaultIds);

  @override
  int get hashCode => Object.hash(
    _title,
    _metadata == _notSet ? _notSet : mapHash(metadata),
    _vaultIds == _notSet ? _notSet : listHash(vaultIds),
  );

  @override
  String toString() =>
      'UpdateSessionParams('
      'title: $title, '
      'metadata: $metadata, '
      'vaultIds: $vaultIds)';
}

bool _listsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return listsEqual(a as List?, b as List?);
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
