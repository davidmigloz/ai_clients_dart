// ignore_for_file: avoid_dynamic_calls

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('InteractionContent Sealed Class', () {
    group('TextContent', () {
      test('creates from text', () {
        const content = TextContent(text: 'Hello world');
        expect(content.text, 'Hello world');
        expect(content.type, 'text');
      });

      test('serializes to JSON', () {
        const content = TextContent(text: 'Hello world');
        final json = content.toJson();
        expect(json['type'], 'text');
        expect(json['text'], 'Hello world');
      });

      test('deserializes from JSON', () {
        final json = {'type': 'text', 'text': 'Hello world'};
        final content = InteractionContent.fromJson(json);
        expect(content, isA<TextContent>());
        expect((content as TextContent).text, 'Hello world');
      });

      test('deserializes partial content (content.start event)', () {
        final json = {'type': 'text'};
        final content = InteractionContent.fromJson(json);
        expect(content, isA<TextContent>());
        expect((content as TextContent).text, '');
      });

      test('roundtrip serialization', () {
        const original = TextContent(text: 'Test message');
        final json = original.toJson();
        final restored = InteractionContent.fromJson(json);
        expect(restored, isA<TextContent>());
        expect((restored as TextContent).text, original.text);
      });

      test('with url_citation annotation', () {
        final json = {
          'type': 'text',
          'text': 'Check this link',
          'annotations': [
            {
              'type': 'url_citation',
              'url': 'https://example.com',
              'title': 'Example',
              'start_index': 0,
              'end_index': 15,
            },
          ],
        };

        final content = InteractionContent.fromJson(json);
        expect(content, isA<TextContent>());
        final textContent = content as TextContent;
        expect(textContent.annotations, isNotNull);
        expect(textContent.annotations!.length, 1);
        expect(textContent.annotations![0], isA<UrlCitation>());
        final citation = textContent.annotations![0] as UrlCitation;
        expect(citation.url, 'https://example.com');
        expect(citation.title, 'Example');
        expect(citation.startIndex, 0);
        expect(citation.endIndex, 15);
      });

      test('with file_citation annotation', () {
        final json = {
          'type': 'text',
          'text': 'From the document',
          'annotations': [
            {
              'type': 'file_citation',
              'file_name': 'doc.pdf',
              'document_uri': 'gs://bucket/doc.pdf',
              'source': 'file-123',
              'start_index': 0,
              'end_index': 17,
            },
          ],
        };

        final content = InteractionContent.fromJson(json);
        final textContent = content as TextContent;
        expect(textContent.annotations![0], isA<FileCitation>());
        final citation = textContent.annotations![0] as FileCitation;
        expect(citation.fileName, 'doc.pdf');
        expect(citation.documentUri, 'gs://bucket/doc.pdf');
        expect(citation.source, 'file-123');
      });

      test('with place_citation annotation', () {
        final json = {
          'type': 'text',
          'text': 'A great restaurant',
          'annotations': [
            {
              'type': 'place_citation',
              'name': 'Pizza Place',
              'place_id': 'ChIJ123',
              'url': 'https://maps.google.com/place/123',
              'start_index': 0,
              'end_index': 18,
              'review_snippets': [
                {
                  'review_id': 'rev-1',
                  'title': 'Great food',
                  'url': 'https://maps.google.com/review/1',
                },
              ],
            },
          ],
        };

        final content = InteractionContent.fromJson(json);
        final textContent = content as TextContent;
        expect(textContent.annotations![0], isA<PlaceCitation>());
        final citation = textContent.annotations![0] as PlaceCitation;
        expect(citation.name, 'Pizza Place');
        expect(citation.placeId, 'ChIJ123');
        expect(citation.reviewSnippets, hasLength(1));
        expect(citation.reviewSnippets![0].reviewId, 'rev-1');
      });

      test('annotation roundtrip serialization', () {
        const original = TextContent(
          text: 'Test',
          annotations: [
            UrlCitation(
              url: 'https://example.com',
              title: 'Example',
              startIndex: 0,
              endIndex: 4,
            ),
          ],
        );
        final json = original.toJson();
        final restored = InteractionContent.fromJson(json) as TextContent;
        expect(restored.annotations, hasLength(1));
        expect(restored.annotations![0], isA<UrlCitation>());
        final citation = restored.annotations![0] as UrlCitation;
        expect(citation.url, 'https://example.com');
      });
    });

    group('ImageContent', () {
      test('creates with base64 data', () {
        const content = ImageContent(data: 'base64data', mimeType: 'image/png');
        expect(content.data, 'base64data');
        expect(content.type, 'image');
      });

      test('serializes to JSON', () {
        const content = ImageContent(data: 'imgdata', mimeType: 'image/jpeg');
        final json = content.toJson();
        expect(json['type'], 'image');
        expect(json['data'], 'imgdata');
        expect(json['mime_type'], 'image/jpeg');
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'image',
          'data': 'base64imagedata',
          'mime_type': 'image/png',
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<ImageContent>());
        expect((content as ImageContent).data, 'base64imagedata');
      });

      test('creates with uri', () {
        const content = ImageContent(uri: 'gs://bucket/image.png');
        expect(content.uri, 'gs://bucket/image.png');
      });

      test('roundtrip MediaResolution enum', () {
        const content = ImageContent(
          data: 'img',
          resolution: InteractionMediaResolution.ultraHigh,
        );
        final json = content.toJson();
        expect(json['resolution'], 'ultra_high');

        final restored = InteractionContent.fromJson(json) as ImageContent;
        expect(restored.resolution, InteractionMediaResolution.ultraHigh);
      });

      test('all MediaResolution values roundtrip', () {
        for (final value in InteractionMediaResolution.values) {
          final content = ImageContent(data: 'x', resolution: value);
          final restored =
              InteractionContent.fromJson(content.toJson()) as ImageContent;
          expect(restored.resolution, value);
        }
      });
    });

    group('AudioContent', () {
      test('creates with audio data', () {
        const content = AudioContent(data: 'audiodata');
        expect(content.data, 'audiodata');
        expect(content.type, 'audio');
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'audio',
          'data': 'base64audio',
          'mime_type': 'audio/mp3',
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<AudioContent>());
        expect((content as AudioContent).data, 'base64audio');
        expect(content.mimeType, 'audio/mp3');
      });
    });

    group('DocumentContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'document',
          'document': {'uri': 'gs://bucket/doc.pdf'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<DocumentContent>());
      });
    });

    group('VideoContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'video',
          'video': {'uri': 'gs://bucket/video.mp4'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<VideoContent>());
      });

      test('roundtrip MediaResolution enum', () {
        const content = VideoContent(
          data: 'vid',
          resolution: InteractionMediaResolution.high,
        );
        final json = content.toJson();
        expect(json['resolution'], 'high');

        final restored = InteractionContent.fromJson(json) as VideoContent;
        expect(restored.resolution, InteractionMediaResolution.high);
      });
    });

    group('ThoughtContent', () {
      test('creates with signature', () {
        const content = ThoughtContent(signature: 'sig123');
        expect(content.signature, 'sig123');
        expect(content.type, 'thought');
      });

      test('serializes to JSON', () {
        const content = ThoughtContent(signature: 'sig456');
        final json = content.toJson();
        expect(json['type'], 'thought');
        expect(json['signature'], 'sig456');
      });

      test('deserializes from JSON', () {
        final json = {'type': 'thought', 'signature': 'sig789'};
        final content = InteractionContent.fromJson(json);
        expect(content, isA<ThoughtContent>());
        expect((content as ThoughtContent).signature, 'sig789');
      });

      test('deserializes from JSON with summary', () {
        final json = {
          'type': 'thought',
          'signature': 'sig789',
          'summary': [
            {'type': 'text', 'text': 'Reasoning step 1'},
            {'type': 'text', 'text': 'Reasoning step 2'},
          ],
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<ThoughtContent>());
        final thought = content as ThoughtContent;
        expect(thought.signature, 'sig789');
        expect(thought.summary, isNotNull);
        expect(thought.summary!.length, 2);
        expect(thought.summary![0], isA<TextContent>());
        expect((thought.summary![0] as TextContent).text, 'Reasoning step 1');
        expect((thought.summary![1] as TextContent).text, 'Reasoning step 2');
      });

      test('handles null summary', () {
        final json = {'type': 'thought', 'signature': 'sig'};
        final content = InteractionContent.fromJson(json);
        expect((content as ThoughtContent).summary, isNull);
      });

      test('round-trip serialization preserves typed summary', () {
        const original = ThoughtContent(
          signature: 'sig-test',
          summary: [
            TextContent(text: 'Step 1'),
            TextContent(text: 'Step 2'),
          ],
        );
        final json = original.toJson();
        final restored = InteractionContent.fromJson(json);
        expect(restored, isA<ThoughtContent>());
        final thought = restored as ThoughtContent;
        expect(thought.summary, hasLength(2));
        expect(thought.summary![0], isA<TextContent>());
        expect((thought.summary![0] as TextContent).text, 'Step 1');
      });
    });

    group('FunctionCallContent', () {
      test('creates with function call', () {
        const content = FunctionCallContent(
          id: 'call-123',
          name: 'get_weather',
          arguments: {'city': 'SF'},
        );
        expect(content.name, 'get_weather');
        expect(content.id, 'call-123');
        expect(content.type, 'function_call');
      });

      test('serializes to JSON', () {
        const content = FunctionCallContent(
          id: 'call-456',
          name: 'search',
          arguments: {'query': 'test'},
        );
        final json = content.toJson();
        expect(json['type'], 'function_call');
        expect(json['id'], 'call-456');
        expect(json['name'], 'search');
        expect(json['arguments'], {'query': 'test'});
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'function_call',
          'id': 'call-789',
          'name': 'search',
          'arguments': {'query': 'test'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<FunctionCallContent>());
        final fc = content as FunctionCallContent;
        expect(fc.id, 'call-789');
        expect(fc.name, 'search');
        expect(fc.arguments, {'query': 'test'});
      });
    });

    group('FunctionResultContent', () {
      test('creates with function result', () {
        const content = FunctionResultContent(
          callId: 'call-123',
          result: ToolResultObject({'temp': 72}),
        );
        expect(content.result, isA<ToolResultObject>());
        expect((content.result as ToolResultObject).value, {'temp': 72});
        expect(content.callId, 'call-123');
        expect(content.type, 'function_result');
      });

      test('serializes to JSON', () {
        const content = FunctionResultContent(
          callId: 'call-456',
          result: ToolResultObject({'results': <String>[]}),
          name: 'search',
        );
        final json = content.toJson();
        expect(json['type'], 'function_result');
        expect(json['call_id'], 'call-456');
        expect(json['name'], 'search');
      });

      test('deserializes from JSON', () {
        final json = {
          'type': 'function_result',
          'call_id': 'call-123',
          'result': {'data': 'test'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<FunctionResultContent>());
        expect((content as FunctionResultContent).callId, 'call-123');
      });
    });

    group('CodeExecutionCallContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'code_execution_call',
          'code_execution_call': {
            'language': 'python',
            'code': 'print("hello")',
          },
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<CodeExecutionCallContent>());
      });
    });

    group('CodeExecutionResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'code_execution_result',
          'call_id': 'call_123',
          'result': 'hello',
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<CodeExecutionResultContent>());
        final result = content as CodeExecutionResultContent;
        expect(result.callId, 'call_123');
        expect(result.result, 'hello');
      });
    });

    group('UrlContextCallContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'url_context_call',
          'url_context_call': {'url': 'https://example.com'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<UrlContextCallContent>());
      });
    });

    group('UrlContextResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'url_context_result',
          'call_id': 'call_123',
          'result': <dynamic>[],
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<UrlContextResultContent>());
        expect((content as UrlContextResultContent).callId, 'call_123');
      });
    });

    group('GoogleSearchCallContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'google_search_call',
          'google_search_call': {'query': 'weather today'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<GoogleSearchCallContent>());
      });
    });

    group('GoogleSearchResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'google_search_result',
          'call_id': 'call_123',
          'result': <dynamic>[],
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<GoogleSearchResultContent>());
        expect((content as GoogleSearchResultContent).callId, 'call_123');
      });
    });

    group('McpServerToolCallContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'mcp_server_tool_call',
          'id': 'call-123',
          'name': 'fetch_data',
          'server_name': 'my-server',
          'arguments': {'url': 'https://example.com'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<McpServerToolCallContent>());
        final mcp = content as McpServerToolCallContent;
        expect(mcp.id, 'call-123');
        expect(mcp.name, 'fetch_data');
        expect(mcp.serverName, 'my-server');
      });
    });

    group('McpServerToolResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'mcp_server_tool_result',
          'mcp_server_tool_result': {'result': 'data'},
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<McpServerToolResultContent>());
      });
    });

    group('FileSearchCallContent', () {
      test('deserializes from JSON', () {
        final json = {'type': 'file_search_call', 'id': 'call_123'};
        final content = InteractionContent.fromJson(json);
        expect(content, isA<FileSearchCallContent>());
        expect((content as FileSearchCallContent).id, 'call_123');
      });
    });

    group('FileSearchResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'file_search_result',
          'call_id': 'call_123',
          'result': [<String, dynamic>{}],
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<FileSearchResultContent>());
        expect((content as FileSearchResultContent).callId, 'call_123');
      });

      test('roundtrip customMetadata on FileSearchResult', () {
        final json = {
          'type': 'file_search_result',
          'call_id': 'call_456',
          'result': [
            {
              'custom_metadata': [
                {'key': 'author', 'value': 'Alice'},
                {'key': 'date', 'value': '2025-01-01'},
              ],
            },
            <String, dynamic>{},
          ],
          'signature': 'sig789',
        };
        final content =
            InteractionContent.fromJson(json) as FileSearchResultContent;
        expect(content.callId, 'call_456');
        expect(content.result, hasLength(2));
        expect(content.result[0].customMetadata, hasLength(2));
        expect(content.result[0].customMetadata![0]['key'], 'author');
        expect(content.result[0].customMetadata![1]['value'], '2025-01-01');
        expect(content.result[1].customMetadata, isNull);

        // Roundtrip
        final restored =
            InteractionContent.fromJson(content.toJson())
                as FileSearchResultContent;
        expect(restored.result[0].customMetadata, hasLength(2));
        expect(restored.result[0].customMetadata![0]['key'], 'author');
        expect(restored.result[1].customMetadata, isNull);
      });
    });

    group('GoogleMapsCallContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'google_maps_call',
          'id': 'call-maps-1',
          'arguments': {
            'queries': ['pizza near me'],
          },
          'signature': 'sig123',
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<GoogleMapsCallContent>());
        final maps = content as GoogleMapsCallContent;
        expect(maps.id, 'call-maps-1');
        expect(maps.queries, ['pizza near me']);
        expect(maps.signature, 'sig123');
      });

      test('roundtrip serialization', () {
        const original = GoogleMapsCallContent(
          id: 'mc-1',
          queries: ['restaurants'],
          signature: 'sig',
        );
        final json = original.toJson();
        final restored =
            InteractionContent.fromJson(json) as GoogleMapsCallContent;
        expect(restored.id, original.id);
        expect(restored.queries, original.queries);
        expect(restored.signature, original.signature);
      });
    });

    group('GoogleMapsResultContent', () {
      test('deserializes from JSON', () {
        final json = {
          'type': 'google_maps_result',
          'call_id': 'call-maps-1',
          'result': [
            {
              'places': [
                {
                  'name': 'Pizza Place',
                  'place_id': 'ChIJ123',
                  'url': 'https://maps.google.com',
                  'review_snippets': [
                    {
                      'review_id': 'rev-1',
                      'title': 'Great',
                      'url': 'https://maps.google.com/review/1',
                    },
                  ],
                },
              ],
              'widget_context_token': 'token123',
            },
          ],
          'signature': 'sig456',
        };
        final content = InteractionContent.fromJson(json);
        expect(content, isA<GoogleMapsResultContent>());
        final maps = content as GoogleMapsResultContent;
        expect(maps.callId, 'call-maps-1');
        expect(maps.signature, 'sig456');
        expect(maps.result, hasLength(1));
        expect(maps.result[0].places, hasLength(1));
        expect(maps.result[0].places![0].name, 'Pizza Place');
        expect(maps.result[0].places![0].placeId, 'ChIJ123');
        expect(maps.result[0].places![0].reviewSnippets, hasLength(1));
        expect(maps.result[0].widgetContextToken, 'token123');
      });

      test('roundtrip serialization', () {
        const original = GoogleMapsResultContent(
          callId: 'mc-1',
          result: [
            GoogleMapsResult(
              places: [Places(name: 'Test Place', placeId: 'p1')],
            ),
          ],
          signature: 'sig',
        );
        final json = original.toJson();
        final restored =
            InteractionContent.fromJson(json) as GoogleMapsResultContent;
        expect(restored.callId, original.callId);
        expect(restored.result[0].places![0].name, 'Test Place');
      });
    });

    group('Exhaustive Matching', () {
      test('throws ArgumentError for unknown type', () {
        final json = {'type': 'unknown_type'};
        expect(
          () => InteractionContent.fromJson(json),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('all 20 content variants can be deserialized', () {
        final variants = <Map<String, dynamic>>[
          {'type': 'text', 'text': 'test'},
          {'type': 'image', 'data': 'data'},
          {'type': 'audio', 'data': 'data'},
          {'type': 'document', 'document': <String, dynamic>{}},
          {'type': 'video', 'video': <String, dynamic>{}},
          {'type': 'thought', 'signature': 'sig'},
          {
            'type': 'function_call',
            'id': 'id',
            'name': 'fn',
            'arguments': <String, dynamic>{},
          },
          {
            'type': 'function_result',
            'call_id': 'id',
            'result': <String, dynamic>{},
          },
          {
            'type': 'code_execution_call',
            'code_execution_call': <String, dynamic>{},
          },
          {
            'type': 'code_execution_result',
            'call_id': 'id',
            'result': 'output',
          },
          {'type': 'url_context_call', 'url_context_call': <String, dynamic>{}},
          {
            'type': 'url_context_result',
            'call_id': 'id',
            'result': <dynamic>[],
          },
          {
            'type': 'google_search_call',
            'google_search_call': <String, dynamic>{},
          },
          {
            'type': 'google_search_result',
            'call_id': 'id',
            'result': <dynamic>[],
          },
          {'type': 'google_maps_call', 'id': 'id'},
          {'type': 'google_maps_result', 'call_id': 'id'},
          {
            'type': 'mcp_server_tool_call',
            'id': 'id',
            'name': 'tool',
            'server_name': 'server',
            'arguments': <String, dynamic>{},
          },
          {
            'type': 'mcp_server_tool_result',
            'mcp_server_tool_result': <String, dynamic>{},
          },
          {'type': 'file_search_call', 'id': 'call_123'},
          {'type': 'file_search_result', 'call_id': 'call_123'},
        ];

        for (final json in variants) {
          expect(
            () => InteractionContent.fromJson(json),
            returnsNormally,
            reason: 'Failed for type: ${json['type']}',
          );
        }
      });

      test('all 20 content variants handle partial JSON (content.start)', () {
        // content.start events send only {"type": "..."} without data fields
        final types = [
          'text',
          'image',
          'audio',
          'document',
          'video',
          'thought',
          'function_call',
          'function_result',
          'code_execution_call',
          'code_execution_result',
          'url_context_call',
          'url_context_result',
          'google_search_call',
          'google_search_result',
          'google_maps_call',
          'google_maps_result',
          'mcp_server_tool_call',
          'mcp_server_tool_result',
          'file_search_call',
          'file_search_result',
        ];

        for (final type in types) {
          expect(
            () => InteractionContent.fromJson({'type': type}),
            returnsNormally,
            reason: 'Partial JSON failed for type: $type',
          );
        }
      });
    });
  });
}
