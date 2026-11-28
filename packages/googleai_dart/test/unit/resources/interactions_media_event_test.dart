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
    const originalInput = UserInputStep(
      content: [
        TextContent(text: 'Describe the attached clip.'),
        VideoContent(
          uri: 'https://example.test/clip.mp4',
          mimeType: 'video/mp4',
        ),
      ],
    );
    const followUp = UserInputStep(
      content: [TextContent(text: 'Focus on the beginning.')],
    );
    var calls = 0;
    final client = GoogleAIClient(
      config: const GoogleAIConfig(),
      httpClient: MockClient((request) async {
        expect(request.url.path, '/v1beta/interactions');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['store'], isFalse);
        expect(body['previous_interaction_id'], isNull);
        if (calls++ == 0) {
          expect(body['input'], [originalInput.toJson()]);
        } else {
          expect(body['input'], [
            originalInput.toJson(),
            mediaCall,
            mediaResult,
            followUp.toJson(),
          ]);
        }
        return http.Response(
          jsonEncode({
            'id': 'interaction_1',
            'status': 'completed',
            'steps': [originalInput.toJson(), mediaCall, mediaResult],
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
      input: const InteractionInput.steps([originalInput]),
    );
    final steps = result.steps!;
    final call = steps[1] as ProcessingCallStep;
    final resultStep = steps[2] as ProcessingResultStep;
    expect(resultStep.callId, call.id);
    expect(call.signature, 'AQI=');
    expect(call.copyWith().toJson(), mediaCall);
    expect(resultStep.copyWith().toJson(), mediaResult);
    await client.interactions.create(
      model: 'gemini-3.8-flash',
      store: false,
      input: InteractionInput.steps([...steps, followUp]),
    );
    expect(calls, 2);
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
    const guest = TextContent(
      text: 'Thanks for having me.',
      annotations: [SpeechAnnotation(speaker: 'Guest')],
    );
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
        expect(body['input'], [
          {
            'type': 'user_input',
            'content': [text, guest.toJson()],
          },
        ]);
        expect(body['response_format'], {'type': 'audio'});
        expect(body['generation_config'], {
          'speech_config': {
            'speakers': [
              {'speaker': 'Narrator', 'voice': 'Puck'},
              {'speaker': 'Guest', 'voice': 'Kore'},
            ],
          },
        });
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
      input: InteractionInput.steps([
        UserInputStep(content: [content, guest]),
      ]),
      responseFormat: const InteractionResponseFormatConfig.single(
        InteractionAudioResponseFormat(),
      ),
      generationConfig: const InteractionGenerationConfig(
        speechConfigObject: InteractionSpeakerConfig(
          speakers: [
            InteractionSpeechConfig(speaker: 'Narrator', voice: 'Puck'),
            InteractionSpeechConfig(speaker: 'Guest', voice: 'Kore'),
          ],
        ),
      ),
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
      {
        'type': 'text_annotation_delta',
        'annotations': [
          {'type': 'speech_metadata', 'style': 'Excited'},
        ],
      },
    ];
    final start = jsonEncode({
      'event_type': 'step.start',
      'index': 0,
      'step': {'type': 'processing_call', 'id': 'process_1'},
    });
    final body = StringBuffer('data: $start\n\n');
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
    final step = (events.first as StepStartEvent).step as ProcessingCallStep;
    expect(step.id, 'process_1');
    final deltas = events.whereType<StepDeltaEvent>().map(
      (event) => event.delta,
    );
    expect(deltas.first, isA<ProcessingCallDelta>());
    expect(deltas.elementAt(1), isA<ProcessingResultDelta>());
    expect(deltas.elementAt(2), isA<UnknownStepDelta>());
    final annotation = (deltas.last as TextAnnotationDelta).annotations!.single;
    expect((annotation as SpeechAnnotation).style, 'Excited');
    expect(deltas.map((delta) => delta.toJson()), frames);
  });
}
