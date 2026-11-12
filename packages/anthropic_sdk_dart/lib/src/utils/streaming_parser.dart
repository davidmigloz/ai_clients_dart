import 'dart:async';
import 'dart:convert';

/// Parses Server-Sent Events (SSE) streams.
///
/// Cancellation and pause signals are forwarded to the byte stream, including
/// while no events arrive.
class SseParser {
  /// Parses a byte stream into SSE events.
  ///
  /// Returns a stream of parsed JSON objects from SSE data lines.
  /// [strictJson] reports malformed non-error frames as stream errors.
  Stream<Map<String, dynamic>> parse(
    Stream<List<int>> bytes, {
    bool strictJson = false,
  }) {
    StreamSubscription<String>? subscription;
    late StreamController<Map<String, dynamic>> controller;
    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        final sink = _SseSink(controller.sink, strictJson: strictJson);
        subscription = bytes
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(sink.add, onError: sink.addError, onDone: sink.close);
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel().ignore(),
    );
    return controller.stream;
  }
}

class _SseSink implements EventSink<String> {
  final EventSink<Map<String, dynamic>> _output;
  final bool _strictJson;
  final _data = StringBuffer();
  String? _event;
  bool _closed = false;

  _SseSink(this._output, {required this._strictJson});

  @override
  void add(String line) {
    if (_closed) return;
    if (line.startsWith('event:')) {
      _event = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      final data = line.substring(5).trim();
      if (data == '[DONE]' && _event != 'error') {
        close();
        return;
      }
      if (_data.isNotEmpty) _data.write('\n');
      _data.write(data);
    } else if (line.isEmpty) {
      _flush();
      _event = null;
    }
  }

  void _flush() {
    if (_data.isEmpty && (!_strictJson || _event != 'error')) return;
    final data = _data.toString();
    _data.clear();
    try {
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object in the SSE frame');
      }
      if (_event != null) json['_event'] = _event;
      _output.add(json);
    } on FormatException catch (error, stackTrace) {
      if (_event == 'error') {
        _output.add({'_event': 'error', '_rawData': data, 'type': 'error'});
      } else if (_strictJson) {
        _output.addError(error, stackTrace);
      }
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    if (_closed) return;
    _closed = true;
    _output
      ..addError(error, stackTrace)
      ..close();
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _flush();
    _output.close();
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
