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
  Stream<Map<String, dynamic>> parse(Stream<List<int>> bytes) async* {
    final lines = bytes.transform(utf8.decoder).transform(const LineSplitter());

    String? currentEvent;
    final dataBuffer = StringBuffer();

    await for (final line in lines) {
      if (line.startsWith('event:')) {
        // Event type (optional in OpenAI responses)
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        // Data line
        final data = line.substring(5).trim();

        // Check for end-of-stream marker — flush any buffered data first
        if (data == '[DONE]') {
          if (dataBuffer.isNotEmpty) {
            final buffered = dataBuffer.toString();
            dataBuffer.clear();
            if (buffered.isNotEmpty) {
              try {
                final json = jsonDecode(buffered) as Map<String, dynamic>;
                if (currentEvent != null) {
                  json['_event'] = currentEvent;
                }
                yield json;
              } catch (_) {
                if (currentEvent == 'error') {
                  yield <String, dynamic>{
                    '_event': 'error',
                    '_rawData': buffered,
                    'type': 'error',
                  };
                }
              }
            }
          }
          return;
        }

        if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
        dataBuffer.write(data);
      } else if (line.isEmpty) {
        // Empty line signals end of event
        if (dataBuffer.isNotEmpty) {
          final data = dataBuffer.toString();
          dataBuffer.clear();

          if (data.isNotEmpty) {
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              // Include event type in parsed data if available
              if (currentEvent != null) {
                json['_event'] = currentEvent;
              }
              yield json;
            } catch (_) {
              if (currentEvent == 'error') {
                yield <String, dynamic>{
                  '_event': 'error',
                  '_rawData': data,
                  'type': 'error',
                };
              }
            }
          }
        }

        currentEvent = null;
      }
    }

    // Handle any remaining data
    if (dataBuffer.isNotEmpty) {
      final data = dataBuffer.toString();
      if (data.isNotEmpty) {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          if (currentEvent != null) {
            json['_event'] = currentEvent;
          }
          yield json;
        } catch (_) {
          if (currentEvent == 'error') {
            yield <String, dynamic>{
              '_event': 'error',
              '_rawData': data,
              'type': 'error',
            };
          }
        }
      }
    }
  }

  /// Parses a byte stream and yields raw SSE events.
  ///
  /// Unlike [parse], this method returns [SseEvent] objects that
  /// preserve the event type and raw data separately.
  Stream<SseEvent> parseRaw(Stream<List<int>> bytes) async* {
    final lines = bytes.transform(utf8.decoder).transform(const LineSplitter());

    String? currentEvent;
    final dataBuffer = StringBuffer();
    String? id;
    int? retry;

    await for (final line in lines) {
      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        final data = line.substring(5).trim();

        // Check for end-of-stream marker — flush any buffered data first
        if (data == '[DONE]') {
          if (dataBuffer.isNotEmpty) {
            yield SseEvent(
              event: currentEvent,
              data: dataBuffer.toString(),
              id: id,
              retry: retry,
            );
            dataBuffer.clear();
          }
          yield const SseEvent(event: 'done', data: '[DONE]');
          return;
        }

        if (dataBuffer.isNotEmpty) {
          dataBuffer.write('\n');
        }
        dataBuffer.write(data);
      } else if (line.startsWith('id:')) {
        id = line.substring(3).trim();
      } else if (line.startsWith('retry:')) {
        retry = int.tryParse(line.substring(6).trim());
      } else if (line.isEmpty) {
        // Empty line signals end of event
        if (dataBuffer.isNotEmpty) {
          yield SseEvent(
            event: currentEvent,
            data: dataBuffer.toString(),
            id: id,
            retry: retry,
          );
          dataBuffer.clear();
        }

        currentEvent = null;
        id = null;
        retry = null;
      }
    }

    // Handle any remaining data
    if (dataBuffer.isNotEmpty) {
      yield SseEvent(
        event: currentEvent,
        data: dataBuffer.toString(),
        id: id,
        retry: retry,
      );
    }
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
