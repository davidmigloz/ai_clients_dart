// ignore_for_file: avoid_print
/// Example demonstrating model operations with OpenAI.
///
/// This example shows how to list and retrieve model information.
/// Run with: dart run example/models_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // List all available models
    print('=== List All Models ===\n');

    final models = await client.models.list();
    print('Total models available: ${models.data.length}\n');

    // Filter and display GPT models
    print('=== GPT Models ===\n');

    final gptModels = models.data.where((m) => m.id.startsWith('gpt')).toList();

    for (final model in gptModels.take(10)) {
      print('Model: ${model.id}');
      print('  Owned by: ${model.ownedBy}');
      print('  Created: ${model.createdAt}');
      print('');
    }

    if (gptModels.length > 10) {
      print('... and ${gptModels.length - 10} more GPT models\n');
    }

    // Filter and display embedding models
    print('=== Embedding Models ===\n');

    final embeddingModels = models.data
        .where((m) => m.id.contains('embedding'))
        .toList();

    for (final model in embeddingModels) {
      print('Model: ${model.id}');
      print('  Owned by: ${model.ownedBy}');
      print('');
    }

    // Filter and display audio models
    print('=== Audio Models ===\n');

    final audioModels = models.data
        .where((m) => m.id.contains('whisper') || m.id.contains('tts'))
        .toList();

    for (final model in audioModels) {
      print('Model: ${model.id}');
      print('  Owned by: ${model.ownedBy}');
      print('');
    }

    // Retrieve a specific model
    print('=== Retrieve Specific Model ===\n');

    final gpt4o = await client.models.retrieve('gpt-4o');
    print('Model: ${gpt4o.id}');
    print('  Object: ${gpt4o.object}');
    print('  Owned by: ${gpt4o.ownedBy}');
    print('  Created: ${gpt4o.createdAt}');
    print('');

    // Group models by owner
    print('=== Models by Owner ===\n');

    final modelsByOwner = <String, List<Model>>{};
    for (final model in models.data) {
      final owner = model.ownedBy ?? 'unknown';
      modelsByOwner.putIfAbsent(owner, () => []).add(model);
    }

    for (final entry in modelsByOwner.entries) {
      print('${entry.key}: ${entry.value.length} model(s)');
    }
    print('');

    // List fine-tuned models (if any)
    print('=== Fine-tuned Models ===\n');

    final fineTunedModels = models.data
        .where((m) => m.id.startsWith('ft:'))
        .toList();

    if (fineTunedModels.isEmpty) {
      print('No fine-tuned models found.\n');
    } else {
      for (final model in fineTunedModels) {
        print('Model: ${model.id}');
        print('  Created: ${model.createdAt}');
        print('');
      }
    }
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
