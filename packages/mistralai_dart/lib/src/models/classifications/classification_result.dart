import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../moderations/category_scores.dart';
import 'classification_target_result.dart';

/// Classifier scores keyed by each target configured on that model.
@immutable
class ClassificationResult {
  /// Flag values for a legacy moderation-shaped result.
  final Map<String, bool> categories;

  /// Scores for a legacy moderation-shaped result.
  final CategoryScores categoryScores;

  /// Scores grouped by the configured classifier target names.
  final Map<String, ClassificationTargetResult> targets;

  final bool _legacy;

  /// Creates a legacy moderation-shaped result.
  const ClassificationResult({
    required this.categories,
    required this.categoryScores,
  }) : targets = const {},
       _legacy = true;

  /// Creates a result using the classifier's target names and label scores.
  const ClassificationResult.targets(this.targets)
    : categories = const {},
      categoryScores = const CategoryScores.empty(),
      _legacy = false;

  /// Decodes the classifier result and still accepts stored legacy results.
  factory ClassificationResult.fromJson(Map<String, dynamic> json) {
    final flags = json['categories'];
    final scores = json['category_scores'];
    if (_isTypedMap<bool>(flags) || _isLegacyScores(scores)) {
      return ClassificationResult(
        categories: flags == null
            ? const {}
            : Map<String, bool>.from(flags as Map<Object?, Object?>),
        categoryScores: CategoryScores.fromJson(
          scores as Map<String, dynamic>? ?? const {},
        ),
      );
    }
    return ClassificationResult.targets({
      for (final entry in json.entries)
        entry.key: ClassificationTargetResult.fromJson(
          entry.value as Map<String, dynamic>,
        ),
    });
  }

  static bool _isTypedMap<T>(Object? value) =>
      value is Map<String, dynamic> &&
      value.values.every((entry) => entry is T);

  static bool _isLegacyScores(Object? value) =>
      value is Map<String, dynamic> &&
      value.values.every((entry) => entry == null || entry is num);

  /// Converts to JSON using the original result representation.
  Map<String, dynamic> toJson() => _legacy
      ? {'categories': categories, 'category_scores': categoryScores.toJson()}
      : targets.map((name, target) => MapEntry(name, target.toJson()));

  /// Creates a copy with replaced classifier targets.
  ClassificationResult copyWith({
    Map<String, ClassificationTargetResult>? targets,
  }) => targets == null ? this : ClassificationResult.targets(targets);

  /// Returns whether any category was flagged in a legacy result.
  bool get flagged => categories.values.any((value) => value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationResult &&
          _legacy == other._legacy &&
          mapsEqual(categories, other.categories) &&
          categoryScores == other.categoryScores &&
          mapsEqual(targets, other.targets);

  @override
  int get hashCode => Object.hash(
    _legacy,
    mapHash(categories),
    categoryScores,
    mapHash(targets),
  );

  @override
  String toString() =>
      'ClassificationResult(targets: ${targets.keys}, '
      'flagged: $flagged, categories: ${categories.keys}, categoryScores: $categoryScores)';
}
