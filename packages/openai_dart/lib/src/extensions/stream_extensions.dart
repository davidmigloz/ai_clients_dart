import '../models/common/finish_reason.dart';
import '../models/streaming/streaming.dart';

/// Extension methods for chat streaming.
extension ChatStreamExtension on Stream<ChatStreamEvent> {
  /// Collects all text deltas into a single string.
  ///
  /// **Note:** For multi-choice streams (`n > 1`), this concatenates text
  /// from all choices into a single string. For separate choice handling,
  /// use [accumulate] which provides per-choice access via the accumulator.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.chat.completions.createStream(request);
  /// final fullText = await stream.collectText();
  /// print(fullText);
  /// ```
  Future<String> collectText() async {
    final buffer = StringBuffer();
    await for (final event in this) {
      final choices = event.choices;
      if (choices == null) continue;
      for (final choice in choices) {
        if (choice.delta.content case final content?) {
          buffer.write(content);
        }
      }
    }
    return buffer.toString();
  }

  /// Accumulates stream events into a [ChatStreamAccumulator].
  ///
  /// Yields the accumulator after each event, allowing you to
  /// access both deltas and the accumulated state.
  ///
  /// **Note:** This method consumes the entire stream. The same mutable
  /// accumulator instance is yielded after each event, so each yield
  /// reflects the current accumulated state (not a snapshot).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.chat.completions.createStream(request);
  ///
  /// await for (final accumulator in stream.accumulate()) {
  ///   // Print the delta
  ///   print(accumulator.lastDelta?.content);
  ///
  ///   // Check accumulated state
  ///   print('Total text so far: ${accumulator.text}');
  /// }
  /// ```
  Stream<ChatStreamAccumulator> accumulate() async* {
    final accumulator = ChatStreamAccumulator();
    await for (final event in this) {
      accumulator.add(event);
      yield accumulator;
    }
  }

  /// Maps each event to its text delta content.
  ///
  /// Null deltas are filtered out.
  ///
  /// **Note:** For multi-choice streams (`n > 1`), this yields text from
  /// all choices interleaved. For separate choice handling, use [accumulate]
  /// which provides per-choice access via the accumulator.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.chat.completions.createStream(request);
  ///
  /// await for (final text in stream.textDeltas()) {
  ///   stdout.write(text);
  /// }
  /// ```
  Stream<String> textDeltas() async* {
    await for (final event in this) {
      final choices = event.choices;
      if (choices == null) continue;
      for (final choice in choices) {
        if (choice.delta.content case final content?) {
          yield content;
        }
      }
    }
  }

  /// Returns the last non-null finish reason from the stream.
  ///
  /// Useful for checking why the stream ended.
  ///
  /// **Note:** This method consumes the entire stream to find the finish
  /// reason. The stream cannot be listened to again after calling this.
  Future<FinishReason?> get finishReason async {
    FinishReason? reason;
    await for (final event in this) {
      final choices = event.choices;
      if (choices == null) continue;
      for (final choice in choices) {
        if (choice.finishReason != null) {
          reason = choice.finishReason;
        }
      }
    }
    return reason;
  }
}

/// Extension providing heuristic pagination checks for lists.
///
/// These methods provide a simple heuristic for detecting whether
/// a list might have more items available. Use this when the API
/// response doesn't include explicit pagination metadata.
extension ListPageSizeHeuristicsExtension<T> on List<T> {
  /// Checks if this list likely has more items available.
  ///
  /// Returns true if the list length equals or exceeds the typical
  /// page size, suggesting there might be more items.
  ///
  /// Throws [ArgumentError] if [pageSize] is not positive.
  bool likelyHasMore({int pageSize = 20}) {
    if (pageSize <= 0) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'pageSize must be greater than 0',
      );
    }
    return length >= pageSize;
  }
}
