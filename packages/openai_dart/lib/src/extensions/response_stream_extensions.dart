import '../models/responses/streaming/response_stream_accumulator.dart';
import '../models/responses/streaming/response_stream_event.dart';

/// Extensions on [Stream<ResponseStreamEvent>] for convenient operations.
extension ResponseStreamExtension on Stream<ResponseStreamEvent> {
  /// Filters to only text delta strings.
  ///
  /// Emits the [OutputTextDeltaEvent.delta] for each text delta event.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.responses.createStream(request);
  ///
  /// await for (final text in stream.textDeltas()) {
  ///   stdout.write(text);
  /// }
  /// ```
  Stream<String> textDeltas() async* {
    await for (final event in this) {
      if (event is OutputTextDeltaEvent) {
        yield event.delta;
      }
    }
  }

  /// Collects all text deltas into a single string.
  ///
  /// **Note:** This method consumes the entire stream. The stream cannot be
  /// listened to again after calling this.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.responses.createStream(request);
  /// final fullText = await stream.collectText();
  /// print(fullText);
  /// ```
  Future<String> collectText() async {
    final buffer = StringBuffer();
    await for (final event in this) {
      if (event is OutputTextDeltaEvent) {
        buffer.write(event.delta);
      }
    }
    return buffer.toString();
  }

  /// Returns a stream of progressive accumulator states.
  ///
  /// Each emitted value reflects the state after processing the latest event.
  ///
  /// **Note:** This method consumes the entire stream. The same mutable
  /// accumulator instance is yielded after each event, so each yield
  /// reflects the current accumulated state (not a snapshot).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.responses.createStream(request);
  ///
  /// await for (final accumulator in stream.accumulate()) {
  ///   print('Current text: ${accumulator.text}');
  /// }
  /// ```
  Stream<ResponseStreamAccumulator> accumulate() async* {
    final accumulator = ResponseStreamAccumulator();
    await for (final event in this) {
      accumulator.add(event);
      yield accumulator;
    }
  }
}
