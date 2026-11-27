import 'dart:io';

import '../../errors/exceptions.dart';

/// Whether the platform supports file paths and input streams.
const supportsLocalFiles = true;

/// Buffers a local file so HTTP retries can replay its bytes.
Future<({List<int> bytes, String fileName})> readLocalFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw const ValidationException(
      message: 'File not found',
      fieldErrors: {
        'filePath': ['File does not exist'],
      },
    );
  }
  return (
    bytes: await file.readAsBytes(),
    fileName: file.uri.pathSegments.last,
  );
}
