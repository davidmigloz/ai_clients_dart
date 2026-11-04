import 'dart:async';
import 'dart:convert';

/// Parses a stream of bytes as newline-delimited JSON (NDJSON).
///
/// Ollama uses NDJSON for streaming responses where each line is a
/// complete JSON object.
///
/// Example:
/// ```dart
/// Future<void> consumeJson(Stream<List<int>> bytes) async {
///   await for (final json in parseNDJSON(bytes)) {
///     print(json); // Each line is parsed as Map<String, dynamic>.
///   }
/// }
/// ```
Stream<Map<String, dynamic>> parseNDJSON(Stream<List<int>> byteStream) {
  return bytesToLines(byteStream).transform(
    StreamTransformer<String, Map<String, dynamic>>.fromHandlers(
      handleData: (line, sink) {
        if (line.isEmpty) return;
        try {
          sink.add(jsonDecode(line) as Map<String, dynamic>);
        } catch (_) {
          // Skip malformed JSON lines.
        }
      },
      handleError: (error, trace, sink) {
        sink
          ..addError(error, trace)
          ..close();
      },
    ),
  );
}

/// Parses a stream of bytes as NDJSON and converts to typed objects.
///
/// Example:
/// ```dart
/// Stream<ChatStreamEvent> decodeChat(Stream<List<int>> bytes) =>
///     parseNDJSONAs<ChatStreamEvent>(bytes, ChatStreamEvent.fromJson);
/// ```
Stream<T> parseNDJSONAs<T>(
  Stream<List<int>> byteStream,
  T Function(Map<String, dynamic>) fromJson,
) {
  return parseNDJSON(byteStream).transform(
    StreamTransformer<Map<String, dynamic>, T>.fromHandlers(
      handleData: (json, sink) {
        try {
          sink.add(fromJson(json));
        } catch (error, trace) {
          sink
            ..addError(error, trace)
            ..close();
        }
      },
      handleError: (error, trace, sink) {
        sink
          ..addError(error, trace)
          ..close();
      },
    ),
  );
}

/// Transforms a byte stream to lines.
///
/// Handles partial lines at chunk boundaries.
Stream<String> bytesToLines(Stream<List<int>> byteStream) {
  return byteStream.transform(utf8.decoder).transform(const LineSplitter());
}
