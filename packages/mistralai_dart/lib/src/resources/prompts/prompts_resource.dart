import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/prompts/create_prompt_request.dart';
import '../../models/prompts/create_prompt_version_request.dart';
import '../../models/prompts/create_prompt_version_response.dart';
import '../../models/prompts/list_prompt_versions_response.dart';
import '../../models/prompts/list_prompts_response.dart';
import '../../models/prompts/prompt.dart';
import '../../models/prompts/update_prompt_request.dart';
import '../../models/prompts/update_prompt_version_request.dart';
import '../base_resource.dart';

/// Resource for managing registered prompts (Beta).
///
/// Prompts are versioned templates that can be shared across a workspace and
/// referenced by alias or version number.
///
/// Example usage:
/// ```dart
/// // Create a prompt
/// final prompt = await client.prompts.create(
///   request: const CreatePromptRequest(
///     name: 'greeting',
///     definition: PromptDefinition(content: 'Hello, {{name}}!'),
///   ),
/// );
///
/// // Fetch the latest version
/// final latest = await client.prompts.retrieve(promptId: prompt.id);
/// print(latest.definition?.content);
/// ```
class PromptsResource extends ResourceBase {
  /// Creates a [PromptsResource].
  PromptsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists prompts.
  ///
  /// [pageSize] is the maximum number of prompts to return.
  /// [pageToken] is the pagination cursor from a previous response.
  /// [alias] filters to prompts that have this alias registered.
  /// [fields] restricts the response to the given top-level fields.
  Future<ListPromptsResponse> list({
    int? pageSize,
    String? pageToken,
    String? alias,
    List<String>? fields,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
      'alias': ?alias,
      'fields': ?fields,
    };

    final url = requestBuilder.buildUrl(
      '/v2/prompts',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListPromptsResponse.fromJson(responseBody);
  }

  /// Creates a new prompt.
  ///
  /// [request] contains the prompt's name, initial definition, and metadata.
  Future<Prompt> create({required CreatePromptRequest request}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/prompts');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Prompt.fromJson(responseBody);
  }

  /// Retrieves a prompt.
  ///
  /// [promptId] is the unique identifier of the prompt.
  /// [version] selects a specific version (defaults to the latest).
  /// [alias] selects the version currently pointed to by this alias.
  /// [fields] restricts the response to the given top-level fields.
  Future<Prompt> retrieve({
    required String promptId,
    int? version,
    String? alias,
    List<String>? fields,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      if (version != null) 'version': version.toString(),
      'alias': ?alias,
      'fields': ?fields,
    };

    final url = requestBuilder.buildUrl(
      '/v2/prompts/$promptId',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Prompt.fromJson(responseBody);
  }

  /// Updates a prompt's metadata.
  ///
  /// [promptId] is the unique identifier of the prompt.
  /// [request] contains the fields to update.
  Future<Prompt> update({
    required String promptId,
    required UpdatePromptRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/prompts/$promptId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Prompt.fromJson(responseBody);
  }

  /// Deletes a prompt.
  ///
  /// [promptId] is the unique identifier of the prompt to delete.
  Future<void> delete({required String promptId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/prompts/$promptId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Lists the versions of a prompt.
  ///
  /// [promptId] is the unique identifier of the prompt.
  Future<ListPromptVersionsResponse> listVersions({
    required String promptId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/prompts/$promptId/versions');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListPromptVersionsResponse.fromJson(responseBody);
  }

  /// Creates a new version of a prompt.
  ///
  /// [promptId] is the unique identifier of the prompt.
  /// [request] contains the new definition and optional aliases/notes.
  Future<CreatePromptVersionResponse> createVersion({
    required String promptId,
    required CreatePromptVersionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/prompts/$promptId/versions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CreatePromptVersionResponse.fromJson(responseBody);
  }

  /// Retrieves a specific version of a prompt.
  ///
  /// [promptId] is the unique identifier of the prompt.
  /// [version] is the version number to retrieve.
  /// [fields] restricts the response to the given top-level fields.
  Future<Prompt> retrieveVersion({
    required String promptId,
    required int version,
    List<String>? fields,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{'fields': ?fields};

    final url = requestBuilder.buildUrl(
      '/v2/prompts/$promptId/versions/$version',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Prompt.fromJson(responseBody);
  }

  /// Updates a prompt version's metadata.
  ///
  /// [promptId] is the unique identifier of the prompt.
  /// [version] is the version number to update.
  /// [request] contains the fields to update.
  Future<Prompt> updateVersion({
    required String promptId,
    required int version,
    required UpdatePromptVersionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v2/prompts/$promptId/versions/$version',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Prompt.fromJson(responseBody);
  }
}
