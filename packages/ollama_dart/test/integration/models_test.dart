@Tags(['integration'])
library;

import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

/// Integration tests for the Models API.
///
/// These tests require a running Ollama server.
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

  group('ModelsResource', () {
    test('list returns available models', () async {
      final response = await client.models.list();

      expect(response.models, isNotNull);
      expect(response.models, isNotEmpty);

      final firstModel = response.models!.first;
      expect(firstModel.name, isNotNull);
    });

    test('ps returns running models', () async {
      // First, ensure a model is loaded by making a request
      await client.chat.create(
        request: ChatRequest(
          model: model,
          messages: const [ChatMessage.user('Hi')],
        ),
      );

      final response = await client.models.ps();
      expect(response.models, isNotNull);
      // At least one model should be running after our request
      expect(response.models, isNotEmpty);
    });

    test('show returns model details', () async {
      final response = await client.models.show(
        request: ShowRequest(model: model),
      );

      expect(response.details, isNotNull);
      expect(response.capabilities, isNotNull);
    });

    test('show with verbose returns extended info', () async {
      final response = await client.models.show(
        request: ShowRequest(model: model, verbose: true),
      );

      expect(response.template, isNotNull);
      expect(response.parameters, isNotNull);
    });

    test(
      'create model from base model',
      () async {
        const modelName = 'test-model-create';

        final response = await client.models.create(
          request: CreateRequest(
            model: modelName,
            from: model,
            system: 'You are a helpful assistant.',
          ),
        );

        expect(response.status, equals('success'));

        // Cleanup
        await client.models.delete(
          request: const DeleteRequest(model: modelName),
        );
      },
      skip: 'Destructive test - creates a new model',
    );

    test(
      'createStream yields progress updates',
      () async {
        const modelName = 'test-model-stream';

        final events = <StatusEvent>[];
        await client.models
            .createStream(
              request: CreateRequest(
                model: modelName,
                from: model,
                system: 'You are a helpful assistant.',
              ),
            )
            .forEach(events.add);

        expect(events, isNotEmpty);
        expect(events.last.status, equals('success'));

        // Cleanup
        await client.models.delete(
          request: const DeleteRequest(model: modelName),
        );
      },
      skip: 'Destructive test - creates a new model',
    );

    test('copy creates a duplicate model', () async {
      const newName = 'test-model-copy';

      await client.models.copy(
        request: CopyRequest(source: model, destination: newName),
      );

      final models = await client.models.list();
      expect(models.models?.any((m) => m.name == '$newName:latest'), isTrue);

      // Cleanup
      await client.models.delete(request: const DeleteRequest(model: newName));
    }, skip: 'Destructive test - copies a model');

    test(
      'delete removes a model',
      () async {
        const copyName = 'test-model-delete';

        // First create a copy to delete
        await client.models.copy(
          request: CopyRequest(source: model, destination: copyName),
        );

        // Verify it exists
        final before = await client.models.list();
        expect(before.models?.any((m) => m.name == '$copyName:latest'), isTrue);

        // Delete it
        await client.models.delete(
          request: const DeleteRequest(model: copyName),
        );

        // Verify it's gone
        final after = await client.models.list();
        expect(after.models?.any((m) => m.name == '$copyName:latest'), isFalse);
      },
      skip: 'Destructive test - creates and deletes a model',
    );

    test(
      'pull downloads a model',
      () async {
        final response = await client.models.pull(
          request: const PullRequest(model: 'nomic-embed-text:latest'),
        );

        expect(response.status, isNotNull);
      },
      skip: 'Long running test - downloads a model from registry',
    );

    test(
      'pullStream yields download progress',
      () async {
        final events = <StatusEvent>[];

        await client.models
            .pullStream(
              request: const PullRequest(model: 'nomic-embed-text:latest'),
            )
            .forEach(events.add);

        expect(events, isNotEmpty);
        // Check that we got progress updates
        final hasProgress = events.any((e) => e.total != null && e.total! > 0);
        expect(hasProgress, isTrue);
      },
      skip: 'Long running test - downloads a model from registry',
    );
  });

  group('VersionResource', () {
    test('get returns version info', () async {
      final response = await client.version.get();

      expect(response.version, isNotNull);
      expect(response.version, isNotEmpty);
      // Version format is typically like "0.3.4" or similar
      expect(response.version, matches(RegExp(r'^\d+\.\d+')));
    });
  });
}
