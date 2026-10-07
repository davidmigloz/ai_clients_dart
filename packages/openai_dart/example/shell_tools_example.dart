// ignore_for_file: avoid_print
/// Hosted shell configuration and synthetic local continuation.
///
/// Uses MockClient, requires no API key, creates no real containers, and never
/// executes the commands proposed by the model.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final hosted = CreateResponseRequest(
    model: 'gpt-6-astra',
    input: const ResponseInput.text('Summarize the demonstration dataset.'),
    tools: [
      ResponseTool.shell(
        environment: ShellToolEnvironment.containerAuto(
          memoryLimit: ContainerMemoryLimit.gb4,
          networkPolicy: ContainerNetworkPolicy.disabled,
          skills: const [ContainerSkill.reference(skillId: 'skill_demo')],
        ),
      ),
    ],
    toolChoice: ResponseToolChoice.shell(),
  );
  final local = CreateResponseRequest(
    model: 'gpt-6-astra',
    input: const ResponseInput.text('Request a local dataset summary.'),
    tools: [
      ResponseTool.shell(
        environment: ShellToolEnvironment.local(
          skills: const [
            ShellLocalSkill(
              name: 'dataset-summary',
              description: 'Summarize a local demonstration dataset.',
              path: '/demo/skills/dataset-summary',
            ),
          ],
        ),
      ),
    ],
    toolChoice: ResponseToolChoice.shell(),
  );
  const proposed = ShellCallOutputItem(
    id: 'sh_local',
    callId: 'call_local',
    action: ShellCallAction(
      commands: ["printf 'synthetic summary'"],
      timeoutMs: 1000,
      maxOutputLength: 4096,
    ),
    status: ItemStatus.completed,
    environment: LocalShellEnvironment(),
  );
  const returnedContent = ShellCallOutputContent(
    stdout: 'Synthetic summary: 12 rows.',
    stderr: '',
    outcome: ShellCallExitOutcome(exitCode: 0),
    createdBy: 'demo_runtime',
  );
  const returned = ShellCallOutputResultItem(
    id: 'sho_local',
    callId: 'call_local',
    status: ItemStatus.completed,
    output: [returnedContent],
    maxOutputLength: 4096,
    createdBy: 'demo_runtime',
  );
  final expectedBodies = [hosted.toJson(), local.toJson()];
  var sends = 0;
  final transport = MockClient((request) async {
    final index = sends++;
    if (request.method != 'POST' || request.url.path != '/v1/responses') {
      throw StateError('Unexpected local example request');
    }
    if (index >= expectedBodies.length ||
        jsonEncode(jsonDecode(request.body)) !=
            jsonEncode(expectedBodies[index])) {
      throw StateError('Shell request metadata was not retained');
    }
    if (index < 2) {
      return http.Response(
        jsonEncode(
          _responseJson(
            index == 0 ? 'resp_hosted' : 'resp_local',
            index == 0 ? [] : [proposed.toJson()],
          ),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    final response = _responseJson('resp_continued', [returned.toJson()]);
    final events = [
      const ResponseShellCallCommandAddedEvent(
        sequenceNumber: 0,
        outputIndex: 0,
        commandIndex: 0,
        command: "printf 'synthetic summary'",
      ).toJson(),
      const ResponseShellCallCommandDeltaEvent(
        sequenceNumber: 1,
        outputIndex: 0,
        commandIndex: 0,
        delta: '',
        obfuscation: 'padding',
      ).toJson(),
      const ResponseShellCallCommandDoneEvent(
        sequenceNumber: 2,
        outputIndex: 0,
        commandIndex: 0,
        command: "printf 'synthetic summary'",
      ).toJson(),
      const ResponseShellCallOutputContentDeltaEvent(
        sequenceNumber: 3,
        outputIndex: 0,
        commandIndex: 0,
        itemId: 'sho_local',
        delta: ShellCallOutputDelta(stdout: 'Synthetic summary: '),
      ).toJson(),
      ResponseShellCallOutputContentDoneEvent(
        sequenceNumber: 4,
        outputIndex: 0,
        commandIndex: 0,
        itemId: 'sho_local',
        output: const [returnedContent],
      ).toJson(),
      {
        'type': 'response.completed',
        'sequence_number': 5,
        'response': response,
      },
    ];
    return http.Response(
      '${events.map((event) => 'data: ${jsonEncode(event)}\n\n').join()}data: [DONE]\n\n',
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  });
  final client = OpenAIClient(
    config: const OpenAIConfig(
      baseUrl: 'https://example.invalid/v1',
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  try {
    await client.responses.create(hosted);
    final response = await client.responses.create(local);
    final call = response.output.whereType<ShellCallOutputItem>().single;
    print('Proposed commands (not executed): ${call.action.commands}');
    final replay = call.toShellCallInputItem();
    if (replay.callId != call.callId) {
      throw StateError('Replay lost the call ID');
    }

    final continuation = CreateResponseRequest(
      model: 'gpt-6-astra',
      previousResponseId: response.id,
      input: ResponseInput.items([
        ShellCallOutputInputItem(
          callId: call.callId,
          maxOutputLength: call.action.maxOutputLength,
          output: const [
            ShellCallOutputContentInput(
              stdout: 'Synthetic summary: 12 rows.',
              stderr: '',
              outcome: ShellCallExitOutcome(exitCode: 0),
            ),
          ],
        ),
      ]),
    );
    expectedBodies.add({...continuation.toJson(), 'stream': true});
    var sawCompletion = false;
    await for (final event in client.responses.createStream(continuation)) {
      if (event is ResponseShellCallOutputContentDeltaEvent) {
        print('Output fragment: ${event.delta.stdout ?? ''}');
      } else if (event is ResponseCompletedEvent) {
        final result = event.response.output
            .whereType<ShellCallOutputResultItem>()
            .single;
        if (result.callId != call.callId ||
            result.output.single != returnedContent) {
          throw StateError('Continuation lost the original call or output');
        }
        print(result.output.single.stdout);
        sawCompletion = true;
      }
    }
    if (!sawCompletion || sends != 3) {
      throw StateError('Incomplete local example');
    }
    print(
      'Completed $sends local requests; no commands executed or API charges.',
    );
  } finally {
    client.close();
    transport.close();
  }
}

Map<String, dynamic> _responseJson(
  String id,
  List<Map<String, dynamic>> output,
) => {
  'id': id,
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'model': 'gpt-6-astra',
  'output': output,
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <Object>[],
  'parallel_tool_calls': false,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};
