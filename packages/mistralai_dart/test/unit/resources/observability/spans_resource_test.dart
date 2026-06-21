@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpansResource', () {
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

    Map<String, dynamic> evalJson(String spanId) => {
      'conversation_id': 'c-1',
      'customer_id': 'cust-1',
      'evaluation_name': 'helpfulness',
      'explanation': 'good',
      'metadata': <String, dynamic>{'k': 'v'},
      'organization_id': 'org-1',
      'response_id': 'r-1',
      'score_label': 'high',
      'score_value': 0.9,
      'span_id': spanId,
      'timestamp': '2024-01-01T00:00:00Z',
      'trace_id': 't-1',
      'user_id': 'u-1',
      'workspace_id': 'ws-1',
    };

    test('searchEvaluations issues POST with body and query params', () async {
      final client = clientReturning({
        'span_evaluations': {
          'cursor': null,
          'next': null,
          'results': [evalJson('s-1')],
        },
      });
      addTearDown(client.close);

      final result = await client.observability.spans.searchEvaluations(
        request: const SpanEvaluationsRequest(
          searchExpression: 'evaluation_name = "helpfulness"',
        ),
        pageSize: 10,
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/observability/spans/evaluations/search');
      expect(captured.url.queryParameters['page_size'], '10');
      expect(jsonDecode(captured.body), {
        'search_expression': 'evaluation_name = "helpfulness"',
      });
      expect(result.spanEvaluations.results.single.spanId, 's-1');
      expect(result.spanEvaluations.results.single.scoreValue, 0.9);
    });

    test('searchLatestEvaluations targets the /latest path', () async {
      final client = clientReturning({
        'span_evaluations': {'results': <Map<String, dynamic>>[]},
      });
      addTearDown(client.close);

      await client.observability.spans.searchLatestEvaluations();

      expect(captured.method, 'POST');
      expect(
        captured.url.path,
        '/v1/observability/spans/evaluations/search/latest',
      );
      expect(jsonDecode(captured.body), <String, dynamic>{});
    });

    test('getEvaluationFields issues GET', () async {
      final client = clientReturning({
        'field_definitions': [
          {
            'name': 'score_value',
            'label': 'Score',
            'type': 'FLOAT',
            'supported_operators': ['gt', 'lt'],
          },
        ],
      });
      addTearDown(client.close);

      final result = await client.observability.spans.getEvaluationFields();

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/observability/spans/evaluations/fields');
      expect(result.fieldDefinitions.single.type, 'FLOAT');
    });

    test('fetchEvaluationFieldOptions issues GET with field name', () async {
      final client = clientReturning({
        'options': ['high', 'low'],
      });
      addTearDown(client.close);

      final result = await client.observability.spans
          .fetchEvaluationFieldOptions(fieldName: 'score_label');

      expect(captured.method, 'GET');
      expect(
        captured.url.path,
        '/v1/observability/spans/evaluations/fields/score_label/options',
      );
      expect(result.options, ['high', 'low']);
    });
  });
}
