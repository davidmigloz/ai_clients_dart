import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const json = {
    'type': 'web_search_call',
    'id': 'ws_input',
    'status': 'searching',
    'agent': {'agent_name': 'worker'},
    'action': {
      'type': 'find_in_page',
      'url': 'https://example.com',
      'pattern': 'private',
    },
    'results': [
      {
        'type': 'image_result',
        'image_url': 'https://example.com/image',
        'source_website_url': 'https://example.com',
      },
      {
        'type': 'future_result',
        'nested': {
          'values': [1, 2],
        },
      },
    ],
  };
  group('WebSearchCallItem', () {
    test(
      'parses canonical input and resource branches with full value contracts',
      () {
        final item = Item.fromJson(json) as WebSearchCallItem;
        final returned = Item.fromResourceJson(json);
        expect(item.toJson(), json);
        expect(returned, item);
        expect(returned.hashCode, item.hashCode);
        expect(item.status, WebSearchCallStatus.searching);
        expect(item.action, isA<WebSearchActionFind>());
        expect(item.results!.first, isA<WebSearchImageResult>());
        expect(item.results!.last, isA<UnknownWebSearchResult>());
        expect(() => item.results!.clear(), throwsUnsupportedError);
        expect(item.toString(), isNot(contains('private')));
      },
    );
    test(
      'preserves all omitted optionals, const construction, and existing list ownership',
      () {
        const minimal = WebSearchCallItem(id: 'ws');
        expect(minimal.toJson(), {'type': 'web_search_call', 'id': 'ws'});
        expect(WebSearchCallItem.fromJson(minimal.toJson()), minimal);
        final callerResults = <WebSearchResult>[];
        final item = WebSearchCallItem(id: 'ws', results: callerResults);
        expect(item.results, same(callerResults));
        expect(item.copyWith().results, same(callerResults));
      },
    );
    final changes = <String, WebSearchCallItem Function(WebSearchCallItem)>{
      'id': (item) => item.copyWith(id: 'other'),
      'agent': (item) =>
          item.copyWith(agent: const AgentTag(agentName: 'other')),
      'status': (item) => item.copyWith(status: WebSearchCallStatus.failed),
      'action': (item) =>
          item.copyWith(action: const WebSearchActionOpenPage()),
      'results': (item) => item.copyWith(results: <WebSearchResult>[]),
      'clear agent': (item) => item.copyWith(agent: null),
      'clear status': (item) => item.copyWith(status: null),
      'clear action': (item) => item.copyWith(action: null),
      'clear results': (item) => item.copyWith(results: null),
    };
    for (final entry in changes.entries) {
      test('copies and compares ${entry.key}', () {
        final original = WebSearchCallItem.fromJson(json);
        final changed = entry.value(original);
        final parsed = WebSearchCallItem.fromJson(changed.toJson());
        expect(changed, isNot(original));
        expect(changed, parsed);
        expect(changed.hashCode, parsed.hashCode);
        expect(original.toJson(), json);
      });
    }
    for (final entry in <String, Object?>{
      'type': 'message',
      'id': null,
      'status': 1,
      'agent': [],
      'action': null,
      'results': null,
    }.entries) {
      test('rejects malformed ${entry.key} contextually', () {
        expect(
          () => WebSearchCallItem.fromJson({...json, entry.key: entry.value}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('WebSearchCallItem.${entry.key}'),
            ),
          ),
        );
      });
    }
  });
  group('Web search choice', () {
    for (final type in [
      'web_search',
      'web_search_preview',
      'web_search_preview_2025_03_11',
    ]) {
      test('retains $type through direct and public factories', () {
        final choice = ResponseToolChoice.webSearch(type: type);
        final parsed = ResponseToolChoice.fromJson({'type': type});
        expect(choice.toJson(), {'type': type});
        expect(parsed, choice);
        expect(parsed.hashCode, choice.hashCode);
        expect(choice.copyWith(), choice);
        expect(choice.copyWith(type: 'web_search').toJson(), {
          'type': 'web_search',
        });
        expect(choice.toString(), contains('type: $type'));
      });
    }
    test('defaults to GA', () {
      expect(
        ResponseToolChoice.webSearch(),
        const ResponseToolChoiceWebSearch(),
      );
    });
    for (final type in <Object?>[null, 1, 'other']) {
      test('rejects malformed choice $type', () {
        expect(
          () => ResponseToolChoiceWebSearch.fromJson({'type': type}),
          throwsFormatException,
        );
      });
    }
    test('invalid const choice fails before serialization', () {
      expect(
        () => const ResponseToolChoiceWebSearch(type: 'other').toJson(),
        throwsArgumentError,
      );
    });
    test('preserves allowed, function, and mode choices', () {
      for (final json in <Object>[
        'none',
        'auto',
        'required',
        {'type': 'function', 'name': 'lookup'},
        {
          'type': 'allowed_tools',
          'tools': [
            {'type': 'function', 'name': 'lookup'},
          ],
          'mode': 'required',
        },
      ]) {
        expect(ResponseToolChoice.fromJson(json).toJson(), json);
      }
    });
  });
  group('Include wire values', () {
    final values = <Include, String>{
      Include.webSearchResults: 'web_search_call.results',
      Include.webSearchActionSources: 'web_search_call.action.sources',
      Include.messageInputImageImageUrl: 'message.input_image.image_url',
      Include.computerCallOutputImageUrl:
          'computer_call_output.output.image_url',
      Include.messageInputAudioTranscript: 'message.input_audio.transcription',
      Include.computerCallOutputs: 'computer_call.outputs',
    };
    for (final entry in values.entries) {
      test('round trips ${entry.value}', () {
        expect(entry.key.toJson(), entry.value);
        expect(Include.fromJson(entry.value), entry.key);
      });
    }
    test('retains unknown fallback', () {
      expect(Include.fromJson('future.include'), Include.unknown);
    });
  });
}
