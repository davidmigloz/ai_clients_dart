import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/interactions/agent_config.dart';
import '../models/interactions/events/events.dart';
import '../models/interactions/generation_config.dart';
import '../models/interactions/interaction.dart';
import '../models/interactions/interaction_input.dart';
import '../models/interactions/response_modality.dart';
import '../models/interactions/tools/tools.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Interactions API.
///
/// The Interactions API provides server-side state management for conversations
/// with Gemini models. It enables multi-turn conversations with managed state,
/// function calling with automatic result handling, and streaming responses.
///
/// This is an experimental API and is subject to change.
class InteractionsResource extends ResourceBase with StreamingResource {
  /// Creates an [InteractionsResource].
  InteractionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new interaction.
  ///
  /// The [model] specifies which model to use (e.g., "gemini-3.1-flash-preview").
  /// The [input] can be a [TextInput], a [ContentListInput],
  /// a [TurnsInput], or a [SingleContentInput].
  ///
  /// Returns the [Interaction] with the model's response.
  Future<Interaction> create({
    required String model,
    InteractionInput? input,
    String? systemInstruction,
    List<InteractionTool>? tools,
    InteractionGenerationConfig? generationConfig,
    List<InteractionResponseModality>? responseModalities,
    String? responseMimeType,
    String? previousInteractionId,
    bool? background,
  }) async {
    final url = requestBuilder.buildUrl('/{version}/interactions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{
      'model': model,
      if (input != null) 'input': input.toJson(),
      'system_instruction': ?systemInstruction,
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (generationConfig != null)
        'generation_config': generationConfig.toJson(),
      if (responseModalities != null)
        'response_modalities': responseModalities
            .map(interactionResponseModalityToString)
            .toList(),
      'response_mime_type': ?responseMimeType,
      'previous_interaction_id': ?previousInteractionId,
      'background': ?background,
    };

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Interaction.fromJson(responseBody);
  }

  /// Creates an interaction with an agent.
  ///
  /// The [agent] specifies which agent to use (e.g., "deep-research-pro-preview-12-2025").
  ///
  /// Returns the [Interaction] with the agent's response.
  Future<Interaction> createWithAgent({
    required String agent,
    InteractionInput? input,
    AgentConfig? agentConfig,
    String? previousInteractionId,
    bool? background,
  }) async {
    final url = requestBuilder.buildUrl('/{version}/interactions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{
      'agent': agent,
      if (input != null) 'input': input.toJson(),
      if (agentConfig != null) 'agent_config': agentConfig.toJson(),
      'previous_interaction_id': ?previousInteractionId,
      'background': ?background,
    };

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Interaction.fromJson(responseBody);
  }

  /// Gets an interaction by ID.
  ///
  /// If [includeInput] is true, the response includes the input that was
  /// sent with the interaction.
  ///
  /// Returns the [Interaction] with its current state and outputs.
  Future<Interaction> get(String id, {bool? includeInput}) async {
    final queryParams = <String, String>{
      if (includeInput ?? false) 'include_input': 'true',
    };

    final url = requestBuilder.buildUrl(
      '/{version}/interactions/$id',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Interaction.fromJson(responseBody);
  }

  /// Cancels an in-progress interaction.
  ///
  /// This only applies to background interactions that are still running.
  ///
  /// Returns the cancelled [Interaction].
  Future<Interaction> cancel(String id) async {
    final url = requestBuilder.buildUrl('/{version}/interactions/$id/cancel');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Interaction.fromJson(responseBody);
  }

  /// Deletes an interaction.
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/interactions/$id');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Creates a streaming interaction.
  ///
  /// Returns a stream of [InteractionEvent]s as the model generates the response.
  Stream<InteractionEvent> createStream({
    required String model,
    InteractionInput? input,
    String? systemInstruction,
    List<InteractionTool>? tools,
    InteractionGenerationConfig? generationConfig,
    List<InteractionResponseModality>? responseModalities,
    String? responseMimeType,
    String? previousInteractionId,
  }) async* {
    final url = requestBuilder.buildUrl(
      '/{version}/interactions',
      queryParams: {'stream': 'true', 'alt': 'sse'},
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{
      'model': model,
      if (input != null) 'input': input.toJson(),
      'system_instruction': ?systemInstruction,
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (generationConfig != null)
        'generation_config': generationConfig.toJson(),
      if (responseModalities != null)
        'response_modalities': responseModalities
            .map(interactionResponseModalityToString)
            .toList(),
      'response_mime_type': ?responseMimeType,
      'previous_interaction_id': ?previousInteractionId,
    };

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    final lineStream = bytesToLines(streamedResponse.stream);
    final jsonStream = parseSSE(lineStream);

    await for (final json in jsonStream) {
      yield InteractionEvent.fromJson(json);
    }
  }

  /// Resumes a streaming interaction from a specific event.
  ///
  /// The [lastEventId] is used to resume from the next event after the one
  /// with that ID.
  Stream<InteractionEvent> resumeStream(
    String id, {
    String? lastEventId,
  }) async* {
    final queryParams = <String, String>{
      'stream': 'true',
      'alt': 'sse',
      'last_event_id': ?lastEventId,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/interactions/$id',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    var httpRequest = http.Request('GET', url)..headers.addAll(headers);

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    final lineStream = bytesToLines(streamedResponse.stream);
    final jsonStream = parseSSE(lineStream);

    await for (final json in jsonStream) {
      yield InteractionEvent.fromJson(json);
    }
  }
}
