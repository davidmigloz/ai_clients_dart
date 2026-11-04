import 'dart:async';
import 'dart:convert';

/// Parses Server-Sent Events (SSE) streams.
///
/// OpenAI uses SSE format for streaming responses. Each event has the format:
///
/// ```text
/// data: {"id":"chatcmpl-...","object":"chat.completion.chunk",...}
///
/// data: {"id":"chatcmpl-...","object":"chat.completion.chunk",...}
///
/// data: [DONE]
/// ```
///
/// ## Example
///
/// ```dart
/// final parser = SseParser();
/// final events = parser.parse(response.stream);
///
/// await for (final json in events) {
///   print('Received: $json');
/// }
/// ```
class SseParser {
  /// Creates an [SseParser].
  const SseParser();

  /// Parses a byte stream into SSE events.
  ///
  /// Returns a stream of parsed JSON objects from SSE data lines.
  /// The stream ends when `[DONE]` is received or the input stream ends.
  Stream<Map<String, dynamic>> parse(Stream<List<int>> bytes) {
    return parseRaw(bytes).expand((event) {
      if (event.isDone) return const <Map<String, dynamic>>[];
      final json = event.json;
      if (json != null) {
        if (event.event != null) json['_event'] = event.event;
        return [json];
      }
      if (event.event == 'error') {
        return [
          <String, dynamic>{
            '_event': 'error',
            '_rawData': event.data,
            'type': 'error',
          },
        ];
      }
      return const <Map<String, dynamic>>[];
    });
  }

  /// Parses raw SSE fields, preserving the event type and unparsed data.
  ///
  /// Pause and cancellation reach the byte stream directly, even while no
  /// complete event is available. Buffered events drain before normal cleanup.
  Stream<SseEvent> parseRaw(Stream<List<int>> bytes) {
    final lines = bytes.transform(utf8.decoder).transform(const LineSplitter());
    StreamSubscription<String>? subscription;
    late StreamController<SseEvent> controller;
    controller = StreamController<SseEvent>(
      onListen: () {
        final sink = _SseEventSink(controller.sink);
        subscription = lines.listen(
          sink.add,
          onError: sink.addError,
          onDone: sink.close,
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel().ignore(),
    );
    return controller.stream;
  }
}

/// A Server-Sent Event.
///
/// Represents a single event from an SSE stream with all its fields.
class SseEvent {
  /// Creates an [SseEvent].
  const SseEvent({this.event, required this.data, this.id, this.retry});

  /// The event type (from the `event:` field).
  final String? event;

  /// The event data (from the `data:` field).
  final String data;

  /// The event ID (from the `id:` field).
  final String? id;

  /// Reconnection time in milliseconds (from the `retry:` field).
  final int? retry;

  /// Whether this is the end-of-stream marker.
  bool get isDone => data == '[DONE]';

  /// Parses the data as JSON.
  ///
  /// Returns null if the data is `[DONE]` or cannot be parsed as JSON.
  Map<String, dynamic>? get json {
    if (isDone) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'SseEvent(event: $event, data: $data)';
}

/// Extension to handle SSE event types in parsed JSON.
extension SseEventExtension on Map<String, dynamic> {
  /// Gets the SSE event type if available.
  String? get sseEventType => this['_event'] as String?;

  /// Creates a copy without the internal event type field.
  Map<String, dynamic> withoutEventType() {
    return Map<String, dynamic>.from(this)..remove('_event');
  }
}

class _SseEventSink implements EventSink<String> {
  _SseEventSink(this._sink);

  final EventSink<SseEvent> _sink;
  final _data = StringBuffer();
  String? _event;
  String? _id;
  int? _retry;
  bool _closed = false;

  void _flush() {
    if (_data.isNotEmpty) {
      _sink.add(
        SseEvent(event: _event, data: _data.toString(), id: _id, retry: _retry),
      );
      _data.clear();
    }
    _event = null;
    _id = null;
    _retry = null;
  }

  @override
  void add(String line) {
    if (_closed) return;
    if (line.startsWith('event:')) {
      _event = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      final data = line.substring(5).trim();
      if (data == '[DONE]') {
        _flush();
        _sink.add(const SseEvent(event: 'done', data: '[DONE]'));
        close();
      } else {
        if (_data.isNotEmpty) _data.write('\n');
        _data.write(data);
      }
    } else if (line.startsWith('id:')) {
      _id = line.substring(3).trim();
    } else if (line.startsWith('retry:')) {
      _retry = int.tryParse(line.substring(6).trim());
    } else if (line.isEmpty) {
      _flush();
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
