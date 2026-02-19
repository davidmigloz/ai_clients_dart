/// Dart client for the OpenAI API.
///
/// This is the main entry point providing access to modern APIs including:
/// - Chat Completions (GPT-4, GPT-4o, etc.)
/// - Responses API (recommended unified API with built-in tools)
/// - Embeddings, Images, Audio, Files, Batches, Fine-tuning, Moderations
///
/// For deprecated Assistants API, import `package:openai_dart/openai_dart_assistants.dart`.
/// For Realtime API, import `package:openai_dart/openai_dart_realtime.dart`.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:openai_dart/openai_dart.dart';
///
/// final client = OpenAIClient.fromEnvironment();
///
/// final response = await client.chat.completions.create(
///   ChatCompletionCreateRequest(
///     model: 'gpt-4o',
///     messages: [ChatMessage.user('Hello!')],
///   ),
/// );
///
/// print(response.text);
/// ```
library;

// Auth
export 'src/auth/auth_provider.dart';
// Client
export 'src/client/config.dart';
export 'src/client/interceptor_chain.dart';
export 'src/client/openai_client.dart';
export 'src/client/retry_wrapper.dart';
// Errors
export 'src/errors/exceptions.dart';
// Extensions
export 'src/extensions/extensions.dart';
// Interceptors
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/error_interceptor.dart';
export 'src/interceptors/interceptor.dart';
export 'src/interceptors/logging_interceptor.dart';
// Models - Audio
export 'src/models/audio/audio.dart';
// Models - Batches
export 'src/models/batches/batches.dart';
// Models - Chat
export 'src/models/chat/chat.dart';
// Models - Chatkit
export 'src/models/chatkit/chatkit.dart';
// Models - Common
export 'src/models/common/common.dart';
// Models - Completions (Legacy)
export 'src/models/completions/completions.dart';
// Models - Containers
export 'src/models/containers/containers.dart';
// Models - Conversations
export 'src/models/conversations/conversations.dart';
// Models - Embeddings
export 'src/models/embeddings/embeddings.dart';
// Models - Evals
export 'src/models/evals/evals.dart';
// Models - Files
export 'src/models/files/files.dart';
// Models - Fine-tuning
export 'src/models/fine_tuning/fine_tuning.dart';
// Models - Images
export 'src/models/images/images.dart';
// Models - Models (metadata)
export 'src/models/models/models.dart';
// Models - Moderations
export 'src/models/moderations/moderations.dart';
// Models - Responses
export 'src/models/responses/responses.dart';
// Models - Skills
export 'src/models/skills/skills.dart';
// Models - Streaming
export 'src/models/streaming/streaming.dart';
// Models - Tools
export 'src/models/tools/tools.dart';
// Models - Videos
export 'src/models/videos/videos.dart';
// Resources
export 'src/resources/resources.dart';
// Utils
export 'src/utils/json_helpers.dart';
export 'src/utils/request_id.dart';
export 'src/utils/streaming_parser.dart';
