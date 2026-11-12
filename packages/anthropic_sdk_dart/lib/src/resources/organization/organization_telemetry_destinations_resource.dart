import '../../auth/request_auth.dart';
import '../../errors/response_error.dart';
import '../../models/common/copy_with_sentinel.dart';
import '../../models/organization/organization_page.dart';
import '../../models/organization/telemetry_destination.dart';
import 'organization_transport.dart';

const _destinationsPath = '/telemetry_destinations';
const _telemetryBeta = 'telemetry-destinations-2026-08-11';

/// Configures server-side OTLP/HTTP export for an organization (beta).
final class OrganizationTelemetryDestinationsResource {
  /// Creates a resource on the organization transport.
  OrganizationTelemetryDestinationsResource(OrganizationTransport transport)
    : _transport = transport,
      workspaces = TelemetryDestinationWorkspacesResource(transport);

  final OrganizationTransport _transport;

  /// Manages the workspace entries on a destination's include/exclude list.
  final TelemetryDestinationWorkspacesResource workspaces;

  /// Registers a destination. The API starts it in the enabled state.
  ///
  /// Supply the collector's HTTPS OTLP/HTTP base URL. [headers] are write-only
  /// credentials sent by the Claude API to the collector.
  Future<TelemetryDestination> create({
    required String endpointUrl,
    required TelemetryWorkspaceSelection workspaces,
    String? displayName,
    Map<String, String>? headers,
    TelemetryTracesConfig? traces,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _destinationsPath,
    TelemetryDestination.fromJson,
    body: {
      'endpoint_url': endpointUrl,
      'workspaces': workspaces.toJson(),
      'display_name': ?displayName,
      'headers': ?headers,
      'traces': ?traces?.toJson(),
    },
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    diagnosticCredentials: _collectorCredentials(headers),
    sanitizeResponseDiagnostics: _sanitizeDestination,
    abortTrigger: abortTrigger,
  );

  /// Lists destinations, newest first, optionally filtered by workspace IDs.
  Future<OrganizationCursorPage<TelemetryDestination>> list({
    List<String> workspaceIds = const [],
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _destinationsPath,
    (json) =>
        OrganizationCursorPage.fromJson(json, TelemetryDestination.fromJson),
    query: {
      if (workspaceIds.isNotEmpty) 'workspace_ids[]': workspaceIds,
      'limit': ?limit?.toString(),
      'page': ?page,
    },
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    sanitizeResponseDiagnostics: _sanitizeDestinationPage,
    abortTrigger: abortTrigger,
  );

  /// Retrieves a destination's settings, state and delivery health.
  Future<TelemetryDestination> retrieve(
    String destinationId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    _destinationPath(destinationId),
    TelemetryDestination.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    sanitizeResponseDiagnostics: _sanitizeDestination,
    abortTrigger: abortTrigger,
  );

  /// Changes only the supplied fields.
  ///
  /// Use null to clear [displayName] or reset all [traces] settings. A null
  /// value inside [headers] removes that header. To set a header value, send
  /// [endpointUrl] as well. Changing the endpoint's host or port clears the
  /// stored headers, so include the new headers in that same request.
  Future<TelemetryDestination> update(
    String destinationId, {
    Object? displayName = unsetCopyWithValue,
    String? endpointUrl,
    Map<String, String?>? headers,
    Object? traces = unsetCopyWithValue,
    TelemetryDestinationState? state,
    TelemetryWorkspaceSelection? workspaces,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) {
    if (endpointUrl == null &&
        (headers?.values.any((value) => value != null) ?? false)) {
      throw ArgumentError('endpointUrl is required to set a telemetry header');
    }
    final body = {
      if (displayName != unsetCopyWithValue)
        'display_name': displayName as String?,
      'endpoint_url': ?endpointUrl,
      'headers': ?headers,
      if (traces != unsetCopyWithValue)
        'traces': (traces as TelemetryTracesConfig?)?.toJson(),
      if (state != null) 'state': {'type': state.name},
      'workspaces': ?workspaces?.toJson(),
    };
    if (body.isEmpty) {
      throw ArgumentError('Provide at least one telemetry destination setting');
    }
    return _transport.send(
      'POST',
      _destinationPath(destinationId),
      TelemetryDestination.fromJson,
      body: body,
      beta: betas.isEmpty ? null : betas.join(','),
      requiredBeta: _telemetryBeta,
      diagnosticCredentials: _collectorCredentials(headers),
      sanitizeResponseDiagnostics: _sanitizeDestination,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes a destination and stops deliveries to it.
  Future<DeletedTelemetryDestination> delete(
    String destinationId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _destinationPath(destinationId),
    DeletedTelemetryDestination.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    abortTrigger: abortTrigger,
  );

  /// Requests a single test span and returns the collector delivery result.
  ///
  /// The API reports collector success or failure in a 200 response. It does
  /// not change the destination or its delivery health.
  Future<TelemetryDestinationTest> test(
    String destinationId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    '${_destinationPath(destinationId)}/test',
    TelemetryDestinationTest.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    sanitizeResponseDiagnostics: _sanitizeTestResult,
    abortTrigger: abortTrigger,
  );
}

Set<String> _collectorCredentials(Map<String, String?>? headers) => {
  for (final value in headers?.values ?? const <String?>[])
    if (value != null) ...requestCredentialValues({'authorization': value}),
};

void _sanitizeDestination(Map<String, dynamic> json, Set<String> credentials) {
  _sanitizeNestedDiagnostic(json, 'delivery_health', 'last_error', credentials);
}

void _sanitizeDestinationPage(
  Map<String, dynamic> json,
  Set<String> credentials,
) {
  if (json['data'] case final List<Object?> destinations) {
    for (final destination in destinations.whereType<Map<String, dynamic>>()) {
      _sanitizeDestination(destination, credentials);
    }
  }
}

void _sanitizeTestResult(Map<String, dynamic> json, Set<String> credentials) {
  _sanitizeNestedDiagnostic(json, 'result', 'error', credentials);
}

void _sanitizeNestedDiagnostic(
  Map<String, dynamic> json,
  String key,
  String field,
  Set<String> credentials,
) {
  if (json[key] case final Map<String, dynamic> diagnostic) {
    if (diagnostic[field] case final String text) {
      diagnostic[field] = redactDiagnosticText(text, credentials);
    }
  }
}

/// Workspace entries for telemetry destinations that use include/exclude lists.
final class TelemetryDestinationWorkspacesResource {
  /// Creates a workspace list resource on the organization transport.
  const TelemetryDestinationWorkspacesResource(this._transport);

  final OrganizationTransport _transport;

  /// Lists workspace entries, newest first.
  Future<OrganizationCursorPage<TelemetryDestinationWorkspace>> list(
    String destinationId, {
    int? limit,
    String? page,
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'GET',
    '${_destinationPath(destinationId)}/workspaces',
    (json) => OrganizationCursorPage.fromJson(
      json,
      TelemetryDestinationWorkspace.fromJson,
    ),
    query: {'limit': ?limit?.toString(), 'page': ?page},
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    abortTrigger: abortTrigger,
  );

  /// Adds a workspace to the current include/exclude list.
  Future<TelemetryDestinationWorkspace> add(
    String destinationId,
    String workspaceId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'POST',
    _workspacePath(destinationId, workspaceId),
    TelemetryDestinationWorkspace.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    abortTrigger: abortTrigger,
  );

  /// Removes a workspace from the current include/exclude list.
  Future<DeletedTelemetryDestinationWorkspace> remove(
    String destinationId,
    String workspaceId, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) => _transport.send(
    'DELETE',
    _workspacePath(destinationId, workspaceId),
    DeletedTelemetryDestinationWorkspace.fromJson,
    beta: betas.isEmpty ? null : betas.join(','),
    requiredBeta: _telemetryBeta,
    abortTrigger: abortTrigger,
  );

  static String _workspacePath(String destinationId, String workspaceId) =>
      '${_destinationPath(destinationId)}/workspaces/${organizationIdSegment(workspaceId, 'workspaceId')}';
}

String _destinationPath(String destinationId) =>
    '$_destinationsPath/${organizationIdSegment(destinationId, 'destinationId')}';
