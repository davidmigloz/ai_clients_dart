import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _fixturesJson = r'''
{
  "PublicCreateEndpointBody": {
    "name": "receiver",
    "url": "https://",
    "event_types": [
      "batch.completed",
      "batch.failed",
      "batch.expired",
      "batch.cancelled",
      "response.completed",
      "response.failed",
      "response.cancelled",
      "response.incomplete",
      "eval.run.succeeded",
      "eval.run.failed",
      "eval.run.canceled",
      "fine_tuning.job.succeeded",
      "fine_tuning.job.failed",
      "fine_tuning.job.cancelled",
      "realtime.call.incoming",
      "video.completed",
      "video.failed",
      "agent.session.created",
      "agent.session.action_required",
      "agent.session.in_progress",
      "agent.session.idle",
      "agent.session.failed",
      "safety.alert.created"
    ]
  },
  "PublicUpdateEndpointBody": {},
  "PublicRotateSecretBody": {},
  "PublicTestEndpointBody": {
    "event_type": "video.completed"
  },
  "WebhookEndpointBody": {
    "id": "opaque id",
    "object": "webhook_endpoint",
    "created_at": -7,
    "name": "",
    "url": "receive-only-any-text",
    "event_types": [
      "future.project.event"
    ],
    "signing_secret_hint": null
  },
  "WebhookEndpointWithSecretResource": {
    "id": "opaque id",
    "object": "webhook_endpoint",
    "created_at": -7,
    "name": "",
    "url": "receive-only-any-text",
    "event_types": [
      "future.project.event"
    ],
    "signing_secret_hint": null,
    "signing_secret": "raw-test-only-key"
  },
  "WebhookEndpointListResource": {
    "object": "list",
    "data": [],
    "first_id": null,
    "last_id": null,
    "has_more": true
  },
  "DeletedWebhookEndpointResource": {
    "id": "opaque id",
    "object": "webhook_endpoint.deleted",
    "deleted": false
  },
  "WebhookEndpointTestResultResource": {
    "object": "webhook_endpoint.test",
    "webhook_endpoint_id": "opaque id",
    "event_type": "future.project.event",
    "status_code": 500,
    "success": true
  },
  "WebhookEventTypeListResource": {
    "object": "list",
    "data": [
      "future.project.event",
      "video.completed"
    ]
  }
}
''';

Map<String, dynamic> _fixture(String schema) => Map<String, dynamic>.from(
  (jsonDecode(_fixturesJson) as Map<String, dynamic>)[schema]
      as Map<String, dynamic>,
);

class _ModelAdapter {
  const _ModelAdapter(this.parse, this.json, this.copy, this.describe);
  final Object Function(Map<String, dynamic>) parse;
  final Map<String, dynamic> Function(Object) json;
  final Object Function(Object) copy;
  final String Function(Object) describe;
}

final _adapters = <String, _ModelAdapter>{
  'PublicCreateEndpointBody': _ModelAdapter(
    WebhookEndpointCreateRequest.fromJson,
    (value) => (value as WebhookEndpointCreateRequest).toJson(),
    (value) => (value as WebhookEndpointCreateRequest).copyWith(),
    (value) => (value as WebhookEndpointCreateRequest).toString(),
  ),
  'PublicUpdateEndpointBody': _ModelAdapter(
    WebhookEndpointUpdateRequest.fromJson,
    (value) => (value as WebhookEndpointUpdateRequest).toJson(),
    (value) => (value as WebhookEndpointUpdateRequest).copyWith(),
    (value) => (value as WebhookEndpointUpdateRequest).toString(),
  ),
  'PublicRotateSecretBody': _ModelAdapter(
    WebhookEndpointRotateSecretRequest.fromJson,
    (value) => (value as WebhookEndpointRotateSecretRequest).toJson(),
    (value) => (value as WebhookEndpointRotateSecretRequest).copyWith(),
    (value) => (value as WebhookEndpointRotateSecretRequest).toString(),
  ),
  'PublicTestEndpointBody': _ModelAdapter(
    WebhookEndpointTestRequest.fromJson,
    (value) => (value as WebhookEndpointTestRequest).toJson(),
    (value) => (value as WebhookEndpointTestRequest).copyWith(),
    (value) => (value as WebhookEndpointTestRequest).toString(),
  ),
  'WebhookEndpointBody': _ModelAdapter(
    WebhookEndpoint.fromJson,
    (value) => (value as WebhookEndpoint).toJson(),
    (value) => (value as WebhookEndpoint).copyWith(),
    (value) => (value as WebhookEndpoint).toString(),
  ),
  'WebhookEndpointWithSecretResource': _ModelAdapter(
    WebhookEndpointWithSecret.fromJson,
    (value) => (value as WebhookEndpointWithSecret).toJson(),
    (value) => (value as WebhookEndpointWithSecret).copyWith(),
    (value) => (value as WebhookEndpointWithSecret).toString(),
  ),
  'WebhookEndpointListResource': _ModelAdapter(
    WebhookEndpointList.fromJson,
    (value) => (value as WebhookEndpointList).toJson(),
    (value) => (value as WebhookEndpointList).copyWith(),
    (value) => (value as WebhookEndpointList).toString(),
  ),
  'DeletedWebhookEndpointResource': _ModelAdapter(
    DeletedWebhookEndpoint.fromJson,
    (value) => (value as DeletedWebhookEndpoint).toJson(),
    (value) => (value as DeletedWebhookEndpoint).copyWith(),
    (value) => (value as DeletedWebhookEndpoint).toString(),
  ),
  'WebhookEndpointTestResultResource': _ModelAdapter(
    WebhookEndpointTestResult.fromJson,
    (value) => (value as WebhookEndpointTestResult).toJson(),
    (value) => (value as WebhookEndpointTestResult).copyWith(),
    (value) => (value as WebhookEndpointTestResult).toString(),
  ),
  'WebhookEventTypeListResource': _ModelAdapter(
    WebhookEventTypeList.fromJson,
    (value) => (value as WebhookEventTypeList).toJson(),
    (value) => (value as WebhookEventTypeList).copyWith(),
    (value) => (value as WebhookEventTypeList).toString(),
  ),
};

