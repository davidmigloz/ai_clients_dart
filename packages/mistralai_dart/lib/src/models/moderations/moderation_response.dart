import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'moderation_result.dart';

/// Response from a moderation request.
@immutable
class ModerationResponse {
  /// Unique identifier for the moderation.
  final String id;

  /// The model used for moderation.
  final String model;

  /// List of moderation results (one per input).
  final List<ModerationResult> results;

  /// Creates a [ModerationResponse].
  const ModerationResponse({
    required this.id,
    required this.model,
    required this.results,
  });

  /// Creates a [ModerationResponse] from JSON.
  factory ModerationResponse.fromJson(Map<String, dynamic> json) =>
      ModerationResponse(
        id: json['id'] as String? ?? '',
        model: json['model'] as String? ?? '',
        results:
            (json['results'] as List?)
                ?.map(
                  (e) => ModerationResult.fromJson(e as Map<String, dynamic>),
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
  ModerationResult? get firstResult =>
      results.isNotEmpty ? results.first : null;

  /// Returns true if any result was flagged.
  bool get flagged => results.any((r) => r.flagged);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          model == other.model &&
          listEquals(results, other.results);

  @override
  int get hashCode => Object.hash(id, model, Object.hashAll(results));

  @override
  String toString() =>
      'ModerationResponse(id: $id, model: $model, results: ${results.length})';
}
