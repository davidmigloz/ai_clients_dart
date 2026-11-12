import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import 'cloud_access_token.dart';
import 'provider_transport.dart';

/// Claude in Microsoft Foundry, using an Azure resource endpoint.
final class AnthropicFoundryClient extends ProviderAnthropicClient {
  /// Creates a Foundry client using an API key or an Entra access token.
  ///
  /// Set [azureHosted] for Azure-hosted deployments that omit Files and Skills.
  /// Entra tokens should target the scope `https://ai.azure.com/.default`.
  factory AnthropicFoundryClient({
    String? resource,
    String? apiKey,
    CloudAccessTokenProvider? tokenProvider,
    String? baseUrl,
    bool azureHosted = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    if (config.authProvider != null) {
      throw ArgumentError(
        'Configure Foundry credentials on AnthropicFoundryClient',
      );
    }
    if (apiKey != null && tokenProvider != null) {
      throw ArgumentError(
        'Use either a Foundry API key or an Entra token provider',
      );
    }
    final resolvedKey =
        apiKey ??
        (tokenProvider == null
            ? providerEnvironmentValue('ANTHROPIC_FOUNDRY_API_KEY')
            : null);
    if (resolvedKey == null && tokenProvider == null) {
      throw ArgumentError('Set a Foundry API key or Entra token provider');
    }
    final explicit = baseUrl ?? configuredProviderBase(config.baseUrl);
    if (explicit != null && resource != null) {
      throw ArgumentError('Use either the Foundry resource or a base URL');
    }
    final environmentBase = resource == null
        ? providerEnvironmentValue('ANTHROPIC_FOUNDRY_BASE_URL')
        : null;
    final resourceName =
        resource ??
        (explicit == null && environmentBase == null
            ? providerEnvironmentValue('ANTHROPIC_FOUNDRY_RESOURCE')
            : null);
    final String endpoint;
    if (explicit != null || environmentBase != null) {
      endpoint = explicit ?? environmentBase!;
    } else {
      if (resourceName == null ||
          !RegExp(r'^[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*$').hasMatch(resourceName)) {
        throw ArgumentError('Set a valid Foundry resource name or base URL');
      }
      endpoint = 'https://$resourceName.services.ai.azure.com/anthropic';
    }
    final base = validateProviderBase(endpoint);
    return AnthropicFoundryClient._(
      config.copyWith(baseUrl: base.toString(), workspaceId: null),
      _FoundryTransport(
        httpClient,
        base,
        CloudRequestAuth(apiKey: resolvedKey, tokenProvider: tokenProvider),
        azureHosted: azureHosted,
      ),
    );
  }

  AnthropicFoundryClient._(super.config, super._transport);
}

final class _FoundryTransport extends ProviderTransport {
  _FoundryTransport(
    super.client,
    this.base,
    this.auth, {
    required this.azureHosted,
  });

  final Uri base;
  final CloudRequestAuth auth;
  final bool azureHosted;

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base);
    if (path.length < 2 ||
        path.first != 'v1' ||
        (path[1] != 'messages' &&
            (azureHosted || !const {'files', 'skills'}.contains(path[1]))) ||
        (path[1] == 'messages' && path.length > 2 && path[2] == 'batches')) {
      throw UnsupportedError(
        'This resource is unavailable on the Foundry deployment',
      );
    }
    request.headers.remove('anthropic-workspace-id');
    if (azureHosted &&
        request.headers.containsKey('anthropic-user-profile-id')) {
      throw UnsupportedError(
        'User profile attribution requires an Anthropic-hosted deployment',
      );
    }
    if (path[1] == 'messages' && request.body.isNotEmpty) {
      final body =
          jsonDecode(utf8.decode(request.body)) as Map<String, dynamic>;
      if (body['fallbacks'] != null) {
        throw UnsupportedError(
          'Server-side fallback is unavailable on Foundry',
        );
      }
    }
    await auth.apply(request);
  }
}
