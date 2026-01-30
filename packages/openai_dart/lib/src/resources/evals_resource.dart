import '../models/evals/evals.dart';
import 'base_resource.dart';

/// Resource for the Evals API.
///
/// The Evals API allows you to create and manage evaluations to test your
/// LLM integrations. Define testing criteria (graders) and run evaluations
/// against different data sources.
///
/// Access this resource through [OpenAIClient.evals].
///
/// ## Example
///
/// ```dart
/// // Create an evaluation
/// final eval = await client.evals.create(
///   CreateEvalRequest(
///     name: 'My Evaluation',
///     dataSourceConfig: EvalDataSourceConfig.custom(
///       itemSchema: {
///         'type': 'object',
///         'properties': {
///           'prompt': {'type': 'string'},
///           'expected': {'type': 'string'},
///         },
///       },
///     ),
///     testingCriteria: [
///       EvalGrader.stringCheck(
///         name: 'matches_expected',
///         input: '{{sample.output_text}}',
///         operation: StringCheckOperation.ilike,
///         reference: '%{{item.expected}}%',
///       ),
///     ],
///   ),
/// );
///
/// // Run the evaluation
/// final run = await client.evals.runs.create(
///   eval.id,
///   CreateEvalRunRequest(
///     dataSource: EvalRunDataSource.jsonlContent([
///       {'prompt': 'Say hello', 'expected': 'hello'},
///     ]),
///   ),
/// );
/// ```
class EvalsResource extends BaseResource {
  /// Creates an [EvalsResource] with the given client.
  EvalsResource(super.client);

  static const _endpoint = '/evals';

  EvalRunsResource? _runs;

  /// Access to evaluation run operations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.evals.runs.create(
  ///   evalId,
  ///   CreateEvalRunRequest(
  ///     dataSource: EvalRunDataSource.jsonlFile('file-abc123'),
  ///   ),
  /// );
  /// ```
  EvalRunsResource get runs => _runs ??= EvalRunsResource(client);

  /// Creates a new evaluation.
  ///
  /// ## Parameters
  ///
  /// - [request] - The evaluation creation request.
  ///
  /// ## Returns
  ///
  /// The created [Eval] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final eval = await client.evals.create(
  ///   CreateEvalRequest(
  ///     name: 'Sentiment Check',
  ///     dataSourceConfig: EvalDataSourceConfig.custom(
  ///       itemSchema: {'type': 'object', 'properties': {'text': {'type': 'string'}}},
  ///     ),
  ///     testingCriteria: [
  ///       EvalGrader.labelModel(
  ///         name: 'sentiment',
  ///         model: 'gpt-4o-mini',
  ///         labels: ['positive', 'negative'],
  ///         passingLabels: ['positive'],
  ///         input: [LabelModelInput.user('Classify: {{sample.output_text}}')],
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<Eval> create(CreateEvalRequest request) async {
    final json = await postJson(_endpoint, body: request.toJson());
    return Eval.fromJson(json);
  }

  /// Lists all evaluations.
  ///
  /// ## Parameters
  ///
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc').
  /// - [orderBy] - Field to sort by ('created_at' or 'updated_at').
  ///
  /// ## Returns
  ///
  /// An [EvalList] containing the evaluations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final evals = await client.evals.list(limit: 10);
  /// for (final eval in evals.data) {
  ///   print('${eval.id}: ${eval.name}');
  /// }
  /// ```
  Future<EvalList> list({
    String? after,
    int? limit,
    String? order,
    String? orderBy,
  }) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (orderBy != null) queryParams['order_by'] = orderBy;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return EvalList.fromJson(json);
  }

  /// Retrieves an evaluation by ID.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  ///
  /// ## Returns
  ///
  /// The [Eval] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final eval = await client.evals.retrieve('eval-abc123');
  /// print('Name: ${eval.name}');
  /// ```
  Future<Eval> retrieve(String evalId) async {
    final json = await getJson('$_endpoint/$evalId');
    return Eval.fromJson(json);
  }

  /// Updates an evaluation.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation to update.
  /// - [request] - The update request.
  ///
  /// ## Returns
  ///
  /// The updated [Eval] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.evals.update(
  ///   'eval-abc123',
  ///   UpdateEvalRequest(name: 'New Name'),
  /// );
  /// ```
  Future<Eval> update(String evalId, UpdateEvalRequest request) async {
    final json = await postJson('$_endpoint/$evalId', body: request.toJson());
    return Eval.fromJson(json);
  }

  /// Deletes an evaluation.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteEvalResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.evals.delete('eval-abc123');
  /// print('Deleted: ${response.deleted}');
  /// ```
  Future<DeleteEvalResponse> delete(String evalId) async {
    final json = await deleteJson('$_endpoint/$evalId');
    return DeleteEvalResponse.fromJson(json);
  }
}

/// Resource for evaluation run operations.
///
/// Runs execute evaluations against specific data sources. Each run
/// processes the data and evaluates it against the parent evaluation's
/// graders.
class EvalRunsResource extends BaseResource {
  /// Creates an [EvalRunsResource] with the given client.
  EvalRunsResource(super.client);

