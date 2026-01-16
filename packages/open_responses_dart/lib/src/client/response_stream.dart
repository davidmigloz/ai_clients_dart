import 'dart:async';

import '../extensions/response_extensions.dart';
import '../models/response/response_resource.dart';
import '../models/streaming/streaming_event.dart';

/// A streaming response with event-based callbacks.
///
/// Similar to OpenAI SDK's ResponseStream pattern:
/// ```dart
/// final runner = client.responses.stream(request)
///   ..onEvent((event) => print('Event: $event'))
///   ..onTextDelta((delta) => stdout.write(delta));
///
/// await for (final event in runner) {
///   // Process events
/// }
///
/// final response = await runner.finalResponse;
/// ```
class ResponseStream {
  final Stream<StreamingEvent> _stream;
  final List<void Function(StreamingEvent)> _eventCallbacks = [];
  final List<void Function(String)> _textDeltaCallbacks = [];
  final List<void Function(String)> _functionCallDeltaCallbacks = [];
  final List<void Function(String)> _reasoningDeltaCallbacks = [];

  ResponseResource? _finalResponse;
  final _textBuffer = StringBuffer();
  bool _consumed = false;

  /// Creates a [ResponseStream].
  ResponseStream(this._stream);

  /// Register callback for all events.
  void onEvent(void Function(StreamingEvent event) callback) {
    _eventCallbacks.add(callback);
  }

  /// Register callback for text delta events only.
  void onTextDelta(void Function(String delta) callback) {
    _textDeltaCallbacks.add(callback);
  }

  /// Register callback for function call argument delta events.
  void onFunctionCallDelta(void Function(String delta) callback) {
    _functionCallDeltaCallbacks.add(callback);
  }

  /// Register callback for reasoning delta events.
  void onReasoningDelta(void Function(String delta) callback) {
    _reasoningDeltaCallbacks.add(callback);
  }

  /// Iterate through all events while executing callbacks.
  Stream<StreamingEvent> asStream() async* {
    if (_consumed) {
      throw StateError('Stream has already been consumed');
    }
    _consumed = true;

    await for (final event in _stream) {
      // Execute general callbacks
      for (final cb in _eventCallbacks) {
        cb(event);
      }

      // Handle text deltas
      if (event is OutputTextDeltaEvent) {
        _textBuffer.write(event.delta);
        for (final cb in _textDeltaCallbacks) {
          cb(event.delta);
        }
      }

      // Handle function call argument deltas
      if (event is FunctionCallArgumentsDeltaEvent) {
        for (final cb in _functionCallDeltaCallbacks) {
          cb(event.delta);
        }
      }

      // Handle reasoning deltas
      if (event is ReasoningDeltaEvent) {
        for (final cb in _reasoningDeltaCallbacks) {
          cb(event.delta);
        }
      }

      // Capture final response
      if (event is ResponseCompletedEvent) {
        _finalResponse = event.response;
      }

      yield event;
    }
  }

  /// Get the final completed response after stream completes.
  ///
  /// This consumes the stream if not already consumed.
  Future<ResponseResource?> get finalResponse async {
    if (_finalResponse != null) return _finalResponse;

    await for (final event in asStream()) {
      if (event is ResponseCompletedEvent) {
        return event.response;
      }
    }
    return null;
  }

  /// Get all accumulated text after stream completes.
  ///
  /// This consumes the stream if not already consumed.
  Future<String> get text async {
    await finalResponse;
    return _textBuffer.toString();
  }

  /// Get the output text from the final response.
  ///
  /// This is a convenience method that calls [finalResponse] and
  /// extracts the output text using the extension method.
  Future<String?> get outputText async {
    final response = await finalResponse;
    return response?.outputText;
  }
}
