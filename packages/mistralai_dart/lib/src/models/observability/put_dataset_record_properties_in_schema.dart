import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to update a dataset record's properties.
@immutable
class PutDatasetRecordPropertiesInSchema {
  /// The new properties (free-form).
  final Map<String, dynamic> properties;

  /// Creates a [PutDatasetRecordPropertiesInSchema].
  PutDatasetRecordPropertiesInSchema({required Map<String, dynamic> properties})
    : properties = Map.unmodifiable(properties);

  /// Creates a [PutDatasetRecordPropertiesInSchema] from JSON.
  factory PutDatasetRecordPropertiesInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PutDatasetRecordPropertiesInSchema(
    properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'properties': Map<String, dynamic>.from(properties),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PutDatasetRecordPropertiesInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return mapsDeepEqual(properties, other.properties);
  }

  @override
  int get hashCode => mapDeepHashCode(properties);

  @override
  String toString() => 'PutDatasetRecordPropertiesInSchema(properties: ...)';
}
