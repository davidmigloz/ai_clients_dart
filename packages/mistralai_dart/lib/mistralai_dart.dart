/// Dart client for the Mistral AI API.
///
/// This library provides a type-safe, resource-based interface to the
/// Mistral AI API including chat completions, embeddings, and model management.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:mistralai_dart/mistralai_dart.dart';
///
/// void main() async {
///   final client = MistralClient.withApiKey('your-api-key');
///
///   // Chat completion
///   final response = await client.chat.create(
///     request: ChatCompletionRequest(
///       model: 'mistral-small-latest',
///       messages: [
///         ChatMessage.user('Hello!'),
///       ],
///     ),
///   );
///   print(response.choices.first.message.content);
///
///   client.close();
/// }
/// ```
///
/// ## Features
///
/// - **Chat Completions**: Generate conversational responses with streaming
/// - **Classifications**: Text classification for content safety
/// - **Embeddings**: Generate text embeddings for semantic search
/// - **Files**: Upload and manage files for fine-tuning and batch processing
/// - **FIM**: Fill-in-the-Middle code completions with Codestral
/// - **Fine-tuning**: Train custom models
/// - **Batch**: Asynchronous large-scale processing
/// - **OCR**: Extract text from documents and images
/// - **Audio**: Speech-to-text transcription with streaming
/// - **Agents** (Beta): Pre-configured AI assistants
/// - **Conversations** (Beta): Flexible multi-turn interactions
/// - **Libraries** (Beta): Document storage for RAG
/// - **Models**: List and manage available models
/// - **Moderations**: Content moderation for safety
/// - **Multimodal**: Support for text and image inputs
/// - **Tool Calling**: Function/tool calling support
///
/// ## Resources
///
/// - [Mistral AI API Documentation](https://docs.mistral.ai/)
/// - [GitHub Repository](https://github.com/davidmigloz/ai_clients_dart)
library;

