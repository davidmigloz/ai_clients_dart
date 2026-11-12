import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads scoped Claude Enterprise projects and optional Code Artifact bytes.
///
/// Set ANTHROPIC_COMPLIANCE_ACCESS_KEY with read:compliance_user_data.
/// Set ANTHROPIC_COMPLIANCE_ARTIFACT_ID to also download a known artifact.
Future<void> main() async {
  final key = Platform.environment['ANTHROPIC_COMPLIANCE_ACCESS_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln(
      'Set ANTHROPIC_COMPLIANCE_ACCESS_KEY with read:compliance_user_data.',
    );
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(key);
  try {
    final apps = client.compliance.apps;
    final projects = await apps.listProjects(limit: 10);
    stdout.writeln('Fetched ${projects.data.length} project records.');

    // An optional artifact ID selects a specific artifact to download.
    final artifactId = Platform.environment['ANTHROPIC_COMPLIANCE_ARTIFACT_ID'];
    if (artifactId != null && artifactId.isNotEmpty) {
      final bytes = apps.downloadCodeArtifact(artifactId, allowZip: true);
      final size = await bytes.fold<int>(0, (sum, chunk) => sum + chunk.length);
      stdout.writeln('Read $size bytes.');
    }
  } finally {
    client.close();
  }
}
