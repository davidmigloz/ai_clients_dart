import 'package:openai_dart/src/models/responses/config/reasoning_mode.dart';
import 'package:test/test.dart';

void main() {
  group('ReasoningMode', () {
    test('known modes round-trip', () {
      for (final mode in [
        const StandardReasoningMode(),
        const ProReasoningMode(),
      ]) {
        final restored = ReasoningMode.fromJson(mode.toJson());
        expect(restored, equals(mode));
      }

      expect(ReasoningMode.fromJson('standard'), isA<StandardReasoningMode>());
      expect(ReasoningMode.fromJson('pro'), isA<ProReasoningMode>());
      expect(const StandardReasoningMode().toJson(), equals('standard'));
      expect(const ProReasoningMode().toJson(), equals('pro'));
    });

    test('unrecognized values become CustomReasoningMode', () {
      final custom = ReasoningMode.fromJson('turbo');
      expect(custom, isA<CustomReasoningMode>());
      expect(custom.toJson(), equals('turbo'));
      expect(custom, equals(const ReasoningMode.custom('turbo')));
      expect(custom, isNot(equals(const StandardReasoningMode())));
    });

    test('factory constructors produce expected variants', () {
      expect(const ReasoningMode.standard(), isA<StandardReasoningMode>());
      expect(const ReasoningMode.pro(), isA<ProReasoningMode>());
      expect(const ReasoningMode.custom('x'), isA<CustomReasoningMode>());
    });

    test('equality and hashCode', () {
      expect(
        const StandardReasoningMode(),
        equals(const StandardReasoningMode()),
      );
      expect(const ProReasoningMode(), equals(const ProReasoningMode()));
      expect(
        const CustomReasoningMode('foo'),
        equals(const CustomReasoningMode('foo')),
      );
      expect(
        const CustomReasoningMode('foo'),
        isNot(equals(const CustomReasoningMode('bar'))),
      );
      expect(
        const StandardReasoningMode().hashCode,
        equals(const StandardReasoningMode().hashCode),
      );
    });

    test('toString', () {
      expect(
        const StandardReasoningMode().toString(),
        'ReasoningMode.standard()',
      );
      expect(const ProReasoningMode().toString(), 'ReasoningMode.pro()');
      expect(
        const CustomReasoningMode('foo').toString(),
        'ReasoningMode.custom(foo)',
      );
    });
  });
}
