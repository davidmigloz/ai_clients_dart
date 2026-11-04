import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _row() => {
  'id': 'artifact_private',
  'object': 'agent.session.artifact',
  'created_at': 1,
  'environment_id': 'environment_private',
  'path': '/workspace/outputs/private.bin',
  'session_id': 'session_private',
  'size_bytes': 2,
  'turn_id': 'turn_private',
};
Map<String, dynamic> _page(List<Map<String, dynamic>> rows) => {
  'object': 'list',
  'data': rows,
  'first_id': null,
  'last_id': 'opaque /%?🚀',
  'has_more': true,
};

void main() {
  test(
    'legacy IDs are contextual and never weaken canonical artifact parsing',
    () {
      for (final missing in [false, true]) {
        final json = _row();
        if (missing) {
          json.remove('id');
        } else {
          json['id'] = null;
        }
        expect(
          () => AgentSessionArtifact.fromJson(json),
          throwsFormatException,
        );
        final candidate = AgentArtifactLookupCandidate.fromJson(json);
        expect(candidate.id, isNull);
        expect(candidate.hasId, !missing);
        expect(candidate.toJson(), json);
        expect(candidate.requireArtifact, throwsFormatException);
        expect(candidate.copyWith().toJson(), json);
        expect(candidate.copyWith().hashCode, candidate.hashCode);
        expect(candidate.toString(), isNot(contains('artifact_private')));
        expect(
          candidate.toString(),
          isNot(contains('/workspace/outputs/private.bin')),
        );
      }
      final valid = AgentArtifactLookupCandidate.fromJson(_row());
      expect(valid.requireArtifact(), AgentSessionArtifact.fromJson(_row()));
      expect(
        () => valid.copyWith(id: '').requireArtifact(),
        throwsFormatException,
      );
      expect(
        () => AgentArtifactLookupCandidate.fromJson({..._row(), 'id': 7}),
        throwsFormatException,
      );
    },
  );

  test(
    'candidate copying includes every scalar, explicit ID presence and authoritative fields',
    () {
      final original = AgentArtifactLookupCandidate.fromJson({
        ..._row(),
        'future': const {
          'values': [1],
        },
      });
      final variants = [
        original.copyWith(id: 'different'),
        original.copyWith(createdAt: 2),
        original.copyWith(environmentId: 'different'),
        original.copyWith(path: '/workspace/other'),
        original.copyWith(sessionId: 'different'),
        original.copyWith(sizeBytes: 3),
        original.copyWith(turnId: 'different'),
      ];
      for (final value in variants) {
        expect(value, isNot(original));
      }
      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
      final nullId = original.copyWith(id: null);
      final absent = original.copyWith(omitId: true);
      expect(nullId.hasId, isTrue);
      expect(nullId.id, isNull);
      expect(absent.hasId, isFalse);
      expect(absent.id, isNull);
      expect(nullId, isNot(absent));
      expect(original.copyWith(id: 'replacement', omitId: true).hasId, isFalse);
      final extras = original.copyWith(
        rawJson: {
          'id': 'wrong',
          'path': '/wrong',
          'future': {
            'values': [2],
          },
        },
      );
      expect(extras.id, original.id);
      expect(extras.path, original.path);
      expect(extras.rawJson['future'], {
        'values': [2],
      });
    },
  );

  test(
    'candidate owns nested extras and preserves every required non-ID field strictly',
    () {
      final future = {
        'values': <Object?>[1],
      };
      final json = {..._row(), 'future': future};
      final candidate = AgentArtifactLookupCandidate.fromJson(json);
      (future['values']!).add(2);
      json['path'] = 'changed';
      expect(candidate.path, '/workspace/outputs/private.bin');
      expect(candidate.rawJson['future'], {
        'values': [1],
      });
      expect(
        () => ((candidate.rawJson['future'] as Map)['values'] as List).add(9),
        throwsUnsupportedError,
      );
      final exported = candidate.toJson()..['id'] = 'changed';
      expect(exported['id'], 'changed');
      expect(candidate.id, 'artifact_private');
      for (final key in [
        'object',
        'created_at',
        'environment_id',
        'path',
        'session_id',
        'size_bytes',
        'turn_id',
      ]) {
        final missing = _row()..remove(key);
        expect(
          () => AgentArtifactLookupCandidate.fromJson(missing),
          throwsFormatException,
        );
        expect(
          () => AgentArtifactLookupCandidate.fromJson({..._row(), key: null}),
          throwsFormatException,
        );
      }
      expect(
        () => AgentArtifactLookupCandidate.fromJson({
          ..._row(),
          'size_bytes': -1,
        }),
        throwsFormatException,
      );
      expect(
        () => AgentArtifactLookupCandidate.fromJson({
          ..._row(),
          'created_at': 1.5,
        }),
        throwsFormatException,
      );
      expect(
        () => AgentArtifactLookupCandidate.fromJson({
          ..._row(),
          'object': 'page',
        }),
        throwsFormatException,
      );
      expect(
        () => AgentArtifactLookupCandidate.fromJson({
          ..._row(),
          'future': double.infinity,
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'lookup page uses actual opaque last_id even when all row IDs are null',
    () {
      final json = _page([
        {..._row(), 'id': null},
      ]);
      final page = AgentArtifactLookupPage.fromJson(json);
      expect(page.data.single.id, isNull);
      expect(page.lastId, 'opaque /%?🚀');
      expect(page.hasMore, isTrue);
      expect(page.toJson(), json);
      expect(page.copyWith(), page);
      expect(page.copyWith().hashCode, page.hashCode);
      expect(page.copyWith(firstId: 'new'), isNot(page));
      expect(page.copyWith(lastId: 'new'), isNot(page));
      expect(page.copyWith(hasMore: false), isNot(page));
      expect(page.copyWith(data: []), isNot(page));
      expect(page.copyWith(lastId: null).toJson()['last_id'], isNull);
      expect(page.copyWith(lastId: null).copyWith().lastId, isNull);
      expect(page.toString(), isNot(contains('opaque')));
      expect(page.data.clear, throwsUnsupportedError);
      expect(() => page.copyWith(lastId: 7), throwsFormatException);
    },
  );

  test(
    'lookup envelope remains strict and bounds match the raw artifact page',
    () {
      for (final key in ['object', 'data', 'first_id', 'last_id', 'has_more']) {
        final missing = _page([])..remove(key);
        expect(
          () => AgentArtifactLookupPage.fromJson(missing),
          throwsFormatException,
        );
      }
      for (final key in ['object', 'data', 'has_more']) {
        expect(
          () => AgentArtifactLookupPage.fromJson({..._page([]), key: null}),
          throwsFormatException,
        );
      }
      expect(
        () => AgentArtifactLookupPage.fromJson({
          ..._page([]),
          'object': 'page',
          'next': 'wrong',
        }),
        throwsFormatException,
      );
      final row = AgentArtifactLookupCandidate.fromJson(_row());
      expect(
        () => AgentArtifactLookupPage(
          data: List.filled(2001, row),
          firstId: null,
          lastId: null,
          hasMore: false,
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'public helper view reuses exact raw GET route/auth/header/query policy',
    () async {
      const opaque = 'cursor /%?🚀';
      final sent = <http.Request>[];
      final sdk = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/proxy/v1',
          authProvider: ApiKeyProvider('fixture-key'),
          project: 'project_fixture',
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((request) async {
          sent.add(request);
          return http.Response(
            jsonEncode(
              _page([
                {..._row(), 'id': null},
              ]),
            ),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final result = await sdk.agents.sessions.artifacts.listForLookup(
        'session /?🚀',
        limit: 100,
        order: AgentListOrder.asc,
        after: opaque,
        additionalHeaders: {'OpenAI-Beta': 'wrong', 'Accept': 'wrong'},
      );
      expect(result.data.single.id, isNull);
      expect(result.lastId, 'opaque /%?🚀');
      final request = sent.single;
      expect(request.method, 'GET');
      expect(request.url.pathSegments, [
        'proxy',
        'v1',
        'agents',
        'sessions',
        'session /?🚀',
        'artifacts',
      ]);
      expect(request.url.queryParameters, {
        'limit': '100',
        'order': 'asc',
        'after': opaque,
      });
      expect(request.headers['openai-beta'], 'agents=v1');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['authorization'], 'Bearer fixture-key');
      expect(request.headers['openai-project'], 'project_fixture');
      expect(request.headers.containsKey('content-type'), isFalse);
      expect(request.bodyBytes, isEmpty);
      await expectLater(
        sdk.agents.sessions.artifacts.list('session_fixture'),
        throwsA(isA<ParseException>()),
      );
      sdk.close();
    },
  );
}
