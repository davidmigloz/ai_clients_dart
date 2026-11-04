import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseToolChoiceCustom', () {
    test('public factories and request parser round trip the named choice', () {
      final choice = ResponseToolChoice.custom(name: 'execute');
      const json = {'type': 'custom', 'name': 'execute'};
      expect(choice, isA<ResponseToolChoiceCustom>());
      expect(choice.type, 'custom');
      expect(choice.toJson(), json);
      expect(ResponseToolChoice.fromJson(json), choice);
      expect(ResponseToolChoiceCustom.fromJson(json), choice);
      final request = CreateResponseRequest(
        model: 'fixture',
        input: const ResponseInput.text('hello'),
        toolChoice: choice,
      );
      expect(request.toJson()['tool_choice'], json);
      expect(
        CreateResponseRequest.fromJson(request.toJson()).toolChoice,
        choice,
      );
    });
    test('copy and value equality retain runtime type', () {
      const choice = ResponseToolChoiceCustom(name: 'execute');
      expect(choice.copyWith(), choice);
      expect(
        choice.copyWith(name: 'other'),
        const ResponseToolChoiceCustom(name: 'other'),
      );
      expect(
        choice.hashCode,
        const ResponseToolChoiceCustom(name: 'execute').hashCode,
      );
      expect(choice, isNot(const _DerivedChoice(name: 'execute')));
      expect(choice, isNot(ResponseToolChoice.function(name: 'execute')));
      expect(choice.toString(), 'ResponseToolChoiceCustom(name: execute)');
    });
    for (final json in <Map<String, dynamic>>[
      {},
      {'type': 'function', 'name': 'x'},
      {'type': 'custom'},
      {'type': 'custom', 'name': 1},
    ]) {
      test('direct parser rejects malformed discriminator or name: $json', () {
        expect(
          () => ResponseToolChoiceCustom.fromJson(json),
          throwsFormatException,
        );
      });
    }
    test('other existing choices retain dispatch', () {
      for (final choice in <ResponseToolChoice>[
        ResponseToolChoice.none,
        ResponseToolChoice.auto,
        ResponseToolChoice.required,
        ResponseToolChoice.function(name: 'execute'),
        ResponseToolChoice.shell(),
        ResponseToolChoice.webSearch(),
        const ResponseToolChoiceProgrammatic(),
      ]) {
        expect(ResponseToolChoice.fromJson(choice.toJson()), choice);
      }
    });
  });
}

class _DerivedChoice extends ResponseToolChoiceCustom {
  const _DerivedChoice({required super.name});
}
