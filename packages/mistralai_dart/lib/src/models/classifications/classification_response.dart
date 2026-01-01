import 'package:meta/meta.dart';

import 'classification_result.dart';

/// Response from a classification request.
@immutable
class ClassificationResponse {
  /// Unique identifier for the classification.
  final String id;

  /// The model used for classification.
  final String model;

  /// List of classification results (one per input).
  final List<ClassificationResult> results;

  /// Creates a [ClassificationResponse].
  const ClassificationResponse({
    required this.id,
    required this.model,
    required this.results,
  });

  /// Creates a [ClassificationResponse] from JSON.
  factory ClassificationResponse.fromJson(Map<String, dynamic> json) =>
      ClassificationResponse(
        id: json['id'] as String? ?? '',
        model: json['model'] as String? ?? '',
        results:
            (json['results'] as List?)
                ?.map(
                  (e) =>
                      ClassificationResult.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'results': results.map((e) => e.toJson()).toList(),
  };

  /// Returns the first result, if any.
  ClassificationResult? get firstResult =>
      results.isNotEmpty ? results.first : null;

  /// Returns true if any result was flagged.
  bool get flagged => results.any((r) => r.flagged);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassificationResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          model == other.model;

  @override
  int get hashCode => Object.hash(id, model, results);

  @override
  String toString() =>
      'ClassificationResponse(id: $id, model: $model, '
      'results: ${results.length})';
}
