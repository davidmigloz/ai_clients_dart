import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SkillAssetContent', () {
    group('factories', () {
      test('raw sets rawContent and isExecutable', () {
        const asset = SkillAssetContent.raw(
          rawContent: 'aGVsbG8=',
          isExecutable: true,
        );

        expect(asset.rawContent, 'aGVsbG8=');
        expect(asset.textContent, isNull);
        expect(asset.isExecutable, true);
      });

      test('text sets textContent and isExecutable', () {
        const asset = SkillAssetContent.text(
          textContent: 'print("hi")',
          isExecutable: false,
        );

        expect(asset.textContent, 'print("hi")');
        expect(asset.rawContent, isNull);
        expect(asset.isExecutable, false);
      });
    });

    group('fromJson', () {
      test('parses rawContent variant', () {
        final asset = SkillAssetContent.fromJson(const {
          'rawContent': 'aGVsbG8=',
          'isExecutable': true,
        });

        expect(asset.rawContent, 'aGVsbG8=');
        expect(asset.isExecutable, true);
      });

      test('parses textContent variant', () {
        final asset = SkillAssetContent.fromJson(const {
          'textContent': 'hello',
        });

        expect(asset.textContent, 'hello');
        expect(asset.isExecutable, isNull);
      });

      test('throws FormatException when neither key is present', () {
        expect(
          () => SkillAssetContent.fromJson(const {'isExecutable': true}),
          throwsFormatException,
        );
      });

      test('throws FormatException when both keys are present', () {
        expect(
          () => SkillAssetContent.fromJson(const {
            'rawContent': 'aGVsbG8=',
            'textContent': 'hello',
          }),
          throwsFormatException,
        );
      });
    });

    group('toJson', () {
      test('serializes raw variant', () {
        const asset = SkillAssetContent.raw(rawContent: 'aGVsbG8=');

        expect(asset.toJson(), {'rawContent': 'aGVsbG8='});
      });

      test('serializes text variant', () {
        const asset = SkillAssetContent.text(textContent: 'hello');

        expect(asset.toJson(), {'textContent': 'hello'});
      });
    });

    group('round-trip', () {
      test('fromJson/toJson preserves raw data', () {
        const original = SkillAssetContent.raw(
          rawContent: 'aGVsbG8=',
          isExecutable: true,
        );

        final roundTripped = SkillAssetContent.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });

      test('fromJson/toJson preserves text data', () {
        const original = SkillAssetContent.text(textContent: 'hello');

        final roundTripped = SkillAssetContent.fromJson(original.toJson());

        expect(roundTripped, equals(original));
      });
    });

    group('constructor', () {
      test('asserts when neither rawContent nor textContent is set', () {
        expect(SkillAssetContent.new, throwsA(isA<AssertionError>()));
      });

      test('asserts when both rawContent and textContent are set', () {
        expect(
          () => SkillAssetContent(rawContent: 'a', textContent: 'b'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('copyWith', () {
      test('replaces fields', () {
        const original = SkillAssetContent.text(textContent: 'a');

        final copy = original.copyWith(textContent: 'b');

        expect(copy.textContent, 'b');
      });

      test('clears fields when null is passed explicitly', () {
        const original = SkillAssetContent.text(
          textContent: 'a',
          isExecutable: true,
        );

        final copy = original.copyWith(isExecutable: null);

        expect(copy.isExecutable, isNull);
      });

      test('preserves fields when not specified', () {
        const original = SkillAssetContent.text(textContent: 'a');

        expect(original.copyWith(), equals(original));
      });

      test('asserts when the result would have neither content set', () {
        const original = SkillAssetContent.text(textContent: 'a');

        expect(
          () => original.copyWith(textContent: null),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts when the result would have both contents set', () {
        const original = SkillAssetContent.text(textContent: 'a');

        expect(
          () => original.copyWith(rawContent: 'b'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('equality', () {
      test('equal when fields match', () {
        const a = SkillAssetContent.text(textContent: 'a');
        const b = SkillAssetContent.text(textContent: 'a');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when content differs', () {
        const a = SkillAssetContent.text(textContent: 'a');
        const b = SkillAssetContent.text(textContent: 'b');

        expect(a, isNot(equals(b)));
      });
    });

    test('toString includes summary', () {
      const asset = SkillAssetContent.text(textContent: 'hello');

      expect(asset.toString(), contains('SkillAssetContent'));
      expect(asset.toString(), contains('hello'));
    });
  });
}
