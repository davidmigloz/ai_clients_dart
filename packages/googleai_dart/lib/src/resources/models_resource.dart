import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../errors/exceptions.dart';
import '../models/batch/embed_content_batch.dart';
import '../models/batch/generate_content_batch.dart';
import '../models/content/candidate.dart';
import '../models/content/citation_metadata.dart';
import '../models/content/content.dart';
import '../models/content/logprobs_result.dart';
import '../models/content/part.dart';
import '../models/embeddings/batch_embed_contents_request.dart';
import '../models/embeddings/batch_embed_contents_response.dart';
import '../models/embeddings/content_embedding.dart';
import '../models/embeddings/embed_content_request.dart';
import '../models/embeddings/embed_content_response.dart';
import '../models/embeddings/task_type.dart';
import '../models/generation/count_tokens_request.dart';
import '../models/generation/count_tokens_response.dart';
import '../models/generation/generate_answer_request.dart';
import '../models/generation/generate_answer_response.dart';
import '../models/generation/generate_content_request.dart';
import '../models/generation/generate_content_response.dart';
import '../models/metadata/finish_reason.dart';
import '../models/metadata/grounding_metadata.dart';
import '../models/metadata/modality_token_count.dart';
import '../models/metadata/usage_metadata.dart';
import '../models/models/list_models_response.dart';
import '../models/models/model.dart';
import '../models/prediction/predict_long_running_operation.dart';
import '../models/prediction/predict_long_running_request.dart';
import '../models/prediction/predict_request.dart';
import '../models/prediction/predict_response.dart';
import '../models/safety/safety_rating.dart';
import '../utils/redactor.dart';
import 'base_resource.dart';
import 'continuation_abort.dart';
import 'generate_content_validation.dart';
import 'operations_resource.dart';
import 'streaming_resource.dart';

part 'generate_content_continuation.dart';

