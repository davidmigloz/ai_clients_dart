import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SessionResourceConfig.fromJson', () {
    test('github_repository → GitHubRepositoryResourceConfig round-trips', () {
      final json = <String, dynamic>{
        'type': 'github_repository',
        'url': 'https://github.com/acme/repo',
        'mount_path': '/workspace/repo',
        'checkout': {'type': 'branch', 'name': 'main'},
      };

      final parsed = SessionResourceConfig.fromJson(json);
      expect(parsed, isA<GitHubRepositoryResourceConfig>());
      final config = parsed as GitHubRepositoryResourceConfig;
      expect(config.type, 'github_repository');
      expect(config.url, 'https://github.com/acme/repo');
      expect(config.mountPath, '/workspace/repo');
      // checkout reuses the existing RepositoryCheckout sealed union.
      expect(config.checkout, isA<BranchCheckout>());
      expect((config.checkout! as BranchCheckout).name, 'main');

      expect(config.toJson(), json);
    });

    test('github_repository with commit checkout and absent mount_path', () {
      final json = <String, dynamic>{
        'type': 'github_repository',
        'url': 'https://github.com/acme/repo',
        'checkout': {'type': 'commit', 'sha': 'abc123'},
      };

      final config =
          SessionResourceConfig.fromJson(json)
              as GitHubRepositoryResourceConfig;
      expect(config.mountPath, isNull);
      expect(config.checkout, isA<CommitCheckout>());
      expect((config.checkout! as CommitCheckout).sha, 'abc123');
      expect(config.toJson().containsKey('mount_path'), isFalse);
      expect(config.toJson(), json);
    });

    test('github_repository without checkout', () {
      final json = <String, dynamic>{
        'type': 'github_repository',
        'url': 'https://github.com/acme/repo',
      };

      final config =
          SessionResourceConfig.fromJson(json)
              as GitHubRepositoryResourceConfig;
      expect(config.checkout, isNull);
      expect(config.toJson().containsKey('checkout'), isFalse);
      expect(config.toJson(), json);
    });

    test('file → FileResourceConfig round-trips', () {
      final json = <String, dynamic>{
        'type': 'file',
        'file_id': 'file_abc',
        'mount_path': '/mnt/session/uploads/file_abc',
      };

      final parsed = SessionResourceConfig.fromJson(json);
      expect(parsed, isA<FileResourceConfig>());
      final config = parsed as FileResourceConfig;
      expect(config.type, 'file');
      expect(config.fileId, 'file_abc');
      expect(config.mountPath, '/mnt/session/uploads/file_abc');
      expect(config.toJson(), json);
    });

    test('file with absent mount_path omits the key', () {
      final json = <String, dynamic>{'type': 'file', 'file_id': 'file_abc'};

      final config = SessionResourceConfig.fromJson(json) as FileResourceConfig;
      expect(config.mountPath, isNull);
      expect(config.toJson().containsKey('mount_path'), isFalse);
      expect(config.toJson(), json);
    });

    test('memory_store → MemoryStoreResourceConfig round-trips', () {
      final json = <String, dynamic>{
        'type': 'memory_store',
        'memory_store_id': 'memstore_123',
        'instructions': 'Use for user preferences.',
        'access': 'read_only',
      };

      final parsed = SessionResourceConfig.fromJson(json);
      expect(parsed, isA<MemoryStoreResourceConfig>());
      final config = parsed as MemoryStoreResourceConfig;
      expect(config.type, 'memory_store');
      expect(config.memoryStoreId, 'memstore_123');
      expect(config.instructions, 'Use for user preferences.');
      // access reuses the existing MountMode enum.
      expect(config.access, MountMode.readOnly);
      expect(config.toJson(), json);
    });

    test('memory_store with read_write access and absent optionals', () {
      final json = <String, dynamic>{
        'type': 'memory_store',
        'memory_store_id': 'memstore_456',
        'access': 'read_write',
      };

      final config =
          SessionResourceConfig.fromJson(json) as MemoryStoreResourceConfig;
      expect(config.instructions, isNull);
      expect(config.access, MountMode.readWrite);
      expect(config.toJson().containsKey('instructions'), isFalse);
      expect(config.toJson(), json);
    });

    test('memory_store without access omits the key', () {
      final json = <String, dynamic>{
        'type': 'memory_store',
        'memory_store_id': 'memstore_789',
      };

      final config =
          SessionResourceConfig.fromJson(json) as MemoryStoreResourceConfig;
      expect(config.access, isNull);
      expect(config.toJson().containsKey('access'), isFalse);
      expect(config.toJson(), json);
    });

    test('unrecognized type → UnknownSessionResourceConfig fallback', () {
      final json = <String, dynamic>{
        'type': 'future_resource',
        'some_field': 'some_value',
      };

      final parsed = SessionResourceConfig.fromJson(json);
      expect(parsed, isA<UnknownSessionResourceConfig>());
      // Round-trips the raw JSON unchanged.
      expect(parsed.toJson(), json);
    });

    test('equality and hashCode', () {
      Map<String, dynamic> j() => {
        'type': 'memory_store',
        'memory_store_id': 'memstore_1',
        'instructions': 'x',
        'access': 'read_write',
      };
      final a = SessionResourceConfig.fromJson(j());
      final b = SessionResourceConfig.fromJson(j());
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith on MemoryStoreResourceConfig', () {
      final config =
          SessionResourceConfig.fromJson({
                'type': 'memory_store',
                'memory_store_id': 'memstore_1',
                'access': 'read_write',
              })
              as MemoryStoreResourceConfig;

      final updated = config.copyWith(access: MountMode.readOnly);
      expect(updated.access, MountMode.readOnly);
      expect(updated.memoryStoreId, 'memstore_1');
    });
  });

  group('DeploymentInitialEvent.fromJson (response)', () {
    test('user.message → DeploymentUserMessageEvent round-trips', () {
      final json = <String, dynamic>{
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      };

      final parsed = DeploymentInitialEvent.fromJson(json);
      expect(parsed, isA<DeploymentUserMessageEvent>());
      final event = parsed as DeploymentUserMessageEvent;
      // content is raw maps.
      expect(event.content, [
        {'type': 'text', 'text': 'hello'},
      ]);
      expect(event.toJson(), json);
    });

    test('user.define_outcome → DeploymentUserDefineOutcomeEvent '
        'round-trips with all fields', () {
      final json = <String, dynamic>{
        'type': 'user.define_outcome',
        'description': 'Produce a report.',
        'rubric': {'type': 'text', 'content': 'Grade leniently.'},
        'max_iterations': 5,
      };

      final parsed = DeploymentInitialEvent.fromJson(json);
      expect(parsed, isA<DeploymentUserDefineOutcomeEvent>());
      final event = parsed as DeploymentUserDefineOutcomeEvent;
      expect(event.description, 'Produce a report.');
      // rubric reuses the existing Rubric sealed union.
      expect(event.rubric, isA<TextRubric>());
      expect((event.rubric as TextRubric).content, 'Grade leniently.');
      expect(event.maxIterations, 5);
      expect(event.toJson(), json);
    });

    test('user.define_outcome with file rubric and absent max_iterations', () {
      final json = <String, dynamic>{
        'type': 'user.define_outcome',
        'description': 'Produce a report.',
        'rubric': {'type': 'file', 'file_id': 'file_rubric_1'},
      };

      final event =
          DeploymentInitialEvent.fromJson(json)
              as DeploymentUserDefineOutcomeEvent;
      expect(event.maxIterations, isNull);
      expect(event.rubric, isA<FileRubric>());
      expect((event.rubric as FileRubric).fileId, 'file_rubric_1');
      expect(event.toJson().containsKey('max_iterations'), isFalse);
      expect(event.toJson(), json);
    });

    test('system.message → DeploymentSystemMessageEvent round-trips', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'content': [
          {'type': 'text', 'text': 'You are a helpful assistant.'},
        ],
      };

      final parsed = DeploymentInitialEvent.fromJson(json);
      expect(parsed, isA<DeploymentSystemMessageEvent>());
      final event = parsed as DeploymentSystemMessageEvent;
      expect(event.content, [
        {'type': 'text', 'text': 'You are a helpful assistant.'},
      ]);
      expect(event.toJson(), json);
    });

    test('unrecognized type → UnknownDeploymentInitialEvent fallback', () {
      final json = <String, dynamic>{
        'type': 'future.event',
        'payload': {'k': 'v'},
      };

      final parsed = DeploymentInitialEvent.fromJson(json);
      expect(parsed, isA<UnknownDeploymentInitialEvent>());
      expect(parsed.toJson(), json);
    });

    test('equality and hashCode', () {
      Map<String, dynamic> j() => {
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hi'},
        ],
      };
      final a = DeploymentInitialEvent.fromJson(j());
      final b = DeploymentInitialEvent.fromJson(j());
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith on DeploymentUserDefineOutcomeEvent', () {
      final event =
          DeploymentInitialEvent.fromJson({
                'type': 'user.define_outcome',
                'description': 'd',
                'rubric': {'type': 'text', 'content': 'r'},
              })
              as DeploymentUserDefineOutcomeEvent;

      final updated = event.copyWith(maxIterations: 10);
      expect(updated.maxIterations, 10);
      expect(updated.description, 'd');
    });
  });

  group('DeploymentInitialEventParams (create wrapper)', () {
    test('.userMessage factory wraps UserMessageEventParams and toJson '
        'delegates', () {
      const params = UserMessageEventParams(
        content: [
          {'type': 'text', 'text': 'hello'},
        ],
      );
      const wrapped = DeploymentInitialEventParams.userMessage(params);

      expect(wrapped, isA<DeploymentUserMessageEventParams>());
      expect(
        (wrapped as DeploymentUserMessageEventParams).params,
        equals(params),
      );
      // toJson delegates to the wrapped EventParams.
      expect(wrapped.toJson(), params.toJson());
      expect(wrapped.toJson(), {
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      });
    });

    test('.userDefineOutcome factory wraps UserDefineOutcomeEventParams', () {
      const params = UserDefineOutcomeEventParams(
        description: 'Produce a report.',
        rubric: TextRubricParams(content: 'Grade leniently.'),
        maxIterations: 5,
      );
      const wrapped = DeploymentInitialEventParams.userDefineOutcome(params);

      expect(wrapped, isA<DeploymentUserDefineOutcomeEventParams>());
      expect(wrapped.toJson(), params.toJson());
      expect(wrapped.toJson()['type'], 'user.define_outcome');
    });

    test('.systemMessage factory wraps SystemMessageEventParams', () {
      const params = SystemMessageEventParams(
        content: [
          {'type': 'text', 'text': 'You are helpful.'},
        ],
      );
      const wrapped = DeploymentInitialEventParams.systemMessage(params);

      expect(wrapped, isA<DeploymentSystemMessageEventParams>());
      expect(wrapped.toJson(), params.toJson());
      expect(wrapped.toJson()['type'], 'system.message');
    });

    test('fromJson dispatches user.message to the right wrapper and '
        'round-trips', () {
      final json = <String, dynamic>{
        'type': 'user.message',
        'content': [
          {'type': 'text', 'text': 'hello'},
        ],
      };

      final parsed = DeploymentInitialEventParams.fromJson(json);
      expect(parsed, isA<DeploymentUserMessageEventParams>());
      expect(parsed.toJson(), json);
    });

    test('fromJson dispatches user.define_outcome to the right wrapper', () {
      final json = <String, dynamic>{
        'type': 'user.define_outcome',
        'description': 'd',
        'rubric': {'type': 'text', 'content': 'r'},
        'max_iterations': 3,
      };

      final parsed = DeploymentInitialEventParams.fromJson(json);
      expect(parsed, isA<DeploymentUserDefineOutcomeEventParams>());
      expect(parsed.toJson(), json);
    });

    test('fromJson dispatches system.message to the right wrapper', () {
      final json = <String, dynamic>{
        'type': 'system.message',
        'content': [
          {'type': 'text', 'text': 'sys'},
        ],
      };

      final parsed = DeploymentInitialEventParams.fromJson(json);
      expect(parsed, isA<DeploymentSystemMessageEventParams>());
      expect(parsed.toJson(), json);
    });

    test(
      'unrecognized type → UnknownDeploymentInitialEventParams fallback',
      () {
        final json = <String, dynamic>{
          'type': 'user.interrupt',
          'session_thread_id': 'thread_1',
        };

        final parsed = DeploymentInitialEventParams.fromJson(json);
        expect(parsed, isA<UnknownDeploymentInitialEventParams>());
        // Round-trips the raw JSON unchanged.
        expect(parsed.toJson(), json);
      },
    );

    test('equality and hashCode', () {
      const a = DeploymentInitialEventParams.userMessage(
        UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'hi'},
          ],
        ),
      );
      const b = DeploymentInitialEventParams.userMessage(
        UserMessageEventParams(
          content: [
            {'type': 'text', 'text': 'hi'},
          ],
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
