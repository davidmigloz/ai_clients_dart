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
///   print(response.text);
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
/// - **Audio**: Speech-to-text transcription, text-to-speech synthesis, and voice management
/// - **Agents** (Beta): Pre-configured AI assistants
/// - **Conversations** (Beta): Flexible multi-turn interactions
/// - **Libraries** (Beta): Document storage for RAG
/// - **Observability** (Beta): Campaigns, datasets, judges, chat completion events
/// - **Workflows** (Beta): Workflow execution, scheduling, and management
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
export 'src/models/agents/agent_alias_response.dart';
export 'src/models/agents/agent_completion_request.dart';
export 'src/models/agents/agent_completion_response.dart';
export 'src/models/agents/agent_list.dart';
export 'src/models/agents/create_agent_request.dart';
export 'src/models/agents/update_agent_request.dart';
// --- Models: Audio ---
export 'src/models/audio/speech_output_format.dart';
export 'src/models/audio/speech_request.dart';
export 'src/models/audio/speech_response.dart';
export 'src/models/audio/speech_stream_event.dart';
export 'src/models/audio/transcription_request.dart';
export 'src/models/audio/transcription_response.dart';
export 'src/models/audio/transcription_segment.dart';
export 'src/models/audio/transcription_stream_event.dart';
export 'src/models/audio/transcription_word.dart';
export 'src/models/audio/voice_create_request.dart';
export 'src/models/audio/voice_list_response.dart';
export 'src/models/audio/voice_response.dart';
export 'src/models/audio/voice_update_request.dart';
// --- Models: Batch ---
export 'src/models/batch/batch_error.dart';
export 'src/models/batch/batch_job.dart';
export 'src/models/batch/batch_job_list.dart';
export 'src/models/batch/batch_job_status.dart';
export 'src/models/batch/batch_request.dart';
export 'src/models/batch/create_batch_job_request.dart';
// --- Models: Chat ---
export 'src/models/chat/chat_choice.dart';
export 'src/models/chat/chat_choice_delta.dart';
export 'src/models/chat/chat_completion_request.dart';
export 'src/models/chat/chat_completion_response.dart';
export 'src/models/chat/chat_completion_stream_response.dart';
export 'src/models/chat/chat_message.dart';
export 'src/models/chat/message_content.dart';
// --- Models: Classifications ---
export 'src/models/classifications/chat_classification_request.dart';
export 'src/models/classifications/classification_request.dart';
export 'src/models/classifications/classification_response.dart';
export 'src/models/classifications/classification_result.dart';
// --- Models: Content ---
export 'src/models/content/content_part.dart';
// --- Models: Conversations (Beta) ---
export 'src/models/conversations/confirmation_status.dart';
export 'src/models/conversations/conversation.dart';
export 'src/models/conversations/conversation_entry.dart';
export 'src/models/conversations/conversation_request.dart';
export 'src/models/conversations/conversation_response.dart';
// --- Models: Embeddings ---
export 'src/models/embeddings/embed_input.dart';
export 'src/models/embeddings/embedding_data.dart';
export 'src/models/embeddings/embedding_dtype.dart';
export 'src/models/embeddings/embedding_request.dart';
export 'src/models/embeddings/embedding_response.dart';
// --- Models: Files ---
export 'src/models/files/file_list.dart';
export 'src/models/files/file_object.dart';
export 'src/models/files/file_purpose.dart';
export 'src/models/files/file_visibility.dart';
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
export 'src/models/metadata/prompt_tokens_details.dart';
export 'src/models/metadata/reasoning_effort.dart';
export 'src/models/metadata/response_format.dart';
export 'src/models/metadata/stop_sequence.dart';
export 'src/models/metadata/usage_info.dart';
// --- Models: Models API ---
export 'src/models/models/model.dart';
export 'src/models/models/model_list.dart';
// --- Models: Moderations ---
export 'src/models/moderations/category_scores.dart';
export 'src/models/moderations/chat_moderation_request.dart';
export 'src/models/moderations/guardrail_config.dart';
export 'src/models/moderations/moderation_request.dart';
export 'src/models/moderations/moderation_response.dart';
export 'src/models/moderations/moderation_result.dart';
// --- Models: Observability (Beta) ---
export 'src/models/observability/base_field_definition.dart';
export 'src/models/observability/base_task_status.dart';
export 'src/models/observability/campaign_preview.dart';
export 'src/models/observability/campaign_previews.dart';
export 'src/models/observability/campaign_selected_events.dart';
export 'src/models/observability/campaign_status.dart';
export 'src/models/observability/chat_completion_event.dart';
export 'src/models/observability/chat_completion_event_ids.dart';
export 'src/models/observability/chat_completion_event_preview.dart';
export 'src/models/observability/chat_completion_events.dart';
export 'src/models/observability/chat_completion_field_options.dart';
export 'src/models/observability/chat_completion_fields.dart';
export 'src/models/observability/chat_transcription_event.dart';
export 'src/models/observability/conversation_payload.dart';
export 'src/models/observability/conversation_source.dart';
export 'src/models/observability/dataset.dart';
export 'src/models/observability/dataset_export.dart';
export 'src/models/observability/dataset_import_task.dart';
export 'src/models/observability/dataset_import_tasks.dart';
export 'src/models/observability/dataset_preview.dart';
export 'src/models/observability/dataset_previews.dart';
export 'src/models/observability/dataset_record.dart';
export 'src/models/observability/dataset_records.dart';
export 'src/models/observability/delete_dataset_records_in_schema.dart';
export 'src/models/observability/feed_result.dart';
export 'src/models/observability/field_group.dart';
export 'src/models/observability/field_option_count_item.dart';
export 'src/models/observability/field_option_counts.dart';
export 'src/models/observability/field_option_counts_in_schema.dart';
export 'src/models/observability/filter_condition.dart';
export 'src/models/observability/filter_group.dart';
export 'src/models/observability/filter_node.dart';
export 'src/models/observability/filter_payload.dart';
export 'src/models/observability/get_chat_completion_event_ids_in_schema.dart';
export 'src/models/observability/get_chat_completion_events_in_schema.dart';
export 'src/models/observability/judge_classification_output.dart';
export 'src/models/observability/judge_classification_output_option.dart';
export 'src/models/observability/judge_conversation_request.dart';
export 'src/models/observability/judge_output.dart';
export 'src/models/observability/judge_output_config.dart';
export 'src/models/observability/judge_output_type.dart';
export 'src/models/observability/judge_preview.dart';
export 'src/models/observability/judge_previews.dart';
export 'src/models/observability/judge_regression_output.dart';
export 'src/models/observability/observability_error.dart';
export 'src/models/observability/observability_error_code.dart';
export 'src/models/observability/observability_error_detail.dart';
export 'src/models/observability/paginated_result.dart';
export 'src/models/observability/pagination_info.dart';
export 'src/models/observability/patch_dataset_in_schema.dart';
export 'src/models/observability/post_campaign_in_schema.dart';
export 'src/models/observability/post_chat_completion_event_judging_in_schema.dart';
export 'src/models/observability/post_dataset_import_from_campaign_in_schema.dart';
export 'src/models/observability/post_dataset_import_from_dataset_in_schema.dart';
export 'src/models/observability/post_dataset_import_from_explorer_in_schema.dart';
export 'src/models/observability/post_dataset_import_from_file_in_schema.dart';
export 'src/models/observability/post_dataset_import_from_playground_in_schema.dart';
export 'src/models/observability/post_dataset_in_schema.dart';
export 'src/models/observability/post_dataset_record_in_schema.dart';
export 'src/models/observability/post_dataset_record_judging_in_schema.dart';
export 'src/models/observability/post_judge_in_schema.dart';
export 'src/models/observability/put_dataset_record_payload_in_schema.dart';
export 'src/models/observability/put_dataset_record_properties_in_schema.dart';
export 'src/models/observability/put_judge_in_schema.dart';
// --- Models: OCR ---
export 'src/models/ocr/ocr_document.dart';
export 'src/models/ocr/ocr_image.dart';
export 'src/models/ocr/ocr_page.dart';
export 'src/models/ocr/ocr_request.dart';
export 'src/models/ocr/ocr_response.dart';
// --- Models: Tools ---
export 'src/models/tools/connector_auth.dart';
export 'src/models/tools/function_call.dart';
export 'src/models/tools/function_definition.dart';
export 'src/models/tools/tool.dart';
export 'src/models/tools/tool_call.dart';
export 'src/models/tools/tool_call_confirmation.dart';
export 'src/models/tools/tool_choice.dart';
export 'src/models/tools/tool_configuration.dart';
// --- Models: Workflows (Beta) ---
export 'src/models/workflows/activity_task_completed_attributes_response.dart';
export 'src/models/workflows/activity_task_completed_response.dart';
export 'src/models/workflows/activity_task_failed_attributes.dart';
export 'src/models/workflows/activity_task_failed_response.dart';
export 'src/models/workflows/activity_task_retrying_attributes.dart';
export 'src/models/workflows/activity_task_retrying_response.dart';
export 'src/models/workflows/activity_task_started_attributes_response.dart';
export 'src/models/workflows/activity_task_started_response.dart';
export 'src/models/workflows/batch_execution_body.dart';
export 'src/models/workflows/batch_execution_response.dart';
export 'src/models/workflows/batch_execution_result.dart';
export 'src/models/workflows/custom_task_canceled_attributes.dart';
export 'src/models/workflows/custom_task_canceled_response.dart';
export 'src/models/workflows/custom_task_completed_attributes_response.dart';
export 'src/models/workflows/custom_task_completed_response.dart';
export 'src/models/workflows/custom_task_failed_attributes.dart';
export 'src/models/workflows/custom_task_failed_response.dart';
export 'src/models/workflows/custom_task_in_progress_attributes_response.dart';
export 'src/models/workflows/custom_task_in_progress_response.dart';
export 'src/models/workflows/custom_task_started_attributes_response.dart';
export 'src/models/workflows/custom_task_started_response.dart';
export 'src/models/workflows/custom_task_timed_out_attributes.dart';
export 'src/models/workflows/custom_task_timed_out_response.dart';
export 'src/models/workflows/deployment_detail_response.dart';
export 'src/models/workflows/deployment_list_response.dart';
export 'src/models/workflows/deployment_response.dart';
export 'src/models/workflows/deployment_worker_response.dart';
export 'src/models/workflows/encoded_payload_options.dart';
export 'src/models/workflows/event_progress_status.dart';
export 'src/models/workflows/event_source.dart';
export 'src/models/workflows/event_type.dart';
export 'src/models/workflows/failure.dart';
export 'src/models/workflows/json_patch_add.dart';
export 'src/models/workflows/json_patch_append.dart';
export 'src/models/workflows/json_patch_payload_response.dart';
export 'src/models/workflows/json_patch_remove.dart';
export 'src/models/workflows/json_patch_replace.dart';
export 'src/models/workflows/json_payload_response.dart';
export 'src/models/workflows/list_workflow_event_response.dart';
export 'src/models/workflows/network_encoded_input.dart';
export 'src/models/workflows/query_definition.dart';
export 'src/models/workflows/query_invocation_body.dart';
export 'src/models/workflows/query_workflow_response.dart';
export 'src/models/workflows/reset_invocation_body.dart';
export 'src/models/workflows/scalar_metric.dart';
export 'src/models/workflows/schedule_calendar.dart';
export 'src/models/workflows/schedule_definition.dart';
export 'src/models/workflows/schedule_definition_output.dart';
export 'src/models/workflows/schedule_interval.dart';
export 'src/models/workflows/schedule_overlap_policy.dart';
export 'src/models/workflows/schedule_policy.dart';
export 'src/models/workflows/schedule_range.dart';
export 'src/models/workflows/signal_definition.dart';
export 'src/models/workflows/signal_invocation_body.dart';
export 'src/models/workflows/signal_workflow_response.dart';
export 'src/models/workflows/stream_event_sse_payload.dart';
export 'src/models/workflows/stream_event_workflow_context.dart';
export 'src/models/workflows/tempo_get_trace_response.dart';
export 'src/models/workflows/tempo_trace_attribute.dart';
export 'src/models/workflows/tempo_trace_attribute_bool_value.dart';
export 'src/models/workflows/tempo_trace_attribute_int_value.dart';
export 'src/models/workflows/tempo_trace_attribute_string_value.dart';
export 'src/models/workflows/tempo_trace_batch.dart';
export 'src/models/workflows/tempo_trace_event.dart';
export 'src/models/workflows/tempo_trace_resource.dart';
export 'src/models/workflows/tempo_trace_scope.dart';
export 'src/models/workflows/tempo_trace_scope_kind.dart';
export 'src/models/workflows/tempo_trace_scope_span.dart';
export 'src/models/workflows/tempo_trace_span.dart';
export 'src/models/workflows/time_series_metric.dart';
export 'src/models/workflows/update_definition.dart';
export 'src/models/workflows/update_invocation_body.dart';
export 'src/models/workflows/update_workflow_response.dart';
export 'src/models/workflows/worker_info.dart';
export 'src/models/workflows/workflow.dart';
export 'src/models/workflows/workflow_archive_response.dart';
export 'src/models/workflows/workflow_basic_definition.dart';
export 'src/models/workflows/workflow_code_definition.dart';
export 'src/models/workflows/workflow_event_type.dart';
export 'src/models/workflows/workflow_execution_canceled_attributes.dart';
export 'src/models/workflows/workflow_execution_canceled_response.dart';
export 'src/models/workflows/workflow_execution_completed_attributes_response.dart';
export 'src/models/workflows/workflow_execution_completed_response.dart';
export 'src/models/workflows/workflow_execution_continued_as_new_attributes_response.dart';
export 'src/models/workflows/workflow_execution_continued_as_new_response.dart';
export 'src/models/workflows/workflow_execution_failed_attributes.dart';
export 'src/models/workflows/workflow_execution_failed_response.dart';
export 'src/models/workflows/workflow_execution_list_response.dart';
export 'src/models/workflows/workflow_execution_progress_trace_event.dart';
export 'src/models/workflows/workflow_execution_request.dart';
export 'src/models/workflows/workflow_execution_response.dart';
export 'src/models/workflows/workflow_execution_started_attributes_response.dart';
export 'src/models/workflows/workflow_execution_started_response.dart';
export 'src/models/workflows/workflow_execution_status.dart';
export 'src/models/workflows/workflow_execution_sync_response.dart';
export 'src/models/workflows/workflow_execution_trace_event.dart';
export 'src/models/workflows/workflow_execution_trace_events_response.dart';
export 'src/models/workflows/workflow_execution_trace_o_tel_response.dart';
export 'src/models/workflows/workflow_execution_trace_summary_response.dart';
export 'src/models/workflows/workflow_execution_trace_summary_span.dart';
export 'src/models/workflows/workflow_execution_without_result_response.dart';
export 'src/models/workflows/workflow_get_response.dart';
export 'src/models/workflows/workflow_list_response.dart';
export 'src/models/workflows/workflow_metadata.dart';
export 'src/models/workflows/workflow_metrics.dart';
export 'src/models/workflows/workflow_registration.dart';
export 'src/models/workflows/workflow_registration_get_response.dart';
export 'src/models/workflows/workflow_registration_list_response.dart';
export 'src/models/workflows/workflow_registration_with_worker_status.dart';
export 'src/models/workflows/workflow_schedule_list_response.dart';
export 'src/models/workflows/workflow_schedule_request.dart';
export 'src/models/workflows/workflow_schedule_response.dart';
export 'src/models/workflows/workflow_task_failed_attributes.dart';
export 'src/models/workflows/workflow_task_failed_response.dart';
export 'src/models/workflows/workflow_task_timed_out_attributes.dart';
export 'src/models/workflows/workflow_task_timed_out_response.dart';
export 'src/models/workflows/workflow_type.dart';
export 'src/models/workflows/workflow_unarchive_response.dart';
export 'src/models/workflows/workflow_update_request.dart';
export 'src/models/workflows/workflow_update_response.dart';
export 'src/models/workflows/workflow_with_worker_status.dart';
// --- Utils ---
export 'src/utils/job_poller.dart';
export 'src/utils/paginator.dart';
