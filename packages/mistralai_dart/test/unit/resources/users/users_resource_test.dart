@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('UsersResource', () {
    late http.Request captured;

    MistralClient clientReturning(Map<String, dynamic> body) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    test('me issues GET /v1/users/me and parses the identity', () async {
      final client = clientReturning({
        'id': 'user-1',
        'email': 'user@example.com',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
      });
      addTearDown(client.close);

      final identity = await client.users.me();

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/users/me');
      expect(identity.id, 'user-1');
      expect(identity.email, 'user@example.com');
      expect(identity.firstName, 'Ada');
      expect(identity.lastName, 'Lovelace');
    });
  });
}
