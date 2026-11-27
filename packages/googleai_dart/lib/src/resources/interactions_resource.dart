import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/common/service_tier.dart';
import '../models/interactions/agent_config.dart';
import '../models/interactions/environments/environments.dart';
import '../models/interactions/events/events.dart';
import '../models/interactions/generation_config.dart';
import '../models/interactions/interaction.dart';
import '../models/interactions/interaction_input.dart';
import '../models/interactions/response_formats/response_formats.dart';
import '../models/interactions/response_modality.dart';
import '../models/interactions/safety_setting.dart';
import '../models/interactions/tools/tools.dart';
import '../models/interactions/webhook_config.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Interactions API.
///
/// The Interactions API supports server-side conversation state, tool calls,
/// background execution, and streaming responses. Select stable Gemini
/// Developer API Interactions with [GoogleAIConfig.interactionsApiVersion].
class InteractionsResource extends ResourceBase with StreamingResource {
  /// Creates an [InteractionsResource].
  InteractionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  // Keep the existing revision header on beta requests for gateways that
  // use it to select the steps schema. Stable requests use that schema by
  // default.
  static const _betaApiRevision = '2026-05-20';

  ApiVersion get _apiVersion =>
      config.interactionsApiVersion ?? config.apiVersion;

  Uri _buildUrl(String path, {Map<String, String>? queryParams}) =>
      requestBuilder.buildUrl(
        '/{version}/interactions$path',
        apiVersion: _apiVersion,
        queryParams: queryParams,
      );

  Map<String, String> _buildHeaders({bool json = false, bool sse = false}) =>
      requestBuilder.buildHeaders(
        additionalHeaders: {
          if (json) 'Content-Type': 'application/json',
          if (sse) 'Accept': 'text/event-stream',
          if (_apiVersion == ApiVersion.v1beta)
            'Api-Revision': _betaApiRevision,
        },
      );

  /// Creates a new interaction with a Gemini model.
  ///
  /// Use [previousInteractionId] to continue a stored conversation. Set [store]
  /// to false for a stateless request. [background] enables asynchronous
  /// execution on supported models and requires server-side storage.
  ///
  /// The stable Gemini Developer API uses [responseFormat] for output options.
  /// [responseModalities] and [responseMimeType] are legacy beta parameters.
  Future<Interaction> create({
    required String model,
    InteractionInput? input,
    String? systemInstruction,
    List<InteractionTool>? tools,
    InteractionGenerationConfig? generationConfig,
    List<InteractionResponseModality>? responseModalities,
    String? responseMimeType,
    InteractionResponseFormatConfig? responseFormat,
    String? previousInteractionId,
    bool? background,
    EnvironmentConfigOrId? environment,
    WebhookConfig? webhookConfig,
    bool? store,
    ServiceTier? serviceTier,
    List<InteractionSafetySetting>? safetySettings,
    Map<String, String>? labels,
  }) => _sendCreate(
    () => _buildCreateBody(
      model: model,
      input: input,
      systemInstruction: systemInstruction,
      tools: tools,
      generationConfig: generationConfig,
      responseModalities: responseModalities,
      responseMimeType: responseMimeType,
      responseFormat: responseFormat,
      previousInteractionId: previousInteractionId,
      background: background,
      environment: environment,
      webhookConfig: webhookConfig,
      store: store,
      serviceTier: serviceTier,
      safetySettings: safetySettings,
      labels: labels,
    ),
  );

  /// Creates an interaction with an agent.
  ///
  /// [agent] names a supported managed agent, for example
  /// `deep-research-preview-04-2026`. Agent, environment, and webhook
  /// availability depend on the backend and configured API version.
  Future<Interaction> createWithAgent({
    required String agent,
    InteractionInput? input,
    AgentConfig? agentConfig,
    InteractionResponseFormatConfig? responseFormat,
    String? previousInteractionId,
    bool? background,
    EnvironmentConfigOrId? environment,
    WebhookConfig? webhookConfig,
    String? systemInstruction,
    List<InteractionTool>? tools,
    bool? store,
    ServiceTier? serviceTier,
    List<InteractionSafetySetting>? safetySettings,
    Map<String, String>? labels,
  }) => _sendCreate(
    () => _buildCreateBody(
      agent: agent,
      input: input,
      agentConfig: agentConfig,
      responseFormat: responseFormat,
      previousInteractionId: previousInteractionId,
      background: background,
      environment: environment,
      webhookConfig: webhookConfig,
      systemInstruction: systemInstruction,
      tools: tools,
      store: store,
      serviceTier: serviceTier,
      safetySettings: safetySettings,
      labels: labels,
    ),
  );

