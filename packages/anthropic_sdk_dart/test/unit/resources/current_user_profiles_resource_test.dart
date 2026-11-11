import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';
import 'user_profiles_resource_test.dart' show UserProfilesFixtures;

const _id = 'uprof_test';
const _workspace = 'wrkspc_test';
const _profiles = '/v1/user_profiles';
const _legacyBeta = 'user-profiles-2026-08-18';

void main() {
  test(
    'GA filters the legacy profile selectors while retaining other betas',
    () async {
      final transport = MockHttpClient();
      final client = AnthropicClient(
        config: const AnthropicConfig(
          defaultHeaders: {
            'Anthropic-Beta':
                'feature-flag, user-profiles-2026-03-24,'
                ' user-profiles-2026-08-18, user-profiles-2026-09-04',
          },
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      transport
        ..queueJsonResponse({'data': <Object>[], 'next_page': null})
        ..queueJsonResponse(UserProfilesFixtures.enrollmentUrl());

      expect((await client.userProfiles.current.list()).data, isEmpty);
      final legacy = await client.userProfiles.createEnrollmentUrl(_id);

      expect(
        transport.requests.first.headers['anthropic-beta'],
        'feature-flag',
      );
      expect(transport.requests.last.headers['anthropic-beta'], _legacyBeta);
      expect((transport.requests.last as http.Request).body, isEmpty);
      expect(legacy.toString(), isNot(contains(legacy.url)));
    },
  );

  late MockHttpClient transport;
  late AnthropicClient client;
  late CurrentUserProfilesResource profiles;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    profiles = client.userProfiles.current;
    addTearDown(client.close);
  });

  void expectRequest(String method, String path, {Object? body}) {
    final request = transport.lastRequest! as http.Request;
    expect(request.method, method);
    expect(request.url.path, path);
    expect(request.headers['anthropic-workspace-id'], _workspace);
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['x-api-key'], 'test-key');
    expect(request.headers, isNot(contains('anthropic-beta')));
    expect(request.headers, isNot(contains('anthropic-user-profile-id')));
    expect(request.body.isEmpty ? null : jsonDecode(request.body), body);
  }

  test('creates a GA profile with nested details and no beta header', () async {
    final json = _profile();
    transport.queueJsonResponse(json);

    final profile = await profiles.create(
      const CreateCurrentUserProfileRequest(
        name: 'Example company',
        accessType: UserProfileAccessType.passthrough,
        externalUserDetails: UserProfileExternalUserDetails(
          referenceId: 'account_123',
          country: 'US',
        ),
        metadata: {'plan': 'pro'},
      ),
      workspaceId: _workspace,
    );

    expectRequest(
      'POST',
      _profiles,
      body: {
        'name': 'Example company',
        'access_type': 'passthrough',
        'external_user_details': {
          'reference_id': 'account_123',
          'country': 'US',
        },
        'metadata': {'plan': 'pro'},
      },
    );
    expect(profile.id, _id);
    expect(profile.enforcementStatus, UserProfileEnforcementStatus.restricted);
    expect(profile.externalUserDetails.referenceId, 'account_123');
    expect(profile.programs.cyber?.tiers['research']?.status, 'active');
    expect(profile.programs.cyber?.requirements?.humanReview, isFalse);
    expect(profile.programs.efs?.features['storage']?.status, 'inactive');
    expect(profile.toJson(), json);
  });

  test('lists with repeated status filters and advances the cursor', () async {
    transport
      ..queueJsonResponse({
        'data': [_profile()],
        'next_page': 'next cursor',
      })
      ..queueJsonResponse({
        'data': [_profile(id: 'uprof_2')],
        'next_page': null,
      });
    const statuses = [
      UserProfileEnforcementStatus.restricted,
      UserProfileEnforcementStatus.banned,
    ];

    final first = await profiles.list(
      limit: 1,
      enforcementStatuses: statuses,
      order: UserProfileListOrder.desc,
      orderBy: UserProfileListOrderBy.name,
      workspaceId: _workspace,
    );
    expect(first.data.single.id, _id);
    expect(first.nextPage, 'next cursor');
    expectRequest('GET', _profiles);
    expect(transport.lastRequest!.url.queryParametersAll, {
      'limit': ['1'],
      'enforcement_status[]': ['restricted', 'banned'],
      'order': ['desc'],
      'order_by': ['name'],
    });

    final last = await profiles.list(
      limit: 1,
      page: first.nextPage,
      enforcementStatuses: statuses,
      order: UserProfileListOrder.desc,
      orderBy: UserProfileListOrderBy.name,
      workspaceId: _workspace,
    );
    expect(last.data.single.id, 'uprof_2');
    expect(last.nextPage, isNull);
    expect(last.toJson()['next_page'], isNull);
    expectRequest('GET', _profiles);
    expect(transport.lastRequest!.url.queryParametersAll, {
      'limit': ['1'],
      'page': ['next cursor'],
      'enforcement_status[]': ['restricted', 'banned'],
      'order': ['desc'],
      'order_by': ['name'],
    });
  });

  test('retrieves GA profile by a single escaped ID segment', () async {
    transport.queueJsonResponse(_profile());

    final profile = await profiles.retrieve(
      'uprof_id/with?characters',
      workspaceId: _workspace,
    );

    expect(profile.id, _id);
    expectRequest('GET', '$_profiles/uprof_id%2Fwith%3Fcharacters');
    expect(
      transport.lastRequest!.url.pathSegments.last,
      'uprof_id/with?characters',
    );
  });

  test('updates only supplied fields and keeps explicit clears', () async {
    transport.queueJsonResponse(_profile());

    final profile = await profiles.update(
      _id,
      const UpdateCurrentUserProfileRequest(
        name: null,
        accessType: null,
        externalUserDetails: UserProfileExternalUserDetails(country: 'DE'),
        metadata: {'remove': ''},
      ),
      workspaceId: _workspace,
    );

    expect(profile.id, _id);
    expectRequest(
      'POST',
      '$_profiles/$_id',
      body: {
        'name': null,
        'access_type': null,
        'external_user_details': {'country': 'DE'},
        'metadata': {'remove': ''},
      },
    );
  });

  test('deletes by ID without a body', () async {
    transport.queueJsonResponse({'type': 'user_profile_deleted', 'id': _id});

    final deleted = await profiles.delete(_id, workspaceId: _workspace);

    expect(deleted.id, _id);
    expect(deleted.type, 'user_profile_deleted');
    expectRequest('DELETE', '$_profiles/$_id');
  });

  test(
    'creates an action URL with the required action discriminator',
    () async {
      transport.queueJsonResponse(_actionUrl);

      final action = await profiles.createActionUrl(
        _id,
        action: UserProfileAction.enrollEndUser,
        workspaceId: _workspace,
      );

      expectRequest(
        'POST',
        '$_profiles/$_id/action_urls',
        body: {
          'action': {'type': 'enroll_end_user'},
        },
      );
      expect(action.url, _actionUrl['url']);
      expect(action.expiresAt, DateTime.utc(2026, 11, 11, 21, 15));
      expect(action.toString(), isNot(contains(action.url)));
    },
  );

  test('keeps all legacy routes under the existing beta header', () async {
    final legacy = client.userProfiles;
    final data = UserProfilesFixtures.userProfile(id: _id);
    transport
      ..queueJsonResponse(data)
      ..queueJsonResponse({
        'data': [data],
        'next_page': null,
      })
      ..queueJsonResponse(data)
      ..queueJsonResponse(data)
      ..queueJsonResponse(UserProfilesFixtures.enrollmentUrl())
      ..queueJsonResponse({'type': 'user_profile_deleted', 'id': _id})
      ..queueJsonResponse(_actionUrl);

    await legacy.create(
      const CreateUserProfileRequest(externalId: 'old-id'),
      workspaceId: _workspace,
    );
    await legacy.list(workspaceId: _workspace);
    await legacy.retrieve(_id, workspaceId: _workspace);
    await legacy.update(
      _id,
      const UpdateUserProfileRequest(externalId: null),
      workspaceId: _workspace,
    );
    await legacy.createEnrollmentUrl(_id, workspaceId: _workspace);
    await legacy.delete(_id, workspaceId: _workspace);
    await legacy.createActionUrl(
      _id,
      action: UserProfileAction.enrollEndUser,
      workspaceId: _workspace,
    );

    expect(transport.requests.map((r) => '${r.method} ${r.url.path}'), [
      'POST $_profiles',
      'GET $_profiles',
      'GET $_profiles/$_id',
      'POST $_profiles/$_id',
      'POST $_profiles/$_id/enrollment_url',
      'DELETE $_profiles/$_id',
      'POST $_profiles/$_id/action_urls',
    ]);
    for (final request in transport.requests) {
      expect(request.headers['anthropic-beta'], _legacyBeta);
      expect(request.headers['anthropic-workspace-id'], _workspace);
    }
    final bodies = transport.requests
        .cast<http.Request>()
        .map((r) => r.body.isEmpty ? null : jsonDecode(r.body))
        .toList();
    expect(bodies, [
      {'external_id': 'old-id'},
      null,
      null,
      {'external_id': null},
      null,
      null,
      {
        'action': {'type': 'enroll_end_user'},
      },
    ]);
  });

  test(
    'rejects missing IDs and unknown write filters before sending',
    () async {
      await expectLater(profiles.delete(''), throwsArgumentError);
      await expectLater(profiles.retrieve('..'), throwsArgumentError);
      await expectLater(
        profiles.list(
          enforcementStatuses: [UserProfileEnforcementStatus.unknown],
        ),
        throwsArgumentError,
      );
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'preserves error status and request ID for rejected profile access',
    () async {
      transport.queueJsonResponse(
        {
          'type': 'error',
          'error': {
            'type': 'permission_error',
            'message': 'Insufficient access',
          },
        },
        statusCode: 403,
        headers: {'request-id': 'req_profile'},
      );
      await expectLater(
        profiles.retrieve(_id),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having((error) => error.requestId, 'requestId', 'req_profile'),
        ),
      );
    },
  );

  test('preserves nullable enforcement fields and future variants', () {
    final data = _profile()
      ..['enforcement_status'] = 'quarantined'
      ..['enforcement_actions'] = [
        {
          'type': 'restriction',
          'id': 'act_1',
          'reason': 'future_reason',
          'action': null,
          'opened_at': '2026-11-11T21:00:00.000Z',
          'expires_at': null,
        },
        {
          'type': 'future_action',
          'context': {
            'reasons': ['one', 'two'],
          },
        },
      ];

    final profile = CurrentUserProfile.fromJson(data);
    expect(profile.enforcementStatus, UserProfileEnforcementStatus.unknown);
    final action =
        profile.enforcementActions!.first as UserProfilePolicyEnforcementAction;
    expect(action.action, isNull);
    expect(action.expiresAt, isNull);
    expect(action.reason, 'future_reason');
    expect(
      profile.enforcementActions!.last,
      isA<UnknownUserProfileEnforcementAction>(),
    );
    expect(profile.toJson(), data);
    expect(profile, CurrentUserProfile.fromJson(data));
    expect(profile.hashCode, CurrentUserProfile.fromJson(data).hashCode);
    expect(
      profile.copyWith(enforcementStatusValue: null).enforcementStatus,
      isNull,
    );

    data
      ..remove('enforcement_status')
      ..remove('enforcement_actions');
    final prior = CurrentUserProfile.fromJson(data);
    expect(prior.enforcementStatus, isNull);
    expect(prior.enforcementActions, isNull);
    expect(prior.toJson(), data);
  });

  test('GA request codecs distinguish absent from explicit null', () {
    final empty = UpdateCurrentUserProfileRequest.fromJson(const {});
    final clear = UpdateCurrentUserProfileRequest.fromJson(const {
      'name': null,
    });
    expect(empty.toJson(), <String, dynamic>{});
    expect(clear.toJson(), {'name': null});
    expect(empty, isNot(clear));
    expect(clear.copyWith(), clear);
    expect(clear.copyWith().hashCode, clear.hashCode);
    expect(
      () => UpdateCurrentUserProfileRequest.fromJson(const {
        'external_user_details': {'reference_id': null},
      }),
      throwsFormatException,
    );
    expect(
      () => CreateCurrentUserProfileRequest.fromJson(const {'metadata': null}),
      throwsFormatException,
    );
    expect(
      CreateCurrentUserProfileRequest.fromJson(const {
        'external_user_details': {'reference_id': null, 'country': 'US'},
      }).toJson(),
      {
        'external_user_details': {'country': 'US'},
      },
    );
    expect(
      () => CreateCurrentUserProfileRequest.fromJson(const {
        'external_user_details': {'onboarded_at': null},
      }),
      throwsFormatException,
    );
  });
}