  EvalOutputItemsResource? _outputItems;

  /// Access to output item operations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final items = await client.evals.runs.outputItems.list(
  ///   evalId,
  ///   runId,
  ///   limit: 10,
  /// );
  /// ```
  EvalOutputItemsResource get outputItems =>
      _outputItems ??= EvalOutputItemsResource(client);

  /// Creates a new evaluation run.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the parent evaluation.
  /// - [request] - The run creation request.
  ///
  /// ## Returns
  ///
  /// The created [EvalRun] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.evals.runs.create(
  ///   'eval-abc123',
  ///   CreateEvalRunRequest(
  ///     name: 'Test Run',
  ///     dataSource: EvalRunDataSource.jsonlContent([
  ///       {'prompt': 'Hello', 'expected': 'Hi'},
  ///     ]),
  ///   ),
  /// );
  /// ```
  Future<EvalRun> create(String evalId, CreateEvalRunRequest request) async {
    final json = await postJson('/evals/$evalId/runs', body: request.toJson());
    return EvalRun.fromJson(json);
  }

  /// Lists runs for an evaluation.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc').
  /// - [status] - Filter by status.
  ///
  /// ## Returns
  ///
  /// An [EvalRunList] containing the runs.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final runs = await client.evals.runs.list(
  ///   'eval-abc123',
  ///   status: EvalRunStatus.completed,
  /// );
  /// ```
  Future<EvalRunList> list(
    String evalId, {
    String? after,
    int? limit,
    String? order,
    EvalRunStatus? status,
  }) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (status != null) queryParams['status'] = status.toJson();

    final json = await getJson(
      '/evals/$evalId/runs',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return EvalRunList.fromJson(json);
  }

  /// Retrieves a run by ID.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [runId] - The ID of the run.
  ///
  /// ## Returns
  ///
  /// The [EvalRun] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.evals.runs.retrieve('eval-abc123', 'run-xyz789');
  /// print('Status: ${run.status}');
  /// ```
  Future<EvalRun> retrieve(String evalId, String runId) async {
    final json = await getJson('/evals/$evalId/runs/$runId');
    return EvalRun.fromJson(json);
  }

  /// Deletes a run.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [runId] - The ID of the run to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteEvalRunResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.evals.runs.delete('eval-abc123', 'run-xyz789');
  /// print('Deleted: ${response.deleted}');
  /// ```
  Future<DeleteEvalRunResponse> delete(String evalId, String runId) async {
    final json = await deleteJson('/evals/$evalId/runs/$runId');
    return DeleteEvalRunResponse.fromJson(json);
  }

  /// Cancels a running evaluation.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [runId] - The ID of the run to cancel.
  ///
  /// ## Returns
  ///
  /// The canceled [EvalRun] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.evals.runs.cancel('eval-abc123', 'run-xyz789');
  /// print('Status: ${run.status}'); // canceled
  /// ```
  Future<EvalRun> cancel(String evalId, String runId) async {
    final json = await postJson('/evals/$evalId/runs/$runId/cancel', body: {});
    return EvalRun.fromJson(json);
  }
}

/// Resource for evaluation output item operations.
///
/// Output items contain the results of individual evaluations within a run.
class EvalOutputItemsResource extends BaseResource {
  /// Creates an [EvalOutputItemsResource] with the given client.
  EvalOutputItemsResource(super.client);

  /// Lists output items for a run.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [runId] - The ID of the run.
  /// - [after] - Cursor for pagination.
  /// - [limit] - Maximum number to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc').
  /// - [status] - Filter by status (pass/fail).
  ///
  /// ## Returns
  ///
  /// An [EvalOutputItemList] containing the items.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Get all failed items
  /// final items = await client.evals.runs.outputItems.list(
  ///   'eval-abc123',
  ///   'run-xyz789',
  ///   status: EvalOutputItemStatus.fail,
  /// );
  /// for (final item in items.data) {
  ///   print('Failed: ${item.id}');
  /// }
  /// ```
  Future<EvalOutputItemList> list(
    String evalId,
    String runId, {
    String? after,
    int? limit,
    String? order,
    EvalOutputItemStatus? status,
  }) async {
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (status != null) queryParams['status'] = status.toJson();

    final json = await getJson(
      '/evals/$evalId/runs/$runId/output_items',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return EvalOutputItemList.fromJson(json);
  }

  /// Retrieves an output item by ID.
  ///
  /// ## Parameters
  ///
  /// - [evalId] - The ID of the evaluation.
  /// - [runId] - The ID of the run.
  /// - [outputItemId] - The ID of the output item.
  ///
  /// ## Returns
  ///
  /// The [EvalOutputItem] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final item = await client.evals.runs.outputItems.retrieve(
  ///   'eval-abc123',
  ///   'run-xyz789',
  ///   'item-def456',
  /// );
  /// print('Sample output: ${item.sample.outputText}');
  /// ```
  Future<EvalOutputItem> retrieve(
    String evalId,
    String runId,
    String outputItemId,
  ) async {
    final json = await getJson(
      '/evals/$evalId/runs/$runId/output_items/$outputItemId',
    );
    return EvalOutputItem.fromJson(json);
  }
}
