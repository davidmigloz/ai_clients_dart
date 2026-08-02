import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/triggers_resource.dart';
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

/// A minimal trigger response payload including the fields the spec marks
/// required (`id`, `interaction`, `schedule`, `time_zone`).
Map<String, dynamic> _triggerJson({
  String id = 'trg_1',
  Map<String, dynamic>? extra,
}) => {
  'id': id,
  'interaction': {'id': 'i_template', 'status': 'completed'},
  'schedule': '0 * * * *',
  'time_zone': 'UTC',
  ...?extra,
};

void main() {
  setUpAll(() {
    registerFallbackValue(
      http.Request('GET', Uri.parse('https://example.com')),
    );
  });

  late _MockHttpClient mockHttpClient;
  late TriggersResource resource;
  late List<http.BaseRequest> capturedRequests;
  late List<List<int>?> capturedBodies;

  void stubJsonResponse(Object? body, {int status = 200}) {
    when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
      final req = invocation.positionalArguments.first as http.BaseRequest;
      capturedRequests.add(req);
      capturedBodies.add(req is http.Request ? req.bodyBytes : null);
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
    resource = TriggersResource(
      config: config,
      httpClient: mockHttpClient,
      interceptorChain: InterceptorChain(
        interceptors: const [],
        httpClient: mockHttpClient,
      ),
      requestBuilder: const RequestBuilder(config: config),
    );
  });

  group('TriggersResource', () {
    test(
      'list() GETs /triggers with filter and pagination query params',
      () async {
        stubJsonResponse({
          'triggers': [_triggerJson()],
          'next_page_token': 'tok',
        });

        final result = await resource.list(
          filter: 'status=active',
          pageSize: 5,
          pageToken: 'p',
        );

        final req = capturedRequests.single;
        expect(req.method, 'GET');
        expect(req.url.path, '/v1beta/triggers');
        expect(req.headers['Api-Revision'], '2026-05-20');
        expect(req.url.queryParameters['filter'], 'status=active');
        expect(req.url.queryParameters['page_size'], '5');
        expect(req.url.queryParameters['page_token'], 'p');
        expect(result.triggers, hasLength(1));
        expect(result.nextPageToken, 'tok');
      },
    );

    test(
      'create() POSTs the trigger and sends the Api-Revision header',
      () async {
        stubJsonResponse(_triggerJson());

        final result = await resource.create(
          trigger: const TriggerCreateParams(
            interaction: CreateModelInteractionParams(
              model: 'gemini-3.5-flash',
            ),
            schedule: '0 * * * *',
            timeZone: 'UTC',
          ),
        );

        final req = capturedRequests.single;
        expect(req.method, 'POST');
        expect(req.url.path, '/v1beta/triggers');
        expect(req.headers['Api-Revision'], '2026-05-20');
        final body =
            jsonDecode(utf8.decode(capturedBodies.single!))
                as Map<String, dynamic>;
        expect(body['schedule'], '0 * * * *');
        expect(body['time_zone'], 'UTC');
        expect((body['interaction'] as Map)['model'], 'gemini-3.5-flash');
        expect(result.id, 'trg_1');
      },
    );

    test('get() GETs /triggers/{id}', () async {
      stubJsonResponse(_triggerJson());

      final result = await resource.get('trg_1');

      final req = capturedRequests.single;
      expect(req.method, 'GET');
      expect(req.url.path, '/v1beta/triggers/trg_1');
      expect(req.headers['Api-Revision'], '2026-05-20');
      expect(result.id, 'trg_1');
    });

    test('update() PATCHes /triggers/{id} with the update body', () async {
      stubJsonResponse(_triggerJson(extra: {'status': 'paused'}));

      final result = await resource.update(
        id: 'trg_1',
        update: const TriggerUpdate(status: TriggerStatus.paused),
      );

      final req = capturedRequests.single;
      expect(req.method, 'PATCH');
      expect(req.url.path, '/v1beta/triggers/trg_1');
      expect(req.headers['Api-Revision'], '2026-05-20');
      final body =
          jsonDecode(utf8.decode(capturedBodies.single!))
              as Map<String, dynamic>;
      expect(body['status'], 'paused');
      expect(result.status, TriggerStatus.paused);
    });

    test('delete() DELETEs /triggers/{id}', () async {
      stubJsonResponse(<String, dynamic>{});

      await resource.delete('trg_1');

      final req = capturedRequests.single;
      expect(req.method, 'DELETE');
      expect(req.url.path, '/v1beta/triggers/trg_1');
      expect(req.headers['Api-Revision'], '2026-05-20');
    });

    test(
      'listExecutions() GETs /triggers/{id}/executions with pagination',
      () async {
        stubJsonResponse({
          'trigger_executions': [
            {'id': 'exec_1', 'trigger_id': 'trg_1'},
          ],
          'next_page_token': 'tok',
        });

        final result = await resource.listExecutions(
          triggerId: 'trg_1',
          pageSize: 5,
          pageToken: 'p',
        );

        final req = capturedRequests.single;
        expect(req.method, 'GET');
        expect(req.url.path, '/v1beta/triggers/trg_1/executions');
        expect(req.headers['Api-Revision'], '2026-05-20');
        expect(req.url.queryParameters['page_size'], '5');
        expect(req.url.queryParameters['page_token'], 'p');
        expect(result.triggerExecutions, hasLength(1));
        expect(result.nextPageToken, 'tok');
      },
    );

    test('run() POSTs an empty body to /triggers/{id}/executions', () async {
      stubJsonResponse({'id': 'exec_1', 'trigger_id': 'trg_1'});

      final result = await resource.run(triggerId: 'trg_1');

      final req = capturedRequests.single;
      expect(req.method, 'POST');
      expect(req.url.path, '/v1beta/triggers/trg_1/executions');
      expect(req.headers['Api-Revision'], '2026-05-20');
      expect(utf8.decode(capturedBodies.single!), '{}');
      expect(result.id, 'exec_1');
    });
  });
}
