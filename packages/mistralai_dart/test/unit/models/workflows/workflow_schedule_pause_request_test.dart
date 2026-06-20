import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WorkflowSchedulePauseRequest', () {
    test('fromJson parses note', () {
      final request = WorkflowSchedulePauseRequest.fromJson(const {
        'note': 'paused',
      });

      expect(request.note, 'paused');
    });

    test('toJson omits null note', () {
      const request = WorkflowSchedulePauseRequest();

      expect(request.toJson(), <String, dynamic>{});
    });

    test('toJson round-trips with note', () {
      const request = WorkflowSchedulePauseRequest(note: 'paused');

      expect(request.toJson(), {'note': 'paused'});
      expect(
        WorkflowSchedulePauseRequest.fromJson(request.toJson()),
        equals(request),
      );
    });

    test('copyWith clears note', () {
      const request = WorkflowSchedulePauseRequest(note: 'paused');

      expect(request.copyWith(note: null).note, isNull);
      expect(request.copyWith().note, 'paused');
    });

    test('equality and hashCode', () {
      const a = WorkflowSchedulePauseRequest(note: 'x');
      const b = WorkflowSchedulePauseRequest(note: 'x');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains note', () {
      const request = WorkflowSchedulePauseRequest(note: 'paused');

      expect(request.toString(), contains('note: paused'));
    });
  });
}
