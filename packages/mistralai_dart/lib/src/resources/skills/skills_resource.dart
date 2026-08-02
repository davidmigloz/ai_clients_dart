import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/skills/create_skill_request.dart';
import '../../models/skills/create_skill_version_request.dart';
import '../../models/skills/create_skill_version_response.dart';
import '../../models/skills/list_skill_versions_response.dart';
import '../../models/skills/list_skills_response.dart';
import '../../models/skills/skill.dart';
import '../../models/skills/update_skill_request.dart';
import '../../models/skills/update_skill_version_request.dart';
import '../base_resource.dart';

/// Resource for managing registered skills (Beta).
///
/// Skills are versioned, reusable model instructions (with optional file
/// assets) that can be shared across a workspace and referenced by alias or
/// version number.
///
/// Example usage:
/// ```dart
/// // Create a skill
/// final skill = await client.skills.create(
///   request: const CreateSkillRequest(
///     name: 'summarizer',
///     definition: SkillDefinition(
///       description: 'Summarizes long documents.',
///       body: 'Summarize the input in three bullet points.',
///     ),
///   ),
/// );
///
/// // Fetch the latest version
/// final latest = await client.skills.retrieve(skillId: skill.id);
/// print(latest.definition?.body);
/// ```
class SkillsResource extends ResourceBase {
  /// Creates a [SkillsResource].
  SkillsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists skills.
  ///
  /// [pageSize] is the maximum number of skills to return.
  /// [pageToken] is the pagination cursor from a previous response.
  /// [alias] filters to skills that have this alias registered.
  /// [fields] restricts the response to the given top-level fields.
  Future<ListSkillsResponse> list({
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

    final url = requestBuilder.buildUrl('/v2/skills', queryParams: queryParams);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListSkillsResponse.fromJson(responseBody);
  }

  /// Creates a new skill.
  ///
  /// [request] contains the skill's name, initial definition, and metadata.
  Future<Skill> create({required CreateSkillRequest request}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/skills');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(responseBody);
  }

  /// Retrieves a skill.
  ///
  /// [skillId] is the unique identifier of the skill.
  /// [version] selects a specific version (defaults to the latest).
  /// [alias] selects the version currently pointed to by this alias.
  /// [fields] restricts the response to the given top-level fields.
  Future<Skill> retrieve({
    required String skillId,
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
      '/v2/skills/$skillId',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(responseBody);
  }

  /// Updates a skill's metadata.
  ///
  /// [skillId] is the unique identifier of the skill.
  /// [request] contains the fields to update.
  Future<Skill> update({
    required String skillId,
    required UpdateSkillRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/skills/$skillId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(responseBody);
  }

  /// Deletes a skill.
  ///
  /// [skillId] is the unique identifier of the skill to delete.
  Future<void> delete({required String skillId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/skills/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Lists the versions of a skill.
  ///
  /// [skillId] is the unique identifier of the skill.
  Future<ListSkillVersionsResponse> listVersions({
    required String skillId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/skills/$skillId/versions');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListSkillVersionsResponse.fromJson(responseBody);
  }

  /// Creates a new version of a skill.
  ///
  /// [skillId] is the unique identifier of the skill.
  /// [request] contains the new definition and optional aliases/notes.
  Future<CreateSkillVersionResponse> createVersion({
    required String skillId,
    required CreateSkillVersionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v2/skills/$skillId/versions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CreateSkillVersionResponse.fromJson(responseBody);
  }

  /// Retrieves a specific version of a skill.
  ///
  /// [skillId] is the unique identifier of the skill.
  /// [version] is the version number to retrieve.
  /// [fields] restricts the response to the given top-level fields.
  Future<Skill> retrieveVersion({
    required String skillId,
    required int version,
    List<String>? fields,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{'fields': ?fields};

    final url = requestBuilder.buildUrl(
      '/v2/skills/$skillId/versions/$version',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(responseBody);
  }

  /// Updates a skill version's metadata.
  ///
  /// [skillId] is the unique identifier of the skill.
  /// [version] is the version number to update.
  /// [request] contains the fields to update.
  Future<Skill> updateVersion({
    required String skillId,
    required int version,
    required UpdateSkillVersionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v2/skills/$skillId/versions/$version',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(responseBody);
  }
}
