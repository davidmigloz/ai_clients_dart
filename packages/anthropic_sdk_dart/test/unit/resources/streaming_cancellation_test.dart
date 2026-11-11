@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/client/interceptor_chain.dart';
import 'package:anthropic_sdk_dart/src/client/request_builder.dart';
import 'package:anthropic_sdk_dart/src/resources/base_resource.dart';
import 'package:anthropic_sdk_dart/src/resources/streaming_resource.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class Resource extends ResourceBase with StreamingResource {
  Resource(http.Client client, AnthropicConfig config)
    : super(
        config: config,
        httpClient: client,
        interceptorChain: InterceptorChain(
          interceptors: [],
          httpClient: client,
        ),
        requestBuilder: RequestBuilder(config: config),
      );
}

class Transport extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  final sent = StreamController<http.BaseRequest>.broadcast();
  final responses = <Completer<http.StreamedResponse>>[];
  bool closed = false;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    final response = Completer<http.StreamedResponse>();
    responses.add(response);
    sent.add(request);
    return response.future;
  }

  @override
  void close() {
    closed = true;
  }
}

class DelayedAuth implements AuthProvider {
  final credentials = Completer<AuthCredentials>();
  @override
  Future<AuthCredentials> getCredentials() => credentials.future;
}

void main() {
  for (final method in ['GET', 'POST']) {
    test(
      '$method aborts before headers without closing sibling request',
      () async {
        final transport = Transport();
        final resource = Resource(transport, const AnthropicConfig());
        final abort = Completer<void>();
        Stream<Map<String, dynamic>> request(Future<void>? signal) =>
            method == 'GET'
            ? resource.getStream('/test', abortTrigger: signal)
            : resource.postStream('/test', body: {}, abortTrigger: signal);
        final firstSend = transport.sent.stream.first;
        final first = request(abort.future).toList();
        await firstSend.timeout(const Duration(seconds: 1));
        final siblingSend = transport.sent.stream.first;
        final sibling = request(null).toList();
        await siblingSend.timeout(const Duration(seconds: 1));
        expect(transport.requests, hasLength(2));
        final native =
            (transport.requests.first as http.Abortable).abortTrigger!;
        var siblingAborted = false;
        unawaited(
          (transport.requests.last as http.Abortable).abortTrigger!.then((_) {
            siblingAborted = true;
          }),
        );
        abort.complete();
        await expectLater(
          first.timeout(const Duration(seconds: 1)),
          throwsA(isA<AbortedException>()),
        );
        await native.timeout(const Duration(seconds: 1));
        expect(siblingAborted, isFalse);
        expect(transport.closed, isFalse);
        transport.responses[1].complete(
          http.StreamedResponse(Stream.value([]), 200),
        );
        expect(await sibling, isEmpty);
        transport.responses[0].complete(
          http.StreamedResponse(Stream.value([]), 200),
        );
        await transport.sent.close();
      },
    );
  }

  test('stalled body is canceled on abort', () async {
    final transport = Transport();
    final resource = Resource(transport, const AnthropicConfig());
    final bodyCanceled = Completer<void>();
    final body = StreamController<List<int>>(onCancel: bodyCanceled.complete);
    final abort = Completer<void>();
    final sent = transport.sent.stream.first;
    final result = resource
        .getStream('/test', abortTrigger: abort.future)
        .toList();
    await sent.timeout(const Duration(seconds: 1));
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    await Future<void>.delayed(Duration.zero);
    abort.complete();
    await expectLater(
      result.timeout(const Duration(seconds: 1)),
      throwsA(isA<AbortedException>()),
    );
    await bodyCanceled.future.timeout(const Duration(seconds: 1));
    await body.close();
    await transport.sent.close();
  });

  test('listener cancellation aborts pending request', () async {
    final transport = Transport();
    final resource = Resource(transport, const AnthropicConfig());
    final subscription = resource.getStream('/test').listen((_) {});
    await Future<void>.delayed(Duration.zero);
    final native = (transport.requests.single as http.Abortable).abortTrigger!;
    await subscription.cancel().timeout(const Duration(seconds: 1));
    await native.timeout(const Duration(seconds: 1));
    transport.responses.single.complete(
      http.StreamedResponse(Stream.value([]), 200),
    );
    await transport.sent.close();
  });

  test('public message listener cancellation aborts pending request', () async {
    final transport = Transport();
    final client = AnthropicClient(
      config: const AnthropicConfig(),
      httpClient: transport,
    );
    final subscription = client.messages
        .createStream(
          MessageCreateRequest(
            model: 'test',
            maxTokens: 1,
            messages: [InputMessage.user('Hi')],
          ),
        )
        .listen((_) {});
    await Future<void>.delayed(Duration.zero);
    final native = (transport.requests.single as http.Abortable).abortTrigger!;
    await subscription.cancel().timeout(const Duration(seconds: 1));
    await native.timeout(const Duration(seconds: 1));
    transport.responses.single.complete(
      http.StreamedResponse(Stream.value([]), 200),
    );
    client.close();
    await transport.sent.close();
  });

  test('native transport aborts while waiting for headers', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<HttpRequest>();
    final serverSubscription = server.listen(received.complete);
    final client = AnthropicClient(
      config: AnthropicConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
    );
    final abort = Completer<void>();
    final result = client.messages
        .createStream(
          MessageCreateRequest(
            model: 'test',
            maxTokens: 1,
            messages: [InputMessage.user('Hi')],
          ),
          abortTrigger: abort.future,
        )
        .toList();
    final request = await received.future.timeout(const Duration(seconds: 1));
    abort.complete();
    await expectLater(
      result.timeout(const Duration(seconds: 1)),
      throwsA(isA<AbortedException>()),
    );
    await request.response.close().catchError((Object _) {});
    client.close();
    await serverSubscription.cancel();
    await server.close(force: true);
  });

  test('pre-cancel prevents request', () async {
    final transport = Transport();
    final result = Resource(
      transport,
      const AnthropicConfig(),
    ).getStream('/test', abortTrigger: Future.value()).toList();
    await expectLater(result, throwsA(isA<AbortedException>()));
    await Future<void>.delayed(Duration.zero);
    expect(transport.requests, isEmpty);
    await transport.sent.close();
  });

  test('abort during authentication prevents request', () async {
    final auth = DelayedAuth();
    final transport = Transport();
    final abort = Completer<void>();
    final result = Resource(
      transport,
      AnthropicConfig(authProvider: auth),
    ).getStream('/test', abortTrigger: abort.future).toList();
    await Future<void>.delayed(Duration.zero);
    abort.complete();
    await expectLater(
      result.timeout(const Duration(seconds: 1)),
      throwsA(isA<AbortedException>()),
    );
    auth.credentials.complete(const NoAuthCredentials());
    await Future<void>.delayed(Duration.zero);
    expect(transport.requests, isEmpty);
    await transport.sent.close();
  });
}
