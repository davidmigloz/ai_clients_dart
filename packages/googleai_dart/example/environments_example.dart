// ignore_for_file: avoid_print

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';

/// Example: managing execution environments for the Interactions API.
///
/// The Environments API (experimental) manages standalone sandboxes —
/// mounted sources and network egress rules — that can be referenced by id
/// from an agent or interaction, instead of configuring them inline every
/// time.
Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
  if (apiKey == null) {
    print('Set GOOGLE_GENAI_API_KEY to run this example.');
    return;
  }

  final client = GoogleAIClient.fromEnvironment();

  try {
    // 1. Create an environment with an inline source and a restricted
    //    network allowlist.
    final environment = await client.environments.create(
      environment: const CreateEnvironmentRequest(
        network: EnvironmentNetworkAllowlist(
          allowlist: [AllowlistEntry(domain: 'wikipedia.org')],
        ),
        sources: [
          Source(
            type: SourceType.inline,
            target: '/mnt/notes/readme.md',
            content: '# Project notes\n\nSee wikipedia.org for background.',
          ),
        ],
      ),
    );
    print('Created environment: ${environment.id} (${environment.status})');

    // 2. List environments.
    final page = await client.environments.list(pageSize: 10);
    for (final e in page.environments ?? const <Environment>[]) {
      print('- ${e.id}: ${e.status}, ${e.sizeBytes ?? '0'} bytes');
    }

    // 3. Fetch a single environment by id.
    final fetched = await client.environments.get(environment.id);
    print('Fetched environment size: ${fetched.sizeBytes} bytes');

    // 4. Clean up.
    await client.environments.delete(environment.id);
    print('Deleted environment ${environment.id}.');
  } finally {
    client.close();
  }
}
