import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('stateless media processing steps retain opaque signatures', () async {
    final mediaCall = {
      'type': 'processing_call',
      'id': 'media_call_1',
      'signature': 'AQI=',
      'future_call_field': 7,
    };
    final mediaResult = {
      'type': 'processing_result',
      'call_id': 'media_call_1',
      'signature': 'AgM=',
    };
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1beta/interactions');
        expect((jsonDecode(request.body) as Map<String, dynamic>)['input'], [
          mediaCall,
          mediaResult,
        ]);
        return http.Response(
          jsonEncode({
            'id': 'interaction_1',
            'status': 'completed',
            'steps': [mediaCall, mediaResult],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(client.close);

    final result = await client.interactions.create(
      model: 'gemini-3.8-flash',
      store: false,
      input: InteractionInput.steps([
        InteractionStep.fromJson(mediaCall),
        InteractionStep.fromJson(mediaResult),
      ]),
    );
    final steps = result.steps!;
    final call = steps[0] as ProcessingCallStep;
    final resultStep = steps[1] as ProcessingResultStep;
    expect(resultStep.callId, call.id);
    expect(call.signature, 'AQI=');
    expect(call.copyWith().toJson(), mediaCall);
    expect(resultStep.copyWith().toJson(), mediaResult);
  });

  test('sends typed speech metadata with attributed text input', () async {
    final text = {
      'type': 'text',
      'text': 'Olá.',
      'annotations': [
        {
          'type': 'speech_metadata',
          'start_index': 0,
          'end_index': 5,
          'speaker': 'Narrator',
          'style': 'Softly',
          'future_speech_field': {'pace': 'slow'},
        },
      ],
    };
    final content = InteractionContent.fromJson(text) as TextContent;
    final speech = content.annotations!.single as SpeechAnnotation;
    expect(speech.startIndex, 0);
    expect(speech.endIndex, 5);
    expect(speech.speaker, 'Narrator');
    expect(speech.style, 'Softly');
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(request.url.path, '/v1beta/interactions');
        expect(body['model'], 'gemini-3.8-flash-tts');
        expect(body['input'], [text]);
        return http.Response(
          '{"id":"speech_interaction","status":"completed"}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    addTearDown(client.close);

    await client.interactions.create(
      model: 'gemini-3.8-flash-tts',
      input: InteractionInput.contentList([content]),
    );
  });

  test('streams typed media deltas and preserves unknown shapes', () async {
    final frames = [
      {
        'type': 'processing_call',
        'signature': 'AQI=',
        'future_call_field': {'param': 'sample'},
      },
      {'type': 'processing_result', 'signature': 'AgM='},
      {'type': 'processing_result', 'signature': 1},
    ];
    final body = StringBuffer();
    for (final delta in frames) {
      body.write(
        'data: ${jsonEncode({'event_type': 'step.delta', 'index': 0, 'delta': delta})}\n\n',
      );
    }
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient(
        (_) async => http.Response(
          body.toString(),
          200,
          headers: {'content-type': 'text/event-stream; charset=utf-8'},
        ),
      ),
    );
    addTearDown(client.close);
    final events = await client.interactions
        .createStream(
          model: 'gemini-3.8-flash',
          input: const InteractionInput.text('Offline fixture'),
        )
        .toList();
    final deltas = events.cast<StepDeltaEvent>().map((event) => event.delta);
    expect(deltas.first, isA<ProcessingCallDelta>());
    expect(deltas.elementAt(1), isA<ProcessingResultDelta>());
    expect(deltas.last, isA<UnknownStepDelta>());
    expect(deltas.map((delta) => delta.toJson()), frames);
  });
}
