import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a [MemoryStore].
///
/// Omit a field to preserve its current value on the server.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateMemoryStoreParams {
  /// New display name. 1–255 characters.
  String? get name => _name == _notSet ? null : _name as String?;
  final Object? _name;

  /// New description. Up to 1024 characters.
  String? get description =>
      _description == _notSet ? null : _description as String?;
  final Object? _description;

  /// Metadata patch. Set a key to a string to upsert it, or to `null` to
  /// delete it. Omit the field to preserve.
  Map<String, String?>? get metadata =>
      _metadata == _notSet ? null : _metadata as Map<String, String?>?;
  final Object? _metadata;

  /// Creates an [UpdateMemoryStoreParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateMemoryStoreParams({
    Object? name = _notSet,
    Object? description = _notSet,
    Object? metadata = _notSet,
  }) : _name = name,
       _description = description,
       _metadata = metadata;

  /// Creates an [UpdateMemoryStoreParams] from JSON.
  factory UpdateMemoryStoreParams.fromJson(Map<String, dynamic> json) {
    return UpdateMemoryStoreParams(
      name: json.containsKey('name') ? json['name'] as String? : _notSet,
      description: json.containsKey('description')
          ? json['description'] as String?
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
  /// Fields that were not set are omitted. Fields explicitly set to `null`
  /// are emitted as `null` to clear the value on the server.
  Map<String, dynamic> toJson() => {
    if (_name != _notSet) 'name': _name,
    if (_description != _notSet) 'description': _description,
    if (_metadata != _notSet) 'metadata': _metadata,
  };

  /// Creates a copy with replaced values.
  UpdateMemoryStoreParams copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateMemoryStoreParams(
      name: name == unsetCopyWithValue ? _name : name,
      description: description == unsetCopyWithValue
          ? _description
          : description,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMemoryStoreParams &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _description == other._description &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata);

  @override
  int get hashCode => Object.hash(
    _name,
    _description,
    _metadata == _notSet ? _notSet : mapHash(metadata),
  );

  @override
  String toString() =>
      'UpdateMemoryStoreParams('
      'name: $name, '
      'description: $description, '
      'metadata: $metadata)';
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
