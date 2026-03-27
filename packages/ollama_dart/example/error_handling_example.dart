// ignore_for_file: avoid_print
import 'package:ollama_dart/ollama_dart.dart';

/// Error handling example using the Ollama Dart client.
///
/// This example demonstrates:
/// - Catching rate limit failures explicitly
/// - Handling generic API errors
/// - Falling back to the base client exception type
///
/// Make sure you have an Ollama server running before executing.
Future<void> main() async {
  final client = OllamaClient();

  try {
    final response = await client.chat.create(
      request: const ChatRequest(
        model: 'llama3.2',
        messages: [
          ChatMessage.user('Return a one-word health check response.'),
        ],
      ),
    );

    print('Response: ${response.message?.content}');
  } on RateLimitException catch (error) {
    print('Rate limited — retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    print('API error ${error.statusCode}: ${error.message}');
  } on OllamaException catch (error) {
    print('Ollama client error: $error');
  } finally {
    client.close();
  }
}
