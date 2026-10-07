// ignore_for_file: avoid_print
/// Demonstrates explicit image models and the JSON-edit default locally.
///
/// Run: dart run example/image_model_selection_example.dart
/// MockClient returns fixtures; no key, network calls, or API charges are needed.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final transport = MockClient.streaming((request, body) async {
    final bytes = await body.toBytes();
    if (request is http.MultipartRequest) {
      print('Multipart edit model: ${request.fields['model']}');
    } else {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final operation = request.url.path.endsWith('/generations')
          ? 'Generation'
          : 'JSON edit';
      print(
        '$operation model: ${json['model'] ?? '(omitted; server default)'}',
      );
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode('{"created":0,"data":[{"b64_json":"AA=="}]}')),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('local-fixture'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    await client.images.generate(
      const ImageGenerationRequest(
        model: ImageModels.gptImage25Flare,
        prompt: 'A red circle',
      ),
    );
    await client.images.edit(
      ImageEditRequest(
        model: ImageModels.gptImage25Sunburst,
        image: Uint8List.fromList([1, 2, 3]),
        imageFilename: 'source.png',
        prompt: 'Add a blue outline',
      ),
    );
    // This model field is optional; the client sends no default itself.
    await client.images.editJson(
      const ImageEditJsonRequest(
        images: [ImageReference.file('file-source')],
        prompt: 'Add a blue outline',
      ),
    );
    // Unknown/future model IDs are forwarded unchanged, even without a constant.
    await client.images.editJson(
      const ImageEditJsonRequest(
        model: 'custom-image-model',
        images: [ImageReference.file('file-source')],
        prompt: 'Add a blue outline',
      ),
    );
  } finally {
    client.close();
    transport.close();
  }
}
