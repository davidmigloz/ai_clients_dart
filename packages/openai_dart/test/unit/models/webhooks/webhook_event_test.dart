// Table-driven tests exercise the common copy contract of heterogeneous sealed variants.
// ignore_for_file: avoid_dynamic_calls

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

typedef _Parser = WebhookEvent Function(Map<String, dynamic>);

enum _ObjectPresence { required, optional }

class _Fixture {
  final String name;
  final String type;
  final Map<String, dynamic> data;
  final _ObjectPresence objectPresence;
  bool get requiredObject => objectPresence == _ObjectPresence.required;
  final _Parser parser;
  const _Fixture(
    this.name,
    this.type,
    this.data,
    this.objectPresence,
    this.parser,
  );
  Map<String, dynamic> json() => {
    'id': 'evt_sensitive',
    'type': type,
    'created_at': -1,
    if (requiredObject) 'object': 'event',
    'data': Map<String, dynamic>.from(data),
  };
}

final _fixtures = <_Fixture>[
  const _Fixture(
    'AgentSessionActionRequiredWebhookEvent',
    'agent.session.action_required',
    {
      'id': 'session_sensitive',
      'required_action': {'type': 'function_call'},
    },
    _ObjectPresence.required,
    AgentSessionActionRequiredWebhookEvent.fromJson,
  ),
  const _Fixture(
    'AgentSessionCreatedWebhookEvent',
    'agent.session.created',
    {'id': 'session_sensitive', 'environment_type': 'future_environment'},
    _ObjectPresence.required,
    AgentSessionCreatedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'AgentSessionFailedWebhookEvent',
    'agent.session.failed',
    {'id': 'session_sensitive', 'environment_type': 'future_environment'},
    _ObjectPresence.required,
    AgentSessionFailedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'AgentSessionIdleWebhookEvent',
    'agent.session.idle',
    {'id': 'session_sensitive', 'environment_type': 'future_environment'},
    _ObjectPresence.required,
    AgentSessionIdleWebhookEvent.fromJson,
  ),
  const _Fixture(
    'AgentSessionInProgressWebhookEvent',
    'agent.session.in_progress',
    {'id': 'session_sensitive', 'environment_type': 'future_environment'},
    _ObjectPresence.required,
    AgentSessionInProgressWebhookEvent.fromJson,
  ),
  const _Fixture(
    'BatchCancelledWebhookEvent',
    'batch.cancelled',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    BatchCancelledWebhookEvent.fromJson,
  ),
  const _Fixture(
    'BatchCompletedWebhookEvent',
    'batch.completed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    BatchCompletedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'BatchExpiredWebhookEvent',
    'batch.expired',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    BatchExpiredWebhookEvent.fromJson,
  ),
  const _Fixture(
    'BatchFailedWebhookEvent',
    'batch.failed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    BatchFailedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'EvalRunCanceledWebhookEvent',
    'eval.run.canceled',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    EvalRunCanceledWebhookEvent.fromJson,
  ),
  const _Fixture(
    'EvalRunFailedWebhookEvent',
    'eval.run.failed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    EvalRunFailedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'EvalRunSucceededWebhookEvent',
    'eval.run.succeeded',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    EvalRunSucceededWebhookEvent.fromJson,
  ),
  const _Fixture(
    'FineTuningJobCancelledWebhookEvent',
    'fine_tuning.job.cancelled',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    FineTuningJobCancelledWebhookEvent.fromJson,
  ),
  const _Fixture(
    'FineTuningJobFailedWebhookEvent',
    'fine_tuning.job.failed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    FineTuningJobFailedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'FineTuningJobSucceededWebhookEvent',
    'fine_tuning.job.succeeded',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    FineTuningJobSucceededWebhookEvent.fromJson,
  ),
  // ignore: deprecated_member_use_from_same_package
  const _Fixture(
    'LiveCallIncomingWebhookEvent',
    'live.call.incoming',
    {
      'session_id': 'pending_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive_sip'},
        {'name': 'From', 'value': 'second_sensitive_sip'},
      ],
      'sip_media_security': 'future_media',
    },
    _ObjectPresence.optional,
    LiveCallIncomingWebhookEvent.fromJson,
  ),
  const _Fixture(
    'LiveTransportIncomingWebhookEvent',
    'live.transport.incoming',
    {
      'session_id': 'pending_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive_sip'},
        {'name': 'From', 'value': 'second_sensitive_sip'},
      ],
      'sip_media_security': 'future_media',
      'type': 'sip',
    },
    _ObjectPresence.optional,
    LiveTransportIncomingWebhookEvent.fromJson,
  ),
  const _Fixture(
    'RealtimeCallIncomingWebhookEvent',
    'realtime.call.incoming',
    {
      'call_id': 'pending_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive_sip'},
        {'name': 'From', 'value': 'second_sensitive_sip'},
      ],
      'sip_media_security': 'future_media',
    },
    _ObjectPresence.optional,
    RealtimeCallIncomingWebhookEvent.fromJson,
  ),
  const _Fixture(
    'ResponseCancelledWebhookEvent',
    'response.cancelled',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    ResponseCancelledWebhookEvent.fromJson,
  ),
  const _Fixture(
    'ResponseCompletedWebhookEvent',
    'response.completed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    ResponseCompletedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'ResponseFailedWebhookEvent',
    'response.failed',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    ResponseFailedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'ResponseIncompleteWebhookEvent',
    'response.incomplete',
    {'id': 'affected_sensitive'},
    _ObjectPresence.optional,
    ResponseIncompleteWebhookEvent.fromJson,
  ),
  const _Fixture(
    'SafetyAlertCreatedWebhookEvent',
    'safety.alert.created',
    {'id': 'alert_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'},
    _ObjectPresence.required,
    SafetyAlertCreatedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'SafetyDeactivationIssuedWebhookEvent',
    'safety.deactivation_issued',
    {'id': 'affected_sensitive'},
    _ObjectPresence.required,
    SafetyDeactivationIssuedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'SafetyOrgAlertCreatedWebhookEvent',
    'safety.org_alert.created',
    {'id': 'alert_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'},
    _ObjectPresence.required,
    SafetyOrgAlertCreatedWebhookEvent.fromJson,
  ),
  const _Fixture(
    'SafetyWarningIssuedWebhookEvent',
    'safety.warning_issued',
    {'id': 'affected_sensitive'},
    _ObjectPresence.required,
    SafetyWarningIssuedWebhookEvent.fromJson,
  ),
];

