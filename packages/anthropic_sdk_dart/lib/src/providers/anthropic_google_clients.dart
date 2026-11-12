import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../resources/base_resource.dart';
import '../utils/path_segment.dart';
import 'cloud_access_token.dart';
import 'provider_transport.dart';

/// Claude Models on Google Cloud, with the Anthropic-managed gateway.
final class AnthropicGoogleCloudClient extends ProviderAnthropicClient {
  /// Creates a Google Cloud client using a Google OAuth credential callback.
  ///
  /// Workspace-scoped routes use [workspaceId]. Organization and user-profile
  /// routes use the project organization gateway. A [baseUrl] override takes
  /// responsibility for routing both scopes.
  factory AnthropicGoogleCloudClient({
    String? projectId,
    String? location,
    String? workspaceId,
    String? accessToken,
    CloudAccessTokenProvider? tokenProvider,
    String? baseUrl,
    bool skipAuth = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    final auth = _googleAuth(config, accessToken, tokenProvider, skipAuth);
    final explicit =
        baseUrl ??
        configuredProviderBase(config.baseUrl) ??
        providerEnvironmentValue('ANTHROPIC_GOOGLE_CLOUD_BASE_URL');
    final project =
        projectId ??
        providerEnvironmentValue('ANTHROPIC_GOOGLE_CLOUD_PROJECT') ??
        providerEnvironmentValue('GOOGLE_CLOUD_PROJECT');
    final configuredLocation =
        location ?? providerEnvironmentValue('ANTHROPIC_GOOGLE_CLOUD_LOCATION');
    final effectiveLocation = (configuredLocation?.isEmpty ?? true)
        ? 'global'
        : configuredLocation!;
    final workspace =
        workspaceId ??
        config.workspaceId ??
        providerEnvironmentValue('ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID');
    if (explicit == null && (project == null || project.isEmpty)) {
      throw ArgumentError(
        'Set a Google project ID or override the gateway base URL',
      );
    }
    Uri? organization;
    final Uri base;
    if (explicit != null) {
      base = validateProviderBase(explicit);
    } else {
      final root =
          'https://claude.googleapis.com/v1/projects/'
          '${encodePathSegment(project!, 'Google project ID')}/locations/'
          '${encodePathSegment(effectiveLocation, 'Google location')}';
      organization = Uri.parse('$root/claudeOrganization/invoke');
      base = workspace == null
          ? organization
          : Uri.parse(
              '$root/workspaces/${encodePathSegment(workspace, 'workspace ID')}/invoke',
            );
    }
    return AnthropicGoogleCloudClient._(
      config.copyWith(baseUrl: base.toString(), workspaceId: null),
      _GoogleGatewayTransport(httpClient, auth, base, organization, workspace),
    );
  }

  AnthropicGoogleCloudClient._(super.config, super._transport);
}

/// Google-managed Vertex AI publisher-model Claude API.
final class AnthropicVertexClient extends ProviderAnthropicClient {
  /// Creates a Vertex client using a Google OAuth credential callback.
  ///
  /// [region] can be global, us, eu, or a supported Vertex region. The
  /// credentials must grant access to the project and model.
  factory AnthropicVertexClient({
    String? projectId,
    String? region,
    String? accessToken,
    CloudAccessTokenProvider? tokenProvider,
    String? baseUrl,
    bool skipAuth = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    final auth = _googleAuth(config, accessToken, tokenProvider, skipAuth);
    final effectiveRegion =
        region ?? providerEnvironmentValue('CLOUD_ML_REGION');
    final project =
        projectId ?? providerEnvironmentValue('ANTHROPIC_VERTEX_PROJECT_ID');
    if (effectiveRegion == null ||
        !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(effectiveRegion)) {
      throw ArgumentError('Set a valid Vertex region');
    }
    if (project == null || project.isEmpty) {
      throw ArgumentError('Set a Vertex project ID');
    }
    final host = switch (effectiveRegion) {
      'global' => 'aiplatform.googleapis.com',
      'us' || 'eu' => 'aiplatform.$effectiveRegion.rep.googleapis.com',
      _ => '$effectiveRegion-aiplatform.googleapis.com',
    };
    final base = validateProviderBase(
      baseUrl ??
          configuredProviderBase(config.baseUrl) ??
          providerEnvironmentValue('ANTHROPIC_VERTEX_BASE_URL') ??
          'https://$host/v1',
    );
    return AnthropicVertexClient._(
      config.copyWith(baseUrl: base.toString(), workspaceId: null),
      _VertexTransport(httpClient, auth, base, project, effectiveRegion),
    );
  }

  AnthropicVertexClient._(super.config, super._transport);
}

CloudRequestAuth _googleAuth(
  AnthropicConfig config,
  String? accessToken,
  CloudAccessTokenProvider? tokenProvider,
  bool skipAuth,
) {
  if (config.authProvider != null) {
    throw ArgumentError('Use a Google OAuth credential on the Google client');
  }
  if ((accessToken != null && tokenProvider != null) ||
      (skipAuth && (accessToken != null || tokenProvider != null))) {
    throw ArgumentError('Use one Google OAuth credential source or a gateway');
  }
  final provider =
      tokenProvider ?? (accessToken == null ? null : () => accessToken);
  final hasAuthorization = config.defaultHeaders.entries.any(
    (entry) =>
        entry.key.toLowerCase() == 'authorization' && entry.value.isNotEmpty,
  );
  if (!skipAuth && provider == null && !hasAuthorization) {
    throw ArgumentError(
      'Set a Google access token, token provider, or Authorization header',
    );
  }
  return CloudRequestAuth(tokenProvider: provider, skipAuth: skipAuth);
}

final class _GoogleGatewayTransport extends ProviderTransport {
  _GoogleGatewayTransport(
    super.client,
    this.auth,
    this.base,
    this.organization,
    this.workspace,
  );

