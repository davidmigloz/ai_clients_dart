// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating version and health check with the Ollama API.
///
/// This is useful for CI/CD integration and verifying server connectivity.
void main() async {
  final client = OllamaClient();

  try {
    // Simple version check
    print('--- Ollama Server Version ---');
    final version = await client.version.get();
    print('Version: ${version.version}');
    print('');

    // Health check pattern for CI/CD
    print('--- Health Check ---');
    final isHealthy = await checkServerHealth(client);
    if (isHealthy) {
      print('Ollama server is healthy and ready!');
      exit(0);
    } else {
      print('Ollama server health check failed!');
      exit(1);
    }
  } on OllamaException catch (e) {
    print('Error connecting to Ollama: ${e.message}');
    exit(1);
  } finally {
    client.close();
  }
}

/// Health check function useful for CI/CD pipelines.
///
/// Returns true if the Ollama server is reachable and responding.
Future<bool> checkServerHealth(OllamaClient client) async {
  try {
    final version = await client.version.get();
    // Verify we got a valid version response
    return version.version?.isNotEmpty ?? false;
  } catch (e) {
    return false;
  }
}
