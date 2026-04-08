import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Request parameters for creating a vault.
@immutable
class CreateVaultParams {
  /// Human-readable name for the vault. 1-255 characters.
  final String displayName;

  /// Arbitrary key-value metadata to attach to the vault.
  final Map<String, String>? metadata;

  /// Creates a [CreateVaultParams].
  const CreateVaultParams({required this.displayName, this.metadata});

  /// Creates a [CreateVaultParams] from JSON.
  factory CreateVaultParams.fromJson(Map<String, dynamic> json) {
    return CreateVaultParams(
      displayName: json['display_name'] as String,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  CreateVaultParams copyWith({
    String? displayName,
    Object? metadata = unsetCopyWithValue,
  }) {
    return CreateVaultParams(
      displayName: displayName ?? this.displayName,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVaultParams &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(displayName, mapHash(metadata));

  @override
  String toString() =>
      'CreateVaultParams(displayName: $displayName, metadata: $metadata)';
}
