import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../models/managed_agents/tunnels/tunnel.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';
import 'protected_resource_request.dart';

/// Manages MCP tunnels in the approved workspace.
///
/// The API is a research preview. Use workload identity credentials with
/// `workspace:manage_tunnels` and select the workspace authorized for them.
class TunnelsResource extends ResourceBase {
  /// Creates a [TunnelsResource].
  TunnelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    this._bearerToken,
  });

  final String? _bearerToken;

  /// Scopes tunnel requests to a workload identity bearer token.
  ///
  /// The configured API key is excluded from requests on this resource.
  TunnelsResource withToken(String bearerToken) => TunnelsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
    bearerToken: bearerToken,
  );

  /// Accesses the certificate authority certificates for a tunnel.
  TunnelCertificatesResource certificates(String tunnelId) =>
      TunnelCertificatesResource(
        tunnelId: tunnelId,
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
        bearerToken: _bearerToken,
      );

  /// Creates a tunnel with an optional display name.
  Future<Tunnel> create({
    String? displayName,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    '/v1/tunnels',
    Tunnel.fromJson,
    body: {'display_name': ?displayName},
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a tunnel by ID.
  Future<Tunnel> retrieve(
    String tunnelId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'GET',
    _tunnelPath(tunnelId),
    Tunnel.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Lists tunnels. Pass the returned cursor to continue pagination.
  Future<TunnelListResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'GET',
    '/v1/tunnels',
    TunnelListResponse.fromJson,
    query: _pageQuery(limit, page, includeArchived),
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Archives a tunnel.
  Future<Tunnel> archive(
    String tunnelId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    '${_tunnelPath(tunnelId)}/archive',
    Tunnel.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Retrieves the existing credential used by a tunnel proxy.
  Future<TunnelToken> revealToken(
    String tunnelId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    '${_tunnelPath(tunnelId)}/reveal_token',
    TunnelToken.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Replaces a tunnel proxy's credential and returns the new token.
  Future<TunnelToken> rotateToken(
    String tunnelId, {
    String? reason,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    '${_tunnelPath(tunnelId)}/rotate_token',
    TunnelToken.fromJson,
    body: {'reason': ?reason},
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );
}

/// Certificate authority records associated with one MCP tunnel.
class TunnelCertificatesResource extends ResourceBase {
  /// Creates a tunnel-scoped certificate resource.
  TunnelCertificatesResource({
    required this.tunnelId,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    this._bearerToken,
  });

  /// Tunnel that owns the certificates.
  final String tunnelId;
  final String? _bearerToken;

  /// Uploads a PEM-encoded certificate authority certificate.
  Future<TunnelCertificate> create({
    required String caCertificatePem,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    _path,
    TunnelCertificate.fromJson,
    body: {'ca_certificate_pem': caCertificatePem},
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Retrieves certificate metadata by ID.
  Future<TunnelCertificate> retrieve(
    String certificateId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'GET',
    '$_path/${encodePathSegment(certificateId, 'certificateId')}',
    TunnelCertificate.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Lists certificates. Pass the returned cursor to continue pagination.
  Future<TunnelCertificateListResponse> list({
    int? limit,
    String? page,
    bool? includeArchived,
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'GET',
    _path,
    TunnelCertificateListResponse.fromJson,
    query: _pageQuery(limit, page, includeArchived),
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  /// Archives a certificate.
  Future<TunnelCertificate> archive(
    String certificateId, {
    String? workspaceId,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _sendTunnelRequest(
    this,
    'POST',
    '$_path/${encodePathSegment(certificateId, 'certificateId')}/archive',
    TunnelCertificate.fromJson,
    workspaceId: workspaceId,
    betas: betas,
    bearerToken: _bearerToken,
    abortTrigger: abortTrigger,
  );

  String get _path => '${_tunnelPath(tunnelId)}/certificates';
}

String _tunnelPath(String id) =>
    '/v1/tunnels/${encodePathSegment(id, 'tunnelId')}';

Map<String, String> _pageQuery(
  int? limit,
  String? page,
  bool? includeArchived,
) => {
  'limit': ?limit?.toString(),
  'page': ?page,
  'include_archived': ?includeArchived?.toString(),
};

Future<T> _sendTunnelRequest<T>(
  ResourceBase resource,
  String method,
  String path,
  T Function(Map<String, dynamic>) parse, {
  Map<String, String>? query,
  Map<String, dynamic>? body,
  required String? workspaceId,
  required List<String> betas,
  required String? bearerToken,
  required Future<void>? abortTrigger,
}) => Future<T>.sync(() {
  resource.ensureNotClosed?.call();
  final request =
      http.Request(
          method,
          resource.requestBuilder.buildUrl(path, queryParams: query),
        )
        ..headers.addAll(
          resource.requestBuilder.buildHeaders(
            additionalHeaders: {'anthropic-workspace-id': ?workspaceId},
          ),
        );
  final auth = request.headers['authorization'];
  final configuredBearer = auth?.toLowerCase().startsWith('bearer ') ?? false
      ? auth!.substring(7)
      : null;
  final effectiveBearer = bearerToken ?? configuredBearer;
  request.headers['anthropic-beta'] = {
    for (final beta in (request.headers['anthropic-beta'] ?? '').split(','))
      if (beta.trim().isNotEmpty) beta.trim(),
    ...betas,
    'mcp-tunnels-2026-06-22',
    if (effectiveBearer != null) oauthBetaHeader,
  }.join(',');
  if (body != null) request.body = jsonEncode(body);
  return sendProtectedResourceRequest(
    resource,
    request,
    (json) => parse(json! as Map<String, dynamic>),
    bearerToken: effectiveBearer,
    abortTrigger: abortTrigger,
  );
});
