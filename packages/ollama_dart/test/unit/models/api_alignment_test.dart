import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

import 'native_fields_test.dart' show optionalContracts;

void main() {
  optionalContracts<ToolDefinition>(
    'Native tool item schema',
    fromJson: ToolDefinition.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(items: null),
    base: const {
      'type': 'function',
      'function': {'name': 'f', 'parameters': <String, dynamic>{}},
    },
    fields: const {
      'items': {
        'type': ['string', 'null'],
        'nested': [
          {
            'enum': ['a', 'b'],
          },
        ],
      },
    },
  );
  optionalContracts<GenerateRequest>(
    'GenerateRequest runner',
    fromJson: GenerateRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const {'model': 'm'},
    fields: const {'runner': 'mlx'},
  );
  optionalContracts<ChatRequest>(
    'ChatRequest runner',
    fromJson: ChatRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const {'model': 'm', 'messages': <dynamic>[]},
    fields: const {'runner': 'mlx'},
  );
  optionalContracts<ShowRequest>(
    'ShowRequest runner',
    fromJson: ShowRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const {'model': 'm'},
    fields: const {'runner': 'mlx'},
  );
  optionalContracts<PullRequest>(
    'PullRequest runner',
    fromJson: PullRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const {'model': 'm'},
    fields: const {'runner': 'mlx'},
  );
  optionalContracts<RunningModel>(
    'RunningModel runner',
    fromJson: RunningModel.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const <String, dynamic>{},
    fields: const {'runner': 'mlx'},
  );
  optionalContracts<ModelDetails>(
    'ModelDetails runner',
    fromJson: ModelDetails.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(runner: null),
    base: const <String, dynamic>{},
    fields: const {'runner': 'mlx'},
  );

  optionalContracts<CreateRequest>(
    'CreateRequest manifest list and capabilities',
    fromJson: CreateRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(capabilities: null, list: null),
    base: const {'model': 'multi'},
    fields: const {
      'capabilities': ['speech', 'vision'],
      'list': ['model:mlx', 'model:gguf'],
    },
  );
  optionalContracts<ShowResponse>(
    'ShowResponse effective template, voices and manifest variants',
    fromJson: ShowResponse.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) =>
        value.copyWith(templateSource: null, voices: null, manifests: null),
    fields: const {
      'template_source': 'gguf_chat_template',
      'voices': ['Hugh'],
      'manifests': [
        {
          'digest': 'sha256:abc',
          'runner': 'mlx',
          'format': 'safetensors',
          'selected': false,
        },
      ],
    },
  );
  optionalContracts<ShowRequest>(
    'ShowRequest all manifests control',
    fromJson: ShowRequest.fromJson,
    toJson: (value) => value.toJson(),
    copy: (value) => value.copyWith(),
    clear: (value) => value.copyWith(allManifests: null),
    base: const {'model': 'multi'},
    fields: const {'all_manifests': false},
  );
  test('new constructors expose every model selection and speech field', () {
    expect(const GenerateRequest(model: 'm', runner: 'mlx').runner, 'mlx');
    expect(
      const ChatRequest(model: 'm', messages: [], runner: 'mlx').runner,
      'mlx',
    );
    expect(const PullRequest(model: 'm', runner: 'mlx').runner, 'mlx');
    expect(
      const ShowRequest(
        model: 'm',
        runner: 'mlx',
        allManifests: true,
      ).allManifests,
      isTrue,
    );
    expect(const ModelDetails(runner: 'mlx').runner, 'mlx');
    expect(const RunningModel(runner: 'mlx').runner, 'mlx');
    expect(
      const CreateRequest(
        model: 'm',
        capabilities: ['speech'],
        list: ['m:mlx'],
      ).toJson(),
      {
        'model': 'm',
        'capabilities': ['speech'],
        'list': ['m:mlx'],
      },
    );
    expect(
      const ShowResponse(
        voices: ['Hugh'],
        templateSource: 'none',
        manifests: [],
      ).toJson(),
      {
        'voices': ['Hugh'],
        'template_source': 'none',
        'manifests': <dynamic>[],
      },
    );
  });
  test(
    'native tool item schemas freeze nested JSON when decoded or replaced',
    () {
      final raw = <String, dynamic>{
        'enum': ['a', 'b'],
      };
      final tool = ToolDefinition.fromJson({
        'type': 'function',
        'function': const {'name': 'f'},
        'items': raw,
      });
      (raw['enum'] as List).clear();
      expect(tool.items, {
        'enum': ['a', 'b'],
      });
      final items = tool.items! as Map<String, dynamic>;
      expect(() => (items['enum'] as List).clear(), throwsUnsupportedError);
      final replaced = tool.copyWith(items: raw);
      (raw['enum'] as List).add('c');
      expect(replaced.items, {'enum': <dynamic>[]});
    },
  );
  test('pull requests compare all public options', () {
    const plain = PullRequest(model: 'm');
    expect(plain, isNot(plain.copyWith(insecure: true)));
    expect(plain, isNot(plain.copyWith(stream: false)));
    expect(plain.toString(), contains('insecure: null'));
  });
  test('all manifest inspection preserves flattened variant details', () {
    final json = <String, dynamic>{
      'license': 'MIT',
      'manifests': [
        {
          'runner': 'mlx',
          'capabilities': ['speech'],
          'voices': ['Hugh'],
          'model_info': {
            'nested': [1, 2],
          },
        },
        {'runner': 'llama', 'template_source': 'gguf_chat_template'},
      ],
    };
    final value = ShowManifestsResponse.fromJson(json);
    expect(value.manifests.first.runner, 'mlx');
    expect(value.manifests.first.details.voices, ['Hugh']);
    expect(value.toJson(), json);
    expect(value, ShowManifestsResponse.fromJson(json));
    expect(value.hashCode, ShowManifestsResponse.fromJson(json).hashCode);
    expect(value.copyWith(), value);
    expect(value.copyWith(license: null).license, isNull);
    expect(value.manifests.first.copyWith(runner: null).runner, isNull);
    expect(
      value.manifests.first.copyWith(details: const ShowResponse()),
      isNot(value.manifests.first),
    );
    expect(value.manifests.first.copyWith(), value.manifests.first);
    expect(value.manifests.clear, throwsUnsupportedError);
    expect(
      () => ShowManifestsResponse.fromJson(const {}),
      throwsFormatException,
    );
    expect(
      () => ShowManifestsResponse.fromJson(const {
        'manifests': [3],
      }),
      throwsFormatException,
    );
  });
  test('new collection fields are frozen when decoded and replaced', () {
    final voices = ['Hugh'];
    final value = ShowResponse.fromJson({
      'voices': voices,
      'manifests': const <dynamic>[],
    });
    voices.clear();
    expect(value.voices, ['Hugh']);
    expect(() => value.voices!.clear(), throwsUnsupportedError);
    final replaced = value.copyWith(voices: voices);
    voices.add('Jane');
    expect(replaced.voices, isEmpty);
    final created = CreateRequest.fromJson(const {
      'model': 'm',
      'list': ['a'],
      'capabilities': ['speech'],
    });
    expect(() => created.list!.clear(), throwsUnsupportedError);
    expect(() => created.capabilities!.clear(), throwsUnsupportedError);
  });
}
