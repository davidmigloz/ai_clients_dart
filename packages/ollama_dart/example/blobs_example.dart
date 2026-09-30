// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Uploads a local model file and creates a model from its blob.
/// Usage: dart run example/blobs_example.dart FILE SHA256_DIGEST MODEL_NAME
/// Compute the digest of FILE first; supply it as sha256:<64 hex characters>.
Future<void> main(List<String> args) async {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run example/blobs_example.dart '
      'FILE sha256:<digest> MODEL_NAME',
    );
    exitCode = 64;
    return;
  }

  final file = File(args[0]);
  final digest = args[1];
  final modelName = args[2];
  final fileName = file.uri.pathSegments.last;
  final client = OllamaClient.fromEnvironment();

  try {
    if (!await client.blobs.exists(digest: digest)) {
      await client.blobs.create(
        digest: digest,
        bytes: await file.readAsBytes(),
      );
      print('Uploaded $fileName');
    } else {
      print('Blob already exists');
    }

    // Preserve original split-GGUF shard names and include every shard in files.
    // This example imports one file. Prepare GGUF quantization before upload.
    final response = await client.models.create(
      request: CreateRequest(model: modelName, files: {fileName: digest}),
    );
    print('Created $modelName: ${response.status}');
  } finally {
    client.close();
  }
}
