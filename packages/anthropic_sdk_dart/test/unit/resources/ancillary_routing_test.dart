import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('memory child deletion cannot dispatch at its parent route', () async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      return http.Response('{}', 400);
    });
    addTearDown(transport.close);
    final client = AnthropicClient(
      config: const AnthropicConfig(baseUrl: 'https://fixture.invalid/proxy'),
      httpClient: transport,
    );
    addTearDown(client.close);
    final memories = client.memoryStores.memories('memstore_fixture');
    for (final id in ['', '.', '..', '..;fixture']) {
      await expectLater(() => memories.delete(id), throwsArgumentError);
    }
    expect(requests, isEmpty);
  });

  test(
    'refresh status constructor cannot override its typed discriminator',
    () {
      const response = RefreshObject(status: CredentialRefreshStatus.succeeded);
      expect(response.toJson()['status'], 'succeeded');
      expect(
        () => Function.apply(RefreshObject.new, const [], const {
          #status: CredentialRefreshStatus.succeeded,
          #rawStatus: 'failed',
        }),
        throwsA(isA<NoSuchMethodError>()),
      );
    },
  );
}
