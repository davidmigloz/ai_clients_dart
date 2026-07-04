import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('SpanModelUsage.speed', () {
    Map<String, dynamic> usageJson({String? speed}) => {
      'input_tokens': 10,
      'output_tokens': 20,
      'cache_creation_input_tokens': 0,
      'cache_read_input_tokens': 5,
      'speed': ?speed,
    };

    test('parses speed as a typed AgentSpeed and round-trips', () {
      final usage = SpanModelUsage.fromJson(usageJson(speed: 'fast'));
      expect(usage.speed, AgentSpeed.fast);
      expect(usage.toJson()['speed'], 'fast');
      expect(usage.toJson(), usageJson(speed: 'fast'));
    });

    test('falls back to AgentSpeed.unknown for an unrecognized value', () {
      final usage = SpanModelUsage.fromJson(usageJson(speed: 'turbo'));
      expect(usage.speed, AgentSpeed.unknown);
    });

    test('omits speed when absent', () {
      final usage = SpanModelUsage.fromJson(usageJson());
      expect(usage.speed, isNull);
      expect(usage.toJson().containsKey('speed'), isFalse);
    });
  });
}
