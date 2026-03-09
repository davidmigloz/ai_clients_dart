// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart' as realtime;
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  // ============================================================
  // Group 1: HTTP Session Creation
  // ============================================================

  group('HTTP Session Creation', () {
    test(
      'creates realtime session',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.create(
          const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-1.5',
          ),
        );

        expect(response.id, startsWith('sess_'));
        expect(response.object, 'realtime.session');
        expect(response.model, contains('realtime'));
        expect(response.clientSecret, isNotNull);
        expect(response.clientSecret!.value, isNotEmpty);
        expect(response.clientSecret!.expiresAt, greaterThan(0));

        print('Session ID: ${response.id}');
        print('Client secret expires at: ${response.clientSecret!.expiresAt}');
      },
    );

    test(
      'creates realtime session with configuration',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.create(
          const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-1.5',
            modalities: ['text', 'audio'],
            voice: realtime.RealtimeVoice.alloy,
            instructions: 'You are a helpful assistant.',
            turnDetection: realtime.TurnDetection(
              type: realtime.TurnDetectionType.serverVad,
              threshold: 0.5,
              prefixPaddingMs: 300,
              silenceDurationMs: 500,
            ),
            temperature: 0.8,
          ),
        );

        expect(response.id, startsWith('sess_'));
        expect(response.voice, realtime.RealtimeVoice.alloy);
        expect(response.modalities, contains('text'));
        expect(response.modalities, contains('audio'));
        expect(response.turnDetection, isNotNull);

        print('Session with config: ${response.id}');
      },
    );

    test(
      'creates transcription session',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.createTranscription(
          const realtime.RealtimeTranscriptionSessionCreateRequest(
            inputAudioFormat: realtime.RealtimeAudioFormat.pcm16,
            inputAudioTranscription: realtime.InputAudioTranscription(
              model: 'whisper-1',
            ),
          ),
        );

        expect(response.clientSecret, isNotNull);
        expect(response.clientSecret.value, isNotEmpty);

        print(
          'Transcription session secret: '
          '${response.clientSecret.value.substring(0, 20)}...',
        );
      },
    );

    test(
      'creates client secret with custom expiration',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.createClientSecret(
          const realtime.RealtimeClientSecretCreateRequest(
            expiresAfter: realtime.ExpiresAfter(
              anchor: 'created_at',
              seconds: 120,
            ),
            session: realtime.RealtimeSessionCreateRequest(
              type: 'realtime', // Required discriminator for client secrets
              model: 'gpt-realtime-1.5',
            ),
          ),
        );

        expect(response.value, isNotEmpty);
        expect(response.expiresAt, greaterThan(0));
        expect(response.session, isNotNull);
        expect(response.session.id, startsWith('sess_'));

        print('Client secret expires at: ${response.expiresAt}');
      },
    );
  });

  // ============================================================
  // Group 2: WebSocket Connection
  // ============================================================

  group('WebSocket Connection', () {
    test(
      'connects to realtime API',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
        );

        expect(connection.isClosed, isFalse);

        await connection.close();
        expect(connection.isClosed, isTrue);
      },
    );

    test(
      'receives session.created event',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
        );

        try {
          final event = await waitForEvent<realtime.SessionCreatedEvent>(
            connection,
          );

          expect(event.type, 'session.created');
          expect(event.session.id, isNotEmpty);
          expect(event.session.model, contains('realtime'));

          print('Session created: ${event.session.id}');
        } finally {
          await connection.close();
        }
      },
    );

    test(
      'closes connection cleanly',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
        );

        // Wait for session created
        await waitForEvent<realtime.SessionCreatedEvent>(connection);

        expect(connection.isClosed, isFalse);

        await connection.close(code: 1000, reason: 'Test complete');

        expect(connection.isClosed, isTrue);
      },
    );

    test(
      'handles multiple connect/disconnect cycles',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        for (var i = 0; i < 2; i++) {
          final connection = await client!.realtime.connect(
            model: 'gpt-realtime-1.5',
          );

          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          expect(connection.isClosed, isFalse);

          await connection.close();
          expect(connection.isClosed, isTrue);

          print('Cycle ${i + 1} complete');
        }
      },
    );
  });

  // ============================================================
  // Group 3: Session Configuration
  // ============================================================

  group('Session Configuration', () {
    test(
      'updates session configuration',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
        );

        try {
          // Wait for initial session
          await waitForEvent<realtime.SessionCreatedEvent>(connection);

          // Update session
          connection.updateSession(
            const realtime.SessionUpdateConfig(
              voice: realtime.RealtimeVoice.shimmer,
              modalities: ['text'],
              instructions: 'You are a helpful assistant.',
              temperature: 0.9,
            ),
          );

          // Wait for update confirmation
          final updateEvent = await waitForEvent<realtime.SessionUpdatedEvent>(
            connection,
          );

          expect(updateEvent.type, 'session.updated');
          expect(updateEvent.session.voice, realtime.RealtimeVoice.shimmer);

          print('Session updated with voice: ${updateEvent.session.voice}');
        } finally {
          await connection.close();
        }
      },
    );

    test(
      'configures voice and modalities',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(
            voice: realtime.RealtimeVoice.echo,
            modalities: ['text', 'audio'],
          ),
        );

        try {
          final sessionEvent = await waitForEvent<realtime.SessionCreatedEvent>(
            connection,
          );

          // The initial config should be applied
          expect(sessionEvent.session, isNotNull);
          print('Initial session: ${sessionEvent.session.id}');

          // Wait for the update from our config
          final updateEvent = await waitForEvent<realtime.SessionUpdatedEvent>(
            connection,
          );

          expect(updateEvent.session.voice, realtime.RealtimeVoice.echo);
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 4: Text Conversation
  // ============================================================

  group('Text Conversation', () {
    test(
      'sends text message and receives response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(modalities: ['text']),
        );

        try {
          // Wait for session
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Send a text message
          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Say "hello" and nothing else.'},
              ],
            })
            // Create response
            ..createResponse();

          // Collect text deltas
          final textBuffer = StringBuffer();
          final events = await collectEventsUntil<realtime.ResponseDoneEvent>(
            connection,
            timeout: const Duration(minutes: 1),
          );

          for (final event in events) {
            if (event is realtime.ResponseTextDeltaEvent) {
              textBuffer.write(event.delta);
            }
          }

          final fullText = textBuffer.toString().toLowerCase();
          expect(fullText, contains('hello'));

          print('Response text: $fullText');
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 5: Tool Calling
  // ============================================================

  group('Tool Calling', () {
    test(
      'model calls function tool',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(
            modalities: ['text'],
            tools: [
              realtime.RealtimeTool(
                type: 'function',
                name: 'get_weather',
                description: 'Get the current weather for a location',
                parameters: {
                  'type': 'object',
                  'properties': {
                    'location': {
                      'type': 'string',
                      'description': 'The city name',
                    },
                  },
                  'required': ['location'],
                },
              ),
            ],
            toolChoice: realtime.RealtimeToolChoice.auto(),
          ),
        );

        try {
          // Wait for session setup
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Send message that should trigger tool call
          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': "What's the weather in Paris?"},
              ],
            })
            ..createResponse();

          // Look for function call
          String? callId;
          String? functionArgs;

          final events = await collectEventsUntil<realtime.ResponseDoneEvent>(
            connection,
            timeout: const Duration(minutes: 2),
          );

          for (final event in events) {
            if (event is realtime.ResponseFunctionCallArgumentsDoneEvent) {
              callId = event.callId;
              functionArgs = event.arguments;
              break;
            }
          }

          expect(callId, isNotNull, reason: 'Should have received a tool call');
          expect(functionArgs, isNotNull);
          expect(functionArgs, contains('Paris'));

          print('Tool call ID: $callId');
          print('Tool arguments: $functionArgs');

          // Send function result
          connection
            ..sendFunctionOutput(callId!, '{"temperature": 22, "unit": "C"}')
            ..createResponse();

          // Wait for final response
          final finalEvents =
              await collectEventsUntil<realtime.ResponseDoneEvent>(
                connection,
                timeout: const Duration(minutes: 1),
              );

          final textBuffer = StringBuffer();
          for (final event in finalEvents) {
            if (event is realtime.ResponseTextDeltaEvent) {
              textBuffer.write(event.delta);
            }
          }

          final response = textBuffer.toString();
          expect(response, isNotEmpty);
          print('Final response: $response');
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 6: Response Control
  // ============================================================

  group('Response Control', () {
    test(
      'creates response on demand',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(modalities: ['text']),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Add user message
          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Say "test response"'},
              ],
            })
            // Explicitly create response with parameters
            ..createResponse(
              modalities: ['text'],
              instructions: 'Be very brief.',
              maxOutputTokens: 50,
            );

          final responseCreated =
              await waitForEvent<realtime.ResponseCreatedEvent>(connection);
          expect(responseCreated.response, isNotNull);

          print('Response created: ${responseCreated.response['id']}');

          // Wait for completion
          await waitForEvent<realtime.ResponseDoneEvent>(connection);
        } finally {
          await connection.close();
        }
      },
    );

    test(
      'cancels response',
      timeout: const Timeout(Duration(minutes: 2)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(modalities: ['text']),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Add message that would generate long response
          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Count slowly from 1 to 100.'},
              ],
            })
            ..createResponse();

          // Wait for response to start
          await waitForEvent<realtime.ResponseCreatedEvent>(connection);

          // Cancel it
          connection.cancelResponse();

          // The response should be cancelled (might get a cancelled status)
          // We just verify we don't hang
          print('Response cancelled');
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 7: Conversation Item Management
  // ============================================================

  group('Conversation Item Management', () {
    test(
      'deletes conversation item',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(modalities: ['text']),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Create an item
          connection.createItem({
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Test message'},
            ],
          });

          // Wait for item creation
          final itemCreated =
              await waitForEvent<realtime.ConversationItemCreatedEvent>(
                connection,
              );

          final itemId = itemCreated.item['id'] as String;
          expect(itemId, isNotEmpty);

          // Delete the item
          connection.deleteItem(itemId);

          // Wait for deletion confirmation
          final itemDeleted =
              await waitForEvent<realtime.ConversationItemDeletedEvent>(
                connection,
              );

          expect(itemDeleted.itemId, itemId);
          print('Deleted item: $itemId');
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 8: Error Handling
  // ============================================================

  group('Error Handling', () {
    test(
      'receives error event on invalid request',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);

          // Send an invalid event type
          connection.send({'type': 'invalid.event.type', 'data': 'test'});

          // Should receive an error event
          final errorEvent = await waitForEvent<realtime.ErrorEvent>(
            connection,
            timeout: const Duration(seconds: 10),
          );

          expect(errorEvent.error, isNotNull);
          expect(errorEvent.error.message, isNotEmpty);

          print('Error received: ${errorEvent.error.message}');
        } finally {
          await connection.close();
        }
      },
    );
  });

  // ============================================================
  // Group 9: Audio Input
  // ============================================================

  group('Audio Input', () {
    test(
      'sends audio and receives transcription',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Read the sample audio file
        final audioFile = File('test/samples/harvard.wav');
        if (!audioFile.existsSync()) {
          markTestSkipped('Sample audio file not found');
          return;
        }

        final audioBytes = await audioFile.readAsBytes();

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(
            modalities: ['text', 'audio'],
            inputAudioFormat: realtime.RealtimeAudioFormat.pcm16,
            inputAudioTranscription: realtime.InputAudioTranscription(
              model: 'whisper-1',
            ),
            turnDetection: realtime.TurnDetection(
              type: realtime.TurnDetectionType.serverVad,
              threshold: 0.3,
              silenceDurationMs: 1000,
              createResponse: false, // We'll manually trigger response
            ),
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // WAV header is typically 44 bytes - skip it for raw PCM
          final pcmData = audioBytes.sublist(44);

          // Send audio in chunks
          const chunkSize = 4800; // 100ms of 24kHz mono PCM16
          for (var i = 0; i < pcmData.length; i += chunkSize) {
            final end = (i + chunkSize < pcmData.length)
                ? i + chunkSize
                : pcmData.length;
            final chunk = pcmData.sublist(i, end);
            connection.appendAudio(base64Encode(chunk));
          }

          // Commit the audio
          connection.commitAudio();

          // Wait for audio to be processed
          await waitForEvent<realtime.InputAudioBufferCommittedEvent>(
            connection,
          );

          // Request a response
          connection.createResponse(
            modalities: ['text'],
            instructions: 'Please repeat what the user said.',
          );

          // Collect response
          final events = await collectEventsUntil<realtime.ResponseDoneEvent>(
            connection,
            timeout: const Duration(minutes: 2),
          );

          final textBuffer = StringBuffer();
          for (final event in events) {
            if (event is realtime.ResponseTextDeltaEvent) {
              textBuffer.write(event.delta);
            }
          }

          final response = textBuffer.toString();
          print('Audio response: $response');

          // The Harvard sentences should produce some response
          expect(response, isNotEmpty);
        } finally {
          await connection.close();
        }
      },
    );

    test(
      'clears audio buffer',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-1.5',
          config: const realtime.SessionUpdateConfig(
            modalities: ['text', 'audio'],
            inputAudioFormat: realtime.RealtimeAudioFormat.pcm16,
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // Append some dummy audio
          final dummyAudio = List.filled(1000, 0);
          connection
            ..appendAudio(base64Encode(dummyAudio))
            // Clear the buffer
            ..clearAudio();

          // Should receive cleared event
          final cleared =
              await waitForEvent<realtime.InputAudioBufferClearedEvent>(
                connection,
              );

          expect(cleared.type, 'input_audio_buffer.cleared');
          print('Audio buffer cleared');
        } finally {
          await connection.close();
        }
      },
    );
  });
}

