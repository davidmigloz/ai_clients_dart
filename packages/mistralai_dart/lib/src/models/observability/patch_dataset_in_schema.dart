import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to update an existing dataset.
@immutable
class PatchDatasetInSchema {
  /// Updated dataset name.
  final String? name;

  /// Updated dataset description.
  final String? description;

  /// Creates a [PatchDatasetInSchema].
  const PatchDatasetInSchema({this.name, this.description});

  /// Creates a [PatchDatasetInSchema] from JSON.
  factory PatchDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PatchDatasetInSchema(
        name: json['name'] as String?,
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
  };

  /// Creates a copy with replaced values.
  PatchDatasetInSchema copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
  }) {
    return PatchDatasetInSchema(
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
    return name == other.name && description == other.description;
  }

  @override
  int get hashCode => Object.hash(name, description);

  @override
  String toString() =>
      'PatchDatasetInSchema(name: $name, description: $description)';
}
