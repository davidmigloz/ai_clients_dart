import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const secret = 'private-payload-credential';
  const url = 'https://example.com/?api_key=$secret';

  Matcher contextualError(String context) => throwsA(
    isA<FormatException>().having(
      (error) => error.message,
      'message',
      contains(context),
    ),
  );

  Map<String, dynamic> searchJson() => {
    'type': 'search',
    'queries': [secret, 'second'],
    'query': secret,
    'sources': [
      {'type': 'url', 'url': url},
    ],
  };

  Map<String, dynamic> imageJson() => {
    'type': 'image_result',
    'image_url': url,
    'source_website_url': url,
    'thumbnail_url': url,
    'caption': secret,
  };

  Map<String, dynamic> futureJson(String type) => {
    'type': type,
    'provider_data': {
      'private': [
        secret,
        {'url': url},
      ],
    },
  };

  Map<String, dynamic> callJson() => {
    'type': 'web_search_call',
    'id': 'ws_1',
    'agent': {'agent_name': 'researcher'},
    'status': 'searching',
    'action': searchJson(),
    'results': [imageJson(), futureJson('future_result')],
  };

  group('WebSearchCallStatus', () {
    for (final status in WebSearchCallStatus.values) {
      test('${status.value} round trips', () {
        expect(WebSearchCallStatus.fromJson(status.toJson()), status);
      });
    }
    test('unrecognized status uses unknown fallback', () {
      expect(
        WebSearchCallStatus.fromJson('future'),
        WebSearchCallStatus.unknown,
      );
    });
    test('exact canonical statuses are available', () {
      expect(WebSearchCallStatus.values.map((value) => value.toJson()), [
        'unknown',
        'in_progress',
        'searching',
        'completed',
        'failed',
        'incomplete',
      ]);
    });
  });

  group('Web search actions', () {
    final variants = <String, Map<String, dynamic> Function()>{
      'search': searchJson,
      'open_page': () => {'type': 'open_page', 'url': url},
      'find_in_page': () => {
        'type': 'find_in_page',
        'url': url,
        'pattern': secret,
      },
      'future_action': () => futureJson('future_action'),
    };
    for (final entry in variants.entries) {
      test('${entry.key} dispatch and full JSON value round trip', () {
        final json = entry.value();
        final parsed = WebSearchAction.fromJson(json);
        expect(parsed.type, entry.key);
        expect(parsed.toJson(), json);
        final repeated = WebSearchAction.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
        );
        expect(repeated, parsed);
        expect(repeated.hashCode, parsed.hashCode);
        expect({parsed, repeated}, hasLength(1));
        expect(parsed.toString(), contains('type: ${entry.key}'));
        expect(parsed.toString(), isNot(contains(secret)));
      });
    }

    for (final malformed in <Object?>[null, 1, false, [], {}]) {
      test('action malformed type $malformed is contextual', () {
        expect(
          () => WebSearchAction.fromJson({'type': malformed}),
          contextualError('WebSearchAction.type'),
        );
      });
    }
    test('action missing type is contextual', () {
      expect(
        () => WebSearchAction.fromJson({}),
        contextualError('WebSearchAction.type'),
      );
    });

    test('search empty optional lists and empty query are retained', () {
      final action = WebSearchActionSearch.fromJson(const {
        'type': 'search',
        'queries': <String>[],
        'query': '',
        'sources': <Map<String, dynamic>>[],
      });
      expect(action.toJson(), {
        'type': 'search',
        'queries': <String>[],
        'query': '',
        'sources': <Map<String, dynamic>>[],
      });
    });
    test('search absent optionals are omitted and clearable', () {
      final action = WebSearchActionSearch.fromJson(const {'type': 'search'});
      expect(action.queries, isNull);
      expect(action.query, isNull);
      expect(action.sources, isNull);
      expect(action.toJson(), {'type': 'search'});
      expect(
        action.toString(),
        contains('queries: null, query: null, sources: null'),
      );
      expect(
        WebSearchActionSearch.fromJson(
          searchJson(),
        ).copyWith(queries: null, query: null, sources: null),
        action,
      );
    });
    test('search copies every field and snapshots supplied lists', () {
      final original = WebSearchActionSearch.fromJson(searchJson());
      final queries = ['replacement'];
      final sources = [const WebSearchActionSource(url: 'https://new.example')];
      final copy = original.copyWith(
        queries: queries,
        query: 'replacement',
        sources: sources,
      );
      queries.add('mutated');
      sources.clear();
      expect(copy.toJson(), {
        'type': 'search',
        'queries': ['replacement'],
        'query': 'replacement',
        'sources': [
          {'type': 'url', 'url': 'https://new.example'},
        ],
      });
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      expect(() => copy.queries!.add('mutation'), throwsUnsupportedError);
      expect(() => copy.sources!.clear(), throwsUnsupportedError);
      expect(original, isNot(copy));
    });
    test('search each field participates in value equality', () {
      final action = WebSearchActionSearch.fromJson(searchJson());
      for (final changed in [
        action.copyWith(queries: const ['different']),
        action.copyWith(query: 'different'),
        action.copyWith(
          sources: const [WebSearchActionSource(url: 'different')],
        ),
      ]) {
        expect(changed, isNot(action));
        final repeated = WebSearchActionSearch.fromJson(changed.toJson());
        expect(repeated, changed);
        expect(repeated.hashCode, changed.hashCode);
      }
    });
    for (final field in ['queries', 'query', 'sources']) {
      for (final malformed in <Object?>[null, 1, false, {}]) {
        test('search $field rejects malformed $malformed', () {
          expect(
            () => WebSearchActionSearch.fromJson({
              'type': 'search',
              field: malformed,
            }),
            contextualError('WebSearchActionSearch.$field'),
          );
        });
      }
    }
    for (final malformed in <Object?>[null, 1, false, {}]) {
      test('search query element rejects $malformed contextually', () {
        expect(
          () => WebSearchActionSearch.fromJson({
            'type': 'search',
            'queries': ['valid', malformed],
          }),
          contextualError('WebSearchActionSearch.queries[1]'),
        );
      });
      test('search source element rejects $malformed contextually', () {
        expect(
          () => WebSearchActionSearch.fromJson({
            'type': 'search',
            'sources': [malformed],
          }),
          contextualError('WebSearchActionSearch.sources[0]'),
        );
      });
    }
    test('URL source round trip, copy, value and diagnostics', () {
      const source = WebSearchActionSource(url: url);
      final repeated = WebSearchActionSource.fromJson(source.toJson());
      expect(repeated, source);
      expect(repeated.hashCode, source.hashCode);
      expect(source.copyWith(), source);
      expect(source.copyWith(url: 'other').url, 'other');
      expect(source.copyWith(url: 'other'), isNot(source));
      expect(source.toString(), contains('url:'));
      expect(source.toString(), isNot(contains(secret)));
    });
    for (final malformed in <Object?>[null, 1, false, []]) {
      test('URL source required url rejects $malformed', () {
        expect(
          () =>
              WebSearchActionSource.fromJson({'type': 'url', 'url': malformed}),
          contextualError('WebSearchActionSource.url'),
        );
      });
    }
    test('source missing URL is contextual', () {
      expect(
        () => WebSearchActionSource.fromJson(const {'type': 'url'}),
        contextualError('WebSearchActionSource.url'),
      );
    });

    for (final optional in <Map<String, dynamic>>[
      {},
      {'url': null},
    ]) {
      test('open page normalizes absent/null url $optional', () {
        final action = WebSearchActionOpenPage.fromJson({
          'type': 'open_page',
          ...optional,
        });
        expect(action.url, isNull);
        expect(action.toJson(), {'type': 'open_page'});
        expect(action.toString(), contains('url: null'));
      });
    }
    test('open page copies, sets and clears URL', () {
      const original = WebSearchActionOpenPage(url: url);
      expect(original.copyWith(), original);
      expect(original.copyWith(url: 'other').url, 'other');
      expect(original.copyWith(url: 'other'), isNot(original));
      expect(original.copyWith(url: null).toJson(), {'type': 'open_page'});
    });
    for (final malformed in <Object?>[1, false, {}, []]) {
      test('open page wrong URL type $malformed is contextual', () {
        expect(
          () => WebSearchActionOpenPage.fromJson({
            'type': 'open_page',
            'url': malformed,
          }),
          contextualError('WebSearchActionOpenPage.url'),
        );
      });
    }
    test('find copies all fields', () {
      const original = WebSearchActionFind(url: url, pattern: secret);
      expect(original.copyWith(), original);
      expect(original.copyWith(url: 'other').url, 'other');
      expect(original.copyWith(pattern: 'other').pattern, 'other');
      expect(original.copyWith(url: 'other'), isNot(original));
      expect(original.copyWith(pattern: 'other'), isNot(original));
      expect(original.toString(), contains('url:'));
      expect(original.toString(), contains('pattern:'));
    });
    for (final field in ['url', 'pattern']) {
      test('find required $field omission is contextual', () {
        final json = {'type': 'find_in_page', 'url': url, 'pattern': secret}
          ..remove(field);
        expect(
          () => WebSearchActionFind.fromJson(json),
          contextualError('WebSearchActionFind.$field'),
        );
      });
      for (final malformed in <Object?>[null, 1, false, {}, []]) {
        test('find required $field rejects $malformed', () {
          expect(
            () => WebSearchActionFind.fromJson({
              'type': 'find_in_page',
              'url': url,
              'pattern': secret,
              field: malformed,
            }),
            contextualError('WebSearchActionFind.$field'),
          );
        });
      }
    }
    final directFactories =
        <String, WebSearchAction Function(Map<String, dynamic>)>{
          'search': WebSearchActionSearch.fromJson,
          'open_page': WebSearchActionOpenPage.fromJson,
          'find_in_page': WebSearchActionFind.fromJson,
        };
    for (final entry in directFactories.entries) {
      test('${entry.key} direct factory validates discriminator', () {
        expect(() => entry.value({'type': 'wrong'}), throwsFormatException);
        expect(() => entry.value({}), throwsFormatException);
      });
    }
    test('URL source direct factory validates discriminator', () {
      expect(
        () =>
            WebSearchActionSource.fromJson(const {'type': 'wrong', 'url': url}),
        contextualError('WebSearchActionSource.type'),
      );
    });

    test(
      'unknown action recursively snapshots JSON and copies type with precedence',
      () {
        final input = futureJson('future_action');
        final action =
            WebSearchAction.fromJson(input) as UnknownWebSearchAction;
        (input['provider_data'] as Map<String, dynamic>)['private'] = [
          'mutated',
        ];
        expect(action.toJson(), futureJson('future_action'));
        expect(() => action.data['new'] = true, throwsUnsupportedError);
        final provider = action.data['provider_data'] as Map<String, dynamic>;
        expect(() => provider['new'] = true, throwsUnsupportedError);
        final list = provider['private'] as List;
        expect(() => list.add(true), throwsUnsupportedError);
        expect(
          () => (list[1] as Map)['url'] = 'mutated',
          throwsUnsupportedError,
        );
        expect(action.copyWith(), action);
        expect(action.copyWith().hashCode, action.hashCode);
        final copy = action.copyWith(type: 'new_type');
        expect(copy.type, 'new_type');
        expect(copy.toJson()['type'], 'new_type');
        expect(copy, isNot(action));
        expect(WebSearchAction.fromJson(copy.toJson()), copy);
        final updated = action.copyWith(
          data: {
            'type': 'stale',
            'data': [secret],
          },
        );
        expect(updated.toJson(), {
          'type': 'future_action',
          'data': [secret],
        });
        expect(updated, isNot(action));
      },
    );
  });

  test('unknown action value equality ignores nested map insertion order', () {
    final first = UnknownWebSearchAction(
      type: 'future',
      data: const {
        'one': {
          'a': 1,
          'b': [2, 3],
        },
        'two': true,
      },
    );
    final second = UnknownWebSearchAction(
      type: 'future',
      data: const {
        'two': true,
        'one': {
          'b': [2, 3],
          'a': 1,
        },
      },
    );
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first.toJson(), {
      'type': 'future',
      'one': {
        'a': 1,
        'b': [2, 3],
      },
      'two': true,
    });
  });

  group('Web search results', () {
    for (final json in [
      imageJson(),
      futureJson('future_result'),
      futureJson('text_result'),
    ]) {
      test('${json['type']} dispatch, JSON and equality/hash round trip', () {
        final result = WebSearchResult.fromJson(json);
        final repeated = WebSearchResult.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
        );
        expect(result.toJson(), json);
        expect(repeated, result);
        expect(repeated.hashCode, result.hashCode);
        expect({result, repeated}, hasLength(1));
        expect(result.toString(), contains('type: ${json['type']}'));
        expect(result.toString(), isNot(contains(secret)));
        if (json['type'] == 'image_result') {
          expect(result, isA<WebSearchImageResult>());
        } else {
          expect(result, isA<UnknownWebSearchResult>());
        }
      });
    }
    for (final malformed in <Object?>[null, 1, false, [], {}]) {
      test('result malformed type $malformed is contextual', () {
        expect(
          () => WebSearchResult.fromJson({'type': malformed}),
          contextualError('WebSearchResult.type'),
        );
      });
    }
    test('result missing type is contextual', () {
      expect(
        () => WebSearchResult.fromJson({}),
        contextualError('WebSearchResult.type'),
      );
    });
    for (final field in ['image_url', 'source_website_url']) {
      test('image required $field omission is contextual', () {
        expect(
          () => WebSearchImageResult.fromJson(imageJson()..remove(field)),
          contextualError('WebSearchImageResult.$field'),
        );
      });
      for (final malformed in <Object?>[null, 1, false, {}, []]) {
        test('image required $field rejects $malformed', () {
          expect(
            () => WebSearchImageResult.fromJson({
              ...imageJson(),
              field: malformed,
            }),
            contextualError('WebSearchImageResult.$field'),
          );
        });
      }
    }
    for (final field in ['thumbnail_url', 'caption']) {
      for (final malformed in <Object?>[1, false, {}, []]) {
        test('image optional $field rejects $malformed', () {
          expect(
            () => WebSearchImageResult.fromJson({
              ...imageJson(),
              field: malformed,
            }),
            contextualError('WebSearchImageResult.$field'),
          );
        });
      }
    }
    test('image absent/null guide metadata normalizes to absence', () {
      final json = imageJson()
        ..remove('thumbnail_url')
        ..remove('caption');
      final result = WebSearchImageResult.fromJson(json);
      final explicitNull = WebSearchImageResult.fromJson({
        ...json,
        'thumbnail_url': null,
        'caption': null,
      });
      expect(explicitNull, result);
      expect(explicitNull.hashCode, result.hashCode);
      expect(explicitNull.toJson(), json);
      expect(
        explicitNull.toString(),
        contains('thumbnailUrl: null, caption: null'),
      );
    });
    test('image copies every field and clears nullable metadata', () {
      final original = WebSearchImageResult.fromJson(imageJson());
      final copy = original.copyWith(
        imageUrl: 'image',
        sourceWebsiteUrl: 'source',
        thumbnailUrl: 'thumb',
        caption: 'caption',
      );
      expect(copy.toJson(), {
        'type': 'image_result',
        'image_url': 'image',
        'source_website_url': 'source',
        'thumbnail_url': 'thumb',
        'caption': 'caption',
      });
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      final cleared = original.copyWith(thumbnailUrl: null, caption: null);
      expect(cleared.thumbnailUrl, isNull);
      expect(cleared.caption, isNull);
      expect(cleared.toJson().keys, isNot(contains('thumbnail_url')));
      expect(cleared.toJson().keys, isNot(contains('caption')));
      for (final changed in [
        original.copyWith(imageUrl: 'other'),
        original.copyWith(sourceWebsiteUrl: 'other'),
        original.copyWith(thumbnailUrl: 'other'),
        original.copyWith(caption: 'other'),
      ]) {
        expect(changed, isNot(original));
      }
      for (final field in [
        'imageUrl:',
        'sourceWebsiteUrl:',
        'thumbnailUrl:',
        'caption:',
      ]) {
        expect(original.toString(), contains(field));
      }
    });
    test('image direct factory validates discriminator', () {
      expect(
        () => WebSearchImageResult.fromJson({...imageJson(), 'type': 'wrong'}),
        contextualError('WebSearchImageResult.type'),
      );
    });
    test(
      'unknown result recursively snapshots JSON and copies type with precedence',
      () {
        final input = futureJson('future_result');
        final result =
            WebSearchResult.fromJson(input) as UnknownWebSearchResult;
        (input['provider_data'] as Map<String, dynamic>)['private'] = [
          'mutated',
        ];
        expect(result.toJson(), futureJson('future_result'));
        expect(() => result.data['new'] = true, throwsUnsupportedError);
        final provider = result.data['provider_data'] as Map<String, dynamic>;
        expect(() => provider['new'] = true, throwsUnsupportedError);
        final list = provider['private'] as List;
        expect(() => list.add(true), throwsUnsupportedError);
        expect(
          () => (list[1] as Map)['url'] = 'mutated',
          throwsUnsupportedError,
        );
        expect(result.copyWith(), result);
        expect(result.copyWith().hashCode, result.hashCode);
        final copy = result.copyWith(type: 'new_type');
        expect(copy.type, 'new_type');
        expect(copy.toJson()['type'], 'new_type');
        expect(copy, isNot(result));
        expect(WebSearchResult.fromJson(copy.toJson()), copy);
        final updated = result.copyWith(
          data: {
            'type': 'stale',
            'data': [secret],
          },
        );
        expect(updated.toJson(), {
          'type': 'future_result',
          'data': [secret],
        });
        expect(updated, isNot(result));
      },
    );
  });

  test('unknown result value equality ignores nested map insertion order', () {
    final first = UnknownWebSearchResult(
      type: 'future',
      data: const {
        'one': {
          'a': 1,
          'b': [2, 3],
        },
        'two': true,
      },
    );
    final second = UnknownWebSearchResult(
      type: 'future',
      data: const {
        'two': true,
        'one': {
          'b': [2, 3],
          'a': 1,
        },
      },
    );
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first.toJson(), {
      'type': 'future',
      'one': {
        'a': 1,
        'b': [2, 3],
      },
      'two': true,
    });
  });

  group('Web search call models', () {
    final parsers = <String, Object Function(Map<String, dynamic>)>{
      'WebSearchCallOutputItem': WebSearchCallOutputItem.fromJson,
      'ConversationWebSearchCallItem': ConversationWebSearchCallItem.fromJson,
    };
    Map<String, dynamic> serialize(Object item) => switch (item) {
      WebSearchCallOutputItem() => item.toJson(),
      ConversationWebSearchCallItem() => item.toJson(),
      _ => throw StateError('Unexpected test model'),
    };
    List<WebSearchResult>? results(Object item) => switch (item) {
      WebSearchCallOutputItem() => item.results,
      ConversationWebSearchCallItem() => item.results,
      _ => throw StateError('Unexpected test model'),
    };
    Object copy(Object item, String field, Object? value) => switch (item) {
      WebSearchCallOutputItem() => switch (field) {
        'id' => item.copyWith(id: value! as String),
        'agent' => item.copyWith(agent: value),
        'status' => item.copyWith(status: value),
        'action' => item.copyWith(action: value),
        'results' => item.copyWith(results: value),
        _ => item.copyWith(),
      },
      ConversationWebSearchCallItem() => switch (field) {
        'id' => item.copyWith(id: value! as String),
        'agent' => item.copyWith(agent: value),
        'status' => item.copyWith(status: value),
        'action' => item.copyWith(action: value),
        'results' => item.copyWith(results: value),
        _ => item.copyWith(),
      },
      _ => throw StateError('Unexpected test model'),
    };
    for (final parser in parsers.entries) {
      test('${parser.key} full JSON and value round trip', () {
        final json = callJson();
        final item = parser.value(json);
        final repeated = parser.value(
          jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
        );
        expect(serialize(item), json);
        expect(repeated, item);
        expect(repeated.hashCode, item.hashCode);
        expect({item, repeated}, hasLength(1));
        expect(copy(item, '', null), item);
        expect(copy(item, '', null).hashCode, item.hashCode);
        expect(item.toString(), isNot(contains(secret)));
        for (final field in [
          'type:',
          'id:',
          'agent:',
          'status:',
          'action:',
          'results:',
        ]) {
          expect(item.toString(), contains(field));
        }
        expect(() => results(item)!.clear(), throwsUnsupportedError);
      });
      for (final status in WebSearchCallStatus.values) {
        test('${parser.key} retains exact ${status.value} status', () {
          expect(
            serialize(
              parser.value({...callJson(), 'status': status.value}),
            )['status'],
            status.value,
          );
        });
      }
      test('${parser.key} future status uses fallback', () {
        expect(
          serialize(
            parser.value({...callJson(), 'status': 'future'}),
          )['status'],
          'unknown',
        );
      });
      test('${parser.key} legacy omitted status and fields remain omitted', () {
        final json = {'type': 'web_search_call', 'id': 'ws_legacy'};
        final item = parser.value(json);
        expect(serialize(item), json);
        expect(item.toString(), contains('results: null'));
        expect(item.toString(), contains('action: null'));
      });
      test(
        '${parser.key} nullable legacy status and agent normalize omission',
        () {
          final json = {
            'type': 'web_search_call',
            'id': 'ws_legacy',
            'status': null,
            'agent': null,
          };
          expect(serialize(parser.value(json)), {
            'type': 'web_search_call',
            'id': 'ws_legacy',
          });
        },
      );
      test('${parser.key} empty results are retained', () {
        expect(
          serialize(
            parser.value({...callJson(), 'results': <Map<String, dynamic>>[]}),
          )['results'],
          isEmpty,
        );
      });
      final values = <String, Object>{
        'id': 'other',
        'agent': const AgentTag(agentName: 'other'),
        'status': WebSearchCallStatus.failed,
        'action': const WebSearchActionFind(url: url, pattern: 'other'),
        'results': const <WebSearchResult>[],
      };
      for (final entry in values.entries) {
        test('${parser.key} copy updates ${entry.key} and value equality', () {
          final item = parser.value(callJson());
          final changed = copy(item, entry.key, entry.value);
          expect(changed, isNot(item));
          final wireValue = switch (entry.value) {
            AgentTag() => (entry.value as AgentTag).toJson(),
            WebSearchCallStatus() =>
              (entry.value as WebSearchCallStatus).toJson(),
            WebSearchAction() => (entry.value as WebSearchAction).toJson(),
            List<WebSearchResult>() => <Map<String, dynamic>>[],
            _ => entry.value,
          };
          expect(serialize(changed)[entry.key], wireValue);
          final repeated = parser.value(serialize(changed));
          expect(repeated, changed);
          expect(repeated.hashCode, changed.hashCode);
        });
        if (entry.key != 'id') {
          test('${parser.key} copy clears optional ${entry.key}', () {
            expect(
              serialize(copy(parser.value(callJson()), entry.key, null)).keys,
              isNot(contains(entry.key)),
            );
          });
        }
      }
      for (final field in ['id', 'type']) {
        test('${parser.key} required $field omission is contextual', () {
          expect(
            () => parser.value(callJson()..remove(field)),
            contextualError('${parser.key}.$field'),
          );
        });
      }
      for (final malformed in <Object?>[null, 1, false, {}, []]) {
        test('${parser.key} required id rejects $malformed', () {
          expect(
            () => parser.value({...callJson(), 'id': malformed}),
            contextualError('${parser.key}.id'),
          );
        });
      }
      test('${parser.key} direct discriminator rejects wrong type', () {
        expect(
          () => parser.value({...callJson(), 'type': 'wrong'}),
          contextualError('${parser.key}.type'),
        );
      });
      for (final field in ['action', 'results']) {
        for (final malformed in <Object?>[null, 1, false, 'wrong']) {
          test('${parser.key} optional nonnull $field rejects $malformed', () {
            expect(
              () => parser.value({...callJson(), field: malformed}),
              contextualError('${parser.key}.$field'),
            );
          });
        }
      }
      for (final malformed in <Object?>[1, false, {}, []]) {
        test('${parser.key} malformed status $malformed is contextual', () {
          expect(
            () => parser.value({...callJson(), 'status': malformed}),
            contextualError('${parser.key}.status'),
          );
        });
      }
      for (final malformed in <Object?>[1, false, 'wrong', []]) {
        test('${parser.key} malformed agent $malformed is contextual', () {
          expect(
            () => parser.value({...callJson(), 'agent': malformed}),
            contextualError('${parser.key}.agent'),
          );
        });
      }
      for (final malformed in <Object?>[null, 1, false, {}, []]) {
        test('${parser.key} malformed agent name $malformed is contextual', () {
          expect(
            () => parser.value({
              ...callJson(),
              'agent': {'agent_name': malformed},
            }),
            contextualError('${parser.key}.agent.agent_name'),
          );
        });
        test(
          '${parser.key} malformed result element $malformed is contextual',
          () {
            expect(
              () => parser.value({
                ...callJson(),
                'results': [malformed],
              }),
              contextualError('${parser.key}.results[0]'),
            );
          },
        );
      }
      test('${parser.key} nested image error identifies original path', () {
        expect(
          () => parser.value({
            ...callJson(),
            'results': [imageJson()..remove('image_url')],
          }),
          contextualError('${parser.key}.results[0].image_url'),
        );
      });
      test('${parser.key} nested action error identifies original path', () {
        expect(
          () => parser.value({
            ...callJson(),
            'action': {
              'type': 'search',
              'queries': [1],
            },
          }),
          contextualError('${parser.key}.action.queries[0]'),
        );
      });
      test(
        '${parser.key} future action and result objects preserve nested JSON',
        () {
          final json = {...callJson(), 'action': futureJson('future_action')};
          expect(serialize(parser.value(json)), json);
        },
      );
    }
    test('output and conversation helpers preserve all typed input fields', () {
      final json = callJson();
      final output = WebSearchCallOutputItem.fromJson(
        json,
      ).toWebSearchCallItem();
      final conversation = ConversationWebSearchCallItem.fromJson(
        json,
      ).toWebSearchCallItem();
      expect(output, isA<WebSearchCallItem>());
      expect(output.toJson(), json);
      expect(conversation.toJson(), json);
      expect(output, conversation);
      expect(output.hashCode, conversation.hashCode);
    });
    test('const call constructors remain available', () {
      const output = WebSearchCallOutputItem(
        id: 'ws_1',
        status: WebSearchCallStatus.completed,
        action: WebSearchActionOpenPage(),
        results: [],
      );
      const conversation = ConversationWebSearchCallItem(
        id: 'ws_1',
        status: WebSearchCallStatus.completed,
        action: WebSearchActionOpenPage(),
        results: [],
      );
      expect(output.toJson(), conversation.toJson());
    });
    test(
      'public OutputItem and ConversationItem dispatch retain full payload',
      () {
        final json = callJson();
        expect(OutputItem.fromJson(json), isA<WebSearchCallOutputItem>());
        expect(
          ConversationItem.fromJson(json),
          isA<ConversationWebSearchCallItem>(),
        );
        expect(OutputItem.fromJson(json).toJson(), json);
        expect(ConversationItem.fromJson(json).toJson(), json);
      },
    );
  });
}
