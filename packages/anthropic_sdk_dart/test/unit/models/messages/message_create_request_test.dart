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
