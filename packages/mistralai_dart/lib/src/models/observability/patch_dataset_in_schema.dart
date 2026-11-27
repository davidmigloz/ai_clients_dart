import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to update an existing dataset.
@immutable
class PatchDatasetInSchema {
  /// Updated dataset name.
  final String? name;

  /// Updated dataset description.
  final String? description;

  /// Additional JSON metadata supplied by the caller.
  final Map<String, dynamic>? metadata;

  /// Creates a [PatchDatasetInSchema].
  const PatchDatasetInSchema({this.name, this.description, this.metadata});

  /// Creates a [PatchDatasetInSchema] from JSON.
  factory PatchDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PatchDatasetInSchema(
        metadata: json['metadata'] as Map<String, dynamic>?,
        name: json['name'] as String?,
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (metadata != null) 'metadata': metadata,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
  };

  /// Creates a copy with replaced values.
  PatchDatasetInSchema copyWith({
    Object? metadata = unsetCopyWithValue,
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
  }) {
    return PatchDatasetInSchema(
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : (metadata as Map<Object?, Object?>?)?.cast<String, dynamic>(),
      name: name == unsetCopyWithValue ? this.name : name as String?,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PatchDatasetInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return mapsDeepEqual(metadata, other.metadata) &&
        name == other.name &&
        description == other.description;
  }

  @override
  int get hashCode =>
      Object.hashAll([name, description, mapDeepHashCode(metadata)]);

  @override
  String toString() =>
      'PatchDatasetInSchema(metadata: ${metadata?.length}, name: $name, description: $description)';
}
