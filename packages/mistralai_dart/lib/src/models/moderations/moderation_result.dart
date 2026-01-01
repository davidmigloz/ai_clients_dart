import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'category_scores.dart';

/// Result of a moderation check on a piece of content.
@immutable
class ModerationResult {
  /// Category flags indicating which categories were triggered.
  final Map<String, bool> categories;

  /// Scores for each moderation category.
  final CategoryScores categoryScores;

  /// Creates a [ModerationResult].
  const ModerationResult({
    required this.categories,
    required this.categoryScores,
  });

  /// Creates a [ModerationResult] from JSON.
  factory ModerationResult.fromJson(Map<String, dynamic> json) =>
      ModerationResult(
        categories:
            (json['categories'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as bool),
            ) ??
            {},
        categoryScores: CategoryScores.fromJson(
          json['category_scores'] as Map<String, dynamic>? ?? {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'categories': categories,
    'category_scores': categoryScores.toJson(),
  };

  /// Returns true if any category was flagged.
  bool get flagged => categories.values.any((v) => v);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResult &&
          runtimeType == other.runtimeType &&
          mapEquals(categories, other.categories) &&
          categoryScores == other.categoryScores;

  @override
  int get hashCode => Object.hash(categories, categoryScores);

  @override
  String toString() =>
      'ModerationResult(flagged: $flagged, categories: $categories)';
}
