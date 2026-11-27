import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'campaigns_resource.dart';
import 'chat_completion_events_resource.dart';
import 'chat_completion_fields_resource.dart';
import 'dataset_records_resource.dart';
import 'datasets_resource.dart';
import 'evaluations_resource.dart';
import 'judges_resource.dart';
import 'logs_resource.dart';
import 'optimizations_resource.dart';
import 'pipelines_resource.dart';
import 'projects_resource.dart';
import 'scorers_resource.dart';
import 'spans_resource.dart';
import 'traces_resource.dart';

/// Resource for Observability API operations (beta).
///
/// Enterprise Public Preview. Query telemetry, read offline evaluations, and
/// manage datasets, scorers, and live evaluations.
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

  /// Historical sub-resource for campaigns. New applications can use [pipelines].
  late final CampaignsResource campaigns;

  /// Historical sub-resource for chat completion events. New applications can use [traces].
  late final ChatCompletionEventsResource chatCompletionEvents;

  /// Historical sub-resource for chat completion fields. New applications can use [traces].
  late final ChatCompletionFieldsResource chatCompletionFields;

  /// Sub-resource for datasets.
  late final DatasetsResource datasets;

  /// Sub-resource for dataset records.
  late final DatasetRecordsResource datasetRecords;

  /// Historical sub-resource for judges. New applications can use [scorers].
  late final JudgesResource judges;

  /// Sub-resource for traces.
  late final TracesResource traces;

  /// Sub-resource for spans.
  late final SpansResource spans;

  /// Sub-resource for logs.
  late final LogsResource logs;

  /// Sub-resource for projects.
  late final EvaluationProjectsResource projects;

  /// Sub-resource for evaluations.
  late final EvaluationsResource evaluations;

  /// Sub-resource for optimizations.
  late final OptimizationsResource optimizations;

  /// Sub-resource for scorers.
  late final ScorersResource scorers;

  /// Sub-resource for pipelines.
  late final PipelinesResource pipelines;

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
    traces = TracesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    spans = SpansResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    projects = EvaluationProjectsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    evaluations = EvaluationsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    optimizations = OptimizationsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    scorers = ScorersResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    pipelines = PipelinesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    logs = LogsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
