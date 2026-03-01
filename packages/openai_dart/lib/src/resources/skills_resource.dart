import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/skills/skills.dart';
import 'base_resource.dart';

/// Resource for Skills API operations.
class SkillsResource extends ResourceBase {
  /// Creates a [SkillsResource].
  SkillsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/skills';

  SkillVersionsResource? _versions;

  /// Access to skill versions operations.
  SkillVersionsResource get versions => _versions ??= SkillVersionsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Lists skills.
  Future<SkillList> list({
    int? limit,
    String? order,
    String? after,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return SkillList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a skill using multipart file upload.
  Future<Skill> create(
    List<SkillUploadFile> files, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (files.isEmpty) {
      throw ArgumentError('At least one file is required to create a skill');
    }
    final url = requestBuilder.buildUrl(_endpoint);
    final request = http.MultipartRequest('POST', url);
    for (final file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          file.bytes,
          filename: file.filename,
        ),
      );
    }
    request.headers.addAll(requestBuilder.buildMultipartHeaders());

    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Skill.fromJson(json);
  }

  /// Retrieves a skill by ID.
  Future<Skill> retrieve(String skillId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Skill.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Updates the default version pointer for a skill.
  Future<Skill> updateDefaultVersion(
    String skillId,
    SetDefaultSkillVersionRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return Skill.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a skill.
  Future<DeletedSkill> delete(
    String skillId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$skillId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return DeletedSkill.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves the zipped content for a skill.
  Future<Uint8List> retrieveContent(
    String skillId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$skillId/content');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return response.bodyBytes;
  }
}

/// Resource for skill versions operations.
class SkillVersionsResource extends ResourceBase {
  /// Creates a [SkillVersionsResource].
  SkillVersionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists versions for a skill.
  Future<SkillVersionList> list(
    String skillId, {
    int? limit,
    String? order,
    String? after,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final url = requestBuilder.buildUrl(
      '/skills/$skillId/versions',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return SkillVersionList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a new skill version using multipart file upload.
  Future<SkillVersion> create(
    String skillId,
    List<SkillUploadFile> files, {
    bool? isDefault,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    if (files.isEmpty) {
      throw ArgumentError(
        'At least one file is required to create a skill version',
      );
    }
    final url = requestBuilder.buildUrl('/skills/$skillId/versions');
    final request = http.MultipartRequest('POST', url);
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
    request.headers.addAll(requestBuilder.buildMultipartHeaders());

    final response = await interceptorChain.execute(
      request,
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/skills/$skillId/versions/$version');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return SkillVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a specific skill version.
  Future<DeletedSkillVersion> delete(
    String skillId,
    String version, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/skills/$skillId/versions/$version');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return DeletedSkillVersion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves zipped content for a skill version.
  Future<Uint8List> retrieveContent(
    String skillId,
    String version, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/skills/$skillId/versions/$version/content',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return response.bodyBytes;
  }
}
