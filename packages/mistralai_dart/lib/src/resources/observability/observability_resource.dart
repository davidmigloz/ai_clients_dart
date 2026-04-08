import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'campaigns_resource.dart';
import 'chat_completion_events_resource.dart';
import 'chat_completion_fields_resource.dart';
import 'dataset_records_resource.dart';
import 'datasets_resource.dart';
import 'judges_resource.dart';

/// Resource for Observability API operations (beta).
///
/// The Observability API provides tools for monitoring, evaluating, and
/// curating chat completion events. Key features include:
/// - **Campaigns**: Automated evaluation of events using judges
/// - **Chat completion events**: Search and inspect logged completions
/// - **Chat completion fields**: Discover filterable fields
/// - **Datasets**: Curate conversation collections for evaluation
/// - **Dataset records**: Manage individual records within datasets
/// - **Judges**: Create LLM-based evaluators (classification or regression)
///
/// Example usage:
/// ```dart
/// // List all judges
/// final judges = await client.observability.judges.list();
///
/// // Search events
/// final events = await client.observability.chatCompletionEvents.search(
///   request: GetChatCompletionEventsInSchema(
///     searchParams: FilterPayload(),
///   ),
/// );
///
/// // Create a dataset and import events
/// final dataset = await client.observability.datasets.create(
///   request: PostDatasetInSchema(
///     name: 'Review Dataset',
///     description: 'Events to review',
///   ),
/// );
/// ```
class ObservabilityResource {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client httpClient;

  /// Interceptor chain.
  final InterceptorChain interceptorChain;

  /// Request builder.
  final RequestBuilder requestBuilder;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Sub-resource for campaigns.
  late final CampaignsResource campaigns;

  /// Sub-resource for chat completion events.
  late final ChatCompletionEventsResource chatCompletionEvents;

  /// Sub-resource for chat completion fields.
  late final ChatCompletionFieldsResource chatCompletionFields;

  /// Sub-resource for datasets.
  late final DatasetsResource datasets;

  /// Sub-resource for dataset records.
  late final DatasetRecordsResource datasetRecords;

  /// Sub-resource for judges.
  late final JudgesResource judges;

  /// Creates an [ObservabilityResource].
  ObservabilityResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  }) {
    campaigns = CampaignsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    chatCompletionEvents = ChatCompletionEventsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    chatCompletionFields = ChatCompletionFieldsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    datasets = DatasetsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    datasetRecords = DatasetRecordsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    judges = JudgesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
