import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionStep dispatch', () {
    test('all 17 variants dispatch through fromJson', () {
      final cases = <Map<String, dynamic>, Type>{
        {
          'type': 'user_input',
          'content': [
            {'type': 'text', 'text': 'hi'},
          ],
        }: UserInputStep,
        {
          'type': 'model_output',
          'content': [
            {'type': 'text', 'text': 'hi'},
          ],
        }: ModelOutputStep,
        {'type': 'thought'}: ThoughtStep,
        {
          'type': 'function_call',
          'id': 'c',
          'name': 'fn',
          'arguments': <String, dynamic>{},
        }: FunctionCallStep,
        {'type': 'function_result', 'call_id': 'c', 'result': 'ok'}:
            FunctionResultStep,
        {
          'type': 'code_execution_call',
          'id': 'c',
          'arguments': {'code': 'print("hi")'},
        }: CodeExecutionCallStep,
        {'type': 'code_execution_result', 'call_id': 'c', 'result': 'hi'}:
            CodeExecutionResultStep,
        {
          'type': 'url_context_call',
          'id': 'c',
          'arguments': {
            'urls': ['https://example.com'],
          },
        }: UrlContextCallStep,
        {
          'type': 'url_context_result',
          'call_id': 'c',
          'result': <Map<String, dynamic>>[],
        }: UrlContextResultStep,
        {
          'type': 'google_search_call',
          'id': 'c',
          'arguments': {
            'queries': ['q1'],
          },
        }: GoogleSearchCallStep,
        {
          'type': 'google_search_result',
          'call_id': 'c',
          'result': <Map<String, dynamic>>[],
        }: GoogleSearchResultStep,
        {'type': 'google_maps_call', 'id': 'c'}: GoogleMapsCallStep,
        {
          'type': 'google_maps_result',
          'call_id': 'c',
          'result': <Map<String, dynamic>>[],
        }: GoogleMapsResultStep,
        {'type': 'file_search_call', 'id': 'c'}: FileSearchCallStep,
        {'type': 'file_search_result', 'call_id': 'c'}: FileSearchResultStep,
        {
          'type': 'mcp_server_tool_call',
          'id': 'c',
          'name': 'tool',
          'server_name': 'srv',
          'arguments': <String, dynamic>{},
        }: McpServerToolCallStep,
        {'type': 'mcp_server_tool_result', 'call_id': 'c', 'result': 'ok'}:
            McpServerToolResultStep,
      };
      for (final entry in cases.entries) {
        final step = InteractionStep.fromJson(entry.key);
        expect(step.runtimeType, entry.value);
      }
    });

    test('unknown type parses as UnknownStep (raw preserved)', () {
      final step = InteractionStep.fromJson({
        'type': 'some_future_step',
        'foo': 'bar',
      });
      expect(step, isA<UnknownStep>());
      expect(step.type, 'some_future_step');
      expect((step as UnknownStep).json['foo'], 'bar');
      expect(step.toJson()['foo'], 'bar');
    });
  });

  group('UserInputStep', () {
    test('roundtrip', () {
      const step = UserInputStep(content: [TextContent(text: 'Hello')]);
      final restored = InteractionStep.fromJson(step.toJson()) as UserInputStep;
      expect(restored.content, hasLength(1));
      expect((restored.content!.first as TextContent).text, 'Hello');
    });

    test('rejects mismatched discriminator', () {
      expect(
        () => UserInputStep.fromJson({'type': 'thought'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('FunctionCallStep', () {
    test('roundtrip preserves arguments', () {
      const step = FunctionCallStep(
        id: 'call-1',
        name: 'get_weather',
        arguments: {'city': 'Tokyo'},
        signature: 'sig123',
      );
      final restored =
          InteractionStep.fromJson(step.toJson()) as FunctionCallStep;
      expect(restored.id, 'call-1');
      expect(restored.name, 'get_weather');
      expect(restored.arguments, {'city': 'Tokyo'});
      expect(restored.signature, 'sig123');
    });

    test('throws when required field missing', () {
      expect(
        () => FunctionCallStep.fromJson({'type': 'function_call'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('copyWith', () {
      const step = FunctionCallStep(id: 'a', name: 'fn', arguments: {});
      expect(step.copyWith(name: 'fn2').name, 'fn2');
      expect(step.copyWith(name: 'fn2').id, 'a');
    });
  });

  group('FunctionResultStep', () {
    test('roundtrip with text result', () {
      const step = FunctionResultStep(
        callId: 'call-1',
        result: ToolResultText('done'),
      );
      final restored =
          InteractionStep.fromJson(step.toJson()) as FunctionResultStep;
      expect(restored.callId, 'call-1');
      expect((restored.result as ToolResultText).text, 'done');
    });

    test('roundtrip with content list result', () {
      const step = FunctionResultStep(
        callId: 'call-1',
        result: ToolResultContentList([
          FunctionResultSubcontentText(TextContent(text: 'piece')),
        ]),
      );
      final restored =
          InteractionStep.fromJson(step.toJson()) as FunctionResultStep;
      final list = restored.result as ToolResultContentList;
      expect(list.items, hasLength(1));
      expect(
        (list.items.first as FunctionResultSubcontentText).content.text,
        'piece',
      );
    });

    test('throws when result missing', () {
      expect(
        () => FunctionResultStep.fromJson({
          'type': 'function_result',
          'call_id': 'c',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ThoughtStep', () {
    test('roundtrip with summary', () {
      const step = ThoughtStep(
        signature: 'sig',
        summary: [ThoughtSummaryContentText(TextContent(text: 'reasoning'))],
      );
      final restored = InteractionStep.fromJson(step.toJson()) as ThoughtStep;
      expect(restored.signature, 'sig');
      expect(restored.summary, hasLength(1));
      expect(
        (restored.summary!.first as ThoughtSummaryContentText).content.text,
        'reasoning',
      );
    });
  });

  group('GoogleSearchCallStep search_type enum', () {
    test('roundtrip', () {
      const step = GoogleSearchCallStep(
        id: 'c',
        arguments: GoogleSearchCallStepArguments(queries: ['q1']),
        searchType: GoogleSearchType.imageSearch,
      );
      final restored =
          InteractionStep.fromJson(step.toJson()) as GoogleSearchCallStep;
      expect(restored.searchType, GoogleSearchType.imageSearch);
      expect(restored.arguments.queries, ['q1']);
    });

    test('unknown search_type returns null (forward-compat)', () {
      final step =
          InteractionStep.fromJson({
                'type': 'google_search_call',
                'id': 'c',
                'arguments': {'queries': <String>[]},
                'search_type': 'future_value',
              })
              as GoogleSearchCallStep;
      expect(step.searchType, isNull);
    });
  });

  group('CodeExecutionCallStepArguments language enum', () {
    test('parses python', () {
      final step =
          InteractionStep.fromJson({
                'type': 'code_execution_call',
                'id': 'c',
                'arguments': {'code': 'x', 'language': 'python'},
              })
              as CodeExecutionCallStep;
      expect(step.arguments.code, 'x');
      expect(step.arguments.language, CodeExecutionLanguage.python);
    });
  });

  group('partial step.start (default-on-absent)', () {
    test('grounding call steps default arguments to empty when absent', () {
      // Streaming `step.start` sends a partial skeleton; `arguments` arrives
      // later via `step.delta`.
      final search =
          InteractionStep.fromJson({
                'type': 'google_search_call',
                'id': 'c',
                'signature': '',
              })
              as GoogleSearchCallStep;
      expect(search.arguments.queries, isNull);

      final url =
          InteractionStep.fromJson({
                'type': 'url_context_call',
                'id': 'c',
                'signature': '',
              })
              as UrlContextCallStep;
      expect(url.arguments.urls, isNull);

      final code =
          InteractionStep.fromJson({'type': 'code_execution_call', 'id': 'c'})
              as CodeExecutionCallStep;
      expect(code.arguments.code, isNull);
    });

    test('grounding result steps default result to empty when absent', () {
      final search =
          InteractionStep.fromJson({
                'type': 'google_search_result',
                'call_id': 'c',
                'signature': '',
              })
              as GoogleSearchResultStep;
      expect(search.result, isEmpty);

      final url =
          InteractionStep.fromJson({
                'type': 'url_context_result',
                'call_id': 'c',
              })
              as UrlContextResultStep;
      expect(url.result, isEmpty);
    });
  });
}
