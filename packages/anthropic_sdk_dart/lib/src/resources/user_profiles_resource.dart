import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user_profiles/create_user_profile_request.dart';
import '../models/user_profiles/enrollment_url.dart';
import '../models/user_profiles/list_user_profiles_response.dart';
import '../models/user_profiles/update_user_profile_request.dart';
import '../models/user_profiles/user_profile.dart';
import '../models/user_profiles/user_profile_list_order.dart';
import 'base_resource.dart';

/// Beta header for the User Profiles API.
const _betaHeader = 'user-profiles-2026-03-24';

/// Resource for the User Profiles API (Beta).
///
/// User profiles let a platform register end-users with Anthropic, attach
/// metadata and an external identifier, track trust-grant status for feature
/// areas that require per-user enrollment, and generate short-lived enrollment
/// URLs for end users to authorize their profile.
///
/// This is a beta feature and requires the `anthropic-beta` header, which
/// this resource sets automatically.
class UserProfilesResource extends ResourceBase {
  /// Creates a [UserProfilesResource].
  UserProfilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new user profile.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<UserProfile> create(
    CreateUserProfileRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/user_profiles');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists user profiles.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of user profiles to return.
  /// - [page]: Pagination cursor from a previous response's `nextPage`.
  /// - [order]: Sort order for the results.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListUserProfilesResponse> list({
    int? limit,
    String? page,
    UserProfileListOrder? order,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'order': ?order?.toJson(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/user_profiles',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return ListUserProfilesResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific user profile.
  ///
  /// Parameters:
  /// - [userProfileId]: The ID of the user profile to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<UserProfile> retrieve(
    String userProfileId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/user_profiles/$userProfileId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a user profile.
  ///
  /// Parameters:
  /// - [userProfileId]: The ID of the user profile to update.
  /// - [request]: The update parameters. Omit fields to leave them unchanged.
  /// - [abortTrigger]: Allows canceling the request.
  Future<UserProfile> update(
    String userProfileId,
    UpdateUserProfileRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/user_profiles/$userProfileId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return UserProfile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates an enrollment URL for a user profile.
  ///
  /// Send the returned URL to the end user so they can authorize their
  /// profile. Each URL is single-use and expires after a short time window;
  /// once expired (or consumed), request a new one.
  ///
  /// Parameters:
  /// - [userProfileId]: The ID of the user profile to enroll.
  /// - [abortTrigger]: Allows canceling the request.
  Future<EnrollmentUrl> createEnrollmentUrl(
    String userProfileId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/user_profiles/$userProfileId/enrollment_url',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return EnrollmentUrl.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
