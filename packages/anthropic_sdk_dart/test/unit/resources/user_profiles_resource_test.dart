import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for user profiles API responses.
class UserProfilesFixtures {
  UserProfilesFixtures._();

  static Map<String, dynamic> userProfile({
    String id = 'uprof_011CZkZCu8hGbp5mYRQgUmz9',
    String? externalId = 'user_12345',
    Map<String, String>? metadata,
    Map<String, dynamic>? trustGrants,
  }) {
    return {
      'id': id,
      'type': 'user_profile',
      'external_id': externalId,
      'metadata': metadata ?? <String, String>{},
      'trust_grants':
          trustGrants ??
          {
            'cyber': {'status': 'active'},
          },
      'created_at': '2026-03-15T10:00:00Z',
      'updated_at': '2026-03-15T10:00:00Z',
    };
  }

  static Map<String, dynamic> enrollmentUrl({
    String url =
        'https://platform.claude.com/user-profiles/enrollment/M3J0bGJxZ2ppMnptbnB1',
    String expiresAt = '2026-03-15T10:15:00Z',
  }) {
    return {'type': 'enrollment_url', 'url': url, 'expires_at': expiresAt};
  }
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('UserProfilesResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        UserProfilesFixtures.userProfile(externalId: 'user_12345'),
      );

      final profile = await client.userProfiles.create(
        const CreateUserProfileRequest(
          externalId: 'user_12345',
          metadata: {'tier': 'pro'},
        ),
      );

      expect(profile.id, 'uprof_011CZkZCu8hGbp5mYRQgUmz9');
      expect(profile.externalId, 'user_12345');
      expect(profile.type, 'user_profile');
      expect(profile.trustGrants['cyber']?.status, TrustGrantStatus.active);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/user_profiles');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'user-profiles-2026-03-24');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['external_id'], 'user_12345');
      expect(body['metadata'], {'tier': 'pro'});
    });

    test('create omits null fields from body', () async {
      mockHttpClient.queueJsonResponse(
        UserProfilesFixtures.userProfile(externalId: null),
      );

      await client.userProfiles.create(const CreateUserProfileRequest());

      final request = mockHttpClient.lastRequest!;
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body.containsKey('external_id'), isFalse);
      expect(body.containsKey('metadata'), isFalse);
    });

    test('list sends query params and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'data': [UserProfilesFixtures.userProfile()],
        'next_page': 'page_abc123',
      });

      final response = await client.userProfiles.list(
        limit: 10,
        page: 'cursor_xyz',
        order: UserProfileListOrder.desc,
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'uprof_011CZkZCu8hGbp5mYRQgUmz9');
      expect(response.nextPage, 'page_abc123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/user_profiles');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '10');
      expect(request.url.queryParameters['page'], 'cursor_xyz');
      expect(request.url.queryParameters['order'], 'desc');
      expect(request.headers['anthropic-beta'], 'user-profiles-2026-03-24');
    });

    test('list without params sends no query string', () async {
      mockHttpClient.queueJsonResponse({
        'data': <Map<String, dynamic>>[],
        'next_page': null,
      });

      final response = await client.userProfiles.list();

      expect(response.data, isEmpty);
      expect(response.nextPage, isNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.queryParameters, isEmpty);
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(UserProfilesFixtures.userProfile());

      final profile = await client.userProfiles.retrieve(
        'uprof_011CZkZCu8hGbp5mYRQgUmz9',
      );

      expect(profile.id, 'uprof_011CZkZCu8hGbp5mYRQgUmz9');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/user_profiles/uprof_011CZkZCu8hGbp5mYRQgUmz9',
      );
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'user-profiles-2026-03-24');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        UserProfilesFixtures.userProfile(externalId: 'user_new'),
      );

      final profile = await client.userProfiles.update(
        'uprof_011CZkZCu8hGbp5mYRQgUmz9',
        const UpdateUserProfileRequest(externalId: 'user_new'),
      );

      expect(profile.externalId, 'user_new');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/user_profiles/uprof_011CZkZCu8hGbp5mYRQgUmz9',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'user-profiles-2026-03-24');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['external_id'], 'user_new');
      expect(body.containsKey('metadata'), isFalse);
    });

    test('update with explicit null clears external_id', () async {
      mockHttpClient.queueJsonResponse(
        UserProfilesFixtures.userProfile(externalId: null),
      );

      await client.userProfiles.update(
        'uprof_011CZkZCu8hGbp5mYRQgUmz9',
        const UpdateUserProfileRequest(externalId: null),
      );

      final request = mockHttpClient.lastRequest!;
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body.containsKey('external_id'), isTrue);
      expect(body['external_id'], isNull);
    });

    test('update with no fields sends empty body', () async {
      mockHttpClient.queueJsonResponse(UserProfilesFixtures.userProfile());

      await client.userProfiles.update(
        'uprof_011CZkZCu8hGbp5mYRQgUmz9',
        const UpdateUserProfileRequest(),
      );

      final request = mockHttpClient.lastRequest!;
      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body, isEmpty);
    });

    test(
      'createEnrollmentUrl sends correct request and parses response',
      () async {
        mockHttpClient.queueJsonResponse(UserProfilesFixtures.enrollmentUrl());

        final enrollment = await client.userProfiles.createEnrollmentUrl(
          'uprof_011CZkZCu8hGbp5mYRQgUmz9',
        );

        expect(enrollment.type, 'enrollment_url');
        expect(enrollment.url, contains('platform.claude.com'));
        expect(enrollment.expiresAt, DateTime.utc(2026, 3, 15, 10, 15));

        final request = mockHttpClient.lastRequest!;
        expect(
          request.url.path,
          '/v1/user_profiles/uprof_011CZkZCu8hGbp5mYRQgUmz9/enrollment_url',
        );
        expect(request.method, 'POST');
        expect(request.headers['anthropic-beta'], 'user-profiles-2026-03-24');
      },
    );

    test(
      'trust_grants with unknown status round-trips as TrustGrantStatus.unknown',
      () async {
        mockHttpClient.queueJsonResponse(
          UserProfilesFixtures.userProfile(
            trustGrants: {
              'cyber': {'status': 'active'},
              'future_feature': {'status': 'new_experimental_status'},
            },
          ),
        );

        final profile = await client.userProfiles.retrieve('uprof_test');

        expect(profile.trustGrants['cyber']?.status, TrustGrantStatus.active);
        expect(
          profile.trustGrants['future_feature']?.status,
          TrustGrantStatus.unknown,
        );
      },
    );
  });
}
