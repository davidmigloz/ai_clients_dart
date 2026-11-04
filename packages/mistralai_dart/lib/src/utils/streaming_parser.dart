import 'dart:async';
import 'dart:convert';

/// Parses a stream of bytes as Server-Sent Events (SSE).
///
/// Mistral AI uses SSE for streaming responses where each event is prefixed
/// with `data: ` and terminated with `\n\n`. The stream ends with `data: [DONE]`.
///
/// Example:
/// ```dart
/// final stream = response.stream;
/// await for (final json in parseSSE(stream)) {
///   print(json); // Each event parsed as Map<String, dynamic>
/// }
/// ```
Stream<Map<String, dynamic>> parseSSE(Stream<List<int>> byteStream) =>
    _parseLines(byteStream, _SseSink.new);

// Queue parsed events before delivering done so normal HTTP EOF can be
// observed before automatic subscription cleanup. Explicit cancellation still
// reaches the raw source directly while it is idle.
Stream<Map<String, dynamic>> _parseLines(
  Stream<List<int>> byteStream,
  EventSink<String> Function(EventSink<Map<String, dynamic>>) createSink,
) {
  StreamSubscription<String>? subscription;
  late StreamController<Map<String, dynamic>> controller;
  controller = StreamController<Map<String, dynamic>>(
    onListen: () {
      final sink = createSink(controller.sink);
      subscription = bytesToLines(
        byteStream,
      ).listen(sink.add, onError: sink.addError, onDone: sink.close);
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () {
      Future<void>.sync(() => subscription?.cancel()).ignore();
    },
  );
  return controller.stream;
}

/// Per-subscription parser state with cancellation forwarded to the byte stream.
class _SseSink implements EventSink<String> {
  final EventSink<Map<String, dynamic>> _sink;
  final _dataBuffer = StringBuffer();
  String? _event;
  bool _closed = false;

  _SseSink(this._sink);

  void _flush() {
    if (_dataBuffer.isEmpty) return;
    final data = _dataBuffer.toString();
    _dataBuffer.clear();
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      if (_event != null) json['_event'] = _event;
      _sink.add(json);
    } catch (_) {
      if (_event == 'error') {
        _sink.add(<String, dynamic>{
          '_event': 'error',
          '_rawData': data,
          'type': 'error',
        });
      }
    }
  }

  @override
  void add(String line) {
    if (_closed || line.startsWith(':')) return;
    if (line.startsWith('event:')) {
      _event = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      final data = line.substring(5).trim();
      if (data == '[DONE]') {
        close();
        return;
      }
      if (_dataBuffer.isNotEmpty) _dataBuffer.write('\n');
      _dataBuffer.write(data);
    } else if (line.isEmpty) {
      _flush();
      _event = null;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    _closed = true;
    _sink
      ..addError(error, stackTrace)
      ..close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _flush();
    _sink.close();
  }
}

/// Parses a stream of bytes as SSE and converts to typed objects.
///
/// **Note:** This convenience function does not check for inline stream errors
/// (e.g., `event: error` or `{"error": ...}` in data). If you need error
/// detection, iterate over [parseSSE] directly and check each event before
/// calling `fromJson`.
///
/// Example:
/// ```dart
/// final events = parseSSEAs<ChatCompletionStreamResponse>(
///   response.stream,
///   ChatCompletionStreamResponse.fromJson,
/// );
/// ```
Stream<T> parseSSEAs<T>(
  Stream<List<int>> byteStream,
  T Function(Map<String, dynamic>) fromJson,
) => _mapEvents(parseSSE(byteStream), fromJson);

/// Parses a stream of bytes as newline-delimited JSON (NDJSON).
///
/// This is an alternative format where each line is a complete JSON object.
///
/// Example:
/// ```dart
/// final stream = response.stream;
/// await for (final json in parseNDJSON(stream)) {
///   print(json); // Each line parsed as Map<String, dynamic>
/// }
/// ```
Stream<Map<String, dynamic>> parseNDJSON(Stream<List<int>> byteStream) =>
    _parseLines(byteStream, _NdjsonSink.new);

class _NdjsonSink implements EventSink<String> {
  final EventSink<Map<String, dynamic>> _sink;
  bool _closed = false;

  _NdjsonSink(this._sink);

  @override
  void add(String line) {
    if (_closed || line.isEmpty) return;
    try {
      _sink.add(jsonDecode(line) as Map<String, dynamic>);
    } catch (_) {
      // Preserve the parser's handling of malformed JSON lines.
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    _closed = true;
    _sink
      ..addError(error, stackTrace)
      ..close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _sink.close();
  }
}

/// Parses a stream of bytes as NDJSON and converts to typed objects.
///
/// Example:
/// ```dart
/// final events = parseNDJSONAs<ChatStreamEvent>(
///   response.stream,
///   ChatStreamEvent.fromJson,
/// );
/// ```
Stream<T> parseNDJSONAs<T>(
  Stream<List<int>> byteStream,
  T Function(Map<String, dynamic>) fromJson,
) => _mapEvents(parseNDJSON(byteStream), fromJson);

Stream<T> _mapEvents<T>(
  Stream<Map<String, dynamic>> events,
  T Function(Map<String, dynamic>) fromJson,
) => events.transform(
  StreamTransformer<Map<String, dynamic>, T>.fromHandlers(
    handleData: (event, sink) {
      try {
        sink.add(fromJson(event));
      } catch (error, stackTrace) {
        sink
          ..addError(error, stackTrace)
          ..close();
      }
    },
  ),
);

/// Transforms a byte stream to lines.
///
/// Handles partial lines at chunk boundaries.
Stream<String> bytesToLines(Stream<List<int>> byteStream) {
  return byteStream.transform(utf8.decoder).transform(const LineSplitter());
}
