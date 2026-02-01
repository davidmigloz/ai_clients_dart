import '../config/response_status.dart';
import '../response.dart';
import '../response_usage.dart';
import 'response_stream_event.dart';

/// Accumulates streaming events into a complete response.
///
/// This class helps reconstruct the full response from individual streaming
/// events. It maintains running state and provides convenient access to
/// accumulated content.
///
/// ## Example
///
/// ```dart
/// final accumulator = ResponseStreamAccumulator();
///
/// await for (final event in client.responses.createStream(request)) {
///   accumulator.add(event);
///   print('Current text: ${accumulator.text}');
/// }
///
/// print('Final response: ${accumulator.response}');
/// ```
class ResponseStreamAccumulator {
  /// The accumulated response, if available.
  Response? _response;

  /// The accumulated text content.
  final StringBuffer _textBuffer = StringBuffer();

  /// The accumulated function call arguments by call ID.
  final Map<String, StringBuffer> _functionArgs = {};

  /// The accumulated reasoning content.
  final StringBuffer _reasoningBuffer = StringBuffer();

  /// The current response status.
  ResponseStatus _status = ResponseStatus.queued;

  /// The latest event received.
  ResponseStreamEvent? _latestEvent;

  /// Token usage, if available.
  ResponseUsage? _usage;

  /// Creates a [ResponseStreamAccumulator].
  ResponseStreamAccumulator();

  /// Adds an event to the accumulator.
  void add(ResponseStreamEvent event) {
    _latestEvent = event;

    switch (event) {
      case ResponseCreatedEvent(:final response):
        _response = response;
        _status = response.status;

      case ResponseQueuedEvent(:final response):
        _response = response;
        _status = response.status;

      case ResponseInProgressEvent(:final response):
        _response = response;
        _status = response.status;

      case ResponseCompletedEvent(:final response):
        _response = response;
        _status = response.status;
        _usage = response.usage;

      case ResponseFailedEvent(:final response):
        _response = response;
        _status = response.status;

      case ResponseIncompleteEvent(:final response):
        _response = response;
        _status = response.status;

      case OutputTextDeltaEvent(:final delta):
        _textBuffer.write(delta);

      case FunctionCallArgumentsDeltaEvent(:final itemId, :final delta):
        // Use itemId if available, otherwise fall back to outputIndex as key
        final key = itemId ?? 'output_${event.outputIndex}';
        _functionArgs.putIfAbsent(key, StringBuffer.new).write(delta);

      case ReasoningTextDeltaEvent(:final delta):
        _reasoningBuffer.write(delta);

      // Other events don't affect accumulated state
      default:
        break;
    }
  }

  /// The current response, if available.
  Response? get response => _response;

  /// The accumulated text content.
  String get text => _textBuffer.toString();

  /// The current response status.
  ResponseStatus get status => _status;

  /// Token usage statistics, if available.
  ResponseUsage? get usage => _usage;

  /// Whether the stream is complete (finished successfully, failed, or incomplete).
  bool get isComplete =>
      _status == ResponseStatus.completed ||
      _status == ResponseStatus.failed ||
      _status == ResponseStatus.incomplete;

  /// Whether the response completed successfully.
  bool get isSuccessful => _status == ResponseStatus.completed;

  /// Whether the response failed.
  bool get isFailed => _status == ResponseStatus.failed;

  /// The latest event received.
  ResponseStreamEvent? get latestEvent => _latestEvent;

  /// The accumulated function call arguments by call ID.
  Map<String, String> get functionArguments =>
      _functionArgs.map((k, v) => MapEntry(k, v.toString()));

  /// The accumulated reasoning content.
  String get reasoning => _reasoningBuffer.toString();

  /// The response ID, if available.
  String? get responseId => _response?.id;

  /// Resets the accumulator to its initial state.
  void reset() {
    _response = null;
    _textBuffer.clear();
    _functionArgs.clear();
    _reasoningBuffer.clear();
    _status = ResponseStatus.queued;
    _latestEvent = null;
    _usage = null;
  }

  @override
  String toString() =>
      'ResponseStreamAccumulator(status: $_status, textLength: ${_textBuffer.length})';
}
