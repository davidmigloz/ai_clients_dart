/// Anthropic API client for Dart.
///
/// Provides type-safe access to Claude models via the Anthropic API.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
///
/// final client = AnthropicClient(
///   config: AnthropicConfig(
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
///
/// // Use client.messages, client.models, etc.
///
/// client.close();
/// ```
///
/// ## Environment Configuration
///
/// ```dart
/// final client = AnthropicClient.fromEnvironment();
/// // Uses ANTHROPIC_API_KEY environment variable
/// ```
library;

// Authentication
export 'src/auth/auth_provider.dart'
    show
        ApiKeyCredentials,
        ApiKeyProvider,
        AuthCredentials,
        AuthProvider,
        NoAuthCredentials,
        NoAuthProvider;

// Client
export 'src/client/anthropic_client.dart' show AnthropicClient;
export 'src/client/config.dart' show AnthropicConfig, RetryPolicy;

// Errors
export 'src/errors/exceptions.dart'
    show
        AbortedException,
        AbortionStage,
        AnthropicException,
        ApiException,
        AuthenticationException,
        RateLimitException,
        RequestMetadata,
        ResponseMetadata,
        TimeoutException,
        ValidationException;

// Extensions
export 'src/extensions/message_extensions.dart';

// Models - Batches
export 'src/models/batches/batch_request.dart';
export 'src/models/batches/message_batch.dart';

// Models - Beta Config
export 'src/models/beta/config/container.dart';
export 'src/models/beta/config/output_config.dart';

// Models - Beta Tools
export 'src/models/beta/tools/code_execution_tool.dart';
export 'src/models/beta/tools/computer_use_tool.dart';
export 'src/models/beta/tools/mcp_toolset.dart';

// Models - Completions (Legacy)
export 'src/models/completions/completion.dart';

// Models - Content
export 'src/models/content/content_block.dart';
export 'src/models/content/input_content_block.dart';

// Models - Files (Beta)
export 'src/models/files/file_delete_response.dart';
export 'src/models/files/file_list_response.dart';
export 'src/models/files/file_metadata.dart';

// Models - Messages
export 'src/models/messages/input_message.dart';
export 'src/models/messages/message.dart';
export 'src/models/messages/message_create_request.dart';
export 'src/models/messages/message_role.dart';
export 'src/models/messages/thinking_config.dart';

// Models - Metadata
export 'src/models/metadata/cache_control.dart';
export 'src/models/metadata/metadata.dart';
export 'src/models/metadata/processing_status.dart';
export 'src/models/metadata/service_tier.dart';
export 'src/models/metadata/stop_reason.dart';
export 'src/models/metadata/usage.dart';

// Models - Models Domain
export 'src/models/models/model_info.dart';

// Models - Skills (Beta)
export 'src/models/skills/skill.dart';
export 'src/models/skills/skill_list_response.dart';
export 'src/models/skills/skill_version.dart';

// Models - Sources
export 'src/models/sources/document_source.dart';
export 'src/models/sources/image_source.dart';

// Models - Streaming
export 'src/models/streaming/content_block_delta.dart';
export 'src/models/streaming/message_delta.dart';
export 'src/models/streaming/message_stream_event.dart';

// Models - Token Counting
export 'src/models/tokens/token_count.dart';

// Models - Tools
export 'src/models/tools/built_in_tools.dart';
export 'src/models/tools/input_schema.dart';
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_choice.dart';

// Resources
export 'src/resources/files_resource.dart';
export 'src/resources/message_batches_resource.dart';
export 'src/resources/messages_resource.dart';
export 'src/resources/models_resource.dart';
export 'src/resources/skills_resource.dart';

// Utilities
export 'src/utils/streaming_parser.dart' show SseEventExtension, SseParser;
