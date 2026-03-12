import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';

/// Response from a delete records operation.
///
/// Contains the count of records that were deleted.
@immutable
class DeleteCollectionRecordsResponse {
  /// The number of records that were deleted.
  final int? deleted;

  /// Creates a delete collection records response.
  const DeleteCollectionRecordsResponse({this.deleted});

  /// Creates a delete collection records response from JSON.
  factory DeleteCollectionRecordsResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCollectionRecordsResponse(deleted: json['deleted'] as int?);
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {'deleted': ?deleted};
  }

  /// Creates a copy with replaced values.
  DeleteCollectionRecordsResponse copyWith({
    Object? deleted = unsetCopyWithValue,
  }) {
    return DeleteCollectionRecordsResponse(
      deleted: deleted == unsetCopyWithValue ? this.deleted : deleted as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteCollectionRecordsResponse &&
          runtimeType == other.runtimeType &&
          deleted == other.deleted;

  @override
  int get hashCode => deleted.hashCode;

  @override
  String toString() => 'DeleteCollectionRecordsResponse(deleted: $deleted)';
}
