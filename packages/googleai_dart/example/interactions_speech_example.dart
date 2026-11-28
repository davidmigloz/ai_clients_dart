// ignore_for_file: avoid_print
/// Generate a short two-speaker WAV with Gemini Developer API v1beta.
///
/// Run with an output path to send the request. The Gemini project must have
/// access to the speech model.
library;

import 'dart:convert';
import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    print(
      'Usage: dart run example/interactions_speech_example.dart output.wav',
    );
    return;
  }

  final client = GoogleAIClient.fromEnvironment(
    interactionsApiVersion: ApiVersion.v1beta,
  );
  try {
    final interaction = await client.interactions.create(
      model: 'gemini-3.8-flash-tts',
      input: const InteractionInput.steps([
        UserInputStep(
          content: [
            TextContent(
              text: 'Welcome to the studio.',
              annotations: [
                SpeechAnnotation(speaker: 'Host', style: 'Warm and upbeat'),
              ],
            ),
            TextContent(
              text: 'Thanks for inviting me.',
              annotations: [SpeechAnnotation(speaker: 'Guest')],
            ),
          ],
        ),
      ]),
      responseFormat: const InteractionResponseFormatConfig.single(
        InteractionAudioResponseFormat(),
      ),
      generationConfig: const InteractionGenerationConfig(
        speechConfigObject: InteractionSpeakerConfig(
          speakers: [
            InteractionSpeechConfig(speaker: 'Host', voice: 'Puck'),
            InteractionSpeechConfig(speaker: 'Guest', voice: 'Kore'),
          ],
        ),
      ),
    );

    final audio = interaction.steps
        ?.whereType<ModelOutputStep>()
        .expand((step) => step.content ?? const <InteractionContent>[])
        .whereType<AudioContent>()
        .firstOrNull;
    final data = audio?.data;
    if (data == null) {
      print('The model returned no inline audio.');
      return;
    }
    await io.File(args.single).writeAsBytes(base64Decode(data));
  } finally {
    client.close();
  }
}
