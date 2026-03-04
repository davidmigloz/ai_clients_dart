import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Request to create a new collection.
@immutable
class CreateCollectionRequest {
  /// The name for the new collection.
  final String name;

  /// Optional metadata for the collection.
  final Map<String, dynamic>? metadata;

  /// If true, get an existing collection with this name instead of
  /// throwing an error if it already exists.
  final bool? getOrCreate;

  /// Creates a create collection request.
  const CreateCollectionRequest({
    required this.name,
    this.metadata,
    this.getOrCreate,
  });

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (metadata != null) 'metadata': metadata,
      if (getOrCreate != null) 'get_or_create': getOrCreate,
    };
  }

  /// Creates a copy with replaced values.
  CreateCollectionRequest copyWith({
    String? name,
    Object? metadata = unsetCopyWithValue,
    Object? getOrCreate = unsetCopyWithValue,
  }) {
    return CreateCollectionRequest(
      name: name ?? this.name,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      getOrCreate: getOrCreate == unsetCopyWithValue
          ? this.getOrCreate
          : getOrCreate as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateCollectionRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mapsEqual(metadata, other.metadata) &&
          getOrCreate == other.getOrCreate;

  @override
  int get hashCode => Object.hash(name, mapHash(metadata), getOrCreate);

  @override
  String toString() =>
      'CreateCollectionRequest(name: $name, metadata: $metadata, '
      'getOrCreate: $getOrCreate)';
}
