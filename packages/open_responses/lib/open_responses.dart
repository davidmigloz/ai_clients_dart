/// OpenResponses API client for Dart.
///
/// Provides a unified, type-safe interface for interacting with multiple
/// LLM providers through the OpenResponses specification.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:open_responses/open_responses.dart';
///
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     authProvider: BearerTokenProvider('your-api-key'),
///   ),
/// );
///
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: ResponseTextInput('Hello, world!'),
///   ),
/// );
///
/// print(response.outputText);
///
/// client.close();
/// ```
///
/// ## Using with Different Providers
///
/// ### OpenAI (Default)
/// ```dart
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     authProvider: BearerTokenProvider(Platform.environment['OPENAI_API_KEY']!),
///   ),
/// );
/// ```
///
/// ### Ollama (Local)
/// ```dart
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     baseUrl: 'http://localhost:11434/v1',
///     // No auth needed for local Ollama
///   ),
/// );
/// ```
///
/// ## Learn More
///
/// - [OpenResponses Specification](https://www.openresponses.org/)
library;

// Authentication
export 'src/auth/auth_provider.dart';

// Client
export 'src/client/config.dart';
export 'src/client/open_responses_client.dart';
export 'src/client/response_stream.dart';
export 'src/client/streaming_event_accumulator.dart';

// Errors
export 'src/errors/exceptions.dart';

// Extensions
export 'src/extensions/response_extensions.dart';
export 'src/extensions/streaming_extensions.dart';

// Models - Common
export 'src/models/common/copy_with_sentinel.dart';
export 'src/models/common/equality_helpers.dart';

// Models - Content
export 'src/models/content/annotation.dart';
export 'src/models/content/input_content.dart';
export 'src/models/content/logprob.dart';
export 'src/models/content/output_content.dart';
export 'src/models/content/reasoning_summary_content.dart';

// Models - Items
export 'src/models/items/item.dart';
export 'src/models/items/output_item.dart';

// Models - Metadata (Enums)
export 'src/models/metadata/function_call_status.dart';
export 'src/models/metadata/image_detail.dart';
export 'src/models/metadata/include.dart';
export 'src/models/metadata/item_status.dart';
export 'src/models/metadata/message_role.dart';
export 'src/models/metadata/reasoning_effort.dart';
export 'src/models/metadata/reasoning_summary.dart';
export 'src/models/metadata/response_status.dart';
export 'src/models/metadata/service_tier.dart';
export 'src/models/metadata/truncation.dart';
export 'src/models/metadata/verbosity.dart';

// Models - Request
export 'src/models/request/create_response_request.dart';
export 'src/models/request/reasoning_config.dart';
export 'src/models/request/stream_options.dart';
export 'src/models/request/text_config.dart';

// Models - Response
export 'src/models/response/error_payload.dart';
export 'src/models/response/incomplete_details.dart';
export 'src/models/response/response_resource.dart';
export 'src/models/response/usage.dart';

// Models - Streaming
export 'src/models/streaming/streaming_event.dart';

// Models - Tools
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_choice.dart';

// Resources
export 'src/resources/responses_resource.dart';
