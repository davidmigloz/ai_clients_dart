import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _png =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a2k0AAAAASUVORK5CYII=';
const Map<String, Object> _imageFile = {
  'type': 'image',
  'source': {'type': 'file', 'file_id': 'file_fixture'},
};
const Map<String, Object> _contentSource = {
  'type': 'content',
  'content': [
    {'type': 'text', 'text': 'The first chunk'},
    {
      'type': 'image',
      'source': {'type': 'url', 'url': 'https://example.invalid/figure.png'},
      'transformations': {'oversized_image': 'error'},
    },
    {
      'type': 'image',
      'source': {'type': 'base64', 'media_type': 'image/png', 'data': _png},
    },
    _imageFile,
    {
      'type': 'text',
      'text': 'The last chunk',
      'cache_control': {'type': 'ephemeral'},
    },
  ],
};
const _citation = ContentBlockLocationInputCitation(
  citedText: 'chunk',
  documentIndex: 0,
  documentTitle: 'Fixture',
  startBlockIndex: 0,
  endBlockIndex: 1,
);

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test(
    'serializes custom string and mixed documents and uploaded images on all request paths',
    () async {
      final blocks = <InputContentBlock>[
        const TextInputBlock('The first chunk'),
        const ImageInputBlock(
          UrlImageSource('https://example.invalid/figure.png'),
          transformations: ImageTransformations(
            oversizedImage: OversizedImageBehavior.error,
          ),
        ),
        const ImageInputBlock(
          Base64ImageSource(data: _png, mediaType: ImageMediaType.png),
        ),
        InputContentBlock.image(ImageSource.file('file_fixture')),
        const TextInputBlock(
          'The last chunk',
          cacheControl: CacheControlEphemeral(),
        ),
      ];
      final mixed =
          DocumentSource.contentBlocks(blocks) as ContentBlockDocumentSource;
      blocks.clear();
      expect(mixed.blocks, hasLength(5));
      expect(mixed, DocumentSource.fromJson(_contentSource));
      expect(mixed.hashCode, DocumentSource.fromJson(_contentSource).hashCode);
      expect(mixed.toJson(), _contentSource);
      expect(mixed.copyWith(text: 'one chunk').toJson(), {
        'type': 'content',
        'content': 'one chunk',
      });
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 64,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.document(
              mixed,
              title: 'Chunks',
              citations: const RequestCitationsConfig(enabled: true),
            ),
            InputContentBlock.document(
              DocumentSource.content('Single chunk'),
              citations: const RequestCitationsConfig(enabled: true),
            ),
            InputContentBlock.image(ImageSource.file('file_fixture')),
            InputContentBlock.text('Compare the documents'),
          ]),
        ],
      );
      final provider = MockResponses.message()
        ..['content'] = [
          {
            'type': 'text',
            'text': 'Cited answer',
            'citations': [_citation.toJson()],
          },
        ];
      transport
        ..queueJsonResponse(provider)
        ..queueJsonResponse({'input_tokens': 4})
        ..queueJsonResponse(MockResponses.messageBatch());
      final response = await client.messages.create(request);
      final citation =
          (response.content.single as TextBlock).citations!.single
              as ContentBlockLocationCitation;
      expect(citation.endBlockIndex, 1);
      await client.messages.countTokens(
        TokenCountRequest.fromMessageCreateRequest(request),
      );
      await client.messages.batches.create(
        MessageBatchCreateRequest(
          requests: [BatchRequestItem(customId: 'doc', params: request)],
        ),
      );

      for (final sent in transport.requests) {
        final body = _body(sent);
        final params = sent.url.path.endsWith('/batches')
            ? ((body['requests'] as List<Object?>).single!
                      as Map<String, dynamic>)['params']
                  as Map<String, dynamic>
            : body;
        final content =
            ((params['messages'] as List<Object?>).single!
                    as Map<String, dynamic>)['content']
                as List<Object?>;
        expect(content[0], {
          'type': 'document',
          'source': _contentSource,
          'title': 'Chunks',
          'citations': {'enabled': true},
        });
        expect(content[1], {
          'type': 'document',
          'source': {'type': 'content', 'content': 'Single chunk'},
          'citations': {'enabled': true},
        });
        expect(content[2], _imageFile);
      }
    },
  );

  test(
    'validates nested user citations at the new API version and preserves legacy input',
    () async {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 64,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.document(
              DocumentSource.contentBlocks(const [
                TextInputBlock('chunk', citations: [_citation]),
              ]),
            ),
          ]),
        ],
      );
      await expectLater(
        client.messages.create(request),
        throwsA(isA<ValidationException>()),
      );
      expect(transport.requests, isEmpty);
      final legacy = AnthropicClient(
        config: client.config.copyWith(
          apiVersion: AnthropicConfig.legacyApiVersion,
        ),
        httpClient: transport,
      );
      addTearDown(legacy.close);
      transport.queueJsonResponse(MockResponses.message());
      await legacy.messages.create(request);
      expect(
        transport.requests.single.headers['anthropic-version'],
        '2023-06-01',
      );
      expect(
        _body(transport.requests.single)['messages'],
        request.toJson()['messages'],
      );
    },
  );

  test(
    'rejects invalid nested block tags and preserves both source representations',
    () {
      expect(
        () => DocumentSource.contentBlocks([
          InputContentBlock.document(DocumentSource.text('Invalid nesting')),
        ]),
        throwsArgumentError,
      );
      expect(
        () => DocumentSource.fromJson(const {
          'type': 'content',
          'content': [
            {'type': 'tool_use'},
          ],
        }),
        throwsFormatException,
      );
      final string =
          DocumentSource.fromJson(const {'type': 'content', 'content': 'text'})
              as ContentBlockDocumentSource;
      expect(string.text, 'text');
      expect(string.blocks, isNull);
      expect(string.copyWith(blocks: const []).toJson(), {
        'type': 'content',
        'content': <Object>[],
      });
      expect(
        const FileImageSource('file_fixture').toJson(),
        _imageFile['source'],
      );
      expect(
        const FileImageSource('file_fixture').copyWith(fileId: 'file_new'),
        const FileImageSource('file_new'),
      );
    },
  );
}
