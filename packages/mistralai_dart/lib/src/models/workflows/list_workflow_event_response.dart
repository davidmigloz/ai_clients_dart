import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Response containing a list of workflow events.
@immutable
class ListWorkflowEventResponse {
  /// The list of events.
  final List<Map<String, dynamic>> events;

  /// Cursor for the next page.
  final String? nextCursor;

  /// Creates a [ListWorkflowEventResponse].
  ListWorkflowEventResponse({
    required List<Map<String, dynamic>> events,
    this.nextCursor,
  }) : events = List.unmodifiable(events);

  /// Creates a [ListWorkflowEventResponse] from JSON.
  factory ListWorkflowEventResponse.fromJson(Map<String, dynamic> json) =>
      ListWorkflowEventResponse(
        events: (json['events'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'events': events,
    if (nextCursor != null) 'next_cursor': nextCursor,
  };

  /// Creates a copy with replaced values.
  ListWorkflowEventResponse copyWith({
    List<Map<String, dynamic>>? events,
    Object? nextCursor = unsetCopyWithValue,
  }) {
    return ListWorkflowEventResponse(
      events: events ?? this.events,
      nextCursor: nextCursor == unsetCopyWithValue
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ListWorkflowEventResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listOfMapsDeepEqual(events, other.events)) return false;
    return nextCursor == other.nextCursor;
  }

  @override
  int get hashCode => Object.hash(listOfMapsHashCode(events), nextCursor);

  @override
  String toString() =>
      'ListWorkflowEventResponse(events: ${events.length}, nextCursor: $nextCursor)';
}
