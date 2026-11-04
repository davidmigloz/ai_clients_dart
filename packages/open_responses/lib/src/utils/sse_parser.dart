import 'dart:async';
import 'dart:convert';

/// Parses Server-Sent Events (SSE) streams.
///
/// OpenResponses uses SSE format for streaming responses.
/// Each event has the format:
/// ```text
/// event: <event_type>
/// data: <json_data>
///
/// ```
class SseParser {
  /// Parses a byte stream into SSE events.
  ///
  /// Returns a stream of parsed JSON objects from SSE data lines.
  Stream<Map<String, dynamic>> parse(Stream<List<int>> bytes) {
    StreamSubscription<String>? subscription;
    late StreamController<Map<String, dynamic>> controller;
    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        final sink = _SseSink(controller.sink);
        subscription = bytes
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
              sink.add,
              onError: sink.addError,
              onDone: sink.close,
              cancelOnError: true,
            );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
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

/// Extension to handle SSE event types.
extension SseEventExtension on Map<String, dynamic> {
  /// Gets the SSE event type if available.
  String? get sseEventType => this['_event'] as String?;

  /// Creates a copy without the internal event type field.
  Map<String, dynamic> withoutEventType() {
    return Map<String, dynamic>.from(this)..remove('_event');
  }
}
