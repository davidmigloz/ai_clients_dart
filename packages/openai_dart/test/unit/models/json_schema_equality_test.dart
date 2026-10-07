import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/common/equality_helpers.dart';
import 'package:test/test.dart';

void main() {
  test(
    'structured schemas compare deeply with order-independent map hashes',
    () {
      final a = ResponseFormat.jsonSchema(
        name: 'result',
        schema: {
          'type': 'object',
          'required': ['name', 'count'],
          'properties': <dynamic, dynamic>{
            'name': {'type': 'string'},
            'count': {'type': 'integer'},
          },
        },
      );
      final b = ResponseFormat.jsonSchema(
        name: 'result',
        schema: {
          'properties': {
            'count': {'type': 'integer'},
            'name': {'type': 'string'},
          },
          'required': ['name', 'count'],
          'type': 'object',
        },
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.toJson(), b.toJson());
      final c = ResponseFormat.jsonSchema(
        name: 'result',
        schema: {
          'type': 'object',
          'required': ['count', 'name'],
          'properties': {
            'count': {'type': 'integer'},
            'name': {'type': 'string'},
          },
        },
      );
      expect(a, isNot(c));
      final requestA = ChatCompletionCreateRequest(
        model: 'model',
        messages: const [],
        responseFormat: a,
      );
      final requestB = ChatCompletionCreateRequest(
        model: 'model',
        messages: const [],
        responseFormat: b,
      );
      expect(requestA, requestB);
      expect(requestA.hashCode, requestB.hashCode);
      expect({requestA, requestB}, hasLength(1));
    },
  );
  test('metadata equality handles nested generic maps with arbitrary keys', () {
    final a = <String, dynamic>{
      'nested': <dynamic, dynamic>{
        'values': [
          <dynamic, dynamic>{
            1: 'one',
            2: ['two'],
          },
        ],
      },
    };
    final b = <String, dynamic>{
      'nested': {
        'values': [
          <int, dynamic>{
            2: ['two'],
            1: 'one',
          },
        ],
      },
    };
    expect(mapsDeepEqual(a, b), isTrue);
    expect(mapDeepHashCode(a), mapDeepHashCode(b));
    expect(
      mapsDeepEqual(a, {
        'nested': {
          'values': [
            {
              1: 'one',
              2: ['changed'],
            },
          ],
        },
      }),
      isFalse,
    );
  });
  test('Responses structured schema equality reaches request map/set keys', () {
    const a = TextConfig(
      format: JsonSchemaFormat(
        name: 'result',
        schema: {
          'type': 'object',
          'required': ['name'],
          'properties': <dynamic, dynamic>{
            'name': {'type': 'string'},
          },
        },
      ),
    );
    const b = TextConfig(
      format: JsonSchemaFormat(
        name: 'result',
        schema: {
          'properties': {
            'name': {'type': 'string'},
          },
          'required': ['name'],
          'type': 'object',
        },
      ),
    );
    const requestA = CreateResponseRequest(
      model: 'model',
      input: ResponseInput.text('Hello'),
      text: a,
    );
    const requestB = CreateResponseRequest(
      model: 'model',
      input: ResponseInput.text('Hello'),
      text: b,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(requestA, requestB);
    expect(requestA.hashCode, requestB.hashCode);
    expect({requestA, requestB}, hasLength(1));
    const changed = TextConfig(
      format: JsonSchemaFormat(
        name: 'result',
        schema: {
          'type': 'object',
          'required': ['different'],
          'properties': {
            'name': {'type': 'string'},
          },
        },
      ),
    );
    expect(a, isNot(changed));
    expect(requestA.copyWith(text: changed), isNot(requestA));
  });
}
