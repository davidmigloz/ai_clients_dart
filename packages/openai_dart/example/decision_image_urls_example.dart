// ignore_for_file: avoid_print
/// Offline Decisions request with HTTP(S) images and inline bytes.
///
/// Run: dart run example/decision_image_urls_example.dart
/// A MockClient checks one API POST; no API key or image download is required.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const httpsImage =
      'https://images.example.invalid/packet%2Ffront.png?variant=red%20blue#front';
  const httpImage = 'http://images.example.invalid/back.png?version=2';
  final inline = DecisionInputPart.imageBytes(const [
    1,
    2,
    3,
  ], mediaType: 'image/png');
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    if (request.method != 'POST' ||
        request.url.toString() != 'https://example.invalid/v1/decisions') {
      throw StateError('Only one mock Decisions POST is expected.');
    }
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final messages = body['input'] as List<dynamic>;
    final parts =
        (messages.single as Map<String, dynamic>)['content'] as List<dynamic>;
    final images = parts.skip(1).cast<Map<String, dynamic>>().toList();
    if (images.length != 3 ||
        images[0]['image_url'] != httpsImage ||
        images[1]['image_url'] != httpImage ||
        images[2]['image_url'] != 'data:image/png;base64,AQID' ||
        images[0]['detail'] != 'original' ||
        images[1].containsKey('detail') ||
        images[2].containsKey('detail')) {
      throw StateError('Image strings/order/details changed in transit.');
    }
    return http.Response(
      jsonEncode({
        'model': 'gpt-6-luna',
        'answers': [
          {'type': 'predicate', 'name': 'damaged', 'probability': 0.75},
        ],
        'usage': {
          'input_tokens': 42,
          'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
          'output_tokens': 0,
          'output_tokens_details': {'reasoning_tokens': 0},
          'total_tokens': 42,
        },
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      authProvider: ApiKeyProvider('synthetic-decisions-key'),
    ),
    httpClient: transport,
  );
  try {
    final response = await client.decisions.create(
      DecisionRequest(
        model: 'gpt-6-luna',
        input: DecisionInput.messages([
          DecisionInputMessage(
            content: DecisionContent.parts([
              const DecisionInputPart.text(
                'Compare the supplied product photos.',
              ),
              DecisionInputPart.image(
                imageUrl: httpsImage,
                detail: ImageDetail.original,
              ),
              DecisionInputPart.image(imageUrl: httpImage),
              inline,
            ]),
          ),
        ]),
        questions: const [
          DecisionQuestion.predicate(
            name: 'damaged',
            instructions: 'Does any product show visible damage?',
          ),
        ],
      ),
    );
    if (requests != 1 || response.answers.single is! PredicateDecisionAnswer) {
      throw StateError('Unexpected request count or answer variant.');
    }
    print('HTTP(S)/inline image strings preserved; one mock POST completed.');
    print(r'No image downloads or live API calls; API cost $0.');
  } finally {
    client.close();
    transport.close();
  }
}
