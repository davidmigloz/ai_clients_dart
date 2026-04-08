import 'package:meta/meta.dart';

import 'chat_completion_event_preview.dart';
import 'feed_result.dart';

/// Response containing a feed of chat completion event previews.
@immutable
class ChatCompletionEvents {
  /// The feed of completion events.
  final FeedResult<ChatCompletionEventPreview> completionEvents;

  /// Creates a [ChatCompletionEvents].
  const ChatCompletionEvents({required this.completionEvents});

  /// Creates a [ChatCompletionEvents] from JSON.
  factory ChatCompletionEvents.fromJson(Map<String, dynamic> json) =>
      ChatCompletionEvents(
        completionEvents: FeedResult.fromJson(
          json['completion_events'] as Map<String, dynamic>? ?? {},
          ChatCompletionEventPreview.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'completion_events': completionEvents.toJson((e) => e.toJson()),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatCompletionEvents) return false;
    if (runtimeType != other.runtimeType) return false;
    return completionEvents == other.completionEvents;
  }

  @override
  int get hashCode => completionEvents.hashCode;

  @override
  String toString() =>
      'ChatCompletionEvents(completionEvents: $completionEvents)';
}
