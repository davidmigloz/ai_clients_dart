import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/skills/skill.dart';
import '../models/skills/skill_list_response.dart';
import '../models/skills/skill_version.dart';
import 'base_resource.dart';

/// Beta header for the Skills API.
const _betaHeader = 'skills-2025-10-02';

/// Resource for the Skills API.
///
/// Skills are reusable components that extend Claude's capabilities.
/// This is a beta feature and requires the `anthropic-beta` header.
class SkillsResource extends ResourceBase {
  final http.Client _httpClient;

  /// Creates a [SkillsResource].
  SkillsResource({
    required super.chain,
    required super.requestBuilder,
    required http.Client httpClient,
  }) : _httpClient = httpClient;

  /// Creates a new skill.
  ///
  /// The [skillBytes] is the skill content as a ZIP archive.
  /// The [displayTitle] is an optional human-readable title for the skill.
  ///
  /// Returns a [Skill] with information about the created skill.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await File('my-skill.zip').readAsBytes();
  /// final skill = await client.skills.create(
  ///   skillBytes: bytes,
  ///   displayTitle: 'My Custom Skill',
  /// );
  /// print('Created skill: ${skill.id}');
  /// ```
  Future<Skill> create({
    required Uint8List skillBytes,
    String? displayTitle,
  }) async {
    final uri = requestBuilder.buildUrl('/v1/skills');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    )..remove('content-type');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'skill',
          skillBytes,
          filename: 'skill.zip',
          contentType: http.MediaType('application', 'zip'),
        ),
      );
    if (displayTitle != null) {
      request.fields['display_title'] = displayTitle;
    }

    // Add authentication header
    await _applyAuthentication(request);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      _throwError(response);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(json);
  }

  /// Lists skills.
  ///
  /// The [limit] specifies the maximum number of skills to return (default 20).
  /// The [page] is an optional pagination token from a previous response.
  /// The [source] filters by source ("custom" or "anthropic").
  ///
  /// Returns a [SkillListResponse] with the list of skills and pagination info.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.skills.list(limit: 10);
  /// for (final skill in response.data) {
  ///   print('${skill.id}: ${skill.displayTitle}');
  /// }
  /// ```
  Future<SkillListResponse> list({
    int? limit,
    String? page,
    String? source,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'source': ?source,
    };

    final json = await get(
      '/v1/skills',
      queryParams: queryParams.isEmpty ? null : queryParams,
      headers: {'anthropic-beta': _betaHeader},
    );

    return SkillListResponse.fromJson(json);
  }

  /// Gets a specific skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  ///
  /// Returns a [Skill] with the skill's metadata.
  ///
  /// Example:
  /// ```dart
  /// final skill = await client.skills.retrieve(skillId: 'skill_abc123');
  /// print('Skill: ${skill.displayTitle}');
  /// ```
  Future<Skill> retrieve({required String skillId}) async {
    final json = await get(
      '/v1/skills/$skillId',
      headers: {'anthropic-beta': _betaHeader},
    );

    return Skill.fromJson(json);
  }

  /// Deletes a skill.
  ///
  /// The [skillId] is the unique identifier of the skill to delete.
  ///
  /// Example:
  /// ```dart
  /// await client.skills.deleteSkill(skillId: 'skill_abc123');
  /// print('Skill deleted');
  /// ```
  Future<void> deleteSkill({required String skillId}) async {
    await delete(
      '/v1/skills/$skillId',
      headers: {'anthropic-beta': _betaHeader},
    );
  }

  /// Creates a new version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [versionBytes] is the new version content as a ZIP archive.
  ///
  /// Returns a [SkillVersion] with information about the created version.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await File('my-skill-v2.zip').readAsBytes();
  /// final version = await client.skills.createVersion(
  ///   skillId: 'skill_abc123',
  ///   versionBytes: bytes,
  /// );
  /// print('Created version: ${version.version}');
  /// ```
  Future<SkillVersion> createVersion({
    required String skillId,
    required Uint8List versionBytes,
  }) async {
    final uri = requestBuilder.buildUrl('/v1/skills/$skillId/versions');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    )..remove('content-type');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'skill',
          versionBytes,
          filename: 'skill.zip',
          contentType: http.MediaType('application', 'zip'),
        ),
      );

    // Add authentication header
    await _applyAuthentication(request);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      _throwError(response);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return SkillVersion.fromJson(json);
  }

  /// Lists versions of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [limit] specifies the maximum number of versions to return.
  /// The [page] is an optional pagination token from a previous response.
  ///
  /// Returns a [SkillVersionListResponse] with the list of versions.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.skills.listVersions(
  ///   skillId: 'skill_abc123',
  /// );
  /// for (final version in response.data) {
  ///   print('${version.version}: ${version.description}');
  /// }
  /// ```
  Future<SkillVersionListResponse> listVersions({
    required String skillId,
    int? limit,
    String? page,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
    };

    final json = await get(
      '/v1/skills/$skillId/versions',
      queryParams: queryParams.isEmpty ? null : queryParams,
      headers: {'anthropic-beta': _betaHeader},
    );

    return SkillVersionListResponse.fromJson(json);
  }

  /// Gets a specific version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [version] is the version identifier.
  ///
  /// Returns a [SkillVersion] with the version's metadata.
  ///
  /// Example:
  /// ```dart
  /// final version = await client.skills.retrieveVersion(
  ///   skillId: 'skill_abc123',
  ///   version: '1759178010641129',
  /// );
  /// print('Version: ${version.name}');
  /// ```
  Future<SkillVersion> retrieveVersion({
    required String skillId,
    required String version,
  }) async {
    final json = await get(
      '/v1/skills/$skillId/versions/$version',
      headers: {'anthropic-beta': _betaHeader},
    );

    return SkillVersion.fromJson(json);
  }

  /// Deletes a specific version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [version] is the version identifier to delete.
  ///
  /// Example:
  /// ```dart
  /// await client.skills.deleteVersion(
  ///   skillId: 'skill_abc123',
  ///   version: '1759178010641129',
  /// );
  /// print('Version deleted');
  /// ```
  Future<void> deleteVersion({
    required String skillId,
    required String version,
  }) async {
    await delete(
      '/v1/skills/$skillId/versions/$version',
      headers: {'anthropic-beta': _betaHeader},
    );
  }

  /// Throws an appropriate error from an HTTP response.
  Never _throwError(http.Response response) {
    String message;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      message = error?['message'] as String? ?? response.body;
    } catch (_) {
      message = response.body;
    }

    switch (response.statusCode) {
      case 401:
        throw AuthenticationException(message: message);
      case 429:
        throw RateLimitException(code: response.statusCode, message: message);
      case 400:
        throw ValidationException(message: message, fieldErrors: const {});
      default:
        throw ApiException(code: response.statusCode, message: message);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = requestBuilder.config.authProvider;
    if (authProvider == null) return;

    final credentials = await authProvider.getCredentials();
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        if (!request.headers.containsKey('x-api-key')) {
          request.headers['x-api-key'] = apiKey;
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }
}
