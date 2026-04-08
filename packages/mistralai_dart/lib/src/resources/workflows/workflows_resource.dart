import 'package:http/http.dart' as http;

import '../../client/config.dart';
import '../../client/interceptor_chain.dart';
import '../../client/request_builder.dart';
import 'deployments_resource.dart';
import 'events_resource.dart';
import 'executions_resource.dart';
import 'metrics_resource.dart';
import 'registrations_resource.dart';
import 'runs_resource.dart';
import 'schedules_resource.dart';
import 'workers_resource.dart';
import 'workflow_core_resource.dart';

/// Resource for Workflows API operations (beta).
///
/// Provides access to all workflow sub-resources for managing workflows,
/// executions, deployments, events, registrations, runs, schedules, metrics,
/// and workers.
///
/// Example usage:
/// ```dart
/// // Get a workflow
/// final workflow = await client.workflows.core.get(
///   workflowIdentifier: 'my-workflow',
/// );
///
/// // Execute a workflow
/// final execution = await client.workflows.core.executeAsync(
///   workflowIdentifier: 'my-workflow',
///   request: WorkflowExecutionRequest(input: {'key': 'value'}),
/// );
///
/// // Stream execution events
/// await for (final event in client.workflows.executions.stream(
///   executionId: execution.executionId,
/// )) {
///   print(event.data);
/// }
///
/// // List runs
/// final runs = await client.workflows.runs.list();
/// ```
class WorkflowsResource {
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

  /// Sub-resource for core workflow operations (get, update, archive, execute).
  late final WorkflowCoreResource core;

  /// Sub-resource for execution operations.
  late final ExecutionsResource executions;

  /// Sub-resource for deployment operations.
  late final DeploymentsResource deployments;

  /// Sub-resource for event operations.
  late final EventsResource events;

  /// Sub-resource for registration operations.
  late final RegistrationsResource registrations;

  /// Sub-resource for run operations.
  late final RunsResource runs;

  /// Sub-resource for schedule operations.
  late final SchedulesResource schedules;

  /// Sub-resource for metrics operations.
  late final MetricsResource metrics;

  /// Sub-resource for worker operations.
  late final WorkersResource workers;

  /// Creates a [WorkflowsResource].
  WorkflowsResource({
    required this.config,
    required this.httpClient,
    required this.interceptorChain,
    required this.requestBuilder,
    this.ensureNotClosed,
  }) {
    core = WorkflowCoreResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    executions = ExecutionsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    deployments = DeploymentsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    events = EventsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    registrations = RegistrationsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    runs = RunsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    schedules = SchedulesResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    metrics = MetricsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
    workers = WorkersResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
