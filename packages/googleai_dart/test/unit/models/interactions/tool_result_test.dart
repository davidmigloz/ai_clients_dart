import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolResult', () {
    group('fromJson', () {
      test('parses String as ToolResultText', () {
        final result = ToolResult.fromJson('sunny weather');
        expect(result, isA<ToolResultText>());
        expect((result as ToolResultText).text, 'sunny weather');
      });

      test('parses List as ToolResultContentList', () {
        final result = ToolResult.fromJson([
          {'type': 'text', 'text': 'Hello'},
          {'type': 'text', 'text': 'World'},
        ]);
        expect(result, isA<ToolResultContentList>());
        final contentList = result as ToolResultContentList;
        expect(contentList.items, hasLength(2));
        expect(contentList.items[0], isA<TextContent>());
        expect((contentList.items[0] as TextContent).text, 'Hello');
        expect((contentList.items[1] as TextContent).text, 'World');
      });

      test('parses Map as ToolResultObject', () {
        final result = ToolResult.fromJson({'temp': 72, 'unit': 'F'});
        expect(result, isA<ToolResultObject>());
        final obj = result as ToolResultObject;
        expect(obj.value, {'temp': 72, 'unit': 'F'});
      });

      test(
        'parses Map with items key as ToolResultObject (not content list)',
        () {
          // Maps are always ToolResultObject, even if they have an 'items' key
          final result = ToolResult.fromJson({
            'items': [1, 2, 3],
          });
          expect(result, isA<ToolResultObject>());
        },
      );

      test('throws ArgumentError for unsupported types', () {
        expect(() => ToolResult.fromJson(42), throwsArgumentError);
      });
    });

    group('toJson', () {
      test('ToolResultText serializes to String', () {
        const result = ToolResultText('hello');
        expect(result.toJson(), 'hello');
      });

      test('ToolResultContentList serializes to List', () {
        const result = ToolResultContentList([TextContent(text: 'Hello')]);
        final json = result.toJson() as List;
        expect(json, hasLength(1));
        expect((json[0] as Map)['type'], 'text');
        expect((json[0] as Map)['text'], 'Hello');
      });

      test('ToolResultObject serializes to Map', () {
        const result = ToolResultObject({'key': 'value'});
        expect(result.toJson(), {'key': 'value'});
      });
    });

    group('round-trip', () {
      test('ToolResultText round-trips', () {
        const original = ToolResultText('test result');
        final restored = ToolResult.fromJson(original.toJson());
        expect(restored, isA<ToolResultText>());
        expect((restored as ToolResultText).text, 'test result');
      });

      test('ToolResultContentList round-trips', () {
        const original = ToolResultContentList([
          TextContent(text: 'Response data'),
        ]);
        final restored = ToolResult.fromJson(original.toJson());
        expect(restored, isA<ToolResultContentList>());
        final list = restored as ToolResultContentList;
        expect(list.items, hasLength(1));
        expect((list.items[0] as TextContent).text, 'Response data');
      });

      test('ToolResultObject round-trips', () {
        const original = ToolResultObject({'data': 'test', 'count': 5});
        final restored = ToolResult.fromJson(original.toJson());
        expect(restored, isA<ToolResultObject>());
        expect((restored as ToolResultObject).value, {
          'data': 'test',
          'count': 5,
        });
      });
    });
  });
}
