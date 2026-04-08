import 'package:meta/meta.dart';

import 'conversation_payload.dart';

/// Request to update a dataset record's payload.
@immutable
class PutDatasetRecordPayloadInSchema {
  /// The new conversation payload.
  final ConversationPayload payload;

  /// Creates a [PutDatasetRecordPayloadInSchema].
  const PutDatasetRecordPayloadInSchema({required this.payload});

  /// Creates a [PutDatasetRecordPayloadInSchema] from JSON.
  factory PutDatasetRecordPayloadInSchema.fromJson(Map<String, dynamic> json) =>
      PutDatasetRecordPayloadInSchema(
        payload: ConversationPayload.fromJson(
          json['payload'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'payload': payload.toJson()};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PutDatasetRecordPayloadInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return payload == other.payload;
  }

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'PutDatasetRecordPayloadInSchema(payload: $payload)';
}
