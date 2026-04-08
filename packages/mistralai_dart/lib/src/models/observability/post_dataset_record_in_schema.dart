import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'conversation_payload.dart';

/// Request to create a new dataset record.
@immutable
class PostDatasetRecordInSchema {
  /// The conversation payload.
  final ConversationPayload payload;

  /// Additional properties (free-form).
  final Map<String, dynamic> properties;

  /// Creates a [PostDatasetRecordInSchema].
  PostDatasetRecordInSchema({
    required this.payload,
    required Map<String, dynamic> properties,
  }) : properties = Map.unmodifiable(properties);

  /// Creates a [PostDatasetRecordInSchema] from JSON.
  factory PostDatasetRecordInSchema.fromJson(Map<String, dynamic> json) =>
      PostDatasetRecordInSchema(
        payload: ConversationPayload.fromJson(
          json['payload'] as Map<String, dynamic>? ?? {},
        ),
        properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'payload': payload.toJson(),
    'properties': Map<String, dynamic>.from(properties),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetRecordInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return payload == other.payload &&
        mapsDeepEqual(properties, other.properties);
  }

  @override
  int get hashCode => Object.hash(payload, mapDeepHashCode(properties));

  @override
  String toString() => 'PostDatasetRecordInSchema(payload: $payload)';
}
