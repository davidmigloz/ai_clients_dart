// ignore_for_file: avoid_print

import 'dart:io' as io;

import 'package:googleai_dart/googleai_dart.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    print('Usage: dart run example/live_music_example.dart output.pcm');
    return;
  }

  final client = GoogleAIClient.fromEnvironment(apiVersion: ApiVersion.v1beta);
  final music = client.createLiveMusicClient();
  try {
    final session = await music.connect(model: 'lyria-realtime-exp');
    session
      ..setWeightedPrompts(const [
        LiveMusicWeightedPrompt(text: 'Minimal piano and brushes', weight: 1),
        LiveMusicWeightedPrompt(text: 'Warm ambient textures', weight: 0.5),
      ])
      ..setMusicGenerationConfig(const LiveMusicGenerationConfig(bpm: 90))
      ..play();

    final output = io.File(args.single).openWrite();
    final formats = <String>{};
    var chunks = 0;
    try {
      await for (final message in session.messages.timeout(
        const Duration(seconds: 15),
      )) {
        if (message.warning case final warning?) print(warning);
        for (final chunk
            in message.serverContent?.audioChunks ??
                const <LiveMusicAudioChunk>[]) {
          if (chunk.data case final bytes?) {
            output.add(bytes);
            if (chunk.mimeType case final format?) formats.add(format);
            chunks++;
          }
        }
        if (chunks >= 12) break;
      }
    } finally {
      await output.close();
    }
    print('Saved $chunks audio chunks.');
    if (formats.isNotEmpty) {
      print('Reported audio formats ${formats.join(', ')}.');
    }
  } finally {
    try {
      await music.close();
    } finally {
      client.close();
    }
  }
}
