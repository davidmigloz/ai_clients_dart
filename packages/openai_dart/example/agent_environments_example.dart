// ignore_for_file: avoid_print
// Run: dart run example/agent_environments_example.dart
// All eight operations use mock HTTP ($0), with no key or paid prewarming.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var requests = 0;
  var template = <String, dynamic>{
    'id': 'template_demo',
    'object': 'agent.environment.template',
    'name': null,
    'created_at': 1,
    'updated_at': 1,
    'packages': {'npm': <String>[], 'python': <String>[], 'system': <String>[]},
    'network': {'access': 'disabled', 'allowed_domains': <String>[]},
    'desktop': {'enabled': false},
    'capability_directories': <String>[],
    'files': <Object>[],
    'skills': <Object>[],
    'plugins': <Object>[],
  };
  final environment = <String, dynamic>{
    'id': 'environment_demo',
    'object': 'agent.environment',
    'type': 'openai_hosted',
    'status': 'ready',
    'files': <Object>[],
    'skills': <Object>[],
    'plugins': <Object>[],
  };
  final transport = MockClient((request) async {
    requests++;
    final parts = request.url.pathSegments;
    final isTemplate = parts.contains('templates');
    final collection =
        parts.last == (isTemplate ? 'templates' : 'environments');
    Object wire;
    var status = 200;
    if (request.method == 'DELETE') {
      wire = {
        'id': 'template_demo',
        'object': 'agent.environment.template.deleted',
        'deleted': true,
      };
    } else if (request.method == 'POST') {
      if (collection) status = 201;
      if (isTemplate) {
        final body =
            jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
        template = {
          ...template,
          if (body.containsKey('name')) 'name': body['name'],
        };
        // These are safe service views: never mirror env/commands/archive data.
      }
      wire = isTemplate ? template : environment;
    } else if (collection) {
      final resource = isTemplate ? template : environment;
      wire = {
        'object': 'list',
        'data': [resource],
        'first_id': resource['id'],
        'last_id': resource['id'],
        'has_more': false,
      };
    } else {
      wire = isTemplate ? template : environment;
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(wire)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  final client = OpenAIClient.withApiKey(
    'synthetic-offline',
    httpClient: transport,
  );
  try {
    final templates = client.agents.environments.templates;
    final template = await templates.create(
      CreateAgentEnvironmentTemplateRequest(
        name: 'Reusable setup',
        packages: AgentSessionEnvironmentPackagesConfig(
          python: const ['pandas'],
        ),
        network: AgentSessionNetworkPolicyConfig(
          access: AgentSessionNetworkAccessConfig.disabled,
        ),
        setupCommands: [
          AgentSessionSetupCommandConfig(command: 'mkdir -p /workspace/output'),
        ],
      ),
    );
    await templates.retrieve(template.id);
    await templates.list(limit: 20, order: AgentListOrder.desc);
    await templates.update(
      template.id,
      UpdateAgentEnvironmentTemplateRequest(
        clearNetwork: true,
        clearDesktop: true,
        name: 'Updated setup',
      ),
    );
    final environment = await client.agents.environments.create(
      CreateAgentEnvironmentRequest(
        environment: AgentPrewarmEnvironment.openaiHosted(
          environmentTemplateId: template.id,
        ),
      ),
      idempotencyKey: 'my-application-prewarm-001',
    );
    await client.agents.environments.list(
      type: AgentEnvironmentType.openaiHosted,
    );
    await client.agents.environments.retrieve(environment.id);
    await templates.delete(template.id);
    if (requests != 8) throw StateError('Expected all eight operations');
    print('Completed $requests mocked operations; API cost: \$0.');
    // A session may attach this environment through its own environmentId.
    // Deleting the template does not imply environment/session/artifact cleanup.
  } finally {
    client.close();
    transport.close();
  }
}
