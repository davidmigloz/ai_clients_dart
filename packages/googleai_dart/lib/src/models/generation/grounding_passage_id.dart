import '../copy_with_sentinel.dart';

/// Identifier for a passage within a `GroundingPassage`.
class GroundingPassageId {
  /// Output only. Index of the part within the `GroundingPassage.content`.
  final int? partIndex;

  /// Output only. ID of the passage matching the `GroundingPassage.id`.
  final String? passageId;

  /// Creates a [GroundingPassageId].
  const GroundingPassageId({this.partIndex, this.passageId});

  /// Creates a [GroundingPassageId] from JSON.
  factory GroundingPassageId.fromJson(Map<String, dynamic> json) {
    return GroundingPassageId(
      partIndex: json['partIndex'] as int?,
      passageId: json['passageId'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'partIndex': ?partIndex,
    'passageId': ?passageId,
  };

  /// Creates a copy with replaced values.
  GroundingPassageId copyWith({
    Object? partIndex = unsetCopyWithValue,
    Object? passageId = unsetCopyWithValue,
  }) {
    return GroundingPassageId(
      partIndex: partIndex == unsetCopyWithValue
          ? this.partIndex
          : partIndex as int?,
      passageId: passageId == unsetCopyWithValue
          ? this.passageId
          : passageId as String?,
    );
  }
}
