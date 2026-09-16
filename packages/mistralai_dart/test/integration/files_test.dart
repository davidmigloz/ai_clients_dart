// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io' as io;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

String _resolveSamplesDir() {
  const candidates = ['packages/mistralai_dart/test/samples', 'test/samples'];
  for (final path in candidates) {
    if (io.Directory(path).existsSync()) return path;
  }
  throw StateError(
    'Cannot find test/samples directory. '
    'Run tests from the workspace root or the package directory.',
  );
}

/// Integration tests for the Files API.
///
/// These tests require a real API key set in the MISTRAL_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  late String samplesDir;
  MistralClient? client;

  setUpAll(() {
    samplesDir = _resolveSamplesDir();

    final apiKey = io.Platform.environment[apiKeyEnvVar];
    if (apiKey == null || apiKey.isEmpty) {
      print(
        '⚠️  $apiKeyEnvVar not set. Integration tests will be skipped.\n'
        '   To run these tests, export $apiKeyEnvVar=your_api_key',
      );
    } else {
      client = MistralClient.withApiKey(apiKey);
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Files', () {
    test(
      'uploads bytes, retrieves the metadata and deletes the file',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (client == null) {
          markTestSkipped('API key not available');
          return;
        }

        final wavBytes = io.File('$samplesDir/harvard.wav').readAsBytesSync();

        final uploaded = await client!.files.upload(
          bytes: wavBytes,
          fileName: 'harvard.wav',
          purpose: FilePurpose.audio,
        );
        try {
          expect(uploaded.id, isNotEmpty);
          final retrieved = await client!.files.retrieve(fileId: uploaded.id);
          expect(retrieved.id, uploaded.id);
        } finally {
          final deleted = await client!.files.delete(fileId: uploaded.id);
          expect(deleted.id, uploaded.id);
        }
      },
    );
  });
}
