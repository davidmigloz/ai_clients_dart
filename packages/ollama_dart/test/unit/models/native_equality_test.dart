import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  test('PushRequest equality and diagnostics include every public option', () {
    const original = PushRequest(model: 'm', insecure: true, stream: false);
    final decoded = PushRequest.fromJson(original.toJson());
    expect(decoded, original);
    expect(decoded.hashCode, original.hashCode);
    expect(original.copyWith(), original);
    expect(original, isNot(original.copyWith(model: 'other')));
    expect(original, isNot(original.copyWith(insecure: false)));
    expect(original, isNot(original.copyWith(stream: true)));
    expect(original, isNot(original.copyWith(insecure: null)));
    expect(original, isNot(original.copyWith(stream: null)));
    expect(
      original.toString(),
      'PushRequest(model: m, insecure: true, stream: false)',
    );
  });

  group('ListResponse equality', () {
    test('compares distinct lists of equivalent model metadata by value', () {
      final first = ListResponse.fromJson(const {
        'models': [
          {
            'name': 'm',
            'capabilities': ['completion', 'vision'],
            'details': {'runner': 'mlx'},
          },
        ],
      });
      final second = ListResponse.fromJson(first.toJson());
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect({first, second}, hasLength(1));
    });

    test('detects changed model content, ordering, length, and absence', () {
      const first = ListResponse(
        models: [
          ModelSummary(name: 'first'),
          ModelSummary(name: 'second'),
        ],
      );
      expect(
        first,
        isNot(
          const ListResponse(
            models: [
              ModelSummary(name: 'other'),
              ModelSummary(name: 'second'),
            ],
          ),
        ),
      );
      expect(
        first,
        isNot(
          const ListResponse(
            models: [
              ModelSummary(name: 'second'),
              ModelSummary(name: 'first'),
            ],
          ),
        ),
      );
      expect(
        first,
        isNot(const ListResponse(models: [ModelSummary(name: 'first')])),
      );
      expect(first, isNot(const ListResponse()));
      expect(const ListResponse(), const ListResponse());
      expect(const ListResponse(models: []), const ListResponse(models: []));
      expect(const ListResponse(), isNot(const ListResponse(models: [])));
    });
  });

  group('StatusEvent equality', () {
    test('does not collapse distinct progress updates', () {
      const first = StatusEvent(
        status: 'downloading',
        digest: 'sha256:abc',
        total: 100,
        completed: 10,
      );
      final decoded = StatusEvent.fromJson(first.toJson());
      expect(decoded, first);
      expect(decoded.hashCode, first.hashCode);
      expect(first.copyWith(), first);
      expect(first, isNot(first.copyWith(status: 'done')));
      expect(first, isNot(first.copyWith(digest: 'sha256:other')));
      expect(first, isNot(first.copyWith(total: 200)));
      expect(first, isNot(first.copyWith(completed: 20)));
      expect(first, isNot(first.copyWith(total: null)));
      expect(first, isNot(first.copyWith(completed: null)));
      expect({first, decoded, first.copyWith(completed: 20)}, hasLength(2));
      expect(first.progress, 0.1);
      expect(first.toString(), contains('status: downloading'));
      expect(first.toString(), contains('digest: sha256:abc'));
      expect(first.toString(), contains('total: 100'));
      expect(first.toString(), contains('completed: 10'));
      expect(first.toString(), contains('progress: 10.0%'));
    });

    test('preserves equality and diagnostics for absent progress fields', () {
      const first = StatusEvent(status: 'success');
      final second = StatusEvent.fromJson(const {'status': 'success'});
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.progress, isNull);
      expect(first.toString(), contains('total: null, completed: null'));
      expect(first.toString(), contains('progress: N/A'));
    });
  });
}
