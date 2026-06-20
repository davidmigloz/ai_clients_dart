@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TracesResource', () {
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

    Map<String, dynamic> traceJson(String id) => {
      'agent_id': 'a-1',
      'agent_name': 'agent',
      'cache_creation_input_tokens': 0,
      'cache_read_input_tokens': 0,
      'conversation_id': 'c-1',
      'customer_id': 'cust-1',
      'duration_ns': 100,
      'end_time': '2024-01-01T00:00:01Z',
      'environment': 'prod',
      'error_count': 0,
      'evaluation_count': 0,
      'first_turn_last_input_message': 'in',
      'first_turn_last_output_message': 'out',
      'gen_ai_span_count': 1,
      'input_tokens': 10,
      'last_turn_last_input_message': 'in2',
      'last_turn_last_output_message': 'out2',
      'llm_call_count': 1,
      'models_used': ['mistral-small'],
      'organization_id': 'org-1',
      'output_tokens': 20,
      'retrieval_count': 0,
      'root_span_id': 's-1',
      'root_span_name': 'root',
      'service_name': 'svc',
      'span_count': 2,
      'start_time': '2024-01-01T00:00:00Z',
      'status_code': 'Unset',
      'tool_call_count': 0,
      'tools_used': <String>[],
      'trace_id': id,
      'user_id': 'u-1',
      'workflow_name': 'wf',
      'workspace_id': 'ws-1',
    };

    test('search issues POST with body and pagination query params', () async {
      final client = clientReturning({
        'traces': {
          'cursor': null,
          'next': 'n-1',
          'results': [traceJson('t-1')],
        },
      });
      addTearDown(client.close);

      final result = await client.observability.traces.search(
        request: const TracesRequest(searchExpression: 'status_code = "Error"'),
        from: '2024-01-01T00:00:00Z',
        pageSize: 25,
        cursor: 'abc',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/observability/traces/search');
      expect(captured.url.queryParameters['from'], '2024-01-01T00:00:00Z');
      expect(captured.url.queryParameters['page_size'], '25');
      expect(captured.url.queryParameters['cursor'], 'abc');
      expect(jsonDecode(captured.body), {
        'search_expression': 'status_code = "Error"',
      });
      expect(result.traces.results.single.traceId, 't-1');
      expect(result.traces.next, 'n-1');
    });

    test('getFields issues GET and parses field definitions', () async {
      final client = clientReturning({
        'field_definitions': [
          {
            'name': 'status_code',
            'label': 'Status',
            'type': 'ENUM',
            'supported_operators': ['eq', 'neq'],
            'group': 'trace',
          },
        ],
      });
      addTearDown(client.close);

      final result = await client.observability.traces.getFields();

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/observability/traces/fields');
      expect(result.fieldDefinitions.single.name, 'status_code');
      expect(result.fieldDefinitions.single.supportedOperators, ['eq', 'neq']);
    });

    test(
      'fetchFieldOptions issues GET with field name and time range',
      () async {
        final client = clientReturning({
          'options': ['Error', 'Unset'],
        });
        addTearDown(client.close);

        final result = await client.observability.traces.fetchFieldOptions(
          fieldName: 'status_code',
          from: '2024-01-01T00:00:00Z',
          to: '2024-01-02T00:00:00Z',
        );

        expect(captured.method, 'GET');
        expect(
          captured.url.path,
          '/v1/observability/traces/fields/status_code/options',
        );
        expect(captured.url.queryParameters['from'], '2024-01-01T00:00:00Z');
        expect(captured.url.queryParameters['to'], '2024-01-02T00:00:00Z');
        expect(result.options, ['Error', 'Unset']);
      },
    );

    test('getById issues GET and parses a trace', () async {
      final client = clientReturning(traceJson('t-9'));
      addTearDown(client.close);

      final result = await client.observability.traces.getById(traceId: 't-9');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/observability/traces/t-9');
      expect(result.traceId, 't-9');
      expect(result.modelsUsed, ['mistral-small']);
    });

    test('getSpanById issues GET against the nested span path', () async {
      final client = clientReturning({
        'agent_description': '',
        'agent_id': 'a-1',
        'agent_name': 'agent',
        'agent_version': '1',
        'conversation_id': 'c-1',
        'customer_id': 'cust-1',
        'data_source_id': '',
        'duration_ns': 5,
        'end_time': '2024-01-01T00:00:01Z',
        'error_type': '',
        'input_messages': '[]',
        'operation_name': 'chat',
        'organization_id': 'org-1',
        'output_messages': '[]',
        'output_type': 'text',
        'parent_span_id': '',
        'prompt_name': '',
        'provider_name': 'mistral',
        'request_choice_count': 1,
        'request_encoding_formats': <String>[],
        'request_frequency_penalty': null,
        'request_max_tokens': 100,
        'request_model': 'mistral-small',
        'request_presence_penalty': null,
        'request_seed': 0,
        'request_stop_sequences': <String>[],
        'request_temperature': 0.7,
        'request_top_k': null,
        'request_top_p': null,
        'resource_attributes': <String, dynamic>{},
        'response_finish_reasons': ['stop'],
        'response_id': 'r-1',
        'response_model': 'mistral-small',
        'scope_name': 'scope',
        'scope_version': '1',
        'service_name': 'svc',
        'span_attributes': <String, dynamic>{},
        'span_id': 's-1',
        'span_kind': 'llm',
        'span_name': 'span',
        'start_time': '2024-01-01T00:00:00Z',
        'status_code': 'Ok',
        'status_message': '',
        'system_instructions': '',
        'tool_call_arguments': '',
        'tool_call_id': '',
        'tool_call_result': '',
        'tool_definitions': '',
        'tool_name': '',
        'tool_type': '',
        'trace_id': 't-1',
        'trace_state': '',
        'usage_cache_creation_input_tokens': 0,
        'usage_cache_read_input_tokens': 0,
        'usage_input_tokens': 10,
        'usage_output_tokens': 20,
        'user_id': 'u-1',
        'workflow_name': 'wf',
        'workspace_id': 'ws-1',
      });
      addTearDown(client.close);

      final result = await client.observability.traces.getSpanById(
        traceId: 't-1',
        spanId: 's-1',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/observability/traces/t-1/spans/s-1');
      expect(result.spanId, 's-1');
      expect(result.requestTemperature, 0.7);
      expect(result.requestTopP, isNull);
    });
  });
}
