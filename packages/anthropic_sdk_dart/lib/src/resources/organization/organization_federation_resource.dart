import '../../models/organization/federation_issuer.dart';
import '../../models/organization/organization_page.dart';
import 'organization_transport.dart';

/// Workload Identity Federation resources in the Admin API.
final class OrganizationFederationResource {
  /// Creates the federation resource.
  OrganizationFederationResource(OrganizationTransport transport)
    : issuers = OrganizationFederationIssuersResource(transport);

  /// Registered OpenID Connect identity providers.
  final OrganizationFederationIssuersResource issuers;
}

/// Registers and manages OpenID Connect identity providers.
///
/// These operations require an OAuth access token with `org:admin`.
/// Use `AnthropicClient.withAuthToken` or a federated organization admin.
/// Admin API keys do not authorize federation issuer operations.
final class OrganizationFederationIssuersResource {
  /// Creates the issuer resource.
  const OrganizationFederationIssuersResource(this._transport);

  final OrganizationTransport _transport;
  static const _path = '/federation_issuers';

  /// Lists issuers. Pass the previous response's `nextPage` to continue.
  Future<OrganizationCursorPage<FederationIssuer>> list({
    String? page,
    int? limit,
    bool? includeArchived,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _path,
    (json) => OrganizationCursorPage.fromJson(json, FederationIssuer.fromJson),
    query: {
      'page': ?page,
      'limit': ?limit?.toString(),
      'include_archived': ?includeArchived?.toString(),
    },
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Registers an issuer. The issuer URL matches the JWT's exact `iss` claim.
  Future<FederationIssuer> create(
    FederationIssuerCreateParams params, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _path,
    FederationIssuer.fromJson,
    body: params.toJson(),
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Retrieves the issuer and its current signing-key polling status.
  Future<FederationIssuer> retrieve(
    String issuerId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _issuerPath(issuerId),
    FederationIssuer.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Updates issuer fields, including the entire JWKS source if supplied.
  Future<FederationIssuer> update(
    String issuerId,
    FederationIssuerUpdateParams params, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _issuerPath(issuerId),
    FederationIssuer.fromJson,
    body: params.toJson(),
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  /// Archives an issuer after its active rules have been archived.
  Future<FederationIssuer> archive(
    String issuerId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_issuerPath(issuerId)}/archive',
    FederationIssuer.fromJson,
    beta: _beta(betas),
    abortTrigger: abortTrigger,
  );

  static String _issuerPath(String id) =>
      '$_path/${organizationIdSegment(id, 'issuerId')}';

  static String? _beta(List<String> values) =>
      values.isEmpty ? null : values.join(',');
}
