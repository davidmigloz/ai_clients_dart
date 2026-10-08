import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE café 🚀';

void main() {
  final cases = <_Case>[
    _Case(
      'offer',
      LiveWebRTCTransport.fromJson,
      {'type': 'webrtc', 'sdp': _private},
      const ['type', 'sdp'],
    ),
    _Case(
      'auth',
      LiveSIPTrunkAuth.fromJson,
      {'type': 'digest', 'username': _private, 'password': _private},
      const ['type', 'username', 'password'],
    ),
    _Case('trunk', LiveSIPTrunk.fromJson, _trunk(), const [
      'provider_url',
      'auth',
      'caller_number',
    ]),
    _Case('sip request', LiveSIPTransport.fromJson, _sip(), const [
      'type',
      'destination',
      'trunk',
    ]),
    _Case(
      'create webrtc',
      LiveSessionCreateRequest.fromJson,
      {
        'session': {'model': _private},
        'transport': {'type': 'webrtc', 'sdp': _private},
      },
      const ['session', 'transport'],
    ),
    _Case(
      'create sip',
      LiveSessionCreateRequest.fromJson,
      {
        'session': {'model': _private},
        'transport': _sip(),
      },
      const ['session', 'transport'],
    ),
    _Case(
      'accept',
      LiveCallAcceptRequest.fromJson,
      {
        'session': {'type': 'live', 'model': _private},
      },
      const ['session'],
    ),
    _Case(
      'reject',
      LiveCallRejectRequest.fromJson,
      {'status_code': 486},
      const ['status_code'],
    ),
    _Case(
      'refer',
      LiveCallReferRequest.fromJson,
      {'target_uri': 'sip:PRIVATE@example.com'},
      const ['target_uri'],
    ),
    _Case(
      'fork omitted',
      LiveForkRequest.fromJson,
      {
        'transport': {'type': 'webrtc', 'sdp': _private},
      },
      const ['transport'],
    ),
    _Case(
      'fork empty',
      LiveForkRequest.fromJson,
      {
        'session': <String, dynamic>{},
        'transport': {'type': 'webrtc', 'sdp': _private},
      },
      const ['transport'],
    ),
    _Case(
      'answer',
      LiveWebRTCResponseTransport.fromJson,
      {'type': 'webrtc', 'sdp': _private},
      const ['type', 'sdp'],
      received: true,
    ),
    _Case(
      'sip result',
      LiveSIPResponseTransport.fromJson,
      {'type': 'sip'},
      const ['type'],
      received: true,
    ),
    _Case(
      'created id',
      LiveCreatedSession.fromJson,
      {'id': _private},
      const ['id'],
      received: true,
    ),
    _Case(
      'create webrtc result',
      LiveSessionCreateResponse.fromJson,
      _result('webrtc'),
      const ['session', 'transport'],
      received: true,
    ),
    _Case(
      'create sip result',
      LiveSessionCreateResponse.fromJson,
      _result('sip'),
      const ['session', 'transport'],
      received: true,
    ),
    _Case('fork result', LiveCreateResponse.fromJson, _result('webrtc'), const [
      'session',
      'transport',
    ], received: true),
    _Case(
      'future transport',
      UnknownLiveResponseTransport.fromJson,
      {
        'type': 'PRIVATE-future',
        'PRIVATE-key': {
          'secret': [_private],
        },
      },
      const ['type'],
      received: true,
    ),
  ];

  group('Live HTTP public model wire and value contracts', () {
    for (final c in cases) {
      test(
        '${c.name} complete round trip, equality/hash and private diagnostics',
        () {
          final parsed = c.parse(c.json);
          expect(parsed.toJson(), c.json);
          final copiedWire = c.parse(parsed.toJson() as Map<String, dynamic>);
          expect(parsed, copiedWire);
          expect(parsed.hashCode, copiedWire.hashCode);
          expect(parsed.toString(), contains('REDACTED'));
          expect(parsed.toString(), isNot(contains('PRIVATE')));
        },
      );
      for (final field in c.required) {
        for (final malformed in [null, true, <dynamic>[]]) {
          test('${c.name} $field rejects malformed known field $malformed', () {
            expect(
              () => c.parse({...c.json, field: malformed}),
              throwsA(_safeFormat),
            );
          });
        }
        test('${c.name} $field required omission fails contextually', () {
          final json = {...c.json}..remove(field);
          expect(() => c.parse(json), throwsA(_safeFormat));
        });
      }
      test(
        '${c.name} finite future JSON ${c.received ? 'retained' : 'rejected'}',
        () {
          final json = {
            ...c.json,
            'PRIVATE-new-key': {
              'secret': [_private, null, 1.5],
            },
          };
          if (c.received) {
            final parsed = c.parse(json);
            expect(parsed.toJson(), json);
            expect(parsed, c.parse(json));
            expect(parsed.hashCode, c.parse(json).hashCode);
            expect(parsed, isNot(c.parse(c.json)));
            expect(parsed.toString(), isNot(contains('PRIVATE')));
          } else {
            expect(() => c.parse(json), throwsA(_safeFormat));
          }
        },
      );
      for (final extra in [double.nan, double.infinity, Object()]) {
        test('${c.name} nonfinite/nonJSON future metadata rejected safely', () {
          expect(
            () => c.parse({...c.json, 'PRIVATE-key': extra}),
            throwsA(_safeFormat),
          );
        });
      }
    }
  });

  group('Live request union and admission', () {
    test('create request union dispatches exact two branches', () {
      expect(
        LiveTransport.fromJson(const {'type': 'webrtc', 'sdp': _private}),
        isA<LiveWebRTCTransport>(),
      );
      expect(LiveTransport.fromJson(_sip()), isA<LiveSIPTransport>());
      expect(
        () => LiveTransport.fromJson(const {'type': 'PRIVATE-future'}),
        throwsA(_safeFormat),
      );
      expect(
        () => LiveTransport.fromJson(const {'type': null}),
        throwsA(_safeFormat),
      );
    });
    for (final value in ['', 'sip', 'PRIVATE-webrtc', null, 1]) {
      test('offer fixed tag rejects $value', () {
        expect(
          () => LiveWebRTCTransport.fromJson({'type': value, 'sdp': _private}),
          throwsA(_safeFormat),
        );
      });
    }
    for (final value in ['', 'live', 'PRIVATE-auth', null, 1]) {
      test('digest fixed tag rejects $value', () {
        expect(
          () => LiveSIPTrunkAuth.fromJson({
            'type': value,
            'username': _private,
            'password': _private,
          }),
          throwsA(_safeFormat),
        );
      });
    }
    test(
      'empty SDP rejected in constructor and response parser; whitespace remains literal',
      () {
        expect(() => LiveWebRTCTransport(sdp: ''), throwsA(_safeFormat));
        expect(
          () => LiveWebRTCResponseTransport.fromJson(const {
            'type': 'webrtc',
            'sdp': '',
          }),
          throwsA(_safeFormat),
        );
        expect(LiveWebRTCTransport(sdp: ' \r\n').sdp, ' \r\n');
      },
    );
    for (final status in [300, 486, 699]) {
      test('SIP reject inclusive valid status $status', () {
        expect(LiveCallRejectRequest(statusCode: status).toJson(), {
          'status_code': status,
        });
      });
    }
    for (final status in [
      299,
      700,
      -1,
      3.1,
      double.nan,
      double.infinity,
      'PRIVATE-status',
    ]) {
      test('SIP reject invalid status safely rejected $status', () {
        expect(
          () => LiveCallRejectRequest.fromJson({'status_code': status}),
          throwsA(_safeFormat),
        );
      });
    }
    for (final uri in ['', ' ', '\r\n\t', '\u00a0']) {
      test('refer rejects blank URI', () {
        expect(
          () => LiveCallReferRequest(targetUri: uri),
          throwsA(_safeFormat),
        );
      });
    }
    for (final uri in [
      'tel:+14155550123',
      'sip:PRIVATE@example.com',
      '  sip:PRIVATE@example.com  ',
      'PRIVATE-future:destination',
      _private,
    ]) {
      test(
        'refer keeps nonblank URI without invented scheme restrictions: $uri',
        () {
          expect(LiveCallReferRequest(targetUri: uri).targetUri, uri);
        },
      );
    }
    test(
      'fork omitted/empty config remain distinct wire shapes and null is forbidden',
      () {
        final omitted = LiveForkRequest(
          transport: LiveWebRTCTransport(sdp: _private),
        );
        final empty = omitted.copyWith(session: LiveMediaSessionForkParams());
        expect(omitted.toJson().containsKey('session'), isFalse);
        expect(empty.toJson()['session'], <String, dynamic>{});
        expect(empty.copyWith(session: null), omitted);
        expect(
          () => empty.copyWith(session: 'PRIVATE-invalid'),
          throwsA(_safeFormat),
        );
        expect(
          () =>
              LiveForkRequest.fromJson({...omitted.toJson(), 'session': null}),
          throwsA(_safeFormat),
        );
        expect(
          () => LiveForkRequest.fromJson({'transport': _sip()}),
          throwsA(_safeFormat),
        );
      },
    );
    test('typed response transport cannot serve as writable request union', () {
      expect(LiveSIPResponseTransport(), isNot(isA<LiveTransport>()));
      expect(
        LiveWebRTCResponseTransport(sdp: _private),
        isNot(isA<LiveTransport>()),
      );
      expect(
        UnknownLiveResponseTransport(rawJson: const {'type': 'PRIVATE-future'}),
        isNot(isA<LiveTransport>()),
      );
    });
    test(
      'received transport dispatches WebRTC/minimal SIP/future branches',
      () {
        expect(
          LiveResponseTransport.fromJson(const {
            'type': 'webrtc',
            'sdp': _private,
          }),
          isA<LiveWebRTCResponseTransport>(),
        );
        expect(LiveResponseTransport.fromJson(const {'type': 'sip'}).toJson(), {
          'type': 'sip',
        });
        expect(
          LiveResponseTransport.fromJson(const {
            'type': 'PRIVATE-future',
            'secret': _private,
          }),
          isA<UnknownLiveResponseTransport>(),
        );
        expect(
          () => LiveResponseTransport.fromJson(const {'type': 'webrtc'}),
          throwsA(_safeFormat),
        );
        expect(
          () => LiveResponseTransport.fromJson(const {'type': null}),
          throwsA(_safeFormat),
        );
      },
    );
    for (final type in ['webrtc', 'sip']) {
      test('future transport helpers cannot bypass known $type admission', () {
        final json = {'type': type, 'PRIVATE-future': _private};
        expect(
          () => UnknownLiveResponseTransport(rawJson: json),
          throwsA(_safeFormat),
        );
        expect(
          () => UnknownLiveResponseTransport.fromJson(json),
          throwsA(_safeFormat),
        );
        final future = UnknownLiveResponseTransport(
          rawJson: const {'type': 'PRIVATE-future'},
        );
        expect(() => future.copyWith(rawJson: json), throwsA(_safeFormat));
      });
    }
    test(
      'SIP response has no required credentials/SDP but retains all receive-only extras',
      () {
        final received = LiveSIPResponseTransport.fromJson({
          'type': 'sip',
          'sdp': _private,
          'trunk': _trunk(),
          'PRIVATE-key': _private,
        });
        expect(received.toJson()['sdp'], _private);
        expect(received.rawJson['trunk'], _trunk());
        expect(received.toString(), isNot(contains('PRIVATE')));
        expect(
          () => LiveTransport.fromJson(received.toJson()),
          throwsA(_safeFormat),
        );
      },
    );
    test(
      'fork response is WebRTC only and received session ID remains opaque',
      () {
        expect(
          () => LiveCreateResponse.fromJson(_result('sip')),
          throwsA(_safeFormat),
        );
        for (final id in ['', '.', '..', 'other/raw%?café🚀']) {
          expect(LiveCreatedSession.fromJson({'id': id}).id, id);
        }
      },
    );
  });

  group('Live SIP documented UTF-8, phone and provider constraints', () {
    for (final unit in ['a', 'é', '🚀']) {
      for (final delta in [-1, 0, 1]) {
        test('SIP JSON UTF-8 aggregate 1 MiB boundary $delta with $unit', () {
          final target = LiveSessionCreateRequest.maxSipRequestBytes + delta;
          final json = _sizedSipJson(target, unit);
          expect(utf8.encode(jsonEncode(json)).length, target);
          if (delta <= 0) {
            final request = LiveSessionCreateRequest.fromJson(json);
            expect(utf8.encode(jsonEncode(request.toJson())).length, target);
            expect(request.copyWith(), request);
          } else {
            expect(
              () => LiveSessionCreateRequest.fromJson(json),
              throwsA(_safeFormat),
            );
            final request = LiveSessionCreateRequest(
              session: LiveMediaSessionCreateParams(model: _private),
              transport: LiveSIPTransport.fromJson(_sip()),
            );
            expect(
              () => request.copyWith(
                session: request.session.copyWith(
                  instructions:
                      (json['session'] as Map<String, dynamic>)['instructions']
                          as String,
                ),
              ),
              throwsA(_safeFormat),
            );
          }
        });
      }
    }
    test(
      'SIP aggregate limit leaves WebRTC offer size unrestricted locally',
      () {
        final sdp = 'a' * (LiveSessionCreateRequest.maxSipRequestBytes + 1);
        final request = LiveSessionCreateRequest(
          session: LiveMediaSessionCreateParams(model: _private),
          transport: LiveWebRTCTransport(sdp: sdp),
        );
        expect((request.transport as LiveWebRTCTransport).sdp, sdp);
      },
    );
    for (final username in ['é' * 128, '🚀' * 64, 'a' * 256]) {
      test('username accepts exact 256 UTF-8 byte boundary', () {
        expect(
          LiveSIPTrunkAuth(username: username, password: _private).username,
          username,
        );
      });
    }
    for (final password in ['é' * 2048, '🚀' * 1024, 'a' * 4096, ' ']) {
      test('password accepts documented nonempty UTF-8 boundary', () {
        expect(
          LiveSIPTrunkAuth(username: _private, password: password).password,
          password,
        );
      });
    }
    for (final username in [
      '',
      ' \t ',
      'é' * 129,
      '🚀' * 65,
      'a' * 257,
      'PRIVATE\ruser',
      'PRIVATE\nuser',
      'PRIVATE\u0000user',
    ]) {
      test('username constraint fails without disclosing content', () {
        expect(
          () => LiveSIPTrunkAuth(username: username, password: _private),
          throwsA(_safeFormat),
        );
      });
    }
    for (final password in [
      '',
      'é' * 2049,
      '🚀' * 1025,
      'a' * 4097,
      'PRIVATE\rpassword',
      'PRIVATE\npassword',
      'PRIVATE\u0000password',
    ]) {
      test('password constraint fails without disclosing content', () {
        expect(
          () => LiveSIPTrunkAuth(username: _private, password: password),
          throwsA(_safeFormat),
        );
      });
    }
    for (final number in ['+12', '+14155550123', '+123456789012345']) {
      test('E.164 number exact literal preserved $number', () {
        expect(
          LiveSIPTransport(
            destination: number,
            trunk: _typedTrunk(),
          ).destination,
          number,
        );
        expect(
          _typedTrunk().copyWith(callerNumber: number).callerNumber,
          number,
        );
      });
    }
    for (final number in [
      '+1',
      '+012',
      '+1234567890123456',
      '14155550123',
      '+1 4155550123',
      'sip:PRIVATE@example.com',
      '+12\n',
      '+12\r',
      '+١٢',
      'PRIVATE-phone',
    ]) {
      test('E.164 malformed destination/caller fail safely $number', () {
        expect(
          () => LiveSIPTransport(destination: number, trunk: _typedTrunk()),
          throwsA(_safeFormat),
        );
        expect(
          () => _typedTrunk().copyWith(callerNumber: number),
          throwsA(_safeFormat),
        );
      });
    }
    for (final provider in [
      'sips:sip.example.com',
      'sips:sip.example.com:5061',
      'sips:sip.example.com:65535;transport=tcp',
      'SIPS:SIP.EXAMPLE.COM:5061;TRANSPORT=TCP',
      'sips:8.8.8.8',
      'sips:[2001:4860:4860::8888]:5061',
      'sips:[2606:4700:4700::1111];transport=tcp',
      'sips:[::ffff:8.8.8.8]',
      'sips:sip.example.com.',
    ]) {
      test('public provider URI preserved without DNS $provider', () {
        expect(
          _typedTrunk().copyWith(providerUrl: provider).providerUrl,
          provider,
        );
      });
    }
    for (final provider in [
      'sip:sip.example.com',
      'https://sip.example.com',
      'sips:user:PRIVATE@sip.example.com',
      'sips:sip.example.com/path',
      'sips:sip.example.com?PRIVATE=header',
      'sips:sip.example.com#PRIVATE',
      'sips:sip.example.com;transport=udp',
      'sips:sip.example.com;PRIVATE=parameter',
      'sips:sip.example.com:0',
      'sips:sip.example.com:65536',
      'sips:sip.example.com:PRIVATE',
      'sips:sip.example.com\n',
      ' sips:sip.example.com',
      'sips:localhost',
      'sips:host',
      'sips:host.local',
      'sips:localhost.localdomain',
      'sips:home.arpa',
      'sips:host.lan',
      'sips:10.0.0.1',
      'sips:127.0.0.1',
      'sips:0.0.0.0',
      'sips:169.254.1.1',
      'sips:172.16.1.1',
      'sips:172.31.255.255',
      'sips:192.168.1.1',
      'sips:100.64.0.1',
      'sips:224.0.0.1',
      'sips:255.255.255.255',
      'sips:127.1',
      'sips:010.0.0.1',
      'sips:999.1.1.1',
      'sips:[::]',
      'sips:[::1]',
      'sips:[fc00::1]',
      'sips:[fdff::1]',
      'sips:[fe80::1]',
      'sips:[fec0::1]',
      'sips:[ff02::1]',
      'sips:[::ffff:192.168.1.1]',
      'sips:[::ffff:127.0.0.1]',
      'sips:2001:4860::8888',
      'sips:[::1%PRIVATE]',
      'sips:[2001:::1]',
      'sips:[8.8.8.8::]',
    ]) {
      test('invalid/local provider safely rejected without DNS $provider', () {
        expect(
          () => _typedTrunk().copyWith(providerUrl: provider),
          throwsA(_safeFormat),
        );
      });
    }
  });

  group('Live response ownership and complete copy semantics', () {
    test(
      'all response layers snapshot finite nested metadata and own it immutably',
      () {
        final json = _result('webrtc');
        json['PRIVATE-extra'] = {
          'data': [_private],
        };
        (json['session'] as Map<String, dynamic>)['PRIVATE-extra'] = {
          'data': [_private],
        };
        (json['transport'] as Map<String, dynamic>)['PRIVATE-extra'] = {
          'data': [_private],
        };
        final response = LiveSessionCreateResponse.fromJson(json);
        (json['PRIVATE-extra'] as Map<String, dynamic>)['data'] = ['mutated'];
        expect((response.rawJson['PRIVATE-extra'] as Map)['data'], [_private]);
        expect(
          () => response.rawJson['PRIVATE-new'] = 1,
          throwsUnsupportedError,
        );
        expect(
          () => (response.session.rawJson['PRIVATE-extra'] as Map)['data'] =
              <dynamic>[],
          throwsUnsupportedError,
        );
        expect(
          () =>
              ((response.transport.rawJson['PRIVATE-extra'] as Map)['data']
                      as List)
                  .add(1),
          throwsUnsupportedError,
        );
        final changed = response.copyWith(
          session: response.session.copyWith(id: 'new-id'),
          transport: (response.transport as LiveWebRTCResponseTransport)
              .copyWith(sdp: 'new-answer'),
        );
        expect(changed.toJson()['session'], {
          'id': 'new-id',
          'PRIVATE-extra': {
            'data': [_private],
          },
        });
        expect(changed.toJson()['transport'], {
          'type': 'webrtc',
          'sdp': 'new-answer',
          'PRIVATE-extra': {
            'data': [_private],
          },
        });
        expect(changed.toJson()['PRIVATE-extra'], {
          'data': [_private],
        });
        expect(changed, isNot(response));
        final fresh = changed.copyWith(
          session: LiveCreatedSession(id: 'fresh'),
          transport: LiveSIPResponseTransport(),
        );
        expect(fresh.toJson()['session'], {'id': 'fresh'});
        expect(fresh.toJson()['transport'], {'type': 'sip'});
        expect(fresh.toJson()['PRIVATE-extra'], {
          'data': [_private],
        });
      },
    );
    test(
      'future metadata cycles and non-string keys fail without key/value leaks',
      () {
        final cycle = <dynamic>[];
        cycle.add(cycle);
        expect(
          () => LiveCreatedSession.fromJson({
            'id': _private,
            'PRIVATE-key': cycle,
          }),
          throwsA(_safeFormat),
        );
        expect(
          () => LiveSIPResponseTransport(
            rawJson: const {
              'PRIVATE-key': {1: _private},
            },
          ),
          throwsA(_safeFormat),
        );
      },
    );
    test('all request and response copy fields affect complete equality', () {
      final offer = LiveWebRTCTransport(sdp: _private);
      final auth = LiveSIPTrunkAuth(username: _private, password: _private);
      expect(offer.copyWith(), offer);
      expect(offer.copyWith(sdp: 'new'), isNot(offer));
      expect(auth.copyWith(), auth);
      expect(auth.copyWith(username: 'new'), isNot(auth));
      expect(auth.copyWith(password: 'new'), isNot(auth));
      final trunk = _typedTrunk();
      expect(trunk.copyWith(), trunk);
      expect(
        trunk.copyWith(providerUrl: 'sips:other.example.com'),
        isNot(trunk),
      );
      expect(
        trunk.copyWith(auth: auth.copyWith(password: 'new')),
        isNot(trunk),
      );
      expect(trunk.copyWith(callerNumber: '+123'), isNot(trunk));
      final sip = LiveSIPTransport(destination: '+123', trunk: trunk);
      expect(sip.copyWith(), sip);
      expect(sip.copyWith(destination: '+124'), isNot(sip));
      expect(
        sip.copyWith(trunk: trunk.copyWith(callerNumber: '+124')),
        isNot(sip),
      );
      final create = LiveSessionCreateRequest(
        session: LiveMediaSessionCreateParams(model: _private),
        transport: offer,
      );
      expect(create.copyWith(), create);
      expect(
        create.copyWith(session: LiveMediaSessionCreateParams(model: 'new')),
        isNot(create),
      );
      expect(create.copyWith(transport: sip), isNot(create));
      final accept = LiveCallAcceptRequest(
        session: LiveCallAcceptSession(model: _private),
      );
      expect(accept.copyWith(), accept);
      expect(
        accept.copyWith(session: LiveCallAcceptSession(model: 'new')),
        isNot(accept),
      );
      expect(
        LiveCallRejectRequest(
          statusCode: 486,
        ).copyWith(statusCode: 487).statusCode,
        487,
      );
      expect(
        LiveCallReferRequest(
          targetUri: _private,
        ).copyWith(targetUri: 'new').targetUri,
        'new',
      );
      final fork = LiveForkRequest(transport: offer);
      expect(fork.copyWith(transport: offer.copyWith(sdp: 'new')), isNot(fork));
      final answer = LiveWebRTCResponseTransport(sdp: _private);
      expect(answer.copyWith(), answer);
      expect(answer.copyWith(rawJson: {'extra': 1}), isNot(answer));
      final marker = LiveSIPResponseTransport();
      expect(marker.copyWith(), marker);
      expect(marker.copyWith(rawJson: {'extra': 1}), isNot(marker));
      final unknown = UnknownLiveResponseTransport(
        rawJson: const {'type': 'future', 'extra': 1},
      );
      expect(unknown.copyWith(), unknown);
      expect(
        unknown.copyWith(rawJson: {'type': 'other', 'extra': 1}),
        isNot(unknown),
      );
      final id = LiveCreatedSession(id: _private);
      expect(id.copyWith(), id);
      expect(id.copyWith(id: 'new'), isNot(id));
      expect(id.copyWith(rawJson: {'extra': 1}), isNot(id));
      final result = LiveCreateResponse(session: id, transport: answer);
      expect(result.copyWith(), result);
      expect(result.copyWith(session: id.copyWith(id: 'new')), isNot(result));
      expect(
        result.copyWith(transport: answer.copyWith(sdp: 'new')),
        isNot(result),
      );
      expect(result.copyWith(rawJson: {'extra': 1}), isNot(result));
    });
  });
}

