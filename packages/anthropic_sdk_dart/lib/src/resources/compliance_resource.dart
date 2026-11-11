import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import '../models/compliance/compliance_models.dart';
import 'base_resource.dart';

/// Access to the Claude Compliance API.
///
/// Configure an `AnthropicClient` with a scoped Compliance Access Key.
/// An Admin API key with the Activity Feed scope can list activities.
/// See the Claude Platform Compliance guide for eligibility and scopes.
class ComplianceResource extends ResourceBase {
  /// Creates a Compliance resource using the client's configured transport.
  ComplianceResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists organization activity with the caller's Activity Feed scope.
  ///
  /// Use a key with `read:compliance_activities`. Cursors are relative to
  /// [order]. Use either [beforeId] or [afterId] per request. To capture late
  /// arrivals when polling, overlap [createdAt] windows and deduplicate by ID.
  Future<ComplianceIdPage<ComplianceActivity>> listActivities({
    List<String>? activityTypes,
    List<String>? excludeActivityTypes,
    List<String>? actorIds,
    List<String>? userIds,
    List<String>? organizationIds,
    ComplianceTimeRange? createdAt,
    String? beforeId,
    String? afterId,
    ComplianceOrder? order,
    int? limit,
    Future<void>? abortTrigger,
  }) async {
    final response = await _get(
      'activities',
      query: {
        'activity_types[]': ?activityTypes,
        'exclude_activity_types[]': ?excludeActivityTypes,
        'actor_ids[]': ?actorIds,
        'user_ids[]': ?userIds,
        'organization_ids[]': ?organizationIds,
        ...?createdAt?.toQueryParameters('created_at'),
        'before_id': ?beforeId,
        'after_id': ?afterId,
        'order': ?order?.name,
        'limit': ?limit?.toString(),
      },
      abortTrigger: abortTrigger,
    );
    return ComplianceIdPage.fromJson(
      response,
      ComplianceActivity.fromJson,
      allowMissingData: true,
    );
  }