  /// Gets an interaction by ID.
  ///
  /// Pass [includeInput] to control whether to request the original input
  /// explicitly. Omit it to use the server's behavior for the selected API
  /// version.
  Future<Interaction> get(String id, {bool? includeInput}) =>
      _sendInteractionRequest(() {
        final url = _buildUrl(
          '/$id',
          queryParams: {
            if (includeInput != null) 'include_input': '$includeInput',
          },
        );
        return http.Request('GET', url)..headers.addAll(_buildHeaders());
      });

  /// Cancels an in-progress background interaction.
  ///
  /// Returns the canceled [Interaction].
  Future<Interaction> cancel(String id) => _sendInteractionRequest(
    () =>
        http.Request('POST', _buildUrl('/$id/cancel'))
          ..headers.addAll(_buildHeaders(json: true)),
  );

  /// Deletes an interaction by ID.
  Future<void> delete(String id) async {
    final request = http.Request('DELETE', _buildUrl('/$id'))
      ..headers.addAll(_buildHeaders());
    await interceptorChain.execute(request);
  }

  /// Creates a streaming interaction with a Gemini model.
  ///
  /// Use [abortTrigger] to cancel the local request and response stream. For a
  /// background interaction, use [cancel] to stop server-side execution.
  /// The stable Gemini Developer API uses [responseFormat] for output options.
  /// [responseModalities] and [responseMimeType] are legacy beta parameters.
  Stream<InteractionEvent> createStream({
    required String model,
    InteractionInput? input,
    String? systemInstruction,
    List<InteractionTool>? tools,
    InteractionGenerationConfig? generationConfig,
    List<InteractionResponseModality>? responseModalities,
    String? responseMimeType,
    InteractionResponseFormatConfig? responseFormat,
    String? previousInteractionId,
    EnvironmentConfigOrId? environment,
    bool? background,
    WebhookConfig? webhookConfig,
    bool? store,
    ServiceTier? serviceTier,
    List<InteractionSafetySetting>? safetySettings,
    Map<String, String>? labels,
    Future<void>? abortTrigger,
  }) => _sendCreateStream(
    () => _buildCreateBody(
      model: model,
      input: input,
      systemInstruction: systemInstruction,
      tools: tools,
      generationConfig: generationConfig,
      responseModalities: responseModalities,
      responseMimeType: responseMimeType,
      responseFormat: responseFormat,
      previousInteractionId: previousInteractionId,
      environment: environment,
      background: background,
      webhookConfig: webhookConfig,
      store: store,
      serviceTier: serviceTier,
      safetySettings: safetySettings,
      labels: labels,
    ),
    abortTrigger: abortTrigger,
  );

  /// Creates a streaming interaction with an agent.
  ///
  /// [input] supplies the prompt or content for the agent.
  ///
  /// [background] lets supported agents continue on the server after the
  /// stream disconnects. Use [resumeStream] with the interaction ID to attach
  /// again. [abortTrigger] cancels the local stream and [cancel] stops the
  /// background interaction on the server.
  Stream<InteractionEvent> createWithAgentStream({
    required String agent,
    required InteractionInput input,
    AgentConfig? agentConfig,
    InteractionResponseFormatConfig? responseFormat,
    String? previousInteractionId,
    bool? background,
    EnvironmentConfigOrId? environment,
    WebhookConfig? webhookConfig,
    String? systemInstruction,
    List<InteractionTool>? tools,
    bool? store,
    ServiceTier? serviceTier,
    List<InteractionSafetySetting>? safetySettings,
    Map<String, String>? labels,
    Future<void>? abortTrigger,
  }) => _sendCreateStream(
    () => _buildCreateBody(
      agent: agent,
      input: input,
      agentConfig: agentConfig,
      responseFormat: responseFormat,
      previousInteractionId: previousInteractionId,
      background: background,
      environment: environment,
      webhookConfig: webhookConfig,
      systemInstruction: systemInstruction,
      tools: tools,
      store: store,
      serviceTier: serviceTier,
      safetySettings: safetySettings,
      labels: labels,
    ),
    abortTrigger: abortTrigger,
  );

