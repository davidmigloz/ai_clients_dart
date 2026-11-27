import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _adminKey = 'admin-usage-fixture-key';

MistralAdminClient _client(http.Client transport) {
  final client = MistralAdminClient.withApiKey(
    _adminKey,
    httpClient: transport,
  );
  addTearDown(client.close);
  addTearDown(transport.close);
  return client;
}

void main() {
  group('Admin usage and analytics wire contract', () {
    test('GET /v1/admin/api-keys', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/api-keys',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'limit': ['2'],
            'offset': ['2'],
            'name': ['fixture'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"keys":[{"actions":{"delete":{"status":"available"},"rotate":{"status":"unavailable","reason":"key_expired"}},"can_delete":null,"created_at":null,"created_by":null,"expiration_date":null,"hidden_key":"fixture","key":null,"key_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","last_used":null,"name":null,"product":null,"workspace_id":null,"workspace_name":null}]}''',
            200,
          );
        }),
      );
      final result = await client.apiKeys.list(
        limit: 2,
        offset: 2,
        name: 'fixture',
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"keys":[{"actions":{"delete":{"status":"available"},"rotate":{"status":"unavailable","reason":"key_expired"}},"can_delete":null,"created_at":null,"created_by":null,"expiration_date":null,"hidden_key":"fixture","key":null,"key_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","last_used":null,"name":null,"product":null,"workspace_id":null,"workspace_name":null}]}''',
        ),
      );
    });

    test('POST /v1/admin/api-keys', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/api-keys',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''{"user_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","workspace_uuid":"8c3d5182-3612-4fbe-b23b-61e0361d679c"}''',
            ),
          );
          return http.Response(
            r'''{"actions":{"delete":{"status":"available"},"rotate":{"status":"unavailable","reason":"key_expired"}},"created_at":null,"expiration_date":null,"hidden_key":"fixture","key":"key-material-shown-once","key_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","name":null}''',
            200,
          );
        }),
      );
      final result = await client.apiKeys.create(
        request: CreateAdminApiKeyRequest.fromJson(
          jsonDecode(
                r'''{"user_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","workspace_uuid":"8c3d5182-3612-4fbe-b23b-61e0361d679c"}''',
              )
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"actions":{"delete":{"status":"available"},"rotate":{"status":"unavailable","reason":"key_expired"}},"created_at":null,"expiration_date":null,"hidden_key":"fixture","key":"key-material-shown-once","key_id":"8c3d5182-3612-4fbe-b23b-61e0361d679c","name":null}''',
        ),
      );
      expect(result.key, 'key-material-shown-once');
      expect(result.toString(), isNot(contains(result.key)));
      expect(result.actions.delete, isA<AdminApiKeyActionAvailable>());
      expect(
        (result.actions.rotate! as AdminApiKeyActionUnavailable).knownReason,
        AdminApiKeyUnavailableReason.keyExpired,
      );
    });

    test('DELETE /v1/admin/api-keys/{key_id}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/api-keys/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(r'''{"detail":"fixture"}''', 200);
        }),
      );
      final result = await client.apiKeys.delete(keyId: 'fixture / id');
      expect(result.toJson(), jsonDecode(r'''{"detail":"fixture"}'''));
    });

    test('GET /v1/admin/audit-logs', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/audit-logs',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'actor_type': ['HUMAN', 'API_KEY'],
            'event_type': ['user.create', 'user.delete'],
            'target_type': ['USER', 'USER_GROUP'],
            'actor_user_uuid': ['fixture'],
            'sort': ['ascending'],
            'after': ['2026-11-27T13:00:00.123Z'],
            'before': ['2026-11-27T13:00:00.123Z'],
            'limit': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''[{"actor_metadata":{},"actor_type":"HUMAN","created_at":"2026-11-27T13:00:00.123Z","event_metadata":{},"event_type":"user.create","log_id":2,"target_metadata":{},"target_type":"USER"}]''',
            200,
          );
        }),
      );
      final result = await client.auditLogs.list(
        actorType: [AdminAuditActorType.human, AdminAuditActorType.apiKey],
        eventType: [
          AdminAuditEventType.userCreate,
          AdminAuditEventType.userDelete,
        ],
        targetType: [AdminAuditTargetType.user, AdminAuditTargetType.userGroup],
        actorUserUuid: 'fixture',
        sort: AdminAuditLogSort.ascending,
        after: '2026-11-27T13:00:00.123Z',
        before: '2026-11-27T13:00:00.123Z',
        limit: 2,
      );
      expect(
        result.map((item) => item.toJson()).toList(),
        jsonDecode(
          r'''[{"actor_metadata":{},"actor_type":"HUMAN","created_at":"2026-11-27T13:00:00.123Z","event_metadata":{},"event_type":"user.create","log_id":2,"target_metadata":{},"target_type":"USER"}]''',
        ),
      );
    });

    test('GET /v1/admin/usage', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/usage',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'month': ['fixture'],
            'year': ['fixture'],
            'workspace_id': ['8c3d5182-3612-4fbe-b23b-61e0361d679c'],
            'api_zone': ['global'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"audio":{"models":{}},"audio_agents":{"models":{}},"audio_characters":{"models":{}},"chat":{"models":{}},"completion":{"models":{}},"connectors":{"models":{}},"currency":null,"currency_symbol":null,"date":"2026-11-27T13:00:00.123Z","end_date":"2026-11-27T13:00:00.123Z","fine_tuning":{"storage":{},"training":{}},"libraries_api":{"audio_seconds":{"models":{}},"pages":{"models":{}},"tokens":{"models":{}}},"next_month":null,"ocr":{"models":{}},"previous_month":null,"prices":[{"api_zone":"eu","billing_group":"chat","billing_metric":"input_tokens","event_type":"api_tokens","price":2.5,"service_tier":"standard"},{"api_zone":"eu","billing_group":"chat","billing_metric":"input_tokens","event_type":"api_tokens","price":"2.500000001","service_tier":"standard"}],"start_date":"2026-11-27T13:00:00.123Z","vibe_code":{"audio":{"models":{}},"audio_characters":{"models":{}},"completion":{"models":{}},"connectors":{"models":{}},"ocr":{"models":{}}},"vibe_usage":2.5}''',
            200,
          );
        }),
      );
      final result = await client.usage.getMonthly(
        month: 'fixture',
        year: 'fixture',
        workspaceId: '8c3d5182-3612-4fbe-b23b-61e0361d679c',
        apiZone: AdminApiZone.global,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"audio":{"models":{}},"audio_agents":{"models":{}},"audio_characters":{"models":{}},"chat":{"models":{}},"completion":{"models":{}},"connectors":{"models":{}},"currency":null,"currency_symbol":null,"date":"2026-11-27T13:00:00.123Z","end_date":"2026-11-27T13:00:00.123Z","fine_tuning":{"storage":{},"training":{}},"libraries_api":{"audio_seconds":{"models":{}},"pages":{"models":{}},"tokens":{"models":{}}},"next_month":null,"ocr":{"models":{}},"previous_month":null,"prices":[{"api_zone":"eu","billing_group":"chat","billing_metric":"input_tokens","event_type":"api_tokens","price":2.5,"service_tier":"standard"},{"api_zone":"eu","billing_group":"chat","billing_metric":"input_tokens","event_type":"api_tokens","price":"2.500000001","service_tier":"standard"}],"start_date":"2026-11-27T13:00:00.123Z","vibe_code":{"audio":{"models":{}},"audio_characters":{"models":{}},"completion":{"models":{}},"connectors":{"models":{}},"ocr":{"models":{}}},"vibe_usage":2.5}''',
        ),
      );
      expect(result.prices!.map((item) => item.price), [
        const AdminNumericPrice(2.5),
        const AdminDecimalPrice('2.500000001'),
      ]);
    });

    test('POST /v1/admin/usage/query', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/usage/query',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''{"end":"2026-11-27T13:00:00.123Z","start":"2026-11-27T13:00:00.123Z","filters":[{"field":"billing_metric","operator":"is","values":["mistral-large-latest",null]}],"workspace_ids":[null,"8c3d5182-3612-4fbe-b23b-61e0361d679c"],"limit":42,"offset":3,"group_by":["workspace_id"],"include_aggregates":true}''',
            ),
          );
          return http.Response(
            r'''{"groups":[{}],"metadata":{"has_more":true,"query_params":{"end":"2026-11-27T13:00:00.123Z","start":"2026-11-27T13:00:00.123Z"}}}''',
            200,
          );
        }),
      );
      final result = await client.usage.query(
        request: AdminUsageQuery.fromJson(
          jsonDecode(
                r'''{"end":"2026-11-27T13:00:00.123Z","start":"2026-11-27T13:00:00.123Z","filters":[{"field":"billing_metric","operator":"is","values":["mistral-large-latest",null]}],"workspace_ids":[null,"8c3d5182-3612-4fbe-b23b-61e0361d679c"],"limit":42,"offset":3,"group_by":["workspace_id"],"include_aggregates":true}''',
              )
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"groups":[{}],"metadata":{"has_more":true,"query_params":{"end":"2026-11-27T13:00:00.123Z","start":"2026-11-27T13:00:00.123Z"}}}''',
        ),
      );
      expect(result.metadata.hasMore, isTrue);
      expect(result.metadata.queryParams.start, '2026-11-27T13:00:00.123Z');
    });

    test('GET /v1/admin/rate-limit', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/rate-limit',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"requests_per_second":2,"tokens_limits_by_model":{"mistral-small-latest":{"tokens_per_minute":2,"tokens_per_month":2}}}''',
            200,
          );
        }),
      );
      final result = await client.usage.getRateLimits();
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"requests_per_second":2,"tokens_limits_by_model":{"mistral-small-latest":{"tokens_per_minute":2,"tokens_per_month":2}}}''',
        ),
      );
    });

    test('GET /v1/admin/spend-limit', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/spend-limit',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"limits":{"completion":{"monthly_limit_reached":true},"currency":"fixture","last_payment_failure":true,"last_payment_failure_protection":null}}''',
            200,
          );
        }),
      );
      final result = await client.usage.getSpendLimits();
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"limits":{"completion":{"monthly_limit_reached":true},"currency":"fixture","last_payment_failure":true,"last_payment_failure_protection":null}}''',
        ),
      );
    });

    test('POST /v1/admin/spend-limit', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/spend-limit',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(jsonDecode(request.body), jsonDecode(r'''{"amount":2}'''));
          return http.Response(
            r'''{"limits":{"completion":{"monthly_limit_reached":true},"currency":"fixture","last_payment_failure":true,"last_payment_failure_protection":null}}''',
            200,
          );
        }),
      );
      final result = await client.usage.updateSpendLimit(
        request: UpdateAdminSpendLimitRequest.fromJson(
          jsonDecode(r'''{"amount":2}''') as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"limits":{"completion":{"monthly_limit_reached":true},"currency":"fixture","last_payment_failure":true,"last_payment_failure_protection":null}}''',
        ),
      );
    });

    test('GET /v1/admin/analytics/vibe/code/usage/by_organization', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/analytics/vibe/code/usage/by_organization',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'start_time': ['2'],
            'end_time': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"end_time":2,"next_edit_active_users":[{"day":"2026-11-27","nb_active_users":2}],"next_edit_modified_loc":[{"day":"2026-11-27","lines_deleted":2,"lines_inserted":2,"lines_total":2,"lines_unchanged":2}],"next_edit_suggestions":[{"day":"2026-11-27","force_generated_false":2,"force_generated_true":2,"outcome_aborted":2,"outcome_accepted":2,"outcome_dismissed":2,"outcome_rejected":2,"outcome_timeout":2,"surface_ghost_text":2,"surface_widget":2,"total_suggestions":2}],"start_time":2}''',
            200,
          );
        }),
      );
      final result = await client.vibeAnalytics.getCodeByOrganization(
        startTime: 2,
        endTime: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"end_time":2,"next_edit_active_users":[{"day":"2026-11-27","nb_active_users":2}],"next_edit_modified_loc":[{"day":"2026-11-27","lines_deleted":2,"lines_inserted":2,"lines_total":2,"lines_unchanged":2}],"next_edit_suggestions":[{"day":"2026-11-27","force_generated_false":2,"force_generated_true":2,"outcome_aborted":2,"outcome_accepted":2,"outcome_dismissed":2,"outcome_rejected":2,"outcome_timeout":2,"surface_ghost_text":2,"surface_widget":2,"total_suggestions":2}],"start_time":2}''',
        ),
      );
    });

    test('GET /v1/admin/analytics/vibe/code/usage/by_workspace', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/analytics/vibe/code/usage/by_workspace',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'start_time': ['2'],
            'end_time': ['2'],
            'workspace_id': ['fixture'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"active_users":[{"day":"2026-11-27","nb_active_users_acp":2,"nb_active_users_cli":2,"nb_active_users_programmatic":2,"nb_active_users_total":2}],"consumed_tokens":[{"cached_tokens":2,"day":"2026-11-27","input_tokens":2,"model":"fixture","output_tokens":2}],"end_time":2,"session_durations":[{"day":"2026-11-27","total_duration_hours":2.5}],"sessions":[{"day":"2026-11-27","nb_sessions":2,"nb_sessions_acp":2,"nb_sessions_cli":2,"nb_sessions_programmatic":2}],"start_time":2,"tool_calls":[{"approval_always":2,"approval_ask":2,"approval_never":2,"day":"2026-11-27","status_failure":2,"status_skipped":2,"status_success":2,"total":2}],"tool_calls_by_name":[{"count":2,"day":"2026-11-27","tool_name":"fixture"}],"user_prompts":[{"day":"2026-11-27","nb_prompts_acp":2,"nb_prompts_cli":2,"nb_prompts_programmatic":2,"nb_prompts_total":2}]}''',
            200,
          );
        }),
      );
      final result = await client.vibeAnalytics.getCodeByWorkspace(
        startTime: 2,
        endTime: 2,
        workspaceId: 'fixture',
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"active_users":[{"day":"2026-11-27","nb_active_users_acp":2,"nb_active_users_cli":2,"nb_active_users_programmatic":2,"nb_active_users_total":2}],"consumed_tokens":[{"cached_tokens":2,"day":"2026-11-27","input_tokens":2,"model":"fixture","output_tokens":2}],"end_time":2,"session_durations":[{"day":"2026-11-27","total_duration_hours":2.5}],"sessions":[{"day":"2026-11-27","nb_sessions":2,"nb_sessions_acp":2,"nb_sessions_cli":2,"nb_sessions_programmatic":2}],"start_time":2,"tool_calls":[{"approval_always":2,"approval_ask":2,"approval_never":2,"day":"2026-11-27","status_failure":2,"status_skipped":2,"status_success":2,"total":2}],"tool_calls_by_name":[{"count":2,"day":"2026-11-27","tool_name":"fixture"}],"user_prompts":[{"day":"2026-11-27","nb_prompts_acp":2,"nb_prompts_cli":2,"nb_prompts_programmatic":2,"nb_prompts_total":2}]}''',
        ),
      );
    });

    test('GET /v1/admin/analytics/vibe/work/usage/by_agent_stats', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/analytics/vibe/work/usage/by_agent_stats',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'start_time': ['2'],
            'end_time': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"data":[{"agent_id":"fixture","files_count":2,"images_count":2,"last_message_at":"2026-11-27T13:00:00.123Z","messages_count":2,"spreadsheets_count":2,"unique_conversations_count":2,"unique_users_count":2}],"end_time":2,"start_time":2}''',
            200,
          );
        }),
      );
      final result = await client.vibeAnalytics.getWorkByAgent(
        startTime: 2,
        endTime: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"data":[{"agent_id":"fixture","files_count":2,"images_count":2,"last_message_at":"2026-11-27T13:00:00.123Z","messages_count":2,"spreadsheets_count":2,"unique_conversations_count":2,"unique_users_count":2}],"end_time":2,"start_time":2}''',
        ),
      );
    });

    test('GET /v1/admin/analytics/vibe/work/usage/by_time_stats', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/analytics/vibe/work/usage/by_time_stats',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'start_time': ['2'],
            'end_time': ['2'],
            'granularity': ['hour'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"data":[{"files_count":2,"images_count":2,"messages_count":2,"messages_to_agents_count":2,"spreadsheets_count":2,"time_bucket":null,"unique_agents_count":2,"unique_conversations_count":2,"unique_users_count":2}],"end_time":2,"start_time":2}''',
            200,
          );
        }),
      );
      final result = await client.vibeAnalytics.getWorkByTime(
        startTime: 2,
        endTime: 2,
        granularity: VibeUsageGranularity.hour,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"data":[{"files_count":2,"images_count":2,"messages_count":2,"messages_to_agents_count":2,"spreadsheets_count":2,"time_bucket":null,"unique_agents_count":2,"unique_conversations_count":2,"unique_users_count":2}],"end_time":2,"start_time":2}''',
        ),
      );
    });

    test('GET /v1/admin/analytics/vibe/work/usage/by_user_stats', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/analytics/vibe/work/usage/by_user_stats',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'start_time': ['2'],
            'end_time': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"data":[{"files_count":2,"images_count":2,"last_message_at":"2026-11-27T13:00:00.123Z","messages_count":2,"messages_to_agents_count":2,"spreadsheets_count":2,"unique_agents_count":2,"unique_conversations_count":2,"user_id":"fixture"}],"end_time":2,"start_time":2}''',
            200,
          );
        }),
      );
      final result = await client.vibeAnalytics.getWorkByUser(
        startTime: 2,
        endTime: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"data":[{"files_count":2,"images_count":2,"last_message_at":"2026-11-27T13:00:00.123Z","messages_count":2,"messages_to_agents_count":2,"spreadsheets_count":2,"unique_agents_count":2,"unique_conversations_count":2,"user_id":"fixture"}],"end_time":2,"start_time":2}''',
        ),
      );
    });
  });
}
