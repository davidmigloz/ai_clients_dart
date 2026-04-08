import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to import dataset records from the event explorer.
@immutable
class PostDatasetImportFromExplorerInSchema {
  /// The completion event IDs to import (max 500 items).
  final List<String> completionEventIds;

  /// Creates a [PostDatasetImportFromExplorerInSchema].
  PostDatasetImportFromExplorerInSchema({
    required List<String> completionEventIds,
  }) : completionEventIds = List.unmodifiable(completionEventIds);

  /// Creates a [PostDatasetImportFromExplorerInSchema] from JSON.
  factory PostDatasetImportFromExplorerInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetImportFromExplorerInSchema(
    completionEventIds:
        (json['completion_event_ids'] as List?)?.cast<String>() ?? [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'completion_event_ids': completionEventIds};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetImportFromExplorerInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(completionEventIds, other.completionEventIds);
  }

  @override
  int get hashCode => listHash(completionEventIds);

  @override
  String toString() =>
      'PostDatasetImportFromExplorerInSchema('
      '${completionEventIds.length} events)';
}
