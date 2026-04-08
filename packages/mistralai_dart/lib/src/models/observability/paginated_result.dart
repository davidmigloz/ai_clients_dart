import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'campaign_preview.dart';
import 'chat_completion_event_preview.dart';
import 'dataset_import_task.dart';
import 'dataset_preview.dart';
import 'dataset_record.dart';
import 'judge_preview.dart';

/// A paginated result containing a count, navigation links, and results.
@immutable
class PaginatedResult<T> {
  /// Total number of matching items.
  final int count;

  /// URL for the next page (null if no more pages).
  final String? next;

  /// URL for the previous page (null if on the first page).
  final String? previous;

  /// The results for this page.
  final List<T> results;

  /// Creates a [PaginatedResult].
  PaginatedResult({
    required this.count,
    this.next,
    this.previous,
    List<T>? results,
  }) : results = List.unmodifiable(results ?? []);

  /// Creates a [PaginatedResult] from JSON with a custom item parser.
  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) => PaginatedResult(
    count: json['count'] as int? ?? 0,
    next: json['next'] as String?,
    previous: json['previous'] as String?,
    results: (json['results'] as List?)
        ?.map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON with a custom item serializer.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
    'count': count,
    if (next != null) 'next': next,
    if (previous != null) 'previous': previous,
    'results': results.map(toJsonT).toList(),
  };

  /// Creates a copy with replaced values.
  PaginatedResult<T> copyWith({
    int? count,
    Object? next = unsetCopyWithValue,
    Object? previous = unsetCopyWithValue,
    List<T>? results,
  }) {
    return PaginatedResult(
      count: count ?? this.count,
      next: next == unsetCopyWithValue ? this.next : next as String?,
      previous: previous == unsetCopyWithValue
          ? this.previous
          : previous as String?,
      results: results ?? this.results,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginatedResult<T>) return false;
    if (runtimeType != other.runtimeType) return false;
    return count == other.count &&
        next == other.next &&
        previous == other.previous &&
        listsEqual(results, other.results);
  }

  @override
  int get hashCode => Object.hash(count, next, previous, listHash(results));

  @override
  String toString() =>
      'PaginatedResult(count: $count, results: ${results.length} items)';
}

/// A paginated result of [CampaignPreview] items.
typedef PaginatedCampaignPreviews = PaginatedResult<CampaignPreview>;

/// A paginated result of [ChatCompletionEventPreview] items.
typedef PaginatedChatCompletionEventPreviews =
    PaginatedResult<ChatCompletionEventPreview>;

/// A paginated result of [DatasetImportTask] items.
typedef PaginatedDatasetImportTasks = PaginatedResult<DatasetImportTask>;

/// A paginated result of [DatasetPreview] items.
typedef PaginatedDatasetPreviews = PaginatedResult<DatasetPreview>;

/// A paginated result of [DatasetRecord] items.
typedef PaginatedDatasetRecords = PaginatedResult<DatasetRecord>;

/// A paginated result of [JudgePreview] items.
typedef PaginatedJudgePreviews = PaginatedResult<JudgePreview>;
