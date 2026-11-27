import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to create a new dataset.
@immutable
class PostDatasetInSchema {
  /// Dataset name (5-50 characters).
  final String name;

  /// Dataset description (max 200 characters).
  final String description;

  /// Additional JSON metadata supplied by the caller.
  final Map<String, dynamic>? metadata;

  /// Creates a [PostDatasetInSchema].
  const PostDatasetInSchema({
    this.metadata,
    required this.name,
    required this.description,
  });

  /// Creates a [PostDatasetInSchema] from JSON.
  factory PostDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PostDatasetInSchema(
        metadata: json['metadata'] as Map<String, dynamic>?,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (metadata != null) 'metadata': metadata,
    'name': name,
    'description': description,
  };

  /// Creates a copy with replaced values.
  PostDatasetInSchema copyWith({
    Object? metadata = unsetCopyWithValue,
    String? name,
    String? description,
  }) => PostDatasetInSchema(
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    name: name ?? this.name,
    description: description ?? this.description,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetInSchema) return false;
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
      'PostDatasetInSchema(metadata: ${metadata?.length}, name: $name, description: $description)';
}
