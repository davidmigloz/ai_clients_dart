import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Request to update a collection.
@immutable
class UpdateCollectionRequest {
  /// The new name for the collection.
  final String? newName;

  /// The new metadata for the collection.
  final Map<String, dynamic>? newMetadata;

  /// Creates an update collection request.
  const UpdateCollectionRequest({this.newName, this.newMetadata});

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {'new_name': ?newName, 'new_metadata': ?newMetadata};
  }

  /// Creates a copy with replaced values.
  UpdateCollectionRequest copyWith({
    Object? newName = unsetCopyWithValue,
    Object? newMetadata = unsetCopyWithValue,
  }) {
    return UpdateCollectionRequest(
      newName: newName == unsetCopyWithValue
          ? this.newName
          : newName as String?,
      newMetadata: newMetadata == unsetCopyWithValue
          ? this.newMetadata
          : newMetadata as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCollectionRequest &&
          runtimeType == other.runtimeType &&
          newName == other.newName &&
          mapsEqual(newMetadata, other.newMetadata);

  @override
  int get hashCode => Object.hash(newName, mapHash(newMetadata));

  @override
  String toString() =>
      'UpdateCollectionRequest(newName: $newName, newMetadata: $newMetadata)';
}
