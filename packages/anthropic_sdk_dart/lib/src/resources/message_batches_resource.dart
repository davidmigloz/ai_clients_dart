import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/response_error.dart';
import '../models/batches/batch_request.dart';
import '../models/batches/message_batch.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Message Batches API.
///
/// The Message Batches API allows you to process large volumes of
/// Messages requests asynchronously.
class MessageBatchesResource extends ResourceBase with StreamingResource {
  /// Creates a [MessageBatchesResource].
  MessageBatchesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a message batch.
  ///
  /// Send a list of requests to be processed asynchronously.
  ///
  /// [userProfileId] attributes the requests in this batch to an end-user
  /// profile; it is sent as the `anthropic-user-profile-id` header.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<MessageBatch> create(
    MessageBatchCreateRequest request, {
    Future<void>? abortTrigger,
    String? userProfileId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/batches');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: userProfileId != null
          ? {'anthropic-user-profile-id': userProfileId}
          : null,
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{};
    if (beforeId != null) queryParams['before_id'] = beforeId;
    if (afterId != null) queryParams['after_id'] = afterId;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      '/v1/messages/batches',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return MessageBatchListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/batches/$batchId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/batches/$batchId/cancel');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return MessageBatch.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/batches/$batchId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeletedMessageBatch.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Streams batch results.
  ///
  /// Returns a stream of [BatchIndividualResponse] items as JSONL.
  ///
  /// Parameters:
  /// - [batchId]: The ID of the batch to get results for.
  /// [abortTrigger] cancels the request even while no results arrive.
  Stream<BatchIndividualResponse> results(
    String batchId, {
    Future<void>? abortTrigger,
  }) => mapStream(
    getJsonlStream(
      '/v1/messages/batches/$batchId/results',
      abortTrigger: abortTrigger,
      errorFactoryWithMetadata: createResourceException,
    ),
    BatchIndividualResponse.fromJson,
  );
}
