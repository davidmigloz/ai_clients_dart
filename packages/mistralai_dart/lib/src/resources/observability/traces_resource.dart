import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/get_span.dart';
import '../../models/observability/get_spans.dart';
import '../../models/observability/get_trace.dart';
import '../../models/observability/get_trace_field_options.dart';
import '../../models/observability/get_trace_fields.dart';
import '../../models/observability/get_traces.dart';
import '../../models/observability/traces_request.dart';
import '../base_resource.dart';

/// Resource for observability trace operations (beta).
///
/// Traces capture end-to-end execution of agent and workflow runs. This
/// resource lets you search traces, inspect their spans, and discover the
/// filterable fields available for trace queries.
///
/// Example usage:
/// ```dart
/// // Search traces
/// final traces = await client.observability.traces.search(
///   request: const TracesRequest(searchExpression: 'status_code = "Error"'),
/// );
///
/// // Get a single trace and its spans
/// final trace = await client.observability.traces.getById(traceId: 't-123');
/// final spans = await client.observability.traces.getSpans(traceId: 't-123');
/// ```
class TracesResource extends ResourceBase {
  /// Creates a [TracesResource].
  TracesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Searches for traces.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetTraces> search({
    TracesRequest? request,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    final url = requestBuilder.buildUrl(
      '/v1/observability/traces/search',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode((request ?? const TracesRequest()).toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetTraces.fromJson(responseBody);
  }

  /// Lists the available trace fields.
  Future<GetTraceFields> getFields() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/traces/fields');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetTraceFields.fromJson(responseBody);
  }

  /// Fetches the available options for a specific trace field.
  ///
  /// - [from]/[to] bound the time range used to compute the options.
  Future<GetTraceFieldOptions> fetchFieldOptions({
    required String fieldName,
    String? from,
    String? to,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final url = requestBuilder.buildUrl(
      '/v1/observability/traces/fields/$fieldName/options',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetTraceFieldOptions.fromJson(responseBody);
  }

  /// Gets a trace by ID.
  Future<GetTrace> getById({required String traceId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/traces/$traceId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetTrace.fromJson(responseBody);
  }

  /// Gets the spans of a trace.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  /// - [pageSize] limits the number of results per page.
  /// - [cursor] continues a previous page.
  Future<GetSpans> getSpans({
    required String traceId,
    String? from,
    String? to,
    int? pageSize,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    final url = requestBuilder.buildUrl(
      '/v1/observability/traces/$traceId/spans',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpans.fromJson(responseBody);
  }

  /// Gets a single span within a trace by ID.
  ///
  /// - [from]/[to] bound the time range (ISO 8601 / RFC 3339).
  Future<GetSpan> getSpanById({
    required String traceId,
    required String spanId,
    String? from,
    String? to,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final url = requestBuilder.buildUrl(
      '/v1/observability/traces/$traceId/spans/$spanId',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GetSpan.fromJson(responseBody);
  }
}
