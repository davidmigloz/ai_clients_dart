import 'dart:async';

import '../models/messages/message.dart';
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
  Stream<String> textDeltas() => transform(
    _deltaStrings(
      (event) => switch (event) {
        ContentBlockDeltaEvent(delta: TextDelta(:final text)) => text,
        _ => null,
      },
    ),
  );

  /// Yields individual thinking delta strings as they arrive.
  Stream<String> thinkingDeltas() => transform(
    _deltaStrings(
      (event) => switch (event) {
        ContentBlockDeltaEvent(delta: ThinkingDelta(:final thinking)) =>
          thinking,
        _ => null,
      },
    ),
  );

  /// Yields individual input JSON delta strings as they arrive (for tool use).
  Stream<String> inputJsonDeltas() => transform(
    _deltaStrings(
      (event) => switch (event) {
        ContentBlockDeltaEvent(delta: InputJsonDelta(:final partialJson)) =>
          partialJson,
        _ => null,
      },
    ),
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

  /// Consumes the stream and returns its completed message.
  ///
  /// A truncated or failed stream throws. For partial output, use
  /// [accumulate] instead.
  Future<Message> finalMessage() async {
    final accumulator = MessageStreamAccumulator();
    await for (final event in this) {
      accumulator.add(event);
      if (event is ErrorEvent) break;
    }
    return accumulator.toFinalMessage();
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

StreamTransformer<MessageStreamEvent, String> _deltaStrings(
  String? Function(MessageStreamEvent) select,
) => StreamTransformer<MessageStreamEvent, String>.fromHandlers(
  handleData: (event, sink) {
    final delta = select(event);
    if (delta != null) sink.add(delta);
  },
  handleError: (error, stackTrace, sink) {
    sink
      ..addError(error, stackTrace)
      ..close();
  },
);

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
