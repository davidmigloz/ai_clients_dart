import 'dart:async';
import 'dart:convert';

/// Parses a stream of bytes as newline-delimited JSON (NDJSON).
///
/// Ollama uses NDJSON for streaming responses where each line is a
/// complete JSON object.
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
