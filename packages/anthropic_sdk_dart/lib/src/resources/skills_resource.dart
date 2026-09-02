import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/skills/deleted_skill.dart';
import '../models/skills/skill.dart';
import '../models/skills/skill_file.dart';
import '../models/skills/skill_list_response.dart';
import '../models/skills/skill_source.dart';
import '../models/skills/skill_version.dart';
import 'base_resource.dart';
import 'media_type.dart';

/// Resource for the Skills API.
///
/// Skills are reusable components that extend Claude's capabilities.
///
/// This is a generally-available (GA) API; no `anthropic-beta` header is
/// required.
class SkillsResource extends ResourceBase {
  /// Creates a [SkillsResource].
  SkillsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new skill.
  ///
  /// The [files] must all share one top-level directory that contains a
  /// `SKILL.md` file at its root (e.g. `my-skill/SKILL.md`). Each file is
  /// sent as a separate multipart part under the repeated field name
  /// `files[]`.
  /// The [displayName] is an optional human-readable label for the skill;
  /// when omitted, it's derived from the `SKILL.md` frontmatter `name`.
  ///
  /// Returns a [Skill] with information about the created skill.
  ///
  /// Example:
  /// ```dart
  /// final skillMd = await File('my-skill/SKILL.md').readAsBytes();
  /// final skill = await client.skills.create(
  ///   files: [SkillFile(path: 'my-skill/SKILL.md', bytes: skillMd)],
  ///   displayName: 'My Custom Skill',
  /// );
  /// print('Created skill: ${skill.id}');
  /// ```
  Future<Skill> create({
    required List<SkillFile> files,
    String? displayName,
  }) async {
    final uri = requestBuilder.buildUrl('/v1/skills');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders()..remove('content-type');

    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files[]',
          file.bytes,
          filename: file.path,
          contentType: file.mimeType != null
              ? parseMediaTypeOrOctetStream(file.mimeType!)
              : null,
        ),
      );
    }
    if (displayName != null) {
      request.fields['display_name'] = displayName;
    }

    // Add authentication header
    await _applyAuthentication(request);

    final streamedResponse = await httpClient.send(request);
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
  /// The [source] filters by source.
  ///
  /// Returns a [SkillListResponse] with the list of skills and pagination info.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.skills.list(limit: 10);
  /// for (final skill in response.data) {
  ///   print('${skill.id}: ${skill.displayName}');
  /// }
  /// ```
  Future<SkillListResponse> list({
    int? limit,
    String? page,
    SkillSourceType? source,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'source': ?source?.toJson(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/skills',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return SkillListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
  /// print('Skill: ${skill.displayName}');
  /// ```
  Future<Skill> retrieve({required String skillId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/skills/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return Skill.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a skill.
  ///
  /// The [skillId] is the unique identifier of the skill to delete.
  ///
  /// Returns a [DeletedSkill] confirming the deletion.
  ///
  /// Example:
  /// ```dart
  /// final deleted = await client.skills.deleteSkill(skillId: 'skill_abc123');
  /// print('Skill deleted: ${deleted.id}');
  /// ```
  Future<DeletedSkill> deleteSkill({required String skillId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/skills/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return DeletedSkill.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a new version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [files] must all share one top-level directory that contains a
  /// `SKILL.md` file at its root (e.g. `my-skill/SKILL.md`). Each file is
  /// sent as a separate multipart part under the repeated field name
  /// `files[]`.
  ///
  /// Returns a [SkillVersion] with information about the created version.
  ///
  /// Example:
  /// ```dart
  /// final skillMd = await File('my-skill/SKILL.md').readAsBytes();
  /// final version = await client.skills.createVersion(
  ///   skillId: 'skill_abc123',
  ///   files: [SkillFile(path: 'my-skill/SKILL.md', bytes: skillMd)],
  /// );
  /// print('Created version: ${version.id}');
  /// ```
  Future<SkillVersion> createVersion({
    required String skillId,
    required List<SkillFile> files,
  }) async {
    final uri = requestBuilder.buildUrl('/v1/skills/$skillId/versions');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders()..remove('content-type');

    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files[]',
          file.bytes,
          filename: file.path,
          contentType: file.mimeType != null
              ? parseMediaTypeOrOctetStream(file.mimeType!)
              : null,
        ),
      );
    }

    // Add authentication header
    await _applyAuthentication(request);

    final streamedResponse = await httpClient.send(request);
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
  ///   print('${version.id}: ${version.description}');
  /// }
  /// ```
  Future<SkillVersionListResponse> listVersions({
    required String skillId,
    int? limit,
    String? page,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
    };

    final url = requestBuilder.buildUrl(
      '/v1/skills/$skillId/versions',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return SkillVersionListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
  ///   version: 'skillver_abc123',
  /// );
  /// print('Version: ${version.name}');
  /// ```
  Future<SkillVersion> retrieveVersion({
    required String skillId,
    required String version,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/$skillId/versions/$version',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return SkillVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Downloads the content of a specific version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [version] is the version identifier to download.
  ///
  /// Returns the version's content as a ZIP archive (raw bytes).
  ///
  /// This endpoint is header-less like the rest of this resource. Note that
  /// the spec only documents it under the beta namespace (with an optional
  /// `anthropic-beta` header) and it isn't exposed by the official Python
  /// SDK; it is included here for completeness.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await client.skills.downloadVersion(
  ///   skillId: 'skill_abc123',
  ///   version: 'skillver_abc123',
  /// );
  /// await File('skill.zip').writeAsBytes(bytes);
  /// ```
  Future<Uint8List> downloadVersion({
    required String skillId,
    required String version,
  }) async {
    if (skillId.isEmpty) {
      throw ArgumentError.value(skillId, 'skillId', 'must not be empty');
    }
    if (version.isEmpty) {
      throw ArgumentError.value(version, 'version', 'must not be empty');
    }

    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/$skillId/versions/$version/content',
    );
    // The response is a binary ZIP archive. Widen Accept and drop the default
    // JSON content-type (this GET has no request body), matching the binary
    // download convention used by FilesResource.download.
    final headers = requestBuilder.buildHeaders();
    headers['accept'] = '*/*';
    headers.remove('content-type');
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return response.bodyBytes;
  }

  /// Deletes a specific version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// The [version] is the version identifier to delete.
  ///
  /// Returns a [DeletedSkillVersion] confirming the deletion.
  ///
  /// Example:
  /// ```dart
  /// final deleted = await client.skills.deleteVersion(
  ///   skillId: 'skill_abc123',
  ///   version: 'skillver_abc123',
  /// );
  /// print('Version deleted: ${deleted.id}');
  /// ```
  Future<DeletedSkillVersion> deleteVersion({
    required String skillId,
    required String version,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/$skillId/versions/$version',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return DeletedSkillVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
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
        throw RateLimitException(
          statusCode: response.statusCode,
          message: message,
        );
      case 400:
        throw ValidationException(message: message, fieldErrors: const {});
      default:
        throw ApiException(statusCode: response.statusCode, message: message);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = config.authProvider;
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
