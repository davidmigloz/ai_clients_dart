import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _collector = 'https://collector.example.test/otlp';
const _secret = 'fixture-collector-secret';
const _destinationId = 'tdst_fixture';
const _workspaceId = 'wrkspc_fixture';
const _createdAt = '2026-11-10T22:01:00Z';
const Map<String, Object?> _destination = {
  'type': 'telemetry_destination',
  'id': _destinationId,
  'display_name': null,
  'endpoint_url': _collector,
  'header_names': ['authorization'],
  'traces': {
    'enabled': true,
    'endpoint_url': null,
    'content_mode': 'metadata_only',
    'max_content_bytes': null,
  },
  'state': {'type': 'enabled'},
  'delivery_health': {
    'last_success_at': null,
    'last_error': null,
    'last_error_at': null,
  },
  'created_at': _createdAt,
  'updated_at': _createdAt,
  'workspaces': {'type': 'include'},
};
const Map<String, Object> _workspace = {
  'type': 'telemetry_destination_workspace',
  'telemetry_destination_id': _destinationId,
  'workspace_id': _workspaceId,
  'created_at': _createdAt,
};

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;
  late OrganizationTelemetryDestinationsResource destinations;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        baseUrl: 'https://proxy.fixture/admin',
        workspaceId: 'wrkspc_ignored',
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    destinations = client.organization.telemetryDestinations;
    addTearDown(client.close);
  });

  test('keeps configured and explicit betas with the required gate', () async {
    final betaClient = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        defaultHeaders: {
          'Anthropic-Beta': 'configured-beta,telemetry-destinations-2026-08-11',
        },
      ),
      httpClient: transport,
    );
    addTearDown(betaClient.close);
    for (var index = 0; index < 2; index++) {
      transport.queueJsonResponse({
        'data': <Object>[],
        'has_more': false,
        'next_page': null,
      });
    }
    final resource = betaClient.organization.telemetryDestinations;
    await resource.list();
    await resource.list(
      betas: ['explicit-beta', 'telemetry-destinations-2026-08-11'],
    );
    expect(
      transport.requests.map((request) => request.headers['anthropic-beta']),
      [
        'configured-beta,telemetry-destinations-2026-08-11',
        'explicit-beta,telemetry-destinations-2026-08-11',
      ],
    );
  });

  test('treats an empty cursor as the terminal page', () async {
    transport.queueJsonResponse({'data': <Object>[], 'next_page': ''});
    final page = await destinations.list();
    expect(page.data, isEmpty);
    expect(page.nextPage, isNull);
    expect(page.hasMore, isFalse);
  });

  void checkRequest(
    String method,
    String suffix, {
    Map<String, List<String>> query = const {},
    Map<String, Object?>? body,
  }) {
    final request = transport.lastRequest! as http.Request;
    expect(request.method, method);
    expect(
      request.url.path,
      '/admin/v1/organizations/telemetry_destinations$suffix',
    );
    expect(request.url.queryParametersAll, query);
    expect(
      request.headers['anthropic-beta'],
      'telemetry-destinations-2026-08-11',
    );
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['x-api-key'], 'fixture-admin-key');
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['authorization'], isNull);
    if (body == null) {
      expect(request.body, isEmpty);
    } else {
      expect(jsonDecode(request.body), body);
    }
  }

  test(
    'registers a destination with write-only headers and typed selectors',
    () async {
      transport.queueJsonResponse({
        ..._destination,
        'headers': {'authorization': _secret},
      });
      final result = await destinations.create(
        endpointUrl: _collector,
        workspaces: TelemetryWorkspaceSelection.include(
          workspaceIds: const [_workspaceId],
        ),
        traces: const TelemetryTracesConfig(
          contentMode: TelemetryContentMode.metadataOnly,
        ),
        headers: const {'authorization': _secret},
      );
      expect(result.id, _destinationId);
      expect(result.headerNames, ['authorization']);
      expect(result.workspaces.type, 'include');
      expect(result.traces.contentMode, 'metadata_only');
      expect(result.traces.maxContentBytes, isNull);
      expect(result.deliveryHealth.lastSuccessAt, isNull);
      expect(result.createdAt, DateTime.parse(_createdAt));
      expect(result.toJson(), _destination);
      expect(result.toString(), isNot(contains(_secret)));
      checkRequest(
        'POST',
        '',
        body: {
          'endpoint_url': _collector,
          'workspaces': {
            'type': 'include',
            'workspace_ids': [_workspaceId],
          },
          'headers': {'authorization': _secret},
          'traces': {'content_mode': 'metadata_only'},
        },
      );
    },
  );

  test(
    'lists filtered destinations, then retrieves a disabled destination',
    () async {
      transport
        ..queueJsonResponse({
          'data': [_destination],
          'next_page': 'cursor_next',
        })
        ..queueJsonResponse({
          ..._destination,
          'state': {
            'type': 'disabled',
            'reason': {'type': 'sustained_failure'},
          },
          'delivery_health': {
            'last_success_at': _createdAt,
            'last_error': 'HTTP error (status 403)',
            'last_error_at': _createdAt,
          },
        });
      final page = await destinations.list(
        workspaceIds: const [_workspaceId, 'wrkspc_second'],
        limit: 2,
        page: 'cursor_previous',
      );
      expect(page.nextPage, 'cursor_next');
      expect(page.data.single.state.type, 'enabled');
      checkRequest(
        'GET',
        '',
        query: {
          'workspace_ids[]': [_workspaceId, 'wrkspc_second'],
          'page': ['cursor_previous'],
          'limit': ['2'],
        },
      );
      final result = await destinations.retrieve(_destinationId);
      expect(result.state.type, 'disabled');
      expect(result.state.disabledReason, 'sustained_failure');
      expect(result.deliveryHealth.lastError, 'HTTP error (status 403)');
      expect(result.deliveryHealth.lastErrorAt, DateTime.parse(_createdAt));
      checkRequest('GET', '/$_destinationId');
    },
  );

  test(
    'updates explicit clears, header deletes, list empties and null traces',
    () async {
      transport
        ..queueJsonResponse(_destination)
        ..queueJsonResponse(_destination);
      await destinations.update(
        _destinationId,
        displayName: null,
        endpointUrl: _collector,
        headers: const {'authorization': _secret, 'old-key': null},
        traces: const TelemetryTracesConfig(
          enabled: false,
          endpointUrl: null,
          contentMode: null,
          maxContentBytes: null,
        ),
        state: TelemetryDestinationState.disabled,
        workspaces: TelemetryWorkspaceSelection.exclude(workspaceIds: const []),
      );
      checkRequest(
        'POST',
        '/$_destinationId',
        body: {
          'display_name': null,
          'endpoint_url': _collector,
          'headers': {'authorization': _secret, 'old-key': null},
          'traces': {
            'enabled': false,
            'endpoint_url': null,
            'content_mode': null,
            'max_content_bytes': null,
          },
          'state': {'type': 'disabled'},
          'workspaces': {'type': 'exclude', 'workspace_ids': <String>[]},
        },
      );
      await destinations.update(
        _destinationId,
        traces: null,
        headers: const {'old-key': null},
      );
      checkRequest(
        'POST',
        '/$_destinationId',
        body: {
          'traces': null,
          'headers': {'old-key': null},
        },
      );
    },
  );

  test('does not send invalid header updates or empty update requests', () {
    expect(() => destinations.update(_destinationId), throwsArgumentError);
    expect(
      () => destinations.update(
        _destinationId,
        headers: const {'authorization': _secret},
      ),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
    expect(TelemetryWorkspaceSelection.include().toJson(), {'type': 'include'});
    expect(const TelemetryWorkspaceSelection.all().toJson(), {'type': 'all'});
  });

  test(
    'handles 200 collector failures as test results and deletes the destination',
    () async {
      transport
        ..queueJsonResponse({
          'type': 'telemetry_destination_test',
          'result': {'type': 'failure', 'error': 'HTTP error (status 403)'},
        })
        ..queueJsonResponse({
          'type': 'telemetry_destination_test',
          'result': {'type': 'success'},
        })
        ..queueJsonResponse({
          'type': 'telemetry_destination_deleted',
          'id': _destinationId,
        });
      final failed = await destinations.test(_destinationId);
      expect(failed.result.succeeded, isFalse);
      expect(failed.result.error, 'HTTP error (status 403)');
      checkRequest('POST', '/$_destinationId/test');
      expect(
        (await destinations.test(_destinationId)).result.succeeded,
        isTrue,
      );
      final deleted = await destinations.delete(_destinationId);
      expect(deleted.id, _destinationId);
      checkRequest('DELETE', '/$_destinationId');
    },
  );

  test(
    'lists, adds and removes a workspace with distinct cursor and IDs',
    () async {
      transport
        ..queueJsonResponse({
          'data': [_workspace],
          'next_page': null,
        })
        ..queueJsonResponse(_workspace)
        ..queueJsonResponse({
          'type': 'telemetry_destination_workspace_deleted',
          'telemetry_destination_id': _destinationId,
          'workspace_id': _workspaceId,
        });
      final workspaces = destinations.workspaces;
      final page = await workspaces.list(
        _destinationId,
        limit: 4,
        page: 'cursor',
      );
      expect(page.nextPage, isNull);
      expect(page.data.single.workspaceId, _workspaceId);
      checkRequest(
        'GET',
        '/$_destinationId/workspaces',
        query: {
          'limit': ['4'],
          'page': ['cursor'],
        },
      );
      final added = await workspaces.add(_destinationId, _workspaceId);
      expect(added.destinationId, _destinationId);
      expect(added.createdAt, DateTime.parse(_createdAt));
      checkRequest('POST', '/$_destinationId/workspaces/$_workspaceId');
      final removed = await workspaces.remove(_destinationId, _workspaceId);
      expect(removed.workspaceId, _workspaceId);
      checkRequest('DELETE', '/$_destinationId/workspaces/$_workspaceId');
    },
  );
}
