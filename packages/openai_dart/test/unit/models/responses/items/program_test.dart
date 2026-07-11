import 'package:openai_dart/src/models/responses/config/program_output_status.dart';
import 'package:openai_dart/src/models/responses/items/item.dart';
import 'package:openai_dart/src/models/responses/items/output_item.dart';
import 'package:test/test.dart';

void main() {
  group('ProgramItem', () {
    test('round-trips through JSON', () {
      const item = ProgramItem(
        id: 'cm_123',
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );

      final json = item.toJson();
      expect(json, {
        'type': 'program',
        'id': 'cm_123',
        'call_id': 'call_1',
        'code': 'return 1 + 1;',
        'fingerprint': 'fp_1',
      });

      expect(Item.fromJson(json), item);
    });

    test('dispatches via Item.fromJson', () {
      final item = Item.fromJson({
        'type': 'program',
        'id': 'cm_1',
        'call_id': 'call_1',
        'code': 'code',
        'fingerprint': 'fp',
      });
      expect(item, isA<ProgramItem>());
    });

    test('supports equality/hashCode', () {
      const a = ProgramItem(
        id: 'cm_1',
        callId: 'call_1',
        code: 'code',
        fingerprint: 'fp',
      );
      const b = ProgramItem(
        id: 'cm_1',
        callId: 'call_1',
        code: 'code',
        fingerprint: 'fp',
      );
      const c = ProgramItem(
        id: 'cm_2',
        callId: 'call_1',
        code: 'code',
        fingerprint: 'fp',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('ProgramOutputItem', () {
    test('round-trips through JSON', () {
      const item = ProgramOutputItem(
        id: 'cmo_123',
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );

      final json = item.toJson();
      expect(json, {
        'type': 'program_output',
        'id': 'cmo_123',
        'call_id': 'call_1',
        'result': '2',
        'status': 'completed',
      });

      expect(Item.fromJson(json), item);
    });

    test('dispatches via Item.fromJson', () {
      final item = Item.fromJson({
        'type': 'program_output',
        'id': 'cmo_1',
        'call_id': 'call_1',
        'result': '2',
        'status': 'incomplete',
      });
      expect(item, isA<ProgramOutputItem>());
      expect(
        (item as ProgramOutputItem).status,
        ProgramOutputStatus.incomplete,
      );
    });

    test('supports equality/hashCode', () {
      const a = ProgramOutputItem(
        id: 'cmo_1',
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );
      const b = ProgramOutputItem(
        id: 'cmo_1',
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );
      const c = ProgramOutputItem(
        id: 'cmo_1',
        callId: 'call_1',
        result: '3',
        status: ProgramOutputStatus.completed,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('ProgramOutputItemResponse', () {
    test('round-trips through JSON', () {
      const item = ProgramOutputItemResponse(
        id: 'cm_123',
        callId: 'call_1',
        code: 'return 1 + 1;',
        fingerprint: 'fp_1',
      );

      final json = item.toJson();
      expect(json, {
        'type': 'program',
        'id': 'cm_123',
        'call_id': 'call_1',
        'code': 'return 1 + 1;',
        'fingerprint': 'fp_1',
      });

      expect(OutputItem.fromJson(json), item);
    });

    test('dispatches via OutputItem.fromJson', () {
      final item = OutputItem.fromJson({
        'type': 'program',
        'id': 'cm_1',
        'call_id': 'call_1',
        'code': 'code',
        'fingerprint': 'fp',
      });
      expect(item, isA<ProgramOutputItemResponse>());
    });
  });

  group('ProgramOutputResultItem', () {
    test('round-trips through JSON', () {
      const item = ProgramOutputResultItem(
        id: 'cmo_123',
        callId: 'call_1',
        result: '2',
        status: ProgramOutputStatus.completed,
      );

      final json = item.toJson();
      expect(json, {
        'type': 'program_output',
        'id': 'cmo_123',
        'call_id': 'call_1',
        'result': '2',
        'status': 'completed',
      });

      expect(OutputItem.fromJson(json), item);
    });

    test('dispatches via OutputItem.fromJson', () {
      final item = OutputItem.fromJson({
        'type': 'program_output',
        'id': 'cmo_1',
        'call_id': 'call_1',
        'result': '2',
        'status': 'completed',
      });
      expect(item, isA<ProgramOutputResultItem>());
    });
  });

  group('ProgramOutputStatus', () {
    test('round-trips known values', () {
      expect(
        ProgramOutputStatus.fromJson('completed'),
        ProgramOutputStatus.completed,
      );
      expect(
        ProgramOutputStatus.fromJson('incomplete'),
        ProgramOutputStatus.incomplete,
      );
      expect(ProgramOutputStatus.completed.toJson(), 'completed');
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        ProgramOutputStatus.fromJson('bogus'),
        ProgramOutputStatus.unknown,
      );
    });
  });
}
