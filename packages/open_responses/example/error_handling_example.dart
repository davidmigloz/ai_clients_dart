// ignore_for_file: avoid_print
import 'dart:io';

import 'package:open_responses/open_responses.dart';

/// Error handling example using the OpenResponses API.
///
/// This example demonstrates:
/// - Catching rate limit failures explicitly
/// - Handling generic provider API errors
/// - Falling back to the base client exception type
///
/// Set the OPENAI_API_KEY environment variable before running.
Future<void> main() async {
  final client = OpenResponsesClient(
    config: OpenResponsesConfig(
      baseUrl: 'https://api.openai.com/v1',
      authProvider: BearerTokenProvider(
        Platform.environment['OPENAI_API_KEY'] ?? '',
      ),
    ),
  );

  try {
    final response = await client.responses.create(
      const CreateResponseRequest(
        model: 'gpt-4o-mini',
        input: ResponseTextInput('Return a one-word health check response.'),
      ),
    );

    print('Response: ${response.outputText}');
  } on RateLimitException catch (error) {
    stderr.writeln('Retry after: ${error.retryAfter}');
  } on ApiException catch (error) {
    stderr.writeln('Provider API error ${error.statusCode}: ${error.message}');
  } on OpenResponsesException catch (error) {
    stderr.writeln('OpenResponses client error: $error');
  } finally {
    client.close();
  }
}
