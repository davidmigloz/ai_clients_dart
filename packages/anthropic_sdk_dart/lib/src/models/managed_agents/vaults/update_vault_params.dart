import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Request parameters for updating a vault.
///
/// Omit a field to preserve its current value.
/// For [metadata], set a key to a string to upsert it, or to null to delete it.
@immutable
class UpdateVaultParams {
  /// Updated human-readable name for the vault. 1-255 characters.
  final String? displayName;

  /// Metadata patch. Set a key to a string to upsert it, or to null to
  /// delete it. Omitted keys are preserved.
  final Map<String, String?>? metadata;

  /// Creates an [UpdateVaultParams].
  const UpdateVaultParams({this.displayName, this.metadata});

  /// Creates an [UpdateVaultParams] from JSON.
  factory UpdateVaultParams.fromJson(Map<String, dynamic> json) {
    return UpdateVaultParams(
      displayName: json['display_name'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String?),
      ),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (displayName != null) 'display_name': displayName,
    if (metadata != null) 'metadata': metadata,
  };

  /// Creates a copy with replaced values.
  ///
  /// For nullable fields ([displayName], [metadata]), pass the sentinel value
  /// [unsetCopyWithValue] (or omit) to keep the original value, or pass
  /// `null` explicitly to set the field to null.
  UpdateVaultParams copyWith({
    Object? displayName = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
  }) {
    return UpdateVaultParams(
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String?>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateVaultParams &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          mapsEqual(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(displayName, mapHash(metadata));

  @override
  String toString() =>
      'UpdateVaultParams('
      'displayName: $displayName, '
      'metadata: $metadata)';
}
