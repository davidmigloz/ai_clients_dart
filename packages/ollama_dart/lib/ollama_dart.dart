/// Dart client for the Ollama API.
///
/// This library provides a type-safe, well-documented interface to the
/// [Ollama](https://ollama.com/) API for local and cloud inference, local
/// decision models, model management, and hosted web search.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:ollama_dart/ollama_dart.dart';
///
/// void main() async {
///   // Create client (connects to localhost:11434 by default)
///   final client = OllamaClient();
///
///   // Chat completion
///   final response = await client.chat.create(
///     request: ChatRequest(
///       model: 'gpt-oss',
///       messages: [
///         ChatMessage.user('Hello!'),
///       ],
///     ),
///   );
///   print(response.message?.content);
///
///   // Streaming chat
///   await for (final chunk in client.chat.createStream(
///     request: ChatRequest(
///       model: 'gpt-oss',
///       messages: [
///         ChatMessage.user('Tell me a story'),
///       ],
///     ),
///   )) {
///     print(chunk.message?.content ?? '');
///   }
///
///   client.close();
/// }
/// ```
///
/// ## Features
///
/// - **Chat Completions**: Multi-turn conversations with tool calling
/// - **Text Generation**: Raw text generation with streaming
/// - **Embeddings**: Generate vector embeddings for text
/// - **Model Management**: List, pull, push, create, copy, delete models
/// - **Thinking Mode**: Extended reasoning for supported models
/// - **Structured Output**: JSON schema-constrained generation
/// - **System One**: Local choice, probability, and scoring decisions
/// - **Blobs**: Binary model-file uploads
/// - **Web**: Hosted search and page fetching with a cloud-configured client
library;

// Authentication
export 'src/auth/auth_provider.dart'
    show
        AuthCredentials,
        AuthProvider,
        BearerTokenCredentials,
        BearerTokenProvider,
        NoAuthCredentials,
        NoAuthProvider;
// Client
export 'src/client/config.dart' show OllamaConfig, RetryPolicy;
export 'src/client/ollama_client.dart' show OllamaClient;
// Exceptions
export 'src/errors/exceptions.dart'
    show
        AbortedException,
        ApiException,
        AuthenticationException,
        OllamaException,
        RateLimitException,
        StreamException,
        TimeoutException,
        ValidationException;
// Chat Models
export 'src/models/chat/chat_message.dart'
    show
        ChatMessage,
        MessageRole,
        messageRoleFromNullableString,
        messageRoleFromString,
        messageRoleToString;
export 'src/models/chat/chat_request.dart' show ChatRequest;
export 'src/models/chat/chat_response.dart'
    show ChatResponse, ChatResponseMessage;
export 'src/models/chat/chat_stream_event.dart' show ChatStreamEvent;
// Common Models
export 'src/models/common/done_reason.dart'
    show DoneReason, doneReasonFromString, doneReasonToString;
export 'src/models/common/keep_alive.dart'
    show KeepAlive, KeepAliveDuration, KeepAliveNumber;
export 'src/models/common/response_format.dart'
    show JsonFormat, ResponseFormat, SchemaFormat;
export 'src/models/common/stop_sequence.dart'
    show StopList, StopSequence, StopString;
export 'src/models/common/think_value.dart'
    show ThinkEnabled, ThinkLevel, ThinkValue, ThinkWithLevel, ThinkWithString;
// Completions Models
export 'src/models/completions/generate_request.dart' show GenerateRequest;
export 'src/models/completions/generate_response.dart' show GenerateResponse;
export 'src/models/completions/generate_stream_event.dart'
    show GenerateStreamEvent;
export 'src/models/completions/logprob.dart' show Logprob, TokenLogprob;
// Embeddings Models
export 'src/models/embeddings/embed_input.dart'
    show EmbedInput, EmbedInputList, EmbedInputString;
export 'src/models/embeddings/embed_request.dart' show EmbedRequest;
export 'src/models/embeddings/embed_response.dart' show EmbedResponse;
// Metadata Models
export 'src/models/metadata/error_response.dart' show ErrorResponse;
export 'src/models/metadata/model_options.dart' show ModelOptions;
export 'src/models/metadata/version_response.dart' show VersionResponse;
// Models Management
export 'src/models/models/copy_request.dart' show CopyRequest;
export 'src/models/models/create_request.dart' show CreateRequest;
export 'src/models/models/delete_request.dart' show DeleteRequest;
export 'src/models/models/list_response.dart' show ListResponse;
export 'src/models/models/model_details.dart' show ModelDetails;
export 'src/models/models/model_summary.dart' show ModelSummary;
export 'src/models/models/model_tensor.dart' show ModelTensor;
export 'src/models/models/model_thinking.dart' show ModelThinking;
export 'src/models/models/ps_response.dart' show PsResponse;
export 'src/models/models/pull_request.dart' show PullRequest;
export 'src/models/models/push_request.dart' show PushRequest;
export 'src/models/models/running_model.dart' show RunningModel;
export 'src/models/models/show_request.dart' show ShowRequest;
export 'src/models/models/show_response.dart' show ShowResponse;
export 'src/models/models/status_event.dart' show StatusEvent;
export 'src/models/models/status_response.dart' show StatusResponse;
export 'src/models/system_one/system_one_answer.dart';
// System One Models
export 'src/models/system_one/system_one_content.dart';
export 'src/models/system_one/system_one_noul_criteria.dart';
export 'src/models/system_one/system_one_question.dart';
export 'src/models/system_one/system_one_request.dart';
export 'src/models/system_one/system_one_response.dart';
export 'src/models/system_one/system_one_usage.dart';
// Tools Models
export 'src/models/tools/tool_call.dart' show ToolCall, ToolCallFunction;
export 'src/models/tools/tool_definition.dart'
    show ToolDefinition, ToolFunction, ToolType;
// Web Models
export 'src/models/web/web_fetch_request.dart' show WebFetchRequest;
export 'src/models/web/web_fetch_response.dart' show WebFetchResponse;
export 'src/models/web/web_search_request.dart' show WebSearchRequest;
export 'src/models/web/web_search_response.dart' show WebSearchResponse;
export 'src/models/web/web_search_result.dart' show WebSearchResult;
