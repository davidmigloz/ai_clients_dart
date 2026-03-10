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
Stream<Map<String, dynamic>> parseSSE(Stream<List<int>> byteStream) async* {
  final lines = byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  String? currentEvent;
  final dataBuffer = StringBuffer();

  await for (final line in lines) {
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
) async* {
  await for (final json in parseSSE(byteStream)) {
    yield fromJson(json);
  }
}

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
Stream<Map<String, dynamic>> parseNDJSON(Stream<List<int>> byteStream) async* {
  final lines = byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty);

  await for (final line in lines) {
    try {
      yield jsonDecode(line) as Map<String, dynamic>;
    } catch (_) {
      // Skip malformed JSON lines
    }
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
) async* {
  await for (final json in parseNDJSON(byteStream)) {
    yield fromJson(json);
  }
}

/// Transforms a byte stream to lines.
///
/// Handles partial lines at chunk boundaries.
Stream<String> bytesToLines(Stream<List<int>> byteStream) {
  return byteStream.transform(utf8.decoder).transform(const LineSplitter());
}
