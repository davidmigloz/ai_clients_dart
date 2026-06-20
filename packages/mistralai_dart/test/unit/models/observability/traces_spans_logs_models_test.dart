@TestOn('vm')
library;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OtelFieldDefinition model', () {
    final json = {
      'name': 'status_code',
      'label': 'Status',
      'type': 'ENUM',
      'supported_operators': ['eq', 'neq'],
      'group': 'trace',
    };

    test('round-trips through JSON', () {
      final def = OtelFieldDefinition.fromJson(json);
      expect(def.name, 'status_code');
      expect(def.supportedOperators, ['eq', 'neq']);
      expect(def.group, 'trace');
      expect(def.toJson(), json);
    });

    test('copyWith clears the nullable group with explicit null', () {
      final def = OtelFieldDefinition.fromJson(json);
      expect(def.copyWith(group: null).group, isNull);
      expect(def.copyWith().group, 'trace');
    });
  });

  group('GetTrace model', () {
    final json = {
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
      'trace_id': 't-1',
      'user_id': 'u-1',
      'workflow_name': 'wf',
      'workspace_id': 'ws-1',
    };

    test('round-trips through JSON', () {
      final trace = GetTrace.fromJson(json);
      expect(trace.traceId, 't-1');
      expect(trace.modelsUsed, ['mistral-small']);
      expect(trace.statusCode, 'Unset');
      expect(trace.toJson(), json);
    });

    test('equality is value-based', () {
      expect(GetTrace.fromJson(json), GetTrace.fromJson(json));
      expect(
        GetTrace.fromJson(json).hashCode,
        GetTrace.fromJson(json).hashCode,
      );
    });

    test('copyWith replaces a single field', () {
      final trace = GetTrace.fromJson(json);
      expect(trace.copyWith(traceId: 't-2').traceId, 't-2');
      expect(trace.copyWith(traceId: 't-2').userId, 'u-1');
    });
  });

  group('GetSpan model', () {
    final json = {
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
      'resource_attributes': <String, dynamic>{'k': 'v'},
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
    };

    test('round-trips through JSON, preserving null tuning params', () {
      final span = GetSpan.fromJson(json);
      expect(span.spanId, 's-1');
      expect(span.requestTemperature, 0.7);
      expect(span.requestTopP, isNull);
      expect(span.responseFinishReasons, ['stop']);
      expect(span.resourceAttributes, {'k': 'v'});
      // toJson omits the null optional tuning params.
      final back = span.toJson();
      expect(back.containsKey('request_top_p'), isFalse);
      expect(back['request_temperature'], 0.7);
    });

    test('copyWith clears a nullable tuning param with explicit null', () {
      final span = GetSpan.fromJson(json);
      expect(
        span.copyWith(requestTemperature: null).requestTemperature,
        isNull,
      );
      expect(span.copyWith().requestTemperature, 0.7);
    });

    test('equality is value-based', () {
      expect(GetSpan.fromJson(json), GetSpan.fromJson(json));
      expect(GetSpan.fromJson(json).hashCode, GetSpan.fromJson(json).hashCode);
    });
  });

  group('GetLog model', () {
    final json = {
      'body': 'msg',
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
      'span_id': 's-1',
      'timestamp': '2024-01-01T00:00:00Z',
      'trace_flags': 1,
      'trace_id': 't-1',
      'user_id': 'u-1',
      'workspace_id': 'ws-1',
    };

    test('round-trips through JSON', () {
      final log = GetLog.fromJson(json);
      expect(log.body, 'msg');
      expect(log.logAttributes, {'a': 1});
      expect(log.severityNumber, 9);
      expect(log.toJson(), json);
    });
  });

  group('Feed wrapper models', () {
    test('GetTraces parses the nested feed result', () {
      final wrapped = GetTraces.fromJson(const {
        'traces': {
          'cursor': 'c0',
          'next': 'c1',
          'results': <Map<String, dynamic>>[],
        },
      });
      expect(wrapped.traces.cursor, 'c0');
      expect(wrapped.traces.next, 'c1');
      expect(wrapped.traces.results, isEmpty);

      final back = wrapped.toJson()['traces'] as Map<String, dynamic>;
      expect(back['cursor'], 'c0');
    });

    test('GetSpanEvaluations parses the nested feed result', () {
      final wrapped = GetSpanEvaluations.fromJson(const {
        'span_evaluations': {'results': <Map<String, dynamic>>[]},
      });
      expect(wrapped.spanEvaluations.results, isEmpty);
    });
  });

  group('Request body models', () {
    test('TracesRequest omits null search expression', () {
      expect(const TracesRequest().toJson(), <String, dynamic>{});
      expect(const TracesRequest(searchExpression: 'x').toJson(), const {
        'search_expression': 'x',
      });
    });

    test('LogsRequest always serializes order with a desc default', () {
      expect(const LogsRequest().toJson(), const {'order': 'desc'});
      expect(
        const LogsRequest(order: 'asc', searchExpression: 'y').toJson(),
        const {'order': 'asc', 'search_expression': 'y'},
      );
      expect(LogsRequest.fromJson(const {'order': 'asc'}).order, 'asc');
    });

    test('GetTraceFieldOptions round-trips a nullable options list', () {
      expect(
        GetTraceFieldOptions.fromJson(const {'options': null}).options,
        isNull,
      );
      expect(
        GetTraceFieldOptions.fromJson(const {
          'options': ['a'],
        }).options,
        const ['a'],
      );
    });
  });
}