/// Resource for the Models API.
///
/// Provides access to model-related operations including content generation,
/// token counting, embeddings, and model information retrieval.
class ModelsResource extends ResourceBase with StreamingResource {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Generates content using the specified model.
  ///
  /// The [request] contains conversation history and generation config.
  /// Set [automaticContinuation] to follow long-decode checkpoints on a
  /// supported model. The response combines candidate parts and usage across
  /// hops. The configured timeout and [abortTrigger] cover the entire call.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<GenerateContentResponse> generateContent({
    required String model,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
    bool automaticContinuation = false,
  }) {
    if (automaticContinuation) {
      return _continueGenerateContent(
        request,
        (body, checkpoints, abort) => _sendGenerateContent(
          model,
          () => body,
          abortTrigger: abort.future,
          checkActive: abort.check,
          knownCheckpoints: checkpoints,
        ),
        timeout: config.timeout,
        abortTrigger: abortTrigger,
      );
    }
    return _sendGenerateContent(
      model,
      request.toJson,
      abortTrigger: abortTrigger,
    );
  }

  Future<GenerateContentResponse> _sendGenerateContent(
    String model,
    Map<String, dynamic> Function() buildBody, {
    Future<void>? abortTrigger,
    void Function()? checkActive,
    Iterable<String>? knownCheckpoints,
  }) async {
    final body = buildBody();
    final diagnosticRedactor = _generationDiagnosticRedactor(
      body,
      knownCheckpoints,
    );
    final response = await interceptorChain.execute(
      _generateContentHttpRequest(model, body, stream: false),
      abortTrigger: abortTrigger,
      checkActive: checkActive,
      diagnosticRedactor: diagnosticRedactor,
    );
    return _decodeGeneratedContent(response, diagnosticRedactor);
  }

  /// Streams content using the specified model.
  ///
  /// Set [automaticContinuation] to follow safe long-decode checkpoints.
  /// Reported usage includes completed hops and the current hop's running
  /// totals. The configured timeout and [abortTrigger] cover the entire
  /// automatically continued stream. Cancelling the subscription stops
  /// any pending requests.
  ///
  /// If [abortTrigger] completes while streaming, the stream emits an
  /// [AbortedException] and closes.
  Stream<GenerateContentResponse> streamGenerateContent({
    required String model,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
    bool automaticContinuation = false,
  }) {
    if (automaticContinuation) {
      return continuationStream(
        operation: _generateContentContinuationName,
        timeout: config.timeout,
        abortTrigger: abortTrigger,
        run: (abort) => _continueGenerateContentStream(
          request,
          (body, checkpoints, trigger) => _streamGenerateContent(
            model,
            () => body,
            abortTrigger: trigger,
            knownCheckpoints: checkpoints,
          ),
          abort,
        ),
      );
    }
    return _streamGenerateContent(
      model,
      request.toJson,
      abortTrigger: abortTrigger,
    );
  }

  Stream<GenerateContentResponse> _streamGenerateContent(
    String model,
    Map<String, dynamic> Function() buildBody, {
    Future<void>? abortTrigger,
    Set<String>? knownCheckpoints,
  }) {
    late Map<String, dynamic> body;
    Redactor? diagnosticRedactor;
    return streamRequest(
      createRequest: () {
        body = buildBody();
        diagnosticRedactor = _generationDiagnosticRedactor(
          body,
          knownCheckpoints,
        );
        return _generateContentHttpRequest(model, body, stream: true);
      },
      abortTrigger: abortTrigger,
      resolveDiagnosticRedactor: () => diagnosticRedactor,
      fromJson: (json) {
        final sseEvent = json['_event'] as String?;
        final error = json['error'];
        if (sseEvent == 'error' || error != null) {
          throwInlineStreamError(
            json,
            sseEvent,
            error,
            redactor: diagnosticRedactor ?? Redactor.continuationTokens,
          );
        }
        final response = GenerateContentResponse.fromJson(json);
        if (knownCheckpoints != null &&
            _captureGenerationTokens(response, knownCheckpoints)) {
          diagnosticRedactor = _generationDiagnosticRedactor(
            body,
            knownCheckpoints,
          );
        }
        return response;
      },
    );
  }

  http.Request _generateContentHttpRequest(
    String model,
    Map<String, dynamic> body, {
    required bool stream,
  }) {
    final toolConfig = body['toolConfig'] as Map<String, dynamic>?;
    final callingConfig =
        toolConfig?['functionCallingConfig'] as Map<String, dynamic>?;
    final argumentsStreaming =
        callingConfig?['streamFunctionCallArguments'] as bool?;
    validateFunctionArgumentStreaming(
      value: argumentsStreaming,
      streamConfig: stream ? config : null,
    );
    final operation = stream ? 'streamGenerateContent' : 'generateContent';
    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:$operation',
      queryParams: stream ? const {'alt': 'sse'} : null,
    );
    return http.Request('POST', url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: const {'Content-Type': 'application/json'},
        ),
      )
      ..body = jsonEncode(body);
  }

  /// Counts tokens in the provided content.
  ///
  /// The [model] parameter specifies which model to use for token counting.
  /// The [request] contains the content to count tokens for.
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Returns a [CountTokensResponse] with the token count.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<CountTokensResponse> countTokens({
    required String model,
    required CountTokensRequest request,
    Future<void>? abortTrigger,
  }) async {
    validateNonStreamingArguments(request.generateContentRequest);
    final url = requestBuilder.buildUrl('/{version}/models/$model:countTokens');

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
    return CountTokensResponse.fromJson(responseBody);
  }

  /// Generates content using a dynamic model ID.
  ///
  /// This method is similar to [generateContent] but accepts a dynamicId parameter
  /// for models that use dynamic identifiers (e.g., live content generation).
  ///
  /// The [dynamicId] specifies the model to use (format: "models/{model}").
  /// The [request] contains the content generation parameters.
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Returns a [GenerateContentResponse] with the generated content.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<GenerateContentResponse> dynamicGenerateContent({
    required String dynamicId,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
  }) async {
    validateNonStreamingArguments(request);
    final url = requestBuilder.buildUrl(
      '/{version}/dynamic/$dynamicId:generateContent',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = request.toJson();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final diagnosticRedactor = _generationDiagnosticRedactor(body, null);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
      diagnosticRedactor: diagnosticRedactor,
    );

    return _decodeGeneratedContent(response, diagnosticRedactor);
  }

  /// Generates streaming content using a dynamic model ID.
  ///
  /// This method is similar to [streamGenerateContent] but accepts a dynamicId parameter
  /// for models that use dynamic identifiers (e.g., live content generation).
  ///
  /// The [dynamicId] specifies the model to use (format: "models/{model}").
  /// The [request] contains the content generation parameters.
  /// The optional [abortTrigger] allows canceling the stream mid-generation.
  ///
  /// Returns a stream of [GenerateContentResponse] chunks.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Stream<GenerateContentResponse> dynamicStreamGenerateContent({
    required String dynamicId,
    required GenerateContentRequest request,
    Future<void>? abortTrigger,
  }) {
    Redactor? diagnosticRedactor;
    return streamRequest(
      createRequest: () {
        validateNonStreamingArguments(request);
        // Build URL and headers
        final url = requestBuilder.buildUrl(
          '/{version}/dynamic/$dynamicId:streamGenerateContent',
          queryParams: {'alt': 'sse'},
        );

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Create request
        final body = request.toJson();
        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(body);
        diagnosticRedactor = _generationDiagnosticRedactor(body, null);
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      resolveDiagnosticRedactor: () => diagnosticRedactor,
      fromJson: (json) {
        final sseEvent = json['_event'] as String?;
        final error = json['error'];
        if (sseEvent == 'error' || error != null) {
          throwInlineStreamError(
            json,
            sseEvent,
            error,
            redactor: diagnosticRedactor ?? Redactor.continuationTokens,
          );
        }
        return GenerateContentResponse.fromJson(json);
      },
    );
  }

  GenerateContentResponse _decodeGeneratedContent(
    http.Response response,
    Redactor? diagnosticRedactor,
  ) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return GenerateContentResponse.fromJson(json);
    } on FormatException catch (error) {
      if (diagnosticRedactor == null) rethrow;
      throw FormatException(
        'Invalid GenerateContent response.',
        null,
        error.offset,
      );
    } on TypeError {
      if (diagnosticRedactor == null) rethrow;
      throw const FormatException('Invalid GenerateContent response.');
    }
  }

  Redactor? _generationDiagnosticRedactor(
    Map<String, dynamic> body,
    Iterable<String>? knownCheckpoints,
  ) {
    final keys = {
      ...?knownCheckpoints,
      ?_generationToken(body['continuationToken'] as String?),
    };
    // Derive the scope from the same serialized request, including saved
    // content on later hops and pending edits before a stream is listened to.
    void addVoiceKey(Object? config) {
      if (config case {
        'voice': final String key,
      } when key.startsWith('voicekey_')) {
        keys.add(key);
      }
    }

    if (body case {
      'generationConfig': {'speechConfig': final Map<String, dynamic> speech},
    }) {
      addVoiceKey(speech['voiceConfig']);
      if (speech case {
        'multiSpeakerVoiceConfig': {
          'speakerVoiceConfigs': final List<Object?> speakers,
        },
      }) {
        for (final speaker in speakers) {
          if (speaker case {'voiceConfig': final Object? config}) {
            addVoiceKey(config);
          }
        }
      }
    }
    if (keys.isEmpty) {
      return knownCheckpoints == null ? null : Redactor.continuationTokens;
    }
    return Redactor.forSecrets(
      secrets: keys,
      redactionList: Redactor.continuationTokenFields,
    );
  }

  /// Embeds content.
  ///
  /// The [model] parameter specifies which embedding model to use.
  /// The [request] contains the content to embed.
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Returns an [EmbedContentResponse] with the embedding.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<EmbedContentResponse> embedContent({
    required String model,
    required EmbedContentRequest request,
    Future<void>? abortTrigger,
  }) async {
    // Vertex AI uses the predict endpoint for embeddings
    if (config.apiMode == ApiMode.vertexAI) {
      return _embedContentViaPredict(model, request, abortTrigger);
    }

    // Google AI uses the embedContent endpoint
    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:embedContent',
      // No endpoint-specific config needed
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(_embedContentRequestToGoogleAIJson(request));

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return EmbedContentResponse.fromJson(responseBody);
  }

  /// Embeds content using Vertex AI's predict endpoint.
  ///
  /// Vertex AI uses a different endpoint structure for embeddings compared to
  /// Google AI. This method transforms the request/response to maintain API compatibility.
  Future<EmbedContentResponse> _embedContentViaPredict(
    String model,
    EmbedContentRequest request,
    Future<void>? abortTrigger,
  ) async {
    // Extract text from content parts
    final textParts = request.content.parts.whereType<TextPart>();
    if (textParts.isEmpty) {
      throw ArgumentError('Content must contain at least one text part');
    }
    final text = textParts.first.text;
    final embedConfig = request.embedContentConfig;
    final taskType = embedConfig?.taskType ?? request.taskType;
    final title = embedConfig?.title ?? request.title;
    final outputDimensionality =
        embedConfig?.outputDimensionality ?? request.outputDimensionality;

    // Build instance in Vertex AI format
    final instance = <String, dynamic>{
      'content': text,
      if (taskType != null) 'task_type': taskTypeToString(taskType),
      'title': ?title,
    };

    // Build parameters
    final parameters = <String, dynamic>{
      'outputDimensionality': ?outputDimensionality,
      if (embedConfig?.autoTruncate != null)
        'autoTruncate': embedConfig!.autoTruncate,
      if (embedConfig?.documentOcr != null)
        'documentOcr': embedConfig!.documentOcr,
      if (embedConfig?.audioTrackExtraction != null)
        'audioTrackExtraction': embedConfig!.audioTrackExtraction,
    };

    // Call predict endpoint
    final predictResponse = await predict(
      model: model,
      instances: [instance],
      parameters: parameters.isNotEmpty ? parameters : null,
    );

    // Transform response: predictions[0].embeddings.values -> embedding.values
    if (predictResponse.predictions.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'No predictions returned from Vertex AI embedding endpoint',
      );
    }

    final prediction =
        predictResponse.predictions.first as Map<String, dynamic>;
    final embeddings = prediction['embeddings'] as Map<String, dynamic>;
    final valuesList = embeddings['values'] as List;
    final values = valuesList.map((e) => (e as num).toDouble()).toList();

    return EmbedContentResponse(embedding: ContentEmbedding(values: values));
  }

  /// Generates multiple embedding vectors from the input content.
  ///
  /// This is a synchronous batch operation that returns embeddings immediately.
  /// For asynchronous batch processing, use [asyncBatchEmbedContent].
  ///
  /// The [model] parameter specifies which embedding model to use
  /// (e.g., "gemini-embedding-2").
  /// The [request] contains a list of embed content requests.
  ///
  /// Returns a [BatchEmbedContentsResponse] with embeddings for each request,
  /// in the same order as provided.
  ///
  /// Note: Vertex AI does not support batch embeddings via a single API call.
  /// Use [embedContent] in a loop instead, or let the client library handle
  /// the fallback automatically.
  Future<BatchEmbedContentsResponse> batchEmbedContents({
    required String model,
    required BatchEmbedContentsRequest request,
  }) async {
    // Vertex AI doesn't have a batch embeddings endpoint
    // Throw ApiException so the fallback in langchain_google can catch it
    if (config.apiMode == ApiMode.vertexAI) {
      throw const ApiException(
        statusCode: 400,
        message:
            'model is not specified', // Trigger fallback in langchain_google
      );
    }

    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:batchEmbedContents',
    );

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Add model to each request as required by the API
    final requests = request.requests
        .map(
          (embedRequest) => {
            ..._embedContentRequestToGoogleAIJson(embedRequest),
            'model': 'models/$model',
          },
        )
        .toList();

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'requests': requests});

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchEmbedContentsResponse.fromJson(responseBody);
  }

  Map<String, dynamic> _embedContentRequestToGoogleAIJson(
    EmbedContentRequest request,
  ) {
    final embedConfig = request.embedContentConfig;
    if (embedConfig == null) return request.toJson();

    if (embedConfig.autoTruncate != null ||
        embedConfig.documentOcr != null ||
        embedConfig.audioTrackExtraction != null) {
      throw ArgumentError(
        'autoTruncate, documentOcr, and audioTrackExtraction are not '
            'supported by the Gemini Developer API.',
        'request',
      );
    }

    final taskType = embedConfig.taskType ?? request.taskType;
    final title = embedConfig.title ?? request.title;
    final outputDimensionality =
        embedConfig.outputDimensionality ?? request.outputDimensionality;
    return {
      'content': request.content.toJson(),
      if (taskType != null) 'taskType': taskTypeToString(taskType),
      'title': ?title,
      'outputDimensionality': ?outputDimensionality,
    };
  }

  /// Enqueues a batch of embed content requests for asynchronous processing.
  ///
  /// This is an asynchronous batch operation that returns immediately with
  /// batch metadata. Use [getEmbedBatch], [listBatches], or [LROPoller] to monitor
  /// the batch processing status.
  ///
  /// The [model] parameter specifies which embedding model to use
  /// (e.g., "gemini-embedding-2").
  /// The [batch] contains the batch configuration including input configuration.
  /// If [batch.model] is not set, it will be auto-populated from [model].
  ///
  /// Returns an [EmbedContentBatch] with the batch job details including
  /// the batch name which can be used to track progress.
  Future<EmbedContentBatch> asyncBatchEmbedContent({
    required String model,
    required EmbedContentBatch batch,
  }) async {
    // Auto-populate batch.model from method parameter if not set
    final effectiveBatch = batch.model == null
        ? batch.copyWith(model: 'models/$model')
        : batch;

    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:asyncBatchEmbedContent',
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

  /// Generates a grounded answer from the model.
  ///
  /// The [model] parameter specifies which model to use (e.g., "aqa").
  /// The [request] contains the question, grounding sources, and configuration.
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Grounding sources can be:
  /// - Inline passages provided in the request
  /// - Content from the Semantic Retriever API
  ///
  /// Returns a [GenerateAnswerResponse] with the grounded answer and metadata.
  ///
  /// Note: Only supports queries in English.
  ///
  /// Throws [AbortedException] if the request is aborted via [abortTrigger].
  Future<GenerateAnswerResponse> generateAnswer({
    required String model,
    required GenerateAnswerRequest request,
    Future<void>? abortTrigger,
  }) async {
    if (config.apiMode == ApiMode.vertexAI) {
      throw UnsupportedError(
        'generateAnswer is only available with Google AI (Gemini API). '
        'Vertex AI uses grounding with Vertex AI Search instead. '
        'See: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/grounding',
      );
    }

    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:generateAnswer',
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
    return GenerateAnswerResponse.fromJson(responseBody);
  }

  /// Performs a synchronous prediction request.
  ///
  /// The [instances] are the required input data for the prediction,
  /// and [parameters] are optional prediction parameters for [model].
  /// [labels] adds metadata where supported by the selected model.
  ///
  /// Returns a [PredictResponse] with the prediction outputs.
  Future<PredictResponse> predict({
    required String model,
    required List<dynamic> instances,
    dynamic parameters,
    Map<String, String>? labels,
  }) async {
    final url = requestBuilder.buildUrl('/{version}/models/$model:predict');

    final headers = requestBuilder.buildHeaders();

    final request = PredictRequest(
      instances: instances,
      parameters: parameters,
      labels: labels,
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..headers.putIfAbsent('Content-Type', () => 'application/json')
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictResponse.fromJson(responseBody);
  }

  /// Performs an asynchronous prediction request that returns a long-running operation.
  ///
  /// The [instances] are the required input data for the prediction,
  /// and [parameters] are optional prediction parameters for [model].
  /// Pass [labels] to add metadata on supported models such as Vertex AI Veo.
  ///
  /// Returns a [PredictLongRunningOperation] that can be polled for status and results.
  Future<PredictLongRunningOperation> predictLongRunning({
    required String model,
    required List<dynamic> instances,
    dynamic parameters,
    Map<String, String>? labels,
  }) async {
    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:predictLongRunning',
    );

    final headers = requestBuilder.buildHeaders();

    final request = PredictLongRunningRequest(
      instances: instances,
      parameters: parameters,
      labels: labels,
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..headers.putIfAbsent('Content-Type', () => 'application/json')
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PredictLongRunningOperation.fromJson(responseBody);
  }

  /// Fetches a Vertex AI publisher model prediction operation.
  ///
  /// Pass the full [operationName] returned by [predictLongRunning]. Use a
  /// Vertex AI client configured for the operation's region. Completed Veo
  /// operations return their media in the response's `videos` list.
  Future<PredictLongRunningOperation> fetchPredictOperation({
    required String operationName,
    Future<void>? abortTrigger,
  }) async {
    if (config.apiMode != ApiMode.vertexAI) {
      throw UnsupportedError(
        'Fetching publisher prediction operations requires Vertex AI.',
      );
    }
    final segments = operationName.split('/');
    final isPublisherOperation = switch (segments) {
      [
        'projects',
        _,
        'locations',
        _,
        'publishers',
        _,
        'models',
        _,
        'operations',
        _,
      ] =>
        true,
      _ => false,
    };
    if (!isPublisherOperation ||
        segments.any(
          (segment) => segment.isEmpty || segment == '.' || segment == '..',
        )) {
      throw ArgumentError(
        'Expected a full Vertex AI publisher model operation name.',
        'operationName',
      );
    }
    final resource = segments
        .take(segments.length - 2)
        .map(Uri.encodeComponent)
        .join('/');
    final url = requestBuilder.buildUrl(
      '/{version}/$resource:fetchPredictOperation',
      vertexPathIncludesProject: true,
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: const {'Content-Type': 'application/json'},
        ),
      )
      ..body = jsonEncode({'operationName': operationName});
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return PredictLongRunningOperation.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// Lists all available models.
  ///
  /// The [pageSize] parameter specifies the maximum number of models to return
  /// (default is 50). The [pageToken] is used for pagination.
  ///
  /// Returns a [ListModelsResponse] with the list of models and a next page token.
  Future<ListModelsResponse> list({int? pageSize, String? pageToken}) async {
    final queryParams = <String, String>{
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/models',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListModelsResponse.fromJson(responseBody);
  }

  /// Gets details for a specific model.
  ///
  /// The [model] parameter specifies which model to retrieve (e.g., "gemini-pro").
  ///
  /// Returns a [Model] with the model's details.
  Future<Model> get({required String model}) async {
    final url = requestBuilder.buildUrl('/{version}/models/$model');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Model.fromJson(responseBody);
  }

  /// Creates a batch of generate content requests.
  ///
  /// The [model] parameter specifies which model to use (e.g., "gemini-pro").
  /// The [batch] contains the batch configuration including requests.
  /// If [batch.model] is not set, it will be auto-populated from [model].
  ///
  /// Returns a [GenerateContentBatch] with the batch job details.
  Future<GenerateContentBatch> batchGenerateContent({
    required String model,
    required GenerateContentBatch batch,
  }) async {
    validateBatchFunctionArguments(batch);
    // Auto-populate batch.model from method parameter if not set
    final effectiveBatch = batch.model == null
        ? batch.copyWith(model: 'models/$model')
        : batch;

    final url = requestBuilder.buildUrl(
      '/{version}/models/$model:batchGenerateContent',
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

  /// Access operations for this model.
  OperationsResource operations({required String model}) {
    return OperationsResource(
      parent: 'models/$model',
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
