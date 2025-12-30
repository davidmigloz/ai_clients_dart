import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/completions/generate_request.dart';
import '../models/completions/generate_response.dart';
import '../models/completions/generate_stream_event.dart';
import '../utils/streaming_parser.dart';
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
  Stream<GenerateStreamEvent> generateStream({
    required GenerateRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/api/generate');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse NDJSON stream
    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield GenerateStreamEvent.fromJson(json);
    }
  }
}
