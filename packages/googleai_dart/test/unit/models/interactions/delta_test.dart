import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('StepDeltaData', () {
    test('the 9 documented step-delta variants dispatch to typed classes', () {
      const types = [
        'text',
        'image',
        'audio',
        'document',
        'video',
        'thought_summary',
        'thought_signature',
        'text_annotation_delta',
        'arguments_delta',
      ];
      for (final type in types) {
        final json = <String, dynamic>{'type': type};
        if (type == 'text') json['text'] = '';
        final delta = StepDeltaData.fromJson(json);
        expect(delta.type, type);
        expect(delta, isNot(isA<UnknownStepDelta>()), reason: type);
      }
    });

    test(
      'the 15 tool-call/result delta variants dispatch to typed classes',
      () {
        final expected = <String, Type>{
          'code_execution_call': CodeExecutionCallDelta,
          'url_context_call': UrlContextCallDelta,
          'google_search_call': GoogleSearchCallDelta,
          'google_maps_call': GoogleMapsCallDelta,
          'mcp_server_tool_call': McpServerToolCallDelta,
          'file_search_call': FileSearchCallDelta,
          'retrieval_call': RetrievalCallDelta,
          'code_execution_result': CodeExecutionResultDelta,
          'url_context_result': UrlContextResultDelta,
          'google_search_result': GoogleSearchResultDelta,
          'google_maps_result': GoogleMapsResultDelta,
          'mcp_server_tool_result': McpServerToolResultDelta,
          'file_search_result': FileSearchResultDelta,
          'function_result': FunctionResultDelta,
          'retrieval_result': RetrievalResultDelta,
        };
        for (final entry in expected.entries) {
          final json = <String, dynamic>{'type': entry.key};
          // RetrievalCallDelta.arguments is required.
          if (entry.key == 'retrieval_call') {
            json['arguments'] = <String, dynamic>{};
          }
          final delta = StepDeltaData.fromJson(json);
          expect(delta.runtimeType, entry.value, reason: entry.key);
          expect(delta, isNot(isA<UnknownStepDelta>()), reason: entry.key);
          expect(delta.type, entry.key);
        }
      },
    );

    test('an undocumented delta type parses as UnknownStepDelta', () {
      final delta = StepDeltaData.fromJson({
        'type': 'some_future_delta',
        'foo': 'bar',
      });
      expect(delta, isA<UnknownStepDelta>());
      expect(delta.type, 'some_future_delta');
      expect((delta as UnknownStepDelta).json['foo'], 'bar');
    });

    group('tool-call / tool-result deltas', () {
      test('GoogleSearchCallDelta round-trips typed arguments', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'google_search_call',
                  'arguments': {
                    'queries': ['dart', 'flutter'],
                  },
                  'signature': 'sig',
                })
                as GoogleSearchCallDelta;
        expect(delta.arguments?.queries, ['dart', 'flutter']);
        expect(delta.signature, 'sig');

        final json = delta.toJson();
        expect(json['type'], 'google_search_call');
        expect((json['arguments'] as Map)['queries'], ['dart', 'flutter']);
      });

      test('FunctionResultDelta round-trips ToolResult + call_id', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'function_result',
                  'call_id': 'c1',
                  'result': 'done',
                  'is_error': false,
                })
                as FunctionResultDelta;
        expect(delta.callId, 'c1');
        expect(delta.result, isA<ToolResult>());
        expect(delta.isError, false);

        final json = delta.toJson();
        expect(json['call_id'], 'c1');
        expect(json['result'], 'done');
      });

      test('CodeExecutionResultDelta round-trips string result', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'code_execution_result',
                  'result': '42',
                  'is_error': false,
                  'signature': 's',
                })
                as CodeExecutionResultDelta;
        expect(delta.result, '42');
        expect(delta.toJson()['result'], '42');
      });

      test('RetrievalCallDelta round-trips arguments + retrieval_type', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'retrieval_call',
                  'arguments': {
                    'queries': ['dart', 'flutter'],
                  },
                  'retrieval_type': 'vertex_ai_search',
                  'signature': 'sig',
                })
                as RetrievalCallDelta;
        expect(delta.arguments.queries, ['dart', 'flutter']);
        expect(delta.retrievalType, RetrievalType.vertexAiSearch);
        expect(delta.signature, 'sig');

        final json = delta.toJson();
        expect(json['type'], 'retrieval_call');
        expect((json['arguments'] as Map)['queries'], ['dart', 'flutter']);
        expect(json['retrieval_type'], 'vertex_ai_search');

        final restored = StepDeltaData.fromJson(json) as RetrievalCallDelta;
        expect(restored.retrievalType, RetrievalType.vertexAiSearch);
      });

      test('RetrievalCallDelta copyWith replaces values', () {
        const delta = RetrievalCallDelta(
          arguments: RetrievalCallArguments(queries: ['a']),
          retrievalType: RetrievalType.ragStore,
        );

        final copy = delta.copyWith(
          arguments: const RetrievalCallArguments(queries: ['b']),
          signature: 'sig',
        );

        expect(copy.arguments.queries, ['b']);
        expect(copy.retrievalType, RetrievalType.ragStore);
        expect(copy.signature, 'sig');
      });

      test('RetrievalResultDelta round-trips is_error + signature', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'retrieval_result',
                  'is_error': true,
                  'signature': 'sig',
                })
                as RetrievalResultDelta;
        expect(delta.isError, true);
        expect(delta.signature, 'sig');

        final json = delta.toJson();
        expect(json['type'], 'retrieval_result');
        expect(json['is_error'], true);
        expect(json['signature'], 'sig');
      });

      test('RetrievalResultDelta copyWith replaces values', () {
        const delta = RetrievalResultDelta(isError: false);

        final copy = delta.copyWith(isError: true, signature: 'sig');

        expect(copy.isError, true);
        expect(copy.signature, 'sig');
      });

      test('McpServerToolCallDelta round-trips name + raw arguments', () {
        final delta =
            StepDeltaData.fromJson({
                  'type': 'mcp_server_tool_call',
                  'name': 'search',
                  'server_name': 'srv',
                  'arguments': {'q': 'x'},
                })
                as McpServerToolCallDelta;
        expect(delta.name, 'search');
        expect(delta.serverName, 'srv');
        expect(delta.arguments, {'q': 'x'});

        final json = delta.toJson();
        expect(json['server_name'], 'srv');
        expect(json['arguments'], {'q': 'x'});
      });
    });

    group('TextAnnotationDelta', () {
      test('roundtrip serialization', () {
        const original = TextAnnotationDelta(
          annotations: [
            UrlCitation(
              url: 'https://example.com',
              title: 'Test',
              startIndex: 0,
              endIndex: 5,
            ),
          ],
        );
        final restored =
            StepDeltaData.fromJson(original.toJson()) as TextAnnotationDelta;
        expect(restored.annotations, hasLength(1));
        expect(
          (restored.annotations![0] as UrlCitation).url,
          'https://example.com',
        );
      });
    });

    group('AudioDelta', () {
      test('uses sample_rate (renamed from rate)', () {
        final json = {
          'type': 'audio',
          'data': 'audiodata',
          'channels': 2,
          'sample_rate': 24000,
        };
        final delta = StepDeltaData.fromJson(json) as AudioDelta;
        expect(delta.channels, 2);
        expect(delta.sampleRate, 24000);
        final out = delta.toJson();
        expect(out['sample_rate'], 24000);
        expect(out.containsKey('rate'), isFalse);
      });
    });

    group('ArgumentsDelta', () {
      test('roundtrip', () {
        const delta = ArgumentsDelta(arguments: '{"a":');
        final restored =
            StepDeltaData.fromJson(delta.toJson()) as ArgumentsDelta;
        expect(restored.arguments, '{"a":');
      });

      test('handles empty partial', () {
        final delta = StepDeltaData.fromJson({'type': 'arguments_delta'});
        expect(delta, isA<ArgumentsDelta>());
        expect((delta as ArgumentsDelta).arguments, isNull);
      });

      test('rejects mismatched type', () {
        expect(
          () => ArgumentsDelta.fromJson({'type': 'text'}),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('ThoughtSummaryDelta', () {
      test(
        'parses content as ThoughtSummaryContent (not InteractionContent)',
        () {
          final json = {
            'type': 'thought_summary',
            'content': {'type': 'text', 'text': 'reasoning'},
          };
          final delta = StepDeltaData.fromJson(json) as ThoughtSummaryDelta;
          expect(delta.content, isA<ThoughtSummaryContentText>());
          final wrapper = delta.content! as ThoughtSummaryContentText;
          expect(wrapper.content.text, 'reasoning');
        },
      );
    });
  });

  group('InteractionResponseModality', () {
    test('roundtrip all values', () {
      for (final value in InteractionResponseModality.values) {
        final str = interactionResponseModalityToString(value);
        final parsed = interactionResponseModalityFromString(str);
        expect(parsed, value);
      }
    });
  });
}
