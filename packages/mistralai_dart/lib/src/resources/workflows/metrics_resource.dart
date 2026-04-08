import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/workflow_metrics.dart';
import '../base_resource.dart';

/// Resource for workflow metrics operations.
///
/// Provides methods to retrieve workflow metrics.
class MetricsResource extends ResourceBase {
  /// Creates a [MetricsResource].
  MetricsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets metrics for a workflow.
  ///
  /// Use [startTime] and [endTime] to filter the time range (ISO 8601 format).
  Future<WorkflowMetrics> get({
    required String workflowName,
    String? startTime,
    String? endTime,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (startTime != null) queryParams['start_time'] = startTime;
    if (endTime != null) queryParams['end_time'] = endTime;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/$workflowName/metrics',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowMetrics.fromJson(responseBody);
  }
}
