import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Schema representation for collection index configurations.
///
/// This represents the server-side schema structure used for index management.
@immutable
class CollectionSchema {
  /// Default index configurations for each value type.
  final Map<String, dynamic> defaults;

  /// Key-specific index overrides.
  final Map<String, dynamic> keys;

  /// Customer-managed encryption key for collection data.
  final Map<String, dynamic>? cmek;

  /// ID of the attached function that created this output collection.
  final String? sourceAttachedFunctionId;

  /// Creates a collection schema.
  const CollectionSchema({
    required this.defaults,
    required this.keys,
    this.cmek,
    this.sourceAttachedFunctionId,
  });

  /// Creates a collection schema from JSON.
  factory CollectionSchema.fromJson(Map<String, dynamic> json) {
    return CollectionSchema(
      defaults: json['defaults'] as Map<String, dynamic>? ?? {},
      keys: json['keys'] as Map<String, dynamic>? ?? {},
      cmek: json['cmek'] as Map<String, dynamic>?,
      sourceAttachedFunctionId: json['source_attached_function_id'] as String?,
    );
  }

  /// Converts this schema to JSON.
  Map<String, dynamic> toJson() {
    return {
      'defaults': defaults,
      'keys': keys,
      'cmek': ?cmek,
      'source_attached_function_id': ?sourceAttachedFunctionId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionSchema &&
          runtimeType == other.runtimeType &&
          mapsEqual(defaults, other.defaults) &&
          mapsEqual(keys, other.keys) &&
          mapsEqual(cmek, other.cmek) &&
          sourceAttachedFunctionId == other.sourceAttachedFunctionId;

  @override
  int get hashCode => Object.hash(
    mapHash(defaults),
    mapHash(keys),
    mapHash(cmek),
    sourceAttachedFunctionId,
  );

  @override
  String toString() =>
      'CollectionSchema('
      'defaults: $defaults, '
      'keys: $keys, '
      'cmek: ${cmek != null}, '
      'sourceAttachedFunctionId: $sourceAttachedFunctionId)';
}
