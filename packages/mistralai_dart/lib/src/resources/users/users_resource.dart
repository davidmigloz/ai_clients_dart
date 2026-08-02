import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/users/user_identity.dart';
import '../base_resource.dart';

/// Resource for the current authenticated user (Beta).
///
/// Example usage:
/// ```dart
/// final identity = await client.users.me();
/// print('Signed in as ${identity.email}');
/// ```
class UsersResource extends ResourceBase {
  /// Creates a [UsersResource].
  UsersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves the identity of the currently authenticated user.
  Future<UserIdentity> me() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/users/me');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return UserIdentity.fromJson(responseBody);
  }
}
