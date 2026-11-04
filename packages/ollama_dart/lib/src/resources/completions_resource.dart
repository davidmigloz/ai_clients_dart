import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/completions/generate_request.dart';
import '../models/completions/generate_response.dart';
import '../models/completions/generate_stream_event.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Generate Completions API.
///
/// Provides text completion generation with optional streaming.
class CompletionsResource extends ResourceBase with StreamingResource {
  /// Creates a [CompletionsResource].
  CompletionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Generates a completion for the given prompt.
  ///
  /// The [request] contains the model, prompt, and generation settings.
  ///
  /// Returns a [GenerateResponse] containing the generated text.
  Future<GenerateResponse> generate({required GenerateRequest request}) async {
    final url = requestBuilder.buildUrl('/api/generate');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GenerateResponse.fromJson(responseBody);
  }

  /// Generates a completion with streaming.
  ///
  /// The [request] contains the model, prompt, and generation settings.
  ///
  /// Returns a stream of [GenerateStreamEvent] chunks.
  /// The optional [abortTrigger] cancels the request and response stream.
  Stream<GenerateStreamEvent> generateStream({
    required GenerateRequest request,
    Future<void>? abortTrigger,
  }) {
    return streamRequest(
      createRequest: () {
        final url = requestBuilder.buildUrl('/api/generate');

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Ensure stream is true for streaming
        final requestData = request.copyWith(stream: true);

        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(requestData.toJson());
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      fromJson: GenerateStreamEvent.fromJson,
    );
  }
}
