// ignore_for_file: avoid_print
// Run: dart run example/agent_files_artifacts_example.dart
// All operations use mock HTTP ($0); no API key, executor or local files.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const environmentId = 'environment_demo';
  const sessionId = 'session_demo';
  const artifactId = 'artifact_demo';
  final binary = <int>[0, 255, 128, 10, 0];
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    final parts = request.url.pathSegments;
    if (request.headers['openai-beta'] != 'agents=v1') {
      throw StateError('Missing beta header');
    }
    final file = <String, dynamic>{
      'object': 'agent.environment.file',
      'environment_id': environmentId,
      'path': '/workspace/input.bin',
      'size_bytes': binary.length,
    };
    final artifact = <String, dynamic>{
      'id': artifactId,
      'object': 'agent.session.artifact',
      'session_id': sessionId,
      'environment_id': environmentId,
      'turn_id': 'turn_completed',
      'path': '/workspace/outputs/result.bin',
      'size_bytes': binary.length,
      'created_at': 1,
    };
    Object wire;
    var status = 200;
    if (parts.last == 'content') {
      if (request.headers['accept'] != 'application/octet-stream' ||
          request.headers.containsKey('content-type')) {
        throw StateError('Invalid download headers');
      }
      return http.Response.bytes(
        binary,
        200,
        headers: {'content-type': 'application/octet-stream'},
      );
    } else if (parts.last == 'files') {
      if (request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['path'] != '/workspace/input.bin') {
          throw StateError('Invalid hosted destination');
        }
        wire = file;
        status = 201;
      } else {
        final second = request.url.queryParameters.containsKey('page');
        wire = {
          'object': 'page',
          'data': second ? <Object>[] : [file],
          'next': second ? null : 'opaque_page_token',
          'has_more': !second,
        };
      }
    } else if (parts.last == 'artifacts') {
      wire = {
        'object': 'list',
        'data': [artifact],
        'first_id': artifactId,
        'last_id': artifactId,
        'has_more': false,
      };
    } else if (request.method == 'DELETE') {
      wire = {
        'id': artifactId,
        'object': 'agent.session.artifact.deleted',
        'deleted': true,
      };
    } else if (parts.last == environmentId) {
      wire = {
        'id': environmentId,
        'object': 'agent.environment',
        'type': 'openai_hosted',
        'status': 'expired',
        'files': <Object>[],
        'skills': <Object>[],
        'plugins': <Object>[],
      };
    } else {
      wire = artifact;
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(wire)),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient.withApiKey('example-only', httpClient: transport);
  try {
    // Or use fileId(fileId: 'an-existing-files-api-id', path: ...).
    await client.agents.environments.files.create(
      environmentId,
      AgentSessionHostedEnvironmentFileConfig.inline(
        data: base64Encode(binary),
        path: '/workspace/input.bin',
      ),
    );
    final page = await client.agents.environments.files.list(
      environmentId,
      path: '/workspace',
      limit: 10,
      order: AgentListOrder.asc,
    );
    final end = await client.agents.environments.files.list(
      environmentId,
      path: '/workspace',
      limit: 10,
      order: AgentListOrder.asc,
      page: page.next,
    );
    if (end.next != null || end.hasMore) throw StateError('Invalid final page');
    final artifacts = await client.agents.sessions.artifacts.list(
      sessionId,
      environmentId: environmentId,
    );
    final artifact = await client.agents.sessions.artifacts.retrieve(
      sessionId,
      artifacts.data.single.id,
    );
    final environment = await client.agents.environments.retrieve(
      environmentId,
    );
    if (environment.status != AgentEnvironmentStatus.expired) {
      throw StateError('Expected expired environment fixture');
    }
    final bytes = await client.agents.sessions.artifacts.download(
      sessionId,
      artifact.id,
    );
    final streamed = <int>[];
    await client.agents.sessions.artifacts
        .downloadStream(sessionId, artifact.id)
        .forEach(streamed.addAll);
    if (base64Encode(bytes) != base64Encode(binary) ||
        base64Encode(streamed) != base64Encode(binary)) {
      throw StateError('Binary contents changed');
    }
    final deleted = await client.agents.sessions.artifacts.delete(
      sessionId,
      artifact.id,
    );
    if (!deleted.deleted || requests != 9) {
      throw StateError('Incomplete example');
    }
    print(
      'Staged input, paged live files, downloaded ${bytes.length} exact bytes '
      r'after environment expiry and deleted the published copy. Cost: $0.',
    );
  } finally {
    client.close();
    transport.close();
  }
}
