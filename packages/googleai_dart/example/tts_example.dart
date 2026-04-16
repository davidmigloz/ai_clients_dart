// ignore_for_file: avoid_print
/// Demonstrates text-to-speech generation with Gemini TTS models.
///
/// This example shows how to:
/// - Generate speech with a prebuilt voice
/// - Control delivery with audio tags (e.g. `[whispers]`, `[excited]`)
/// - Produce multi-speaker dialogue with distinct voices per speaker
/// - Save the returned PCM audio as a playable WAV file
///
/// Supported models:
/// - `gemini-3.1-flash-tts-preview`
/// - `gemini-2.5-flash-preview-tts`
/// - `gemini-2.5-pro-preview-tts`
///
/// The API returns 24 kHz, 16-bit, mono PCM in an `InlineDataPart`. Wrap the
/// bytes with a WAV header (see `_pcmToWav` below) before writing `.wav`.
library;

import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:googleai_dart/googleai_dart.dart';

const _model = 'gemini-3.1-flash-tts-preview';

void main() async {
  final client = GoogleAIClient.fromEnvironment();

  try {
    // Example 1: Single speaker with a prebuilt voice.
    print('=== Single speaker ===\n');

    final single = await client.models.generateContent(
      model: _model,
      request: GenerateContentRequest(
        contents: [Content.text('Say cheerfully: Have a wonderful day!')],
        generationConfig: GenerationConfig(
          responseModalities: const [ResponseModality.audio],
          speechConfig: SpeechConfig.withVoice('Kore'),
        ),
      ),
    );

    await _saveAudio(single, 'tts_single_speaker.wav');

    // Example 2: Expressive control with audio tags.
    //
    // Audio tags in square brackets steer pacing, tone, and delivery. Tags
    // must be separated by text or punctuation — never place two tags
    // adjacent. Tags are English-only but work inside prompts in any language.
    print('\n=== Audio tags ===\n');

    const prompt =
        '[cautious] The shadow crept slowly across the silent room. '
        '[whispers] The secret document had to be hidden here. '
        '[short pause] But where?';

    final tagged = await client.models.generateContent(
      model: _model,
      request: GenerateContentRequest(
        contents: [Content.text(prompt)],
        generationConfig: GenerationConfig(
          responseModalities: const [ResponseModality.audio],
          speechConfig: SpeechConfig.withVoice('Charon'),
        ),
      ),
    );

    await _saveAudio(tagged, 'tts_audio_tags.wav');

    // Example 3: Multi-speaker dialogue with one voice per speaker.
    //
    // Each turn in the transcript must be prefixed with the speaker label
    // declared in `speakerVoiceConfigs`.
    print('\n=== Multi-speaker ===\n');

    final dialogue = await client.models.generateContent(
      model: _model,
      request: GenerateContentRequest(
        contents: [
          Content.text(
            "Joe: How's it going today, Jane?\n"
            'Jane: Not too bad, how about you?',
          ),
        ],
        generationConfig: const GenerationConfig(
          responseModalities: [ResponseModality.audio],
          speechConfig: SpeechConfig(
            multiSpeakerVoiceConfig: MultiSpeakerVoiceConfig(
              speakerVoiceConfigs: [
                SpeakerVoiceConfig(
                  speaker: 'Joe',
                  voiceConfig: VoiceConfig(
                    prebuiltVoiceConfig: PrebuiltVoiceConfig(voiceName: 'Kore'),
                  ),
                ),
                SpeakerVoiceConfig(
                  speaker: 'Jane',
                  voiceConfig: VoiceConfig(
                    prebuiltVoiceConfig: PrebuiltVoiceConfig(voiceName: 'Puck'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await _saveAudio(dialogue, 'tts_multi_speaker.wav');
  } finally {
    client.close();
  }
}

Future<void> _saveAudio(
  GenerateContentResponse response,
  String filename,
) async {
  final base64Audio = response.data;
  if (base64Audio == null) {
    print('No audio in response.');
    return;
  }

  final pcm = base64Decode(base64Audio);
  final wav = _pcmToWav(pcm);
  await io.File(filename).writeAsBytes(wav);
  print('Saved $filename (${wav.length} bytes).');
}

/// Wraps 24 kHz, 16-bit, mono PCM bytes in a RIFF/WAVE header.
Uint8List _pcmToWav(
  Uint8List pcm, {
  int sampleRate = 24000,
  int channels = 1,
  int bitsPerSample = 16,
}) {
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final header = BytesBuilder()
    ..add(ascii.encode('RIFF'))
    ..add(_u32le(36 + pcm.length))
    ..add(ascii.encode('WAVE'))
    ..add(ascii.encode('fmt '))
    ..add(_u32le(16)) // PCM chunk size
    ..add(_u16le(1)) // audio format = PCM
    ..add(_u16le(channels))
    ..add(_u32le(sampleRate))
    ..add(_u32le(byteRate))
    ..add(_u16le(blockAlign))
    ..add(_u16le(bitsPerSample))
    ..add(ascii.encode('data'))
    ..add(_u32le(pcm.length))
    ..add(pcm);
  return header.toBytes();
}

Uint8List _u16le(int value) =>
    (ByteData(2)..setUint16(0, value, Endian.little)).buffer.asUint8List();

Uint8List _u32le(int value) =>
    (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();
