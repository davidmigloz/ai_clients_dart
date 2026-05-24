import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/interactions_resource.dart';
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
  late InteractionsResource resource;
  late List<http.BaseRequest> capturedRequests;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      capturedRequests.add(
        invocation.positionalArguments.first as http.BaseRequest,
      );
      return _jsonResponse(body, status: status);
    });
  }

  setUp(() {
    mockHttpClient = _MockHttpClient();
    capturedRequests = <http.BaseRequest>[];

    const config = GoogleAIConfig(
      baseUrl: 'https://generativelanguage.googleapis.com',
      authProvider: ApiKeyProvider('test-key'),
    );
    resource = InteractionsResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('InteractionsResource Api-Revision header', () {
    test('create() opts into the new schema via Api-Revision', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.create(
        model: 'gemini-3.5-flash',
        input: const InteractionInput.text('hi'),
      );

      final req = capturedRequests.single;
      expect(req.headers['Api-Revision'], '2026-05-20');
    });

    test('get() also sends the Api-Revision header', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.get('i_1');

      expect(capturedRequests.single.headers['Api-Revision'], '2026-05-20');
    });
  });

  group('InteractionsResource responseFormat wiring', () {
    test('create() serializes response_format into the body', () async {
      stubJsonResponse({
        'id': 'i_1',
        'status': 'completed',
        'steps': <dynamic>[],
      });

      await resource.create(
        model: 'gemini-3.5-flash',
        input: const InteractionInput.text('hi'),
        responseFormat: const InteractionResponseFormatConfig.single(
          InteractionTextResponseFormat(
            mimeType: InteractionTextResponseFormatMimeType.applicationJson,
            schema: {'type': 'object'},
          ),
        ),
      );

      final req = capturedRequests.single as http.Request;
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      final rf = body['response_format'] as Map<String, dynamic>;
      expect(rf['type'], 'text');
      expect(rf['mime_type'], 'application/json');
      expect(rf['schema'], {'type': 'object'});
    });
  });
}
