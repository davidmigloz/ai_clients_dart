import 'package:meta/meta.dart';

import '../moderations/category_scores.dart';

/// Result of a classification check on a piece of content.
@immutable
class ClassificationResult {
  /// Category flags indicating which categories were triggered.
  final Map<String, bool> categories;

  /// Scores for each classification category.
  final CategoryScores categoryScores;

  /// Creates a [ClassificationResult].
  const ClassificationResult({
    required this.categories,
    required this.categoryScores,
  });

  /// Creates a [ClassificationResult] from JSON.
  factory ClassificationResult.fromJson(Map<String, dynamic> json) =>
      ClassificationResult(
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
      other is ClassificationResult &&
          runtimeType == other.runtimeType &&
          categoryScores == other.categoryScores;

  @override
  int get hashCode => Object.hash(categories, categoryScores);

  @override
  String toString() =>
      'ClassificationResult(flagged: $flagged, categories: $categories)';
}
