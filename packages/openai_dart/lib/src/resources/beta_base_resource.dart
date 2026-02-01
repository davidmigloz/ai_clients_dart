import 'dart:convert';

import 'base_resource.dart';

/// Base class for beta API resources.
///
/// This class extends [BaseResource] to add the `OpenAI-Beta` header
/// required for all beta API endpoints (Assistants, Threads, Runs, etc.).
abstract class BetaBaseResource extends BaseResource {
  /// Creates a [BetaBaseResource] with the given client.
  const BetaBaseResource(super.client);

  /// The beta feature version header value.
  ///
  /// Override this in subclasses if a different beta version is needed.
  String get betaVersion => 'assistants=v2';

  /// The headers to include with all beta API requests.
  Map<String, String> get _betaHeaders => {'OpenAI-Beta': betaVersion};

  @override
  Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    final response = await client.get(
      endpoint,
      queryParameters: queryParameters,
      headers: _betaHeaders,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String endpoint, {
    required Map<String, dynamic> body,
    Future<void>? abortTrigger,
  }) async {
    final response = await client.post(
      endpoint,
      body: jsonEncode(body),
      headers: _betaHeaders,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> deleteJson(
    String endpoint, {
    Future<void>? abortTrigger,
  }) async {
    final response = await client.delete(
      endpoint,
      headers: _betaHeaders,
      abortTrigger: abortTrigger,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
