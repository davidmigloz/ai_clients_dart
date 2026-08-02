import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/interactions/triggers/triggers.dart';
import 'base_resource.dart';

/// Resource for the Triggers API.
///
/// Provides CRUD operations on [Trigger]s that run agent interactions on a
/// cron schedule, plus listing and manually running trigger executions.
///
/// **Note:** the Triggers API is part of the experimental Interactions API.
class TriggersResource extends ResourceBase {
  /// Creates a [TriggersResource].
  TriggersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// The Interactions API schema revision this client targets.
  ///
  /// Sent via the `Api-Revision` header on every request, mirroring the
  /// official google-genai SDK, which sends it unconditionally for the
  /// Interactions API family (interactions, agents, webhooks).
  ///
  /// See https://ai.google.dev/gemini-api/docs/interactions-breaking-changes-may-2026
  static const _apiRevision = '2026-05-20';

  /// Builds headers for a Triggers API request, always opting into the
  /// [_apiRevision] schema via the `Api-Revision` header.
  Map<String, String> _buildHeaders([Map<String, String>? additionalHeaders]) {
    return requestBuilder.buildHeaders(
      // Spread additionalHeaders first so the Api-Revision opt-in always wins.
      additionalHeaders: {...?additionalHeaders, 'Api-Revision': _apiRevision},
    );
  }

  /// Lists triggers.
  ///
  /// [filter] is an optional filter expression (e.g., by status). [pageSize]
  /// caps the maximum number of triggers per page and [pageToken] is used
  /// for pagination.
  Future<ListTriggersResponse> list({
    String? filter,
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      'filter': ?filter,
      if (pageSize != null) 'page_size': pageSize.toString(),
      'page_token': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/triggers',
      queryParams: queryParams,
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListTriggersResponse.fromJson(responseBody);
  }

  /// Creates a new [Trigger] that invokes the given interaction template on
  /// the given cron schedule.
  ///
  /// Returns the created trigger with its server-assigned [Trigger.id]
  /// populated.
  Future<Trigger> create({required TriggerCreateParams trigger}) async {
    final url = requestBuilder.buildUrl('/{version}/triggers');

    final headers = _buildHeaders(const {'Content-Type': 'application/json'});

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(trigger.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Trigger.fromJson(responseBody);
  }

  /// Gets a specific trigger by [id].
  Future<Trigger> get(String id) async {
    final url = requestBuilder.buildUrl('/{version}/triggers/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Trigger.fromJson(responseBody);
  }

  /// Updates a trigger.
  ///
  /// [id] identifies the trigger to update and [update] holds the fields to
  /// change.
  Future<Trigger> update({
    required String id,
    required TriggerUpdate update,
  }) async {
    final url = requestBuilder.buildUrl('/{version}/triggers/$id');

    final headers = _buildHeaders(const {'Content-Type': 'application/json'});

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(update.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Trigger.fromJson(responseBody);
  }

  /// Deletes a trigger by [id].
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/triggers/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Lists executions for the trigger identified by [triggerId].
  ///
  /// [pageSize] caps the maximum number of executions per page and
  /// [pageToken] is used for pagination.
  Future<ListTriggerExecutionsResponse> listExecutions({
    required String triggerId,
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      if (pageSize != null) 'page_size': pageSize.toString(),
      'page_token': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/triggers/$triggerId/executions',
      queryParams: queryParams,
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListTriggerExecutionsResponse.fromJson(responseBody);
  }

  /// Runs the trigger identified by [triggerId] immediately.
  Future<TriggerExecution> run({required String triggerId}) async {
    final url = requestBuilder.buildUrl(
      '/{version}/triggers/$triggerId/executions',
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('POST', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return TriggerExecution.fromJson(responseBody);
  }
}
