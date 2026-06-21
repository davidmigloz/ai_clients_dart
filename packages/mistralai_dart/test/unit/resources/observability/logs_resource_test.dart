@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LogsResource', () {
    late http.Request captured;

    MistralClient clientReturning(Object body, {int statusCode = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Map<String, dynamic> logJson(String spanId) => {
      'body': 'something happened',
      'customer_id': 'cust-1',
      'event_name': 'evt',
      'log_attributes': <String, dynamic>{'a': 1},
      'organization_id': 'org-1',
      'resource_attributes': <String, dynamic>{},
      'resource_schema_url': '',
      'scope_attributes': <String, dynamic>{},
      'scope_name': 'scope',
      'scope_schema_url': '',
      'scope_version': '1',
      'service_name': 'svc',
      'severity_number': 9,
      'severity_text': 'INFO',
      'span_id': spanId,
      'timestamp': '2024-01-01T00:00:00Z',
      'trace_flags': 1,
      'trace_id': 't-1',
      'user_id': 'u-1',
      'workspace_id': 'ws-1',
    };

    test(
      'search issues POST with order/search body and query params',
      () async {
        final client = clientReturning({
          'logs': {
            'cursor': null,
            'next': null,
            'results': [logJson('s-1')],
          },
        });
        addTearDown(client.close);

        final result = await client.observability.logs.search(
          request: const LogsRequest(
            order: 'asc',
            searchExpression: 'severity_text = "ERROR"',
          ),
          pageSize: 5,
        );

        expect(captured.method, 'POST');
        expect(captured.url.path, '/v1/observability/logs/search');
        expect(captured.url.queryParameters['page_size'], '5');
        expect(jsonDecode(captured.body), {
          'order': 'asc',
          'search_expression': 'severity_text = "ERROR"',
        });
        expect(result.logs.results.single.body, 'something happened');
        expect(result.logs.results.single.severityNumber, 9);
      },
    );

    test('search defaults to a desc-ordered empty request body', () async {
      final client = clientReturning({
        'logs': {'results': <Map<String, dynamic>>[]},
      });
      addTearDown(client.close);

      await client.observability.logs.search();

      expect(captured.method, 'POST');
      expect(jsonDecode(captured.body), {'order': 'desc'});
    });

    test('getFields issues GET', () async {
      final client = clientReturning({
        'field_definitions': [
          {
            'name': 'severity_text',
            'label': 'Severity',
            'type': 'ENUM',
            'supported_operators': ['eq'],
          },
        ],
      });
      addTearDown(client.close);

      final result = await client.observability.logs.getFields();

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/observability/logs/fields');
      expect(result.fieldDefinitions.single.name, 'severity_text');
    });

    test('fetchFieldOptions issues GET with field name', () async {
      final client = clientReturning({
        'options': ['INFO', 'ERROR'],
      });
      addTearDown(client.close);

      final result = await client.observability.logs.fetchFieldOptions(
        fieldName: 'severity_text',
      );

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/observability/logs/fields/severity_text/options',
      );
      expect(result.options, ['INFO', 'ERROR']);
    });
  });
}
