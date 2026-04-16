import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request parameters for creating a user profile.
@immutable
class CreateUserProfileRequest {
  /// Platform's own identifier for this user. Not enforced unique.
  /// Maximum 255 characters.
  final String? externalId;

  /// Free-form key-value metadata to attach to this user profile.
  ///
  /// Maximum 16 keys, keys up to 64 chars, and values must be non-empty
  /// strings up to 512 chars.
  final Map<String, String>? metadata;

  /// Creates a [CreateUserProfileRequest].
  const CreateUserProfileRequest({this.externalId, this.metadata});

  /// Creates a [CreateUserProfileRequest] from JSON.
  factory CreateUserProfileRequest.fromJson(Map<String, dynamic> json) {
    return CreateUserProfileRequest(
      externalId: json['external_id'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (externalId != null) 'external_id': externalId,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([externalId], [metadata]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  CreateUserProfileRequest copyWith({
    Object? externalId = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateUserProfileRequest(
      externalId: externalId == unsetCopyWithValue
          ? this.externalId
          : externalId as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateUserProfileRequest &&
          runtimeType == other.runtimeType &&
          externalId == other.externalId &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(externalId, mapHash(metadata));

  @override
  String toString() =>
      'CreateUserProfileRequest('
      'externalId: $externalId, '
      'metadata: $metadata)';
}
