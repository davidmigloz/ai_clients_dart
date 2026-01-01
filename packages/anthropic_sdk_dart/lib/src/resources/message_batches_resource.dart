import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/batches/batch_request.dart';
import '../models/batches/message_batch.dart';
import 'base_resource.dart';

/// Resource for the Message Batches API.
///
/// The Message Batches API allows you to process large volumes of
/// Messages requests asynchronously.
class MessageBatchesResource extends ResourceBase {
  final http.Client _httpClient;

  /// Creates a [MessageBatchesResource].
  MessageBatchesResource({
    required super.chain,
    required super.requestBuilder,
    required http.Client httpClient,
  }) : _httpClient = httpClient;

  /// Creates a message batch.
  ///
  /// Send a list of requests to be processed asynchronously.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<MessageBatch> create(
    MessageBatchCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final response = await post(
      '/v1/messages/batches',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(response);
  }

  /// Lists message batches.
  ///
  /// Returns a paginated list of message batches.
  ///
  /// Parameters:
  /// - [beforeId]: Return batches before this ID for pagination.
  /// - [afterId]: Return batches after this ID for pagination.
  /// - [limit]: Maximum number of batches to return (default: 20).
  /// - [abortTrigger]: Allows canceling the request.
  Future<MessageBatchListResponse> list({
    String? beforeId,
    String? afterId,
    int? limit,
    Future<void>? abortTrigger,
  }) async {
    final queryParams = <String, dynamic>{};
    if (beforeId != null) queryParams['before_id'] = beforeId;
    if (afterId != null) queryParams['after_id'] = afterId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await get(
      '/v1/messages/batches',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      abortTrigger: abortTrigger,
    );

    return MessageBatchListResponse.fromJson(response);
  }

  /// Retrieves a specific message batch.
  ///
  /// Parameters:
  /// - [batchId]: The ID of the batch to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MessageBatch> retrieve(
    String batchId, {
    Future<void>? abortTrigger,
  }) async {
    final response = await get(
      '/v1/messages/batches/$batchId',
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(response);
  }

  /// Cancels a message batch.
  ///
  /// Cancels all in-progress requests in the batch.
  ///
  /// Parameters:
  /// - [batchId]: The ID of the batch to cancel.
  /// - [abortTrigger]: Allows canceling the request.
  Future<MessageBatch> cancel(
    String batchId, {
    Future<void>? abortTrigger,
  }) async {
    final response = await post(
      '/v1/messages/batches/$batchId/cancel',
      body: <String, dynamic>{},
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(response);
  }

  /// Deletes a message batch.
  ///
  /// Deletes the batch and all its results.
  ///
  /// Parameters:
  /// - [batchId]: The ID of the batch to delete.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeletedMessageBatch> deleteBatch(
    String batchId, {
    Future<void>? abortTrigger,
  }) async {
    final response = await delete(
      '/v1/messages/batches/$batchId',
      abortTrigger: abortTrigger,
    );

    return DeletedMessageBatch.fromJson(response);
  }

  /// Streams batch results.
  ///
  /// Returns a stream of [BatchIndividualResponse] items as JSONL.
  ///
  /// Parameters:
  /// - [batchId]: The ID of the batch to get results for.
  Stream<BatchIndividualResponse> results(String batchId) async* {
    final uri = requestBuilder.buildUrl(
      '/v1/messages/batches/$batchId/results',
    );
    final request = http.Request('GET', uri)
      ..headers.addAll(requestBuilder.buildHeaders());

    // Apply authentication before sending (bypasses interceptor chain)
    await _applyAuthentication(request);

    final response = await _httpClient.send(request);

    if (response.statusCode >= 400) {
      final body = await response.stream.bytesToString();
      String message;
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final error = json['error'] as Map<String, dynamic>?;
        message = error?['message'] as String? ?? body;
      } catch (_) {
        message = body;
      }

      switch (response.statusCode) {
        case 401:
          throw AuthenticationException(message: message);
        case 429:
          throw RateLimitException(code: response.statusCode, message: message);
        case 400:
          throw ValidationException(message: message, fieldErrors: const {});
        default:
          throw ApiException(code: response.statusCode, message: message);
      }
    }

    // Parse JSONL stream
    final lineStream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      if (line.trim().isEmpty) continue;
      final json = jsonDecode(line) as Map<String, dynamic>;
      yield BatchIndividualResponse.fromJson(json);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = requestBuilder.config.authProvider;
    if (authProvider == null) return;

    final credentials = await authProvider.getCredentials();
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        if (!request.headers.containsKey('x-api-key')) {
          request.headers['x-api-key'] = apiKey;
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }
}
