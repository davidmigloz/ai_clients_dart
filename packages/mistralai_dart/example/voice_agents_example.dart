// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Manages Mistral-hosted voice agents and opens a short-lived room.
Future<void> main(List<String> args) async {
  if (args.isEmpty || args.contains('--help')) {
    print('''
Usage
  dart run example/voice_agents_example.dart agents
  dart run example/voice_agents_example.dart create NAME
  dart run example/voice_agents_example.dart session AGENT_ID

Set MISTRAL_API_KEY on your backend. The session command stops the room
after reading its status. Use the README handoff with a LiveKit media client
to join a room and exchange audio.
''');
    return;
  }

  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set MISTRAL_API_KEY before calling the API.');
    exitCode = 1;
    return;
  }

  final client = MistralClient.withApiKey(apiKey);
  try {
    switch (args) {
      case ['agents']:
        final page = await client.audio.agents.list(pageSize: 10);
        for (final agent in page.data) {
          print('${agent.id} ${agent.name}');
        }
      case ['create', final name]:
        final agent = await client.audio.agents.create(
          request: CreateAudioAgentRequest(
            name: name,
            configuration: const AudioAgentConfiguration(
              llm: AudioLlmConfig(model: 'mistral-small-latest'),
              welcomeMessage: 'Hello. How can I help?',
            ),
          ),
        );
        print('Saved ${agent.id} at version ${agent.version}.');
      case ['session', final agentId]:
        final session = await client.audio.sessions.create(
          request: CreateAudioSessionRequest(agentId: agentId),
        );
        try {
          final current = await client.audio.sessions.get(
            sessionId: session.id,
          );
          print('Session ${current.id} is ${current.status.value}.');
          // Return VoiceAgentRoomCredentials.fromSession(session).toJson()
          // from your authenticated backend to join from a media client.
        } finally {
          await client.audio.sessions.close(sessionId: session.id);
        }
      default:
        stderr.writeln('Unknown command. Run with --help for usage.');
        exitCode = 1;
    }
  } finally {
    client.close();
  }
}