final TypeMatcher<FormatException> _safeFormat = isA<FormatException>()
    .having((error) => error.message, 'context', isNotEmpty)
    .having(
      (error) => error.toString(),
      'private diagnostics',
      isNot(contains('PRIVATE')),
    )
    .having((error) => error.source, 'source', isNull);

Map<String, dynamic> _sizedSipJson(int target, String unit) {
  final json = <String, dynamic>{
    'session': <String, dynamic>{'model': _private, 'instructions': ''},
    'transport': _sip(),
  };
  final padding = target - utf8.encode(jsonEncode(json)).length;
  final width = utf8.encode(unit).length;
  (json['session'] as Map<String, dynamic>)['instructions'] =
      unit * (padding ~/ width) + 'a' * (padding % width);
  return json;
}

Map<String, dynamic> _trunk() => {
  'provider_url': 'sips:sip.example.com:5061',
  'auth': {'type': 'digest', 'username': _private, 'password': _private},
  'caller_number': '+14155550100',
};
Map<String, dynamic> _sip() => {
  'type': 'sip',
  'destination': '+14155550123',
  'trunk': _trunk(),
};
LiveSIPTrunk _typedTrunk() => LiveSIPTrunk.fromJson(_trunk());
Map<String, dynamic> _result(String type) => {
  'session': <String, dynamic>{'id': _private},
  'transport': <String, dynamic>{
    'type': type,
    if (type == 'webrtc') 'sdp': _private,
  },
};

class _Case {
  _Case(
    this.name,
    this.parse,
    this.json,
    this.required, {
    this.received = false,
  });
  final String name;
  final LiveJsonModel Function(Map<String, dynamic>) parse;
  final Map<String, dynamic> json;
  final List<String> required;
  final bool received;
}
