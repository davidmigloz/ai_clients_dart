import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

MessageCreateRequest buildRequest({ContainerParam? container}) =>
    MessageCreateRequest(
      model: 'claude-sonnet-5',
      maxTokens: 1024,
      messages: [InputMessage.user('Hello')],
      container: container,
    );

void main() {
  group('FileDocumentSource', () {
    test('round-trips a complete message request with cache control', () {
      final request = MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 1024,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.document(
              DocumentSource.file('file_123'),
              cacheControl: const CacheControlEphemeral(ttl: CacheTtl.ttl1h),
            ),
          ]),
        ],
      );
      final json = request.toJson();
      expect(json['messages'], [
        {
          'role': 'user',
          'content': [
            {
              'type': 'document',
              'source': {'type': 'file', 'file_id': 'file_123'},
              'cache_control': {'type': 'ephemeral', 'ttl': '1h'},
            },
          ],
        },
      ]);
      expect(MessageCreateRequest.fromJson(json).toJson(), json);
    });

    test('supports value semantics and rejects invalid sources', () {
      const source = FileDocumentSource('file_123');
      expect(DocumentSource.fromJson(source.toJson()), source);
      expect(source.copyWith(), source);
      expect(
        source.copyWith(fileId: 'file_456'),
        const FileDocumentSource('file_456'),
      );
      expect(source.hashCode, const FileDocumentSource('file_123').hashCode);
      expect(
        () => DocumentSource.fromJson({'type': 'file'}),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => DocumentSource.fromJson({'type': 'unknown'}),
        throwsFormatException,
      );
    });
  });

  group('MessageCreateRequest.container', () {
    test('round-trips a plain string container id', () {
      final request = buildRequest(
        container: ContainerParam.id('container_123'),
      );
      final json = request.toJson();

      expect(json['container'], 'container_123');

      final parsed = MessageCreateRequest.fromJson(json);
      expect(parsed.container, isA<ContainerParamId>());
      expect((parsed.container! as ContainerParamId).id, 'container_123');
    });

    test('round-trips a ContainerParams object with skills', () {
      final request = buildRequest(
        container: ContainerParam.config(
          const ContainerParams(
            skills: [
              ContainerSkillParams(
                type: ContainerSkillType.anthropic,
                skillId: 'pdf',
                version: 'latest',
              ),
            ],
          ),
        ),
      );
      final json = request.toJson();

      expect(json['container'], {
        'skills': [
          {'type': 'anthropic', 'skill_id': 'pdf', 'version': 'latest'},
        ],
      });

      final parsed = MessageCreateRequest.fromJson(json);
      expect(parsed.container, isA<ContainerParamConfig>());
      final config = parsed.container! as ContainerParamConfig;
      expect(config.params.skills, hasLength(1));
    });

    test('omits container when absent', () {
      final json = buildRequest().toJson();
      expect(json.containsKey('container'), isFalse);
    });
  });
}
