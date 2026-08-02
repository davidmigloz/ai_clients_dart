// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating fine-tuned model management with the Mistral AI API.
///
/// Note: The fine-tuning *jobs* API has been removed upstream. Training runs
/// are launched outside this client; use `client.fineTuning.models` to
/// manage the fine-tuned models that result from those runs.
///
/// This example shows how to:
/// - List available models, including fine-tuned ones
/// - Update a fine-tuned model's metadata
/// - Archive and unarchive a fine-tuned model
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: List available models ---
    print('=== List Models ===\n');

    final models = await client.models.list();
    print('Total models: ${models.data.length}');

    for (final model in models.data) {
      print('  - ${model.id}');
    }

    // --- Example 2: Update a fine-tuned model's metadata ---
    print('\n=== Update Fine-tuned Model (Example) ===\n');

    print(r'''
Example code:

final updated = await client.fineTuning.models.update(
  modelId: 'ft:mistral-small:my-model:xyz',
  name: 'My Model v2',
  description: 'Fine-tuned for customer support',
);
print('Updated: ${updated.id}');
''');

    // --- Example 3: Archive a fine-tuned model ---
    print('=== Archive a Fine-tuned Model (Example) ===\n');

    print(r'''
Archived models are hidden from the default model list but can be
unarchived later.

final archived = await client.fineTuning.models.archive(
  modelId: 'ft:mistral-small:my-model:xyz',
);
print('Archived: ${archived.archived}');
''');

    // --- Example 4: Unarchive a fine-tuned model ---
    print('=== Unarchive a Fine-tuned Model (Example) ===\n');

    print(r'''
final unarchived = await client.fineTuning.models.unarchive(
  modelId: 'ft:mistral-small:my-model:xyz',
);
print('Unarchived: ${unarchived.archived}');
''');
  } finally {
    client.close();
  }
}
