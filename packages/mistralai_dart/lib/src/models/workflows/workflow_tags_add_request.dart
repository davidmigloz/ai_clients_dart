import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Tags to add to a workflow.
@immutable
class WorkflowTagsAddRequest {
  /// Tags to add to the existing set.
  final List<String> tags;

  /// Creates a [WorkflowTagsAddRequest].
  const WorkflowTagsAddRequest({required this.tags});

  /// Creates a [WorkflowTagsAddRequest] from JSON.
  factory WorkflowTagsAddRequest.fromJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as List<dynamic>?)?.cast<String>();
    if (tags == null) {
      throw const FormatException(
        'WorkflowTagsAddRequest: missing required "tags"',
      );
    }
    return WorkflowTagsAddRequest(tags: tags);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'tags': tags};

  /// Creates a copy with the given fields replaced.
  WorkflowTagsAddRequest copyWith({List<String>? tags}) =>
      WorkflowTagsAddRequest(tags: tags ?? this.tags);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkflowTagsAddRequest && listsEqual(tags, other.tags);

  @override
  int get hashCode => listHash(tags);

  @override
  String toString() => 'WorkflowTagsAddRequest(tags: ${tags.length} items)';
}
