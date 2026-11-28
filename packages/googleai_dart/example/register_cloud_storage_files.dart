// ignore_for_file: avoid_print

import 'dart:io' show Platform, exitCode, stderr;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print(
      'Usage: dart run example/register_cloud_storage_files.dart gs://bucket/object',
    );
    return;
  }
  final token = Platform.environment['GOOGLE_OAUTH_ACCESS_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln(
      'Set GOOGLE_OAUTH_ACCESS_TOKEN to a Google Cloud OAuth access token.',
    );
    exitCode = 64;
    return;
  }

  final client = GoogleAIClient(config: const GoogleAIConfig());
  try {
    final result = await client.files.register(
      uris: args,
      authProvider: BearerTokenProvider(token),
      quotaProjectId: Platform.environment['GOOGLE_CLOUD_QUOTA_PROJECT'],
    );
    for (final file in result.files ?? const <File>[]) {
      print(file.uri);
    }
  } finally {
    client.close();
  }
}
