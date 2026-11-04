import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';
import '../platform/environment.dart';
import 'config.dart';

/// Explicit configuration for organization administration, isolated from model API credentials.
///
/// Only the provider's Bearer Authorization header is consumed. Supply optional
/// organization/routing headers through this configuration instead. Project
/// credentials and OpenAIClient configuration are never consulted.
@immutable
final class OpenAIAdminConfig {
  /// Captures headers so later caller mutation cannot change this credential realm.
  OpenAIAdminConfig({
    required this.authProvider,
    this.baseUrl = 'https://api.openai.com/v1',
    this.organization,
    this.timeout = const Duration(minutes: 2),
    this.retryPolicy = RetryPolicy.defaultPolicy,
    this.logLevel,
    Map<String, String> defaultHeaders = const {},
  }) : defaultHeaders = Map.unmodifiable(defaultHeaders) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw const FormatException('Invalid Admin base URL.');
    }
  }

  /// Reads OPENAI_ADMIN_KEY only; OPENAI_API_KEY is never a fallback.
  factory OpenAIAdminConfig.fromEnvironment() {
    final key = getEnvironmentVariable('OPENAI_ADMIN_KEY');
    if (key == null || key.isEmpty) {
      throw StateError('OPENAI_ADMIN_KEY is not set.');
    }
    return OpenAIAdminConfig(
      authProvider: ApiKeyProvider(key),
      baseUrl:
          getEnvironmentVariable('OPENAI_BASE_URL') ??
          'https://api.openai.com/v1',
      organization: getEnvironmentVariable('OPENAI_ORG_ID'),
    );
  }

  /// Explicit Admin credential provider; must return a nonempty Bearer token.
  final AuthProvider authProvider;

  /// Administration API base URL. Redirects are disabled for every request.
  final String baseUrl;

  /// Optional organization selection, independent of any project client.
  final String? organization;

  /// Per-attempt HTTP timeout.
  final Duration timeout;

  /// Ordinary HTTP retry policy. Relative API-key expiry is reapplied on retry.
  final RetryPolicy retryPolicy;

  /// Optional logging level. Admin bodies and identifiers are redacted.
  final Level? logLevel;

  /// Detached request defaults, never inherited from an OpenAIClient.
  final Map<String, String> defaultHeaders;

  @override
  String toString() => 'OpenAIAdminConfig([REDACTED])';
}
