import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('JSONPatchAppendValue', () {
    test('parses a plain string value', () {
      final value = JSONPatchAppendValue.fromJson('hello');

      expect(value, isA<JSONPatchAppendStringValue>());
      expect((value as JSONPatchAppendStringValue).value, 'hello');
      expect(value.toJson(), 'hello');
    });

    test('parses an encrypted wrapper value', () {
      final value = JSONPatchAppendValue.fromJson(const {
        'type': '__encrypted__',
        'value': 'ZW5jcnlwdGVk',
      });

      expect(value, isA<JSONPatchAppendEncryptedValue>());
      final encrypted = (value as JSONPatchAppendEncryptedValue).value;
      expect(encrypted.type, '__encrypted__');
      expect(encrypted.value, 'ZW5jcnlwdGVk');
      expect(value.toJson(), {
        'type': '__encrypted__',
        'value': 'ZW5jcnlwdGVk',
      });
    });

    test('throws on an unexpected type', () {
      expect(
        () => JSONPatchAppendValue.fromJson(42),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('EncryptedPatchValue', () {
    test('fromJson validates the discriminator', () {
      expect(
        () =>
            EncryptedPatchValue.fromJson(const {'type': 'nope', 'value': 'x'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString redacts the payload', () {
      const value = EncryptedPatchValue(value: 'super-secret-cipher');

      expect(value.toString(), contains('chars'));
      expect(value.toString(), isNot(contains('super-secret-cipher')));
    });
  });

  group('JSONPatchAppend', () {
    test('round-trips a string value', () {
      const append = JSONPatchAppend(
        path: '/log',
        value: JSONPatchAppendStringValue('entry'),
      );

      final json = append.toJson();
      expect(json, {'op': 'append', 'path': '/log', 'value': 'entry'});
      expect(JSONPatchAppend.fromJson(json), equals(append));
    });

    test('parses and round-trips an encrypted value', () {
      final json = {
        'op': 'append',
        'path': '/secret',
        'value': {'type': '__encrypted__', 'value': 'ZW5j'},
      };

      final append = JSONPatchAppend.fromJson(json);
      expect(append.value, isA<JSONPatchAppendEncryptedValue>());
      expect(append.toJson()['value'], {
        'type': '__encrypted__',
        'value': 'ZW5j',
      });
    });
  });
}
