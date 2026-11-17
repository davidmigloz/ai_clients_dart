import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../common/json_helpers.dart';

/// The moderation classifier's result for one image.
@immutable
final class ImageClassifierResponse {
  /// Creates a response for a classified image.
  const ImageClassifierResponse({
    required this.id,
    required this.model,
    required this.result,
  });

  /// Creates a response from the standalone moderation endpoint's JSON.
  factory ImageClassifierResponse.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    if (results is! List || results.length != 1) {
      throw const FormatException(
        'ImageClassifierResponse.results: expected one result',
      );
    }
    return ImageClassifierResponse(
      id: requireJsonString(json['id'], 'ImageClassifierResponse.id'),
      model: requireJsonString(json['model'], 'ImageClassifierResponse.model'),
      result: ImageClassifierResult.fromJson(
        requireJsonObject(results.single, 'ImageClassifierResponse.results[0]'),
      ),
    );
  }

  /// The moderation request ID.
  final String id;

  /// The model that classified the image.
  final String model;

  /// The classification result for the single input image.
  final ImageClassifierResult result;

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'results': [result.toJson()],
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageClassifierResponse &&
          id == other.id &&
          model == other.model &&
          result == other.result;

  @override
  int get hashCode => Object.hash(id, model, result);
}

/// The category flags, scores, and applied inputs for a classified image.
///
/// The documented category keys are `likely-csam` and `likely-csam/gen-ai`.
/// The maps preserve additional keys from the service. A lookup for an absent
/// key returns null.
@immutable
final class ImageClassifierResult {
  /// Creates a result with immutable copies of its category maps.
  ImageClassifierResult({
    required this.flagged,
    required Map<String, bool> categories,
    required Map<String, double> categoryScores,
    required Map<String, List<String>> categoryAppliedInputTypes,
  }) : categories = Map.unmodifiable(categories),
       categoryScores = Map.unmodifiable(categoryScores),
       categoryAppliedInputTypes = Map.unmodifiable({
         for (final entry in categoryAppliedInputTypes.entries)
           entry.key: List<String>.unmodifiable(entry.value),
       });

  /// Creates a classifier result from JSON.
  factory ImageClassifierResult.fromJson(Map<String, dynamic> json) =>
      ImageClassifierResult(
        flagged: _readFlag(json['flagged'], 'flagged'),
        categories: _readCategories(json, 'categories', _readFlag),
        categoryScores: _readCategories(json, 'category_scores', _readScore),
        categoryAppliedInputTypes: _readCategories(
          json,
          'category_applied_input_types',
          _readInputTypes,
        ),
      );

  /// Whether the classifier flagged the image.
  final bool flagged;

  /// The classifier's flag for each returned category.
  final Map<String, bool> categories;

  /// The model's score for each returned category.
  ///
  /// Scores are model signals. Interpret them using the classifier guide.
  final Map<String, double> categoryScores;

  /// The input types evaluated for each returned category.
  final Map<String, List<String>> categoryAppliedInputTypes;

  /// Converts this result to JSON.
  Map<String, dynamic> toJson() => {
    'flagged': flagged,
    'categories': categories,
    'category_scores': categoryScores,
    'category_applied_input_types': categoryAppliedInputTypes,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageClassifierResult &&
          flagged == other.flagged &&
          mapsEqual(categories, other.categories) &&
          mapsEqual(categoryScores, other.categoryScores) &&
          mapsDeepEqual(
            categoryAppliedInputTypes,
            other.categoryAppliedInputTypes,
          );

  @override
  int get hashCode => Object.hash(
    flagged,
    mapHash(categories),
    mapHash(categoryScores),
    mapDeepHashCode(categoryAppliedInputTypes),
  );
}

Map<String, T> _readCategories<T>(
  Map<String, dynamic> json,
  String field,
  T Function(Object?, String) readValue,
) {
  final categories = requireJsonObject(
    json[field],
    'ImageClassifierResult.$field',
  );
  return {
    for (final entry in categories.entries)
      entry.key: readValue(entry.value, field),
  };
}

bool _readFlag(Object? value, String field) {
  if (value is! bool) {
    throw FormatException('ImageClassifierResult.$field: expected a boolean');
  }
  return value;
}

double _readScore(Object? value, String field) {
  if (value is! num || !value.isFinite) {
    throw FormatException(
      'ImageClassifierResult.$field: expected a finite number',
    );
  }
  return value.toDouble();
}

List<String> _readInputTypes(Object? value, String field) {
  if (value is! List) {
    throw FormatException('ImageClassifierResult.$field: expected a list');
  }
  return [
    for (final item in value)
      requireJsonString(item, 'ImageClassifierResult.$field item'),
  ];
}
