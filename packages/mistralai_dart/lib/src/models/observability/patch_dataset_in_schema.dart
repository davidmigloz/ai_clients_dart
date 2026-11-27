import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to update an existing dataset.
@immutable
class PatchDatasetInSchema {
  /// Creates a dataset patch.
  ///
  /// Omit a field to leave it out of the request. An explicit null is sent
  /// as a JSON null.
  const PatchDatasetInSchema({
    this._name = unsetCopyWithValue,
    this._description = unsetCopyWithValue,
    this._metadata = unsetCopyWithValue,
  });

  final Object? _name;
  final Object? _description;
  final Object? _metadata;

  /// Updated dataset name.
  String? get name => _name == unsetCopyWithValue ? null : _name as String?;

  /// Updated dataset description.
  String? get description =>
      _description == unsetCopyWithValue ? null : _description as String?;

  /// Additional JSON metadata supplied by the caller.
  Map<String, dynamic>? get metadata => _metadata == unsetCopyWithValue
      ? null
      : (_metadata as Map<Object?, Object?>?)?.cast<String, dynamic>();

  /// Creates a [PatchDatasetInSchema] from JSON.
  factory PatchDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PatchDatasetInSchema(
        name: json.containsKey('name') ? json['name'] : unsetCopyWithValue,
        description: json.containsKey('description')
            ? json['description']
            : unsetCopyWithValue,
        metadata: json.containsKey('metadata')
            ? json['metadata']
            : unsetCopyWithValue,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (_metadata != unsetCopyWithValue) 'metadata': metadata,
    if (_name != unsetCopyWithValue) 'name': name,
    if (_description != unsetCopyWithValue) 'description': description,
  };

  /// Creates a copy with replaced values.
  PatchDatasetInSchema copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) => PatchDatasetInSchema(
    name: name == unsetCopyWithValue ? _name : name,
    description: description == unsetCopyWithValue ? _description : description,
    metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchDatasetInSchema &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _description == other._description &&
          valuesDeepEqual(_metadata, other._metadata);

  @override
  int get hashCode =>
      Object.hash(_name, _description, valueDeepHashCode(_metadata));

  @override
  String toString() =>
      'PatchDatasetInSchema(name: $name, description: $description, '
      'metadata: ${metadata?.length})';
}
