import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request to update an existing dataset.
@immutable
class PatchDatasetInSchema {
  /// Creates a dataset patch.
  ///
  /// Null fields are omitted unless their corresponding send-null flag is set.
  const PatchDatasetInSchema({
    this.name,
    this.description,
    this.metadata,
    this.sendNullName = false,
    this.sendNullDescription = false,
    this.sendNullMetadata = false,
  });

  /// Updated dataset name.
  final String? name;

  /// Updated dataset description.
  final String? description;

  /// Additional JSON metadata supplied by the caller.
  final Map<String, dynamic>? metadata;

  /// Sends the name field when its value is null.
  final bool sendNullName;

  /// Sends the description field when its value is null.
  final bool sendNullDescription;

  /// Sends the metadata field when its value is null.
  final bool sendNullMetadata;

  /// Creates a [PatchDatasetInSchema] from JSON, preserving explicit nulls.
  factory PatchDatasetInSchema.fromJson(Map<String, dynamic> json) =>
      PatchDatasetInSchema(
        name: json['name'] as String?,
        description: json['description'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        sendNullName: json.containsKey('name') && json['name'] == null,
        sendNullDescription:
            json.containsKey('description') && json['description'] == null,
        sendNullMetadata:
            json.containsKey('metadata') && json['metadata'] == null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null || sendNullName) 'name': name,
    if (description != null || sendNullDescription) 'description': description,
    if (metadata != null || sendNullMetadata) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  PatchDatasetInSchema copyWith({
    Object? name = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    bool? sendNullName,
    bool? sendNullDescription,
    bool? sendNullMetadata,
  }) => PatchDatasetInSchema(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    sendNullName: sendNullName ?? this.sendNullName,
    sendNullDescription: sendNullDescription ?? this.sendNullDescription,
    sendNullMetadata: sendNullMetadata ?? this.sendNullMetadata,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchDatasetInSchema &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsDeepEqual(metadata, other.metadata) &&
          sendNullName == other.sendNullName &&
          sendNullDescription == other.sendNullDescription &&
          sendNullMetadata == other.sendNullMetadata;

  @override
  int get hashCode => Object.hash(
    name,
    description,
    mapDeepHashCode(metadata),
    sendNullName,
    sendNullDescription,
    sendNullMetadata,
  );

  @override
  String toString() =>
      'PatchDatasetInSchema(name: $name, description: $description, '
      'metadata: ${metadata?.length}, sendNullName: $sendNullName, '
      'sendNullDescription: $sendNullDescription, sendNullMetadata: $sendNullMetadata)';
}
