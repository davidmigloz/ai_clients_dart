import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/threads/threads.dart';
import 'base_resource.dart';
import 'messages_resource.dart';
import 'runs_resource.dart';

/// Resource for Threads API operations (Beta).
///
/// Threads represent conversations with an assistant.
///
/// Access this resource through [OpenAIClient.beta.threads].
///
/// ## Example
///
/// ```dart
/// // Create a thread
/// final thread = await client.beta.threads.create();
///
/// // Create with initial messages
/// final thread = await client.beta.threads.create(
///   CreateThreadRequest(
///     messages: [
///       ThreadMessage(role: 'user', content: 'Hello!'),
///     ],
///   ),
/// );
/// ```
class ThreadsResource extends ResourceBase {
  /// Creates a [ThreadsResource].
  ThreadsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  static const _endpoint = '/threads';
  static const _betaFeature = 'assistants=v2';

  MessagesResource? _messages;
  RunsResource? _runs;

  /// Access to thread messages.
  MessagesResource get messages => _messages ??= MessagesResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Access to thread runs.
  RunsResource get runs => _runs ??= RunsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
    streamClientFactory: streamClientFactory,
  );

  /// Creates a new thread.
  ///
  /// ## Parameters
  ///
  /// - [request] - Optional creation request with initial messages.
  ///
  /// ## Returns
  ///
  /// A [Thread] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Empty thread
  /// final thread = await client.beta.threads.create();
  ///
  /// // Thread with initial messages
  /// final thread = await client.beta.threads.create(
  ///   CreateThreadRequest(
  ///     messages: [
  ///       ThreadMessage(role: 'user', content: 'Help me with math'),
  ///     ],
  ///     metadata: {'user_id': '123'},
  ///   ),
  /// );
  /// ```
  Future<Thread> create([CreateThreadRequest? request]) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request?.toJson() ?? {});
    final response = await interceptorChain.execute(httpRequest);
    return Thread.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Retrieves a thread by ID.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Thread] with the thread information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final thread = await client.beta.threads.retrieve('thread_abc123');
  /// print('Created: ${thread.createdAt}');
  /// ```
  Future<Thread> retrieve(String threadId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$threadId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Thread.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Modifies a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to modify.
  /// - [request] - The modification request.
  ///
  /// ## Returns
  ///
  /// A [Thread] with the updated information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.beta.threads.update(
  ///   'thread_abc123',
  ///   ModifyThreadRequest(
  ///     metadata: {'status': 'active'},
  ///   ),
  /// );
  /// ```
  Future<Thread> update(String threadId, ModifyThreadRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$threadId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Thread.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteThreadResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.beta.threads.delete('thread_abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteThreadResponse> delete(String threadId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$threadId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteThreadResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
