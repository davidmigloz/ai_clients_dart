import 'package:meta/meta.dart';

import '../models/response/response_resource.dart';
import '../models/streaming/streaming_event.dart';

/// Accumulates streaming events into a progressive state.
///
/// Tracks text, reasoning, function arguments, and response status
/// as events arrive. Similar to openai_dart's `ResponseStreamAccumulator`.
///
/// ## Usage
///
/// ```dart
/// final accumulator = StreamingEventAccumulator();
/// await for (final event in stream) {
///   accumulator.add(event);
///   print('Text so far: ${accumulator.text}');
///   if (accumulator.isComplete) break;
/// }
/// ```
@immutable
class StreamingEventAccumulatorSnapshot {
  /// The accumulated text content.
  final String text;

  /// The accumulated reasoning content.
  final String reasoning;

  /// The accumulated reasoning summary content.
  final String reasoningSummary;

  /// The accumulated function call arguments, keyed by item ID (unmodifiable).
  final Map<String, String> functionArguments;

  /// The final response, if the stream has completed.
  final ResponseResource? response;

  /// The latest event that was processed.
  final StreamingEvent? latestEvent;

  /// Whether the stream has completed (successfully, with failure, or incomplete).
  final bool isComplete;

  /// Whether the stream completed successfully.
  final bool isSuccessful;

  /// Whether the stream failed.
  final bool isFailed;

  /// Creates a [StreamingEventAccumulatorSnapshot].
  StreamingEventAccumulatorSnapshot({
    this.text = '',
    this.reasoning = '',
    this.reasoningSummary = '',
    Map<String, String> functionArguments = const {},
    this.response,
    this.latestEvent,
    this.isComplete = false,
    this.isSuccessful = false,
    this.isFailed = false,
  }) : functionArguments = Map.unmodifiable(functionArguments);
}

/// Accumulates streaming events into progressive state snapshots.
class StreamingEventAccumulator {
  final _textBuffer = StringBuffer();
  final _reasoningBuffer = StringBuffer();
  final _reasoningSummaryBuffer = StringBuffer();
  final Map<String, StringBuffer> _functionArgsBuffers = {};
  ResponseResource? _response;
  StreamingEvent? _latestEvent;
  bool _isComplete = false;
  bool _isSuccessful = false;
  bool _isFailed = false;

  /// The accumulated text content.
  String get text => _textBuffer.toString();

  /// The accumulated reasoning content.
  String get reasoning => _reasoningBuffer.toString();

  /// The accumulated reasoning summary content.
  String get reasoningSummary => _reasoningSummaryBuffer.toString();

  /// The accumulated function call arguments, keyed by item ID.
  Map<String, String> get functionArguments =>
      _functionArgsBuffers.map((k, v) => MapEntry(k, v.toString()));

  /// The final response, if the stream has completed.
  ResponseResource? get response => _response;

  /// The latest event that was processed.
  StreamingEvent? get latestEvent => _latestEvent;

  /// Whether the stream has completed.
  bool get isComplete => _isComplete;

  /// Whether the stream completed successfully.
  bool get isSuccessful => _isSuccessful;

  /// Whether the stream failed.
  bool get isFailed => _isFailed;

  /// Adds an event to the accumulator and updates the state.
  void add(StreamingEvent event) {
    _latestEvent = event;

    switch (event) {
      case OutputTextDeltaEvent(:final delta):
        _textBuffer.write(delta);
      case ReasoningDeltaEvent(:final delta):
        _reasoningBuffer.write(delta);
      case ReasoningSummaryDeltaEvent(:final delta):
        _reasoningSummaryBuffer.write(delta);
      case FunctionCallArgumentsDeltaEvent(:final itemId, :final delta):
        (_functionArgsBuffers[itemId] ??= StringBuffer()).write(delta);
      case ResponseCompletedEvent(:final response):
        _response = response;
        _isComplete = true;
        _isSuccessful = true;
        _isFailed = false;
      case ResponseFailedEvent(:final response):
        _response = response;
        _isComplete = true;
        _isSuccessful = false;
        _isFailed = true;
      case ResponseIncompleteEvent(:final response):
        _response = response;
        _isComplete = true;
        _isSuccessful = false;
        _isFailed = false;
      default:
        break;
    }
  }

  /// Returns a snapshot of the current accumulator state.
  StreamingEventAccumulatorSnapshot get snapshot =>
      StreamingEventAccumulatorSnapshot(
        text: text,
        reasoning: reasoning,
        reasoningSummary: reasoningSummary,
        functionArguments: functionArguments,
        response: _response,
        latestEvent: _latestEvent,
        isComplete: _isComplete,
        isSuccessful: _isSuccessful,
        isFailed: _isFailed,
      );

  /// Resets the accumulator to its initial state.
  void reset() {
    _textBuffer.clear();
    _reasoningBuffer.clear();
    _reasoningSummaryBuffer.clear();
    _functionArgsBuffers.clear();
    _response = null;
    _latestEvent = null;
    _isComplete = false;
    _isSuccessful = false;
    _isFailed = false;
  }
}
