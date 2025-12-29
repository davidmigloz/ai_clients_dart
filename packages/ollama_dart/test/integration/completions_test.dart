@Tags(['integration'])
library;

import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

/// Integration tests for the Completions API.
///
/// These tests require a running Ollama server with a model.
/// Set OLLAMA_MODEL environment variable to specify the model (default: gpt-oss).
/// Run with: dart test --tags=integration
void main() {
  late OllamaClient client;
  late String model;

  setUpAll(() {
    client = OllamaClient();
    model = Platform.environment['OLLAMA_MODEL'] ?? 'gpt-oss';
  });

  tearDownAll(() {
    client.close();
  });

  group('CompletionsResource', () {
    test('generate creates a completion', () async {
      final response = await client.completions.generate(
        request: GenerateRequest(
          model: model,
          prompt: 'Complete this: The capital of France is',
        ),
      );

      expect(response.response, isNotNull);
      expect(response.response!.toLowerCase(), contains('paris'));
      expect(response.done, isTrue);
    });

    test('generateStream yields chunks', () async {
      final chunks = <GenerateStreamEvent>[];

      await client.completions
          .generateStream(
            request: GenerateRequest(model: model, prompt: 'Say hello'),
          )
          .forEach(chunks.add);

      expect(chunks, isNotEmpty);
      expect(chunks.last.done, isTrue);
    });

    test('system prompt works', () async {
      final response = await client.completions.generate(
        request: GenerateRequest(
          model: model,
          prompt: 'Describe yourself',
          system: 'You are a helpful robot named Robo.',
        ),
      );

      expect(response.response, isNotNull);
      expect(response.response!.toLowerCase(), contains('robo'));
    });

    test(
      'JSON format works',
      () async {
        final response = await client.completions.generate(
          request: GenerateRequest(
            model: model,
            prompt:
                'Return a JSON object with key "greeting" and value "hello"',
            format: 'json',
          ),
        );

        expect(response.response, isNotNull);
        expect(response.response, contains('{'));
        expect(response.response, contains('hello'));
      },
      skip: 'Requires a model with JSON format support (e.g., llama3.2)',
    );

    test('includes timing statistics', () async {
      final response = await client.completions.generate(
        request: GenerateRequest(model: model, prompt: 'Hello'),
      );

      expect(response.totalDuration, isNotNull);
      expect(response.totalDuration, greaterThan(0));
      expect(response.evalCount, isNotNull);
    });

    test('raw mode bypasses templating', () async {
      final response = await client.completions.generate(
        request: GenerateRequest(
          model: model,
          prompt:
              'List the numbers from 1 to 9 in order. '
              'Output ONLY the numbers in one line without any spaces or commas. '
              'NUMBERS:',
          raw: true,
        ),
      );

      expect(response.response, isNotNull);
      final output = response.response!.replaceAll(RegExp(r'[\s\n]'), '');
      expect(output, contains('123456789'));
    });

    test('stop sequence works', () async {
      final response = await client.completions.generate(
        request: GenerateRequest(
          model: model,
          prompt:
              'List the numbers from 1 to 9 in order. '
              'Output ONLY the numbers in one line without any spaces or commas. '
              'NUMBERS:',
          options: const ModelOptions(stop: ['4']),
        ),
      );

      expect(response.response, isNotNull);
      final output = response.response!.replaceAll(RegExp(r'[\s\n]'), '');
      expect(output, contains('123'));
      expect(output, isNot(contains('456789')));
    });

    test(
      'image input works with vision model',
      () async {
        final visionModel =
            Platform.environment['OLLAMA_VISION_MODEL'] ?? 'llava';

        final response = await client.completions.generate(
          request: GenerateRequest(
            model: visionModel,
            prompt: 'What is in the image?',
            images: const [
              // Small base64 encoded star image
              'iVBORw0KGgoAAAANSUhEUgAAAAkAAAANCAIAAAD0YtNRAAAABnRSTlMA/AD+APzoM1ogAAAAWklEQVR4AWP48+8PLkR7uUdzcMvtU8EhdykHKAciEXL3pvw5FQIURaBDJkARoDhY3zEXiCgCHbNBmAlUiyaBkENoxZSDWnOtBmoAQu7TnT+3WuDOA7KBIkAGAGwiNeqjusp/AAAAAElFTkSuQmCC',
            ],
          ),
        );

        expect(response.response, isNotNull);
        final content = response.response!.toLowerCase();
        expect(content, contains('star'));
      },
      skip: 'Requires a vision model (e.g., llava) to be available',
    );
  });
}
