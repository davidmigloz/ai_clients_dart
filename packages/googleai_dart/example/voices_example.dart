// ignore_for_file: avoid_print

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print(
      'Usage: dart run example/voices_example.dart "Describe a fictional narrator"',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  try {
    final voice = await client.voices.create(
      store: true,
      voice: Voice(
        type: VoiceType.prompted,
        model: 'gemini-3.8-flash-tts',
        prompted: PromptedVoice(input: args.join(' ')),
      ),
    );
    print('Created voice: ${voice.id}');
    final preview = voice.sampleAudio;
    if (preview != null) {
      print('Preview audio contains ${preview.toBytes().length} bytes.');
    }
  } finally {
    client.close();
  }
}
