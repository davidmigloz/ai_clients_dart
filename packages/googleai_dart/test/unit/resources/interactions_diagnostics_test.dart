import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test(
    'reads reported faults, exact token budgets, and code tool output',
    () async {
      final fixture = {
        'object': 'interaction',
        'id': 'agent_run_fixture',
        'status': 'completed',
        'max_total_tokens': '9007199254740993',
        'errors': [
          {
            'code': 'https://example.test/platform-fault',
            'message': 'One optional artifact could not be processed.',
          },
        ],
        'steps': [
          {
            'type': 'code_execution_call',
            'id': 'call_1',
            'arguments': {'code': 'printf hello', 'language': 'bash'},
          },
          {
            'type': 'code_execution_result',
            'call_id': 'call_1',
            'result': [
              {'type': 'text', 'text': 'hello'},
              {'type': 'image', 'data': 'AQI=', 'mime_type': 'image/png'},
            ],
          },
          {
            'type': 'code_execution_result',
            'call_id': 'call_2',
            'result': 'legacy text',
          },
          {
            'type': 'code_execution_result',
            'call_id': 'call_3',
            'result': [
              {'type': 'future_media'},
            ],
          },
        ],
      };
      final client = GoogleAIClient(
        config: const GoogleAIConfig(),
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v1beta/interactions/agent_run_fixture');
          return http.Response(
            jsonEncode(fixture),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      addTearDown(client.close);

      final response = await client.interactions.get('agent_run_fixture');
      expect(response.maxTotalTokens, '9007199254740993');
      expect(
        response.errors!.single.message,
        'One optional artifact could not be processed.',
      );
      final steps = response.steps!;
      final call = steps.first as CodeExecutionCallStep;
      expect(call.arguments.language, CodeExecutionLanguage.bash);
      final structured = steps[1] as CodeExecutionResultStep;
      expect(structured.result, isEmpty);
      expect(structured.resultContent, [
        isA<TextContent>(),
        isA<ImageContent>(),
      ]);
      expect(structured.copyWith(result: 'replacement').resultContent, isNull);
      expect((steps[2] as CodeExecutionResultStep).result, 'legacy text');
      expect((steps[3] as CodeExecutionResultStep).resultContent, isNull);
      expect(response.copyWith().toJson(), fixture);
      expect(
        response.copyWith(errors: null, maxTotalTokens: null).errors,
        isNull,
      );
    },
  );

  test('encodes and decodes the video extension selector', () {
    const config = InteractionVideoConfig(
      task: InteractionVideoConfigTask.extend,
    );
    expect(config.toJson(), {'task': 'extend'});
    expect(
      InteractionVideoConfig.fromJson(config.toJson()).task,
      InteractionVideoConfigTask.extend,
    );
  });
}
