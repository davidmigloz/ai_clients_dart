import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/assistants/assistants.dart';
import 'base_resource.dart';

/// Resource for Assistants API operations (Beta).
///
/// Assistants can be configured with instructions and tools,
/// then used in threads to generate responses.
///
/// Access this resource through [OpenAIClient.beta.assistants].
///
/// ## Example
///
/// ```dart
/// // Create an assistant
/// final assistant = await client.beta.assistants.create(
///   CreateAssistantRequest(
///     model: 'gpt-4o',
///     name: 'Math Tutor',
///     instructions: 'You are a math tutor.',
///     tools: [CodeInterpreterTool()],
///   ),
/// );
///
/// // List assistants
/// final assistants = await client.beta.assistants.list();
/// ```
class AssistantsResource extends ResourceBase {
  /// Creates an [AssistantsResource].
  AssistantsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/assistants';
  static const _betaFeature = 'assistants=v2';

  /// Creates a new assistant.
  ///
  /// ## Parameters
  ///
  /// - [request] - The assistant creation request.
  ///
  /// ## Returns
  ///
  /// An [Assistant] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final assistant = await client.beta.assistants.create(
  ///   CreateAssistantRequest(
  ///     model: 'gpt-4o',
  ///     name: 'Code Helper',
  ///     instructions: 'You help with coding questions.',
  ///     tools: [
  ///       CodeInterpreterTool(),
  ///       FileSearchTool(),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<Assistant> create(CreateAssistantRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Assistant.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists all assistants.
  ///
  /// ## Parameters
  ///
  /// - [limit] - Maximum number of assistants to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination (get items after this ID).
  /// - [before] - Cursor for pagination (get items before this ID).
  ///
  /// ## Returns
  ///
  /// An [AssistantList] containing the assistants.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final assistants = await client.beta.assistants.list(limit: 10);
  ///
  /// for (final assistant in assistants.data) {
  ///   print('${assistant.name}: ${assistant.id}');
  /// }
  /// ```
  Future<AssistantList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return AssistantList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves an assistant by ID.
  ///
  /// ## Parameters
  ///
  /// - [assistantId] - The ID of the assistant to retrieve.
  ///
  /// ## Returns
  ///
  /// An [Assistant] with the assistant information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final assistant = await client.beta.assistants.retrieve('asst_abc123');
  /// print('Name: ${assistant.name}');
  /// print('Model: ${assistant.model}');
  /// ```
  Future<Assistant> retrieve(String assistantId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$assistantId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Assistant.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Modifies an assistant.
  ///
  /// ## Parameters
  ///
  /// - [assistantId] - The ID of the assistant to modify.
  /// - [request] - The modification request.
  ///
  /// ## Returns
  ///
  /// An [Assistant] with the updated information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final updated = await client.beta.assistants.update(
  ///   'asst_abc123',
  ///   ModifyAssistantRequest(
  ///     name: 'Updated Name',
  ///     instructions: 'Updated instructions',
  ///   ),
  /// );
  /// ```
  Future<Assistant> update(
    String assistantId,
    ModifyAssistantRequest request,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$assistantId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Assistant.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes an assistant.
  ///
  /// ## Parameters
  ///
  /// - [assistantId] - The ID of the assistant to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteAssistantResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.beta.assistants.delete('asst_abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteAssistantResponse> delete(String assistantId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$assistantId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteAssistantResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
