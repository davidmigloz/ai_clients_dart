import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';

/// Downloads a generated Gemini file to a local path.
Future<void> main(List<String> args) async {
  if (args.length != 2 ||
      !(args.first.startsWith('files/') ||
          args.first.startsWith('generatedFiles/'))) {
    io.stderr.writeln(
      'Set GOOGLE_GENAI_API_KEY and run dart run '
      'example/generated_files_example.dart <resource-name> <output-path>. '
      'Use a files/{id} or generatedFiles/{id} name.',
    );
    return;
  }

  final name = args.first;
  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  try {
    final List<int> bytes;
    if (name.startsWith('generatedFiles/')) {
      bytes = await client.generatedFiles.download(name: name);
    } else {
      final file = await client.files.get(name: name);
      if (file.source != FileSource.generated && file.downloadUri == null) {
        throw StateError(
          'Choose an API-generated file available for download.',
        );
      }
      bytes = await client.files.download(name: file.name);
    }
    final destination = io.File(args.last);
    await destination.writeAsBytes(bytes);
    io.stdout.writeln('Saved ${bytes.length} bytes to ${destination.path}.');
  } finally {
    client.close();
  }
}
