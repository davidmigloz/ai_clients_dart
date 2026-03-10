import 'dart:async';
import 'dart:convert';

/// Parses an SSE (Server-Sent Events) stream into a stream of JSON objects.
///
/// Implements parsing according to the WHATWG SSE specification:
/// https://html.spec.whatwg.org/multipage/server-sent-events.html
///
/// SSE Format: Each line can be one of:
/// - `data: value` (standard format with space after colon)
/// - `data:value` (format without space, used by some providers)
/// - `data:[DONE]` (termination signal, filtered out)
///
/// Per the WHATWG spec, the space after the colon is optional. When present,
/// exactly one leading space should be removed from the value. We use `.trim()`
/// to handle both formats and any additional whitespace variations robustly.
///
/// This parser:
/// 1. Tracks `event:` lines to identify event types
/// 2. Buffers `data:` lines until an empty line signals end of event
/// 3. Parses the buffered data as JSON and yields the resulting map
/// 4. For `event: error` with non-JSON data, yields a synthetic JSON map
/// 5. Gracefully skips other malformed JSON lines
Stream<Map<String, dynamic>> parseSSE(Stream<String> stream) async* {
  String? currentEvent;
  final dataBuffer = StringBuffer();

  await for (final line in stream) {
    if (line.startsWith('event:')) {
      currentEvent = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      final data = line.substring(5).trim();
      // Check for stream end marker — flush any buffered data first
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

/// Parses an NDJSON stream into a stream of JSON objects.
Stream<Map<String, dynamic>> parseNDJSON(Stream<String> stream) async* {
  await for (final line in stream) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty) {
      try {
        yield jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {
        // Skip malformed JSON
      }
    }
  }
}

/// Converts a byte stream to a line stream.
Stream<String> bytesToLines(Stream<List<int>> byteStream) {
  return byteStream
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter());
}