  final CloudRequestAuth auth;
  final Uri base;
  final Uri? organization;
  final String? workspace;

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base);
    if (path.length > 1 && path[1] == 'tunnels') {
      throw UnsupportedError(
        'MCP tunnels are unavailable on Anthropic-managed Google Cloud',
      );
    }
    if (organization case final organizationBase?) {
      final orgScoped =
          path.length > 1 &&
          (path[1] == 'organizations' || path[1] == 'user_profiles');
      if (orgScoped) {
        final original = request.uri;
        final suffix = original.path.substring(base.path.length);
        request.uri = replaceProviderPath(
          original,
          '${organizationBase.path}$suffix',
        );
      } else if (workspace == null) {
        throw ArgumentError('Set a workspace ID for this Google Cloud route');
      }
    }
    request.headers.remove('anthropic-workspace-id');
    await auth.apply(request);
  }
}

final class _VertexTransport extends ProviderTransport
    implements MessageThreadSupport {
  _VertexTransport(
    super.client,
    this.auth,
    this.base,
    this.project,
    this.region,
  );

  final CloudRequestAuth auth;
  final Uri base;
  final String project;
  final String region;

  @override
  void ensureMessageThreadsSupported() {
    throw UnsupportedError('Messages threads are unavailable on Vertex');
  }

  @override
  Future<void> prepare(ProviderRequest request) async {
    final logicalPath = providerPath(request.uri, base).join('/');
    final count = logicalPath == 'v1/messages/count_tokens';
    if (request.method != 'POST' || (!count && logicalPath != 'v1/messages')) {
      throw UnsupportedError(
        'Vertex supports Claude Messages and token counting',
      );
    }
    final body = jsonDecode(utf8.decode(request.body)) as Map<String, dynamic>;
    if (body['thread'] != null) ensureMessageThreadsSupported();
    if (body['fallbacks'] != null) {
      throw UnsupportedError('Server-side fallback is unavailable on Vertex');
    }
    final version = (request.headers..remove('anthropic-workspace-id')).remove(
      'anthropic-version',
    );
    if (version != null) body.putIfAbsent('anthropic_version', () => version);
    final String methodPath;
    if (count) {
      methodPath = 'count-tokens:rawPredict';
    } else {
      final model = body.remove('model');
      if (model is! String) throw ArgumentError('Expected a Vertex model ID');
      final modelSegment = encodePathSegment(model, 'Vertex model ID');
      methodPath =
          '$modelSegment:${body['stream'] == true ? 'streamRawPredict' : 'rawPredict'}';
    }
    final original = request.uri;
    final prefix = original.path.substring(
      0,
      original.path.length - logicalPath.length - 1,
    );
    request
      ..uri = replaceProviderPath(
        original,
        '$prefix/projects/${encodePathSegment(project, 'Vertex project ID')}'
        '/locations/$region/publishers/anthropic/models/$methodPath',
        removeBeta: true,
      )
      ..body = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    await auth.apply(request);
  }
}
