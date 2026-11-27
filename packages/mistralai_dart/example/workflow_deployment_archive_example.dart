// ignore_for_file: avoid_print
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mistralai_dart/mistralai_dart.dart';

/// Creates an archive-backed workflow deployment using a gzipped tar file.
///
/// Run with a paid Mistral workspace that has Managed Deployments access.
Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null || args.length != 2) {
    print(
      'Set MISTRAL_API_KEY and pass the path to a .tar.gz containing a '
      'Dockerfile, followed by a deployment name.',
    );
    exitCode = 1;
    return;
  }

  final archive = File(args[0]);
  final size = await archive.length();
  if (size < 1 || size > 268435456) {
    print('The archive must contain 1 to 268435456 bytes.');
    exitCode = 1;
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  final storage = http.Client();
  try {
    final slot = await client.workflows.deployments.createArchive(
      request: CreateDeploymentArchiveRequest(size: size),
    );
    final uploadUrl = Uri.parse(slot.uploadUrl);
    if (uploadUrl.scheme != 'https' || !uploadUrl.hasAuthority) {
      throw StateError('Expected an HTTPS archive upload URL');
    }

    // Send the signed headers and raw archive bytes through a separate client.
    final upload = http.Request('PUT', uploadUrl)
      ..followRedirects = false
      ..headers.addAll(slot.uploadHeaders)
      ..bodyBytes = await archive.readAsBytes();
    final int statusCode;
    try {
      final response = await storage.send(upload);
      await response.stream.drain<void>();
      statusCode = response.statusCode;
    } on http.ClientException {
      // Some transport errors include the URL and its signing credential.
      throw StateError('Archive upload transport failed');
    }
    if (statusCode < 200 || statusCode >= 300) {
      throw StateError('Archive upload failed with HTTP $statusCode');
    }

    final deployment = await client.workflows.deployments.create(
      request: CreateDeploymentRequest(
        name: args[1],
        spec: DeploymentWorkerSpecInput(
          archiveId: slot.archiveId,
          backendSpec: const DeploymentMistralCloudBackendSpec(
            dockerfilePath: 'Dockerfile',
          ),
        ),
      ),
    );
    print('Created ${deployment.name} with phase ${deployment.status.phase}.');
  } finally {
    storage.close();
    client.close();
  }
}
