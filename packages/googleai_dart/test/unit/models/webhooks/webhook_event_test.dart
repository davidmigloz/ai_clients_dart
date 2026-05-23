import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('WebhookEvent dispatch', () {
    test('all 7 known event types dispatch through fromJson', () {
      final cases = <Map<String, dynamic>, Type>{
        {
          'type': 'batch.succeeded',
          'data': {'id': 'b1', 'output_file_uri': 'gs://b/out'},
        }: WebhookBatchSucceededEvent,
        {
          'type': 'batch.expired',
          'data': {'id': 'b1'},
        }: WebhookBatchExpiredEvent,
        {
          'type': 'batch.failed',
          'data': {'id': 'b1', 'error_code': 'TIMEOUT'},
        }: WebhookBatchFailedEvent,
        {
          'type': 'interaction.requires_action',
          'data': {'id': 'i1'},
        }: WebhookInteractionRequiresActionEvent,
        {
          'type': 'interaction.completed',
          'data': {'id': 'i1'},
        }: WebhookInteractionCompletedEvent,
        {
          'type': 'interaction.failed',
          'data': {'id': 'i1', 'error_message': 'oops'},
        }: WebhookInteractionFailedEvent,
        {
          'type': 'video.generated',
          'data': {'id': 'v1', 'output_file_uri': 'gs://b/v.mp4'},
        }: WebhookVideoGeneratedEvent,
      };
      for (final entry in cases.entries) {
        final event = WebhookEvent.fromJson(entry.key);
        expect(event.runtimeType, entry.value);
      }
    });

    test('throws ArgumentError on unknown type', () {
      expect(
        () => WebhookEvent.fromJson({
          'type': 'unknown.event',
          'data': {'id': 'x'},
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws FormatException when data.id missing', () {
      expect(
        () => WebhookEvent.fromJson({
          'type': 'batch.succeeded',
          'data': <String, dynamic>{},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when data missing entirely', () {
      expect(
        () => WebhookEvent.fromJson({'type': 'batch.expired'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('WebhookEvent envelope + roundtrip', () {
    test('preserves type, version, timestamp, and nested data', () {
      final json = {
        'type': 'video.generated',
        'version': 'v1',
        'timestamp': '2025-12-04T15:01:45Z',
        'data': {
          'id': 'v-1',
          'output_file_uri': 'gs://bucket/video.mp4',
          'file_name': 'video.mp4',
        },
      };
      final event = WebhookEvent.fromJson(json) as WebhookVideoGeneratedEvent;
      expect(event.type, 'video.generated');
      expect(event.version, 'v1');
      expect(event.timestamp, DateTime.parse('2025-12-04T15:01:45Z'));
      expect(event.id, 'v-1');
      expect(event.outputFileUri, 'gs://bucket/video.mp4');
      expect(event.fileName, 'video.mp4');

      final restored =
          WebhookEvent.fromJson(event.toJson()) as WebhookVideoGeneratedEvent;
      expect(restored.id, event.id);
      expect(restored.outputFileUri, event.outputFileUri);
      expect(restored.fileName, event.fileName);
      expect(restored.version, event.version);
      expect(restored.timestamp, event.timestamp);
    });

    test('toJson re-nests fields under `data`', () {
      const event = WebhookBatchFailedEvent(
        id: 'b1',
        errorCode: 'TIMEOUT',
        errorMessage: 'took too long',
      );
      final json = event.toJson();
      expect(json['type'], 'batch.failed');
      expect(json['data'], isA<Map<String, dynamic>>());
      final data = json['data'] as Map<String, dynamic>;
      expect(data['id'], 'b1');
      expect(data['error_code'], 'TIMEOUT');
      expect(data['error_message'], 'took too long');
    });

    test('mismatched discriminator on variant fromJson throws', () {
      expect(
        () => WebhookBatchSucceededEvent.fromJson({
          'type': 'batch.failed',
          'data': {'id': 'x'},
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
