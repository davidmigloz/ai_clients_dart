import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_LIVE_PAYLOAD';

Map<String, dynamic> _object(String value) =>
    jsonDecode(value) as Map<String, dynamic>;

Matcher _safeError(String context) => isA<FormatException>()
    .having((error) => error.message, 'context', contains(context))
    .having((error) => error.source, 'source', isNull)
    .having((error) => error.offset, 'offset', isNull)
    .having((error) => error.toString(), 'privacy', isNot(contains(_private)));

void main() {
  group('LiveAllowedServerEventParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"type": "response.event", "response_event": "response.output_text.delta"}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveAllowedServerEventParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveAllowedServerEventParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.responseEvent, fixture()['response_event']);
      expect(model.toString(), contains('responseEvent:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveAllowedServerEventParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('closed writable extras reject without disclosing keys', () {
      expect(
        () => LiveAllowedServerEventParam.fromJson({
          ...fixture(),
          _private: true,
        }),
        throwsA(_safeError('LiveAllowedServerEventParam')),
      );
      expect(
        () => LiveAllowedServerEventParam.fromJson(
          fixture(),
        ).copyWith(rawJson: {_private: true}),
        throwsA(_safeError('LiveAllowedServerEventParam')),
      );
    });
    test('response_event rejects wrong known values contextually', () {
      expect(
        () => LiveAllowedServerEventParam.fromJson({
          ...fixture(),
          'response_event': 42,
        }),
        throwsA(_safeError('LiveAllowedServerEventParam.response_event')),
      );
    });
    test('response_event omission, null and clearing follow schema', () {
      final absent = LiveAllowedServerEventParam.fromJson(
        fixture()
          ..remove('response_event')
          ..['type'] = 'session.started',
      );
      expect(absent.responseEvent, isNull);
      expect(absent.toJson().containsKey('response_event'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveAllowedServerEventParam.fromJson({
          ...fixture(),
          'response_event': null,
        }),
        throwsA(_safeError('LiveAllowedServerEventParam.response_event')),
      );
    });
    test('response_event typed copy wins over stale raw JSON', () {
      final model = LiveAllowedServerEventParam.fromJson(fixture());
      final copied = model.copyWith(responseEvent: 'response.completed');
      expect(
        copied.toJson()['response_event'],
        jsonDecode('"response.completed"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(responseEvent: Object()),
        throwsA(_safeError('LiveAllowedServerEventParam.response_event')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveAllowedServerEventParam.fromJson({...fixture(), 'type': 42}),
        throwsA(_safeError('LiveAllowedServerEventParam.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveAllowedServerEventParam.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveAllowedServerEventParam.type')),
      );
      expect(
        () =>
            LiveAllowedServerEventParam.fromJson({...fixture(), 'type': null}),
        throwsA(_safeError('LiveAllowedServerEventParam.type')),
      );
    });
    test('type typed copy wins over stale raw JSON', () {
      final model = LiveAllowedServerEventParam.fromJson(fixture());
      final copied = model.copyWith(type: 'response.event');
      expect(copied.toJson()['type'], jsonDecode('"response.event"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
  });

  group('LiveDataChannelConfigParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveDataChannelConfigParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveDataChannelConfigParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(
        model.allowedClientEvents?.toJson(),
        fixture()['allowed_client_events'],
      );
      expect(model.toString(), contains('allowedClientEvents:'));
      expect(
        model.allowedServerEvents?.toJson(),
        fixture()['allowed_server_events'],
      );
      expect(model.toString(), contains('allowedServerEvents:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveDataChannelConfigParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveDataChannelConfigParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveDataChannelConfigParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveDataChannelConfigParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveDataChannelConfigParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveDataChannelConfigParam')),
        );
      }
    });
    test('allowed_client_events rejects wrong known values contextually', () {
      expect(
        () => LiveDataChannelConfigParam.fromJson({
          ...fixture(),
          'allowed_client_events': 42,
        }),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_client_events')),
      );
    });
    test('allowed_client_events omission, null and clearing follow schema', () {
      final absent = LiveDataChannelConfigParam.fromJson(
        fixture()..remove('allowed_client_events'),
      );
      expect(absent.allowedClientEvents, isNull);
      expect(absent.toJson().containsKey('allowed_client_events'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveDataChannelConfigParam.fromJson({
          ...fixture(),
          'allowed_client_events': null,
        }),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_client_events')),
      );
      expect(
        LiveDataChannelConfigParam.fromJson(fixture())
            .copyWith(allowedClientEvents: null)
            .toJson()
            .containsKey('allowed_client_events'),
        isFalse,
      );
    });
    test('allowed_client_events typed copy wins over stale raw JSON', () {
      final model = LiveDataChannelConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        allowedClientEvents: LiveAllowedClientEvents.fromJson('all'),
      );
      expect(copied.toJson()['allowed_client_events'], jsonDecode('"all"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(allowedClientEvents: Object()),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_client_events')),
      );
    });
    test('allowed_server_events rejects wrong known values contextually', () {
      expect(
        () => LiveDataChannelConfigParam.fromJson({
          ...fixture(),
          'allowed_server_events': 42,
        }),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_server_events')),
      );
    });
    test('allowed_server_events omission, null and clearing follow schema', () {
      final absent = LiveDataChannelConfigParam.fromJson(
        fixture()..remove('allowed_server_events'),
      );
      expect(absent.allowedServerEvents, isNull);
      expect(absent.toJson().containsKey('allowed_server_events'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveDataChannelConfigParam.fromJson({
          ...fixture(),
          'allowed_server_events': null,
        }),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_server_events')),
      );
      expect(
        LiveDataChannelConfigParam.fromJson(fixture())
            .copyWith(allowedServerEvents: null)
            .toJson()
            .containsKey('allowed_server_events'),
        isFalse,
      );
    });
    test('allowed_server_events typed copy wins over stale raw JSON', () {
      final model = LiveDataChannelConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        allowedServerEvents: LiveAllowedServerEvents.fromJson('all'),
      );
      expect(copied.toJson()['allowed_server_events'], jsonDecode('"all"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(allowedServerEvents: Object()),
        throwsA(_safeError('LiveDataChannelConfigParam.allowed_server_events')),
      );
    });
  });

  group('LiveClientConfigParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveClientConfigParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveClientConfigParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.dataChannel.toJson(), fixture()['data_channel']);
      expect(model.toString(), contains('dataChannel:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveClientConfigParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveClientConfigParam.fromJson({...fixture(), ...future});
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveClientConfigParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveClientConfigParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveClientConfigParam.fromJson({...fixture(), _private: value}),
          throwsA(_safeError('LiveClientConfigParam')),
        );
      }
    });
    test('data_channel rejects wrong known values contextually', () {
      expect(
        () =>
            LiveClientConfigParam.fromJson({...fixture(), 'data_channel': 42}),
        throwsA(_safeError('LiveClientConfigParam.data_channel')),
      );
    });
    test('data_channel is required and rejects null', () {
      expect(
        () => LiveClientConfigParam.fromJson(fixture()..remove('data_channel')),
        throwsA(_safeError('LiveClientConfigParam.data_channel')),
      );
      expect(
        () => LiveClientConfigParam.fromJson({
          ...fixture(),
          'data_channel': null,
        }),
        throwsA(_safeError('LiveClientConfigParam.data_channel')),
      );
    });
    test('data_channel typed copy wins over stale raw JSON', () {
      final model = LiveClientConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        dataChannel: LiveDataChannelConfigParam.fromJson(
          _object(
            '{"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}], "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['data_channel'],
        jsonDecode(
          '{"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}], "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
  });

  group('LiveSessionCreateParams', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-live-future", "audio": {"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}, "client": {"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "input": [{"role": "developer", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "user", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "assistant", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}], "instructions": "PRIVATE_LIVE_PAYLOAD", "store": false}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionCreateParams.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.audio?.toJson(), fixture()['audio']);
      expect(model.toString(), contains('audio:'));
      expect(model.client?.toJson(), fixture()['client']);
      expect(model.toString(), contains('client:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.hasDelegation, isTrue);
      expect(
        model.input?.map((item) => item.toJson()).toList(),
        fixture()['input'],
      );
      expect(model.toString(), contains('input:'));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionCreateParams.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionCreateParams.fromJson({...fixture(), ...future});
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionCreateParams.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionCreateParams.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () =>
              LiveSessionCreateParams.fromJson({...fixture(), _private: value}),
          throwsA(_safeError('LiveSessionCreateParams')),
        );
      }
    });
    test('audio rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'audio': 42}),
        throwsA(_safeError('LiveSessionCreateParams.audio')),
      );
    });
    test('audio omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('audio'),
      );
      expect(absent.audio, isNull);
      expect(absent.toJson().containsKey('audio'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'audio': null}),
        throwsA(_safeError('LiveSessionCreateParams.audio')),
      );
      expect(
        LiveSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(audio: null).toJson().containsKey('audio'),
        isFalse,
      );
    });
    test('audio typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        audio: LiveInitialSessionAudioParam.fromJson(
          _object(
            '{"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['audio'],
        jsonDecode(
          '{"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(audio: Object()),
        throwsA(_safeError('LiveSessionCreateParams.audio')),
      );
    });
    test('client rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'client': 42}),
        throwsA(_safeError('LiveSessionCreateParams.client')),
      );
    });
    test('client omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('client'),
      );
      expect(absent.client, isNull);
      expect(absent.toJson().containsKey('client'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'client': null}),
        throwsA(_safeError('LiveSessionCreateParams.client')),
      );
      expect(
        LiveSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(client: null).toJson().containsKey('client'),
        isFalse,
      );
    });
    test('client typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        client: LiveClientConfigParam.fromJson(
          _object(
            '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['client'],
        jsonDecode(
          '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(client: Object()),
        throwsA(_safeError('LiveSessionCreateParams.client')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () =>
            LiveSessionCreateParams.fromJson({...fixture(), 'delegation': 42}),
        throwsA(_safeError('LiveSessionCreateParams.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasDelegation, isFalse);
      final explicit = absent.copyWith(delegation: null);
      expect(explicit.hasDelegation, isTrue);
      expect(explicit.toJson().containsKey('delegation'), isTrue);
      expect(explicit.toJson()['delegation'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearDelegation: true);
      expect(cleared.hasDelegation, isFalse);
      expect(cleared, absent);
      expect(
        LiveSessionCreateParams.fromJson({
          ...fixture(),
          'delegation': null,
        }).toJson()['delegation'],
        isNull,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveDelegation.fromJson(_object('{"type": "client"}')),
      );
      expect(copied.toJson()['delegation'], jsonDecode('{"type": "client"}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveSessionCreateParams.delegation')),
      );
    });
    test('input rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'input': 42}),
        throwsA(_safeError('LiveSessionCreateParams.input')),
      );
    });
    test('input omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('input'),
      );
      expect(absent.input, isNull);
      expect(absent.toJson().containsKey('input'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'input': null}),
        throwsA(_safeError('LiveSessionCreateParams.input')),
      );
      expect(
        LiveSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(input: null).toJson().containsKey('input'),
        isFalse,
      );
    });
    test('input typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(input: <LiveInitialItem>[]);
      expect(copied.toJson()['input'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(input: Object()),
        throwsA(_safeError('LiveSessionCreateParams.input')),
      );
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({
          ...fixture(),
          'instructions': 42,
        }),
        throwsA(_safeError('LiveSessionCreateParams.instructions')),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveSessionCreateParams.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(_safeError('LiveSessionCreateParams.instructions')),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'model': 42}),
        throwsA(_safeError('LiveSessionCreateParams.model')),
      );
    });
    test('model is required and rejects null', () {
      expect(
        () => LiveSessionCreateParams.fromJson(fixture()..remove('model')),
        throwsA(_safeError('LiveSessionCreateParams.model')),
      );
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'model': null}),
        throwsA(_safeError('LiveSessionCreateParams.model')),
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveSessionCreateParams.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveSessionCreateParams.fromJson(
        fixture()..remove('store'),
      );
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionCreateParams.fromJson({...fixture(), 'store': null}),
        throwsA(_safeError('LiveSessionCreateParams.store')),
      );
      expect(
        LiveSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveSessionCreateParams.store')),
      );
    });
  });

  group('LiveSessionResourceParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-live-future", "audio": {"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}, "client": {"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "input": [{"role": "developer", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "user", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "assistant", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}], "instructions": "PRIVATE_LIVE_PAYLOAD", "store": false, "id": "PRIVATE_LIVE_PAYLOAD", "expires_at": 123456, "status": "active"}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionResourceParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.audio?.toJson(), fixture()['audio']);
      expect(model.toString(), contains('audio:'));
      expect(model.client?.toJson(), fixture()['client']);
      expect(model.toString(), contains('client:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.hasDelegation, isTrue);
      expect(model.expiresAt, fixture()['expires_at']);
      expect(model.toString(), contains('expiresAt:'));
      expect(model.id, fixture()['id']);
      expect(model.toString(), contains('id:'));
      expect(
        model.input?.map((item) => item.toJson()).toList(),
        fixture()['input'],
      );
      expect(model.toString(), contains('input:'));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.status, fixture()['status']);
      expect(model.toString(), contains('status:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionResourceParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionResourceParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionResourceParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionResourceParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveSessionResourceParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveSessionResourceParam')),
        );
      }
    });
    test('audio rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'audio': 42}),
        throwsA(_safeError('LiveSessionResourceParam.audio')),
      );
    });
    test('audio omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('audio'),
      );
      expect(absent.audio, isNull);
      expect(absent.toJson().containsKey('audio'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'audio': null}),
        throwsA(_safeError('LiveSessionResourceParam.audio')),
      );
      expect(
        LiveSessionResourceParam.fromJson(
          fixture(),
        ).copyWith(audio: null).toJson().containsKey('audio'),
        isFalse,
      );
    });
    test('audio typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(
        audio: LiveInitialSessionAudioParam.fromJson(
          _object(
            '{"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['audio'],
        jsonDecode(
          '{"format": {"type": "audio/pcm", "rate": 16000}, "output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(audio: Object()),
        throwsA(_safeError('LiveSessionResourceParam.audio')),
      );
    });
    test('client rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'client': 42}),
        throwsA(_safeError('LiveSessionResourceParam.client')),
      );
    });
    test('client omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('client'),
      );
      expect(absent.client, isNull);
      expect(absent.toJson().containsKey('client'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'client': null}),
        throwsA(_safeError('LiveSessionResourceParam.client')),
      );
      expect(
        LiveSessionResourceParam.fromJson(
          fixture(),
        ).copyWith(client: null).toJson().containsKey('client'),
        isFalse,
      );
    });
    test('client typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(
        client: LiveClientConfigParam.fromJson(
          _object(
            '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['client'],
        jsonDecode(
          '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(client: Object()),
        throwsA(_safeError('LiveSessionResourceParam.client')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () =>
            LiveSessionResourceParam.fromJson({...fixture(), 'delegation': 42}),
        throwsA(_safeError('LiveSessionResourceParam.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasDelegation, isFalse);
      final explicit = absent.copyWith(delegation: null);
      expect(explicit.hasDelegation, isTrue);
      expect(explicit.toJson().containsKey('delegation'), isTrue);
      expect(explicit.toJson()['delegation'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearDelegation: true);
      expect(cleared.hasDelegation, isFalse);
      expect(cleared, absent);
      expect(
        LiveSessionResourceParam.fromJson({
          ...fixture(),
          'delegation': null,
        }).toJson()['delegation'],
        isNull,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveDelegation.fromJson(_object('{"type": "client"}')),
      );
      expect(copied.toJson()['delegation'], jsonDecode('{"type": "client"}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveSessionResourceParam.delegation')),
      );
    });
    test('expires_at rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({
          ...fixture(),
          'expires_at': _private,
        }),
        throwsA(_safeError('LiveSessionResourceParam.expires_at')),
      );
    });
    test('expires_at is required and rejects null', () {
      expect(
        () =>
            LiveSessionResourceParam.fromJson(fixture()..remove('expires_at')),
        throwsA(_safeError('LiveSessionResourceParam.expires_at')),
      );
      expect(
        () => LiveSessionResourceParam.fromJson({
          ...fixture(),
          'expires_at': null,
        }),
        throwsA(_safeError('LiveSessionResourceParam.expires_at')),
      );
    });
    test('expires_at typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(expiresAt: 654321);
      expect(copied.toJson()['expires_at'], jsonDecode('654321'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('id rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'id': 42}),
        throwsA(_safeError('LiveSessionResourceParam.id')),
      );
    });
    test('id is required and rejects null', () {
      expect(
        () => LiveSessionResourceParam.fromJson(fixture()..remove('id')),
        throwsA(_safeError('LiveSessionResourceParam.id')),
      );
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'id': null}),
        throwsA(_safeError('LiveSessionResourceParam.id')),
      );
    });
    test('id typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(id: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['id'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('input rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'input': 42}),
        throwsA(_safeError('LiveSessionResourceParam.input')),
      );
    });
    test('input omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('input'),
      );
      expect(absent.input, isNull);
      expect(absent.toJson().containsKey('input'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'input': null}),
        throwsA(_safeError('LiveSessionResourceParam.input')),
      );
      expect(
        LiveSessionResourceParam.fromJson(
          fixture(),
        ).copyWith(input: null).toJson().containsKey('input'),
        isFalse,
      );
    });
    test('input typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(input: <LiveInitialItem>[]);
      expect(copied.toJson()['input'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(input: Object()),
        throwsA(_safeError('LiveSessionResourceParam.input')),
      );
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({
          ...fixture(),
          'instructions': 42,
        }),
        throwsA(_safeError('LiveSessionResourceParam.instructions')),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveSessionResourceParam.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(_safeError('LiveSessionResourceParam.instructions')),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'model': 42}),
        throwsA(_safeError('LiveSessionResourceParam.model')),
      );
    });
    test('model is required and rejects null', () {
      expect(
        () => LiveSessionResourceParam.fromJson(fixture()..remove('model')),
        throwsA(_safeError('LiveSessionResourceParam.model')),
      );
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'model': null}),
        throwsA(_safeError('LiveSessionResourceParam.model')),
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('status rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'status': 42}),
        throwsA(_safeError('LiveSessionResourceParam.status')),
      );
    });
    test('status is required and rejects null', () {
      expect(
        () => LiveSessionResourceParam.fromJson(fixture()..remove('status')),
        throwsA(_safeError('LiveSessionResourceParam.status')),
      );
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'status': null}),
        throwsA(_safeError('LiveSessionResourceParam.status')),
      );
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveSessionResourceParam.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveSessionResourceParam.fromJson(
        fixture()..remove('store'),
      );
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveSessionResourceParam.fromJson({...fixture(), 'store': null}),
        throwsA(_safeError('LiveSessionResourceParam.store')),
      );
      expect(
        LiveSessionResourceParam.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveSessionResourceParam.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveSessionResourceParam.store')),
      );
    });
  });

  group('LiveSessionUpdateParams', () {
    Map<String, dynamic> fixture() => _object(
      '{"delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveSessionUpdateParams.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveSessionUpdateParams.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.hasDelegation, isTrue);
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveSessionUpdateParams.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveSessionUpdateParams.fromJson({...fixture(), ...future});
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveSessionUpdateParams.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveSessionUpdateParams.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () =>
              LiveSessionUpdateParams.fromJson({...fixture(), _private: value}),
          throwsA(_safeError('LiveSessionUpdateParams')),
        );
      }
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () =>
            LiveSessionUpdateParams.fromJson({...fixture(), 'delegation': 42}),
        throwsA(_safeError('LiveSessionUpdateParams.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveSessionUpdateParams.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasDelegation, isFalse);
      final explicit = absent.copyWith(delegation: null);
      expect(explicit.hasDelegation, isTrue);
      expect(explicit.toJson().containsKey('delegation'), isTrue);
      expect(explicit.toJson()['delegation'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearDelegation: true);
      expect(cleared.hasDelegation, isFalse);
      expect(cleared, absent);
      expect(
        LiveSessionUpdateParams.fromJson({
          ...fixture(),
          'delegation': null,
        }).toJson()['delegation'],
        isNull,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveSessionUpdateParams.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveDelegationUpdate.fromJson(
          _object('{"type": "client"}'),
        ),
      );
      expect(copied.toJson()['delegation'], jsonDecode('{"type": "client"}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveSessionUpdateParams.delegation')),
      );
    });
  });

  group('LiveMediaSessionCreateParams', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-live-future", "audio": {"output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}, "client": {"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "input": [{"role": "developer", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "user", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "assistant", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}], "instructions": "PRIVATE_LIVE_PAYLOAD", "store": false}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveMediaSessionCreateParams.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.audio?.toJson(), fixture()['audio']);
      expect(model.toString(), contains('audio:'));
      expect(model.client?.toJson(), fixture()['client']);
      expect(model.toString(), contains('client:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.hasDelegation, isTrue);
      expect(
        model.input?.map((item) => item.toJson()).toList(),
        fixture()['input'],
      );
      expect(model.toString(), contains('input:'));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveMediaSessionCreateParams.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('closed writable extras reject without disclosing keys', () {
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          _private: true,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams')),
      );
      expect(
        () => LiveMediaSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(rawJson: {_private: true}),
        throwsA(_safeError('LiveMediaSessionCreateParams')),
      );
    });
    test('audio rejects wrong known values contextually', () {
      expect(
        () =>
            LiveMediaSessionCreateParams.fromJson({...fixture(), 'audio': 42}),
        throwsA(_safeError('LiveMediaSessionCreateParams.audio')),
      );
    });
    test('audio omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('audio'),
      );
      expect(absent.audio, isNull);
      expect(absent.toJson().containsKey('audio'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'audio': null,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.audio')),
      );
      expect(
        LiveMediaSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(audio: null).toJson().containsKey('audio'),
        isFalse,
      );
    });
    test('audio typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        audio: LiveMediaSessionAudioParam.fromJson(_object('{}')),
      );
      expect(copied.toJson()['audio'], jsonDecode('{}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(audio: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.audio')),
      );
    });
    test('client rejects wrong known values contextually', () {
      expect(
        () =>
            LiveMediaSessionCreateParams.fromJson({...fixture(), 'client': 42}),
        throwsA(_safeError('LiveMediaSessionCreateParams.client')),
      );
    });
    test('client omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('client'),
      );
      expect(absent.client, isNull);
      expect(absent.toJson().containsKey('client'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'client': null,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.client')),
      );
      expect(
        LiveMediaSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(client: null).toJson().containsKey('client'),
        isFalse,
      );
    });
    test('client typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        client: LiveClientConfigParam.fromJson(
          _object(
            '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['client'],
        jsonDecode(
          '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(client: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.client')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'delegation': 42,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasDelegation, isFalse);
      final explicit = absent.copyWith(delegation: null);
      expect(explicit.hasDelegation, isTrue);
      expect(explicit.toJson().containsKey('delegation'), isTrue);
      expect(explicit.toJson()['delegation'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearDelegation: true);
      expect(cleared.hasDelegation, isFalse);
      expect(cleared, absent);
      expect(
        LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'delegation': null,
        }).toJson()['delegation'],
        isNull,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveDelegation.fromJson(_object('{"type": "client"}')),
      );
      expect(copied.toJson()['delegation'], jsonDecode('{"type": "client"}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.delegation')),
      );
    });
    test('input rejects wrong known values contextually', () {
      expect(
        () =>
            LiveMediaSessionCreateParams.fromJson({...fixture(), 'input': 42}),
        throwsA(_safeError('LiveMediaSessionCreateParams.input')),
      );
    });
    test('input omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('input'),
      );
      expect(absent.input, isNull);
      expect(absent.toJson().containsKey('input'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'input': null,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.input')),
      );
      expect(
        LiveMediaSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(input: null).toJson().containsKey('input'),
        isFalse,
      );
    });
    test('input typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(input: <LiveInitialItem>[]);
      expect(copied.toJson()['input'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(input: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.input')),
      );
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'instructions': 42,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.instructions')),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.instructions')),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () =>
            LiveMediaSessionCreateParams.fromJson({...fixture(), 'model': 42}),
        throwsA(_safeError('LiveMediaSessionCreateParams.model')),
      );
    });
    test('model is required and rejects null', () {
      expect(
        () => LiveMediaSessionCreateParams.fromJson(fixture()..remove('model')),
        throwsA(_safeError('LiveMediaSessionCreateParams.model')),
      );
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'model': null,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.model')),
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () =>
            LiveMediaSessionCreateParams.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveMediaSessionCreateParams.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionCreateParams.fromJson(
        fixture()..remove('store'),
      );
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveMediaSessionCreateParams.fromJson({
          ...fixture(),
          'store': null,
        }),
        throwsA(_safeError('LiveMediaSessionCreateParams.store')),
      );
      expect(
        LiveMediaSessionCreateParams.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionCreateParams.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveMediaSessionCreateParams.store')),
      );
    });
  });

  group('LiveMediaSessionForkParams', () {
    Map<String, dynamic> fixture() => _object(
      '{"client": {"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "store": false}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveMediaSessionForkParams.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveMediaSessionForkParams.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.client?.toJson(), fixture()['client']);
      expect(model.toString(), contains('client:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveMediaSessionForkParams.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('closed writable extras reject without disclosing keys', () {
      expect(
        () =>
            LiveMediaSessionForkParams.fromJson({...fixture(), _private: true}),
        throwsA(_safeError('LiveMediaSessionForkParams')),
      );
      expect(
        () => LiveMediaSessionForkParams.fromJson(
          fixture(),
        ).copyWith(rawJson: {_private: true}),
        throwsA(_safeError('LiveMediaSessionForkParams')),
      );
    });
    test('client rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionForkParams.fromJson({...fixture(), 'client': 42}),
        throwsA(_safeError('LiveMediaSessionForkParams.client')),
      );
    });
    test('client omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionForkParams.fromJson(
        fixture()..remove('client'),
      );
      expect(absent.client, isNull);
      expect(absent.toJson().containsKey('client'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveMediaSessionForkParams.fromJson({...fixture(), 'client': null}),
        throwsA(_safeError('LiveMediaSessionForkParams.client')),
      );
      expect(
        LiveMediaSessionForkParams.fromJson(
          fixture(),
        ).copyWith(client: null).toJson().containsKey('client'),
        isFalse,
      );
    });
    test('client typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionForkParams.fromJson(fixture());
      final copied = model.copyWith(
        client: LiveClientConfigParam.fromJson(
          _object(
            '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['client'],
        jsonDecode(
          '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(client: Object()),
        throwsA(_safeError('LiveMediaSessionForkParams.client')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionForkParams.fromJson({
          ...fixture(),
          'delegation': 42,
        }),
        throwsA(_safeError('LiveMediaSessionForkParams.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionForkParams.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveMediaSessionForkParams.fromJson({
          ...fixture(),
          'delegation': null,
        }),
        throwsA(_safeError('LiveMediaSessionForkParams.delegation')),
      );
      expect(
        LiveMediaSessionForkParams.fromJson(
          fixture(),
        ).copyWith(delegation: null).toJson().containsKey('delegation'),
        isFalse,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionForkParams.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveResponsesDelegationUpdateParam.fromJson(
          _object(
            '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['delegation'],
        jsonDecode(
          '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveMediaSessionForkParams.delegation')),
      );
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () => LiveMediaSessionForkParams.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveMediaSessionForkParams.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveMediaSessionForkParams.fromJson(
        fixture()..remove('store'),
      );
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveMediaSessionForkParams.fromJson({...fixture(), 'store': null}),
        throwsA(_safeError('LiveMediaSessionForkParams.store')),
      );
      expect(
        LiveMediaSessionForkParams.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveMediaSessionForkParams.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveMediaSessionForkParams.store')),
      );
    });
  });

  group('LiveCallAcceptSession', () {
    Map<String, dynamic> fixture() => _object(
      '{"model": "gpt-live-future", "audio": {"output": {"voice": {"id": "PRIVATE_LIVE_PAYLOAD"}}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "input": [{"role": "developer", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "user", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "input_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}, {"role": "assistant", "type": "message", "id": "PRIVATE_LIVE_PAYLOAD", "status": "completed", "content": [{"type": "output_text", "text": "PRIVATE_LIVE_PAYLOAD"}]}], "instructions": "PRIVATE_LIVE_PAYLOAD", "store": false, "type": "live"}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveCallAcceptSession.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.audio?.toJson(), fixture()['audio']);
      expect(model.toString(), contains('audio:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.hasDelegation, isTrue);
      expect(
        model.input?.map((item) => item.toJson()).toList(),
        fixture()['input'],
      );
      expect(model.toString(), contains('input:'));
      expect(model.instructions, fixture()['instructions']);
      expect(model.toString(), contains('instructions:'));
      expect(model.hasInstructions, isTrue);
      expect(model.model, fixture()['model']);
      expect(model.toString(), contains('model:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
      expect(model.type, fixture()['type']);
      expect(model.toString(), contains('type:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveCallAcceptSession.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('closed writable extras reject without disclosing keys', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), _private: true}),
        throwsA(_safeError('LiveCallAcceptSession')),
      );
      expect(
        () => LiveCallAcceptSession.fromJson(
          fixture(),
        ).copyWith(rawJson: {_private: true}),
        throwsA(_safeError('LiveCallAcceptSession')),
      );
    });
    test('audio rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'audio': 42}),
        throwsA(_safeError('LiveCallAcceptSession.audio')),
      );
    });
    test('audio omission, null and clearing follow schema', () {
      final absent = LiveCallAcceptSession.fromJson(fixture()..remove('audio'));
      expect(absent.audio, isNull);
      expect(absent.toJson().containsKey('audio'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'audio': null}),
        throwsA(_safeError('LiveCallAcceptSession.audio')),
      );
      expect(
        LiveCallAcceptSession.fromJson(
          fixture(),
        ).copyWith(audio: null).toJson().containsKey('audio'),
        isFalse,
      );
    });
    test('audio typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(
        audio: LiveMediaSessionAudioParam.fromJson(_object('{}')),
      );
      expect(copied.toJson()['audio'], jsonDecode('{}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(audio: Object()),
        throwsA(_safeError('LiveCallAcceptSession.audio')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'delegation': 42}),
        throwsA(_safeError('LiveCallAcceptSession.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveCallAcceptSession.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasDelegation, isFalse);
      final explicit = absent.copyWith(delegation: null);
      expect(explicit.hasDelegation, isTrue);
      expect(explicit.toJson().containsKey('delegation'), isTrue);
      expect(explicit.toJson()['delegation'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearDelegation: true);
      expect(cleared.hasDelegation, isFalse);
      expect(cleared, absent);
      expect(
        LiveCallAcceptSession.fromJson({
          ...fixture(),
          'delegation': null,
        }).toJson()['delegation'],
        isNull,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveDelegation.fromJson(_object('{"type": "client"}')),
      );
      expect(copied.toJson()['delegation'], jsonDecode('{"type": "client"}'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveCallAcceptSession.delegation')),
      );
    });
    test('input rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'input': 42}),
        throwsA(_safeError('LiveCallAcceptSession.input')),
      );
    });
    test('input omission, null and clearing follow schema', () {
      final absent = LiveCallAcceptSession.fromJson(fixture()..remove('input'));
      expect(absent.input, isNull);
      expect(absent.toJson().containsKey('input'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'input': null}),
        throwsA(_safeError('LiveCallAcceptSession.input')),
      );
      expect(
        LiveCallAcceptSession.fromJson(
          fixture(),
        ).copyWith(input: null).toJson().containsKey('input'),
        isFalse,
      );
    });
    test('input typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(input: <LiveInitialItem>[]);
      expect(copied.toJson()['input'], jsonDecode('[]'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(input: Object()),
        throwsA(_safeError('LiveCallAcceptSession.input')),
      );
    });
    test('instructions rejects wrong known values contextually', () {
      expect(
        () =>
            LiveCallAcceptSession.fromJson({...fixture(), 'instructions': 42}),
        throwsA(_safeError('LiveCallAcceptSession.instructions')),
      );
    });
    test('instructions omission, null and clearing follow schema', () {
      final absent = LiveCallAcceptSession.fromJson(
        fixture()..remove('instructions'),
      );
      expect(absent.instructions, isNull);
      expect(absent.toJson().containsKey('instructions'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(absent.hasInstructions, isFalse);
      final explicit = absent.copyWith(instructions: null);
      expect(explicit.hasInstructions, isTrue);
      expect(explicit.toJson().containsKey('instructions'), isTrue);
      expect(explicit.toJson()['instructions'], isNull);
      expect(explicit.copyWith(), explicit);
      expect(explicit, isNot(absent));
      final cleared = explicit.copyWith(clearInstructions: true);
      expect(cleared.hasInstructions, isFalse);
      expect(cleared, absent);
      expect(
        LiveCallAcceptSession.fromJson({
          ...fixture(),
          'instructions': null,
        }).toJson()['instructions'],
        isNull,
      );
    });
    test('instructions typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(instructions: 'ALTERNATE_LIVE_VALUE');
      expect(
        copied.toJson()['instructions'],
        jsonDecode('"ALTERNATE_LIVE_VALUE"'),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(instructions: Object()),
        throwsA(_safeError('LiveCallAcceptSession.instructions')),
      );
    });
    test('model rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'model': 42}),
        throwsA(_safeError('LiveCallAcceptSession.model')),
      );
    });
    test('model is required and rejects null', () {
      expect(
        () => LiveCallAcceptSession.fromJson(fixture()..remove('model')),
        throwsA(_safeError('LiveCallAcceptSession.model')),
      );
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'model': null}),
        throwsA(_safeError('LiveCallAcceptSession.model')),
      );
    });
    test('model typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(model: 'ALTERNATE_LIVE_VALUE');
      expect(copied.toJson()['model'], jsonDecode('"ALTERNATE_LIVE_VALUE"'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveCallAcceptSession.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveCallAcceptSession.fromJson(fixture()..remove('store'));
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'store': null}),
        throwsA(_safeError('LiveCallAcceptSession.store')),
      );
      expect(
        LiveCallAcceptSession.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveCallAcceptSession.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveCallAcceptSession.store')),
      );
    });
    test('type rejects wrong known values contextually', () {
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'type': 42}),
        throwsA(_safeError('LiveCallAcceptSession.type')),
      );
    });
    test('type is required and rejects null', () {
      expect(
        () => LiveCallAcceptSession.fromJson(fixture()..remove('type')),
        throwsA(_safeError('LiveCallAcceptSession.type')),
      );
      expect(
        () => LiveCallAcceptSession.fromJson({...fixture(), 'type': null}),
        throwsA(_safeError('LiveCallAcceptSession.type')),
      );
    });
  });

  group('LiveForkSessionConfigParam', () {
    Map<String, dynamic> fixture() => _object(
      '{"client": {"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}}, "delegation": {"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}}, "store": false, "audio": {"format": {"type": "audio/pcmu", "rate": 8000}}}',
    );
    test('all fields round-trip, equality/hash and private diagnostics', () {
      final model = LiveForkSessionConfigParam.fromJson(fixture());
      expect(model.toJson(), fixture());
      final equal = LiveForkSessionConfigParam.fromJson(
        Map.fromEntries(fixture().entries.toList().reversed),
      );
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
      expect(model.toString(), isNot(contains(_private)));
      expect(model.audio?.toJson(), fixture()['audio']);
      expect(model.toString(), contains('audio:'));
      expect(model.client?.toJson(), fixture()['client']);
      expect(model.toString(), contains('client:'));
      expect(model.delegation?.toJson(), fixture()['delegation']);
      expect(model.toString(), contains('delegation:'));
      expect(model.store, fixture()['store']);
      expect(model.toString(), contains('store:'));
    });
    test('raw parsed ownership is deeply immutable', () {
      final input = fixture();
      final model = LiveForkSessionConfigParam.fromJson(input);
      final expected = fixture();
      input.clear();
      expect(model.toJson(), expected);
      expect(() => model.rawJson['mutation'] = true, throwsUnsupportedError);
    });
    test('future metadata remains finite, immutable and value-significant', () {
      final future = <String, dynamic>{
        _private: <String, dynamic>{
          'list': <Object?>[_private, null, false, 1.5],
        },
      };
      final model = LiveForkSessionConfigParam.fromJson({
        ...fixture(),
        ...future,
      });
      (future[_private] as Map<String, dynamic>)['list'] = 'changed';
      expect(model.toJson()[_private], {
        'list': [_private, null, false, 1.5],
      });
      expect(
        () => (model.rawJson[_private] as Map<String, dynamic>)['list'] = null,
        throwsUnsupportedError,
      );
      expect(
        () =>
            ((model.rawJson[_private] as Map<String, dynamic>)['list']
                    as List<Object?>)
                .add(null),
        throwsUnsupportedError,
      );
      final equal = LiveForkSessionConfigParam.fromJson({
        ...fixture(),
        _private: const {
          'list': [_private, null, false, 1.5],
        },
      });
      expect(model, equal);
      expect(model.hashCode, equal.hashCode);
      expect(model, isNot(LiveForkSessionConfigParam.fromJson(fixture())));
      expect(model.toString(), isNot(contains(_private)));
      expect(model.copyWith(rawJson: const {}).toJson(), fixture());
    });
    test('malformed private overflow never leaks', () {
      final cycle = <Object?>[];
      cycle.add(cycle);
      for (final value in <Object?>[
        double.nan,
        double.infinity,
        Object(),
        cycle,
        <Object, Object>{1: _private},
      ]) {
        expect(
          () => LiveForkSessionConfigParam.fromJson({
            ...fixture(),
            _private: value,
          }),
          throwsA(_safeError('LiveForkSessionConfigParam')),
        );
      }
    });
    test('audio rejects wrong known values contextually', () {
      expect(
        () => LiveForkSessionConfigParam.fromJson({...fixture(), 'audio': 42}),
        throwsA(_safeError('LiveForkSessionConfigParam.audio')),
      );
    });
    test('audio omission, null and clearing follow schema', () {
      final absent = LiveForkSessionConfigParam.fromJson(
        fixture()..remove('audio'),
      );
      expect(absent.audio, isNull);
      expect(absent.toJson().containsKey('audio'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveForkSessionConfigParam.fromJson({...fixture(), 'audio': null}),
        throwsA(_safeError('LiveForkSessionConfigParam.audio')),
      );
      expect(
        LiveForkSessionConfigParam.fromJson(
          fixture(),
        ).copyWith(audio: null).toJson().containsKey('audio'),
        isFalse,
      );
    });
    test('audio typed copy wins over stale raw JSON', () {
      final model = LiveForkSessionConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        audio: LiveForkAudioParam.fromJson(
          _object(
            '{"format": {"type": "audio/pcmu", "rate": 8000}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['audio'],
        jsonDecode(
          '{"format": {"type": "audio/pcmu", "rate": 8000}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(audio: Object()),
        throwsA(_safeError('LiveForkSessionConfigParam.audio')),
      );
    });
    test('client rejects wrong known values contextually', () {
      expect(
        () => LiveForkSessionConfigParam.fromJson({...fixture(), 'client': 42}),
        throwsA(_safeError('LiveForkSessionConfigParam.client')),
      );
    });
    test('client omission, null and clearing follow schema', () {
      final absent = LiveForkSessionConfigParam.fromJson(
        fixture()..remove('client'),
      );
      expect(absent.client, isNull);
      expect(absent.toJson().containsKey('client'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveForkSessionConfigParam.fromJson({...fixture(), 'client': null}),
        throwsA(_safeError('LiveForkSessionConfigParam.client')),
      );
      expect(
        LiveForkSessionConfigParam.fromJson(
          fixture(),
        ).copyWith(client: null).toJson().containsKey('client'),
        isFalse,
      );
    });
    test('client typed copy wins over stale raw JSON', () {
      final model = LiveForkSessionConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        client: LiveClientConfigParam.fromJson(
          _object(
            '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['client'],
        jsonDecode(
          '{"data_channel": {"allowed_client_events": ["info", "session.input_audio.mute"], "allowed_server_events": [{"type": "response.event", "response_event": "response.output_text.delta"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(client: Object()),
        throwsA(_safeError('LiveForkSessionConfigParam.client')),
      );
    });
    test('delegation rejects wrong known values contextually', () {
      expect(
        () => LiveForkSessionConfigParam.fromJson({
          ...fixture(),
          'delegation': 42,
        }),
        throwsA(_safeError('LiveForkSessionConfigParam.delegation')),
      );
    });
    test('delegation omission, null and clearing follow schema', () {
      final absent = LiveForkSessionConfigParam.fromJson(
        fixture()..remove('delegation'),
      );
      expect(absent.delegation, isNull);
      expect(absent.toJson().containsKey('delegation'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () => LiveForkSessionConfigParam.fromJson({
          ...fixture(),
          'delegation': null,
        }),
        throwsA(_safeError('LiveForkSessionConfigParam.delegation')),
      );
      expect(
        LiveForkSessionConfigParam.fromJson(
          fixture(),
        ).copyWith(delegation: null).toJson().containsKey('delegation'),
        isFalse,
      );
    });
    test('delegation typed copy wins over stale raw JSON', () {
      final model = LiveForkSessionConfigParam.fromJson(fixture());
      final copied = model.copyWith(
        delegation: LiveResponsesDelegationUpdateParam.fromJson(
          _object(
            '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}, "alternate_metadata": {"ok": true}}',
          ),
        ),
      );
      expect(
        copied.toJson()['delegation'],
        jsonDecode(
          '{"type": "responses", "responses": {"model": "gpt-backend-future", "instructions": "PRIVATE_LIVE_PAYLOAD", "max_output_tokens": 16, "parallel_tool_calls": false, "reasoning": {"effort": "high", "summary": "detailed"}, "service_tier": "fast_tier_temp_pilot", "text": {"verbosity": "high"}, "tool_choice": "auto", "tools": [{"type": "web_search"}]}, "alternate_metadata": {"ok": true}}',
        ),
      );
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(delegation: Object()),
        throwsA(_safeError('LiveForkSessionConfigParam.delegation')),
      );
    });
    test('store rejects wrong known values contextually', () {
      expect(
        () => LiveForkSessionConfigParam.fromJson({...fixture(), 'store': 42}),
        throwsA(_safeError('LiveForkSessionConfigParam.store')),
      );
    });
    test('store omission, null and clearing follow schema', () {
      final absent = LiveForkSessionConfigParam.fromJson(
        fixture()..remove('store'),
      );
      expect(absent.store, isNull);
      expect(absent.toJson().containsKey('store'), isFalse);
      expect(absent.copyWith().toJson(), absent.toJson());
      expect(
        () =>
            LiveForkSessionConfigParam.fromJson({...fixture(), 'store': null}),
        throwsA(_safeError('LiveForkSessionConfigParam.store')),
      );
      expect(
        LiveForkSessionConfigParam.fromJson(
          fixture(),
        ).copyWith(store: null).toJson().containsKey('store'),
        isFalse,
      );
    });
    test('store typed copy wins over stale raw JSON', () {
      final model = LiveForkSessionConfigParam.fromJson(fixture());
      final copied = model.copyWith(store: true);
      expect(copied.toJson()['store'], jsonDecode('true'));
      expect(model.toJson(), fixture());
      expect(copied.copyWith(), copied);
      expect(copied.copyWith().hashCode, copied.hashCode);
      expect(
        () => model.copyWith(store: Object()),
        throwsA(_safeError('LiveForkSessionConfigParam.store')),
      );
    });
  });
}