  /// Lists organizations visible to the caller's Compliance key.
  ///
  /// Requires `read:compliance_org_data`.
  Future<ComplianceCursorPage<ComplianceOrganization>> listOrganizations({
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'organizations',
    ComplianceOrganization.fromJson,
    page: page,
    limit: limit,
    allowMissingTerminalCursor: true,
    abortTrigger: abortTrigger,
  );

  /// Lists current user members of the organization identified by its UUID.
  ///
  /// Requires `read:compliance_user_data`.
  Future<ComplianceCursorPage<ComplianceOrganizationUser>>
  listOrganizationUsers(
    String organizationUuid, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'organizations/${_segment(organizationUuid)}/users',
    ComplianceOrganizationUser.fromJson,
    page: page,
    limit: limit,
    abortTrigger: abortTrigger,
  );

  /// Lists personal Claude and Cowork preferences for members (beta).
  ///
  /// Pass the organization UUID. The caller needs `read:compliance_user_data`.
  /// Repeat [userIds] and [includeUnset] on each page, and continue when an
  /// empty page supplies a [ComplianceCursorPage.nextPage] token.
  Future<ComplianceCursorPage<ComplianceUserPreferences>>
  listOrganizationUserPreferences(
    String organizationUuid, {
    List<String>? userIds,
    bool? includeUnset,
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'organizations/${_segment(organizationUuid)}/user_preferences',
    ComplianceUserPreferences.fromJson,
    page: page,
    limit: limit,
    query: {'user_ids[]': ?userIds, 'include_unset': ?includeUnset?.toString()},
    abortTrigger: abortTrigger,
  );

  /// Lists roles in a linked organization.
  ///
  /// Pass its UUID and a key with `read:compliance_org_data`.
  Future<ComplianceCursorPage<ComplianceRole>> listOrganizationRoles(
    String organizationUuid, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'organizations/${_segment(organizationUuid)}/roles',
    ComplianceRole.fromJson,
    page: page,
    limit: limit,
    abortTrigger: abortTrigger,
  );

  /// Retrieves an organization role.
  ///
  /// Pass its UUID and a key with `read:compliance_org_data`.
  Future<ComplianceRole> retrieveOrganizationRole(
    String organizationUuid,
    String roleId, {
    Future<void>? abortTrigger,
  }) async => ComplianceRole.fromJson(
    await _get(
      'organizations/${_segment(organizationUuid)}/roles/${_segment(roleId)}',
      abortTrigger: abortTrigger,
    ),
  );

  /// Lists an organization role's permissions.
  ///
  /// Pass its UUID and a key with `read:compliance_org_data`.
  Future<ComplianceCursorPage<ComplianceRolePermission>>
  listOrganizationRolePermissions(
    String organizationUuid,
    String roleId, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'organizations/${_segment(organizationUuid)}/roles/'
    '${_segment(roleId)}/permissions',
    ComplianceRolePermission.fromJson,
    page: page,
    limit: limit,
    abortTrigger: abortTrigger,
  );

  /// Retrieves the effective settings and API-key metadata for an organization.
  ///
  /// Pass its UUID and a key with `read:compliance_org_data`.
  Future<ComplianceOrganizationSettings> retrieveOrganizationSettings(
    String organizationId, {
    Future<void>? abortTrigger,
  }) async => ComplianceOrganizationSettings.fromJson(
    await _get(
      'organizations/${_segment(organizationId)}/settings',
      abortTrigger: abortTrigger,
    ),
  );

  /// Retrieves the organization's current Security Posture results (beta).
  ///
  /// Pass its UUID and a key with `read:compliance_org_data` or `read:org_audit`.
  /// The server rejects query parameters on this endpoint, so configured
  /// default query parameters are omitted.
  Future<ComplianceSecurityPosture> retrieveSecurityPosture(
    String organizationId, {
    Future<void>? abortTrigger,
  }) async => ComplianceSecurityPosture.fromJson(
    await _get(
      'organizations/${_segment(organizationId)}/security_posture',
      allowQuery: false,
      abortTrigger: abortTrigger,
    ),
  );

  /// Lists the directory groups visible to the caller.
  ///
  /// Requires `read:compliance_org_data`.
  Future<ComplianceCursorPage<ComplianceGroup>> listGroups({
    String? namePrefix,
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'groups',
    ComplianceGroup.fromJson,
    page: page,
    limit: limit,
    query: {'name_prefix': ?namePrefix},
    abortTrigger: abortTrigger,
  );

  /// Retrieves a directory group.
  ///
  /// Requires `read:compliance_org_data`.
  Future<ComplianceGroup> retrieveGroup(
    String groupId, {
    Future<void>? abortTrigger,
  }) async => ComplianceGroup.fromJson(
    await _get('groups/${_segment(groupId)}', abortTrigger: abortTrigger),
  );

  /// Lists members of a directory group.
  ///
  /// Requires `read:compliance_user_data`.
  Future<ComplianceCursorPage<ComplianceGroupMember>> listGroupMembers(
    String groupId, {
    String? page,
    int? limit,
    Future<void>? abortTrigger,
  }) => _getPage(
    'groups/${_segment(groupId)}/members',
    ComplianceGroupMember.fromJson,
    page: page,
    limit: limit,
    abortTrigger: abortTrigger,
  );

  Future<ComplianceCursorPage<T>> _getPage<T extends ComplianceRecord>(
    String path,
    T Function(Map<String, dynamic>) decode, {
    String? page,
    int? limit,
    Map<String, dynamic>? query,
    bool allowMissingTerminalCursor = false,
    Future<void>? abortTrigger,
  }) async => ComplianceCursorPage.directoryFromJson(
    await _get(
      path,
      query: {'page': ?page, 'limit': ?limit?.toString(), ...?query},
      abortTrigger: abortTrigger,
    ),
    decode,
    allowMissingTerminalCursor: allowMissingTerminalCursor,
  );

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
    bool allowQuery = true,
    Future<void>? abortTrigger,
  }) async => _decodeObject(
    await _send(
      'GET',
      path,
      query: query,
      allowQuery: allowQuery,
      abortTrigger: abortTrigger,
    ),
  );

  http.Request _request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    bool allowQuery = true,
  }) {
    final url = requestBuilder.buildUrl(
      '/v1/compliance/$path',
      queryParams: query,
    );
    if (path == 'activities') {
      final effectiveQuery = url.queryParametersAll;
      if (effectiveQuery.containsKey('activity_types[]') &&
          effectiveQuery.containsKey('exclude_activity_types[]')) {
        throw ArgumentError(
          'activityTypes and excludeActivityTypes are mutually exclusive.',
        );
      }
      if (effectiveQuery.containsKey('before_id') &&
          effectiveQuery.containsKey('after_id')) {
        throw ArgumentError('beforeId and afterId are mutually exclusive.');
      }
    }
    return http.Request(
        method,
        allowQuery ? url : Uri.parse(url.toString().split('?').first),
      )
      ..followRedirects = false
      ..headers.addAll(requestBuilder.buildHeaders(includeWorkspace: false))
      ..headers.remove('anthropic-workspace-id')
      ..headers.remove('content-type')
      ..headers['accept'] = 'application/json';
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    bool allowQuery = true,
    Future<void>? abortTrigger,
  }) async {
    final request = _request(
      method,
      path,
      query: query,
      allowQuery: allowQuery,
    );
    final watch = Stopwatch()..start();
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    if (response.statusCode >= 300 && response.statusCode < 400) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected redirect from the Compliance API',
        responseMetadata: createSafeResponseMetadata(
          statusCode: response.statusCode,
          headers: response.headers,
          latency: watch.elapsed,
        ),
      );
    }
    return response;
  }

  static Map<String, dynamic> _decodeObject(http.Response response) {
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    if (json is Map<String, dynamic>) return json;
    throw const FormatException('Expected a Compliance API response object');
  }

  static String _segment(String value) {
    final segment = value.split(';').first;
    if (segment.isEmpty || segment == '.' || segment == '..') {
      throw ArgumentError('Expected a non-empty Compliance identifier');
    }
    return Uri.encodeComponent(value);
  }
}
