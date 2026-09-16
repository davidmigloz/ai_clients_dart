import 'package:openai_realtime_dart/openai_realtime_dart.dart';
import 'package:test/test.dart';

void main() {
  test('session configuration preserves nested JSON and nullable copying', () {
    const json = {
      'modalities': ['text', 'audio'],
      'instructions': 'Be concise',
      'turn_detection': null,
      'input_audio_transcription': {'model': 'whisper-1', 'language': 'en'},
      'tools': [
        {
          'type': 'function',
          'name': 'weather',
          'parameters': {
            'type': 'object',
            'properties': {
              'city': {'type': 'string'},
            },
          },
        },
      ],
    };
    final session = SessionConfig.fromJson(json);
    expect(session.toJson(), json);
    expect(SessionConfig.fromJson(session.toJson()), session);
    final copy = session.copyWith(
      instructions: null,
      inputAudioTranscription: null,
    );
    expect(copy.toJson().containsKey('instructions'), isFalse);
    expect(copy.toJson().containsKey('input_audio_transcription'), isFalse);
    expect(copy.tools, session.tools);
    expect(session.instructions, 'Be concise');
  });

  test('nested event unions preserve discriminators and copying', () {
    const json = {
      'type': 'conversation.item.create',
      'event_id': 'event_1',
      'previous_item_id': 'item_0',
      'item': {
        'type': 'message',
        'id': 'item_1',
        'role': 'user',
        'content': [
          {'type': 'input_text', 'text': 'Hello'},
        ],
      },
    };
    final event = RealtimeEvent.fromJson(json);
    expect(event, isA<RealtimeEventConversationItemCreate>());
    expect(event.toJson(), json);
    final item = event.mapOrNull(conversationItemCreate: (value) => value.item);
    expect(item, isA<ItemMessage>());
    expect((item! as ItemMessage).content.single, isA<ContentPartInputText>());
    final copy = (event as RealtimeEventConversationItemCreate).copyWith(
      eventId: 'event_2',
      previousItemId: null,
    );
    expect(copy.toJson().containsKey('previous_item_id'), isFalse);
    expect(copy.eventId, 'event_2');
    expect(copy.item, event.item);
    expect(RealtimeEvent.fromJson(copy.toJson()), copy);
  });

  test('tool parameters retain deep equality across generated models', () {
    ToolDefinition makeTool() => ToolDefinition.fromJson({
      'name': 'weather',
      'parameters': {
        'required': ['city'],
        'properties': {
          'city': {'type': 'string'},
        },
      },
    });
    final first = makeTool();
    final second = makeTool();
    expect(identical(first, second), isFalse);
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first.toJson()['type'], 'function');
    expect(
      first.copyWith(parameters: null).toJson().containsKey('parameters'),
      isFalse,
    );
  });
}
