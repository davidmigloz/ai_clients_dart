import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profiles/create_user_profile_request.dart';
import '../models/user_profiles/current_user_profile.dart';
import '../models/user_profiles/current_user_profile_requests.dart';
import '../models/user_profiles/enrollment_url.dart';
import '../models/user_profiles/list_user_profiles_response.dart';
import '../models/user_profiles/update_user_profile_request.dart';
import '../models/user_profiles/user_profile.dart';
import '../models/user_profiles/user_profile_action.dart';
import '../models/user_profiles/user_profile_enforcement.dart';
import '../models/user_profiles/user_profile_list_order.dart';
import '../models/user_profiles/user_profile_list_order_by.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';

const _profilesPath = '/v1/user_profiles';
const _legacyBetaHeader = 'user-profiles-2026-08-18';

/// The legacy beta User Profiles API.
///
/// Use [current] for the generally available User Profiles API. This resource
/// continues to send the legacy beta header and use the corresponding models.
/// Pass `betas` to add other feature flags for an individual request.
class UserProfilesResource extends _UserProfilesBase {
  /// Creates a [UserProfilesResource].
  UserProfilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  }) : super(legacyBeta: true);

  /// The generally available User Profiles API.
  late final CurrentUserProfilesResource current = CurrentUserProfilesResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Creates a user profile using the legacy beta request shape.
  Future<UserProfile> create(
    CreateUserProfileRequest request, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    UserProfile.fromJson,
    body: request.toJson,
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Lists legacy user profiles. Pass the response's next cursor as [page].
  Future<ListUserProfilesResponse> list({
    int? limit,
    String? page,
    UserProfileListOrder? order,
    UserProfileListOrderBy? orderBy,
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    ListUserProfilesResponse.fromJson,
    query: () => _listQuery(limit, page, order, orderBy),
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a legacy user profile by its ID.
  Future<UserProfile> retrieve(
    String userProfileId, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    UserProfile.fromJson,
    profileId: userProfileId,
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Updates a legacy user profile. Omit fields to leave them unchanged.
  Future<UserProfile> update(
    String userProfileId,
    UpdateUserProfileRequest request, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    UserProfile.fromJson,
    profileId: userProfileId,
    body: request.toJson,
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Creates a short-lived legacy enrollment URL.
  Future<EnrollmentUrl> createEnrollmentUrl(
    String userProfileId, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    EnrollmentUrl.fromJson,
    profileId: userProfileId,
    subpath: '/enrollment_url',
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Deletes a profile using the legacy beta route.
  Future<DeletedUserProfile> delete(
    String userProfileId, {
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'DELETE',
    DeletedUserProfile.fromJson,
    profileId: userProfileId,
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Creates a short-lived action URL using the legacy beta route.
  Future<UserProfileActionUrl> createActionUrl(
    String userProfileId, {
    required UserProfileAction action,
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    UserProfileActionUrl.fromJson,
    profileId: userProfileId,
    subpath: '/action_urls',
    body: () => {'action': action.toJson()},
    betas: betas,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );
}

/// The generally available User Profiles API.
///
/// Profiles belong to an organization. Pass a returned profile ID to Messages,
/// token counting, or batch creation to attribute inference to that profile.
/// The optional `workspaceId` parameter on operations select the request workspace when
/// the caller's credentials can access multiple workspaces.
class CurrentUserProfilesResource extends _UserProfilesBase {
  /// Creates a [CurrentUserProfilesResource].
  CurrentUserProfilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  }) : super(legacyBeta: false);

  /// Creates a user profile. Each successful call creates a distinct profile.
  Future<CurrentUserProfile> create(
    CreateCurrentUserProfileRequest request, {
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    CurrentUserProfile.fromJson,
    body: request.toJson,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Lists user profiles, optionally filtered by enforcement status.
  ///
  /// Pass [CurrentUserProfilePage.nextPage] as [page] on the next request
  /// with the same filters. A null cursor means the list is complete.
  Future<CurrentUserProfilePage> list({
    int? limit,
    String? page,
    UserProfileListOrder? order,
    UserProfileListOrderBy? orderBy,
    List<UserProfileEnforcementStatus>? enforcementStatuses,
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    CurrentUserProfilePage.fromJson,
    query: () => {
      ..._listQuery(limit, page, order, orderBy),
      if (enforcementStatuses != null)
        'enforcement_status[]': enforcementStatuses.map(_filterStatus).toList(),
    },
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a user profile by its ID.
  Future<CurrentUserProfile> retrieve(
    String userProfileId, {
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'GET',
    CurrentUserProfile.fromJson,
    profileId: userProfileId,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Updates a profile. Omit fields to leave them unchanged.
  Future<CurrentUserProfile> update(
    String userProfileId,
    UpdateCurrentUserProfileRequest request, {
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    CurrentUserProfile.fromJson,
    profileId: userProfileId,
    body: request.toJson,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Deletes a profile and returns confirmation of its ID.
  Future<DeletedUserProfile> delete(
    String userProfileId, {
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'DELETE',
    DeletedUserProfile.fromJson,
    profileId: userProfileId,
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );

  /// Creates a short-lived URL for the specified [action].
  Future<UserProfileActionUrl> createActionUrl(
    String userProfileId, {
    required UserProfileAction action,
    String? workspaceId,
    Future<void>? abortTrigger,
  }) => _send(
    'POST',
    UserProfileActionUrl.fromJson,
    profileId: userProfileId,
    subpath: '/action_urls',
    body: () => {'action': action.toJson()},
    workspaceId: workspaceId,
    abortTrigger: abortTrigger,
  );
}

abstract class _UserProfilesBase extends ResourceBase {
  final bool _legacyBeta;

  _UserProfilesBase({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    required this._legacyBeta,
    super.ensureNotClosed,
  });

  Future<T> _send<T>(
    String method,
    T Function(Map<String, dynamic>) decode, {
    String? profileId,
    String subpath = '',
    Map<String, dynamic> Function()? body,
    Map<String, dynamic> Function()? query,
    List<String> betas = const [],
    String? workspaceId,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = profileId == null
        ? _profilesPath
        : '${_profilePath(profileId)}$subpath';
    final url = requestBuilder.buildUrl(path, queryParams: query?.call());
    final headers = requestBuilder.buildHeaders(
      workspaceId: workspaceId,
      additionalHeaders: {
        if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
      },
    );
    // The selected resource owns the profile API version.
    final features = {
      for (final feature
          in headers['anthropic-beta']?.split(',') ?? const <String>[])
        if (feature.trim() case final value
            when value.isNotEmpty && !value.startsWith('user-profiles-'))
          value,
      if (_legacyBeta) _legacyBetaHeader,
    };
    if (features.isEmpty) {
      headers.remove('anthropic-beta');
    } else {
      headers['anthropic-beta'] = features.join(',');
    }
    final request = http.Request(method, url)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return decode(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

String _profilePath(String id) =>
    '$_profilesPath/${encodePathSegment(id, 'userProfileId')}';

Map<String, dynamic> _listQuery(
  int? limit,
  String? page,
  UserProfileListOrder? order,
  UserProfileListOrderBy? orderBy,
) => {
  'limit': ?limit?.toString(),
  'page': ?page,
  'order': ?order?.toJson(),
  'order_by': ?orderBy?.toJson(),
};

String _filterStatus(UserProfileEnforcementStatus status) {
  if (status == UserProfileEnforcementStatus.unknown) {
    throw ArgumentError('Filtering requires a known enforcement status');
  }
  return status.value;
}