const _actionUrl = {
  'type': 'user_profile_action_url',
  'url': 'https://platform.claude.com/user-profiles/enrollment/test-secret',
  'expires_at': '2026-11-11T21:15:00.000Z',
};

Map<String, dynamic> _profile({String id = _id}) => {
  'id': id,
  'type': 'user_profile',
  'name': null,
  'access_type': 'application',
  'external_user_details': {
    'reference_id': 'account_123',
    'onboarded_at': null,
    'account_status': null,
    'entity_type': null,
    'country': 'US',
    'name_hash': null,
    'email_hash': null,
  },
  'enforcement_status': 'restricted',
  'enforcement_actions': [
    {
      'type': 'restriction',
      'id': 'act_1',
      'reason': 'unsupported_region',
      'action': 'verify',
      'opened_at': '2026-11-11T21:00:00.000Z',
      'expires_at': '2026-11-12T21:00:00.000Z',
    },
  ],
  'programs': {
    'cyber': {
      'status': 'active',
      'tiers': {
        'research': {'status': 'active'},
      },
      'requirements': {'data_retention': true, 'human_review': false},
    },
    'efs': {
      'status': 'pending',
      'features': {
        'storage': {'status': 'inactive'},
      },
    },
  },
  'metadata': <String, String>{},
  'created_at': '2026-11-11T21:00:00.000Z',
  'updated_at': '2026-11-11T21:01:00.000Z',
};
