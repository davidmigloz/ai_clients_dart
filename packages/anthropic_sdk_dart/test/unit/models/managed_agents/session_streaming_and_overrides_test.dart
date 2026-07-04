import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionEvent event_start', () {
    test('dispatches and round-trips an agent.message preview', () {
      final json = <String, dynamic>{
        'type': 'event_start',
        'event': {'type': 'agent.message', 'id': 'evt_1'},
      };
      final event = SessionEvent.fromJson(json);
      expect(event, isA<EventStartEvent>());
      final start = event as EventStartEvent;
      expect(start.event, isA<AgentMessagePreview>());
      expect((start.event as AgentMessagePreview).id, 'evt_1');
      expect(start.toJson(), json);
    });

    test('parses an agent.thinking preview', () {
      final json = <String, dynamic>{
        'type': 'event_start',
        'event': {'type': 'agent.thinking', 'id': 'evt_2'},
      };
      final start = SessionEvent.fromJson(json) as EventStartEvent;
      expect(start.event, isA<AgentThinkingPreview>());
      expect(start.toJson(), json);
    });

    test('unknown preview type falls back gracefully', () {
      final json = <String, dynamic>{
        'type': 'event_start',
        'event': {'type': 'agent.mystery', 'id': 'evt_3'},
      };
      final start = SessionEvent.fromJson(json) as EventStartEvent;
      expect(start.event, isA<UnknownEventStartPreview>());
      expect(start.toJson(), json);
    });
  });

  group('SessionEvent event_delta', () {
    test('dispatches and round-trips a content_delta', () {
      final json = <String, dynamic>{
        'type': 'event_delta',
        'event_id': 'evt_1',
        'delta': {
          'type': 'content_delta',
          'content': {'type': 'text', 'text': 'hel'},
          'index': 0,
        },
      };
      final event = SessionEvent.fromJson(json);
      expect(event, isA<EventDeltaEvent>());
      final delta = event as EventDeltaEvent;
      expect(delta.eventId, 'evt_1');
      expect(delta.delta, isA<ContentDelta>());
      final content = delta.delta as ContentDelta;
      expect(content.index, 0);
      expect(content.content['text'], 'hel');
      expect(delta.toJson(), json);
    });

    test('omits index when absent', () {
      final json = <String, dynamic>{
        'type': 'event_delta',
        'event_id': 'evt_1',
        'delta': {
          'type': 'content_delta',
          'content': {'type': 'text', 'text': 'lo'},
        },
      };
      final delta = SessionEvent.fromJson(json) as EventDeltaEvent;
      expect((delta.delta as ContentDelta).index, isNull);
      expect(delta.toJson(), json);
    });

    test('unknown delta type falls back gracefully', () {
      final json = <String, dynamic>{
        'type': 'event_delta',
        'event_id': 'evt_1',
        'delta': {'type': 'mystery_delta', 'foo': 'bar'},
      };
      final delta = SessionEvent.fromJson(json) as EventDeltaEvent;
      expect(delta.delta, isA<UnknownEventDelta>());
      expect(delta.toJson(), json);
    });
  });

  group('InjectionLocation on env-var credentials', () {
    test('response requires both flags and round-trips', () {
      final json = <String, dynamic>{
        'type': 'environment_variable',
        'secret_name': 'API_KEY',
        'networking': {'type': 'unrestricted'},
        'injection_location': {'header': true, 'body': false},
      };
      final auth = CredentialAuth.fromJson(json);
      expect(auth, isA<EnvironmentVariableAuthResponse>());
      final env = auth as EnvironmentVariableAuthResponse;
      expect(env.injectionLocation.header, isTrue);
      expect(env.injectionLocation.body, isFalse);
      expect(env.toJson(), json);
    });

    test('create params include injection_location when set', () {
      final json = <String, dynamic>{
        'type': 'environment_variable',
        'secret_name': 'API_KEY',
        'secret_value': 'sk-123',
        'networking': {'type': 'unrestricted'},
        'injection_location': {'header': true},
      };
      final params =
          CredentialCreateAuth.fromJson(json)
              as EnvironmentVariableCreateParams;
      expect(params.injectionLocation?.header, isTrue);
      expect(params.injectionLocation?.body, isNull);
      expect(params.toJson(), json);
    });

    test('create params omit injection_location when absent', () {
      final json = <String, dynamic>{
        'type': 'environment_variable',
        'secret_name': 'API_KEY',
        'secret_value': 'sk-123',
        'networking': {'type': 'unrestricted'},
      };
      final params =
          CredentialCreateAuth.fromJson(json)
              as EnvironmentVariableCreateParams;
      expect(params.injectionLocation, isNull);
      expect(params.toJson().containsKey('injection_location'), isFalse);
    });

    test('update params round-trip injection_location', () {
      final json = <String, dynamic>{
        'type': 'environment_variable',
        'injection_location': {'body': true},
      };
      final params =
          CredentialUpdateAuth.fromJson(json)
              as EnvironmentVariableUpdateParams;
      expect(params.injectionLocation?.body, isTrue);
      expect(params.toJson(), json);
    });
  });

  group('AgentParamsWithOverrides', () {
    test('dispatches on agent_with_overrides discriminator', () {
      final agent = AgentParams.fromJson(<String, dynamic>{
        'type': 'agent_with_overrides',
        'id': 'agt_1',
      });
      expect(agent, isA<AgentParamsWithOverrides>());
    });

    test('plain agent object still yields AgentParamsObject', () {
      final agent = AgentParams.fromJson(<String, dynamic>{
        'type': 'agent',
        'id': 'agt_1',
      });
      expect(agent, isA<AgentParamsObject>());
    });

    test('string still yields AgentParamsId', () {
      expect(AgentParams.fromJson('agt_1'), isA<AgentParamsId>());
    });

    test('round-trips model and version', () {
      final json = <String, dynamic>{
        'type': 'agent_with_overrides',
        'id': 'agt_1',
        'version': 3,
        'model': 'claude-sonnet-5',
      };
      final agent = AgentParams.fromJson(json) as AgentParamsWithOverrides;
      expect(agent.version, 3);
      expect(agent.model, isNotNull);
      expect(agent.toJson(), json);
    });

    test('system tri-state: explicit null clears', () {
      const agent = AgentParamsWithOverrides(id: 'agt_1', system: null);
      final json = agent.toJson();
      expect(json.containsKey('system'), isTrue);
      expect(json['system'], isNull);
    });

    test('system tri-state: omitted preserves (key absent)', () {
      const agent = AgentParamsWithOverrides(id: 'agt_1');
      expect(agent.toJson().containsKey('system'), isFalse);
    });

    test('system tri-state: value emitted', () {
      const agent = AgentParamsWithOverrides(id: 'agt_1', system: 'be concise');
      expect(agent.toJson()['system'], 'be concise');
    });

    test('fromJson with explicit null system round-trips', () {
      final json = <String, dynamic>{
        'type': 'agent_with_overrides',
        'id': 'agt_1',
        'system': null,
      };
      final agent = AgentParams.fromJson(json) as AgentParamsWithOverrides;
      expect(agent.system, isNull);
      expect(agent.toJson(), json);
    });
  });

  group('ListSessionsResponse prev_page', () {
    test('round-trips prev_page', () {
      final json = <String, dynamic>{
        'data': <dynamic>[],
        'next_page': 'next_cursor',
        'prev_page': 'prev_cursor',
      };
      final resp = ListSessionsResponse.fromJson(json);
      expect(resp.prevPage, 'prev_cursor');
      expect(resp.nextPage, 'next_cursor');
      expect(resp.toJson(), json);
    });

    test('omits prev_page when absent', () {
      final resp = ListSessionsResponse.fromJson(const <String, dynamic>{
        'data': <dynamic>[],
      });
      expect(resp.prevPage, isNull);
      expect(resp.toJson().containsKey('prev_page'), isFalse);
    });
  });
}
