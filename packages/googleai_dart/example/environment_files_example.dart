// ignore_for_file: avoid_print

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.length > 2) {
    print(
      'Usage: dart run example/environment_files_example.dart '
      '<environment-id> [file-to-download]',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  try {
    final files = client.environments.files;
    String? pageToken;
    do {
      final page = await files.list(
        environment: args.first,
        pageSize: 50,
        pageToken: pageToken,
        recursive: true,
      );
      for (final entry in page.files ?? const <EnvironmentFile>[]) {
        print('${entry.path} (${entry.type?.value})');
      }
      pageToken = page.nextPageToken;
    } while (pageToken != null && pageToken.isNotEmpty);

    if (args.length == 2) {
      final bytes = await files.download(
        environment: args.first,
        path: args[1],
      );
      print('Downloaded ${bytes.length} bytes.');
    }
  } finally {
    client.close();
  }
}
