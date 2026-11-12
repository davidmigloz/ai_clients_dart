import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/response_error.dart';
import '../models/batches/batch_request.dart';
import '../models/batches/message_batch.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';
import 'message_request_validation.dart';
import 'streaming_resource.dart';

/// Resource for the Message Batches API.
///
/// The Message Batches API allows you to process large volumes of
/// Messages requests asynchronously. Set `workspaceId` to override the
/// client's workspace for a call. Set `betas` to opt into beta behavior
/// for the same HTTP endpoint. Include `message-batches-2024-09-24` to
/// request the beta Batches contract used by the official SDKs.
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
    String? workspaceId,
    List<String> betas = const [],
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/batches');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(betas, workspaceId, userProfileId),
    );
    final body = request.toJson();
    validateBatchRequestVersion(headers['anthropic-version'], body);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

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
    String? workspaceId,
    List<String> betas = const [],
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
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(betas, workspaceId),
    );
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
    String? workspaceId,
    List<String> betas = const [],
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/messages/batches/${encodePathSegment(batchId, 'batchId')}',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(betas, workspaceId),
    );
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
    String? workspaceId,
    List<String> betas = const [],
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/messages/batches/${encodePathSegment(batchId, 'batchId')}/cancel',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(betas, workspaceId),
    );
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
    String? workspaceId,
    List<String> betas = const [],
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/messages/batches/${encodePathSegment(batchId, 'batchId')}',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(betas, workspaceId),
    );
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
    String? workspaceId,
    List<String> betas = const [],
  }) => mapStream(
    getJsonlStream(
      '/v1/messages/batches/${encodePathSegment(batchId, 'batchId')}/results',
      abortTrigger: abortTrigger,
      headers: _requestHeaders(betas, workspaceId),
      errorFactoryWithMetadata: createResourceException,
    ),
    BatchIndividualResponse.fromJson,
  );

  static Map<String, String> _requestHeaders(
    List<String> betas,
    String? workspaceId, [
    String? userProfileId,
  ]) => {
    if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
    'anthropic-user-profile-id': ?userProfileId,
    'anthropic-workspace-id': ?workspaceId,
  };
}
