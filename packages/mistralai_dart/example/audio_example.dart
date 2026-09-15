// ignore_for_file: avoid_print, unreachable_from_main
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating audio transcription with the Mistral AI API.
///
/// This example shows how to:
/// 1. Transcribe audio to text
/// 2. Stream transcription results in real-time
/// 3. Get word-level and segment-level timing information
///
/// Before running, set the MISTRAL_API_KEY environment variable.
/// The audio can be passed as bytes, as a URL, or as the ID of a file
/// uploaded with the Files API.
void main() {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic transcription (requires an audio.mp3 file)
    // Uncomment and point at an actual audio file to test
    // await basicTranscription(client);

    // Example 2: Transcription with verbose output
    // await verboseTranscription(client);

    // Example 3: Streaming transcription
    // await streamingTranscription(client);

    // For demonstration, show how the API would be called
    demonstrateUsage();
  } finally {
    client.close();
  }
}

/// Demonstrates basic audio transcription.
Future<void> basicTranscription(MistralClient client) async {
  print('=== Basic Audio Transcription ===\n');

  // The audio is sent inline; no upload to the Files API is needed
  final bytes = await File('audio.mp3').readAsBytes();

  final response = await client.audio.transcriptions.create(
    request: TranscriptionRequest(
      fileBytes: bytes,
      fileName: 'audio.mp3',
      model: 'mistral-audio-latest',
      language: 'en', // Optional: specify language for better accuracy
    ),
  );

  print('Transcribed text:');
  print(response.text);

  if (response.duration != null) {
    print('\nAudio duration: ${response.duration} seconds');
  }

  if (response.language != null) {
    print('Detected language: ${response.language}');
  }
}

/// Demonstrates transcription with verbose output including timing.
Future<void> verboseTranscription(MistralClient client) async {
  print('=== Verbose Audio Transcription ===\n');

  const fileId = 'your-audio-file-id'; // Replace with actual file ID

  final response = await client.audio.transcriptions.create(
    request: const TranscriptionRequest(
      file: fileId,
      model: 'mistral-audio-latest',
      responseFormat: 'verbose_json', // Get detailed timing info
      timestampGranularities: true, // Include word-level timestamps
    ),
  );

  print('Full transcription:');
  print(response.text);
  print('');

  // Print segment information
  if (response.segments != null && response.segments!.isNotEmpty) {
    print('Segments:');
    for (final segment in response.segments!) {
      print(
        '  [${_formatTime(segment.start)} - ${_formatTime(segment.end)}] '
        '${segment.text}',
      );
    }
    print('');
  }

  // Print word-level timing
  if (response.words != null && response.words!.isNotEmpty) {
    print('Words with timing:');
    for (final word in response.words!) {
      print(
        '  ${word.word}: ${_formatTime(word.start)} - ${_formatTime(word.end)} '
        '(${word.duration.toStringAsFixed(2)}s)',
      );
    }
  }
}

/// Demonstrates streaming transcription.
Future<void> streamingTranscription(MistralClient client) async {
  print('=== Streaming Audio Transcription ===\n');

  const fileId = 'your-audio-file-id'; // Replace with actual file ID

  final stream = client.audio.transcriptions.createStream(
    request: const TranscriptionRequest(
      file: fileId,
      model: 'mistral-audio-latest',
    ),
  );

  print('Transcribing (streaming)...\n');

  await for (final event in stream) {
    switch (event.type) {
      case 'start':
        print('Started transcription (ID: ${event.id})');

      case 'text':
      case 'text_delta':
        // Print text as it arrives
        if (event.text != null) {
          stdout.write(event.text);
        }

      case 'word':
        // Optionally handle word events
        if (event.word != null) {
          // Could use for timing visualization
        }

      case 'segment':
        // Handle segment completion
        if (event.segment != null) {
          print('\n[Segment ${event.segment!.id} complete]');
        }

      case 'end':
      case 'done':
        print('\n\nTranscription complete.');

      default:
        // Handle other event types
        break;
    }
  }
}

/// Demonstrates how the API would be used without making actual calls.
void demonstrateUsage() {
  print('=== Audio Transcription API Usage ===\n');

  print('1. Transcribe audio bytes directly:');
  print('''
   final bytes = await File('recording.mp3').readAsBytes();
   final response = await client.audio.transcriptions.create(
     request: TranscriptionRequest(
       fileBytes: bytes,
       fileName: 'recording.mp3',
       model: 'mistral-audio-latest',
       language: 'en',  // Optional
     ),
   );
   print(response.text);
''');

  print('2. Or transcribe a file uploaded with the Files API:');
  print('''
   final file = await client.files.upload(
     file: File('recording.mp3'),
     purpose: FilePurpose.audio,
   );
   final response = await client.audio.transcriptions.create(
     request: TranscriptionRequest(
       file: file.id,
       model: 'mistral-audio-latest',
     ),
   );
''');

  print('3. Stream transcription for real-time results:');
  print('''
   final stream = client.audio.transcriptions.createStream(
     request: TranscriptionRequest(
       file: file.id,
       model: 'mistral-audio-latest',
     ),
   );

   await for (final event in stream) {
     if (event.text != null) {
       stdout.write(event.text);
     }
   }
''');

  print('4. Get detailed timing information:');
  print(r'''
   final response = await client.audio.transcriptions.create(
     request: TranscriptionRequest(
       file: file.id,
       model: 'mistral-audio-latest',
       responseFormat: 'verbose_json',
       timestampGranularities: true,
     ),
   );

   for (final word in response.words ?? []) {
     print('${word.word}: ${word.start}s - ${word.end}s');
   }
''');

  print('Supported response formats:');
  print('  - json: Standard JSON response');
  print('  - text: Plain text only');
  print('  - srt: SubRip subtitle format');
  print('  - vtt: WebVTT subtitle format');
  print('  - verbose_json: JSON with detailed timing info');
}

/// Formats a time in seconds as MM:SS.mmm
String _formatTime(double seconds) {
  final mins = (seconds / 60).floor();
  final secs = seconds % 60;
  return '${mins.toString().padLeft(2, '0')}:${secs.toStringAsFixed(3).padLeft(6, '0')}';
}
