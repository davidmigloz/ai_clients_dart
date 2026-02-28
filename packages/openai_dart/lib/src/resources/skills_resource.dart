import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/skills/skills.dart';
import 'base_resource.dart';

/// Resource for Skills API operations.
class SkillsResource extends BaseResource {
  /// Creates a [SkillsResource] with the given client.
  SkillsResource(super.client);

  static const _endpoint = '/skills';

  SkillVersionsResource? _versions;

  /// Access to skill versions operations.
  SkillVersionsResource get versions =>
      _versions ??= SkillVersionsResource(client);

  /// Lists skills.
  Future<SkillList> list({
    int? limit,
    String? order,
    String? after,
    Future<void>? abortTrigger,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      abortTrigger: abortTrigger,
    );
    return SkillList.fromJson(json);
  }

  /// Creates a skill using multipart file upload.
  Future<Skill> create(
    List<SkillUploadFile> files, {
    Future<void>? abortTrigger,
  }) async {
    if (files.isEmpty) {
      throw ArgumentError('At least one file is required to create a skill');
    }
    final request = http.MultipartRequest('POST', client.buildUrl(_endpoint));
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          file.bytes,
          filename: file.filename,
        ),
      );
    }

    final response = await client.postMultipart(
      request: request,
      abortTrigger: abortTrigger,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(json);
  }

  /// Retrieves a skill by ID.
  Future<Skill> retrieve(String skillId, {Future<void>? abortTrigger}) async {
    final json = await getJson(
      '$_endpoint/$skillId',
      abortTrigger: abortTrigger,
    );
    return Skill.fromJson(json);
  }

  /// Updates the default version pointer for a skill.
  Future<Skill> updateDefaultVersion(
    String skillId,
    SetDefaultSkillVersionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    final json = await postJson(
      '$_endpoint/$skillId',
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return Skill.fromJson(json);
  }

  /// Deletes a skill.
  Future<DeletedSkill> delete(
    String skillId, {
    Future<void>? abortTrigger,
  }) async {
    final json = await deleteJson(
      '$_endpoint/$skillId',
      abortTrigger: abortTrigger,
    );
    return DeletedSkill.fromJson(json);
  }

  /// Retrieves the zipped content for a skill.
  Future<Uint8List> retrieveContent(
    String skillId, {
    Future<void>? abortTrigger,
  }) async {
    final response = await client.get(
      '$_endpoint/$skillId/content',
      abortTrigger: abortTrigger,
    );
    return response.bodyBytes;
  }
}

/// Resource for skill versions operations.
class SkillVersionsResource extends BaseResource {
  /// Creates a [SkillVersionsResource] with the given client.
  SkillVersionsResource(super.client);

  /// Lists versions for a skill.
  Future<SkillVersionList> list(
    String skillId, {
    int? limit,
    String? order,
    String? after,
    Future<void>? abortTrigger,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final json = await getJson(
      '/skills/$skillId/versions',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      abortTrigger: abortTrigger,
    );
    return SkillVersionList.fromJson(json);
  }

  /// Creates a new skill version using multipart file upload.
  Future<SkillVersion> create(
    String skillId,
    List<SkillUploadFile> files, {
    bool? isDefault,
    Future<void>? abortTrigger,
  }) async {
    if (files.isEmpty) {
      throw ArgumentError(
        'At least one file is required to create a skill version',
      );
    }
    final request = http.MultipartRequest(
      'POST',
      client.buildUrl('/skills/$skillId/versions'),
    );
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          file.bytes,
          filename: file.filename,
        ),
      );
    }
    if (isDefault != null) {
      request.fields['default'] = isDefault.toString();
    }

    final response = await client.postMultipart(
      request: request,
      abortTrigger: abortTrigger,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return SkillVersion.fromJson(json);
  }

  /// Retrieves a specific skill version.
  Future<SkillVersion> retrieve(
    String skillId,
    String version, {
    Future<void>? abortTrigger,
  }) async {
    final json = await getJson(
      '/skills/$skillId/versions/$version',
      abortTrigger: abortTrigger,
    );
    return SkillVersion.fromJson(json);
  }

  /// Deletes a specific skill version.
  Future<DeletedSkillVersion> delete(
    String skillId,
    String version, {
    Future<void>? abortTrigger,
  }) async {
    final json = await deleteJson(
      '/skills/$skillId/versions/$version',
      abortTrigger: abortTrigger,
    );
    return DeletedSkillVersion.fromJson(json);
  }

  /// Retrieves zipped content for a skill version.
  Future<Uint8List> retrieveContent(
    String skillId,
    String version, {
    Future<void>? abortTrigger,
  }) async {
    final response = await client.get(
      '/skills/$skillId/versions/$version/content',
      abortTrigger: abortTrigger,
    );
    return response.bodyBytes;
  }
}
