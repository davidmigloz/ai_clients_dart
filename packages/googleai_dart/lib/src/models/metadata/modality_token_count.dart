import 'package:meta/meta.dart';

import '../copy_with_sentinel.dart';

/// Represents token counting info for a single modality.
@immutable
class ModalityTokenCount {
  /// The modality associated with this token count.
  final String? modality;

  /// Number of tokens.
  final int? tokenCount;

  /// Creates a [ModalityTokenCount].
  const ModalityTokenCount({this.modality, this.tokenCount});

  /// Creates a [ModalityTokenCount] from JSON.
  factory ModalityTokenCount.fromJson(Map<String, dynamic> json) =>
      ModalityTokenCount(
        modality: json['modality'] as String?,
        tokenCount: json['tokenCount'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modality != null) 'modality': modality,
    if (tokenCount != null) 'tokenCount': tokenCount,
  };

  /// Creates a copy with replaced values.
  ModalityTokenCount copyWith({
    Object? modality = unsetCopyWithValue,
    Object? tokenCount = unsetCopyWithValue,
  }) {
    return ModalityTokenCount(
      modality: modality == unsetCopyWithValue
          ? this.modality
          : modality as String?,
      tokenCount: tokenCount == unsetCopyWithValue
          ? this.tokenCount
          : tokenCount as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModalityTokenCount &&
        other.modality == modality &&
        other.tokenCount == tokenCount;
  }

  @override
  int get hashCode => Object.hash(modality, tokenCount);

  @override
  String toString() =>
      'ModalityTokenCount(modality: $modality, tokenCount: $tokenCount)';
}
