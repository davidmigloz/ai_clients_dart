import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MessageStreamEvent', () {
    test('parses message_start event', () {
      final json = {
        'type': 'message_start',
        'message': {
          'id': 'msg_123',
          'type': 'message',
          'role': 'assistant',
          'model': 'claude-sonnet-4-20250514',
          'content': <Map<String, dynamic>>[],
          'stop_reason': null,
          'stop_sequence': null,
          'usage': {'input_tokens': 10, 'output_tokens': 0},
        },
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<MessageStartEvent>());
      final messageStart = event as MessageStartEvent;
      expect(messageStart.message.id, 'msg_123');
      expect(messageStart.message.model, 'claude-sonnet-4-20250514');
    });

    test('parses content_block_start event with text block', () {
      final json = {
        'type': 'content_block_start',
        'index': 0,
        'content_block': {'type': 'text', 'text': ''},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockStartEvent>());
      final blockStart = event as ContentBlockStartEvent;
      expect(blockStart.index, 0);
      expect(blockStart.contentBlock, isA<TextBlock>());
    });

    test('parses content_block_start event with tool_use block', () {
      final json = {
        'type': 'content_block_start',
        'index': 0,
        'content_block': {
          'type': 'tool_use',
          'id': 'tu_123',
          'name': 'get_weather',
          'input': <String, dynamic>{},
        },
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockStartEvent>());
      final blockStart = event as ContentBlockStartEvent;
      expect(blockStart.contentBlock, isA<ToolUseBlock>());
      final toolUse = blockStart.contentBlock as ToolUseBlock;
      expect(toolUse.name, 'get_weather');
    });

    test('parses content_block_delta event with text_delta', () {
      final json = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'text_delta', 'text': 'Hello, world!'},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockDeltaEvent>());
      final deltaEvent = event as ContentBlockDeltaEvent;
      expect(deltaEvent.index, 0);
      expect(deltaEvent.delta, isA<TextDelta>());
      final textDelta = deltaEvent.delta as TextDelta;
      expect(textDelta.text, 'Hello, world!');
    });

    test('parses content_block_delta event with input_json_delta', () {
      final json = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'input_json_delta', 'partial_json': '{"city":'},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockDeltaEvent>());
      final deltaEvent = event as ContentBlockDeltaEvent;
      expect(deltaEvent.delta, isA<InputJsonDelta>());
      final jsonDelta = deltaEvent.delta as InputJsonDelta;
      expect(jsonDelta.partialJson, '{"city":');
    });

    test('parses content_block_delta event with signature_delta', () {
      final json = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'signature_delta', 'signature': 'EqQBCgIYAhIM0v...'},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockDeltaEvent>());
      final deltaEvent = event as ContentBlockDeltaEvent;
      expect(deltaEvent.delta, isA<SignatureDelta>());
      final sigDelta = deltaEvent.delta as SignatureDelta;
      expect(sigDelta.signature, 'EqQBCgIYAhIM0v...');
    });

    test('parses content_block_delta event with thinking_delta', () {
      final json = {
        'type': 'content_block_delta',
        'index': 0,
        'delta': {'type': 'thinking_delta', 'thinking': 'Let me think...'},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockDeltaEvent>());
      final deltaEvent = event as ContentBlockDeltaEvent;
      expect(deltaEvent.delta, isA<ThinkingDelta>());
      final thinkingDelta = deltaEvent.delta as ThinkingDelta;
      expect(thinkingDelta.thinking, 'Let me think...');
    });

    test('parses content_block_stop event', () {
      final json = {'type': 'content_block_stop', 'index': 0};

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ContentBlockStopEvent>());
      final stopEvent = event as ContentBlockStopEvent;
      expect(stopEvent.index, 0);
    });

    test('parses message_delta event', () {
      final json = {
        'type': 'message_delta',
        'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
        'usage': {'output_tokens': 25},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<MessageDeltaEvent>());
      final deltaEvent = event as MessageDeltaEvent;
      expect(deltaEvent.delta.stopReason, StopReason.endTurn);
      expect(deltaEvent.usage.outputTokens, 25);
    });

    test('parses message_delta event with tool_use stop reason', () {
      final json = {
        'type': 'message_delta',
        'delta': {'stop_reason': 'tool_use', 'stop_sequence': null},
        'usage': {'output_tokens': 50},
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<MessageDeltaEvent>());
      final deltaEvent = event as MessageDeltaEvent;
      expect(deltaEvent.delta.stopReason, StopReason.toolUse);
    });

    test('parses message_stop event', () {
      final json = {'type': 'message_stop'};

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<MessageStopEvent>());
    });

    test('parses ping event', () {
      final json = {'type': 'ping'};

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<PingEvent>());
    });

    test('parses error event', () {
      final json = {
        'type': 'error',
        'error': {
          'type': 'invalid_request_error',
          'message': 'Invalid model specified',
        },
      };

      final event = MessageStreamEvent.fromJson(json);

      expect(event, isA<ErrorEvent>());
      final errorEvent = event as ErrorEvent;
      expect(errorEvent.errorType, 'invalid_request_error');
      expect(errorEvent.message, 'Invalid model specified');
    });
  });

  group('ContentBlockDelta', () {
    test('text_delta deserializes correctly', () {
      final json = {'type': 'text_delta', 'text': 'Hello!'};

      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<TextDelta>());
      expect((delta as TextDelta).text, 'Hello!');
    });

    test('input_json_delta deserializes correctly', () {
      final json = {
        'type': 'input_json_delta',
        'partial_json': '{"location":"Boston"}',
      };

      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<InputJsonDelta>());
      expect((delta as InputJsonDelta).partialJson, '{"location":"Boston"}');
    });

    test('signature_delta deserializes correctly', () {
      const signatureDeltaJson = '''
      {
        "type": "signature_delta",
        "signature": "EqQBCgIYAhIM0v..."
      }
      ''';

      final json = jsonDecode(signatureDeltaJson) as Map<String, dynamic>;
      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<SignatureDelta>());
      final signatureDelta = delta as SignatureDelta;
      expect(signatureDelta.signature, 'EqQBCgIYAhIM0v...');
    });

    test('thinking_delta deserializes correctly', () {
      final json = {
        'type': 'thinking_delta',
        'thinking': 'I need to analyze...',
      };

      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<ThinkingDelta>());
      expect((delta as ThinkingDelta).thinking, 'I need to analyze...');
    });
  });

  group('Citations delta', () {
    test('citations_delta with char_location deserializes correctly', () {
      const citationsDeltaJson = '''
      {
        "type": "citations_delta",
        "citation": {
          "type": "char_location",
          "cited_text": "Example cited text",
          "document_index": 0,
          "document_title": "Test Document",
          "start_char_index": 0,
          "end_char_index": 18
        }
      }
      ''';

      final json = jsonDecode(citationsDeltaJson) as Map<String, dynamic>;
      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<CitationsDelta>());
      final citationsDelta = delta as CitationsDelta;
      expect(citationsDelta.citation, isA<CharLocationCitation>());

      final charLocation = citationsDelta.citation as CharLocationCitation;
      expect(charLocation.citedText, 'Example cited text');
      expect(charLocation.documentIndex, 0);
      expect(charLocation.startCharIndex, 0);
      expect(charLocation.endCharIndex, 18);
    });

    test('citations_delta with page_location deserializes correctly', () {
      const citationsJson = '''
      {
        "type": "citations_delta",
        "citation": {
          "type": "page_location",
          "cited_text": "Page cited text",
          "document_index": 0,
          "document_title": "PDF Document",
          "start_page_number": 1,
          "end_page_number": 2
        }
      }
      ''';

      final json = jsonDecode(citationsJson) as Map<String, dynamic>;
      final delta = ContentBlockDelta.fromJson(json);

      expect(delta, isA<CitationsDelta>());
      final citationsDelta = delta as CitationsDelta;
      expect(citationsDelta.citation, isA<PageLocationCitation>());

      final pageLocation = citationsDelta.citation as PageLocationCitation;
      expect(pageLocation.citedText, 'Page cited text');
      expect(pageLocation.startPageNumber, 1);
      expect(pageLocation.endPageNumber, 2);
    });

    test('content_block_location citation deserializes correctly', () {
      const citationJson = '''
      {
        "type": "content_block_location",
        "cited_text": "Block cited text",
        "document_index": 0,
        "document_title": "Content Block Doc",
        "start_block_index": 0,
        "end_block_index": 3
      }
      ''';

      final json = jsonDecode(citationJson) as Map<String, dynamic>;
      final citation = Citation.fromJson(json);

      expect(citation, isA<ContentBlockLocationCitation>());
      final blockLocation = citation as ContentBlockLocationCitation;
      expect(blockLocation.citedText, 'Block cited text');
      expect(blockLocation.startBlockIndex, 0);
      expect(blockLocation.endBlockIndex, 3);
    });
  });

  group('Full streaming event flow', () {
    test('complete streaming message can be parsed', () {
      final events = [
        {
          'type': 'message_start',
          'message': {
            'id': 'msg_123',
            'type': 'message',
            'role': 'assistant',
            'model': 'claude-sonnet-4-20250514',
            'content': <Map<String, dynamic>>[],
            'stop_reason': null,
            'stop_sequence': null,
            'usage': {'input_tokens': 10, 'output_tokens': 0},
          },
        },
        {
          'type': 'content_block_start',
          'index': 0,
          'content_block': {'type': 'text', 'text': ''},
        },
        {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {'type': 'text_delta', 'text': 'Hello'},
        },
        {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {'type': 'text_delta', 'text': ', world!'},
        },
        {'type': 'content_block_stop', 'index': 0},
        {
          'type': 'message_delta',
          'delta': {'stop_reason': 'end_turn', 'stop_sequence': null},
          'usage': {'output_tokens': 5},
        },
        {'type': 'message_stop'},
      ];

      final parsedEvents = events.map(MessageStreamEvent.fromJson).toList();

      expect(parsedEvents, hasLength(7));
      expect(parsedEvents[0], isA<MessageStartEvent>());
      expect(parsedEvents[1], isA<ContentBlockStartEvent>());
      expect(parsedEvents[2], isA<ContentBlockDeltaEvent>());
      expect(parsedEvents[3], isA<ContentBlockDeltaEvent>());
      expect(parsedEvents[4], isA<ContentBlockStopEvent>());
      expect(parsedEvents[5], isA<MessageDeltaEvent>());
      expect(parsedEvents[6], isA<MessageStopEvent>());

      // Verify text content
      final delta1 = parsedEvents[2] as ContentBlockDeltaEvent;
      final delta2 = parsedEvents[3] as ContentBlockDeltaEvent;
      final text1 = (delta1.delta as TextDelta).text;
      final text2 = (delta2.delta as TextDelta).text;
      expect(text1 + text2, 'Hello, world!');
    });

    test('tool use streaming flow can be parsed', () {
      final events = [
        {
          'type': 'message_start',
          'message': {
            'id': 'msg_456',
            'type': 'message',
            'role': 'assistant',
            'model': 'claude-sonnet-4-20250514',
            'content': <Map<String, dynamic>>[],
            'stop_reason': null,
            'stop_sequence': null,
            'usage': {'input_tokens': 15, 'output_tokens': 0},
          },
        },
        {
          'type': 'content_block_start',
          'index': 0,
          'content_block': {
            'type': 'tool_use',
            'id': 'tu_789',
            'name': 'get_weather',
            'input': <String, dynamic>{},
          },
        },
        {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {'type': 'input_json_delta', 'partial_json': '{"city":'},
        },
        {
          'type': 'content_block_delta',
          'index': 0,
          'delta': {'type': 'input_json_delta', 'partial_json': '"Boston"}'},
        },
        {'type': 'content_block_stop', 'index': 0},
        {
          'type': 'message_delta',
          'delta': {'stop_reason': 'tool_use', 'stop_sequence': null},
          'usage': {'output_tokens': 20},
        },
        {'type': 'message_stop'},
      ];

      final parsedEvents = events.map(MessageStreamEvent.fromJson).toList();

      expect(parsedEvents, hasLength(7));

      // Verify tool use block
      final blockStart = parsedEvents[1] as ContentBlockStartEvent;
      expect(blockStart.contentBlock, isA<ToolUseBlock>());
      final toolUse = blockStart.contentBlock as ToolUseBlock;
      expect(toolUse.name, 'get_weather');

      // Verify input JSON accumulation
      final jsonDelta1 = parsedEvents[2] as ContentBlockDeltaEvent;
      final jsonDelta2 = parsedEvents[3] as ContentBlockDeltaEvent;
      final json1 = (jsonDelta1.delta as InputJsonDelta).partialJson;
      final json2 = (jsonDelta2.delta as InputJsonDelta).partialJson;
      expect(json1 + json2, '{"city":"Boston"}');

      // Verify stop reason
      final messageDelta = parsedEvents[5] as MessageDeltaEvent;
      expect(messageDelta.delta.stopReason, StopReason.toolUse);
    });
  });
}