Matcher _context(String field) => throwsA(
  isA<FormatException>().having((e) => e.message, 'context', contains(field)),
);

void main() {
  for (final fixture in _fixtures) {
    group(fixture.name, () {
      test('dispatch, round trip, delivery/resource roles', () {
        final event = WebhookEvent.fromJson(fixture.json());
        expect(event.runtimeType.toString(), fixture.name);
        expect(event.id, 'evt_sensitive');
        expect(event.createdAt, -1);
        expect(event.type, fixture.type);
        expect(event.toJson(), fixture.json());
        expect(event, fixture.parser(fixture.json()));
        expect(event.hashCode, fixture.parser(fixture.json()).hashCode);
        expect(event.toString(), isNot(contains('sensitive')));
        expect(event.toString(), isNot(contains('aaaaaaaa')));
      });
      test('deep immutable ownership and future metadata', () {
        final future = <String, dynamic>{
          'nested': <Object?>[
            <String, dynamic>{'secret': 'future_sensitive'},
          ],
        };
        final data = <String, dynamic>{...fixture.data, 'future': future};
        final source = <String, dynamic>{
          ...fixture.json(),
          'data': data,
          'future': future,
        };
        final event = fixture.parser(source);
        final wire = event.toJson();
        future['nested'] = 'mutated';
        data['future'] = 'mutated';
        source['future'] = 'mutated';
        expect(event.toJson(), wire);
        expect(() => event.rawJson['future'] = false, throwsUnsupportedError);
        expect(
          () =>
              (event.rawJson['data'] as Map<String, dynamic>)['future'] = false,
          throwsUnsupportedError,
        );
        final nested =
            (event.rawJson['future'] as Map<String, dynamic>)['nested']
                as List<Object?>;
        expect(() => nested.add(null), throwsUnsupportedError);
        expect(
          () => (nested.first! as Map<String, dynamic>)['secret'] = false,
          throwsUnsupportedError,
        );
        expect(event.toString(), isNot(contains('future_sensitive')));
        expect(event.data.toString(), isNot(contains('future_sensitive')));
      });
      for (final field in ['id', 'created_at', 'type', 'data']) {
        test('required $field missing', () {
          expect(
            () => fixture.parser(fixture.json()..remove(field)),
            _context(field),
          );
        });
        for (final invalid in <Object?>[null, true, <Object?>[], 1.5]) {
          test('required $field rejects $invalid', () {
            expect(
              () => fixture.parser({...fixture.json(), field: invalid}),
              _context(field),
            );
          });
        }
      }
      test('exact known discriminator', () {
        expect(
          () => fixture.parser({...fixture.json(), 'type': 'future.type'}),
          _context('type'),
        );
      });
      test('exact optional/required envelope object', () {
        final source = fixture.json();
        if (fixture.requiredObject) {
          expect(
            () => fixture.parser(source..remove('object')),
            _context('object'),
          );
        } else {
          expect(fixture.parser(source).object, null);
          expect(fixture.parser(source).toJson().containsKey('object'), false);
        }
        for (final value in <Object?>[null, false, 'wrong', 3, <Object?>[]]) {
          expect(
            () => fixture.parser({...fixture.json(), 'object': value}),
            _context('object'),
          );
        }
        final present = fixture.parser({...fixture.json(), 'object': 'event'});
        expect(present.object, 'event');
        expect(present.toJson()['object'], 'event');
        if (!fixture.requiredObject) {
          final dynamic copied = present;
          final omitted = copied.copyWith(object: null) as WebhookEvent;
          expect(omitted.object, null);
          expect(omitted.toJson().containsKey('object'), false);
          expect(() => copied.copyWith(object: 'wrong'), _context('object'));
          expect(present == omitted, false);
        }
      });
      test('complete scalar/data/raw copy and effective equality/hash', () {
        final dynamic original = fixture.parser({
          ...fixture.json(),
          'future': {'secret': 'hidden'},
        });
        final same = original.copyWith() as WebhookEvent;
        expect(same, original);
        expect(same.hashCode, original.hashCode);
        final changedId = original.copyWith(id: 'evt_changed') as WebhookEvent;
        expect(changedId.id, 'evt_changed');
        expect(changedId == original, false);
        final changedTime = original.copyWith(createdAt: 2) as WebhookEvent;
        expect(changedTime.createdAt, 2);
        expect(changedTime == original, false);
        final rawClear =
            original.copyWith(rawJson: <String, dynamic>{}) as WebhookEvent;
        expect(rawClear.toJson().containsKey('future'), false);
        expect(rawClear == original, false);
        final changedData =
            original.copyWith(
                  data: fixture.parser({
                    ...fixture.json(),
                    'data': {...fixture.data, 'future': true},
                  }).data,
                )
                as WebhookEvent;
        expect(
          (changedData.toJson()['data'] as Map<String, dynamic>)['future'],
          true,
        );
        expect(changedData == original, false);
        final WebhookEvent reconstructed = fixture.parser(
          original.toJson() as Map<String, dynamic>,
        );
        expect(reconstructed, original);
        expect(reconstructed.hashCode, original.hashCode);
        expect(
          <WebhookEvent>{same, reconstructed, original as WebhookEvent}.length,
          1,
        );
      });
      test(
        'child metadata clear/full replacement never resurrects parent raw',
        () {
          final dynamic event = fixture.parser({
            ...fixture.json(),
            'data': {
              ...fixture.data,
              'future': {'secret': 'hidden'},
            },
          });
          final dynamic child = event.data;
          final clear =
              event.copyWith(data: child.copyWith(rawJson: <String, dynamic>{}))
                  as WebhookEvent;
          expect(
            (clear.toJson()['data'] as Map<String, dynamic>).containsKey(
              'future',
            ),
            false,
          );
          final fresh = fixture.parser(fixture.json()).data;
          final replacement = event.copyWith(data: fresh) as WebhookEvent;
          expect(replacement.toJson(), fixture.json());
          final source = <String, dynamic>{
            'future': {
              'nested': <Object?>['secret'],
            },
            'data': {'future': 'stale'},
          };
          final dynamic direct = event.copyWith(data: fresh, rawJson: source);
          expect(
            (direct.toJson()['data'] as Map<String, dynamic>).containsKey(
              'future',
            ),
            false,
          );
          source['future'] = 'mutated';
          expect((direct.toJson() as Map<String, dynamic>)['future'], {
            'nested': ['secret'],
          });
        },
      );
      test('nonfinite/invalid future values redact diagnostics', () {
        for (final value in <Object?>[
          double.nan,
          double.infinity,
          double.negativeInfinity,
          Object(),
          <Object?, Object?>{1: 'sensitive_key'},
        ]) {
          try {
            fixture.parser({...fixture.json(), 'sensitive_key': value});
            fail('must reject non-JSON');
          } on FormatException catch (e) {
            expect(e.message, isNot(contains('sensitive_key')));
            expect(e.source, null);
          }
        }
        final cycle = <Object?>[];
        cycle.add(cycle);
        expect(
          () => fixture.parser({...fixture.json(), 'future': cycle}),
          _context('JSON'),
        );
      });
    });
  }
  for (final fixture in _payloadFixtures) {
    group(fixture.name, () {
      test('payload finite round trip, equality, hash and raw ownership', () {
        final raw = <String, dynamic>{
          'nested': <Object?>[
            <String, dynamic>{'secret': 'opaque_sensitive'},
          ],
        };
        final dynamic value = fixture.parser({...fixture.json, 'future': raw});
        final wire = value.toJson() as Map<String, dynamic>;
        raw['nested'] = 'mutated';
        expect(value.toJson(), wire);
        expect(
          () => (value.rawJson as Map<String, dynamic>)['future'] = true,
          throwsUnsupportedError,
        );
        final dynamic same = fixture.parser(wire);
        expect(value, same);
        expect(value.hashCode, same.hashCode);
        expect(value.copyWith(), value);
        final dynamic cleared = value.copyWith(rawJson: <String, dynamic>{});
        expect(
          (cleared.toJson() as Map<String, dynamic>).containsKey('future'),
          false,
        );
        expect(cleared == value, false);
        expect(value.toString(), isNot(contains('sensitive')));
        expect(value.toString(), isNot(contains('aaaaaaaa')));
      });
      for (final field in fixture.requiredFields) {
        test('required payload $field missing/null', () {
          final missing = <String, dynamic>{...fixture.json}..remove(field);
          expect(
            () => fixture.parser(missing),
            throwsA(isA<FormatException>()),
          );
          expect(
            () => fixture.parser({...fixture.json, field: null}),
            throwsA(isA<FormatException>()),
          );
        });
      }
      for (final field in fixture.requiredFields) {
        final example = fixture.json[field];
        final invalid = example is String
            ? <Object?>[true, 3, <Object?>[], <String, dynamic>{}]
            : example is List<dynamic>
            ? <Object?>[true, 3, 'wrong', <String, dynamic>{}]
            : <Object?>[true, 3, 'wrong', <Object?>[]];
        for (final value in invalid) {
          test('required payload $field wrong type $value', () {
            expect(
              () => fixture.parser({...fixture.json, field: value}),
              throwsA(isA<FormatException>()),
            );
          });
        }
        if (example is List<dynamic>) {
          test('required payload $field accepts empty list', () {
            final dynamic value = fixture.parser({
              ...fixture.json,
              field: <Object?>[],
            });
            expect((value.toJson() as Map<String, dynamic>)[field], isEmpty);
          });
        } else if (example is String &&
            field != 'type' &&
            fixture.name != 'WebhookSafetyAlertData') {
          test('required payload $field accepts empty string', () {
            final dynamic value = fixture.parser({...fixture.json, field: ''});
            expect((value.toJson() as Map<String, dynamic>)[field], '');
          });
        }
      }
      for (final field in fixture.optionalFields) {
        test('optional payload $field omitted/non-null', () {
          final absent = <String, dynamic>{...fixture.json}..remove(field);
          final dynamic value = fixture.parser(absent);
          expect(
            (value.toJson() as Map<String, dynamic>).containsKey(field),
            false,
          );
          expect(
            () => fixture.parser({...fixture.json, field: null}),
            throwsA(isA<FormatException>()),
          );
        });
      }
      for (final field in fixture.changes.keys) {
        test('all-field effective equality/hash: $field', () {
          final dynamic value = fixture.parser(fixture.json);
          final dynamic changed = fixture.parser({
            ...fixture.json,
            field: fixture.changes[field],
          });
          expect(value == changed, false);
          final dynamic reconstructed = fixture.parser(
            changed.toJson() as Map<String, dynamic>,
          );
          expect(changed, reconstructed);
          expect(changed.hashCode, reconstructed.hashCode);
        });
      }
    });
  }
  group('nested payload copy semantics', () {
    test('Agent scalar/optional/complete nested replacements', () {
      final raw = <String, dynamic>{
        'id': 'session_sensitive',
        'environment_type': 'future_environment',
        'environment_id': 'environment_sensitive',
        'connect': {'remote_url': 'url_sensitive', 'future': true},
        'future': true,
      };
      final value = AgentSessionCreatedPayloadResource.fromJson(raw);
      expect(value.copyWith(id: 'changed').id, 'changed');
      expect(value.copyWith(environmentType: 'other').environmentType, 'other');
      expect(value.copyWith(environmentId: 'changed').environmentId, 'changed');
      expect(
        value
            .copyWith(environmentId: null)
            .toJson()
            .containsKey('environment_id'),
        false,
      );
      expect(
        value.copyWith(connect: null).toJson().containsKey('connect'),
        false,
      );
      expect(
        value
            .copyWith(connect: value.connect!.copyWith(rawJson: {}))
            .toJson()['connect'],
        {'remote_url': 'url_sensitive'},
      );
      expect(
        value
            .copyWith(
              connect: AgentSessionConnectPayloadResource(
                remoteUrl: 'url_sensitive',
              ),
            )
            .toJson()['connect'],
        {'remote_url': 'url_sensitive'},
      );
      expect(
        value
            .copyWith(connect: value.connect!.copyWith(remoteUrl: 'changed'))
            .toJson()['connect'],
        {'remote_url': 'changed', 'future': true},
      );
      expect(
        value
            .copyWith(
              connect: AgentSessionConnectPayloadResource(remoteUrl: 'new'),
              rawJson: {
                'connect': {'future': 'stale'},
              },
            )
            .toJson()['connect'],
        {'remote_url': 'new'},
      );
      final direct = AgentSessionCreatedPayloadResource(
        id: 'session_sensitive',
        environmentType: 'future_environment',
        connect: AgentSessionConnectPayloadResource(remoteUrl: 'new'),
        rawJson: raw,
      );
      expect(direct.toJson().containsKey('environment_id'), false);
      expect(direct.toJson()['connect'], {'remote_url': 'new'});
      expect(
        value.connect!.copyWith(remoteUrl: 'changed').remoteUrl,
        'changed',
      );
    });
    test('Agent environment optional clear and raw override', () {
      final value = AgentSessionEnvironmentPayloadResource.fromJson(const {
        'id': 'id',
        'environment_type': 'future',
        'environment_id': 'old',
        'future': true,
      });
      expect(value.copyWith(id: 'new').id, 'new');
      expect(value.copyWith(environmentType: 'new').environmentType, 'new');
      expect(value.copyWith(environmentId: 'new').environmentId, 'new');
      expect(value.copyWith(environmentId: null).toJson(), {
        'id': 'id',
        'environment_type': 'future',
        'future': true,
      });
    });
    test('required action nested future clear/fresh replacement', () {
      final value = AgentSessionActionRequiredPayloadResource.fromJson(const {
        'id': 'id',
        'required_action': {'type': 'function_call', 'future': true},
        'future': true,
      });
      expect(value.copyWith(id: 'new').id, 'new');
      expect(
        value
            .copyWith(
              requiredAction: value.requiredAction.copyWith(rawJson: {}),
            )
            .toJson()['required_action'],
        {'type': 'function_call'},
      );
      expect(
        value
            .copyWith(
              requiredAction: AgentSessionRequiredActionPayloadResource(
                type: AgentSessionRequiredActionTypeResource.functionCall,
              ),
            )
            .toJson()['required_action'],
        {'type': 'function_call'},
      );
      expect(
        value.requiredAction
            .copyWith(
              type:
                  AgentSessionRequiredActionTypeResource.environmentConnection,
            )
            .toJson(),
        {'type': 'environment_connection', 'future': true},
      );
      expect(
        AgentSessionActionRequiredPayloadResource(
          id: 'new',
          requiredAction: AgentSessionRequiredActionPayloadResource(
            type: AgentSessionRequiredActionTypeResource.functionCall,
          ),
          rawJson: const {
            'required_action': {'future': 'stale'},
          },
        ).toJson()['required_action'],
        {'type': 'function_call'},
      );
    });
    test('SIP order/repetition/full list replacement/clear', () {
      final rawHeaders = <WebhookSipHeader>[
        WebhookSipHeader.fromJson(const {
          'name': 'From',
          'value': 'first_sensitive',
          'future': 'first',
        }),
        WebhookSipHeader.fromJson(const {
          'name': 'From',
          'value': 'second_sensitive',
          'future': 'second',
        }),
      ];
      final live = LiveTransportIncomingWebhookData(
        sessionId: 'live_sensitive',
        sipHeaders: rawHeaders,
        sipMediaSecurity: 'future_media',
        rawJson: const {
          'sip_headers': [
            {'future': 'stale'},
            {'future': 'stale'},
          ],
          'sip_media_security': 'stale',
        },
      );
      rawHeaders.clear();
      expect(live.sipHeaders.length, 2);
      expect(
        () => live.sipHeaders.add(WebhookSipHeader(name: 'To', value: 'new')),
        throwsUnsupportedError,
      );
      expect(live.sipHeaders.map((e) => e.value), [
        'first_sensitive',
        'second_sensitive',
      ]);
      expect(live.copyWith(sessionId: 'new').sessionId, 'new');
      expect(
        live.copyWith(sipMediaSecurity: 'other').sipMediaSecurity,
        'other',
      );
      expect(
        live
            .copyWith(sipMediaSecurity: null)
            .toJson()
            .containsKey('sip_media_security'),
        false,
      );
      final reverse = live.copyWith(
        sipHeaders: live.sipHeaders.reversed.toList(),
      );
      expect(reverse.toJson()['sip_headers'], [
        {'name': 'From', 'value': 'second_sensitive', 'future': 'second'},
        {'name': 'From', 'value': 'first_sensitive', 'future': 'first'},
      ]);
      expect(
        live
            .copyWith(
              sipHeaders: [WebhookSipHeader(name: 'From', value: 'fresh')],
            )
            .toJson()['sip_headers'],
        [
          {'name': 'From', 'value': 'fresh'},
        ],
      );
      expect(live.copyWith(sipHeaders: []).toJson()['sip_headers'], isEmpty);
      final realtime = RealtimeCallIncomingWebhookData(
        callId: 'rtc_sensitive',
        sipHeaders: live.sipHeaders,
        sipMediaSecurity: 'future',
      );
      expect(realtime.copyWith(callId: 'new').callId, 'new');
      expect(realtime.copyWith(sipHeaders: []).sipHeaders, isEmpty);
      expect(
        realtime.copyWith(sipMediaSecurity: 'new').sipMediaSecurity,
        'new',
      );
      expect(
        realtime
            .copyWith(sipMediaSecurity: null)
            .toJson()
            .containsKey('sip_media_security'),
        false,
      );
      final alias = LiveCallIncomingWebhookData(
        sessionId: 'live_sensitive',
        sipHeaders: live.sipHeaders,
        sipMediaSecurity: 'future',
      );
      expect(alias.copyWith(sessionId: 'new').sessionId, 'new');
      expect(alias.copyWith(sipHeaders: []).sipHeaders, isEmpty);
      expect(alias.copyWith(sipMediaSecurity: 'new').sipMediaSecurity, 'new');
      expect(
        alias
            .copyWith(sipMediaSecurity: null)
            .toJson()
            .containsKey('sip_media_security'),
        false,
      );
      final header = live.sipHeaders.first;
      expect(header.copyWith(name: 'To').name, 'To');
      expect(header.copyWith(value: 'new').value, 'new');
      expect(header.copyWith(rawJson: {}).toJson(), {
        'name': 'From',
        'value': 'first_sensitive',
      });
    });
  });
  group('closed actions/transport/alert tokens', () {
    for (final value in AgentSessionRequiredActionTypeResource.values) {
      test('action ${value.value}', () {
        expect(
          AgentSessionRequiredActionTypeResource.fromJson(value.toJson()),
          value,
        );
        expect(
          AgentSessionRequiredActionPayloadResource(type: value).toJson(),
          {'type': value.value},
        );
      });
    }
    for (final value in <Object?>[
      null,
      3,
      false,
      'unknown',
      'function_call\n',
      'FUNCTION_CALL',
    ]) {
      test(
        'invalid closed action $value',
        () => expect(
          () => AgentSessionRequiredActionTypeResource.fromJson(value),
          throwsA(isA<FormatException>()),
        ),
      );
    }
    for (final value in <Object?>[null, 3, false, 'wrong', 'sip\n']) {
      test(
        'invalid transport type $value',
        () => expect(
          () => LiveTransportIncomingWebhookData.fromJson({
            'type': value,
            'session_id': 'id',
            'sip_headers': const <Object?>[],
          }),
          _context('type'),
        ),
      );
    }
    for (final value in [
      'alert_${'a' * 32}\n',
      'alert_${'a' * 32}\r',
      'alert_${'A' * 32}',
      'alert_${'g' * 32}',
      'alert_${'a' * 31}',
      'alert_${'a' * 33}',
      'prefix_alert_${'a' * 32}',
    ]) {
      test('exact alert token rejects ${value.length}', () {
        expect(
          () => WebhookSafetyAlertData.fromJson({'id': value}),
          _context('id'),
        );
        expect(() => WebhookSafetyAlertData(id: value), _context('id'));
      });
    }
    test('alert copy/valid all hex and case IDs have no invented pattern', () {
      final value = WebhookSafetyAlertData(id: 'alert_${'a' * 32}');
      expect(value.copyWith(id: 'alert_${'0' * 32}').id, 'alert_${'0' * 32}');
      expect(WebhookIdData(id: '').copyWith(id: 'case\n').id, 'case\n');
    });
  });
  group('malformed nested known payloads', () {
    for (final value in <Object?>[
      true,
      3,
      1.5,
      <Object?>[],
      <String, dynamic>{},
    ]) {
      for (final field in ['id', 'environment_type', 'environment_id']) {
        test('Agent $field rejects wrong shape $value', () {
          expect(
            () => AgentSessionCreatedPayloadResource.fromJson({
              'id': 'id',
              'environment_type': 'future',
              field: value,
            }),
            throwsA(isA<FormatException>()),
          );
          expect(
            () => AgentSessionEnvironmentPayloadResource.fromJson({
              'id': 'id',
              'environment_type': 'future',
              field: value,
            }),
            throwsA(isA<FormatException>()),
          );
        });
      }
      test('Agent nested connect rejects wrong shape $value', () {
        expect(
          () => AgentSessionCreatedPayloadResource.fromJson({
            'id': 'id',
            'environment_type': 'future',
            'connect': value,
          }),
          throwsA(isA<FormatException>()),
        );
      });
      test('Agent required_action rejects wrong shape $value', () {
        expect(
          () => AgentSessionActionRequiredPayloadResource.fromJson({
            'id': 'id',
            'required_action': value,
          }),
          throwsA(isA<FormatException>()),
        );
      });
      test('SIP media security rejects wrong shape $value', () {
        expect(
          () => RealtimeCallIncomingWebhookData.fromJson({
            'call_id': 'id',
            'sip_headers': const <Object?>[],
            'sip_media_security': value,
          }),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => LiveCallIncomingWebhookData.fromJson({
            'session_id': 'id',
            'sip_headers': const <Object?>[],
            'sip_media_security': value,
          }),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => LiveTransportIncomingWebhookData.fromJson({
            'type': 'sip',
            'session_id': 'id',
            'sip_headers': const <Object?>[],
            'sip_media_security': value,
          }),
          throwsA(isA<FormatException>()),
        );
      });
    }
    for (final value in <Object?>[
      null,
      true,
      3,
      'wrong',
      <Object?>[],
      <String, dynamic>{},
      <String, dynamic>{'name': 'From'},
      <String, dynamic>{'value': 'hidden'},
      <String, dynamic>{'name': false, 'value': 'hidden'},
      <String, dynamic>{'name': 'From', 'value': false},
    ]) {
      test('SIP header requires both strings $value', () {
        expect(
          () => RealtimeCallIncomingWebhookData.fromJson({
            'call_id': 'id',
            'sip_headers': [value],
          }),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => LiveCallIncomingWebhookData.fromJson({
            'session_id': 'id',
            'sip_headers': [value],
          }),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => LiveTransportIncomingWebhookData.fromJson({
            'type': 'sip',
            'session_id': 'id',
            'sip_headers': [value],
          }),
          throwsA(isA<FormatException>()),
        );
      });
    }
    for (final value in <Object?>[
      null,
      true,
      3,
      'wrong',
      <String, dynamic>{},
    ]) {
      test(
        'SIP header list required $value',
        () => expect(
          () => RealtimeCallIncomingWebhookData.fromJson({
            'call_id': 'id',
            'sip_headers': value,
          }),
          throwsA(isA<FormatException>()),
        ),
      );
    }
    test(
      'direct finite raw constructor boundary for helpers and known envelopes',
      () {
        expect(
          () => WebhookIdData(
            id: 'id',
            rawJson: const {'hidden': double.infinity},
          ),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => AgentSessionConnectPayloadResource(
            remoteUrl: 'url',
            rawJson: const {'hidden': Object()},
          ),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => ResponseCompletedWebhookEvent(
            id: 'id',
            createdAt: 1,
            data: WebhookIdData(id: 'resource'),
            rawJson: const {'hidden': double.nan},
          ),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => UnknownWebhookEvent(
            rawJson: const {'type': 'future', 'hidden': double.nan},
          ),
          throwsA(isA<FormatException>()),
        );
        final raw = <String, dynamic>{
          'id': 'stale',
          'created_at': 5,
          'type': 'wrong',
          'object': false,
          'data': {'id': 'stale', 'future': true},
          'future': {
            'child': ['hidden'],
          },
        };
        final value = ResponseCompletedWebhookEvent(
          id: 'delivery',
          createdAt: -1,
          data: WebhookIdData(id: 'resource'),
          rawJson: raw,
        );
        raw['future'] = false;
        expect(value.toJson(), {
          'id': 'delivery',
          'created_at': -1,
          'type': 'response.completed',
          'data': {'id': 'resource'},
          'future': {
            'child': ['hidden'],
          },
        });
        expect(value, WebhookEvent.fromJson(value.toJson()));
        expect(value.hashCode, WebhookEvent.fromJson(value.toJson()).hashCode);
        expect(value.toString(), isNot(contains('hidden')));
        expect(
          WebhookIdData(id: 'resource', rawJson: const {'id': 'stale'}),
          WebhookIdData(id: 'resource'),
        );
        expect(
          WebhookIdData(
            id: 'resource',
            rawJson: const {'id': 'stale'},
          ).hashCode,
          WebhookIdData(id: 'resource').hashCode,
        );
      },
    );
  });
  group('unknown received events', () {
    for (final type in [
      'video.completed',
      'video.failed',
      'safety_identifier.blocked',
      'future_sensitive_type',
    ]) {
      for (final data in <Object?>[
        null,
        false,
        4,
        2.5,
        'raw_sensitive',
        <Object?>[
          false,
          {'sensitive': true},
        ],
        <String, dynamic>{'id': 5},
      ]) {
        test('$type retains arbitrary finite future shape $data', () {
          final raw = <String, dynamic>{
            'type': type,
            'id': 4,
            'object': false,
            'created_at': 'future',
            'data': data,
            'extra': {
              'nested': [null, true],
            },
          };
          final event = WebhookEvent.fromJson(raw) as UnknownWebhookEvent;
          expect(event.toJson(), raw);
          expect(event.id, null);
          expect(event.createdAt, null);
          expect(event.object, null);
          expect(event, UnknownWebhookEvent.fromJson(raw));
          expect(event.hashCode, UnknownWebhookEvent.fromJson(raw).hashCode);
          expect(event.toString(), isNot(contains('sensitive')));
          expect(() => event.rawJson['data'] = false, throwsUnsupportedError);
          expect(event.copyWith(), event);
          final changed = event.copyWith(
            type: 'future.changed',
            id: 'id',
            createdAt: -5,
            object: 'arbitrary',
            data: {'changed': true},
          );
          expect(changed.type, 'future.changed');
          expect(changed.id, 'id');
          expect(changed.createdAt, -5);
          expect(changed.object, 'arbitrary');
          expect(changed.data, {'changed': true});
          expect(changed == event, false);
          expect(event.copyWith(data: null).toJson().containsKey('data'), true);
          expect(
            event.copyWith(removeKeys: {'data'}).toJson().containsKey('data'),
            false,
          );
          expect(event.copyWith(rawJson: {'type': 'other'}).toJson(), {
            'type': 'other',
          });
        });
      }
    }
    test('deep direct ownership + missing future envelope fields', () {
      final raw = <String, dynamic>{
        'type': 'future',
        'data': <Object?>[
          <String, dynamic>{'secret': 'hidden'},
        ],
      };
      final event = UnknownWebhookEvent(rawJson: raw);
      (raw['data'] as List<Object?>).clear();
      raw['type'] = 'mutated';
      expect(event.toJson(), {
        'type': 'future',
        'data': [
          {'secret': 'hidden'},
        ],
      });
      expect(
        () => (event.data! as List<Object?>).add(false),
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((event.data! as List<Object?>).first!
                    as Map<String, dynamic>)['secret'] =
                false,
        throwsUnsupportedError,
      );
      expect(WebhookEvent.fromJson(const {'type': 'future'}).toJson(), {
        'type': 'future',
      });
    });
    for (final value in <Object?>[null, 3, false, [], {}]) {
      test(
        'parent requires string type $value',
        () => expect(
          () => WebhookEvent.fromJson({'type': value}),
          _context('type'),
        ),
      );
    }
  });
}

