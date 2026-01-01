// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Models API.
///
/// Shows how to list available models and retrieve model details.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: List all models
    await listModels(client);

    // Example 2: Get specific model details
    await getModelDetails(client);

    // Example 3: Filter models by capability
    await filterModelsByCapability(client);
  } finally {
    client.close();
  }
}

/// List all available models.
Future<void> listModels(MistralClient client) async {
  print('=== Available Models ===\n');

  final models = await client.models.list();

  print('Found ${models.data.length} models:\n');

  for (final model in models.data) {
    print('  ${model.id}');
    if (model.description != null) {
      print('    Description: ${model.description}');
    }
    if (model.maxContextLength != null) {
      print('    Max context: ${model.maxContextLength} tokens');
    }
    print('');
  }
}

/// Get details for a specific model.
Future<void> getModelDetails(MistralClient client) async {
  print('=== Model Details ===\n');

  const modelId = 'mistral-small-latest';

  try {
    final model = await client.models.get(modelId);

    print('Model: ${model.id}');
    print('  Object: ${model.object}');
    if (model.description != null) {
      print('  Description: ${model.description}');
    }
    if (model.maxContextLength != null) {
      print('  Max context length: ${model.maxContextLength}');
    }
    if (model.capabilities != null) {
      print('  Capabilities:');
      final caps = model.capabilities!;
      print('    - Completion: ${caps.completionChat}');
      print('    - Fine-tuning: ${caps.fineTuning}');
      print('    - Function calling: ${caps.functionCalling}');
      print('    - Vision: ${caps.vision}');
    }
  } catch (e) {
    print('Error retrieving model: $e');
  }

  print('');
}

/// Filter models by capability.
Future<void> filterModelsByCapability(MistralClient client) async {
  print('=== Models by Capability ===\n');

  final models = await client.models.list();

  // Filter for vision-capable models
  final visionModels = models.data.where((m) {
    return m.capabilities?.vision ?? false;
  }).toList();

  print('Vision-capable models (${visionModels.length}):');
  for (final model in visionModels) {
    print('  - ${model.id}');
  }
  print('');

  // Filter for function-calling models
  final functionModels = models.data.where((m) {
    return m.capabilities?.functionCalling ?? false;
  }).toList();

  print('Function-calling models (${functionModels.length}):');
  for (final model in functionModels) {
    print('  - ${model.id}');
  }
  print('');

  // Filter for fine-tuning capable models
  final fineTuningModels = models.data.where((m) {
    return m.capabilities?.fineTuning ?? false;
  }).toList();

  print('Fine-tuning capable models (${fineTuningModels.length}):');
  for (final model in fineTuningModels) {
    print('  - ${model.id}');
  }
  print('');

  // Group by context length
  print('Models by context length:');
  final sortedByContext = [...models.data]
    ..sort((a, b) {
      return (b.maxContextLength ?? 0).compareTo(a.maxContextLength ?? 0);
    });

  for (final model in sortedByContext.take(5)) {
    if (model.maxContextLength != null) {
      print('  - ${model.id}: ${model.maxContextLength} tokens');
    }
  }
}