  /// Resumes a streaming interaction from a specific event.
  ///
  /// [lastEventId] identifies the last event already received. The server
  /// starts with the next event. [abortTrigger] cancels the local stream.
  Stream<InteractionEvent> resumeStream(
    String id, {
    String? lastEventId,
    bool? includeInput,
    Future<void>? abortTrigger,
  }) => streamRequest(
    createRequest: () {
      final url = _buildUrl(
        '/$id',
        queryParams: {
          'stream': 'true',
          if (_apiVersion == ApiVersion.v1beta) 'alt': 'sse',
          'last_event_id': ?lastEventId,
          if (includeInput != null) 'include_input': '$includeInput',
        },
      );
      return http.Request('GET', url)..headers.addAll(_buildHeaders(sse: true));
    },
    abortTrigger: abortTrigger,
    fromJson: InteractionEvent.fromJson,
  );

  Map<String, dynamic> _buildCreateBody({
    String? model,
    String? agent,
    InteractionInput? input,
    String? systemInstruction,
    List<InteractionTool>? tools,
    InteractionGenerationConfig? generationConfig,
    AgentConfig? agentConfig,
    List<InteractionResponseModality>? responseModalities,
    String? responseMimeType,
    InteractionResponseFormatConfig? responseFormat,
    String? previousInteractionId,
    bool? background,
    EnvironmentConfigOrId? environment,
    WebhookConfig? webhookConfig,
    bool? store,
    ServiceTier? serviceTier,
    List<InteractionSafetySetting>? safetySettings,
    Map<String, String>? labels,
  }) => {
    'model': ?model,
    'agent': ?agent,
    if (input != null) 'input': input.toJson(),
    'system_instruction': ?systemInstruction,
    if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
    if (generationConfig != null)
      'generation_config': generationConfig.toJson(),
    if (agentConfig != null) 'agent_config': agentConfig.toJson(),
    if (responseModalities != null)
      'response_modalities': responseModalities
          .map(interactionResponseModalityToString)
          .toList(),
    'response_mime_type': ?responseMimeType,
    if (responseFormat != null) 'response_format': responseFormat.toJson(),
    'previous_interaction_id': ?previousInteractionId,
    'background': ?background,
    if (environment != null) 'environment': environment.toJson(),
    if (webhookConfig != null) 'webhook_config': webhookConfig.toJson(),
    'store': ?store,
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier),
    if (safetySettings != null)
      'safety_settings': safetySettings
          .map((setting) => setting.toJson())
          .toList(),
    'labels': ?labels,
  };

  http.Request _buildCreateRequest(
    Map<String, dynamic> body, {
    bool stream = false,
  }) {
    final url = _buildUrl(
      '',
      queryParams: stream && _apiVersion == ApiVersion.v1beta
          ? const {'alt': 'sse'}
          : null,
    );
    return http.Request('POST', url)
      ..headers.addAll(_buildHeaders(json: true, sse: stream))
      ..body = jsonEncode(stream ? {...body, 'stream': true} : body);
  }

  Future<Interaction> _sendInteractionRequest(
    http.Request Function() buildRequest,
  ) async {
    final response = await interceptorChain.execute(buildRequest());
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return Interaction.fromJson(body);
  }

  Future<Interaction> _sendCreate(Map<String, dynamic> Function() buildBody) =>
      _sendInteractionRequest(() => _buildCreateRequest(buildBody()));

  Stream<InteractionEvent> _sendCreateStream(
    Map<String, dynamic> Function() buildBody, {
    Future<void>? abortTrigger,
  }) => streamRequest(
    createRequest: () => _buildCreateRequest(buildBody(), stream: true),
    abortTrigger: abortTrigger,
    fromJson: InteractionEvent.fromJson,
  );
}