class _PayloadFixture {
  final String name;
  final Map<String, dynamic> json;
  final dynamic Function(Map<String, dynamic>) parser;
  final List<String> requiredFields;
  final List<String> optionalFields;
  final Map<String, dynamic> changes;
  const _PayloadFixture(
    this.name,
    this.json,
    this.parser,
    this.requiredFields,
    this.optionalFields,
    this.changes,
  );
}

final _payloadFixtures = <_PayloadFixture>[
  const _PayloadFixture(
    'WebhookIdData',
    {'id': 'id_sensitive'},
    WebhookIdData.fromJson,
    ['id'],
    [],
    {'id': 'changed'},
  ),
  _PayloadFixture(
    'WebhookSafetyAlertData',
    {'id': 'alert_${'a' * 32}'},
    WebhookSafetyAlertData.fromJson,
    ['id'],
    [],
    {'id': 'alert_${'0' * 32}'},
  ),
  const _PayloadFixture(
    'WebhookSipHeader',
    {'name': 'name_sensitive', 'value': 'value_sensitive'},
    WebhookSipHeader.fromJson,
    ['name', 'value'],
    [],
    {'name': 'changed', 'value': 'changed'},
  ),
  const _PayloadFixture(
    'AgentSessionConnectPayloadResource',
    {'remote_url': 'url_sensitive'},
    AgentSessionConnectPayloadResource.fromJson,
    ['remote_url'],
    [],
    {'remote_url': 'changed'},
  ),
  const _PayloadFixture(
    'AgentSessionRequiredActionPayloadResource',
    {'type': 'function_call'},
    AgentSessionRequiredActionPayloadResource.fromJson,
    ['type'],
    [],
    {'type': 'environment_connection'},
  ),
  const _PayloadFixture(
    'AgentSessionActionRequiredPayloadResource',
    {
      'id': 'id_sensitive',
      'required_action': {'type': 'function_call'},
    },
    AgentSessionActionRequiredPayloadResource.fromJson,
    ['id', 'required_action'],
    [],
    {
      'id': 'changed',
      'required_action': {'type': 'environment_connection'},
    },
  ),
  const _PayloadFixture(
    'AgentSessionCreatedPayloadResource',
    {
      'id': 'id_sensitive',
      'environment_type': 'future',
      'environment_id': 'env_sensitive',
      'connect': {'remote_url': 'url_sensitive'},
    },
    AgentSessionCreatedPayloadResource.fromJson,
    ['id', 'environment_type'],
    ['environment_id', 'connect'],
    {
      'id': 'changed',
      'environment_type': 'changed',
      'environment_id': 'changed',
      'connect': {'remote_url': 'changed'},
    },
  ),
  const _PayloadFixture(
    'AgentSessionEnvironmentPayloadResource',
    {
      'id': 'id_sensitive',
      'environment_type': 'future',
      'environment_id': 'env_sensitive',
    },
    AgentSessionEnvironmentPayloadResource.fromJson,
    ['id', 'environment_type'],
    ['environment_id'],
    {
      'id': 'changed',
      'environment_type': 'changed',
      'environment_id': 'changed',
    },
  ),
  const _PayloadFixture(
    'LiveCallIncomingWebhookData',
    {
      'session_id': 'live_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive'},
      ],
      'sip_media_security': 'future',
    },
    LiveCallIncomingWebhookData.fromJson,
    ['session_id', 'sip_headers'],
    ['sip_media_security'],
    {
      'session_id': 'changed',
      'sip_headers': <Object?>[],
      'sip_media_security': 'changed',
    },
  ),
  const _PayloadFixture(
    'LiveTransportIncomingWebhookData',
    {
      'type': 'sip',
      'session_id': 'live_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive'},
      ],
      'sip_media_security': 'future',
    },
    LiveTransportIncomingWebhookData.fromJson,
    ['type', 'session_id', 'sip_headers'],
    ['sip_media_security'],
    {
      'session_id': 'changed',
      'sip_headers': <Object?>[],
      'sip_media_security': 'changed',
    },
  ),
  const _PayloadFixture(
    'RealtimeCallIncomingWebhookData',
    {
      'call_id': 'rtc_sensitive',
      'sip_headers': [
        {'name': 'From', 'value': 'sensitive'},
      ],
      'sip_media_security': 'future',
    },
    RealtimeCallIncomingWebhookData.fromJson,
    ['call_id', 'sip_headers'],
    ['sip_media_security'],
    {
      'call_id': 'changed',
      'sip_headers': <Object?>[],
      'sip_media_security': 'changed',
    },
  ),
];