// ============================================================
// Helper Functions
// ============================================================

/// Waits for a specific event type from the connection.
Future<T> waitForEvent<T extends realtime.RealtimeEvent>(
  RealtimeConnection connection, {
  Duration timeout = const Duration(seconds: 30),
}) {
  final completer = Completer<T>();

  late StreamSubscription<realtime.RealtimeEvent> subscription;
  Timer? timer;

  subscription = connection.events.listen(
    (event) async {
      if (event is T) {
        timer?.cancel();
        await subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(event);
        }
      }
    },
    onError: (Object e) async {
      timer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    },
  );

  timer = Timer(timeout, () async {
    await subscription.cancel();
    if (!completer.isCompleted) {
      completer.completeError(
        RequestTimeoutException(
          message: 'Timeout waiting for $T',
          timeout: timeout,
        ),
      );
    }
  });

  return completer.future;
}

/// Collects events until a specific event type is received.
Future<List<realtime.RealtimeEvent>> collectEventsUntil<T>(
  RealtimeConnection connection, {
  Duration timeout = const Duration(minutes: 2),
}) {
  final events = <realtime.RealtimeEvent>[];
  final completer = Completer<List<realtime.RealtimeEvent>>();

  late StreamSubscription<realtime.RealtimeEvent> subscription;
  Timer? timer;

  subscription = connection.events.listen(
    (event) async {
      events.add(event);
      if (event is T) {
        timer?.cancel();
        await subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete(events);
        }
      }
    },
    onError: (Object e) async {
      timer?.cancel();
      await subscription.cancel();
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    },
  );

  timer = Timer(timeout, () async {
    await subscription.cancel();
    if (!completer.isCompleted) {
      completer.completeError(
        RequestTimeoutException(
          message: 'Timeout waiting for $T',
          timeout: timeout,
        ),
      );
    }
  });

  return completer.future;
}
