import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/usage_info.dart';
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

  /// Token usage when reported by the moderation model.
  final UsageInfo? usage;

  /// Creates a [ModerationResponse].
  const ModerationResponse({
    required this.id,
    required this.model,
    required this.results,
    this.usage,
  });

  /// Creates a [ModerationResponse] from JSON.
  factory ModerationResponse.fromJson(Map<String, dynamic> json) =>
      ModerationResponse(
        id: json['id'] as String? ?? '',
        model: json['model'] as String? ?? '',
        usage: json['usage'] == null
            ? null
            : UsageInfo.fromJson(json['usage'] as Map<String, dynamic>),
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
    if (usage != null) 'usage': usage!.toJson(),
  };

  /// Creates a copy with replaced values.
  ModerationResponse copyWith({
    String? id,
    String? model,
    List<ModerationResult>? results,
    Object? usage = unsetCopyWithValue,
  }) => ModerationResponse(
    id: id ?? this.id,
    model: model ?? this.model,
    results: results ?? this.results,
    usage: usage == unsetCopyWithValue ? this.usage : usage as UsageInfo?,
  );

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
          listsEqual(results, other.results) &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(id, model, listHash(results), usage);

  @override
  String toString() =>
      'ModerationResponse(id: $id, model: $model, results: ${results.length}, usage: $usage)';
}
