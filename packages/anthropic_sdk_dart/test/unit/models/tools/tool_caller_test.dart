import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ToolCaller', () {
    test('parses direct caller', () {
      final caller = ToolCaller.fromJson({'type': 'direct'});

      expect(caller, isA<DirectToolCaller>());
      expect(caller.toJson(), {'type': 'direct'});
    });

    test('parses server caller', () {
      final caller = ToolCaller.fromJson({
        'type': 'code_execution_20260120',
        'tool_id': 'srvtoolu_123',
      });

      expect(caller, isA<ServerToolCaller>());
      final server = caller as ServerToolCaller;
      expect(server.type, 'code_execution_20260120');
      expect(server.toolId, 'srvtoolu_123');
      expect(server.toJson(), {
        'type': 'code_execution_20260120',
        'tool_id': 'srvtoolu_123',
      });
    });
  });
}
