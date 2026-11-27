import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _image = ImageUrlContentPart.withDetail(
  'https://example.com/chart.png',
  detail: 'high',
);
const _conversations = [
  [UserMessage(content: MessageContent.text('One'))],
  [UserMessage(content: MessageContent.text('Two'))],
];
const _messagesJson = [
  [
    {'role': 'user', 'content': 'One'},
  ],
  [
    {'role': 'user', 'content': 'Two'},
  ],
];

http.Response _jsonResponse(Map<String, Object?> response) => http.Response(
  jsonEncode(response),
  200,
  headers: {'content-type': 'application/json'},
);

MistralClient _client(
  String path,
  Map<String, Object?> response, {
  Map<String, Object?>? requestBody,
}) {
  final client = MistralClient.withApiKey(
    'mock-key',
    httpClient: MockClient((request) async {
      expect(request.url.path, path);
      if (requestBody != null) {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), requestBody);
      } else {
        expect(request.method, 'GET');
      }
      return _jsonResponse(response);
    }),
  );
  addTearDown(client.close);
  return client;
}

void main() {
  group('OCR', () {
    test('requests block confidence and decodes it on every block', () async {
      const blockTypes = [
        'text',
        'title',
        'list',
        'table',
        'image',
        'equation',
        'caption',
        'code',
        'references',
        'aside_text',
        'header',
        'footer',
        'signature',
      ];
      const model = 'mistral-ocr-4-1';
      final blocks = [
        for (final type in blockTypes)
          {
            'type': type,
            'top_left_x': 1,
            'top_left_y': 2,
            'bottom_right_x': 11,
            'bottom_right_y': 12,
            'content': type,
            if (type == 'image') 'image_id': 'img-1',
            if (type == 'table') 'table_id': 'table-1',
            'confidence_scores': {
              'average_content_confidence_score': type == 'image' ? null : 1,
              'minimum_content_confidence_score': type == 'image' ? null : 0.7,
              'block_type_confidence_score': 0.8,
            },
          },
      ];
      final client = _client(
        '/v1/ocr',
        {
          'model': model,
          'pages': [
            {'index': 0, 'markdown': 'Example', 'blocks': blocks},
          ],
          'usage_info': {'pages_processed': 1},
        },
        requestBody: {
          'model': model,
          'document': {
            'type': 'document_url',
            'document_url': 'data:application/pdf;base64,JVBERg==',
          },
          'include_blocks': true,
          'confidence_scores_granularity': 'block',
          'pages': '0,2-4',
        },
      );
      final response = await client.ocr.process(
        request: const OcrRequest(
          model: model,
          document: OcrDocument.base64(
            data: 'JVBERg==',
            mimeType: 'application/pdf',
          ),
          includeBlocks: true,
          confidenceScoresGranularity: OcrConfidenceScoresGranularity.block,
          pages: OcrPages.string('0,2-4'),
        ),
      );
      final decoded = response.pages.single.blocks!;
      expect(decoded.map((block) => block.type), blockTypes);
      for (final block in decoded) {
        final scores = block.confidenceScores!;
        expect(scores.blockTypeConfidenceScore, 0.8, reason: block.type);
        expect(
          scores.averageContentConfidenceScore,
          block.type == 'image' ? isNull : 1.0,
          reason: block.type,
        );
        expect(
          scores.minimumContentConfidenceScore,
          block.type == 'image' ? isNull : 0.7,
          reason: block.type,
        );
        expect(OcrBlock.fromJson(block.toJson()), block, reason: block.type);
      }
      final first = decoded.first as OcrTextBlock;
      expect(
        first.confidenceScores!
            .copyWith(blockTypeConfidenceScore: 1)
            .blockTypeConfidenceScore,
        1.0,
      );
      expect(first.copyWith(confidenceScores: null).confidenceScores, isNull);
    });

    for (final granularity in [
      OcrConfidenceScoresGranularity.page,
      OcrConfidenceScoresGranularity.word,
    ]) {
      test('uses page lists and decodes ${granularity.value} scores', () async {
        final word = granularity == OcrConfidenceScoresGranularity.word;
        final client = _client(
          '/v1/ocr',
          {
            'model': 'mistral-ocr-4-1',
            'pages': [
              {
                'index': 1,
                'markdown': 'Hello',
                'confidence_scores': {
                  'average_page_confidence_score': 0.9,
                  'minimum_page_confidence_score': 0.8,
                  if (word)
                    'word_confidence_scores': [
                      {'text': 'Hello', 'confidence': 0.9, 'start_index': 0},
                    ],
                },
              },
            ],
          },
          requestBody: {
            'model': 'mistral-ocr-latest',
            'document': {'type': 'file', 'file_id': 'ocr-file'},
            'pages': [1, 3],
            'confidence_scores_granularity': granularity.value,
          },
        );
        final response = await client.ocr.process(
          request: OcrRequest(
            document: const OcrDocument.file('ocr-file'),
            pages: const OcrPages.list([1, 3]),
            confidenceScoresGranularity: granularity,
          ),
        );
        final scores = response.pages.single.confidenceScores!;
        expect(scores.averagePageConfidenceScore, 0.9);
        expect(scores.minimumPageConfidenceScore, 0.8);
        expect(scores.wordConfidenceScores?.single.text, word ? 'Hello' : null);
      });
    }

    test('serializes named documents and image detail', () {
      const named = OcrDocument.namedUrl(
        'https://example.com/doc.pdf',
        documentName: 'report.pdf',
      );
      const image = OcrDocument.image(_image);
      expect(named.toJson(), {
        'type': 'document_url',
        'document_url': 'https://example.com/doc.pdf',
        'document_name': 'report.pdf',
      });
      expect(image.toJson(), {
        'type': 'image_url',
        'image_url': {'url': 'https://example.com/chart.png', 'detail': 'high'},
      });
      expect(OcrDocument.fromJson(named.toJson()), named);
      expect(OcrDocument.fromJson(image.toJson()), image);
      expect(
        OcrDocument.fromJson(const {
          'type': 'base64',
          'data': 'JVBERg==',
          'mime_type': 'application/pdf',
        }).toJson(),
        {
          'type': 'document_url',
          'document_url': 'data:application/pdf;base64,JVBERg==',
        },
      );
    });
  });

  test('embeddings support mixed media and preserve encoded vectors', () async {
    const model = 'multimodal-embedding-model';
    const request = EmbeddingRequest(
      model: model,
      input: EmbedInput.batch([
        EmbedInputString('Text'),
        EmbedInputImage(_image),
        EmbedInputAudio(AudioContentPart(inputAudio: 'AQID')),
      ]),
      encodingFormat: 'base64',
      outputDtype: EmbeddingDtype.int8,
    );
    final client = _client(
      '/v1/embeddings',
      {
        'id': 'emb-1',
        'object': 'list',
        'model': model,
        'data': [
          {'object': 'embedding', 'index': 0, 'embedding': 'AQID'},
          {'object': 'embedding', 'index': 1, 'embedding': 'BAUG'},
          {'object': 'embedding', 'index': 2, 'embedding': 'BwgJ'},
        ],
      },
      requestBody: {
        'model': model,
        'input': [
          'Text',
          {
            'type': 'image_url',
            'image_url': {
              'url': 'https://example.com/chart.png',
              'detail': 'high',
            },
          },
          {'type': 'input_audio', 'input_audio': 'AQID'},
        ],
        'encoding_format': 'base64',
        'output_dtype': 'int8',
      },
    );
    final response = await client.embeddings.create(request: request);
    expect(response.data.first.embeddingBase64, 'AQID');
    expect(response.data.first.embedding, isEmpty);
    expect(response.data.first.toJson()['embedding'], 'AQID');
    expect(EmbeddingRequest.fromJson(request.toJson()), request);
    final vector = EmbeddingData.fromJson(const {
      'index': 1,
      'embedding': [1, 2.5],
    });
    expect(vector.embedding, [1.0, 2.5]);
    expect(vector.embeddingBase64, isNull);
    expect(
      EmbedInput.fromJson(const ['a', 'b']),
      const EmbedInput.list(['a', 'b']),
    );
  });

  group('moderation', () {
    const result = {
      'id': 'mod-1',
      'model': 'mistral-moderation-2603',
      'results': [
        {
          'categories': {'dangerous_and_criminal_content': true},
          'category_scores': {
            'dangerous_and_criminal_content': 0.95,
            'selfharm': 0,
          },
        },
      ],
      'usage': {
        'prompt_tokens': 3,
        'completion_tokens': 0,
        'total_tokens': 3,
        'request_count': 1,
      },
    };
    test('sends custom queries and retains arbitrary categories', () async {
      final client = _client(
        '/v1/moderations',
        result,
        requestBody: {
          'model': 'mistral-moderation-2603',
          'input': 'Review this text',
          'metadata': {
            'trace': {'id': 'a'},
          },
          'queries': {'pii': 'Does the text contain personal information?'},
        },
      );
      final request = ModerationRequest.text(
        input: 'Review this text',
        metadata: const {
          'trace': {'id': 'a'},
        },
        queries: const {'pii': 'Does the text contain personal information?'},
      );
      final response = await client.moderations.create(request: request);
      expect(response.results.single.flagged, isTrue);
      expect(response.results.single.categoryScores.scores, {
        'dangerous_and_criminal_content': 0.95,
        'selfharm': 0.0,
      });
      expect(response.usage?.requestCount, 1);
      expect(ModerationRequest.fromJson(request.toJson()), request);
      expect(() => request.copyWith(queries: {}).toJson(), throwsArgumentError);
    });

    test('sends batches as nested message arrays', () async {
      final client = _client(
        '/v1/chat/moderations',
        result,
        requestBody: {
          'model': 'mistral-moderation-2603',
          'input': _messagesJson,
        },
      );
      const request = ChatModerationRequest.batch(
        conversations: _conversations,
      );
      await client.moderations.createChat(request: request);
      expect(ChatModerationRequest.fromJson(request.toJson()), request);
      expect(request.copyWith(conversations: []).conversations, isEmpty);
      expect(request.copyWith(conversations: null).conversations, isNull);
    });
  });

  group('classification', () {
    const model = 'ft:existing-classifier';
    const targets = {
      'topic': {
        'scores': {'billing': 0.9, 'support': 0.1},
      },
      'categories': {
        'scores': {'custom': 1},
      },
    };
    const result = {
      'id': 'clf-1',
      'model': model,
      'results': [targets],
    };
    test('passes text metadata and decodes model-defined targets', () async {
      final client = _client(
        '/v1/classifications',
        result,
        requestBody: {
          'model': model,
          'input': 'Invoice',
          'metadata': {'trace': 'a'},
        },
      );
      final request = ClassificationRequest.text(
        model: model,
        input: 'Invoice',
        metadata: const {'trace': 'a'},
      );
      final response = await client.classifications.create(request: request);
      expect(response.results.single.targets['topic']?.scores['billing'], 0.9);
      expect(
        response.results.single.targets['categories']?.scores['custom'],
        1.0,
      );
      expect(response.results.single.toJson(), targets);
      expect(ClassificationRequest.fromJson(request.toJson()), request);
    });

    test('sends each chat as a messages envelope', () async {
      final batchClient = _client(
        '/v1/chat/classifications',
        result,
        requestBody: {
          'model': model,
          'input': [
            {'messages': _messagesJson[0]},
            {'messages': _messagesJson[1]},
          ],
        },
      );
      const batch = ChatClassificationRequest.batch(
        model: model,
        conversations: _conversations,
      );
      await batchClient.classifications.createChat(request: batch);
      expect(ChatClassificationRequest.fromJson(batch.toJson()), batch);
      expect(batch.copyWith(conversations: []).conversations, isEmpty);

      final singleClient = _client(
        '/v1/chat/classifications',
        result,
        requestBody: {
          'model': model,
          'input': {'messages': _messagesJson.first},
        },
      );
      final single = ChatClassificationRequest(
        model: model,
        input: _conversations.first,
      );
      await singleClient.classifications.createChat(request: single);
      expect(ChatClassificationRequest.fromJson(single.toJson()), single);
      expect(
        ChatClassificationRequest.fromJson({
          'model': model,
          'input': _messagesJson.first,
        }),
        single,
      );
    });
  });

  test(
    'model listing and retrieval preserve base and fine-tuned fields',
    () async {
      const base = {
        'id': 'voxtral',
        'type': 'base',
        'capabilities': {'audio_transcription': true, 'audio_speech': true},
        'billing_model_name': 'voxtral-billing',
        'deprecation': '2027-03-01T00:00:00Z',
        'deprecation_replacement_model': 'voxtral-next',
        'audio_transcription_capabilities': {
          'modes': ['offline', 'realtime'],
          'diarization': true,
          'context_bias': true,
          'turn_detection': false,
          'timestamp_granularities': ['segment'],
          'languages': ['en'],
          'streaming_delays_ms': [
            {'min': 100, 'max': 800},
          ],
        },
        'audio_speech_capabilities': {
          'modes': ['offline'],
          'instruction': true,
          'response_formats': ['mp3'],
        },
      };
      const fineTuned = {
        'id': 'ft:model',
        'type': 'fine-tuned',
        'capabilities': {'completion_chat': true},
        'job': 'ft-job',
        'root': 'base-model',
        'archived': true,
        'billing_model_name': 'base-model',
      };
      final listing = _client('/v1/models', {
        'object': 'list',
        'data': [base, fineTuned],
      });
      final retrieval = _client('/v1/models/ft:model', fineTuned);
      final cards = (await listing.models.list()).data;
      expect(cards.first.billingModelName, 'voxtral-billing');
      expect(cards.first.deprecation, '2027-03-01T00:00:00Z');
      expect(cards.first.deprecationReplacementModel, 'voxtral-next');
      final transcription = cards.first.audioTranscriptionCapabilities!;
      expect(transcription.streamingDelaysMs!.single.max, 800);
      expect(transcription.timestampGranularities, ['segment']);
      expect(transcription.copyWith(modes: []).modes, isEmpty);
      expect(cards.first.audioSpeechCapabilities?.responseFormats, ['mp3']);
      final ft = await retrieval.models.get('ft:model');
      expect(ft, cards.last);
      expect(ft.billingModelName, 'base-model');
      expect(ft.archived, isTrue);
      expect(ft.job, 'ft-job');
      expect(ft.root, 'base-model');
      expect(Model.fromJson(cards.first.toJson()), cards.first);
    },
  );
}
