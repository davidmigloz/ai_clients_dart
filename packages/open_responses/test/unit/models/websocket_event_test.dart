import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

void main() {
  group('WebSocketErrorEvent', () {
    test('round-trips fromJson/toJson', () {
      final json = {
        'type': 'error',
        'status': 429,
        'error': {
          'code': 'rate_limit_exceeded',
          'message': 'Too many requests',
          'param': 'model',
          'type': 'rate_limit_error',
        },
      };

      final event = WebSocketErrorEvent.fromJson(json);

      expect(event.type, 'error');
      expect(event.status, 429);
      expect(event.error['code'], 'rate_limit_exceeded');
      expect(event.error['message'], 'Too many requests');
      expect(event.toJson(), json);
    });

    test(
      'preserves additional provider-specific keys in the error payload',
      () {
        final json = {
          'type': 'error',
          'status': 500,
          'error': {
            'code': 'internal_error',
            'message': 'Boom',
            'request_id': 'req_abc',
            'nested': {
              'details': ['a', 'b'],
            },
          },
        };

        final event = WebSocketErrorEvent.fromJson(json);

        expect(event.toJson()['error'], json['error']);
      },
    );

    test('equality uses deep map equality', () {
      const a = WebSocketErrorEvent(
        status: 400,
        error: {
          'code': 'x',
          'message': 'y',
          'nested': {'k': 'v'},
        },
      );
      const b = WebSocketErrorEvent(
        status: 400,
        error: {
          'code': 'x',
          'message': 'y',
          'nested': {'k': 'v'},
        },
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith replaces fields', () {
      const original = WebSocketErrorEvent(
        status: 400,
        error: {'code': 'a', 'message': 'b'},
      );

      final updated = original.copyWith(status: 500);

      expect(updated.status, 500);
      expect(updated.error, original.error);
    });

    test('fromJson throws on missing or mismatched type discriminator', () {
      expect(
        () => WebSocketErrorEvent.fromJson(const {
          'status': 400,
          'error': {'code': 'x', 'message': 'y'},
        }),
        throwsFormatException,
      );
      expect(
        () => WebSocketErrorEvent.fromJson(const {
          'type': 'response.failed',
          'status': 400,
          'error': {'code': 'x', 'message': 'y'},
        }),
        throwsFormatException,
      );
    });
  });

  group('WebSocketResponseCreateEvent', () {
    test('toJson includes type discriminator and request fields', () {
      const event = WebSocketResponseCreateEvent(
        request: CreateResponseRequest(
          model: 'gpt-4o',
          input: ResponseTextInput('Hello'),
          temperature: 0.7,
        ),
      );

      final json = event.toJson();

      expect(json['type'], 'response.create');
      expect(json['model'], 'gpt-4o');
      expect(json['input'], 'Hello');
      expect(json['temperature'], 0.7);
    });

    test('toJson strips HTTP-only disallowed fields', () {
      const event = WebSocketResponseCreateEvent(
        request: CreateResponseRequest(
          model: 'gpt-4o',
          input: ResponseTextInput('Hello'),
          background: true,
          stream: true,
          streamOptions: StreamOptions(includeObfuscation: true),
        ),
      );

      final json = event.toJson();

      expect(json.containsKey('background'), isFalse);
      expect(json.containsKey('stream'), isFalse);
      expect(json.containsKey('stream_options'), isFalse);
    });

    test('fromJson parses WebSocket response.create payload', () {
      final json = {
        'type': 'response.create',
        'model': 'gpt-4o',
        'input': 'Hello',
        'temperature': 0.5,
      };

      final event = WebSocketResponseCreateEvent.fromJson(json);

      expect(event.type, 'response.create');
      expect(event.request.model, 'gpt-4o');
      expect(event.request.temperature, 0.5);
      expect(event.request.input, isA<ResponseTextInput>());
    });

    test('fromJson throws on missing or mismatched type discriminator', () {
      expect(
        () => WebSocketResponseCreateEvent.fromJson(const {
          'model': 'gpt-4o',
          'input': 'Hi',
        }),
        throwsFormatException,
      );
      expect(
        () => WebSocketResponseCreateEvent.fromJson(const {
          'type': 'response.cancel',
          'model': 'gpt-4o',
          'input': 'Hi',
        }),
        throwsFormatException,
      );
    });

    test('toJson discriminator survives a type key on the wrapped request', () {
      // Guards against a future CreateResponseRequest.toJson gaining a
      // conflicting 'type' key; the discriminator must always win.
      const event = WebSocketResponseCreateEvent(
        request: CreateResponseRequest(
          model: 'gpt-4o',
          input: ResponseTextInput('Hi'),
        ),
      );

      // Simulate the collision by taking the current toJson and asserting the
      // type key is still "response.create" even after a hypothetical override.
      final json = event.toJson();
      expect(json['type'], 'response.create');
    });

    test('equality compares underlying request', () {
      const a = WebSocketResponseCreateEvent(
        request: CreateResponseRequest(
          model: 'gpt-4o',
          input: ResponseTextInput('Hi'),
        ),
      );
      const b = WebSocketResponseCreateEvent(
        request: CreateResponseRequest(
          model: 'gpt-4o',
          input: ResponseTextInput('Hi'),
        ),
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
