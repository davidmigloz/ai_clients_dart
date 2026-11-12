import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../models/skills/deleted_skill.dart';
import '../models/skills/skill.dart';
import '../models/skills/skill_file.dart';
import '../models/skills/skill_list_response.dart';
import '../models/skills/skill_source.dart';
import '../models/skills/skill_version.dart';
import 'base_resource.dart';
import 'media_type.dart';
import 'resource_request.dart';

/// Resource for the Skills API.
///
/// Skills are reusable components that extend Claude's capabilities.
///
/// The Skills API is generally available. Use `betas` to opt into additional
/// beta features and `workspaceId` for request-level workspace routing.
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
  /// Include `SKILL.md` at the upload root or in one enclosing directory.
  /// Each file is sent as a separate multipart part under `files[]`.
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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final uri = requestBuilder.buildUrl('/v1/skills');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    )..removeWhere((name, _) => name.toLowerCase() == 'content-type');

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
    ensureNotClosed?.call();

    final response = await sendResourceRequest(
      httpClient,
      request,
      timeout: config.timeout,
    );

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
    List<String> betas = const [],
    String? workspaceId,
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
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
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
  Future<Skill> retrieve({
    required String skillId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return Skill.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a skill and all of its versions.
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
  Future<DeletedSkill> deleteSkill({
    required String skillId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return DeletedSkill.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a new version of a skill.
  ///
  /// The [skillId] is the unique identifier of the skill.
  /// Include `SKILL.md` at the upload root or in one enclosing directory.
  /// Each file is sent as a separate multipart part under `files[]`.
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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final uri = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}/versions',
    );
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    )..removeWhere((name, _) => name.toLowerCase() == 'content-type');

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
    ensureNotClosed?.call();

    final response = await sendResourceRequest(
      httpClient,
      request,
      timeout: config.timeout,
    );

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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
    };

    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}/versions',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}/versions/${Uri.encodeComponent(version)}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
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
  /// The official SDKs expose this endpoint in their beta namespaces. It
  /// does not require a beta header.
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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    if (skillId.isEmpty) {
      throw ArgumentError.value(skillId, 'skillId', 'must not be empty');
    }
    if (version.isEmpty) {
      throw ArgumentError.value(version, 'version', 'must not be empty');
    }

    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}/versions/${Uri.encodeComponent(version)}/content',
    );
    // The response is a binary ZIP archive. Widen Accept and drop the default
    // JSON content-type (this GET has no request body), matching the binary
    // download convention used by FilesResource.download.
    final headers =
        requestBuilder.buildHeaders(betas: betas, workspaceId: workspaceId)
          ..removeWhere(
            (name, _) =>
                const {'accept', 'content-type'}.contains(name.toLowerCase()),
          )
          ..['accept'] = 'application/binary';
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return response.bodyBytes;
  }

  /// Deletes a specific version of a skill.
  ///
  /// Deleting the only version of a skill returns a 400 error.
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
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/skills/${Uri.encodeComponent(skillId)}/versions/${Uri.encodeComponent(version)}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return DeletedSkillVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = config.authProvider;
    if (authProvider == null) return;

    request.headers.addAll(
      await resolveCredentialHeaders(request.headers, authProvider),
    );
  }
}
