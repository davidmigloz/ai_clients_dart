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
              {
                'type': 'text',
                'text': 'hello',
                'future': [1, 2],
              },
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
      final copy = structured.copyWith(signature: 'AQI=');
      final serialized = copy.toJson()['result'] as List<dynamic>;
      (serialized.first as Map<String, dynamic>)['text'] = 'changed externally';
      expect((structured.resultContent!.first as TextContent).text, 'hello');
      expect(copy.toJson()['result'], structured.toJson()['result']);
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

  test('decodes result content independently of the caller JSON', () {
    final ids = [1, 2];
    final step = CodeExecutionResultStep.fromJson({
      'type': 'code_execution_result',
      'call_id': 'code',
      'result': [
        {
          'type': 'text',
          'text': 'record',
          'annotations': [
            {
              'type': 'file_citation',
              'custom_metadata': {'ids': ids},
            },
          ],
        },
      ],
    });
    ids[0] = 7;
    final text = step.resultContent!.single as TextContent;
    final citation = text.annotations!.single as FileCitation;
    expect(citation.customMetadata!['ids'], [1, 2]);
    expect(step.toJson()['result'], [
      {
        'type': 'text',
        'text': 'record',
        'annotations': [
          {
            'type': 'file_citation',
            'custom_metadata': {
              'ids': [1, 2],
            },
          },
        ],
      },
    ]);
  });

  test('retains diagnostic faults from every continuation hop', () async {
    var calls = 0;
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        calls++;
        final first = calls == 1;
        expect(body['continuation_token'], first ? isNull : 'opaque');
        return http.Response(
          jsonEncode({
            'id': 'hop_$calls',
            'status': first ? 'requires_continuation' : 'completed',
            if (first) 'continuation_token': 'opaque',
            'errors': [
              {'code': 'fault_$calls'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(client.close);
    final result = await client.interactions.create(
      model: 'gemini-3.8-flash',
      input: const InteractionInput.text('Offline fixture'),
      automaticContinuation: true,
    );
    expect(calls, 2);
    expect(result.errors?.map((item) => item.code), ['fault_1', 'fault_2']);
  });

  test('sends the video extension selector through Interactions', () async {
    const config = InteractionVideoConfig(
      task: InteractionVideoConfigTask.extend,
    );
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.url.path, '/v1beta/interactions');
        expect(body['generation_config'], {
          'video_config': {'task': 'extend'},
        });
        return http.Response(
          '{"id":"clip_extension","status":"completed"}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(client.close);
    await client.interactions.create(
      model: 'gemini-omni-flash-preview',
      input: const InteractionInput.contentList([
        TextContent(text: 'Continue the shot.'),
        VideoContent(
          uri: 'https://example.test/signed-clip',
          mimeType: 'video/mp4',
        ),
      ]),
      generationConfig: const InteractionGenerationConfig(videoConfig: config),
    );
    expect(
      InteractionVideoConfig.fromJson(config.toJson()).task,
      InteractionVideoConfigTask.extend,
    );
  });
}
