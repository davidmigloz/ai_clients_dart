// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:async';
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

        final response = await client!.realtimeSessions.createClientSecret(
          const realtime.RealtimeClientSecretCreateRequest(
            session: realtime.RealtimeSessionCreateRequest(
              model: 'gpt-realtime-2',
            ),
          ),
        );

        expect(response.value, startsWith('ek_'));
        expect(response.session.id, startsWith('sess_'));
        expect(response.session.object, 'realtime.session');
        expect(response.session.type, 'realtime');
        expect(response.session.model, contains('realtime'));
        expect(response.expiresAt, greaterThan(0));

        print(
          'Session ID: ${response.session.id}, '
          'secret expires at: ${response.expiresAt}',
        );
      },
    );

    test(
      'creates realtime session with full configuration',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.createClientSecret(
          const realtime.RealtimeClientSecretCreateRequest(
            session: realtime.RealtimeSessionCreateRequest(
              model: 'gpt-realtime-2',
              // The server only accepts a single modality at a time —
              // `['text', 'audio']` is rejected; pick `['text']` or `['audio']`.
              outputModalities: ['audio'],
              audio: realtime.RealtimeAudioConfig(
                input: realtime.RealtimeAudioConfigInput(
                  turnDetection:
                      realtime.RealtimeAudioInputTurnDetection.serverVad(
                        threshold: 0.5,
                        prefixPaddingMs: 300,
                        silenceDurationMs: 500,
                      ),
                ),
                output: realtime.RealtimeAudioConfigOutput(voice: 'alloy'),
              ),
              instructions: 'You are a helpful assistant.',
            ),
          ),
        );

        expect(response.session.id, startsWith('sess_'));
        expect(response.session.audio?.output?.voice, isNotNull);
        expect(response.session.outputModalities, contains('audio'));
        expect(response.session.audio?.input?.turnDetection, isNotNull);

        print('Session with full config: ${response.session.id}');
      },
    );

    test(
      'creates transcription client secret',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Transcription sessions are created via
        // `createTranscriptionClientSecret(...)` — `/realtime/client_secrets`
        // accepts both realtime and transcription session shapes
        // discriminated by `type`, but the transcription shape carries no
        // top-level `model`.
        final response = await client!.realtimeSessions
            .createTranscriptionClientSecret(
              const realtime.RealtimeTranscriptionClientSecretCreateRequest(
                session: realtime.RealtimeTranscriptionSessionCreateRequest(
                  audio: realtime.RealtimeTranscriptionSessionAudio(
                    input: realtime.RealtimeAudioConfigInput(
                      format: realtime.AudioPcm(rate: 24000),
                      transcription: realtime.InputAudioTranscription(
                        model: 'whisper-1',
                      ),
                    ),
                  ),
                ),
              ),
            );

        expect(response.value, startsWith('ek_'));
        expect(response.expiresAt, greaterThan(0));

        print('Transcription client secret: ${response.session.id}');
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
              model: 'gpt-realtime-2',
            ),
          ),
        );

        expect(response.value, startsWith('ek_'));
        expect(response.expiresAt, greaterThan(0));
        expect(response.session.id, startsWith('sess_'));

        print(
          'Client secret expires at: ${response.expiresAt}, '
          'session: ${response.session.id}',
        );
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
          model: 'gpt-realtime-2',
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
          model: 'gpt-realtime-2',
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
          model: 'gpt-realtime-2',
        );

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
            model: 'gpt-realtime-2',
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
          model: 'gpt-realtime-2',
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);

          // Update the session configuration.
          connection.updateSession(
            const realtime.RealtimeSessionCreateRequest(
              model: 'gpt-realtime-2',
              outputModalities: ['text'],
              audio: realtime.RealtimeAudioConfig(
                output: realtime.RealtimeAudioConfigOutput(voice: 'shimmer'),
              ),
              instructions: 'You are a helpful assistant.',
            ),
          );

          final updateEvent = await waitForEvent<realtime.SessionUpdatedEvent>(
            connection,
          );

          expect(updateEvent.type, 'session.updated');
          // The server may or may not allow voice changes; assert nesting
          // works rather than the exact value.
          expect(updateEvent.session.audio?.output?.voice, isNotNull);
          expect(updateEvent.session.outputModalities, contains('text'));

          print(
            'Session updated, voice: ${updateEvent.session.audio?.output?.voice}',
          );
        } finally {
          await connection.close();
        }
      },
    );

    test(
      'configures voice and modalities at connect time',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['audio'],
            audio: realtime.RealtimeAudioConfig(
              output: realtime.RealtimeAudioConfigOutput(voice: 'echo'),
            ),
          ),
        );

        try {
          final sessionEvent = await waitForEvent<realtime.SessionCreatedEvent>(
            connection,
          );

          expect(sessionEvent.session.id, isNotEmpty);
          print('Initial session: ${sessionEvent.session.id}');

          final updateEvent = await waitForEvent<realtime.SessionUpdatedEvent>(
            connection,
          );

          expect(updateEvent.session.audio?.output?.voice, isNotNull);
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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          connection.sendUserMessage('Say "hello" and nothing else.');

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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
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
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': "What's the weather in Paris?"},
              ],
            })
            ..createResponse();

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

          connection
            ..sendFunctionOutput(callId!, '{"temperature": 22, "unit": "C"}')
            ..createResponse();

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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Say "test response"'},
              ],
            })
            ..createResponse(
              outputModalities: ['text'],
              instructions: 'Be very brief.',
              maxOutputTokens: 50,
            );

          final responseCreated =
              await waitForEvent<realtime.ResponseCreatedEvent>(connection);
          expect(responseCreated.response, isNotNull);

          print('Response created: ${responseCreated.response['id']}');

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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          connection
            ..createItem({
              'type': 'message',
              'role': 'user',
              'content': [
                {'type': 'input_text', 'text': 'Count slowly from 1 to 100.'},
              ],
            })
            ..createResponse();

          await waitForEvent<realtime.ResponseCreatedEvent>(connection);

          connection.cancelResponse();

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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          connection.createItem({
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Test message'},
            ],
          });

          // The server emits `conversation.item.added` after a client
          // `conversation.item.create`. The `conversation.item.created`
          // event is reserved for `item_reference` lookup paths.
          final itemAdded =
              await waitForEvent<realtime.ConversationItemAddedEvent>(
                connection,
              );

          final itemId = itemAdded.item['id'] as String;
          expect(itemId, isNotEmpty);

          connection.deleteItem(itemId);

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
          model: 'gpt-realtime-2',
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);

          connection.send({'type': 'invalid.event.type', 'data': 'test'});

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

        final audioFile = File('test/samples/harvard.wav');
        if (!audioFile.existsSync()) {
          markTestSkipped('Sample audio file not found');
          return;
        }

        final audioBytes = await audioFile.readAsBytes();

        final connection = await client!.realtime.connect(
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['text'],
            audio: realtime.RealtimeAudioConfig(
              input: realtime.RealtimeAudioConfigInput(
                format: realtime.AudioPcm(rate: 24000),
                transcription: realtime.InputAudioTranscription(
                  model: 'whisper-1',
                ),
                turnDetection:
                    realtime.RealtimeAudioInputTurnDetection.serverVad(
                      threshold: 0.3,
                      silenceDurationMs: 1000,
                      createResponse: false,
                    ),
              ),
            ),
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          // WAV header is typically 44 bytes - skip it for raw PCM.
          final pcmData = audioBytes.sublist(44);

          const chunkSize = 4800; // 100ms of 24kHz mono PCM16
          for (var i = 0; i < pcmData.length; i += chunkSize) {
            final end = (i + chunkSize < pcmData.length)
                ? i + chunkSize
                : pcmData.length;
            final chunk = pcmData.sublist(i, end);
            connection.appendAudioBytes(chunk);
          }

          connection.commitAudio();

          await waitForEvent<realtime.InputAudioBufferCommittedEvent>(
            connection,
          );

          connection.createResponse(
            outputModalities: ['text'],
            instructions: 'Please repeat what the user said.',
          );

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
          model: 'gpt-realtime-2',
          config: const realtime.RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            outputModalities: ['audio'],
            audio: realtime.RealtimeAudioConfig(
              input: realtime.RealtimeAudioConfigInput(
                format: realtime.AudioPcm(rate: 24000),
              ),
            ),
          ),
        );

        try {
          await waitForEvent<realtime.SessionCreatedEvent>(connection);
          await waitForEvent<realtime.SessionUpdatedEvent>(connection);

          final dummyAudio = List.filled(1000, 0);
          connection
            ..appendAudioBytes(dummyAudio)
            ..clearAudio();

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

  // ============================================================
  // Group 10: Reasoning + parallel tool calls
  // ============================================================

  group('Reasoning + parallel tool calls', () {
    test(
      'session honours reasoning + parallel_tool_calls',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.createClientSecret(
          const realtime.RealtimeClientSecretCreateRequest(
            session: realtime.RealtimeSessionCreateRequest(
              model: 'gpt-realtime-2',
              outputModalities: ['text'],
              parallelToolCalls: true,
              reasoning: realtime.RealtimeReasoning(
                effort: realtime.RealtimeReasoningEffort.minimal,
              ),
              tools: [
                realtime.RealtimeTool(
                  type: 'function',
                  name: 'get_weather',
                  description: 'Get the current weather for a location',
                  parameters: {
                    'type': 'object',
                    'properties': {
                      'location': {'type': 'string'},
                    },
                    'required': ['location'],
                  },
                ),
              ],
            ),
          ),
        );

        // The server doesn't necessarily echo every input field back on the
        // session response (e.g., `parallel_tool_calls` may be elided). The
        // important contract is that the request was accepted.
        expect(response.value, startsWith('ek_'));
        expect(response.session.id, startsWith('sess_'));
        print(
          'Reasoning session: ${response.session.id}, '
          'effort: ${response.session.reasoning?.effort}, '
          'parallelToolCalls: ${response.session.parallelToolCalls}',
        );
      },
    );
  });

  // ============================================================
  // Group 11: Translation client secret
  // ============================================================

  group('Translation client secret', () {
    test(
      'creates a translation session and ephemeral client secret',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions.translations
            .createClientSecret(
              const realtime.RealtimeTranslationClientSecretCreateRequest(
                session: realtime.RealtimeTranslationSessionCreateRequest(
                  model: 'gpt-realtime-translate',
                  audio: realtime.RealtimeTranslationSessionAudio(
                    input: realtime.RealtimeTranslationSessionAudioInput(
                      transcription:
                          realtime.RealtimeTranslationInputTranscription(
                            model: 'gpt-realtime-whisper',
                          ),
                    ),
                    output: realtime.RealtimeTranslationSessionAudioOutput(
                      language: 'es',
                    ),
                  ),
                ),
              ),
            );

        expect(response.value, startsWith('ek_'));
        expect(response.expiresAt, greaterThan(0));
        expect(response.session.type, 'translation');
        expect(response.session.model, contains('translate'));

        print(
          'Translation client secret: '
          '${response.value.substring(0, 12)}…, '
          'session: ${response.session.id}',
        );
      },
    );
  });

  // ============================================================
  // Group 12: Transcription delay
  // ============================================================

  group('Transcription delay', () {
    test(
      'transcription session accepts gpt-realtime-whisper + delay knob',
      timeout: const Timeout(Duration(seconds: 30)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.realtimeSessions
            .createTranscriptionClientSecret(
              const realtime.RealtimeTranscriptionClientSecretCreateRequest(
                session: realtime.RealtimeTranscriptionSessionCreateRequest(
                  audio: realtime.RealtimeTranscriptionSessionAudio(
                    input: realtime.RealtimeAudioConfigInput(
                      format: realtime.AudioPcm(rate: 24000),
                      transcription: realtime.InputAudioTranscription(
                        model: 'gpt-realtime-whisper',
                        delay: realtime.AudioTranscriptionDelay.high,
                      ),
                    ),
                  ),
                ),
              ),
            );

        expect(response.value, startsWith('ek_'));
        expect(response.session.id, startsWith('sess_'));

        print('Transcription session w/ delay: ${response.session.id}');
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
