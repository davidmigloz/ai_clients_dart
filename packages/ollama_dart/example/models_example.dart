// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating model management with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // List all models
    print('--- Available Models ---');
    final models = await client.models.list();
    for (final model in models.models ?? <ModelSummary>[]) {
      final sizeGb = (model.size ?? 0) / (1024 * 1024 * 1024);
      print('${model.name} (${sizeGb.toStringAsFixed(2)} GB)');
      if (model.details != null) {
        print('  Family: ${model.details?.family}');
        print('  Parameters: ${model.details?.parameterSize}');
        print('  Quantization: ${model.details?.quantizationLevel}');
      }
    }

    // Show model details
    print('\n--- Model Details ---');
    final details = await client.models.show(
      request: const ShowRequest(model: 'gpt-oss'),
    );
    print('Template: ${details.template?.substring(0, 100)}...');
    print('Capabilities: ${details.capabilities?.join(', ')}');

    // List running models
    print('\n--- Running Models ---');
    final running = await client.models.ps();
    if (running.models?.isEmpty ?? true) {
      print('No models currently running');
    } else {
      for (final model in running.models!) {
        final vramGb = (model.sizeVram ?? 0) / (1024 * 1024 * 1024);
        print('${model.model} - VRAM: ${vramGb.toStringAsFixed(2)} GB');
        print('  Context: ${model.contextLength}');
        print('  Expires: ${model.expiresAt}');
      }
    }

    // Pull a model with progress (streaming)
    print('\n--- Pull Model (if not exists) ---');
    print('Checking for nomic-embed-text...');

    final hasModel =
        models.models?.any(
          (m) => m.name?.startsWith('nomic-embed-text') ?? false,
        ) ??
        false;

    if (!hasModel) {
      print('Pulling nomic-embed-text...');
      await for (final status in client.models.pullStream(
        request: const PullRequest(model: 'nomic-embed-text'),
      )) {
        if (status.total != null && status.total! > 0) {
          final percent = ((status.completed ?? 0) / status.total!) * 100;
          stdout.write('\r${status.status}: ${percent.toStringAsFixed(1)}%');
        } else {
          stdout.write('\r${status.status}');
        }
      }
      print('\nPull complete!');
    } else {
      print('Model already exists');
    }

    // Get server version
    print('\n--- Server Version ---');
    final version = await client.version.get();
    print('Ollama version: ${version.version}');
  } finally {
    client.close();
  }
}
