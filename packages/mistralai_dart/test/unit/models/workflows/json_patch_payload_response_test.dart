import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('JSONPatchPayloadValue', () {
    test('parses a list of operations', () {
      final value = JSONPatchPayloadValue.fromJson(const [
        {'op': 'add', 'path': '/a', 'value': 1},
      ]);

      expect(value, isA<JSONPatchPayloadOperations>());
      expect((value as JSONPatchPayloadOperations).operations, hasLength(1));
      expect(value.toJson(), [
        {'op': 'add', 'path': '/a', 'value': 1},
      ]);
    });

    test('parses an encrypted string', () {
      final value = JSONPatchPayloadValue.fromJson('ZW5jcnlwdGVk');

      expect(value, isA<JSONPatchPayloadEncryptedValue>());
      expect((value as JSONPatchPayloadEncryptedValue).data, 'ZW5jcnlwdGVk');
      expect(value.toJson(), 'ZW5jcnlwdGVk');
    });

    test('throws on an unexpected type', () {
      expect(
        () => JSONPatchPayloadValue.fromJson(42),
        throwsA(isA<FormatException>()),
      );
    });

    test('toString redacts the encrypted payload', () {
      const value = JSONPatchPayloadEncryptedValue('super-secret-bytes');

      expect(value.toString(), contains('chars'));
      expect(value.toString(), isNot(contains('super-secret-bytes')));
    });
  });

  group('JSONPatchPayloadResponse', () {
    test('round-trips the operations variant', () {
      final response = JSONPatchPayloadResponse(
        value: JSONPatchPayloadOperations(const [
          {'op': 'replace', 'path': '/x', 'value': 'y'},
        ]),
        encodingOptions: const [EncodedPayloadOptions.offloaded],
      );

      final json = response.toJson();
      expect(json['value'], [
        {'op': 'replace', 'path': '/x', 'value': 'y'},
      ]);
      expect(JSONPatchPayloadResponse.fromJson(json), equals(response));
    });

    test('parses and round-trips the encrypted variant', () {
      final json = {
        'type': 'json_patch',
        'value': 'ZW5jcnlwdGVk',
        'encoding_options': ['encrypted'],
      };

      final response = JSONPatchPayloadResponse.fromJson(json);
      expect(response.value, isA<JSONPatchPayloadEncryptedValue>());
      expect(response.toJson()['value'], 'ZW5jcnlwdGVk');
      expect(response.encodingOptions, [EncodedPayloadOptions.encrypted]);
    });
  });
}
