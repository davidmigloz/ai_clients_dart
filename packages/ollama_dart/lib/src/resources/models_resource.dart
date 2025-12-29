import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/models/copy_request.dart';
import '../models/models/create_request.dart';
import '../models/models/delete_request.dart';
import '../models/models/list_response.dart';
import '../models/models/ps_response.dart';
import '../models/models/pull_request.dart';
import '../models/models/push_request.dart';
import '../models/models/show_request.dart';
import '../models/models/show_response.dart';
import '../models/models/status_event.dart';
import '../models/models/status_response.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Resource for the Models API.
///
/// Provides model management operations: list, show, create, copy, delete,
/// pull, and push.
class ModelsResource extends ResourceBase {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Lists all locally available models.
  ///
  /// Returns a [ListResponse] containing model summaries.
  Future<ListResponse> list() async {
    final url = requestBuilder.buildUrl('/api/tags');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListResponse.fromJson(responseBody);
  }

  /// Lists currently running models.
  ///
  /// Returns a [PsResponse] containing running model information.
  Future<PsResponse> ps() async {
    final url = requestBuilder.buildUrl('/api/ps');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PsResponse.fromJson(responseBody);
  }

  /// Shows details for a specific model.
  ///
  /// The [request] contains the model name and optional verbose flag.
  ///
  /// Returns a [ShowResponse] with model details.
  Future<ShowResponse> show({required ShowRequest request}) async {
    final url = requestBuilder.buildUrl('/api/show');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ShowResponse.fromJson(responseBody);
  }

  /// Creates a new model.
  ///
  /// The [request] contains the model configuration.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> create({required CreateRequest request}) async {
    final url = requestBuilder.buildUrl('/api/create');

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
    return StatusResponse.fromJson(responseBody);
  }

  /// Creates a new model with streaming progress.
  ///
  /// The [request] contains the model configuration.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  Stream<StatusEvent> createStream({required CreateRequest request}) async* {
    final url = requestBuilder.buildUrl('/api/create');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    httpRequest = await _prepareStreamingRequest(httpRequest);

    final streamedResponse = await _sendStreamingRequest(httpRequest);

    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield StatusEvent.fromJson(json);
    }
  }

  /// Copies a model.
  ///
  /// The [request] contains the source and destination names.
  Future<void> copy({required CopyRequest request}) async {
    final url = requestBuilder.buildUrl('/api/copy');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Deletes a model.
  ///
  /// The [request] contains the model name to delete.
  Future<void> delete({required DeleteRequest request}) async {
    final url = requestBuilder.buildUrl('/api/delete');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('DELETE', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Pulls a model from the registry.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> pull({required PullRequest request}) async {
    final url = requestBuilder.buildUrl('/api/pull');

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
    return StatusResponse.fromJson(responseBody);
  }

  /// Pulls a model from the registry with streaming progress.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  Stream<StatusEvent> pullStream({required PullRequest request}) async* {
    final url = requestBuilder.buildUrl('/api/pull');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    httpRequest = await _prepareStreamingRequest(httpRequest);

    final streamedResponse = await _sendStreamingRequest(httpRequest);

    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield StatusEvent.fromJson(json);
    }
  }

  /// Pushes a model to the registry.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> push({required PushRequest request}) async {
    final url = requestBuilder.buildUrl('/api/push');

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
    return StatusResponse.fromJson(responseBody);
  }

  /// Pushes a model to the registry with streaming progress.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  Stream<StatusEvent> pushStream({required PushRequest request}) async* {
    final url = requestBuilder.buildUrl('/api/push');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    httpRequest = await _prepareStreamingRequest(httpRequest);

    final streamedResponse = await _sendStreamingRequest(httpRequest);

    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield StatusEvent.fromJson(json);
    }
  }

  // Helper methods for streaming

  Future<http.Request> _prepareStreamingRequest(http.Request request) async {
    var req = request;

    // 1. Auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    req = _applyAuthToRequest(req, credentials);

    // 2. Logging
    req = _applyLoggingToRequest(req);

    return req;
  }

  Future<http.StreamedResponse> _sendStreamingRequest(
    http.Request request,
  ) async {
    try {
      final streamedResponse = await httpClient.send(request);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw _mapHttpError(response);
      }

      return streamedResponse;
    } catch (e) {
      _logStreamError(
        e,
        request.headers['X-Request-ID'] ?? generateRequestId(),
      );
      rethrow;
    }
  }

  http.Request _applyAuthToRequest(
    http.Request request,
    AuthCredentials? credentials,
  ) {
    if (credentials == null) return request;

    return switch (credentials) {
      BearerTokenCredentials(:final token) =>
        http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['Authorization'] = 'Bearer $token'
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding,
      NoAuthCredentials() => request,
    };
  }

  http.Request _applyLoggingToRequest(http.Request request) {
    if (!request.headers.containsKey('X-Request-ID')) {
      final requestId = generateRequestId();
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      if (config.logLevel.value <= Level.INFO.value) {
        Logger(
          'Ollama.HTTP',
        ).info('REQUEST [$requestId] ${request.method} ${request.url}');
      }

      return updatedRequest;
    }

    return request;
  }

  OllamaException _mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    var message = 'HTTP $statusCode error';

    try {
      final errorDetails = jsonDecode(response.body);
      if (errorDetails is Map<String, dynamic>) {
        message = errorDetails['error']?.toString() ?? message;
      }
    } catch (_) {
      if (response.body.isNotEmpty && response.body.length < 200) {
        message = response.body;
      }
    }

    if (statusCode == 429) {
      DateTime? retryAfter;
      final retryHeader = response.headers['retry-after'];
      if (retryHeader != null) {
        final seconds = int.tryParse(retryHeader);
        if (seconds != null) {
          retryAfter = DateTime.now().add(Duration(seconds: seconds));
        }
      }

      return RateLimitException(
        code: statusCode,
        message: message,
        retryAfter: retryAfter,
      );
    }

    return ApiException(code: statusCode, message: message);
  }

  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('Ollama.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }
}
