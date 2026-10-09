import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_session_history_fixtures.dart';

void main() {
  for (final fixture in agentSessionHistoryFixtures) {
    for (final sample in {
      'minimal': fixture.minimal,
      'full': fixture.full,
    }.entries) {
      test(
        '${fixture.schema}: ${sample.key} canonical roundtrip/copy/privacy',
        () {
          final model = fixture.parse(sample.value);
          expect(model.toJson(), sample.value);
          final copied = fixture.copy(model);
          expect(copied, model);
          expect(copied.hashCode, model.hashCode);
          expect(model.toString(), isNot(contains('PRIVATE')));
        },
      );
    }
    test(
      '${fixture.schema}: required fields and malformed known values fail privately',
      () {
        for (final key in fixture.minimal.keys) {
          final missing = Map<String, dynamic>.of(fixture.minimal)..remove(key);
          expect(
            () => fixture.parse(missing),
            throwsFormatException,
            reason: key,
          );
          final malformed = Map<String, dynamic>.of(fixture.minimal)
            ..[key] = (fixture.minimal[key] is Map
                ? 'PRIVATE'
                : <String, dynamic>{'PRIVATE': true});
          expect(
            () => fixture.parse(malformed),
            throwsA(
              isA<FormatException>().having(
                (e) => e.toString(),
                'private',
                isNot(contains('PRIVATE')),
              ),
            ),
            reason: key,
          );
        }
      },
    );
    test(
      '${fixture.schema}: finite received extras detached and cannot override fields',
      () {
        final raw = <String, dynamic>{
          ...fixture.full,
          'future': <String, dynamic>{
            'nested': <Object?>[null, 'PRIVATE'],
          },
        };
        final model = fixture.parse(raw);
        final expected = jsonDecode(jsonEncode(model.toJson()));
        (raw['future'] as Map<String, dynamic>)['nested'] = <Object?>[
          'changed',
        ];
        expect(model.toJson(), expected);
        expect(model.toString(), isNot(contains('PRIVATE')));
        expect(
          () => fixture.parse({...fixture.minimal, 'future': double.nan}),
          throwsFormatException,
        );
      },
    );
  }
  test(
    'All seventeen history item branches retain safe returned representations',
    () {
      final fixture = agentSessionHistoryFixtures.singleWhere(
        (f) => f.schema == 'SessionItemListResource',
      );
      final page = AgentSessionItemList.fromJson(fixture.full);
      expect(page.data, hasLength(17));
      expect(page.data.map((x) => x.type).toSet(), hasLength(17));
      for (final item in page.data) {
        expect(AgentSessionTurnItem.fromJson(item.toJson()), item);
        final bad = Map<String, dynamic>.of(item.toJson())..remove('type');
        expect(() => AgentSessionTurnItem.fromJson(bad), throwsFormatException);
      }
      final authentication = page.data.singleWhere(
        (x) => x.type == 'computer_use_approval_request_result',
      );
      final response =
          authentication.toJson()['response'] as Map<String, dynamic>;
      expect(response.containsKey('fields'), isFalse);
      expect(response.containsKey('values'), isFalse);
      final unknown = AgentSessionTurnItem.fromJson(const {
        'type': 'future',
        'payload': {
          'PRIVATE': [1, null],
        },
      });
      expect(unknown.toString(), isNot(contains('PRIVATE')));
      expect(AgentSessionTurnItem.fromJson(unknown.toJson()), unknown);
    },
  );
  test(
    'Page clear/replacement copies preserve nullable boundaries and data ownership',
    () {
      final source = agentSessionHistoryFixtures
          .singleWhere((f) => f.schema == 'SessionItemListResource')
          .full;
      final page = AgentSessionItemList.fromJson(source);
      final data = page.data.toList();
      final copied = page.copyWith(
        data: data,
        firstId: null,
        lastId: null,
        hasMore: false,
      );
      data.clear();
      expect(copied.data, hasLength(17));
      expect(copied.firstId, isNull);
      expect(copied.lastId, isNull);
      expect(copied.toJson().containsKey('first_id'), isTrue);
      expect(copied, isNot(page));
      expect(copied.data.clear, throwsUnsupportedError);
      expect(
        () => page.copyWith(rawJson: {'data': 'PRIVATE'}),
        throwsFormatException,
      );
      final turns = AgentSessionTurnList.fromJson(
        agentSessionHistoryFixtures
            .singleWhere((f) => f.schema == 'SessionTurnListResource')
            .full,
      );
      final cleared = turns.copyWith(
        firstId: null,
        lastId: null,
        data: [],
        hasMore: false,
      );
      expect(cleared.toJson(), {
        'object': 'list',
        'data': <Object?>[],
        'first_id': null,
        'last_id': null,
        'has_more': false,
      });
      final traces = AgentSessionTraceList.fromJson(
        agentSessionHistoryFixtures
            .singleWhere((f) => f.schema == 'SessionTraceListResource')
            .full,
      );
      expect(
        traces.copyWith(firstId: null, lastId: null, hasMore: false).firstId,
        isNull,
      );
      expect(
        () => AgentSessionTraceList(
          data: List.filled(2001, traces.data.first),
          firstId: null,
          lastId: null,
          hasMore: false,
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'Arbitrary OTLP snapshot/copy deep ownership, equality/hash and finite values',
    () {
      final data = <String, dynamic>{
        'resourceSpans': <Object?>[
          <String, dynamic>{
            'PRIVATE': <Object?>[false, null, 1, 'café🚀'],
          },
        ],
      };
      final trace = AgentSessionTurnTrace(
        id: 'turn',
        sessionId: 'session',
        createdAt: 0,
        otlp: data,
      );
      final expected = jsonDecode(jsonEncode(trace.toJson()));
      data.clear();
      expect(trace.toJson(), expected);
      final changed = trace.copyWith(
        id: 'next',
        sessionId: 'other',
        createdAt: 2,
        otlp: {
          'other': [null, true],
        },
        rawJson: {
          'future': {'PRIVATE': true},
        },
      );
      expect(AgentSessionTurnTrace.fromJson(changed.toJson()), changed);
      expect(
        AgentSessionTurnTrace.fromJson(changed.toJson()).hashCode,
        changed.hashCode,
      );
      expect(changed, isNot(trace));
      expect(changed.toString(), isNot(contains('PRIVATE')));
      expect(() => trace.otlp['bad'] = true, throwsUnsupportedError);
      final cyclic = <String, dynamic>{};
      cyclic['self'] = cyclic;
      for (final invalid in [
        cyclic,
        <String, dynamic>{'value': double.infinity},
      ]) {
        expect(() => trace.copyWith(otlp: invalid), throwsFormatException);
      }
    },
  );
  test(
    'History page counts, copy type errors and safe authentication submit record',
    () {
      final items = AgentSessionItemList.fromJson(
        agentSessionHistoryFixtures
            .singleWhere((f) => f.schema == 'SessionItemListResource')
            .full,
      );
      final turns = AgentSessionTurnList.fromJson(
        agentSessionHistoryFixtures
            .singleWhere((f) => f.schema == 'SessionTurnListResource')
            .full,
      );
      expect(
        () => items.copyWith(data: List.filled(2001, items.data.first)),
        throwsFormatException,
      );
      expect(
        () => turns.copyWith(data: List.filled(2001, turns.data.first)),
        throwsFormatException,
      );
      expect(() => items.copyWith(firstId: 1), throwsFormatException);
      final safe =
          AgentSessionBrowserAuthenticationResponseResource.fromJson(const {
            'type': 'browser_authentication',
            'action': 'submit',
            'selected_option': null,
          });
      expect(safe.toJson(), {
        'type': 'browser_authentication',
        'action': 'submit',
        'selected_option': null,
      });
      expect(safe.toString(), contains('[REDACTED]'));
    },
  );
  test(
    'Direct/copy timestamp construction rejects nonfinite values on every platform',
    () {
      final valid = AgentSessionTurnTrace(
        id: 'turn',
        sessionId: 'session',
        createdAt: 0,
        otlp: const {},
      );
      for (final value in [
        double.infinity,
        double.negativeInfinity,
        double.nan,
      ]) {
        expect(
          () => AgentSessionTurnTrace(
            id: 'turn',
            sessionId: 'session',
            createdAt: value as dynamic,
            otlp: const {},
          ),
          throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
        );
        expect(
          () => valid.copyWith(createdAt: value as dynamic),
          throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
        );
        expect(
          () => AgentSessionTurnTrace.fromJson({
            ...valid.toJson(),
            'created_at': value,
          }),
          throwsFormatException,
        );
      }
    },
  );
}
