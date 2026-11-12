import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

// HMAC fixture computed independently from the UTF-8 body with Python hmac.
const _payload =
    '{"type":"event","id":"evt_fixture",'
    '"created_at":"2026-11-11T21:00:00Z","data":{'
    '"type":"user_profile.enforcement_action_opened","id":"upro_fixture",'
    '"organization_id":"org_fixture","enforcement_action_id":"enf_fixture"}}';
const _key = 'whsec_Zml4dHVyZSBzaWduaW5nIHNlY3JldCAzMiBieXRlcyE=';
const _timestamp = 1794438000;
const _validSignature = 'v1,1OX7HmUrKHoNX5Up0oI6ii+qiR1yJEwQUG6o4KlNu5E=';
const _headers = {
  'Webhook-ID': 'evt_fixture',
  'WEBHOOK-TIMESTAMP': '$_timestamp',
  'webhook-signature': 'v2,ignored v1,malformed! $_validSignature',
};
final _receivedAt = DateTime.fromMillisecondsSinceEpoch(
  _timestamp * 1000,
  isUtc: true,
);

void main() {
  test('verifies the raw signed payload using case-insensitive headers', () {
    final event = WebhookEvent.unwrap(
      _payload,
      headers: _headers,
      signingSecret: _key,
      receivedAt: _receivedAt,
    );
    expect(event.id, 'evt_fixture');
    final data = event.data as WebhookUserProfileEventData;
    expect(data.event, OrganizationWebhookEventType.enforcementActionOpened);
    expect(data.id, 'upro_fixture');
    expect(data.organizationId, 'org_fixture');
    expect(data.enforcementActionId, 'enf_fixture');
  });

  test('rejects a validly signed event missing required fields', () {
    const missingId =
        '{"type":"event","created_at":"2026-11-11T21:00:00Z",'
        '"data":{"type":"future"}}';
    final headers = Map<String, String>.of(_headers)
      ..['webhook-signature'] =
          'v1,ra4moyOyOxdX8j4sK/v9shkre07j6lW3y1v0zcClf1c=';
    expect(
      () => WebhookEvent.unwrap(
        missingId,
        headers: headers,
        signingSecret: _key,
        receivedAt: _receivedAt,
      ),
      throwsA(isA<FormatException>().having((e) => e.source, 'source', isNull)),
    );
    expect(
      WebhookEvent.unwrap(
        _payload,
        headers: _headers,
        signingSecret: _key,
        receivedAt: _receivedAt,
      ).id,
      'evt_fixture',
    );
  });

  test('checks the timestamp and rejects a modified body or delivery ID', () {
    WebhookEvent verify({
      String payload = _payload,
      Map<String, String> headers = _headers,
      String key = _key,
      Duration offset = Duration.zero,
    }) => WebhookEvent.unwrap(
      payload,
      headers: headers,
      signingSecret: key,
      receivedAt: _receivedAt.add(offset),
    );

    expect(verify(offset: const Duration(minutes: 5)).id, 'evt_fixture');
    expect(
      () => verify(offset: const Duration(seconds: 301)),
      throwsFormatException,
    );
    expect(
      () => verify(offset: const Duration(seconds: -301)),
      throwsFormatException,
    );
    expect(() => verify(payload: '$_payload\n'), throwsFormatException);
    expect(
      () => verify(headers: {..._headers, 'Webhook-ID': 'evt_modified'}),
      throwsFormatException,
    );
    expect(() => verify(headers: const {}), throwsFormatException);
    expect(
      () => verify(headers: {..._headers, 'WEBHOOK-TIMESTAMP': '0xff'}),
      throwsFormatException,
    );
    expect(() => verify(key: 'whsec_'), throwsFormatException);
    expect(
      () => verify(key: 'whsec_invalid-secret-value!'),
      throwsA(
        isA<FormatException>().having(
          (error) => error.toString(),
          'redacted',
          isNot(contains('invalid-secret-value')),
        ),
      ),
    );
  });

  test(
    'parses all pinned organization events and leaves future events intact',
    () {
      for (final type in OrganizationWebhookEventType.values) {
        final data = <String, String>{
          'type': type.value,
          'id': 'upro_fixture',
          'organization_id': 'org_fixture',
          if (type != OrganizationWebhookEventType.programStatusUpdated)
            'enforcement_action_id': 'enf_fixture',
        };
        final parsed = WebhookEvent.parseUnverified(
          jsonEncode({
            'type': 'event',
            'id': 'evt_fixture',
            'created_at': '2026-11-11T21:00:00Z',
            'data': data,
          }),
        );
        expect((parsed.data as WebhookUserProfileEventData).event, type);
        expect(parsed.data.toJson(), data);
      }
      const future = {
        'type': 'user_profile.future_event',
        'arbitrary': [1, 2],
      };
      final event = WebhookEvent.fromJson(const {
        'type': 'event',
        'id': 'evt_fixture',
        'created_at': '2026-11-11T21:00:00Z',
        'data': future,
      });
      expect(event.data, isA<UnknownWebhookEventData>());
      expect(event.data.toJson(), future);
      expect(() => WebhookEvent.parseUnverified('[]'), throwsFormatException);
    },
  );
}
