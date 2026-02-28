import '../models/metadata/stop_reason.dart';
import '../models/streaming/content_block_delta.dart';
import '../models/streaming/message_stream_accumulator.dart';
import '../models/streaming/message_stream_event.dart';

/// Convenience extensions on [Stream<MessageStreamEvent>].
extension MessageStreamExtension on Stream<MessageStreamEvent> {
  /// Collects all text deltas into a single string.
  Future<String> collectText() async {
    final buffer = StringBuffer();
    await for (final event in this) {
      if (event is ContentBlockDeltaEvent && event.delta is TextDelta) {
        buffer.write((event.delta as TextDelta).text);
      }
    }
    return buffer.toString();
  }

  /// Yields individual text delta strings as they arrive.
  Stream<String> textDeltas() async* {
    await for (final event in this) {
      if (event is ContentBlockDeltaEvent && event.delta is TextDelta) {
        yield (event.delta as TextDelta).text;
      }
    }
  }

  /// Yields individual thinking delta strings as they arrive.
  Stream<String> thinkingDeltas() async* {
    await for (final event in this) {
      if (event is ContentBlockDeltaEvent && event.delta is ThinkingDelta) {
        yield (event.delta as ThinkingDelta).thinking;
      }
    }
  }

  /// Yields individual input JSON delta strings as they arrive (for tool use).
  Stream<String> inputJsonDeltas() async* {
    await for (final event in this) {
      if (event is ContentBlockDeltaEvent && event.delta is InputJsonDelta) {
        yield (event.delta as InputJsonDelta).partialJson;
      }
    }
  }

  /// Accumulates events, yielding the accumulator after each event.
  ///
  /// The same mutable [MessageStreamAccumulator] instance is yielded each
  /// time. Use [MessageStreamAccumulator.toMessage] to obtain an immutable
  /// snapshot at any point.
  Stream<MessageStreamAccumulator> accumulate() async* {
    final accumulator = MessageStreamAccumulator();
    await for (final event in this) {
      accumulator.add(event);
      yield accumulator;
    }
  }

  /// Consumes the entire stream and returns the last stop reason.
  ///
  /// Returns `null` if no [MessageDeltaEvent] with a stop reason was received.
  Future<StopReason?> get stopReason async {
    StopReason? result;
    await for (final event in this) {
      if (event is MessageDeltaEvent) {
        final reason = event.delta.stopReason;
        if (reason != null) result = reason;
      }
    }
    return result;
  }
}
