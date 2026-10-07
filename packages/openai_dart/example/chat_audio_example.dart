// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

/// Generate WAV audio, replay its ID, and accumulate a PCM16 audio stream.
///
/// Run with OPENAI_API_KEY set. Makes up to three small paid requests with
/// retries disabled and output capped. Writes chat_audio.wav/chat_audio.pcm.
Future<void> main() async {
  final client = OpenAIClient(
    config: OpenAIConfig.fromEnvironment().copyWith(
      retryPolicy: const RetryPolicy(maxRetries: 0),
      timeout: const Duration(seconds: 60),
    ),
  );
  final prompt = ChatMessage.user('Say only OK.');
  try {
    final completion = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: 'gpt-audio-1.5',
        messages: [prompt],
        modalities: const [ChatModality.text, ChatModality.audio],
        audio: const ChatAudioConfig(
          voice: ChatAudioVoice.alloy,
          format: ChatAudioFormat.wav,
        ),
        maxCompletionTokens: 128,
        store: false,
      ),
    );
    if (completion.audio case final audio?) {
      print('Transcript: ${audio.transcript}');
      await File('chat_audio.wav').writeAsBytes(base64Decode(audio.data));
      print('Audio replay expires at Unix timestamp ${audio.expiresAt}.');

      // Reusing the returned message sends only audio:{id:...}; generated data,
      // transcript and expiry stay in the local model. You can also construct
      // ChatMessage.assistant(audio: ChatAudio.reference(id: audio.id)).
      final replay = await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-audio-1.5',
          messages: [
            prompt,
            completion.choices.first.message,
            ChatMessage.user('What word did you say? Reply in text.'),
          ],
          modalities: const [ChatModality.text],
          maxCompletionTokens: 64,
          store: false,
        ),
      );
      print('Replay: ${replay.text}');
    } else {
      print('No audio output: ${completion.text}');
    }

    final accumulator = ChatStreamAccumulator();
    await for (final event in client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'gpt-audio-1.5',
        messages: [prompt],
        modalities: const [ChatModality.text, ChatModality.audio],
        audio: const ChatAudioConfig(
          voice: ChatAudioVoice.alloy,
          format: ChatAudioFormat.pcm16,
        ),
        maxCompletionTokens: 128,
        store: false,
        streamOptions: const StreamOptions(includeUsage: true),
      ),
    )) {
      accumulator.add(event);
      // Transcript and binary data can arrive independently.
      if (event.firstChoice?.delta.audio?.transcript case final text?) {
        stdout.write(text);
      }
    }
    print('\nStream usage: ${accumulator.usage}');
    if (accumulator.audio case final partial?) {
      if (partial.isComplete) {
        final audio = accumulator.toChatCompletion().audio!;
        // Concatenate opaque fragments first, decode the complete data once.
        await File('chat_audio.pcm').writeAsBytes(base64Decode(audio.data));
        print('Saved raw PCM16 audio.');
      } else {
        print(
          'Audio ended before all fields arrived; inspect the partial snapshot.',
        );
        // toChatCompletion() throws StateError for incomplete audio.
      }
    }
  } finally {
    client.close();
  }
}
