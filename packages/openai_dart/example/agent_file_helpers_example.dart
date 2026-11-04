/// Portable selected uploads, completed results and exact artifact bytes.
/// Entirely synthetic HTTP/SSE: no API key, hosted execution or API charges.
library;

// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  const destination = '/workspace/input.bin';
  const outputPath = '/workspace/outputs/result.bin';
  final binary = [0, 255, 128, 13, 10];
  var calls = 0;
  final transport = MockClient.streaming((request, body) async {
    calls++;
    if (request.url.path.endsWith('/content')) {
      return http.StreamedResponse(
        Stream.value(binary),
        200,
        headers: {'content-type': 'application/octet-stream'},
      );
    }
    Object json;
    var status = 200;
    if (request.url.path.endsWith('/files')) {
      if (request.url.path.contains('/environments/')) {
        final staged =
            jsonDecode(
                  utf8.decode(await body.expand((chunk) => chunk).toList()),
                )
                as Map<String, dynamic>;
        if (staged['file_id'] != 'file_demo' || staged['path'] != destination) {
          throw StateError('Unexpected staging configuration');
        }
        json = {
          'object': 'agent.environment.file',
          'environment_id': 'environment_demo',
          'path': destination,
          'size_bytes': binary.length,
        };
        status = 201;
      } else {
        await body.drain<void>();
        json = {
          'id': 'file_demo',
          'object': 'file',
          'bytes': binary.length,
          'created_at': 0,
          'filename': 'selected.bin',
          'purpose': 'user_data',
          'status': 'processed',
        };
      }
    } else if (request.url.path.endsWith('/artifacts')) {
      json = {
        'object': 'list',
        'first_id': 'artifact_demo',
        'last_id': 'artifact_demo',
        'has_more': false,
        'data': [
          {
            'id': 'artifact_demo',
            'object': 'agent.session.artifact',
            'created_at': 1,
            'session_id': 'session_demo',
            'turn_id': 'turn_demo',
            'environment_id': 'environment_demo',
            'path': outputPath,
            'size_bytes': binary.length,
          },
        ],
      };
    } else if (request.url.path.endsWith('/sessions') &&
        request.method == 'POST') {
      await body.drain<void>();
      final events = [
        {
          'type': 'agent.session.created',
          'event_id': 'created',
          'session': _session(),
        },
        {
          'type': 'agent.session.turn.created',
          'event_id': 'turn-created',
          'session_id': 'session_demo',
          'turn_id': 'turn_demo',
          'turn': _turn(false),
        },
        {
          'type': 'agent.session.turn.completed',
          'event_id': 'turn-completed',
          'session_id': 'session_demo',
          'turn_id': 'turn_demo',
          'usage': null,
          'turn': _turn(true),
        },
        {
          'type': 'agent.session.idle',
          'event_id': 'idle',
          'session': _session(),
        },
      ];
      return http.StreamedResponse(
        Stream.fromIterable(
          events.map((event) => utf8.encode('data: ${jsonEncode(event)}\n\n')),
        ),
        201,
        headers: {'content-type': 'text/event-stream'},
      );
    } else {
      throw StateError('Unexpected mock operation');
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(json))),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
  final client = OpenAIClient(httpClient: transport);
  AgentSessionRun? run;
  try {
    // Explicit staging into an existing connected environment. The upload is
    // caller-owned; no remote file/session is deleted by these helpers.
    final staged = await AgentFiles(client).stage(
      'environment_demo',
      AgentFileInput.bytes(
        bytes: binary,
        filename: 'selected.bin',
        destination: destination,
      ),
    );
    run = client.agents.sessions.createRun(
      CreateAgentSessionRequest(
        agentId: 'agent_demo',
        environment: AgentSessionEnvironment.openaiHosted(
          environmentId: 'environment_demo',
        ),
        input: AgentSessionInitialInput.text(
          'Read /workspace/input.bin and publish a binary result.',
        ),
      ),
    )..withResultCollection();
    final result = await run.finalResult();
    final artifacts = AgentResultArtifacts(client: client, result: result);
    final downloaded = <int>[];
    final artifact = await artifacts.downloadTo(
      outputPath,
      // Await writes here for a real asynchronous binary sink. The caller owns
      // its flush/close policy; this hosted path never selects a local filename.
      sink: downloaded.addAll,
    );
    if (base64Encode(downloaded) != base64Encode(binary) || calls != 5) {
      throw StateError('Unexpected offline result');
    }
    print(
      'Observed ${staged.uploadedFileId}; downloaded ${artifact.sizeBytes} bytes for completed turn ${result.turnId}.',
    );
  } on AgentFilePreparationException catch (error) {
    // These IDs are observations only. Cleanup is an explicit caller decision.
    print(
      'Known caller-owned uploads: ${error.prepared.uploadedFileIds.length}.',
    );
    rethrow;
  } finally {
    await run?.close();
    client.close();
    transport.close();
  }
}

Map<String, dynamic> _turn(bool completed) => {
  'object': 'agent.session.turn',
  'id': 'turn_demo',
  'session_id': 'session_demo',
  'agent_id': 'agent_demo',
  'subagent_id': null,
  'created_at': 0,
  'started_at': null,
  'completed_at': completed ? 1 : null,
  'status': completed ? 'completed' : 'queued',
  'error': null,
  'usage': null,
};
Map<String, dynamic> _session() => {
  'object': 'agent.session',
  'id': 'session_demo',
  'created_at': 0,
  'last_active_at': 0,
  'agent': {
    'id': 'agent_demo',
    'instructions': null,
    'model': 'fixture-model',
    'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
    'name': null,
    'reasoning': {'effort': null, 'summary': null},
    'service_tier': 'auto',
    'text': {
      'format': {'type': 'text'},
      'verbosity': 'low',
    },
    'tools': <Object?>[],
  },
  'environment': {
    'type': 'openai_hosted',
    'id': 'environment_demo',
    'capability_directories': <String>[],
    'desktop': {'enabled': false},
    'network': {'access': 'enabled', 'allowed_domains': <String>[]},
    'packages': {'npm': <String>[], 'python': <String>[], 'system': <String>[]},
    'files': <Object?>[],
    'plugins': <Object?>[],
    'skills': <Object?>[],
  },
  'error': null,
  'metadata': <String, String>{},
  'usage': null,
  'vault_ids': <String>[],
  'status': 'idle',
  'required_actions': <Object?>[],
};
