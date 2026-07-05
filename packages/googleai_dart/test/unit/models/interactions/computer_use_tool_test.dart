import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ComputerUseTool', () {
    test('serializes enable_prompt_injection_detection and round-trips', () {
      const tool = ComputerUseTool(
        environment: 'browser',
        excludedPredefinedFunctions: ['open_web_browser'],
        enablePromptInjectionDetection: true,
      );

      final json = tool.toJson();
      expect(json['type'], 'computer_use');
      expect(json['environment'], 'browser');
      expect(json['excluded_predefined_functions'], ['open_web_browser']);
      expect(json['enable_prompt_injection_detection'], true);

      final restored = InteractionTool.fromJson(json) as ComputerUseTool;
      expect(restored.enablePromptInjectionDetection, true);
      expect(restored.environment, 'browser');
      expect(restored.excludedPredefinedFunctions, ['open_web_browser']);
    });

    test('omits enable_prompt_injection_detection when null', () {
      const tool = ComputerUseTool(environment: 'browser');
      expect(
        tool.toJson().containsKey('enable_prompt_injection_detection'),
        isFalse,
      );
    });
  });
}
