import 'dart:async';
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const collectorToken = 'synthetic-collector-key+/=';
const adminKey = 'synthetic-admin-key+/=';
const endpoint = 'https://collector.example.test/otlp';
const id = 'tdst_review';
const createdAt = '2026-11-10T22:01:00Z';
const scope = TelemetryWorkspaceSelection.all();

Map<String, Object?> destination(String? lastError) => {
  'type': 'telemetry_destination',
  'id': id,
  'display_name': null,
  'endpoint_url': endpoint,
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
    'last_error': lastError,
    'last_error_at': null,
  },
  'created_at': createdAt,
  'updated_at': createdAt,
  'workspaces': {'type': 'all'},
};

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;
  late OrganizationTelemetryDestinationsResource resource;
  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider(adminKey),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
    resource = client.organization.telemetryDestinations;
  });

  Future<TelemetryDestination> create() => resource.create(
    endpointUrl: endpoint,
    workspaces: scope,
    headers: const {'authorization': 'Bearer $collectorToken'},
  );

  test(
    'HTTP errors redact collector credentials and retain safe fields',
    () async {
      final encoded = Uri.encodeComponent(collectorToken);
      transport.queueResponse(
        MockResponse(
          body: jsonEncode({
            'type': 'error',
            'error': {
              'type': 'invalid_request_error',
              'message': 'invalid collector config: $collectorToken',
              'details': {'error_code': encoded, 'field': 'headers'},
            },
          }),
          statusCode: 400,
          headers: {'request-id': encoded, 'x-safe-diagnostic': 'safe-value'},
        ),
      );
      await expectLater(
        create(),
        throwsA(
          isA<ApiException>().having(
            (error) => [
              error.message,
              error.toString(),
              error.errorDetails,
              error.errorCode,
              error.requestId,
              error.responseMetadata?.bodyExcerpt,
              error.responseMetadata?.headers,
            ].toString(),
            'public diagnostics',
            allOf(
              isNot(contains(collectorToken)),
              isNot(contains(encoded)),
              contains('headers'),
              contains('safe-value'),
            ),
          ),
        ),
      );
      final request = transport.lastRequest! as http.Request;
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload['headers'], {'authorization': 'Bearer $collectorToken'});
    },
  );

  test('malformed update response cannot echo a collector token', () async {
    final encoded = Uri.encodeComponent(collectorToken);
    transport.queueResponse(MockResponse(body: 'invalid JSON: $encoded'));
    await expectLater(
      resource.update(
        id,
        endpointUrl: endpoint,
        headers: const {'authorization': 'Bearer $collectorToken'},
      ),
      throwsA(
        isA<FormatException>().having(
          (error) => '${error.source} $error',
          'parse error',
          allOf(isNot(contains(collectorToken)), isNot(contains(encoded))),
        ),
      ),
    );
  });

  test('create result cannot expose a submitted collector token', () async {
    transport.queueJsonResponse(
      destination('delivery failed: $collectorToken'),
    );
    final result = await create();
    expect(result.deliveryHealth.lastError, startsWith('delivery failed: '));
    expect(
      [
        result.deliveryHealth.lastError,
        result.toString(),
        result.toJson(),
      ].toString(),
      isNot(contains(collectorToken)),
    );
  });

  test(
    'test delivery result does not echo Admin auth in diagnostics',
    () async {
      final encoded = Uri.encodeComponent(adminKey);
      transport.queueJsonResponse({
        'type': 'telemetry_destination_test',
        'result': {'type': 'failure', 'error': 'delivery failed: $encoded'},
      });
      final result = await resource.test(id);
      expect(result.result.succeeded, isFalse);
      expect(result.result.error, contains('redacted credential'));
      expect(result.toJson().toString(), isNot(contains(encoded)));
    },
  );

  test('a known telemetry failure requires its reason', () async {
    transport.queueJsonResponse({
      'type': 'telemetry_destination_test',
      'result': {'type': 'failure'},
    });
    await expectLater(resource.test(id), throwsFormatException);
  });

  final invalidFields = <String, Object>{
    'traces': {
      'enabled': 'true',
      'endpoint_url': null,
      'content_mode': 'metadata_only',
      'max_content_bytes': null,
    },
    'delivery_health': {'last_success_at': null, 'last_error': null},
    'state': {'type': 'disabled'},
    'header_names': [123],
  };
  for (final entry in invalidFields.entries) {
    test('malformed ${entry.key} fails while decoding a destination', () async {
      transport.queueJsonResponse({
        ...destination(null),
        entry.key: entry.value,
      });
      await expectLater(resource.retrieve(id), throwsFormatException);
    });
  }

  test(
    'refused redirect cannot leak the collector token in metadata',
    () async {
      final encoded = Uri.encodeComponent(collectorToken);
      transport.queueResponse(
        MockResponse(
          statusCode: 307,
          headers: {
            'location': 'https://elsewhere.example.test/target',
            'request-id': encoded,
            'retry-after': '3',
          },
        ),
      );
      await expectLater(
        create(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 307)
              .having((error) => error.requestId, 'request ID', isNull)
              .having(
                (error) => error.responseMetadata?.headers['retry-after'],
                'retry hint',
                '3',
              ),
        ),
      );
      expect(transport.requests, hasLength(1));
    },
  );

  test(
    'AWS IAM sends organization scope without configured workspace',
    () async {
      final aws = AnthropicAwsClient(
        region: 'us-east-1',
        workspaceId: 'wrkspc_ignored',
        credentials: () => const ClaudeAwsCredentials(
          accessKeyId: 'AKID_SYNTHETIC',
          secretAccessKey: 'synthetic-signing-secret',
        ),
        httpClient: transport,
      );
      addTearDown(aws.close);
      transport.queueJsonResponse({'data': <Object>[], 'next_page': null});
      final page = await aws.organization.telemetryDestinations.list();
      expect(page.hasMore, isFalse);
      final request = transport.lastRequest!;
      expect(request.url.host, 'aws-external-anthropic.us-east-1.api.aws');
      expect(request.url.path, '/v1/organizations/telemetry_destinations');
      expect(request.headers['anthropic-workspace-id'], isNull);
      expect(request.headers['x-api-key'], isNull);
      expect(
        request.headers['anthropic-beta'],
        'telemetry-destinations-2026-08-11',
      );
      expect(request.headers['authorization'], startsWith('AWS4-HMAC-SHA256 '));
      expect(
        request.headers['authorization'],
        contains('/aws-external-anthropic/aws4_request'),
      );
    },
  );

  test('two opaque cursor pages repeat exact workspace filters', () async {
    const cursor = 'cursor+/% ?&#';
    const workspaceFilters = ['wrkspc_a/b', 'wrkspc_z?x=y'];
    transport
      ..queueJsonResponse({'data': <Object>[], 'next_page': cursor})
      ..queueJsonResponse({
        'data': [destination(null)],
        'next_page': null,
      });
    final first = await resource.list(workspaceIds: workspaceFilters, limit: 1);
    expect(first.hasMore, isTrue);
    expect(first.nextPage, cursor);
    final last = await resource.list(
      workspaceIds: workspaceFilters,
      limit: 1,
      page: first.nextPage,
    );
    expect(last.data.single.id, id);
    expect(last.hasMore, isFalse);
    expect(last.nextPage, isNull);
    expect(transport.requests.first.url.queryParametersAll, {
      'workspace_ids[]': workspaceFilters,
      'limit': ['1'],
    });
    expect(transport.requests.last.url.queryParametersAll, {
      'workspace_ids[]': workspaceFilters,
      'limit': ['1'],
      'page': [cursor],
    });
  });

  test('future discriminators and extra fields still round-trip', () async {
    final futureDestination = {
      ...destination(null),
      'state': {'type': 'waiting_for_review', 'new_field': 'retained'},
      'workspaces': {'type': 'future_selection', 'new_field': true},
    };
    final futureResult = {
      'type': 'telemetry_destination_test',
      'result': {'type': 'accepted_pending', 'new_field': 'future diagnostic'},
    };
    transport
      ..queueJsonResponse(futureDestination)
      ..queueJsonResponse(futureResult);
    final telemetry = await resource.retrieve(id);
    expect(telemetry.state.type, 'waiting_for_review');
    expect(telemetry.workspaces.type, 'future_selection');
    expect(telemetry.toJson(), futureDestination);
    final delivery = await resource.test(id);
    expect(delivery.result.type, 'accepted_pending');
    expect(delivery.result.error, isNull);
    expect(delivery.toJson(), futureResult);
  });

  test('same-turn abort never dispatches the collector credential', () async {
    final abort = Completer<void>()..complete();
    await expectLater(
      resource.create(
        endpointUrl: endpoint,
        workspaces: scope,
        headers: const {'authorization': 'Bearer $collectorToken'},
        abortTrigger: abort.future,
      ),
      throwsA(isA<AbortedException>()),
    );
    expect(transport.requests, isEmpty);
  });
}
