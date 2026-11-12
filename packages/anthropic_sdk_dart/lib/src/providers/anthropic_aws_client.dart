import 'package:http/http.dart' as http;

import '../client/config.dart';
import 'aws_signing.dart';
import 'provider_transport.dart';

const _workspaceHeader = 'anthropic-workspace-id';

/// A Claude Platform on AWS client using the native Claude API protocol.
///
/// Authenticate with an AWS-issued API key or AWS IAM credentials. Inference
/// and workspace resource calls require a workspace ID.
final class AnthropicAwsClient extends ProviderAnthropicClient {
  /// Creates a regional Claude Platform on AWS client.
  ///
  /// The region falls back to AWS_REGION and AWS_DEFAULT_REGION. The workspace
  /// and AWS-issued API key can be supplied in ANTHROPIC_AWS_WORKSPACE_ID and
  /// ANTHROPIC_AWS_API_KEY. Supply [credentials] to resolve short-lived IAM
  /// credentials for each attempt.
  factory AnthropicAwsClient({
    String? region,
    String? workspaceId,
    String? apiKey,
    ClaudeAwsCredentialProvider? credentials,
    String? baseUrl,
    bool skipAuth = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    if (config.authProvider != null) {
      throw ArgumentError('Configure AWS authentication on AnthropicAwsClient');
    }
    if (apiKey != null && credentials != null) {
      throw ArgumentError('Use either an AWS-issued key or IAM credentials');
    }
    if (skipAuth && (apiKey != null || credentials != null)) {
      throw ArgumentError('Skip authentication without supplying credentials');
    }
    final awsRegion = resolveAwsRegion(region);
    final awsKey =
        apiKey ??
        (credentials == null && !skipAuth
            ? providerEnvironmentValue('ANTHROPIC_AWS_API_KEY')
            : null);
    final awsBase =
        baseUrl ??
        configuredProviderBase(config.baseUrl) ??
        providerEnvironmentValue('ANTHROPIC_AWS_BASE_URL') ??
        (awsRegion == null
            ? null
            : 'https://aws-external-anthropic.$awsRegion.api.aws');
    if (awsBase == null || (awsRegion == null && awsKey == null && !skipAuth)) {
      throw ArgumentError(
        'Set an AWS region or a base URL for Bearer authentication',
      );
    }
    final validated = validateProviderBase(awsBase);
    final resolvedWorkspace =
        workspaceId ??
        config.workspaceId ??
        providerEnvironmentValue('ANTHROPIC_AWS_WORKSPACE_ID');
    final effectiveConfig = config.copyWith(
      baseUrl: validated.toString(),
      workspaceId: resolvedWorkspace,
      defaultHeaders: {
        for (final entry in config.defaultHeaders.entries)
          if (resolvedWorkspace == null ||
              entry.key.toLowerCase() != _workspaceHeader)
            entry.key: entry.value,
      },
    );
    final transport = _ClaudeAwsTransport(
      httpClient,
      validated,
      resolvedWorkspace,
      AwsRequestAuth(
        region: awsRegion,
        service: 'aws-external-anthropic',
        apiKey: awsKey,
        credentials: credentials,
        skipAuth: skipAuth,
      ),
    );
    return AnthropicAwsClient._(effectiveConfig, transport);
  }

  AnthropicAwsClient._(super.config, super._transport);
}

final class _ClaudeAwsTransport extends ProviderTransport {
  _ClaudeAwsTransport(super.client, this.base, this.workspaceId, this.auth);

  final Uri base;
  final String? workspaceId;
  final AwsRequestAuth auth;

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base);
    if (path.length == 4 &&
        path[1] == 'user_profiles' &&
        path.last == 'action_urls') {
      throw UnsupportedError(
        'User profile action URLs are unavailable on Claude Platform on AWS',
      );
    }
    final orgScoped =
        path.length > 1 &&
        (path[1] == 'organizations' || path[1] == 'compliance');
    if (orgScoped) {
      request.headers.remove(_workspaceHeader);
    } else {
      // Direct Claude workers use an environment or scoped bearer credential.
      // AWS workers send the configured workspace with AWS authentication.
      if (workspaceId case final workspace?
          when path.length >= 4 &&
              path[1] == 'environments' &&
              path[3] == 'work') {
        request.headers.putIfAbsent(_workspaceHeader, () => workspace);
      }
      if (!auth.skipAuth &&
          (request.headers[_workspaceHeader]?.trim().isEmpty ?? true)) {
        throw ArgumentError(
          'Claude Platform on AWS requires a workspace ID for this route',
        );
      }
    }
    await auth.apply(request);
  }
}
