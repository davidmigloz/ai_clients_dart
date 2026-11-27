/// Whether the platform supports file paths and input streams.
const supportsLocalFiles = false;

/// Local file paths are only available on native platforms.
Future<({List<int> bytes, String fileName})> readLocalFile(String path) {
  throw UnsupportedError('File paths are only available on native platforms.');
}
