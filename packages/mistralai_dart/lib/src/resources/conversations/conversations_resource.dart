import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/conversations/conversation.dart';
import '../../models/conversations/conversation_entry.dart';
import '../../models/conversations/conversation_event.dart';
import '../../models/conversations/conversation_request.dart';
import '../../models/conversations/conversation_response.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for managing conversations (Beta).
///
/// Conversations provide a more flexible and expressive way to interact with
/// AI models compared to the Chat Completion API. They allow for fine-grained
/// control over events and support complex multi-turn interactions.
///
/// Example usage:
/// ```dart
/// // Start a new conversation
/// final response = await client.conversations.start(
///   request: StartConversationRequest.withMessage(
///     model: 'mistral-large-latest',
///     message: 'Hello! How can you help me?',
///   ),
/// );
/// print('Conversation ID: ${response.conversationId}');
/// print('Response: ${response.text}');
///
/// // Continue the conversation
/// final reply = await client.conversations.sendMessage(
///   conversationId: response.conversationId,
///   message: 'Tell me more about that.',
/// );
/// print(reply.text);
/// ```
class ConversationsResource extends ResourceBase with StreamingResource {
  /// Creates a [ConversationsResource].
  ConversationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _path = '/v1/conversations';

  String _conversationPath(String conversationId) =>
      '$_path/${Uri.encodeComponent(conversationId)}';

  /// Lists conversations with optional pagination and metadata filters.
  Future<ConversationList> list({
    int? page,
    int? pageSize,
    Map<String, dynamic>? metadata,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      _path,
      queryParams: {
        'page': ?page?.toString(),
        'page_size': ?pageSize?.toString(),
        if (metadata != null) 'metadata': jsonEncode(metadata),
      },
    );
    final request = http.Request('GET', url)
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(request);
    return ConversationList.fromJson(jsonDecode(response.body) as Object);
  }

  /// Retrieves a conversation by ID.
  Future<Conversation> retrieve({required String conversationId}) async =>
      Conversation.fromJson(await _get(_conversationPath(conversationId)));

  /// Starts a conversation and returns the completed response.
  Future<ConversationResponse> start({
    required StartConversationRequest request,
  }) => _complete(_path, request.toJson);

  /// Starts a conversation and streams its events as they arrive.
  ///
  /// Complete [abortTrigger] or cancel the returned subscription to stop it.
  Stream<ConversationEvent> startStream({
    required StartConversationRequest request,
    Future<void>? abortTrigger,
  }) => _stream(_path, request.toJson, abortTrigger: abortTrigger);

  /// Appends entries to a conversation and returns the completed response.
  Future<ConversationResponse> append({
    required String conversationId,
    required AppendConversationRequest request,
  }) => _complete(_conversationPath(conversationId), request.toJson);

  /// Appends entries to a conversation and streams its events as they arrive.
  ///
  /// Complete [abortTrigger] or cancel the returned subscription to stop it.
  Stream<ConversationEvent> appendStream({
    required String conversationId,
    required AppendConversationRequest request,
    Future<void>? abortTrigger,
  }) => _stream(
    _conversationPath(conversationId),
    request.toJson,
    abortTrigger: abortTrigger,
  );

  /// Retrieves all conversation entries in the order they were appended.
  Future<ConversationEntriesResponse> getHistory({
    required String conversationId,
  }) async => ConversationEntriesResponse.fromJson(
    await _get('${_conversationPath(conversationId)}/history'),
  );

  /// Retrieves all conversation entries. This is an alias for [getHistory].
  Future<ConversationEntriesResponse> getEntries({
    required String conversationId,
  }) => getHistory(conversationId: conversationId);

  /// Retrieves the input and output messages of an existing conversation.
  Future<ConversationMessagesResponse> getMessages({
    required String conversationId,
  }) async => ConversationMessagesResponse.fromJson(
    await _get('${_conversationPath(conversationId)}/messages'),
  );

  /// Restarts a conversation from the requested entry.
  Future<ConversationResponse> restart({
    required String conversationId,
    required RestartConversationRequest request,
  }) =>
      _complete('${_conversationPath(conversationId)}/restart', request.toJson);

  /// Restarts a conversation from an entry and streams its events.
  ///
  /// Complete [abortTrigger] or cancel the returned subscription to stop it.
  Stream<ConversationEvent> restartStream({
    required String conversationId,
    required RestartConversationRequest request,
    Future<void>? abortTrigger,
  }) => _stream(
    '${_conversationPath(conversationId)}/restart',
    request.toJson,
    abortTrigger: abortTrigger,
  );

  /// Deletes a conversation.
  Future<void> delete({required String conversationId}) async {
    ensureNotClosed?.call();
    final request = http.Request(
      'DELETE',
      requestBuilder.buildUrl(_conversationPath(conversationId)),
    )..headers.addAll(requestBuilder.buildHeaders());
    await interceptorChain.execute(request);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    ensureNotClosed?.call();
    final request = http.Request('GET', requestBuilder.buildUrl(path))
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(request);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<ConversationResponse> _complete(
    String path,
    Map<String, dynamic> Function() body,
  ) async {
    ensureNotClosed?.call();
    final response = await interceptorChain.execute(_post(path, body()));
    return ConversationResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  http.Request _post(
    String path,
    Map<String, dynamic> body, {
    bool stream = false,
  }) => http.Request('POST', requestBuilder.buildUrl(path))
    ..headers.addAll(
      requestBuilder.buildHeaders(
        additionalHeaders: {
          'Content-Type': 'application/json',
          'Accept': stream ? 'text/event-stream' : 'application/json',
        },
      ),
    )
    ..body = jsonEncode({...body, 'stream': stream});

  Stream<ConversationEvent> _stream(
    String path,
    Map<String, dynamic> Function() body, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return streamRequest(() => _post(path, body(), stream: true), (event) {
      final json = Map<String, dynamic>.of(event);
      final eventType = json.remove('_event') as String?;
      json.putIfAbsent('type', () => eventType);
      return ConversationEvent.fromJson(json);
    }, abortTrigger: abortTrigger);
  }

  /// Convenience method to send a message in a conversation.
  ///
  /// This is a shorthand for appending a user message entry and getting
  /// the assistant's response.
  ///
  /// [conversationId] is the ID of the conversation.
  /// [message] is the user's message.
  /// [maxTokens] is the maximum number of tokens to generate.
  /// [temperature] is the sampling temperature.
  Future<ConversationResponse> sendMessage({
    required String conversationId,
    required String message,
    int? maxTokens,
    double? temperature,
  }) {
    return append(
      conversationId: conversationId,
      request: AppendConversationRequest(
        inputs: [MessageInputEntry(content: message)],
        maxTokens: maxTokens,
        temperature: temperature,
      ),
    );
  }

  /// Convenience method to provide a function result.
  ///
  /// This is a shorthand for appending a function result entry after a
  /// function call.
  ///
  /// [conversationId] is the ID of the conversation.
  /// [callId] is the ID of the function call this result responds to.
  /// [result] is the result of the function execution.
  /// Include details of function errors in [result]. The legacy [isError]
  /// flag has no field in the Conversations API.
  Future<ConversationResponse> sendFunctionResult({
    required String conversationId,
    required String callId,
    required String result,
    bool? isError,
  }) {
    return append(
      conversationId: conversationId,
      request: AppendConversationRequest(
        inputs: [
          FunctionResultEntry(callId: callId, result: result, isError: isError),
        ],
      ),
    );
  }
}
