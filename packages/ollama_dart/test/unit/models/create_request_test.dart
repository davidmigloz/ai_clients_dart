import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('CreateRequest', () {
    test('fromJson creates request correctly', () {
      final json = {
        'model': 'llama3.2',
        'from': 'llama3.1',
        'template': '{{ .Prompt }}',
        'license': 'MIT',
        'system': 'You are a helpful assistant.',
        'parameters': {'temperature': 0.7},
        'messages': [
          {'role': 'user', 'content': 'Hello'},
        ],
        'quantize': 'q4_K_M',
        'renderer': 'qwen3.5',
        'parser': 'harmony',
        'files': {'model.gguf': 'sha256:abc123'},
        'adapters': {'adapter.gguf': 'sha256:def456'},
        'draft_quantize': 'q8_0',
        'draft_files': {'draft.gguf': 'sha256:ghi789'},
        'remote_host': 'https://example.com',
        'requires': '0.5.0',
        'info': {'author': 'someone'},
        'stream': false,
      };

      final request = CreateRequest.fromJson(json);

      expect(request.model, 'llama3.2');
      expect(request.from, 'llama3.1');
      expect(request.template, '{{ .Prompt }}');
      expect(request.license, 'MIT');
      expect(request.system, 'You are a helpful assistant.');
      expect(request.parameters, {'temperature': 0.7});
      expect(request.messages?.length, 1);
      expect(request.messages?.first.content, 'Hello');
      expect(request.quantize, 'q4_K_M');
      expect(request.renderer, 'qwen3.5');
      expect(request.parser, 'harmony');
      expect(request.files, {'model.gguf': 'sha256:abc123'});
      expect(request.adapters, {'adapter.gguf': 'sha256:def456'});
      expect(request.draftQuantize, 'q8_0');
      expect(request.draftFiles, {'draft.gguf': 'sha256:ghi789'});
      expect(request.remoteHost, 'https://example.com');
      expect(request.requires, '0.5.0');
      expect(request.info, {'author': 'someone'});
      expect(request.stream, false);
    });

    test('toJson converts request correctly', () {
      const request = CreateRequest(
        model: 'llama3.2',
        from: 'llama3.1',
        template: '{{ .Prompt }}',
        license: 'MIT',
        system: 'You are a helpful assistant.',
        parameters: {'temperature': 0.7},
        messages: [ChatMessage.user('Hi')],
        quantize: 'q4_K_M',
        renderer: 'qwen3.5',
        parser: 'harmony',
        files: {'model.gguf': 'sha256:abc123'},
        adapters: {'adapter.gguf': 'sha256:def456'},
        draftQuantize: 'q8_0',
        draftFiles: {'draft.gguf': 'sha256:ghi789'},
        remoteHost: 'https://example.com',
        requires: '0.5.0',
        info: {'author': 'someone'},
        stream: true,
      );

      final json = request.toJson();

      expect(json['model'], 'llama3.2');
      expect(json['from'], 'llama3.1');
      expect(json['template'], '{{ .Prompt }}');
      expect(json['license'], 'MIT');
      expect(json['system'], 'You are a helpful assistant.');
      expect(json['parameters'], {'temperature': 0.7});
      expect(json['messages'], isA<List<dynamic>>());
      expect(json['quantize'], 'q4_K_M');
      expect(json['renderer'], 'qwen3.5');
      expect(json['parser'], 'harmony');
      expect(json['files'], {'model.gguf': 'sha256:abc123'});
      expect(json['adapters'], {'adapter.gguf': 'sha256:def456'});
      expect(json['draft_quantize'], 'q8_0');
      expect(json['draft_files'], {'draft.gguf': 'sha256:ghi789'});
      expect(json['remote_host'], 'https://example.com');
      expect(json['requires'], '0.5.0');
      expect(json['info'], {'author': 'someone'});
      expect(json['stream'], true);
    });

    test('toJson of minimal request omits optional fields', () {
      const request = CreateRequest(model: 'x');

      final json = request.toJson();

      expect(json, {'model': 'x'});
    });

    test('fromJson/toJson round-trip preserves all new fields', () {
      final json = {
        'model': 'llama3.2',
        'renderer': 'qwen3.5',
        'parser': 'harmony',
        'files': {'model.gguf': 'sha256:abc123'},
        'adapters': {'adapter.gguf': 'sha256:def456'},
        'draft_quantize': 'q8_0',
        'draft_files': {'draft.gguf': 'sha256:ghi789'},
        'remote_host': 'https://example.com',
        'requires': '0.5.0',
        'info': {'author': 'someone'},
      };

      final restored = CreateRequest.fromJson(json).toJson();

      expect(restored, json);
    });

    test('copyWith works correctly', () {
      const original = CreateRequest(
        model: 'llama3.2',
        renderer: 'qwen3.5',
        files: {'model.gguf': 'sha256:abc123'},
      );

      final copied = original.copyWith(
        renderer: 'other-renderer',
        files: {'other.gguf': 'sha256:xyz'},
      );

      expect(copied.model, 'llama3.2');
      expect(copied.renderer, 'other-renderer');
      expect(copied.files, {'other.gguf': 'sha256:xyz'});

      // Omitting a param keeps the original value.
      final unchanged = original.copyWith(model: 'mistral');
      expect(unchanged.renderer, 'qwen3.5');
      expect(unchanged.files, {'model.gguf': 'sha256:abc123'});

      // Passing null explicitly clears the value.
      final cleared = original.copyWith(renderer: null, files: null);
      expect(cleared.renderer, isNull);
      expect(cleared.files, isNull);
    });

    test('equality works correctly', () {
      const request1 = CreateRequest(
        model: 'llama3.2',
        renderer: 'qwen3.5',
        files: {'model.gguf': 'sha256:abc123'},
        adapters: {'adapter.gguf': 'sha256:def456'},
        info: {
          'author': 'someone',
          'nested': {'a': 1},
        },
        messages: [ChatMessage.user('Hello')],
      );
      const request2 = CreateRequest(
        model: 'llama3.2',
        renderer: 'qwen3.5',
        files: {'model.gguf': 'sha256:abc123'},
        adapters: {'adapter.gguf': 'sha256:def456'},
        info: {
          'author': 'someone',
          'nested': {'a': 1},
        },
        messages: [ChatMessage.user('Hello')],
      );

      expect(request1, equals(request2));
      expect(request1.hashCode, equals(request2.hashCode));

      final differentRenderer = request1.copyWith(renderer: 'other');
      expect(request1, isNot(equals(differentRenderer)));

      final differentFiles = request1.copyWith(
        files: {'other.gguf': 'sha256:xyz'},
      );
      expect(request1, isNot(equals(differentFiles)));

      final differentInfo = request1.copyWith(info: {'author': 'someone-else'});
      expect(request1, isNot(equals(differentInfo)));
    });

    test('toString includes new fields', () {
      const request = CreateRequest(
        model: 'llama3.2',
        renderer: 'qwen3.5',
        parser: 'harmony',
        files: {'model.gguf': 'sha256:abc123'},
        adapters: {'adapter.gguf': 'sha256:def456'},
        draftQuantize: 'q8_0',
        draftFiles: {'draft.gguf': 'sha256:ghi789'},
        remoteHost: 'https://example.com',
        requires: '0.5.0',
        info: {'author': 'someone'},
      );

      final str = request.toString();

      expect(str, contains('renderer: qwen3.5'));
      expect(str, contains('parser: harmony'));
      expect(str, contains('files: {model.gguf: sha256:abc123}'));
      expect(str, contains('adapters: {adapter.gguf: sha256:def456}'));
      expect(str, contains('draftQuantize: q8_0'));
      expect(str, contains('draftFiles: {draft.gguf: sha256:ghi789}'));
      expect(str, contains('remoteHost: https://example.com'));
      expect(str, contains('requires: 0.5.0'));
      expect(str, contains('info: {author: someone}'));
    });
  });
}
