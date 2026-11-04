import 'dart:async';

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
  Stream<String> textDeltas() => where(
    (event) => event is ContentBlockDeltaEvent && event.delta is TextDelta,
  ).map((event) => ((event as ContentBlockDeltaEvent).delta as TextDelta).text);

  /// Yields individual thinking delta strings as they arrive.
  Stream<String> thinkingDeltas() =>
      where(
        (event) =>
            event is ContentBlockDeltaEvent && event.delta is ThinkingDelta,
      ).map(
        (event) =>
            ((event as ContentBlockDeltaEvent).delta as ThinkingDelta).thinking,
      );

  /// Yields individual input JSON delta strings as they arrive (for tool use).
  Stream<String> inputJsonDeltas() =>
      where(
        (event) =>
            event is ContentBlockDeltaEvent && event.delta is InputJsonDelta,
      ).map(
        (event) => ((event as ContentBlockDeltaEvent).delta as InputJsonDelta)
            .partialJson,
      );

  /// Accumulates events, yielding the accumulator after each event.
  ///
  /// The same mutable [MessageStreamAccumulator] instance is yielded each
  /// time. Use [MessageStreamAccumulator.toMessage] to obtain an immutable
  /// snapshot at any point.
  Stream<MessageStreamAccumulator> accumulate() =>
      Stream<MessageStreamAccumulator>.eventTransformed(
        this,
        _AccumulatorSink.new,
      );

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

class _AccumulatorSink implements EventSink<MessageStreamEvent> {
  final EventSink<MessageStreamAccumulator> _output;
  final _accumulator = MessageStreamAccumulator();
  bool _closed = false;

  _AccumulatorSink(this._output);

  @override
  void add(MessageStreamEvent event) {
    if (_closed) return;
    try {
      _accumulator.add(event);
      _output.add(_accumulator);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    _output.addError(error, stackTrace);
    close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _output.close();
  }
}
