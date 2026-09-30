import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/system_one/_system_one_helpers.dart';
import '../models/system_one/system_one_request.dart';
import '../models/system_one/system_one_response.dart';
import 'base_resource.dart';

/// Resource for the local System One decision API in Ollama v0.35.0 and later.
///
/// Returns choices, probabilities, and scores in one JSON response. Requires a
/// compatible local model such as Nimble or Tev1; cloud and streaming are not
/// supported. The server validates body and context limits without truncation.
class SystemOneResource extends ResourceBase {
  /// Creates a System One resource using the client's shared transport.
  SystemOneResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Answers the typed questions in [request].
  ///
  /// [abortTrigger] cancels an in-flight request through the existing transport.
  Future<SystemOneResponse> create({
    required SystemOneRequest request,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/systemone');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return SystemOneResponse.fromJson(
      systemOneObject(jsonDecode(response.body), 'SystemOneResponse'),
    );
  }
}
