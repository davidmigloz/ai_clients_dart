import 'package:http/http.dart' as http;

import '../client/config.dart';
import 'aws_signing.dart';
import 'provider_transport.dart';

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
    final effectiveConfig = config.copyWith(
      baseUrl: validated.toString(),
      workspaceId:
          workspaceId ??
          config.workspaceId ??
          providerEnvironmentValue('ANTHROPIC_AWS_WORKSPACE_ID'),
    );
    final transport = _ClaudeAwsTransport(
      httpClient,
      validated,
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
  _ClaudeAwsTransport(super.client, this.base, this.auth);

  final Uri base;
  final AwsRequestAuth auth;

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base);
    final orgScoped =
        path.length > 1 &&
        (path[1] == 'organizations' || path[1] == 'compliance');
    if (orgScoped) {
      request.headers.remove('anthropic-workspace-id');
    } else if (!auth.skipAuth &&
        (request.headers['anthropic-workspace-id']?.trim().isEmpty ?? true)) {
      throw ArgumentError(
        'Claude Platform on AWS requires a workspace ID for this route',
      );
    }
    await auth.apply(request);
  }
}
