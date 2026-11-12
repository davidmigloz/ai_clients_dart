import 'dart:typed_data';

/// Reports that local path uploads require a platform with dart:io.
Future<({Uint8List bytes, String name})> readLocalFile(String _) {
  throw UnsupportedError(
    'File path uploads require dart:io. Use uploadBytes on this platform.',
  );
}
