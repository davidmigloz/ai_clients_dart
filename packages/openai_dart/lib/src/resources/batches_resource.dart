import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/batches/batches.dart';
import 'base_resource.dart';

/// Resource for batch operations.
///
/// The Batch API allows processing large numbers of requests asynchronously
/// at a 50% discount compared to synchronous API calls.
///
/// Access this resource through [OpenAIClient.batches].
///
/// ## Example
///
/// ```dart
/// // Create a batch
/// final batch = await client.batches.create(
///   CreateBatchRequest(
///     inputFileId: 'file-abc123',
///     endpoint: BatchEndpoint.chatCompletions,
///     completionWindow: CompletionWindow.h24,
///   ),
/// );
///
/// // Check status
/// final status = await client.batches.retrieve(batch.id);
/// print('Status: ${status.status}');
/// ```
class BatchesResource extends ResourceBase {
  /// Creates a [BatchesResource].
  BatchesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/batches';

  /// Creates a new batch.
  ///
  /// ## Parameters
  ///
  /// - [request] - The batch creation request.
  ///
  /// ## Returns
  ///
  /// A [Batch] object with the batch information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final batch = await client.batches.create(
  ///   CreateBatchRequest(
  ///     inputFileId: 'file-abc123',
  ///     endpoint: BatchEndpoint.chatCompletions,
  ///     completionWindow: CompletionWindow.h24,
  ///     metadata: {'project': 'training'},
  ///   ),
  /// );
  ///
  /// print('Batch ID: ${batch.id}');
  /// ```
  Future<Batch> create(CreateBatchRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Batch.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists batches for the organization.
  ///
  /// ## Parameters
  ///
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number of batches to return (1-100, default 20).
  ///
  /// ## Returns
  ///
  /// A [BatchList] containing the batches.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final batches = await client.batches.list(limit: 10);
  ///
  /// for (final batch in batches.data) {
  ///   print('${batch.id}: ${batch.status}');
  /// }
  /// ```
  Future<BatchList> list({String? after, int? limit}) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return BatchList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a batch.
  ///
  /// ## Parameters
  ///
  /// - [batchId] - The ID of the batch to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Batch] with the batch information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final batch = await client.batches.retrieve('batch-abc123');
  ///
  /// if (batch.status == BatchStatus.completed) {
  ///   print('Output file: ${batch.outputFileId}');
  /// }
  /// ```
  Future<Batch> retrieve(String batchId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$batchId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Batch.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Cancels a batch.
  ///
  /// The batch status changes to "cancelling" and eventually to "cancelled".
  /// Any requests that are already in progress will not be cancelled.
  ///
  /// ## Parameters
  ///
  /// - [batchId] - The ID of the batch to cancel.
  ///
  /// ## Returns
  ///
  /// A [Batch] with the updated status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final cancelled = await client.batches.cancel('batch-abc123');
  /// print('Status: ${cancelled.status}');
  /// ```
  Future<Batch> cancel(String batchId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$batchId/cancel');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return Batch.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
