import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseToolChoiceShell', () {
    test('value equality distinguishes subclasses', () {
      expect(
        const ResponseToolChoiceShell(),
        isNot(const _DerivedShellChoice()),
      );
      expect(
        const _DerivedShellChoice(),
        isNot(const ResponseToolChoiceShell()),
      );
    });
    test('factory, dispatch and direct parser retain the exact choice', () {
      final choice = ResponseToolChoice.shell();
      expect(choice, isA<ResponseToolChoiceShell>());
      expect(choice.toJson(), {'type': 'shell'});
      expect(ResponseToolChoice.fromJson(choice.toJson()), choice);
      expect(ResponseToolChoiceShell.fromJson(choice.toJson()), choice);
      expect(choice.hashCode, const ResponseToolChoiceShell().hashCode);
      expect(choice, isNot(ResponseToolChoice.auto));
      expect(choice.copyWith(), choice);
      expect(choice.type, 'shell');
      expect(choice.toString(), 'ResponseToolChoiceShell(type: shell)');
    });

    for (final value in [null, 1, 'local_shell', 'future_tool']) {
      test('direct parser rejects invalid type $value contextually', () {
        expect(
          () => ResponseToolChoiceShell.fromJson({'type': value}),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'context',
              contains('ResponseToolChoiceShell.type'),
            ),
          ),
        );
      });
    }
    test('direct and union parsers reject a missing discriminator', () {
      expect(
        () => ResponseToolChoiceShell.fromJson(const {}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ResponseToolChoice.fromJson(<String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });
    test(
      'existing mode, function, allowed, web and programmatic choices survive',
      () {
        for (final choice in <ResponseToolChoice>[
          ResponseToolChoice.none,
          ResponseToolChoice.auto,
          ResponseToolChoice.required,
          ResponseToolChoice.function(name: 'calculate'),
          const ResponseToolChoiceAllowedTools(
            tools: [SpecificFunctionChoice(name: 'calculate')],
            mode: ToolChoiceMode.auto,
          ),
          ResponseToolChoice.webSearch(),
          const ResponseToolChoiceProgrammatic(),
        ]) {
          expect(ResponseToolChoice.fromJson(choice.toJson()), choice);
        }
      },
    );
  });
}

class _DerivedShellChoice extends ResponseToolChoiceShell {
  const _DerivedShellChoice();
}
