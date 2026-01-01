import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../models/messages/message.dart';
import '../models/messages/message_create_request.dart';
import '../models/streaming/message_stream_event.dart';
import '../models/tokens/token_count.dart';
import 'base_resource.dart';
import 'message_batches_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Messages API.
///
/// The Messages API is the primary way to interact with Claude.
/// It supports multi-turn conversations, tool use, vision, and more.
class MessagesResource extends ResourceBase with StreamingResource {
  final http.Client _httpClient;

  /// Resource for the Message Batches API.
  ///
  /// Access via `client.messages.batches`.
  late final MessageBatchesResource batches;

  /// Creates a [MessagesResource].
  MessagesResource({
    required super.chain,
    required super.requestBuilder,
    required http.Client httpClient,
  }) : _httpClient = httpClient {
    batches = MessageBatchesResource(
      chain: chain,
      requestBuilder: requestBuilder,
      httpClient: _httpClient,
    );
  }

  @override
  http.Client get httpClient => _httpClient;

  @override
  AuthProvider? get authProvider => requestBuilder.config.authProvider;

  /// Creates a message.
  ///
  /// Send a structured list of input messages with text and/or image content,
  /// and the model will generate the next message in the conversation.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Message> create(
    MessageCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final body = request.toJson()..remove('stream'); // Ensure non-streaming

    final response = await post(
      '/v1/messages',
      body: body,
      abortTrigger: abortTrigger,
    );

    return Message.fromJson(response);
  }

  /// Creates a streaming message.
  ///
  /// Returns a stream of [MessageStreamEvent]s as the response is generated.
  ///
  /// The optional [abortTrigger] allows canceling the stream.
  Stream<MessageStreamEvent> createStream(
    MessageCreateRequest request, {
    Future<void>? abortTrigger,
  }) async* {
    final body = request.toJson();
    body['stream'] = true;

    final eventStream = postStream(
      '/v1/messages',
      body: body,
      abortTrigger: abortTrigger,
    );

    await for (final event in eventStream) {
      yield MessageStreamEvent.fromJson(event);
    }
  }

  /// Counts the number of tokens in a message.
  ///
  /// Returns the count of input tokens for the given request.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<TokenCountResponse> countTokens(
    TokenCountRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final response = await post(
      '/v1/messages/count_tokens',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );

    return TokenCountResponse.fromJson(response);
  }
}
