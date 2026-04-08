import 'package:meta/meta.dart';

import 'judge_preview.dart';
import 'paginated_result.dart';

/// Response containing a paginated list of judge previews.
@immutable
class JudgePreviews {
  /// The paginated judges.
  final PaginatedResult<JudgePreview> judges;

  /// Creates a [JudgePreviews].
  const JudgePreviews({required this.judges});

  /// Creates a [JudgePreviews] from JSON.
  factory JudgePreviews.fromJson(Map<String, dynamic> json) => JudgePreviews(
    judges: PaginatedResult.fromJson(
      json['judges'] as Map<String, dynamic>? ?? {},
      JudgePreview.fromJson,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'judges': judges.toJson((e) => e.toJson())};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgePreviews) return false;
    if (runtimeType != other.runtimeType) return false;
    return judges == other.judges;
  }

  @override
  int get hashCode => judges.hashCode;

  @override
  String toString() => 'JudgePreviews(judges: $judges)';
}
