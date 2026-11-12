// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Upload a file, inspect metadata, and follow file pagination.
///
/// Set ANTHROPIC_API_KEY and run:
/// - `dart run example/files_example.dart` to upload sample text.
/// - `dart run example/files_example.dart path/to/file.pdf` to upload a file.
/// - `dart run example/files_example.dart --session sesn_...` to list and read
///   downloadable output files from a Managed Agents session you can access.
///
/// For a browser build, compile with
/// `dart compile js -DANTHROPIC_PROXY_URL=https://your-proxy.example example/files_example.dart`.
/// Load the compiled script from your application. The backend handles Claude
/// authentication and CORS. The example uses byte upload when no arguments
/// are supplied.
Future<void> main(List<String> args) async {
  if (args.length > 1 && (args.length != 2 || args.first != '--session')) {
    print('Usage: dart run example/files_example.dart [path | --session ID]');
    return;
  }

  const proxyUrl = String.fromEnvironment('ANTHROPIC_PROXY_URL');
  final client = proxyUrl.isEmpty
      ? AnthropicClient.fromEnvironment()
      : AnthropicClient(config: const AnthropicConfig(baseUrl: proxyUrl));
  try {
    if (args case ['--session', final sessionId]) {
      String? page;
      do {
        // The scope filter adds the Managed Agents beta header automatically.
        final files = await client.files.list(scopeId: sessionId, page: page);
        for (final file in files.data) {
          print('${file.id}: ${file.filename}');
          if (file.downloadable) {
            final bytes = await client.files.download(fileId: file.id);
            print('Read ${bytes.length} bytes.');
          }
        }
        page = files.nextPage;
      } while (page != null);
      return;
    }

    final uploaded = args.isEmpty
        ? await client.files.uploadBytes(
            bytes: Uint8List.fromList(utf8.encode('Hello from Dart!')),
            fileName: 'hello.txt',
            mimeType: 'text/plain',
            expiresInSeconds: 3600,
          )
        : await client.files.upload(
            filePath: args.single,
            expiresInSeconds: 3600,
          );
    try {
      final file = await client.files.retrieve(fileId: uploaded.id);
      print('${file.id}: ${file.filename} (${file.sizeBytes} bytes)');
      print('Expires at ${file.expiresAt}');

      String? page;
      do {
        final files = await client.files.list(limit: 20, page: page);
        for (final item in files.data) {
          print('${item.id}: ${item.filename}');
        }
        page = files.nextPage;
      } while (page != null);
    } finally {
      await client.files.deleteFile(fileId: uploaded.id);
    }
  } finally {
    client.close();
  }
}
