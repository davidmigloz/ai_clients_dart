import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('TrustGrantStatus', () {
    test('round-trips known values', () {
      for (final status in const [
        TrustGrantStatus.active,
        TrustGrantStatus.pending,
        TrustGrantStatus.rejected,
      ]) {
        final parsed = TrustGrantStatus.fromJson(status.toJson());
        expect(parsed, status);
      }
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        TrustGrantStatus.fromJson('new_server_status'),
        TrustGrantStatus.unknown,
      );
    });
  });

  group('UserProfileListOrder', () {
    test('round-trips known values', () {
      expect(
        UserProfileListOrder.fromJson(UserProfileListOrder.asc.toJson()),
        UserProfileListOrder.asc,
      );
      expect(
        UserProfileListOrder.fromJson(UserProfileListOrder.desc.toJson()),
        UserProfileListOrder.desc,
      );
    });

    test('falls back to unknown for unrecognized values', () {
      expect(
        UserProfileListOrder.fromJson('random_order'),
        UserProfileListOrder.unknown,
      );
    });
  });

  group('UserProfileTrustGrant', () {
    test('round-trips all statuses', () {
      for (final status in TrustGrantStatus.values) {
        final grant = UserProfileTrustGrant(status: status);
        final parsed = UserProfileTrustGrant.fromJson(grant.toJson());
        expect(parsed, grant);
      }
    });

    test('equality and hashCode', () {
      const a = UserProfileTrustGrant(status: TrustGrantStatus.active);
      const b = UserProfileTrustGrant(status: TrustGrantStatus.active);
      const c = UserProfileTrustGrant(status: TrustGrantStatus.pending);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });

  group('EnrollmentUrl', () {
    test('round-trips JSON', () {
      final url = EnrollmentUrl(
        url: 'https://platform.claude.com/enroll/abc',
        expiresAt: DateTime.utc(2026, 3, 15, 10, 15),
      );

      final json = url.toJson();
      expect(json['type'], 'enrollment_url');
      expect(json['url'], 'https://platform.claude.com/enroll/abc');
      expect(json['expires_at'], '2026-03-15T10:15:00.000Z');

      final parsed = EnrollmentUrl.fromJson(json);
      expect(parsed, equals(url));
    });
  });

  group('UserProfile', () {
    Map<String, dynamic> profileJson({
      String? externalId = 'user_12345',
      Map<String, String>? metadata,
      Map<String, dynamic>? trustGrants,
    }) {
      return {
        'id': 'uprof_011CZkZCu8hGbp5mYRQgUmz9',
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

    test('round-trips with all fields populated', () {
      final json = profileJson(
        metadata: {'tier': 'pro', 'region': 'eu'},
        trustGrants: {
          'cyber': {'status': 'active'},
          'legal': {'status': 'pending'},
        },
      );
      final parsed = UserProfile.fromJson(json);

      expect(parsed.id, 'uprof_011CZkZCu8hGbp5mYRQgUmz9');
      expect(parsed.type, 'user_profile');
      expect(parsed.externalId, 'user_12345');
      expect(parsed.metadata, {'tier': 'pro', 'region': 'eu'});
      expect(parsed.trustGrants['cyber']?.status, TrustGrantStatus.active);
      expect(parsed.trustGrants['legal']?.status, TrustGrantStatus.pending);

      // Round-trip check: re-serialize and compare structurally.
      final reparsed = UserProfile.fromJson(parsed.toJson());
      expect(reparsed, equals(parsed));
    });

    test('round-trips with null external_id', () {
      final parsed = UserProfile.fromJson(profileJson(externalId: null));
      expect(parsed.externalId, isNull);

      final json = parsed.toJson();
      expect(json.containsKey('external_id'), isTrue);
      expect(json['external_id'], isNull);
    });

    test('metadata defaults to empty map when missing from JSON', () {
      final json = profileJson()..remove('metadata');
      final parsed = UserProfile.fromJson(json);
      expect(parsed.metadata, isEmpty);
      expect(parsed.toJson()['metadata'], <String, String>{});
    });

    test('accepts empty trust_grants', () {
      final parsed = UserProfile.fromJson(profileJson(trustGrants: {}));
      expect(parsed.trustGrants, isEmpty);

      final json = parsed.toJson();
      expect(json['trust_grants'], <String, dynamic>{});
    });

    test('equality uses content-based comparison for maps', () {
      final a = UserProfile.fromJson(profileJson(metadata: {'k': 'v'}));
      final b = UserProfile.fromJson(profileJson(metadata: {'k': 'v'}));
      final c = UserProfile.fromJson(profileJson(metadata: {'k': 'different'}));

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('copyWith clears externalId with explicit null', () {
      final original = UserProfile.fromJson(profileJson());
      final cleared = original.copyWith(externalId: null);

      expect(cleared.externalId, isNull);
      expect(cleared.id, original.id);
    });

    test('copyWith preserves externalId when omitted', () {
      final original = UserProfile.fromJson(profileJson());
      final copy = original.copyWith(type: 'user_profile');

      expect(copy.externalId, 'user_12345');
    });
  });

  group('CreateUserProfileRequest', () {
    test('omits null fields from JSON', () {
      const request = CreateUserProfileRequest();
      expect(request.toJson(), isEmpty);
    });

    test('round-trips with all fields', () {
      const request = CreateUserProfileRequest(
        externalId: 'user_12345',
        metadata: {'tier': 'pro'},
      );

      final json = request.toJson();
      expect(json, {
        'external_id': 'user_12345',
        'metadata': {'tier': 'pro'},
      });

      final parsed = CreateUserProfileRequest.fromJson(json);
      expect(parsed, equals(request));
    });

    test('copyWith clears externalId with explicit null', () {
      const request = CreateUserProfileRequest(externalId: 'user_12345');
      final cleared = request.copyWith(externalId: null);

      expect(cleared.externalId, isNull);
    });
  });

  group('UpdateUserProfileRequest', () {
    test('omits unset fields from JSON', () {
      const request = UpdateUserProfileRequest();
      expect(request.toJson(), isEmpty);
    });

    test('includes explicit null for externalId', () {
      const request = UpdateUserProfileRequest(externalId: null);
      final json = request.toJson();

      expect(json.containsKey('external_id'), isTrue);
      expect(json['external_id'], isNull);
    });

    test('distinguishes unset vs explicit null', () {
      const unset = UpdateUserProfileRequest();
      const explicitNull = UpdateUserProfileRequest(externalId: null);

      expect(unset.hasExternalId, isFalse);
      expect(explicitNull.hasExternalId, isTrue);
      expect(unset, isNot(equals(explicitNull)));
    });

    test('round-trips metadata patch', () {
      const request = UpdateUserProfileRequest(
        metadata: {'tier': 'enterprise', 'old_key': ''},
      );

      final json = request.toJson();
      expect(json['metadata'], {'tier': 'enterprise', 'old_key': ''});

      final parsed = UpdateUserProfileRequest.fromJson(json);
      expect(parsed, equals(request));
    });

    test('copyWith preserves sentinel semantics', () {
      const original = UpdateUserProfileRequest(externalId: 'user_1');
      final kept = original.copyWith();

      expect(kept.externalId, 'user_1');
      expect(kept.hasExternalId, isTrue);
    });

    test('rejects explicit null metadata (not nullable per spec)', () {
      expect(
        () => UpdateUserProfileRequest(metadata: null),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('ListUserProfilesResponse', () {
    test('round-trips with next_page', () {
      final json = {
        'data': [
          {
            'id': 'uprof_1',
            'type': 'user_profile',
            'external_id': null,
            'trust_grants': <String, dynamic>{},
            'created_at': '2026-03-15T10:00:00Z',
            'updated_at': '2026-03-15T10:00:00Z',
          },
        ],
        'next_page': 'page_abc',
      };

      final parsed = ListUserProfilesResponse.fromJson(json);
      expect(parsed.data, hasLength(1));
      expect(parsed.data.first.id, 'uprof_1');
      expect(parsed.nextPage, 'page_abc');

      final reparsed = ListUserProfilesResponse.fromJson(parsed.toJson());
      expect(reparsed, equals(parsed));
    });

    test('omits next_page when null', () {
      const response = ListUserProfilesResponse(data: []);
      final json = response.toJson();

      expect(json['data'], <Map<String, dynamic>>[]);
      expect(json.containsKey('next_page'), isFalse);
    });

    test('handles missing data array', () {
      final parsed = ListUserProfilesResponse.fromJson(
        const <String, dynamic>{},
      );
      expect(parsed.data, isEmpty);
      expect(parsed.nextPage, isNull);
    });
  });
}
