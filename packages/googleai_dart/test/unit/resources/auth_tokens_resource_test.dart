import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/auth_tokens_resource.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

http.StreamedResponse _jsonResponse(Object? body, {int status = 200}) {
  final encoded = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream.value(encoded),
    status,
    headers: {
      'content-type': 'application/json',
      'content-length': '${encoded.length}',
    },
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  late _MockHttpClient mockHttpClient;
  late AuthTokensResource resource;
  late List<http.BaseRequest> capturedRequests;
  late List<List<int>?> capturedBodies;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      final req = invocation.positionalArguments.first as http.BaseRequest;
      capturedRequests.add(req);
      if (req is http.Request) {
        capturedBodies.add(req.bodyBytes);
      } else {
        capturedBodies.add(null);
      }
      return _jsonResponse(body, status: status);
    });
  }

  setUp(() {
    mockHttpClient = _MockHttpClient();
    capturedRequests = <http.BaseRequest>[];
    capturedBodies = <List<int>?>[];

    const config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
      authProvider: ApiKeyProvider('test-key'),
    );
    resource = AuthTokensResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('AuthTokensResource', () {
    test('create() POSTs a flat AuthToken body to /auth_tokens', () async {
      stubJsonResponse({'name': 'auth_tokens/abc123'});

      final token = await resource.create(
        authToken: const AuthToken(
          uses: 1,
          fieldMask: 'bidiGenerateContentSetup',
        ),
      );

      expect(capturedRequests, hasLength(1));
      final req = capturedRequests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/v1beta/auth_tokens');

      final body =
          jsonDecode(utf8.decode(capturedBodies.single!))
              as Map<String, dynamic>;
      // Body is the flat AuthToken (no `authToken` wrapper).
      expect(body.containsKey('authToken'), isFalse);
      expect(body['uses'], 1);
      expect(body['fieldMask'], 'bidiGenerateContentSetup');

      expect(token.name, 'auth_tokens/abc123');
    });
  });
}
