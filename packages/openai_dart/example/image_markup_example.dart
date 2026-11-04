/// Image edit overlays and safety identifiers using an offline synthetic peer.
/// No API key, image generation, network request or charge is involved.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // A tiny transparent PNG is sufficient for this mock wire demonstration.
  // Supply your real image and matching overlay when using a live service.
  const png =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpeqz8AAAAASUVORK5CYII=';
  final bytes = base64Decode(png);
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    if (request.url.path != '/v1/images/edits') {
      throw StateError('Unexpected synthetic endpoint.');
    }
    if (request.headers['content-type']!.startsWith('application/json')) {
      final body =
          jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
      if (body['markup'] == null ||
          body.containsKey('mask') ||
          body['safety_identifier'] != 'synthetic-user-hash') {
        throw StateError('Missing overlay or safety identifier.');
      }
      return http.Response(
        jsonEncode({
          'created': 1,
          'data': [
            {'b64_json': png},
          ],
          'safety_identifier': 'synthetic-user-hash',
        }),
        200,
      );
    }
    final body = latin1.decode(request.bodyBytes);
    if (!body.contains('name="markup"') ||
        !body.contains('name="safety_identifier"') ||
        body.contains('name="mask"')) {
      throw StateError('Unexpected synthetic multipart fields.');
    }
    return http.Response(
      'data: ${jsonEncode({
        'type': 'image_edit.completed',
        'b64_json': png,
        'created_at': 1,
        'size': '1024x1024',
        'quality': 'high',
        'background': 'transparent',
        'output_format': 'png',
        'safety_identifier': 'synthetic-user-hash',
        'usage': {
          'input_tokens': 1,
          'output_tokens': 1,
          'total_tokens': 2,
          'input_tokens_details': {'text_tokens': 1, 'image_tokens': 0},
        },
      })}\n\ndata: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final client = OpenAIClient(httpClient: transport);
  try {
    final edited = await client.images.editJson(
      ImageEditJsonRequest(
        images: const [ImageReference.file('file_original')],
        markup: const ImageReference.url('data:image/png;base64,$png'),
        model: ImageModels.gptImage25Sunburst,
        prompt:
            'Follow the transparent PNG overlay while retaining the subject.',
        safetyIdentifier: 'synthetic-user-hash',
      ),
    );
    if (edited.safetyIdentifier != 'synthetic-user-hash') {
      throw StateError('The effective identifier was lost.');
    }
    var completed = false;
    await for (final event in client.images.editStream(
      ImageEditRequest(
        image: bytes,
        imageFilename: 'original.png',
        markup: bytes,
        markupFilename: 'overlay.png',
        model: ImageModels.gptImage25Sunburst,
        prompt: 'Follow the overlay in the first input image.',
        safetyIdentifier: 'synthetic-user-hash',
        outputFormat: ImageOutputFormat.png,
      ),
    )) {
      if (event is ImageEditCompletedEvent) {
        // Decode base64 before treating a result as image bytes.
        final imageBytes = base64Decode(event.b64Json);
        if (imageBytes.isEmpty ||
            event.safetyIdentifier != 'synthetic-user-hash') {
          throw StateError('The completed result was incomplete.');
        }
        completed = true;
      }
    }
    if (!completed || requests != 2) {
      throw StateError('The offline edit flow did not finish.');
    }
    stdout.writeln('Offline image markup: two mock edits; no API charges.');
  } finally {
    client.close();
    transport.close();
  }
}
