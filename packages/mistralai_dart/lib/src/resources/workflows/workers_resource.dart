import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/worker_info.dart';
import '../base_resource.dart';

/// Resource for workflow worker operations.
///
/// Provides methods to retrieve worker information.
class WorkersResource extends ResourceBase {
  /// Creates a [WorkersResource].
  WorkersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets information about the current worker.
  Future<WorkerInfo> whoami() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/workers/whoami');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkerInfo.fromJson(responseBody);
  }
}
