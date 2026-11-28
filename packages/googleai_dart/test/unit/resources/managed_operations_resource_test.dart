import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

http.Response _json(Map<String, Object?> value) => http.Response.bytes(
  utf8.encode(jsonEncode(value)),
  200,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('creates and fetches a beta agent with an optional parent', () async {
    const agentId = 'custom/notes+preview';
    const parent = 'projects/test-project/locations/global';
    const wireAgent = {
      'id': agentId,
      'base_agent': 'antigravity-preview-09-2026',
      'description': 'résumé editor',
      'agent_config': {'type': 'antigravity', 'max_total_tokens': '512'},
    };
    final client = GoogleAIClient(
      config: const GoogleAIConfig(
        interactionsApiVersion: ApiVersion.v1,
        authProvider: ApiKeyProvider(
          'fixture',
          placement: AuthPlacement.header,
        ),
      ),
      httpClient: MockClient((request) async {
        expect(request.headers['x-goog-api-key'], 'fixture');
        expect(request.headers['api-revision'], '2026-05-20');
        if (request.method == 'POST') {
          expect(request.url.path, '/v1beta/agents');
          expect(request.url.queryParameters, {'parent': parent});
          expect(jsonDecode(utf8.decode(request.bodyBytes)), wireAgent);
        } else {
          expect(request.method, 'GET');
          expect(request.url.pathSegments, ['v1beta', 'agents', agentId]);
          expect(request.url.path, contains('custom%2Fnotes%2Bpreview'));
          expect(request.url.query, isEmpty);
        }
        return _json(wireAgent);
      }),
    );
    addTearDown(client.close);

    final created = await client.agents.create(
      parent: parent,
      agent: const Agent(
        id: agentId,
        baseAgent: 'antigravity-preview-09-2026',
        description: 'résumé editor',
        agentConfig: AntigravityAgentConfig(maxTotalTokens: '512'),
      ),
    );
    expect(created.id, agentId);
    expect(created.description, 'résumé editor');
    final fetched = await client.agents.get(agentId);
    expect(fetched.toJson(), wireAgent);
  });

  test(
    'uses the full agent template and documented trigger run and update routes',
    () async {
      const triggerId = 'daily/review#1';
      const template = {
        'agent': 'antigravity-preview-09-2026',
        'input': 'Summarize notes.',
        'system_instruction': 'Use the saved notes.',
        'tools': [
          {'type': 'google_search'},
        ],
        'response_modalities': ['text'],
        'response_mime_type': 'text/plain',
        'stream': false,
        'environment': 'remote',
        'labels': {'report': 'daily'},
      };
      const triggerBody = {
        'interaction': template,
        'schedule': '0 11 * * *',
        'time_zone': 'UTC',
        'execution_timeout_seconds': 600,
        'max_consecutive_failures': 2,
      };
      const trigger = {'id': triggerId, ...triggerBody, 'status': 'paused'};
      const execution = {
        'id': 'execution-1',
        'trigger_id': triggerId,
        'interaction_id': 'interaction-1',
        'status': 'in_progress',
      };
      var requests = 0;
      final client = GoogleAIClient(
        httpClient: MockClient((request) async {
          final segments = request.url.pathSegments;
          expect(request.headers['api-revision'], '2026-05-20');
          switch (requests++) {
            case 0:
              expect(request.method, 'POST');
              expect(segments, ['v1beta', 'triggers']);
              expect(jsonDecode(request.body), triggerBody);
              return _json(trigger);
            case 1:
              expect(request.method, 'PATCH');
              expect(segments, ['v1beta', 'triggers', triggerId]);
              expect(request.url.queryParameters, isEmpty);
              expect(jsonDecode(request.body), {
                'id': triggerId,
                'trigger': {'status': 'paused', 'display_name': 'Daily digest'},
                'update_mask': 'status,display_name',
              });
              return _json(trigger);
            case 2:
              expect(request.method, 'POST');
              expect(segments, ['v1beta', 'triggers', triggerId, 'executions']);
              expect(request.bodyBytes, isEmpty);
              return _json(execution);
            case 3:
              expect(request.method, 'GET');
              expect(segments, ['v1beta', 'triggers', triggerId, 'executions']);
              expect(request.url.queryParameters, {
                'filter': 'status=in_progress',
                'page_size': '7',
                'page_token': 'page+/=',
              });
              return _json({
                'trigger_executions': [execution],
                'next_page_token': 'next',
              });
            default:
              fail('Unexpected request ${request.url}.');
          }
        }),
      );
      addTearDown(client.close);

      final created = await client.triggers.create(
        trigger: const TriggerCreateParams(
          interaction: CreateAgentInteractionParams(
            agent: 'antigravity-preview-09-2026',
            input: InteractionInput.text('Summarize notes.'),
            systemInstruction: 'Use the saved notes.',
            tools: [GoogleSearchTool()],
            responseModalities: [InteractionResponseModality.text],
            responseMimeType: 'text/plain',
            stream: false,
            environment: EnvironmentConfigOrId.id('remote'),
            labels: {'report': 'daily'},
          ),
          schedule: '0 11 * * *',
          timeZone: 'UTC',
          executionTimeoutSeconds: 600,
          maxConsecutiveFailures: 2,
        ),
      );
      expect(created.interaction.toJson(), template);
      final paused = await client.triggers.update(
        id: triggerId,
        update: const TriggerUpdate(
          status: TriggerStatus.paused,
          displayName: 'Daily digest',
        ),
        updateMask: 'status,display_name',
      );
      expect(paused.status, TriggerStatus.paused);
      final run = await client.triggers.run(triggerId: triggerId);
      expect(run.interactionId, 'interaction-1');
      final page = await client.triggers.listExecutions(
        triggerId: triggerId,
        filter: 'status=in_progress',
        pageSize: 7,
        pageToken: 'page+/=',
      );
      expect(page.triggerExecutions?.single.id, 'execution-1');
      expect(page.nextPageToken, 'next');
      expect(requests, 4);
    },
  );

  test(
    'passes beta response formats on unary and streaming custom agents',
    () async {
      const agent = 'my-custom-agent';
      const fixture = {'id': 'int-1', 'agent': agent, 'status': 'in_progress'};
      final client = GoogleAIClient(
        httpClient: MockClient((request) async {
          final stream = request.url.queryParameters['alt'] == 'sse';
          expect(request.url.path, '/v1beta/interactions');
          expect(request.headers['api-revision'], '2026-05-20');
          expect(jsonDecode(request.body), {
            'agent': agent,
            'input': 'Summarize notes.',
            'response_modalities': ['text'],
            'response_mime_type': 'text/plain',
            if (stream) 'stream': true,
          });
          if (!stream) return _json(fixture);
          final event = jsonEncode({
            'event_type': 'interaction.created',
            'interaction': fixture,
          });
          return http.Response(
            'data: $event\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          );
        }),
      );
      addTearDown(client.close);
      const input = InteractionInput.text('Summarize notes.');

      final unary = await client.interactions.createWithAgent(
        agent: agent,
        input: input,
        responseModalities: const [InteractionResponseModality.text],
        responseMimeType: 'text/plain',
      );
      expect(unary.id, 'int-1');
      final events = await client.interactions
          .createWithAgentStream(
            agent: agent,
            input: input,
            responseModalities: const [InteractionResponseModality.text],
            responseMimeType: 'text/plain',
          )
          .toList();
      expect(events.single, isA<InteractionCreatedEvent>());
    },
  );

  test(
    'creates a webhook and rotates the signing secret without logging it',
    () async {
      final previousHierarchy = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      addTearDown(() => hierarchicalLoggingEnabled = previousHierarchy);
      final logger = Logger('GoogleAI.HTTP');
      final previousLevel = logger.level;
      addTearDown(() => logger.level = previousLevel);
      final logs = <LogRecord>[];
      final log = logger.onRecord.listen(logs.add);
      addTearDown(log.cancel);
      const webhookId = 'hook:tenant/preview';
      const webhookFields = {
        'uri': 'https://example.com/hook',
        'subscribed_events': ['interaction.completed'],
        'name': 'Réception',
      };
      var requests = 0;
      final client = GoogleAIClient(
        config: const GoogleAIConfig(logLevel: Level.FINE),
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          switch (requests++) {
            case 0:
              expect(request.url.path, '/v1beta/webhooks');
              expect(request.url.queryParameters, {'webhook_id': webhookId});
              expect(jsonDecode(utf8.decode(request.bodyBytes)), {
                'webhook': webhookFields,
              });
              return _json({
                ...webhookFields,
                'id': webhookId,
                'new_signing_secret': 'fixture-created-secret',
              });
            case 1:
              expect(
                request.url.path,
                '/v1beta/webhooks/hook%3Atenant%2Fpreview:rotateSigningSecret',
              );
              expect(request.url.queryParameters, isEmpty);
              expect(jsonDecode(request.body), {
                'revocation_behavior': 'revoke_previous_secrets_after_h24',
              });
              return _json({'secret': 'fixture-rotated-secret'});
            default:
              fail('Unexpected request ${request.url}.');
          }
        }),
      );
      addTearDown(client.close);

      final webhook = await client.webhooks.create(
        webhookId: webhookId,
        webhook: const Webhook(
          uri: 'https://example.com/hook',
          subscribedEvents: ['interaction.completed'],
          id: 'response-only',
          name: 'Réception',
          state: WebhookState.disabled,
          newSigningSecret: 'fixture-existing-secret',
        ),
      );
      expect(webhook.name, 'Réception');
      expect(webhook.newSigningSecret, 'fixture-created-secret');
      final rotated = await client.webhooks.rotateSigningSecret(
        id: webhookId,
        request: const RotateSigningSecretRequest(
          revocationBehavior:
              SigningSecretRevocationBehavior.revokePreviousSecretsAfterH24,
        ),
      );
      expect(rotated.secret, 'fixture-rotated-secret');
      expect(logs.any((record) => record.message.startsWith('Body:')), isTrue);
      expect(
        logs.map((record) => record.message).join(),
        isNot(contains('fixture-created-secret')),
      );
      expect(
        logs.map((record) => record.message).join(),
        isNot(contains('fixture-rotated-secret')),
      );
      expect(requests, 2);
    },
  );
}
