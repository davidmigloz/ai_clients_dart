import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../errors/response_error.dart';
import '../models/messages/message.dart';
import '../models/messages/message_create_request.dart';
import '../models/messages/message_response.dart';
import '../models/streaming/message_stream_event.dart';
import '../models/tokens/token_count.dart';
import 'base_resource.dart';
import 'message_batches_resource.dart';
import 'message_request_validation.dart';
import 'streaming_resource.dart';

/// Resource for the Messages API.
///
/// The Messages API is the primary way to interact with Claude.
/// It supports multi-turn conversations, tool use, vision, and more.
class MessagesResource extends ResourceBase with StreamingResource {
  /// Resource for the Message Batches API.
  ///
  /// Access via `client.messages.batches`.
  late final MessageBatchesResource batches;

  /// Creates a [MessagesResource].
  MessagesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  }) {
    batches = MessageBatchesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }

  /// Creates a message.
  ///
  /// Send a structured list of input messages with text and/or image content,
  /// and the model will generate the next message in the conversation.
  ///
  /// [userProfileId] attributes this request to an end-user profile; it is sent
  /// as the `anthropic-user-profile-id` header. [workspaceId] overrides the
  /// configured workspace for this call.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Message> create(
    MessageCreateRequest request, {
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) async {
    final response = await _sendCreateRequest(
      request,
      abortTrigger: abortTrigger,
      betas: betas,
      userProfileId: userProfileId,
      workspaceId: workspaceId,
    );
    return decodeApiJsonResponse(response, Message.fromJson);
  }

  /// Creates a message with the HTTP status and safe provider identifiers.
  ///
  /// Uses the same request, decoding, and cancellation as [create]. The
  /// response's identifiers can be null if the server omits them.
  ///
  /// [userProfileId] attributes this request to an end-user profile.
  /// [workspaceId] selects the workspace for this request. The returned
  /// [MessageResponse.workspaceId] comes from the response header.
  Future<MessageResponse> createWithResponse(
    MessageCreateRequest request, {
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) async {
    final response = await _sendCreateRequest(
      request,
      abortTrigger: abortTrigger,
      betas: betas,
      userProfileId: userProfileId,
      workspaceId: workspaceId,
    );
    final credentials = responseCredentialValues(response);
    final headers = response.headers;
    final awsRequestId =
        safeResponseIdentifier(headers, 'x-amzn-requestid', credentials) ??
        safeResponseIdentifier(headers, 'x-amzn-request-id', credentials) ??
        safeResponseIdentifier(headers, 'x-amz-request-id', credentials);
    final azureRequestId = safeResponseIdentifier(
      headers,
      'apim-request-id',
      credentials,
    );
    return MessageResponse(
      message: decodeApiJsonResponse(response, Message.fromJson),
      statusCode: response.statusCode,
      requestId:
          safeResponseIdentifier(headers, 'request-id', credentials) ??
          awsRequestId ??
          azureRequestId,
      workspaceId: safeResponseIdentifier(
        headers,
        'anthropic-workspace-id',
        credentials,
      ),
      awsRequestId: awsRequestId,
      azureRequestId: azureRequestId,
    );
  }

  Future<http.Response> _sendCreateRequest(
    MessageCreateRequest request, {
    required Future<void>? abortTrigger,
    required List<String> betas,
    required String? userProfileId,
    required String? workspaceId,
  }) {
    ensureNotClosed?.call();
    final body = request.toJson()..remove('stream'); // Ensure non-streaming
    final url = requestBuilder.buildUrl('/v1/messages');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(
        betas: betas,
        userProfileId: userProfileId,
        workspaceId: workspaceId,
      ),
    );
    validateMessageRequestVersion(headers['anthropic-version'], body);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);
    return interceptorChain.execute(httpRequest, abortTrigger: abortTrigger);
  }

  /// Creates a streaming message.
  ///
  /// Returns a stream of [MessageStreamEvent]s as the response is generated.
  ///
  /// [userProfileId] attributes this request to an end-user profile; it is sent
  /// as the `anthropic-user-profile-id` header. [workspaceId] overrides the
  /// configured workspace for this call.
  ///
  /// The optional [abortTrigger] allows canceling the stream.
  Stream<MessageStreamEvent> createStream(
    MessageCreateRequest request, {
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) {
    final body = request.toJson();
    body['stream'] = true;

    return postResourceEventStream<MessageStreamEvent>(
      this,
      '/v1/messages',
      body: body,
      headers: _requestHeaders(
        betas: betas,
        userProfileId: userProfileId,
        workspaceId: workspaceId,
      ),
      validateHeaders: (headers) =>
          validateMessageRequestVersion(headers['anthropic-version'], body),
      abortTrigger: abortTrigger,
      decodeEvent: (event, metadata) =>
          MessageStreamEvent.fromJson(event, responseMetadata: metadata),
      isTerminal: (event) => event is ErrorEvent,
    );
  }

  /// Counts the number of tokens in a message.
  ///
  /// Returns the count of input tokens for the given request.
  ///
  /// [userProfileId] attributes this request to an end-user profile; it is sent
  /// as the `anthropic-user-profile-id` header. [workspaceId] overrides the
  /// configured workspace for this call.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<TokenCountResponse> countTokens(
    TokenCountRequest request, {
    Future<void>? abortTrigger,
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/messages/count_tokens');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: _requestHeaders(
        betas: betas,
        userProfileId: userProfileId,
        workspaceId: workspaceId,
      ),
    );
    final body = request.toJson();
    validateMessageRequestVersion(headers['anthropic-version'], body);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return decodeApiJsonResponse(response, TokenCountResponse.fromJson);
  }

  /// Builds the per-request beta, attribution and workspace headers.
  static Map<String, String>? _requestHeaders({
    List<String> betas = const [],
    String? userProfileId,
    String? workspaceId,
  }) {
    final headers = <String, String>{
      if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
      'anthropic-user-profile-id': ?userProfileId,
      'anthropic-workspace-id': ?workspaceId,
    };
    return headers.isEmpty ? null : headers;
  }
}
