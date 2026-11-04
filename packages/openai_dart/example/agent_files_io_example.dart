/// Local-only Agent file selection; no API key or network access is used.
library;

import 'dart:io';

import 'package:openai_dart/openai_dart_agent_files_io.dart';

Future<void> main() async {
  // The application explicitly creates and owns this stable directory.
  final root = await Directory.systemTemp.createTemp('agent-file-selection-');
  try {
    await File('${root.path}/selected.bin').writeAsBytes([0, 255, 128]);
    final files = await AgentFileSystem.open(root);
    final selected = await files.selectFile(
      'selected.bin',
      destination: '/workspace/input.bin',
    );
    // Pass this portable input to AgentFiles.prepare when using the API.
    // Here the example only consumes the local selection and reports its size.
    var received = 0;
    await for (final chunk in selected.open()) {
      received += chunk.length;
    }
    stdout.writeln('Selected and read $received binary bytes locally.');
  } finally {
    // Cleanup is an explicit application action, never an adapter side effect.
    await root.delete(recursive: true);
  }
}