void main() {
  group('canonical management components through the public barrel', () {
    group('WebhookEndpointCreateRequest', () {
      final adapter = _adapters['PublicCreateEndpointBody']!;
      Map<String, dynamic> fixture() => _fixture('PublicCreateEndpointBody');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required name rejects absence', () {
        final json = fixture()..remove('name');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects explicit null', () {
        final json = fixture()..['name'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects wrong wire value without exposing it', () {
        final json = fixture()..['name'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required url rejects absence', () {
        final json = fixture()..remove('url');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects explicit null', () {
        final json = fixture()..['url'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects wrong wire value without exposing it', () {
        final json = fixture()..['url'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required event_types rejects absence', () {
        final json = fixture()..remove('event_types');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects explicit null', () {
        final json = fixture()..['event_types'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_types'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('event_types validates each array element', () {
        final json = fixture()..['event_types'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
    });
    group('WebhookEndpointUpdateRequest', () {
      final adapter = _adapters['PublicUpdateEndpointBody']!;
      Map<String, dynamic> fixture() => _fixture('PublicUpdateEndpointBody');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('name rejects explicit null', () {
        final json = fixture()..['name'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects wrong wire value without exposing it', () {
        final json = fixture()..['name'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('optional name can remain absent', () {
        final json = fixture()..remove('name');
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('url rejects explicit null', () {
        final json = fixture()..['url'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects wrong wire value without exposing it', () {
        final json = fixture()..['url'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('optional url can remain absent', () {
        final json = fixture()..remove('url');
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('event_types rejects explicit null', () {
        final json = fixture()..['event_types'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_types'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('event_types validates each array element', () {
        final json = fixture()..['event_types'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('optional event_types can remain absent', () {
        final json = fixture()..remove('event_types');
        expect(adapter.json(adapter.parse(json)), json);
      });
    });
    group('WebhookEndpointRotateSecretRequest', () {
      final adapter = _adapters['PublicRotateSecretBody']!;
      Map<String, dynamic> fixture() => _fixture('PublicRotateSecretBody');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('keep_old_secret_active_for_24_hours rejects explicit null', () {
        final json = fixture()..['keep_old_secret_active_for_24_hours'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test(
        'keep_old_secret_active_for_24_hours rejects wrong wire value without exposing it',
        () {
          final json = fixture()
            ..['keep_old_secret_active_for_24_hours'] = 'opaque_secret_marker';
          try {
            adapter.parse(json);
            fail('Expected contextual FormatException');
          } on FormatException catch (error) {
            expect(error.source, isNull);
            expect(error.offset, isNull);
            expect(error.toString(), isNot(contains('opaque_secret_marker')));
          }
        },
      );
      test(
        'optional keep_old_secret_active_for_24_hours can remain absent',
        () {
          final json = fixture()..remove('keep_old_secret_active_for_24_hours');
          expect(adapter.json(adapter.parse(json)), json);
        },
      );
    });
    group('WebhookEndpointTestRequest', () {
      final adapter = _adapters['PublicTestEndpointBody']!;
      Map<String, dynamic> fixture() => _fixture('PublicTestEndpointBody');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required event_type rejects absence', () {
        final json = fixture()..remove('event_type');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_type rejects explicit null', () {
        final json = fixture()..['event_type'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_type rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_type'] = 'future.unknown.event';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
    });
    group('WebhookEndpoint', () {
      final adapter = _adapters['WebhookEndpointBody']!;
      Map<String, dynamic> fixture() => _fixture('WebhookEndpointBody');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required id rejects absence', () {
        final json = fixture()..remove('id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects explicit null', () {
        final json = fixture()..['id'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects wrong wire value without exposing it', () {
        final json = fixture()..['id'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required created_at rejects absence', () {
        final json = fixture()..remove('created_at');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('created_at rejects explicit null', () {
        final json = fixture()..['created_at'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('created_at rejects wrong wire value without exposing it', () {
        final json = fixture()..['created_at'] = 1.5;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('updated_at rejects explicit null', () {
        final json = fixture()..['updated_at'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('updated_at rejects wrong wire value without exposing it', () {
        final json = fixture()..['updated_at'] = 1.5;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('optional updated_at can remain absent', () {
        final json = fixture()..remove('updated_at');
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('required name rejects absence', () {
        final json = fixture()..remove('name');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects explicit null', () {
        final json = fixture()..['name'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects wrong wire value without exposing it', () {
        final json = fixture()..['name'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required url rejects absence', () {
        final json = fixture()..remove('url');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects explicit null', () {
        final json = fixture()..['url'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects wrong wire value without exposing it', () {
        final json = fixture()..['url'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required event_types rejects absence', () {
        final json = fixture()..remove('event_types');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects explicit null', () {
        final json = fixture()..['event_types'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_types'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('event_types validates each array element', () {
        final json = fixture()..['event_types'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('required signing_secret_hint rejects absence', () {
        final json = fixture()..remove('signing_secret_hint');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('signing_secret_hint accepts and emits required explicit null', () {
        final json = fixture()..['signing_secret_hint'] = null;
        expect(adapter.json(adapter.parse(json)), json);
      });
      test(
        'signing_secret_hint rejects wrong wire value without exposing it',
        () {
          final json = fixture()..['signing_secret_hint'] = false;
          try {
            adapter.parse(json);
            fail('Expected contextual FormatException');
          } on FormatException catch (error) {
            expect(error.source, isNull);
            expect(error.offset, isNull);
            expect(error.toString(), isNot(contains('opaque_secret_marker')));
          }
        },
      );
    });
    group('WebhookEndpointWithSecret', () {
      final adapter = _adapters['WebhookEndpointWithSecretResource']!;
      Map<String, dynamic> fixture() =>
          _fixture('WebhookEndpointWithSecretResource');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required id rejects absence', () {
        final json = fixture()..remove('id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects explicit null', () {
        final json = fixture()..['id'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects wrong wire value without exposing it', () {
        final json = fixture()..['id'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required created_at rejects absence', () {
        final json = fixture()..remove('created_at');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('created_at rejects explicit null', () {
        final json = fixture()..['created_at'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('created_at rejects wrong wire value without exposing it', () {
        final json = fixture()..['created_at'] = 1.5;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('updated_at rejects explicit null', () {
        final json = fixture()..['updated_at'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('updated_at rejects wrong wire value without exposing it', () {
        final json = fixture()..['updated_at'] = 1.5;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('optional updated_at can remain absent', () {
        final json = fixture()..remove('updated_at');
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('required name rejects absence', () {
        final json = fixture()..remove('name');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects explicit null', () {
        final json = fixture()..['name'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('name rejects wrong wire value without exposing it', () {
        final json = fixture()..['name'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required url rejects absence', () {
        final json = fixture()..remove('url');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects explicit null', () {
        final json = fixture()..['url'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('url rejects wrong wire value without exposing it', () {
        final json = fixture()..['url'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required event_types rejects absence', () {
        final json = fixture()..remove('event_types');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects explicit null', () {
        final json = fixture()..['event_types'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_types rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_types'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('event_types validates each array element', () {
        final json = fixture()..['event_types'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('required signing_secret_hint rejects absence', () {
        final json = fixture()..remove('signing_secret_hint');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('signing_secret_hint accepts and emits required explicit null', () {
        final json = fixture()..['signing_secret_hint'] = null;
        expect(adapter.json(adapter.parse(json)), json);
      });
      test(
        'signing_secret_hint rejects wrong wire value without exposing it',
        () {
          final json = fixture()..['signing_secret_hint'] = false;
          try {
            adapter.parse(json);
            fail('Expected contextual FormatException');
          } on FormatException catch (error) {
            expect(error.source, isNull);
            expect(error.offset, isNull);
            expect(error.toString(), isNot(contains('opaque_secret_marker')));
          }
        },
      );
      test('required signing_secret rejects absence', () {
        final json = fixture()..remove('signing_secret');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('signing_secret rejects explicit null', () {
        final json = fixture()..['signing_secret'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('signing_secret rejects wrong wire value without exposing it', () {
        final json = fixture()..['signing_secret'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
    });
    group('WebhookEndpointList', () {
      final adapter = _adapters['WebhookEndpointListResource']!;
      Map<String, dynamic> fixture() => _fixture('WebhookEndpointListResource');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required data rejects absence', () {
        final json = fixture()..remove('data');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('data rejects explicit null', () {
        final json = fixture()..['data'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('data rejects wrong wire value without exposing it', () {
        final json = fixture()..['data'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('data validates each array element', () {
        final json = fixture()..['data'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('required first_id rejects absence', () {
        final json = fixture()..remove('first_id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('first_id accepts and emits required explicit null', () {
        final json = fixture()..['first_id'] = null;
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('first_id rejects wrong wire value without exposing it', () {
        final json = fixture()..['first_id'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required last_id rejects absence', () {
        final json = fixture()..remove('last_id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('last_id accepts and emits required explicit null', () {
        final json = fixture()..['last_id'] = null;
        expect(adapter.json(adapter.parse(json)), json);
      });
      test('last_id rejects wrong wire value without exposing it', () {
        final json = fixture()..['last_id'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required has_more rejects absence', () {
        final json = fixture()..remove('has_more');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('has_more rejects explicit null', () {
        final json = fixture()..['has_more'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('has_more rejects wrong wire value without exposing it', () {
        final json = fixture()..['has_more'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
    });
    group('DeletedWebhookEndpoint', () {
      final adapter = _adapters['DeletedWebhookEndpointResource']!;
      Map<String, dynamic> fixture() =>
          _fixture('DeletedWebhookEndpointResource');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required id rejects absence', () {
        final json = fixture()..remove('id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects explicit null', () {
        final json = fixture()..['id'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('id rejects wrong wire value without exposing it', () {
        final json = fixture()..['id'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required deleted rejects absence', () {
        final json = fixture()..remove('deleted');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('deleted rejects explicit null', () {
        final json = fixture()..['deleted'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('deleted rejects wrong wire value without exposing it', () {
        final json = fixture()..['deleted'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
    });
    group('WebhookEndpointTestResult', () {
      final adapter = _adapters['WebhookEndpointTestResultResource']!;
      Map<String, dynamic> fixture() =>
          _fixture('WebhookEndpointTestResultResource');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required webhook_endpoint_id rejects absence', () {
        final json = fixture()..remove('webhook_endpoint_id');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('webhook_endpoint_id rejects explicit null', () {
        final json = fixture()..['webhook_endpoint_id'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test(
        'webhook_endpoint_id rejects wrong wire value without exposing it',
        () {
          final json = fixture()..['webhook_endpoint_id'] = false;
          try {
            adapter.parse(json);
            fail('Expected contextual FormatException');
          } on FormatException catch (error) {
            expect(error.source, isNull);
            expect(error.offset, isNull);
            expect(error.toString(), isNot(contains('opaque_secret_marker')));
          }
        },
      );
      test('required event_type rejects absence', () {
        final json = fixture()..remove('event_type');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_type rejects explicit null', () {
        final json = fixture()..['event_type'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('event_type rejects wrong wire value without exposing it', () {
        final json = fixture()..['event_type'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required status_code rejects absence', () {
        final json = fixture()..remove('status_code');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('status_code rejects explicit null', () {
        final json = fixture()..['status_code'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('status_code rejects wrong wire value without exposing it', () {
        final json = fixture()..['status_code'] = 1.5;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required success rejects absence', () {
        final json = fixture()..remove('success');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('success rejects explicit null', () {
        final json = fixture()..['success'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('success rejects wrong wire value without exposing it', () {
        final json = fixture()..['success'] = false;
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
    });
    group('WebhookEventTypeList', () {
      final adapter = _adapters['WebhookEventTypeListResource']!;
      Map<String, dynamic> fixture() =>
          _fixture('WebhookEventTypeListResource');
      test(
        'round-trips canonical fixture and copy with complete equality/hash',
        () {
          final json = fixture();
          final value = adapter.parse(json);
          expect(adapter.json(value), json);
          final reparsed = adapter.parse(adapter.json(value));
          expect(value, reparsed);
          expect(value.hashCode, reparsed.hashCode);
          expect(adapter.copy(value), value);
          expect(adapter.copy(value).hashCode, value.hashCode);
          expect(value == Object(), isFalse);
        },
      );
      test('required object rejects absence', () {
        final json = fixture()..remove('object');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects explicit null', () {
        final json = fixture()..['object'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('object rejects wrong wire value without exposing it', () {
        final json = fixture()..['object'] = 'wrong_object';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('required data rejects absence', () {
        final json = fixture()..remove('data');
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('data rejects explicit null', () {
        final json = fixture()..['data'] = null;
        expect(() => adapter.parse(json), throwsFormatException);
      });
      test('data rejects wrong wire value without exposing it', () {
        final json = fixture()..['data'] = 'opaque_secret_marker';
        try {
          adapter.parse(json);
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.offset, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      });
      test('data validates each array element', () {
        final json = fixture()..['data'] = [false];
        expect(() => adapter.parse(json), throwsFormatException);
      });
    });
  });
  group('exact writable project event choices', () {
    const expected = <String>[
      'batch.completed',
      'batch.failed',
      'batch.expired',
      'batch.cancelled',
      'response.completed',
      'response.failed',
      'response.cancelled',
      'response.incomplete',
      'eval.run.succeeded',
      'eval.run.failed',
      'eval.run.canceled',
      'fine_tuning.job.succeeded',
      'fine_tuning.job.failed',
      'fine_tuning.job.cancelled',
      'realtime.call.incoming',
      'video.completed',
      'video.failed',
      'agent.session.created',
      'agent.session.action_required',
      'agent.session.in_progress',
      'agent.session.idle',
      'agent.session.failed',
      'safety.alert.created',
    ];
    test('contains exactly all 23 canonical choices including video', () {
      expect(WebhookEventType.values.map((value) => value.value), expected);
      expect(WebhookEventType.values.length, 23);
    });
    for (final wire in expected) {
      test('$wire enum/create/update/test round trips', () {
        final event = WebhookEventType.fromJson(wire);
        expect(event.value, wire);
        expect(event.toJson(), wire);
        final create = WebhookEndpointCreateRequest(
          name: 'receiver',
          url: 'https://',
          eventTypes: [event],
        );
        expect(create.toJson()['event_types'], [wire]);
        expect(WebhookEndpointCreateRequest.fromJson(create.toJson()), create);
        final update = WebhookEndpointUpdateRequest(eventTypes: [event]);
        expect(update.toJson(), {
          'event_types': [wire],
        });
        expect(WebhookEndpointUpdateRequest.fromJson(update.toJson()), update);
        final testRequest = WebhookEndpointTestRequest(eventType: event);
        expect(testRequest.toJson(), {'event_type': wire});
        expect(
          WebhookEndpointTestRequest.fromJson(testRequest.toJson()),
          testRequest,
        );
      });
    }
    for (final value in [
      'future.unknown.event',
      'live.call.incoming',
      'live.transport.incoming',
      'safety.org_alert.created',
      'safety.warning_issued',
      'safety.deactivation_issued',
      'VIDEO.COMPLETED',
      'video.completed ',
      '',
      'opaque_secret_marker',
    ]) {
      test('rejects noncanonical writable choice $value', () {
        expect(() => WebhookEventType.fromJson(value), throwsFormatException);
        expect(
          () => WebhookEndpointCreateRequest.fromJson({
            'name': 'receiver',
            'url': 'https://',
            'event_types': [value],
          }),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointUpdateRequest.fromJson({
            'event_types': [value],
          }),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointTestRequest.fromJson({'event_type': value}),
          throwsFormatException,
        );
      });
    }
  });

  group('declared writable constraints', () {
    WebhookEndpointCreateRequest create({
      String name = 'receiver',
      String url = 'https://',
      List<WebhookEventType>? events,
    }) => WebhookEndpointCreateRequest(
      name: name,
      url: url,
      eventTypes: events ?? [WebhookEventType.responseCompleted],
    );
    test('names use Unicode code points at both exact bounds', () {
      for (final name in ['x', 'x' * 256, '😀' * 256, ' ']) {
        final value = create(name: name);
        expect(value.toJson()['name'], name);
        expect(WebhookEndpointCreateRequest.fromJson(value.toJson()), value);
        expect(WebhookEndpointUpdateRequest(name: name).toJson(), {
          'name': name,
        });
      }
    });
    test('names reject zero/257 code points at constructors and parsers', () {
      for (final name in ['', 'x' * 257, '😀' * 257]) {
        expect(() => create(name: name), throwsFormatException);
        expect(
          () => WebhookEndpointCreateRequest.fromJson({
            'name': name,
            'url': 'https://',
            'event_types': const ['response.completed'],
          }),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointUpdateRequest(name: name),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointUpdateRequest.fromJson({'name': name}),
          throwsFormatException,
        );
      }
    });
    test('HTTPS prefix and URL maximum impose no extra URL grammar', () {
      for (final url in [
        'https://',
        'https:// unusual text',
        'https://${'x' * 2040}',
        'https://${'😀' * 2040}',
      ]) {
        final value = create(url: url);
        expect(value.toJson()['url'], url);
        expect(WebhookEndpointCreateRequest.fromJson(value.toJson()), value);
        expect(WebhookEndpointUpdateRequest(url: url).toJson(), {'url': url});
      }
    });
    test('URL rejects wrong prefix or length, with no echoed value', () {
      for (final url in [
        'http://receiver',
        'HTTPS://receiver',
        '',
        'prefixhttps://receiver',
        'https://${'x' * 2041}',
        'https://${'😀' * 2041}',
      ]) {
        expect(() => create(url: url), throwsFormatException);
        expect(
          () => WebhookEndpointCreateRequest.fromJson({
            'name': 'receiver',
            'url': url,
            'event_types': const ['response.completed'],
          }),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointUpdateRequest(url: url),
          throwsFormatException,
        );
        expect(
          () => WebhookEndpointUpdateRequest.fromJson({'url': url}),
          throwsFormatException,
        );
      }
    });
    test('empty event arrays reject, duplicate canonical choices preserve', () {
      expect(() => create(events: []), throwsFormatException);
      expect(
        () => WebhookEndpointUpdateRequest(eventTypes: const []),
        throwsFormatException,
      );
      expect(
        () => WebhookEndpointCreateRequest.fromJson(const {
          'name': 'receiver',
          'url': 'https://',
          'event_types': <String>[],
        }),
        throwsFormatException,
      );
      expect(
        () => WebhookEndpointUpdateRequest.fromJson(const {
          'event_types': <String>[],
        }),
        throwsFormatException,
      );
      final value = create(
        events: [
          WebhookEventType.videoCompleted,
          WebhookEventType.videoCompleted,
        ],
      );
      expect(value.toJson()['event_types'], [
        'video.completed',
        'video.completed',
      ]);
    });
    test('update admits empty object and nullable copy clears to omission', () {
      final value = WebhookEndpointUpdateRequest(
        name: 'receiver',
        url: 'https://',
        eventTypes: const [WebhookEventType.videoCompleted],
      );
      final cleared = value.copyWith(name: null, url: null, eventTypes: null);
      expect(cleared.toJson(), isEmpty);
      expect(cleared, WebhookEndpointUpdateRequest.fromJson(const {}));
      expect(cleared.hashCode, WebhookEndpointUpdateRequest().hashCode);
      for (final key in ['name', 'url', 'event_types']) {
        expect(
          () => WebhookEndpointUpdateRequest.fromJson({key: null}),
          throwsFormatException,
        );
      }
    });
    test(
      'rotation distinguishes omission/false/true and clears to omission',
      () {
        final omitted = WebhookEndpointRotateSecretRequest();
        expect(omitted.toJson(), isEmpty);
        for (final flag in [false, true]) {
          final value = WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: flag,
          );
          expect(value.toJson(), {'keep_old_secret_active_for_24_hours': flag});
          expect(
            WebhookEndpointRotateSecretRequest.fromJson(value.toJson()),
            value,
          );
          expect(value.copyWith(keepOldSecretActiveFor24Hours: null), omitted);
          expect(value.copyWith(), value);
        }
        expect(
          WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: false,
          ),
          isNot(omitted),
        );
        expect(
          WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: true,
          ),
          isNot(omitted),
        );
      },
    );
    test(
      'copy optional values validates bad types without sensitive source',
      () {
        final value = WebhookEndpointUpdateRequest();
        final callbacks = <void Function()>[
          () => value.copyWith(name: {'opaque_secret_marker': true}),
          () => value.copyWith(url: ['opaque_secret_marker']),
          () => value.copyWith(eventTypes: 'opaque_secret_marker'),
          () => value.copyWith(eventTypes: ['opaque_secret_marker']),
          () => WebhookEndpointRotateSecretRequest().copyWith(
            keepOldSecretActiveFor24Hours: 'opaque_secret_marker',
          ),
        ];
        for (final callback in callbacks) {
          try {
            callback();
            fail('Expected contextual FormatException');
          } on FormatException catch (error) {
            expect(error.source, isNull);
            expect(error.toString(), isNot(contains('opaque_secret_marker')));
          }
        }
      },
    );
    test(
      'request parser never emits future received metadata as writable fields',
      () {
        for (final schema in [
          'PublicCreateEndpointBody',
          'PublicUpdateEndpointBody',
          'PublicRotateSecretBody',
          'PublicTestEndpointBody',
        ]) {
          final adapter = _adapters[schema]!;
          final value = adapter.parse({
            ..._fixture(schema),
            'future': {'opaque_secret_marker': true},
          });
          expect(adapter.json(value), _fixture(schema));
        }
      },
    );
  });
  group('copy replacement and effective wire equality/hash', () {
    test('WebhookEndpointCreateRequest copy replaces name', () {
      final original = WebhookEndpointCreateRequest.fromJson(
        _fixture('PublicCreateEndpointBody'),
      );
      final changed = original.copyWith(name: 'new_value');
      final expected = {
        ..._fixture('PublicCreateEndpointBody'),
        'name': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointCreateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicCreateEndpointBody'));
    });
    test('WebhookEndpointCreateRequest copy replaces url', () {
      final original = WebhookEndpointCreateRequest.fromJson(
        _fixture('PublicCreateEndpointBody'),
      );
      final changed = original.copyWith(url: 'https://new_receiver');
      final expected = {
        ..._fixture('PublicCreateEndpointBody'),
        'url': 'https://new_receiver',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointCreateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicCreateEndpointBody'));
    });
    test('WebhookEndpointCreateRequest copy replaces event_types', () {
      final original = WebhookEndpointCreateRequest.fromJson(
        _fixture('PublicCreateEndpointBody'),
      );
      final changed = original.copyWith(
        eventTypes: [WebhookEventType.responseFailed],
      );
      final expected = {
        ..._fixture('PublicCreateEndpointBody'),
        'event_types': ['response.failed'],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointCreateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicCreateEndpointBody'));
    });
    test('WebhookEndpointUpdateRequest copy replaces name', () {
      final original = WebhookEndpointUpdateRequest.fromJson(
        _fixture('PublicUpdateEndpointBody'),
      );
      final changed = original.copyWith(name: 'new_value');
      final expected = {
        ..._fixture('PublicUpdateEndpointBody'),
        'name': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicUpdateEndpointBody'));
    });
    test('WebhookEndpointUpdateRequest copy clears name', () {
      final original = WebhookEndpointUpdateRequest.fromJson({
        ..._fixture('PublicUpdateEndpointBody'),
        'name': 'new_value',
      });
      final cleared = original.copyWith(name: null);
      final expected = (_fixture('PublicUpdateEndpointBody')..remove('name'));
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointUpdateRequest copy replaces url', () {
      final original = WebhookEndpointUpdateRequest.fromJson(
        _fixture('PublicUpdateEndpointBody'),
      );
      final changed = original.copyWith(url: 'https://new_receiver');
      final expected = {
        ..._fixture('PublicUpdateEndpointBody'),
        'url': 'https://new_receiver',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicUpdateEndpointBody'));
    });
    test('WebhookEndpointUpdateRequest copy clears url', () {
      final original = WebhookEndpointUpdateRequest.fromJson({
        ..._fixture('PublicUpdateEndpointBody'),
        'url': 'https://new_receiver',
      });
      final cleared = original.copyWith(url: null);
      final expected = (_fixture('PublicUpdateEndpointBody')..remove('url'));
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointUpdateRequest copy replaces event_types', () {
      final original = WebhookEndpointUpdateRequest.fromJson(
        _fixture('PublicUpdateEndpointBody'),
      );
      final changed = original.copyWith(
        eventTypes: [WebhookEventType.responseFailed],
      );
      final expected = {
        ..._fixture('PublicUpdateEndpointBody'),
        'event_types': ['response.failed'],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicUpdateEndpointBody'));
    });
    test('WebhookEndpointUpdateRequest copy clears event_types', () {
      final original = WebhookEndpointUpdateRequest.fromJson({
        ..._fixture('PublicUpdateEndpointBody'),
        'event_types': const ['response.failed'],
      });
      final cleared = original.copyWith(eventTypes: null);
      final expected = (_fixture('PublicUpdateEndpointBody')
        ..remove('event_types'));
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointUpdateRequest.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test(
      'WebhookEndpointRotateSecretRequest copy replaces keep_old_secret_active_for_24_hours',
      () {
        final original = WebhookEndpointRotateSecretRequest.fromJson(
          _fixture('PublicRotateSecretBody'),
        );
        final changed = original.copyWith(keepOldSecretActiveFor24Hours: true);
        final expected = {
          ..._fixture('PublicRotateSecretBody'),
          'keep_old_secret_active_for_24_hours': true,
        };
        expect(changed.toJson(), expected);
        final reparsed = WebhookEndpointRotateSecretRequest.fromJson(expected);
        expect(changed, reparsed);
        expect(changed.hashCode, reparsed.hashCode);
        expect(changed, isNot(original));
        expect(original.toJson(), _fixture('PublicRotateSecretBody'));
      },
    );
    test(
      'WebhookEndpointRotateSecretRequest copy clears keep_old_secret_active_for_24_hours',
      () {
        final original = WebhookEndpointRotateSecretRequest.fromJson({
          ..._fixture('PublicRotateSecretBody'),
          'keep_old_secret_active_for_24_hours': true,
        });
        final cleared = original.copyWith(keepOldSecretActiveFor24Hours: null);
        final expected = (_fixture('PublicRotateSecretBody')
          ..remove('keep_old_secret_active_for_24_hours'));
        expect(cleared.toJson(), expected);
        final reparsed = WebhookEndpointRotateSecretRequest.fromJson(expected);
        expect(cleared, reparsed);
        expect(cleared.hashCode, reparsed.hashCode);
      },
    );
    test('WebhookEndpointTestRequest copy replaces event_type', () {
      final original = WebhookEndpointTestRequest.fromJson(
        _fixture('PublicTestEndpointBody'),
      );
      final changed = original.copyWith(
        eventType: WebhookEventType.responseFailed,
      );
      final expected = {
        ..._fixture('PublicTestEndpointBody'),
        'event_type': 'response.failed',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointTestRequest.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('PublicTestEndpointBody'));
    });
    test('WebhookEndpoint copy replaces id', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(id: 'new_value');
      final expected = {..._fixture('WebhookEndpointBody'), 'id': 'new_value'};
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy replaces created_at', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(createdAt: 99);
      final expected = {..._fixture('WebhookEndpointBody'), 'created_at': 99};
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy replaces updated_at', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(updatedAt: 99);
      final expected = {..._fixture('WebhookEndpointBody'), 'updated_at': 99};
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy clears updated_at', () {
      final original = WebhookEndpoint.fromJson({
        ..._fixture('WebhookEndpointBody'),
        'updated_at': 99,
      });
      final cleared = original.copyWith(updatedAt: null);
      final expected = (_fixture('WebhookEndpointBody')..remove('updated_at'));
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpoint copy replaces name', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(name: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointBody'),
        'name': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy replaces url', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(url: 'https://new_receiver');
      final expected = {
        ..._fixture('WebhookEndpointBody'),
        'url': 'https://new_receiver',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy replaces event_types', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(eventTypes: ['future.new.event']);
      final expected = {
        ..._fixture('WebhookEndpointBody'),
        'event_types': ['future.new.event'],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy replaces signing_secret_hint', () {
      final original = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final changed = original.copyWith(signingSecretHint: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointBody'),
        'signing_secret_hint': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointBody'));
    });
    test('WebhookEndpoint copy clears signing_secret_hint', () {
      final original = WebhookEndpoint.fromJson({
        ..._fixture('WebhookEndpointBody'),
        'signing_secret_hint': 'new_value',
      });
      final cleared = original.copyWith(signingSecretHint: null);
      final expected = {
        ..._fixture('WebhookEndpointBody'),
        'signing_secret_hint': null,
      };
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpoint.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test(
      'WebhookEndpoint raw shadows never override typed fields and futures clear',
      () {
        final original = WebhookEndpoint.fromJson({
          ..._fixture('WebhookEndpointBody'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'id': 'known_raw_shadow',
            'object': 'known_raw_shadow',
            'created_at': 'known_raw_shadow',
            'updated_at': 'known_raw_shadow',
            'name': 'known_raw_shadow',
            'url': 'known_raw_shadow',
            'event_types': 'known_raw_shadow',
            'signing_secret_hint': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('WebhookEndpointBody'));
        final canonical = WebhookEndpoint.fromJson(
          _fixture('WebhookEndpointBody'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
    test('WebhookEndpointWithSecret copy replaces id', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(id: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'id': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy replaces created_at', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(createdAt: 99);
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'created_at': 99,
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy replaces updated_at', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(updatedAt: 99);
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'updated_at': 99,
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy clears updated_at', () {
      final original = WebhookEndpointWithSecret.fromJson({
        ..._fixture('WebhookEndpointWithSecretResource'),
        'updated_at': 99,
      });
      final cleared = original.copyWith(updatedAt: null);
      final expected = (_fixture('WebhookEndpointWithSecretResource')
        ..remove('updated_at'));
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointWithSecret copy replaces name', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(name: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'name': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy replaces url', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(url: 'https://new_receiver');
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'url': 'https://new_receiver',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy replaces event_types', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(eventTypes: ['future.new.event']);
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'event_types': ['future.new.event'],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy replaces signing_secret_hint', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(signingSecretHint: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'signing_secret_hint': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test('WebhookEndpointWithSecret copy clears signing_secret_hint', () {
      final original = WebhookEndpointWithSecret.fromJson({
        ..._fixture('WebhookEndpointWithSecretResource'),
        'signing_secret_hint': 'new_value',
      });
      final cleared = original.copyWith(signingSecretHint: null);
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'signing_secret_hint': null,
      };
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointWithSecret copy replaces signing_secret', () {
      final original = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final changed = original.copyWith(signingSecret: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointWithSecretResource'),
        'signing_secret': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointWithSecret.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointWithSecretResource'));
    });
    test(
      'WebhookEndpointWithSecret raw shadows never override typed fields and futures clear',
      () {
        final original = WebhookEndpointWithSecret.fromJson({
          ..._fixture('WebhookEndpointWithSecretResource'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'id': 'known_raw_shadow',
            'object': 'known_raw_shadow',
            'created_at': 'known_raw_shadow',
            'updated_at': 'known_raw_shadow',
            'name': 'known_raw_shadow',
            'url': 'known_raw_shadow',
            'event_types': 'known_raw_shadow',
            'signing_secret_hint': 'known_raw_shadow',
            'signing_secret': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('WebhookEndpointWithSecretResource'));
        final canonical = WebhookEndpointWithSecret.fromJson(
          _fixture('WebhookEndpointWithSecretResource'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
    test('WebhookEndpointList copy replaces data', () {
      final original = WebhookEndpointList.fromJson(
        _fixture('WebhookEndpointListResource'),
      );
      final changed = original.copyWith(
        data: [
          WebhookEndpoint.fromJson(
            _fixture('WebhookEndpointBody'),
          ).copyWith(id: 'new_child'),
        ],
      );
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'data': [
          ...<Map<String, dynamic>>[
            {..._fixture('WebhookEndpointBody'), 'id': 'new_child'},
          ],
        ],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointListResource'));
    });
    test('WebhookEndpointList copy replaces first_id', () {
      final original = WebhookEndpointList.fromJson(
        _fixture('WebhookEndpointListResource'),
      );
      final changed = original.copyWith(firstId: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'first_id': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointListResource'));
    });
    test('WebhookEndpointList copy clears first_id', () {
      final original = WebhookEndpointList.fromJson({
        ..._fixture('WebhookEndpointListResource'),
        'first_id': 'new_value',
      });
      final cleared = original.copyWith(firstId: null);
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'first_id': null,
      };
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointList copy replaces last_id', () {
      final original = WebhookEndpointList.fromJson(
        _fixture('WebhookEndpointListResource'),
      );
      final changed = original.copyWith(lastId: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'last_id': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointListResource'));
    });
    test('WebhookEndpointList copy clears last_id', () {
      final original = WebhookEndpointList.fromJson({
        ..._fixture('WebhookEndpointListResource'),
        'last_id': 'new_value',
      });
      final cleared = original.copyWith(lastId: null);
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'last_id': null,
      };
      expect(cleared.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(cleared, reparsed);
      expect(cleared.hashCode, reparsed.hashCode);
    });
    test('WebhookEndpointList copy replaces has_more', () {
      final original = WebhookEndpointList.fromJson(
        _fixture('WebhookEndpointListResource'),
      );
      final changed = original.copyWith(hasMore: false);
      final expected = {
        ..._fixture('WebhookEndpointListResource'),
        'has_more': false,
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointList.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointListResource'));
    });
    test(
      'WebhookEndpointList raw shadows never override typed fields and futures clear',
      () {
        final original = WebhookEndpointList.fromJson({
          ..._fixture('WebhookEndpointListResource'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'object': 'known_raw_shadow',
            'data': 'known_raw_shadow',
            'first_id': 'known_raw_shadow',
            'last_id': 'known_raw_shadow',
            'has_more': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('WebhookEndpointListResource'));
        final canonical = WebhookEndpointList.fromJson(
          _fixture('WebhookEndpointListResource'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
    test('DeletedWebhookEndpoint copy replaces id', () {
      final original = DeletedWebhookEndpoint.fromJson(
        _fixture('DeletedWebhookEndpointResource'),
      );
      final changed = original.copyWith(id: 'new_value');
      final expected = {
        ..._fixture('DeletedWebhookEndpointResource'),
        'id': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = DeletedWebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('DeletedWebhookEndpointResource'));
    });
    test('DeletedWebhookEndpoint copy replaces deleted', () {
      final original = DeletedWebhookEndpoint.fromJson(
        _fixture('DeletedWebhookEndpointResource'),
      );
      final changed = original.copyWith(deleted: true);
      final expected = {
        ..._fixture('DeletedWebhookEndpointResource'),
        'deleted': true,
      };
      expect(changed.toJson(), expected);
      final reparsed = DeletedWebhookEndpoint.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('DeletedWebhookEndpointResource'));
    });
    test(
      'DeletedWebhookEndpoint raw shadows never override typed fields and futures clear',
      () {
        final original = DeletedWebhookEndpoint.fromJson({
          ..._fixture('DeletedWebhookEndpointResource'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'id': 'known_raw_shadow',
            'object': 'known_raw_shadow',
            'deleted': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('DeletedWebhookEndpointResource'));
        final canonical = DeletedWebhookEndpoint.fromJson(
          _fixture('DeletedWebhookEndpointResource'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
    test('WebhookEndpointTestResult copy replaces webhook_endpoint_id', () {
      final original = WebhookEndpointTestResult.fromJson(
        _fixture('WebhookEndpointTestResultResource'),
      );
      final changed = original.copyWith(webhookEndpointId: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointTestResultResource'),
        'webhook_endpoint_id': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointTestResult.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointTestResultResource'));
    });
    test('WebhookEndpointTestResult copy replaces event_type', () {
      final original = WebhookEndpointTestResult.fromJson(
        _fixture('WebhookEndpointTestResultResource'),
      );
      final changed = original.copyWith(eventType: 'new_value');
      final expected = {
        ..._fixture('WebhookEndpointTestResultResource'),
        'event_type': 'new_value',
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointTestResult.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointTestResultResource'));
    });
    test('WebhookEndpointTestResult copy replaces status_code', () {
      final original = WebhookEndpointTestResult.fromJson(
        _fixture('WebhookEndpointTestResultResource'),
      );
      final changed = original.copyWith(statusCode: 99);
      final expected = {
        ..._fixture('WebhookEndpointTestResultResource'),
        'status_code': 99,
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEndpointTestResult.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEndpointTestResultResource'));
    });
    test(
      'WebhookEndpointTestResult raw shadows never override typed fields and futures clear',
      () {
        final original = WebhookEndpointTestResult.fromJson({
          ..._fixture('WebhookEndpointTestResultResource'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'object': 'known_raw_shadow',
            'webhook_endpoint_id': 'known_raw_shadow',
            'event_type': 'known_raw_shadow',
            'status_code': 'known_raw_shadow',
            'success': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('WebhookEndpointTestResultResource'));
        final canonical = WebhookEndpointTestResult.fromJson(
          _fixture('WebhookEndpointTestResultResource'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
    test('WebhookEventTypeList copy replaces data', () {
      final original = WebhookEventTypeList.fromJson(
        _fixture('WebhookEventTypeListResource'),
      );
      final changed = original.copyWith(data: ['future.new.event']);
      final expected = {
        ..._fixture('WebhookEventTypeListResource'),
        'data': ['future.new.event'],
      };
      expect(changed.toJson(), expected);
      final reparsed = WebhookEventTypeList.fromJson(expected);
      expect(changed, reparsed);
      expect(changed.hashCode, reparsed.hashCode);
      expect(changed, isNot(original));
      expect(original.toJson(), _fixture('WebhookEventTypeListResource'));
    });
    test(
      'WebhookEventTypeList raw shadows never override typed fields and futures clear',
      () {
        final original = WebhookEventTypeList.fromJson({
          ..._fixture('WebhookEventTypeListResource'),
          'future': const {
            'nested': ['opaque_secret_marker'],
          },
        });
        final retained = original.copyWith();
        expect(retained, original);
        expect(retained.hashCode, original.hashCode);
        final changedRaw = original.copyWith(
          rawJson: {
            'future': {
              'nested': ['opaque_secret_marker'],
            },
            'object': 'known_raw_shadow',
            'data': 'known_raw_shadow',
          },
        );
        expect(changedRaw, original);
        expect(changedRaw.hashCode, original.hashCode);
        final cleared = original.copyWith(rawJson: {});
        expect(cleared.toJson(), _fixture('WebhookEventTypeListResource'));
        final canonical = WebhookEventTypeList.fromJson(
          _fixture('WebhookEventTypeListResource'),
        );
        expect(cleared, canonical);
        expect(cleared.hashCode, canonical.hashCode);
        expect(cleared, isNot(original));
      },
    );
  });

  group('receive-only compatibility and ownership', () {
    test('receiver DTOs preserve values outside writable constraints', () {
      final value = WebhookEndpoint.fromJson(const {
        'id': '',
        'object': 'webhook_endpoint',
        'created_at': -999,
        'updated_at': -998,
        'name': '',
        'url': 'http://receive-only',
        'event_types': <String>[],
        'signing_secret_hint': null,
      });
      expect(value.id, '');
      expect(value.createdAt, -999);
      expect(value.updatedAt, -998);
      expect(value.name, '');
      expect(value.url, 'http://receive-only');
      expect(value.eventTypes, isEmpty);
      expect(WebhookEndpoint.fromJson(value.toJson()), value);
      final discovery = WebhookEventTypeList.fromJson(const {
        'object': 'list',
        'data': ['future.project.event', 'video.completed'],
      });
      expect(discovery.data, ['future.project.event', 'video.completed']);
      expect(WebhookEventTypeList.fromJson(discovery.toJson()), discovery);
    });
    test('signing secrets retain raw, short and empty string values', () {
      for (final secret in ['', 'x', 'synthetic_signing_secret']) {
        final value = WebhookEndpointWithSecret.fromJson({
          ..._fixture('WebhookEndpointWithSecretResource'),
          'signing_secret': secret,
        });
        expect(value.signingSecret, secret);
        expect(value.toJson()['signing_secret'], secret);
        expect(WebhookEndpointWithSecret.fromJson(value.toJson()), value);
        expect(value.toString(), contains('signingSecret: [redacted]'));
      }
    });
    test(
      'success true remains true at 2xx and 500 without status range invention',
      () {
        for (final status in [200, 204, 400, 500, -1, 9999]) {
          final value = WebhookEndpointTestResult.fromJson({
            ..._fixture('WebhookEndpointTestResultResource'),
            'status_code': status,
          });
          expect(value.success, isTrue);
          expect(value.statusCode, status);
          expect(value.toJson()['success'], isTrue);
          expect(WebhookEndpointTestResult.fromJson(value.toJson()), value);
        }
        final deleted = DeletedWebhookEndpoint.fromJson({
          ..._fixture('DeletedWebhookEndpointResource'),
          'deleted': false,
        });
        expect(deleted.deleted, isFalse);
        expect(deleted.toJson()['deleted'], isFalse);
      },
    );
    test('optional updatedAt can clear without a stale raw resurrection', () {
      for (final schema in [
        'WebhookEndpointBody',
        'WebhookEndpointWithSecretResource',
      ]) {
        final adapter = _adapters[schema]!;
        final wire = {..._fixture(schema), 'updated_at': 100};
        final value = adapter.parse(wire);
        final cleared = switch (value) {
          final WebhookEndpoint endpoint => endpoint.copyWith(updatedAt: null),
          final WebhookEndpointWithSecret endpoint => endpoint.copyWith(
            updatedAt: null,
          ),
          _ => throw StateError('Unsupported fixture'),
        };
        expect(adapter.json(cleared), _fixture(schema));
        expect(cleared, adapter.parse(_fixture(schema)));
        expect(cleared.hashCode, adapter.parse(_fixture(schema)).hashCode);
      }
    });
    test(
      'all model diagnostics redact opaque fields and include each field',
      () {
        const marker = 'opaque_secret_marker';
        final endpointWire = {
          'id': marker,
          'object': 'webhook_endpoint',
          'created_at': 1,
          'updated_at': 2,
          'name': marker,
          'url': marker,
          'event_types': [marker],
          'signing_secret_hint': marker,
          'signing_secret': marker,
          'future': {
            marker: [marker],
          },
        };
        final values = <Object>[
          WebhookEndpointCreateRequest(
            name: marker,
            url: 'https://$marker',
            eventTypes: const [WebhookEventType.videoFailed],
          ),
          WebhookEndpointUpdateRequest(
            name: marker,
            url: 'https://$marker',
            eventTypes: const [WebhookEventType.videoFailed],
          ),
          WebhookEndpointRotateSecretRequest(
            keepOldSecretActiveFor24Hours: true,
          ),
          WebhookEndpointTestRequest(eventType: WebhookEventType.videoFailed),
          WebhookEndpoint.fromJson(endpointWire),
          WebhookEndpointWithSecret.fromJson(endpointWire),
          WebhookEndpointList.fromJson({
            'object': 'list',
            'data': [endpointWire],
            'first_id': marker,
            'last_id': marker,
            'has_more': true,
            'future': marker,
          }),
          DeletedWebhookEndpoint.fromJson(const {
            'id': marker,
            'object': 'webhook_endpoint.deleted',
            'deleted': false,
            'future': marker,
          }),
          WebhookEndpointTestResult.fromJson(const {
            'object': 'webhook_endpoint.test',
            'webhook_endpoint_id': marker,
            'event_type': marker,
            'status_code': 500,
            'success': true,
            'future': marker,
          }),
          WebhookEventTypeList.fromJson(const {
            'object': 'list',
            'data': [marker],
            'future': marker,
          }),
        ];
        for (final value in values) {
          expect(value.toString(), isNot(contains(marker)));
        }
        final diagnostics = values[5].toString();
        for (final field in [
          'id',
          'object',
          'createdAt',
          'updatedAt',
          'name',
          'url',
          'eventTypes',
          'signingSecretHint',
          'signingSecret',
          'rawJson',
        ]) {
          expect(diagnostics, contains('$field:'));
        }
      },
    );
    test('constructors defensively own mutable typed lists', () {
      final events = [WebhookEventType.videoCompleted];
      final create = WebhookEndpointCreateRequest(
        name: 'receiver',
        url: 'https://',
        eventTypes: events,
      );
      final update = WebhookEndpointUpdateRequest(eventTypes: events);
      events[0] = WebhookEventType.videoFailed;
      expect(create.eventTypes, [WebhookEventType.videoCompleted]);
      expect(update.eventTypes, [WebhookEventType.videoCompleted]);
      expect(
        () => create.eventTypes.add(WebhookEventType.videoFailed),
        throwsUnsupportedError,
      );
      expect(
        () => update.eventTypes!.add(WebhookEventType.videoFailed),
        throwsUnsupportedError,
      );
      final receivedEvents = ['future.project.event'];
      final endpoint = WebhookEndpoint(
        id: 'id',
        createdAt: 1,
        name: 'name',
        url: 'url',
        eventTypes: receivedEvents,
        signingSecretHint: null,
      );
      final withSecret = WebhookEndpointWithSecret(
        id: 'id',
        createdAt: 1,
        name: 'name',
        url: 'url',
        eventTypes: receivedEvents,
        signingSecretHint: null,
        signingSecret: 'synthetic_signing_secret',
      );
      final discovery = WebhookEventTypeList(data: receivedEvents);
      receivedEvents.clear();
      expect(endpoint.eventTypes, ['future.project.event']);
      expect(withSecret.eventTypes, ['future.project.event']);
      expect(discovery.data, ['future.project.event']);
      expect(endpoint.eventTypes.clear, throwsUnsupportedError);
      expect(withSecret.eventTypes.clear, throwsUnsupportedError);
      expect(discovery.data.clear, throwsUnsupportedError);
      final data = [endpoint];
      final page = WebhookEndpointList(
        data: data,
        firstId: null,
        lastId: null,
        hasMore: false,
      );
      data.clear();
      expect(page.data, [endpoint]);
      expect(page.data.clear, throwsUnsupportedError);
    });
    test(
      'parsed snapshots deeply freeze nested future values and serialize freshly',
      () {
        final nested = <String, dynamic>{
          'items': <Object?>[
            <String, dynamic>{'marker': 'before'},
          ],
        };
        final json = {
          ..._fixture('WebhookEndpointWithSecretResource'),
          'future': nested,
        };
        final value = WebhookEndpointWithSecret.fromJson(json);
        final before = value.toJson();
        (nested['items'] as List<Object?>).clear();
        json['id'] = 'after';
        expect(value.toJson(), before);
        expect(identical(value.toJson(), before), isFalse);
        expect(() => value.rawJson['future'] = null, throwsUnsupportedError);
        final rawFuture = value.rawJson['future'] as Map<String, dynamic>;
        expect(() => rawFuture['items'] = null, throwsUnsupportedError);
        expect(
          () => (rawFuture['items'] as List<Object?>).clear(),
          throwsUnsupportedError,
        );
        final child =
            (rawFuture['items'] as List<Object?>).single!
                as Map<String, dynamic>;
        expect(() => child['marker'] = 'after', throwsUnsupportedError);
        expect(
          () => before['signing_secret'] = 'after',
          throwsUnsupportedError,
        );
      },
    );
    test(
      'nested children use complete replacement JSON without parent resurrection',
      () {
        final first = {
          ..._fixture('WebhookEndpointBody'),
          'id': 'first',
          'future': {'marker': 'first_metadata'},
        };
        final second = {
          ..._fixture('WebhookEndpointBody'),
          'id': 'second',
          'future': {'marker': 'second_metadata'},
        };
        final page = WebhookEndpointList.fromJson({
          'object': 'list',
          'data': [first, second],
          'first_id': 'first',
          'last_id': 'second',
          'has_more': true,
          'future_page': 'retained',
        });
        final reversed = page.copyWith(data: page.data.reversed.toList());
        expect(reversed.toJson()['data'], [second, first]);
        final fresh = WebhookEndpoint.fromJson(
          _fixture('WebhookEndpointBody'),
        ).copyWith(id: 'fresh');
        final changed = page.copyWith(
          data: [
            page.data[1].copyWith(rawJson: {}),
            fresh,
          ],
        );
        expect(changed.toJson()['data'], [
          {..._fixture('WebhookEndpointBody'), 'id': 'second'},
          {..._fixture('WebhookEndpointBody'), 'id': 'fresh'},
        ]);
        expect(changed.toJson()['future_page'], 'retained');
        final reparsed = WebhookEndpointList.fromJson(changed.toJson());
        expect(changed, reparsed);
        expect(changed.hashCode, reparsed.hashCode);
      },
    );
    test('raw-only map key order has equal deep values and hash', () {
      final first = WebhookEventTypeList(
        data: const ['future.project.event'],
        rawJson: const {
          'a': {
            'x': 1,
            'y': <Object?>[true, null],
          },
          'b': 'value',
        },
      );
      final second = WebhookEventTypeList(
        data: const ['future.project.event'],
        rawJson: const {
          'b': 'value',
          'a': {
            'y': <Object?>[true, null],
            'x': 1,
          },
        },
      );
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
    test('required nullable copies reject bad types with safe context', () {
      final endpoint = WebhookEndpoint.fromJson(
        _fixture('WebhookEndpointBody'),
      );
      final withSecret = WebhookEndpointWithSecret.fromJson(
        _fixture('WebhookEndpointWithSecretResource'),
      );
      final page = WebhookEndpointList.fromJson(
        _fixture('WebhookEndpointListResource'),
      );
      final callbacks = <void Function()>[
        () => endpoint.copyWith(signingSecretHint: ['opaque_secret_marker']),
        () => endpoint.copyWith(updatedAt: 'opaque_secret_marker'),
        () => withSecret.copyWith(signingSecretHint: ['opaque_secret_marker']),
        () => withSecret.copyWith(updatedAt: 'opaque_secret_marker'),
        () => page.copyWith(firstId: ['opaque_secret_marker']),
        () => page.copyWith(lastId: ['opaque_secret_marker']),
      ];
      for (final callback in callbacks) {
        try {
          callback();
          fail('Expected contextual FormatException');
        } on FormatException catch (error) {
          expect(error.source, isNull);
          expect(error.toString(), isNot(contains('opaque_secret_marker')));
        }
      }
    });
    test(
      'finite raw JSON rejects objects, nonfinite values and cycles safely',
      () {
        final cycle = <String, dynamic>{};
        cycle['self'] = cycle;
        final listCycle = <Object?>[];
        listCycle.add(listCycle);
        final values = <Object?>[
          double.nan,
          double.infinity,
          -double.infinity,
          Object(),
          DateTime.utc(2020),
          cycle,
          listCycle,
          <Object?, Object?>{1: 'opaque_secret_marker'},
        ];
        for (final invalid in values) {
          for (final schema in [
            'WebhookEndpointBody',
            'WebhookEndpointWithSecretResource',
            'WebhookEndpointListResource',
            'DeletedWebhookEndpointResource',
            'WebhookEndpointTestResultResource',
            'WebhookEventTypeListResource',
          ]) {
            final adapter = _adapters[schema]!;
            try {
              adapter.parse({..._fixture(schema), 'future': invalid});
              fail('Expected finite JSON FormatException');
            } on FormatException catch (error) {
              expect(error.source, isNull);
              expect(error.toString(), isNot(contains('opaque_secret_marker')));
            }
          }
          expect(
            () => WebhookEventTypeList(
              data: const [],
              rawJson: {'future': invalid},
            ),
            throwsFormatException,
          );
        }
      },
    );
  });
}
