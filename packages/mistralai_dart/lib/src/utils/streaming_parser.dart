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
  final buffer = StringBuffer();

  await for (final chunk in byteStream.transform(utf8.decoder)) {
    buffer.write(chunk);
    final content = buffer.toString();
    final lines = content.split('\n');

    // Keep the last potentially incomplete line in the buffer
    buffer.clear();
    if (!content.endsWith('\n')) {
      buffer.write(lines.removeLast());
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('data: ')) {
        final data = trimmed.substring(6).trim();

        // Check for stream end marker
        if (data == '[DONE]') {
          return;
        }

        if (data.isNotEmpty) {
          try {
            yield jsonDecode(data) as Map<String, dynamic>;
          } catch (_) {
            // Skip malformed JSON
          }
        }
      }
    }
  }
}

/// Parses a stream of bytes as SSE and converts to typed objects.
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
Stream<Map<String, dynamic>> parseNDJSON(Stream<List<int>> byteStream) {
  return byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty)
      .map((line) => jsonDecode(line) as Map<String, dynamic>);
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
) {
  return byteStream
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty)
      .map((line) => fromJson(jsonDecode(line) as Map<String, dynamic>));
}

/// Transforms a byte stream to lines.
///
/// Handles partial lines at chunk boundaries.
Stream<String> bytesToLines(Stream<List<int>> byteStream) {
  return byteStream.transform(utf8.decoder).transform(const LineSplitter());
}
