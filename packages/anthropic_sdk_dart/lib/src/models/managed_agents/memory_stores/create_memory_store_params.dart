import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Request parameters for creating a [MemoryStore].
@immutable
class CreateMemoryStoreParams {
  /// Display name for the new memory store. Required, 1–255 characters.
  final String name;

  /// Optional description, up to 1024 characters.
  final String? description;

  /// Custom metadata. Limited to 16 keys (≤64 chars), values up to 512 chars.
  final Map<String, String>? metadata;

  /// Creates a [CreateMemoryStoreParams].
  CreateMemoryStoreParams({
    required this.name,
    this.description,
    Map<String, String>? metadata,
  }) : metadata = metadata != null ? Map.unmodifiable(metadata) : null;

  /// Creates a [CreateMemoryStoreParams] from JSON.
  factory CreateMemoryStoreParams.fromJson(Map<String, dynamic> json) {
    return CreateMemoryStoreParams(
      name: json['name'] as String,
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  CreateMemoryStoreParams copyWith({
    String? name,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateMemoryStoreParams(
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateMemoryStoreParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(name, description, mapHash(metadata));

  @override
  String toString() =>
      'CreateMemoryStoreParams('
      'name: $name, '
      'description: $description, '
      'metadata: ${metadata?.length ?? 0} entries)';
}
