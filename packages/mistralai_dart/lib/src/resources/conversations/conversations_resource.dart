import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/conversations/conversation.dart';
import '../../models/conversations/conversation_entry.dart';
import '../../models/conversations/conversation_request.dart';
import '../../models/conversations/conversation_response.dart';
import '../base_resource.dart';

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
class ConversationsResource extends ResourceBase {
  /// Creates a [ConversationsResource].
  ConversationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Lists all conversations.
  ///
  /// [page] is the page number to retrieve (0-indexed).
  /// [pageSize] is the number of conversations per page.
  Future<ConversationList> list({int? page, int? pageSize}) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/conversations',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConversationList.fromJson(responseBody);
  }

  /// Retrieves a conversation by ID.
  ///
  /// [conversationId] is the unique identifier of the conversation.
  Future<Conversation> retrieve({required String conversationId}) async {
    final url = requestBuilder.buildUrl('/v1/conversations/$conversationId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Conversation.fromJson(responseBody);
  }

  /// Starts a new conversation.
  ///
  /// Creates a new conversation and runs completion on the provided inputs.
  /// Returns the conversation ID and the generated outputs.
  ///
  /// [request] contains the model/agent ID and initial inputs.
  Future<ConversationResponse> start({
    required StartConversationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/conversations');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConversationResponse.fromJson(responseBody);
  }

  /// Appends entries to an existing conversation.
  ///
  /// Appends new entries to the conversation, runs completion, and returns
  /// the newly created entries.
  ///
  /// [conversationId] is the ID of the conversation to append to.
  /// [request] contains the entries to append and completion parameters.
  Future<ConversationResponse> append({
    required String conversationId,
    required AppendConversationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/conversations/$conversationId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConversationResponse.fromJson(responseBody);
  }

  /// Retrieves all entries in a conversation.
  ///
  /// Returns all entries belonging to the conversation, sorted in the order
  /// they were appended.
  ///
  /// [conversationId] is the ID of the conversation.
  Future<ConversationEntriesResponse> getEntries({
    required String conversationId,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/conversations/$conversationId/entries',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConversationEntriesResponse.fromJson(responseBody);
  }

  /// Restarts a conversation from a specific entry.
  ///
  /// Creates a new conversation from the specified entry point and runs
  /// completion. Returns the new conversation ID and generated outputs.
  ///
  /// [conversationId] is the ID of the original conversation.
  /// [request] contains the entry ID to restart from.
  Future<ConversationResponse> restart({
    required String conversationId,
    required RestartConversationRequest request,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/conversations/$conversationId/restart',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ConversationResponse.fromJson(responseBody);
  }

  /// Deletes a conversation.
  ///
  /// [conversationId] is the unique identifier of the conversation to delete.
  Future<void> delete({required String conversationId}) async {
    final url = requestBuilder.buildUrl('/v1/conversations/$conversationId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
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
  /// [isError] indicates if the result represents an error.
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
