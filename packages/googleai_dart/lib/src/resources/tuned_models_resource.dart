import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/batch/embed_content_batch.dart';
import '../models/batch/generate_content_batch.dart';
import '../models/generation/generate_content_request.dart';
import '../models/generation/generate_content_response.dart';
import '../models/models/list_tuned_models_response.dart';
import '../models/models/operation.dart';
import '../models/models/tuned_model.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'operations_resource.dart';
import 'permissions_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Tuned Models API.
///
/// Provides access to tuned model operations including content generation,
/// model management, and permissions.
///
/// **Note**: This resource is only available with the Google AI (Gemini) API.
/// Vertex AI has a different tuning API structure.
///
/// See: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/tuning
class TunedModelsResource extends ResourceBase with StreamingResource {
  /// Creates a [TunedModelsResource].
  TunedModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Validates that the Tuned Models API is only used with Google AI.
  void _validateGoogleAIOnly() {
    if (config.apiMode == ApiMode.vertexAI) {
      throw UnsupportedError(
        'Tuned Models API is only available with Google AI (Gemini API). '
        'Vertex AI uses a different tuning API structure. '
        'See: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/tuning',
      );
    }
  }

  /// Generates content using a tuned model.
  ///
  /// The [tunedModel] parameter specifies which tuned model to use (e.g., "my-model-abc123").
  /// The [request] contains the conversation history and generation config.
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Returns a [GenerateContentResponse] containing the model's response.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<GenerateContentResponse> generateContent({
    required String tunedModel,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
  }) async {
    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels/$tunedModel:generateContent',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GenerateContentResponse.fromJson(responseBody);
  }

  /// Generates streaming content using a tuned model.
  ///
  /// The [tunedModel] parameter specifies which tuned model to use (e.g., "my-model-abc123").
  /// The [request] contains the conversation history and generation config.
  /// The optional [abortTrigger] allows canceling the stream.
  ///
  /// Returns a stream of [GenerateContentResponse] chunks.
  ///
  /// If [abortTrigger] completes while streaming, the stream will emit
  /// an [AbortedException] error and close immediately.
  ///
  /// Note: Streaming applies auth and logging interceptors manually since
  /// StreamedResponse cannot go through the full interceptor chain.
  /// This is an **intentional and spec-compliant design** per spec.md line 60-63.
  /// Streaming responses are consumed incrementally, making full chain impossible.
  Stream<GenerateContentResponse> streamGenerateContent({
    required String tunedModel,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
  }) async* {
    // Build URL and headers
    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels/$tunedModel:streamGenerateContent',
      queryParams: {'alt': 'sse'},
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Create request
    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream
    final lineStream = bytesToLines(streamedResponse.stream);
    final jsonStream = parseSSE(lineStream);

    // Get request ID for abortion tracking
    final requestId =
        httpRequest.headers['X-Request-ID'] ?? generateRequestId();

    if (abortTrigger != null) {
      // Monitor abort trigger during streaming
      yield* streamWithAbortMonitoring(
        source: jsonStream,
        abortTrigger: abortTrigger,
        requestId: requestId,
        fromJson: GenerateContentResponse.fromJson,
      );
    } else {
      // No abort trigger, stream normally
      await for (final json in jsonStream) {
        yield GenerateContentResponse.fromJson(json);
      }
    }
  }

  /// Creates a batch of generate content requests using a tuned model.
  ///
  /// The [tunedModel] parameter specifies which tuned model to use (e.g., "my-model-abc123").
  /// The [batch] contains the batch configuration including requests.
  /// If [batch.model] is not set, it will be auto-populated from [tunedModel].
  ///
  /// Returns a [GenerateContentBatch] with the batch job details.
  Future<GenerateContentBatch> batchGenerateContent({
    required String tunedModel,
    required GenerateContentBatch batch,
  }) async {
    // Auto-populate batch.model from method parameter if not set
    final effectiveBatch = batch.model == null
        ? batch.copyWith(model: 'tunedModels/$tunedModel')
        : batch;

    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels/$tunedModel:batchGenerateContent',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'batch': effectiveBatch.toJson()});

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GenerateContentBatch.fromJson(responseBody);
  }

  /// Enqueues a batch of embed content requests for asynchronous processing using a tuned model.
  ///
  /// This is an asynchronous batch operation that returns immediately with
  /// batch metadata. Use [getEmbedBatch], [listBatches], or [LROPoller] to monitor
  /// the batch processing status.
  ///
  /// The [tunedModel] parameter specifies which tuned model to use (e.g., "my-model-abc123").
  /// The [batch] contains the batch configuration including input configuration.
  /// If [batch.model] is not set, it will be auto-populated from [tunedModel].
  ///
  /// Returns an [EmbedContentBatch] with the batch job details including
  /// the batch name which can be used to track progress.
  Future<EmbedContentBatch> asyncBatchEmbedContent({
    required String tunedModel,
    required EmbedContentBatch batch,
  }) async {
    // Auto-populate batch.model from method parameter if not set
    final effectiveBatch = batch.model == null
        ? batch.copyWith(model: 'tunedModels/$tunedModel')
        : batch;

    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels/$tunedModel:asyncBatchEmbedContent',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'batch': effectiveBatch.toJson()});

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return EmbedContentBatch.fromJson(responseBody);
  }

  /// Creates a tuned model.
  ///
  /// The [tunedModel] contains the model configuration and training data.
  /// The optional [tunedModelId] specifies a custom ID for the model.
  ///
  /// Returns an [Operation] that can be polled for completion status.
  Future<Operation> create({
    required TunedModel tunedModel,
    String? tunedModelId,
  }) async {
    _validateGoogleAIOnly();

    final queryParams = <String, String>{'tunedModelId': ?tunedModelId};

    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(tunedModel.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Operation.fromJson(responseBody);
  }

  /// Updates a tuned model.
  ///
  /// The [name] is the resource name of the tuned model.
  /// The [tunedModel] contains the updated model configuration.
  /// The [updateMask] specifies which fields to update.
  ///
  /// Returns the updated [TunedModel].
  Future<TunedModel> patch({
    required String name,
    required TunedModel tunedModel,
    String? updateMask,
  }) async {
    _validateGoogleAIOnly();

    final queryParams = <String, String>{'updateMask': ?updateMask};

    final url = requestBuilder.buildUrl(
      '/{version}/$name',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(tunedModel.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return TunedModel.fromJson(responseBody);
  }

  /// Deletes a tuned model.
  ///
  /// The [name] is the resource name of the tuned model to delete.
  Future<void> delete({required String name}) async {
    _validateGoogleAIOnly();

    final url = requestBuilder.buildUrl('/{version}/$name');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Lists created tuned models.
  ///
  /// The [pageSize] parameter specifies the maximum number of tuned models to return
  /// (default is 10, max is 1000). The [pageToken] is used for pagination.
  /// The [filter] allows filtering by ownership or sharing status (e.g., "owner:me", "readers:everyone").
  ///
  /// Returns a [ListTunedModelsResponse] with the list of tuned models and a next page token.
  Future<ListTunedModelsResponse> list({
    int? pageSize,
    String? pageToken,
    String? filter,
  }) async {
    _validateGoogleAIOnly();

    final queryParams = <String, String>{
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
      'filter': ?filter,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/tunedModels',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListTunedModelsResponse.fromJson(responseBody);
  }

  /// Gets information about a specific tuned model.
  ///
  /// The [name] is the resource name of the tuned model (e.g., "tunedModels/my-model").
  ///
  /// Returns a [TunedModel] with the model's details.
  Future<TunedModel> get({required String name}) async {
    _validateGoogleAIOnly();

    final url = requestBuilder.buildUrl('/{version}/$name');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return TunedModel.fromJson(responseBody);
  }

  /// Access operations for this tuned model.
  OperationsResource operations({required String tunedModel}) {
    return OperationsResource(
      parent: 'tunedModels/$tunedModel',
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }

  /// Access permissions for this tuned model or corpus.
  PermissionsResource permissions({required String parent}) {
    return PermissionsResource(
      parent: parent,
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
    );
  }
}
