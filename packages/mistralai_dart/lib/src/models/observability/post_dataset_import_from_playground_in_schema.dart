import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to import dataset records from the playground.
@immutable
class PostDatasetImportFromPlaygroundInSchema {
  /// The conversation IDs to import.
  final List<String> conversationIds;

  /// Creates a [PostDatasetImportFromPlaygroundInSchema].
  PostDatasetImportFromPlaygroundInSchema({
    required List<String> conversationIds,
  }) : conversationIds = List.unmodifiable(conversationIds);

  /// Creates a [PostDatasetImportFromPlaygroundInSchema] from JSON.
  factory PostDatasetImportFromPlaygroundInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetImportFromPlaygroundInSchema(
    conversationIds: (json['conversation_ids'] as List?)?.cast<String>() ?? [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'conversation_ids': conversationIds};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetImportFromPlaygroundInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(conversationIds, other.conversationIds);
  }

  @override
  int get hashCode => listHash(conversationIds);

  @override
  String toString() =>
      'PostDatasetImportFromPlaygroundInSchema('
      '${conversationIds.length} conversations)';
}
