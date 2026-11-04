import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final kind in ['ready', 'failed', 'suspended', 'expired']) {
    group('agent.environment.$kind', () {
      test('dispatch, required envelope and exact value/copy semantics', () {
        final wire = _wire(kind);
        final parsed = WebhookEvent.fromJson(wire);
        expect(parsed, isA<WebhookAgentSessionEnvelope>());
        expect(parsed, switch (kind) {
          'ready' => isA<AgentEnvironmentReadyWebhookEvent>(),
          'failed' => isA<AgentEnvironmentFailedWebhookEvent>(),
          'suspended' => isA<AgentEnvironmentSuspendedWebhookEvent>(),
          _ => isA<AgentEnvironmentExpiredWebhookEvent>(),
        });
        expect(parsed.data, isA<WebhookIdData>());
        expect((parsed.data! as WebhookIdData).id, 'PRIVATE-environment');
        expect(parsed.toJson(), wire);
        final copied = _copy(parsed);
        expect(copied, parsed);
        expect(copied.hashCode, parsed.hashCode);
        expect(parsed.toString(), isNot(contains('PRIVATE')));
        expect(
          (parsed.data! as WebhookIdData).toString(),
          isNot(contains('PRIVATE')),
        );
        expect(jsonDecode(jsonEncode(parsed.toJson())), wire);
        final replaced = _copy(parsed, data: WebhookIdData(id: 'replacement'));
        expect(replaced.toJson()['data'], {'id': 'replacement'});
        expect(replaced, isNot(parsed));
        final renamed = _copy(parsed, id: 'changed', createdAt: 456);
        expect(renamed.toJson(), {...wire, 'id': 'changed', 'created_at': 456});
        expect(renamed, isNot(parsed));
      });
      test(
        'known envelope fields and payload fail when malformed or missing',
        () {
          for (final key in ['id', 'object', 'created_at', 'type', 'data']) {
            final wire = _wire(kind)..remove(key);
            expect(() => WebhookEvent.fromJson(wire), throwsFormatException);
            expect(
              () => WebhookEvent.fromJson(_wire(kind)..[key] = null),
              throwsFormatException,
            );
          }
          for (final data in [
            <String, dynamic>{},
            {'id': null},
            {'id': 1},
            'PRIVATE',
          ]) {
            expect(
              () => WebhookEvent.fromJson(_wire(kind)..['data'] = data),
              throwsFormatException,
            );
          }
          expect(
            () => WebhookEvent.fromJson(_wire(kind)..['created_at'] = 1.5),
            throwsFormatException,
          );
          expect(
            () => WebhookEvent.fromJson(_wire(kind)..['object'] = 'PRIVATE'),
            throwsFormatException,
          );
        },
      );
      test(
        'received metadata is detached and no environment prefix is invented',
        () {
          final nested = <String, dynamic>{
            'private': <String>['PRIVATE'],
          };
          final wire = _wire(kind)..['future'] = nested;
          final parsed = WebhookEvent.fromJson(wire);
          (nested['private'] as List<String>).clear();
          (wire['data'] as Map<String, dynamic>)['id'] = 'changed';
          expect(parsed.toJson()['future'], {
            'private': ['PRIVATE'],
          });
          expect((parsed.data! as WebhookIdData).id, 'PRIVATE-environment');
          expect(
            () =>
                ((parsed.toJson()['future'] as Map)['private'] as List).clear(),
            throwsUnsupportedError,
          );
          final emptyId = WebhookEvent.fromJson(
            _wire(kind)..['data'] = {'id': ''},
          );
          expect((emptyId.data! as WebhookIdData).id, isEmpty);
        },
      );
    });
  }
}

Map<String, dynamic> _wire(String kind) => {
  'id': 'PRIVATE-event',
  'object': 'event',
  'created_at': 123,
  'type': 'agent.environment.$kind',
  'data': {
    'id': 'PRIVATE-environment',
    'future': {'private': 'PRIVATE'},
  },
};

WebhookEvent _copy(
  WebhookEvent event, {
  WebhookIdData? data,
  String? id,
  int? createdAt,
}) => switch (event) {
  final AgentEnvironmentReadyWebhookEvent value => value.copyWith(
    data: data,
    id: id,
    createdAt: createdAt,
  ),
  final AgentEnvironmentFailedWebhookEvent value => value.copyWith(
    data: data,
    id: id,
    createdAt: createdAt,
  ),
  final AgentEnvironmentSuspendedWebhookEvent value => value.copyWith(
    data: data,
    id: id,
    createdAt: createdAt,
  ),
  final AgentEnvironmentExpiredWebhookEvent value => value.copyWith(
    data: data,
    id: id,
    createdAt: createdAt,
  ),
  _ => throw StateError('Unexpected fixture'),
};
