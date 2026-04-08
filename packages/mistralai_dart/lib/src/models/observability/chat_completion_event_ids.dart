import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Response containing a list of chat completion event IDs.
@immutable
class ChatCompletionEventIds {
  /// The event IDs.
  final List<String> completionEventIds;

  /// Creates a [ChatCompletionEventIds].
  ChatCompletionEventIds({required List<String> completionEventIds})
    : completionEventIds = List.unmodifiable(completionEventIds);

  /// Creates a [ChatCompletionEventIds] from JSON.
  factory ChatCompletionEventIds.fromJson(Map<String, dynamic> json) =>
      ChatCompletionEventIds(
        completionEventIds:
            (json['completion_event_ids'] as List?)?.cast<String>() ?? [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'completion_event_ids': completionEventIds};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionEventIds) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(completionEventIds, other.completionEventIds);
  }

  @override
  int get hashCode => listHash(completionEventIds);

  @override
  String toString() =>
      'ChatCompletionEventIds(${completionEventIds.length} ids)';
}
