import 'dart:convert';
import 'package:test/test.dart';
import '../../fixtures/vault_wire_fixtures.dart';

void main() {
  for (final fixture in vaultWireFixtures) {
    test(
      '${fixture.schema}: independent minimal/full wire and value semantics',
      () {
        for (final wire in [fixture.minimal, fixture.full]) {
          final value = fixture.parse(wire);
          expect(value.toJson(), wire);
          final copied = copyVaultFixture(value);
          expect(copied.toJson(), wire);
          expect(copied, value);
          expect(copied.hashCode, value.hashCode);
          expect(value.toString(), isNot(contains('PRIVATE')));
        }
      },
    );
    if (fixture.full is Map<String, dynamic>) {
      test(
        '${fixture.schema}: required presence and nonnull types fail privately',
        () {
          for (final key in fixture.requiredKeys) {
            final missing = Map<String, dynamic>.from(fixture.full! as Map)
              ..remove(key);
            expect(() => fixture.parse(missing), throwsA(_privateFormat));
            if (!fixture.nullableKeys.contains(key)) {
              expect(
                () => fixture.parse({...missing, key: null}),
                throwsA(_privateFormat),
              );
            }
          }
          for (final key in fixture.optionalNonnullKeys) {
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                key: null,
              }),
              throwsA(_privateFormat),
            );
          }
        },
      );
      test(
        '${fixture.schema}: future extras are closed for writes and owned for reads',
        () {
          final extra = <String, dynamic>{
            'nested': <Object?>['PRIVATE-future', null, true],
          };
          final input = {
            ...fixture.full! as Map<String, dynamic>,
            'future': extra,
          };
          if (fixture.writable) {
            expect(() => fixture.parse(input), throwsA(_privateFormat));
          } else {
            final value = fixture.parse(input);
            final expected = jsonDecode(jsonEncode(input));
            (extra['nested'] as List)[0] = 'changed';
            expect(value.toJson(), expected);
            expect(value.toString(), isNot(contains('PRIVATE')));
            expect(copyVaultFixture(value), value);
            expect(
              () =>
                  (((value.toJson() as Map<String, dynamic>)['future']
                              as Map<String, dynamic>)['nested']
                          as List<Object?>)
                      .add(0),
              throwsUnsupportedError,
            );
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                'future': double.nan,
              }),
              throwsA(_privateFormat),
            );
            final cycle = <String, dynamic>{};
            cycle['self'] = cycle;
            expect(
              () => fixture.parse({
                ...fixture.full! as Map<String, dynamic>,
                'future': cycle,
              }),
              throwsA(_privateFormat),
            );
          }
        },
      );
    }
  }
}

final TypeMatcher<FormatException> _privateFormat = isA<FormatException>()
    .having(
      (error) => error.toString(),
      'private message',
      isNot(contains('PRIVATE')),
    );
