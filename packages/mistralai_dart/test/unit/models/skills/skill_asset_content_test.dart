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

      test('throws FormatException when the present key is null', () {
        expect(
          () => SkillAssetContent.fromJson(const {'rawContent': null}),
          throwsFormatException,
        );
        expect(
          () => SkillAssetContent.fromJson(const {'textContent': null}),
          throwsFormatException,
        );
      });

      test('throws FormatException when the present key is not a String', () {
        expect(
          () => SkillAssetContent.fromJson(const {'rawContent': 123}),
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
      test('throws ArgumentError when neither rawContent nor textContent is '
          'set', () {
        expect(SkillAssetContent.new, throwsArgumentError);
      });

      test('throws ArgumentError when both rawContent and textContent are '
          'set', () {
        expect(
          () => SkillAssetContent(rawContent: 'a', textContent: 'b'),
          throwsArgumentError,
        );
      });

      test('validation is not stripped in release mode (not an assert)', () {
        // Regression guard: this must be a runtime check (ArgumentError),
        // not `assert`, since asserts are stripped from release builds.
        expect(
          () => SkillAssetContent(rawContent: 'a', textContent: 'b'),
          throwsA(isNot(isA<AssertionError>())),
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

      test('throws ArgumentError when the result would have neither content '
          'set', () {
        const original = SkillAssetContent.text(textContent: 'a');

        expect(() => original.copyWith(textContent: null), throwsArgumentError);
      });

      test('throws ArgumentError when the result would have both contents '
          'set', () {
        const original = SkillAssetContent.text(textContent: 'a');

        // Switching content kind requires explicitly clearing the other
        // field in the same call (see the copyWith doc comment); passing
        // only the new field leaves the old one set too.
        expect(() => original.copyWith(rawContent: 'b'), throwsArgumentError);
      });

      test('switching content kind requires clearing the other field', () {
        const original = SkillAssetContent.text(textContent: 'a');

        final switched = original.copyWith(rawContent: 'b', textContent: null);

        expect(switched.rawContent, 'b');
        expect(switched.textContent, isNull);
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
