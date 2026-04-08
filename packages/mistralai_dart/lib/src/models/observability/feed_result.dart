import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'chat_completion_event_preview.dart';

/// A feed result with cursor-based pagination.
@immutable
class FeedResult<T> {
  /// Current cursor position.
  final String? cursor;

  /// Cursor for the next page.
  final String? next;

  /// The results.
  final List<T> results;

  /// Creates a [FeedResult].
  FeedResult({this.cursor, this.next, List<T>? results})
    : results = List.unmodifiable(results ?? []);

  /// Creates a [FeedResult] from JSON with a custom item parser.
  factory FeedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) => FeedResult(
    cursor: json['cursor'] as String?,
    next: json['next'] as String?,
    results: (json['results'] as List?)
        ?.map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON with a custom item serializer.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) => {
    if (cursor != null) 'cursor': cursor,
    if (next != null) 'next': next,
    'results': results.map(toJsonT).toList(),
  };

  /// Creates a copy with replaced values.
  FeedResult<T> copyWith({
    Object? cursor = unsetCopyWithValue,
    Object? next = unsetCopyWithValue,
    List<T>? results,
  }) {
    return FeedResult(
      cursor: cursor == unsetCopyWithValue ? this.cursor : cursor as String?,
      next: next == unsetCopyWithValue ? this.next : next as String?,
      results: results ?? this.results,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FeedResult<T>) return false;
    if (runtimeType != other.runtimeType) return false;
    return cursor == other.cursor &&
        next == other.next &&
        listsEqual(results, other.results);
  }

  @override
  int get hashCode => Object.hash(cursor, next, listHash(results));

  @override
  String toString() =>
      'FeedResult(cursor: $cursor, results: ${results.length} items)';
}

/// A feed result of [ChatCompletionEventPreview] items.
typedef ChatCompletionEventPreviewFeed = FeedResult<ChatCompletionEventPreview>;
