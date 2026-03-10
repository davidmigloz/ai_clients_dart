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
  Stream<Map<String, dynamic>> parse(Stream<List<int>> bytes) async* {
    final lines = bytes.transform(utf8.decoder).transform(const LineSplitter());

    String? currentEvent;
    final dataBuffer = StringBuffer();

    await for (final line in lines) {
      // Skip comment lines (keep-alive)
      if (line.startsWith(':')) {
        continue;
      }

      if (line.startsWith('event:')) {
        currentEvent = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        final data = line.substring(5).trim();
        if (dataBuffer.isNotEmpty) dataBuffer.write('\n');
        dataBuffer.write(data);
      } else if (line.isEmpty && dataBuffer.isNotEmpty) {
        // Empty line signals end of event
        final data = dataBuffer.toString();
        dataBuffer.clear();

        if (data.isNotEmpty && data != '[DONE]') {
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            // Include event type in parsed data if available
            if (currentEvent != null) {
              json['_event'] = currentEvent;
            }
            yield json;
          } catch (_) {
            if (currentEvent == 'error') {
              yield <String, dynamic>{'_event': 'error', '_rawData': data};
            }
          }
        }

        currentEvent = null;
      }
    }

    // Handle any remaining data
    if (dataBuffer.isNotEmpty) {
      final data = dataBuffer.toString();
      if (data.isNotEmpty && data != '[DONE]') {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          if (currentEvent != null) {
            json['_event'] = currentEvent;
          }
          yield json;
        } catch (_) {
          if (currentEvent == 'error') {
            yield <String, dynamic>{'_event': 'error', '_rawData': data};
          }
        }
      }
    }
  }
}

/// Extension to handle SSE event types.
extension SseEventExtension on Map<String, dynamic> {
  /// Gets the SSE event type if available.
  String? get sseEventType => this['_event'] as String?;

  /// Creates a copy without the internal event type field.
  Map<String, dynamic> withoutEventType() {
    return Map<String, dynamic>.from(this)
      ..remove('_event')
      ..remove('_rawData');
  }
}
