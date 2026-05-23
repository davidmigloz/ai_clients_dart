import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionExtensions', () {
    Interaction withSteps(List<InteractionStep> steps) => Interaction(
      id: 'test-id',
      status: InteractionStatus.completed,
      steps: steps,
    );

    group('text', () {
      test('returns concatenated text from model_output steps', () {
        final interaction = withSteps([
          const ModelOutputStep(
            content: [
              TextContent(text: 'Hello, '),
              TextContent(text: 'World!'),
            ],
          ),
        ]);
        expect(interaction.text, 'Hello, World!');
      });

      test('returns null when no text content', () {
        final interaction = withSteps([const ThoughtStep(signature: 'sig')]);
        expect(interaction.text, isNull);
      });

      test('returns null when steps is null', () {
        const interaction = Interaction(
          id: 'test-id',
          status: InteractionStatus.completed,
        );
        expect(interaction.text, isNull);
      });

      test('skips empty TextContent when concatenating', () {
        final interaction = withSteps([
          const ModelOutputStep(
            content: [
              TextContent(text: ''),
              TextContent(text: 'Hello'),
              TextContent(text: ''),
              TextContent(text: ' World'),
            ],
          ),
        ]);
        expect(interaction.text, 'Hello World');
      });

      test('skips non-text content and non-output steps', () {
        final interaction = withSteps([
          const ThoughtStep(signature: 'sig'),
          const ModelOutputStep(
            content: [
              TextContent(text: 'Hello'),
              ImageContent(data: 'imagedata'),
              TextContent(text: ' World'),
            ],
          ),
        ]);
        expect(interaction.text, 'Hello World');
      });
    });

    group('textOutputs', () {
      test('returns all text content from model_output steps', () {
        final interaction = withSteps([
          const ModelOutputStep(content: [TextContent(text: 'A')]),
          const ThoughtStep(signature: 'sig'),
          const ModelOutputStep(content: [TextContent(text: 'B')]),
        ]);
        expect(interaction.textOutputs, hasLength(2));
        expect(interaction.textOutputs[0].text, 'A');
        expect(interaction.textOutputs[1].text, 'B');
      });

      test('returns empty list when steps is null', () {
        const interaction = Interaction(
          id: 'test-id',
          status: InteractionStatus.completed,
        );
        expect(interaction.textOutputs, isEmpty);
      });
    });

    group('functionCallSteps', () {
      test('returns all function call steps', () {
        final interaction = withSteps([
          const FunctionCallStep(id: 'call-1', name: 'fn1', arguments: {}),
          const ModelOutputStep(content: [TextContent(text: 'Text')]),
          const FunctionCallStep(id: 'call-2', name: 'fn2', arguments: {}),
        ]);
        expect(interaction.functionCallSteps, hasLength(2));
        expect(interaction.functionCallSteps[0].name, 'fn1');
        expect(interaction.functionCallSteps[1].name, 'fn2');
      });
    });

    group('thoughtSteps', () {
      test('returns all thought steps', () {
        final interaction = withSteps([
          const ThoughtStep(signature: 'sig1'),
          const ModelOutputStep(content: [TextContent(text: 'Text')]),
          const ThoughtStep(signature: 'sig2'),
        ]);
        expect(interaction.thoughtSteps, hasLength(2));
        expect(interaction.thoughtSteps[0].signature, 'sig1');
        expect(interaction.thoughtSteps[1].signature, 'sig2');
      });
    });

    group('imageOutputs', () {
      test('returns all image content from model_output steps', () {
        final interaction = withSteps([
          const ModelOutputStep(
            content: [
              ImageContent(data: 'img1'),
              TextContent(text: 'Text'),
              ImageContent(data: 'img2'),
            ],
          ),
        ]);
        expect(interaction.imageOutputs, hasLength(2));
        expect(interaction.imageOutputs[0].data, 'img1');
        expect(interaction.imageOutputs[1].data, 'img2');
      });
    });

    group('audioOutputs', () {
      test('returns all audio content from model_output steps', () {
        final interaction = withSteps([
          const ModelOutputStep(
            content: [
              AudioContent(data: 'audio1'),
              TextContent(text: 'Text'),
              AudioContent(data: 'audio2'),
            ],
          ),
        ]);
        expect(interaction.audioOutputs, hasLength(2));
        expect(interaction.audioOutputs[0].data, 'audio1');
        expect(interaction.audioOutputs[1].data, 'audio2');
      });
    });

    group('hasTextOutput / hasFunctionCalls', () {
      test('hasTextOutput true with text content', () {
        final interaction = withSteps([
          const ModelOutputStep(content: [TextContent(text: 'Hello')]),
        ]);
        expect(interaction.hasTextOutput, isTrue);
      });

      test('hasTextOutput false without text content', () {
        final interaction = withSteps([const ThoughtStep(signature: 'sig')]);
        expect(interaction.hasTextOutput, isFalse);
      });

      test('hasFunctionCalls true with function call step', () {
        final interaction = withSteps([
          const FunctionCallStep(id: 'call-1', name: 'test', arguments: {}),
        ]);
        expect(interaction.hasFunctionCalls, isTrue);
      });

      test('hasFunctionCalls false without function call steps', () {
        final interaction = withSteps([
          const ModelOutputStep(content: [TextContent(text: 'Text')]),
        ]);
        expect(interaction.hasFunctionCalls, isFalse);
      });
    });

    group('googleMapsCallSteps / googleMapsResultSteps', () {
      test('googleMapsCallSteps returns all maps call steps', () {
        final interaction = withSteps([
          const GoogleMapsCallStep(
            id: 'mc-1',
            arguments: GoogleMapsCallStepArguments(queries: ['pizza']),
          ),
          const ModelOutputStep(content: [TextContent(text: 'Text')]),
          const GoogleMapsCallStep(
            id: 'mc-2',
            arguments: GoogleMapsCallStepArguments(queries: ['sushi']),
          ),
        ]);
        expect(interaction.googleMapsCallSteps, hasLength(2));
        expect(interaction.googleMapsCallSteps[0].id, 'mc-1');
        expect(interaction.googleMapsCallSteps[1].id, 'mc-2');
      });

      test('googleMapsResultSteps returns all maps result steps', () {
        final interaction = withSteps([
          const GoogleMapsResultStep(callId: 'mc-1', result: []),
          const ModelOutputStep(content: [TextContent(text: 'Text')]),
          const GoogleMapsResultStep(callId: 'mc-2', result: []),
        ]);
        expect(interaction.googleMapsResultSteps, hasLength(2));
      });
    });
  });
}
