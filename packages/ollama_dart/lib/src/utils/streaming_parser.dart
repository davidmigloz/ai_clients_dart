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