// --- Auth ---
export 'src/auth/auth_provider.dart';
// --- Client ---
export 'src/client/config.dart' show MistralConfig, RetryPolicy;
export 'src/client/mistral_client.dart';
// --- Errors ---
export 'src/errors/exceptions.dart';
// --- Extensions ---
export 'src/extensions/chat_completion_extensions.dart';
export 'src/extensions/chat_stream_extensions.dart';
// --- Models: Agents (Beta) ---
export 'src/models/agents/agent.dart';
export 'src/models/agents/agent_completion_request.dart';
export 'src/models/agents/agent_completion_response.dart';
export 'src/models/agents/agent_list.dart';
export 'src/models/agents/create_agent_request.dart';
export 'src/models/agents/update_agent_request.dart';
// --- Models: Audio ---
export 'src/models/audio/transcription_request.dart';
export 'src/models/audio/transcription_response.dart';
export 'src/models/audio/transcription_segment.dart';
export 'src/models/audio/transcription_stream_event.dart';
export 'src/models/audio/transcription_word.dart';
// --- Models: Batch ---
export 'src/models/batch/batch_error.dart';
export 'src/models/batch/batch_job.dart';
export 'src/models/batch/batch_job_list.dart';
export 'src/models/batch/batch_job_status.dart';
export 'src/models/batch/create_batch_job_request.dart';
// --- Models: Chat ---
export 'src/models/chat/chat_choice.dart';
export 'src/models/chat/chat_choice_delta.dart';
export 'src/models/chat/chat_completion_request.dart';
export 'src/models/chat/chat_completion_response.dart';
export 'src/models/chat/chat_completion_stream_response.dart';
export 'src/models/chat/chat_message.dart';
// --- Models: Classifications ---
export 'src/models/classifications/chat_classification_request.dart';
export 'src/models/classifications/classification_request.dart';
export 'src/models/classifications/classification_response.dart';
export 'src/models/classifications/classification_result.dart';
// --- Models: Content ---
export 'src/models/content/content_part.dart';
// --- Models: Conversations (Beta) ---
export 'src/models/conversations/conversation.dart';
export 'src/models/conversations/conversation_entry.dart';
export 'src/models/conversations/conversation_request.dart';
export 'src/models/conversations/conversation_response.dart';
// --- Models: Embeddings ---
export 'src/models/embeddings/embedding_data.dart';
export 'src/models/embeddings/embedding_dtype.dart';
export 'src/models/embeddings/embedding_request.dart';
export 'src/models/embeddings/embedding_response.dart';
// --- Models: Files ---
export 'src/models/files/file_list.dart';
export 'src/models/files/file_object.dart';
export 'src/models/files/file_purpose.dart';
export 'src/models/files/signed_url.dart';
// --- Models: FIM ---
export 'src/models/fim/fim_choice.dart';
export 'src/models/fim/fim_choice_delta.dart';
export 'src/models/fim/fim_completion_request.dart';
export 'src/models/fim/fim_completion_response.dart';
export 'src/models/fim/fim_completion_stream_response.dart';
// --- Models: Fine-tuning ---
export 'src/models/fine_tuning/archive_ft_model_response.dart';
export 'src/models/fine_tuning/checkpoint.dart';
export 'src/models/fine_tuning/classifier_target_out.dart';
export 'src/models/fine_tuning/create_fine_tuning_job_request.dart';
export 'src/models/fine_tuning/fine_tuning_integration.dart';
export 'src/models/fine_tuning/fine_tuning_job.dart';
export 'src/models/fine_tuning/fine_tuning_job_list.dart';
export 'src/models/fine_tuning/fine_tuning_job_status.dart';
export 'src/models/fine_tuning/ft_classifier_loss_function.dart';
export 'src/models/fine_tuning/ft_model_capabilities_out.dart';
export 'src/models/fine_tuning/ft_model_out.dart';
export 'src/models/fine_tuning/hyperparameters.dart';
export 'src/models/fine_tuning/training_event.dart';
export 'src/models/fine_tuning/training_file.dart';
export 'src/models/fine_tuning/update_ft_model_request.dart';
// --- Models: Libraries (Beta) ---
export 'src/models/libraries/entity_type.dart';
export 'src/models/libraries/library.dart';
export 'src/models/libraries/library_document.dart';
export 'src/models/libraries/processing_status_out.dart';
export 'src/models/libraries/share_level.dart';
export 'src/models/libraries/sharing_delete_request.dart';
export 'src/models/libraries/sharing_list.dart';
export 'src/models/libraries/sharing_request.dart';
export 'src/models/libraries/sharing_response.dart';
// --- Models: Metadata ---
export 'src/models/metadata/finish_reason.dart';
export 'src/models/metadata/prediction.dart';
export 'src/models/metadata/prompt_mode.dart';
export 'src/models/metadata/response_format.dart';
export 'src/models/metadata/usage_info.dart';
// --- Models: Models API ---
export 'src/models/models/model.dart';
export 'src/models/models/model_list.dart';
// --- Models: Moderations ---
export 'src/models/moderations/category_scores.dart';
export 'src/models/moderations/chat_moderation_request.dart';
export 'src/models/moderations/moderation_request.dart';
export 'src/models/moderations/moderation_response.dart';
export 'src/models/moderations/moderation_result.dart';
// --- Models: OCR ---
export 'src/models/ocr/ocr_document.dart';
export 'src/models/ocr/ocr_image.dart';
export 'src/models/ocr/ocr_page.dart';
export 'src/models/ocr/ocr_request.dart';
export 'src/models/ocr/ocr_response.dart';
// --- Models: Tools ---
export 'src/models/tools/function_call.dart';
export 'src/models/tools/function_definition.dart';
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_call.dart';
export 'src/models/tools/tool_choice.dart';
// --- Utils ---
export 'src/utils/job_poller.dart';
export 'src/utils/paginator.dart';
