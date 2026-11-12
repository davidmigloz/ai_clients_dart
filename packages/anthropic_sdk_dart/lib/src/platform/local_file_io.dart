import 'dart:io';
import 'dart:typed_data';

/// Reads a local file and obtains its platform-specific basename.
Future<({Uint8List bytes, String name})> readLocalFile(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw ArgumentError('File not found: $filePath');
  }
  return (bytes: await file.readAsBytes(), name: file.uri.pathSegments.last);
}
