import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DoneReason', () {
    test('doneReasonFromString returns correct enum values', () {
      expect(doneReasonFromString('stop'), DoneReason.stop);
      expect(doneReasonFromString('length'), DoneReason.length);
      expect(doneReasonFromString('load'), DoneReason.load);
      expect(doneReasonFromString('unload'), DoneReason.unload);
    });

    test('doneReasonFromString returns null for unknown values', () {
      expect(doneReasonFromString('unknown'), isNull);
      expect(doneReasonFromString(null), isNull);
      expect(doneReasonFromString(''), isNull);
    });

    test('doneReasonToString returns correct string values', () {
      expect(doneReasonToString(DoneReason.stop), 'stop');
      expect(doneReasonToString(DoneReason.length), 'length');
      expect(doneReasonToString(DoneReason.load), 'load');
      expect(doneReasonToString(DoneReason.unload), 'unload');
    });
  });
}
