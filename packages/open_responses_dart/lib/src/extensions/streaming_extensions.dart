import '../models/response/response_resource.dart';
import '../models/streaming/streaming_event.dart';

/// Convenience extensions for [StreamingEvent].
extension StreamingEventExtensions on StreamingEvent {
  /// Extract text delta if this is a text delta event.
  String? get textDelta => switch (this) {
    OutputTextDeltaEvent(delta: final d) => d,
    _ => null,
  };

  /// Whether this is the final event (response completed/failed/incomplete).
  bool get isFinal => switch (this) {
    ResponseCompletedEvent() ||
    ResponseFailedEvent() ||
    ResponseIncompleteEvent() => true,
    _ => false,
  };
}

/// Convenience extensions for streaming responses.
extension StreamingEventsExtensions on Stream<StreamingEvent> {
  /// Collects all text content from the stream.
  ///
  /// Matches OpenAI SDK's text accumulation pattern.
  Future<String> get text async {
    final buffer = StringBuffer();
    await for (final event in this) {
      if (event is OutputTextDeltaEvent) {
        buffer.write(event.delta);
      }
    }
    return buffer.toString();
  }

  /// Gets the final response from the stream.
  ///
  /// Matches OpenAI SDK's `finalResponse()` method.
  Future<ResponseResource?> get finalResponse async {
    await for (final event in this) {
      if (event is ResponseCompletedEvent) return event.response;
    }
    return null;
  }

  /// Filters stream to only text delta events for simple text streaming.
  Stream<String> get textDeltas => where(
    (e) => e is OutputTextDeltaEvent,
  ).map((e) => (e as OutputTextDeltaEvent).delta);
}
