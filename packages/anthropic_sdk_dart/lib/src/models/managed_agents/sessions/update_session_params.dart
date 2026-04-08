import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Request parameters for updating a session.
///
/// Omit a field to preserve its current value.
@immutable
class UpdateSessionParams {
  /// Human-readable session title.
  final String? title;

  /// Metadata patch. Set a key to a string to upsert, or to null to delete.
  final Map<String, String?>? metadata;

  /// Vault IDs to attach to the session.
  final List<String>? vaultIds;

  /// Creates an [UpdateSessionParams].
  const UpdateSessionParams({this.title, this.metadata, this.vaultIds});

  /// Creates an [UpdateSessionParams] from JSON.
  factory UpdateSessionParams.fromJson(Map<String, dynamic> json) {
    return UpdateSessionParams(
      title: json['title'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String?),
      ),
      vaultIds: (json['vault_ids'] as List?)?.map((e) => e as String).toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (metadata != null) 'metadata': metadata,
    if (vaultIds != null) 'vault_ids': vaultIds,
  };

  /// Creates a copy with replaced values.
  UpdateSessionParams copyWith({
    Object? title = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
  }) {
    return UpdateSessionParams(
      title: title == unsetCopyWithValue ? this.title : title as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String?>?,
      vaultIds: vaultIds == unsetCopyWithValue
          ? this.vaultIds
          : vaultIds as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSessionParams &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          mapsEqual(metadata, other.metadata) &&
          listsEqual(vaultIds, other.vaultIds);

  @override
  int get hashCode => Object.hash(title, mapHash(metadata), listHash(vaultIds));

  @override
  String toString() =>
      'UpdateSessionParams('
      'title: $title, '
      'metadata: $metadata, '
      'vaultIds: $vaultIds)';
}
