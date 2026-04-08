import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/observability/campaign_preview.dart';
import '../../models/observability/campaign_previews.dart';
import '../../models/observability/campaign_selected_events.dart';
import '../../models/observability/campaign_status.dart';
import '../../models/observability/post_campaign_in_schema.dart';
import '../base_resource.dart';

/// Resource for observability campaign operations.
///
/// Campaigns evaluate chat completion events using a judge. They select
/// events based on search parameters and apply the judge to each event.
///
/// Example usage:
/// ```dart
/// // List campaigns
/// final campaigns = await client.observability.campaigns.list();
///
/// // Create a campaign
/// final campaign = await client.observability.campaigns.create(
///   request: PostCampaignInSchema(
///     name: 'Quality Review',
///     description: 'Review chat quality',
///     judgeId: 'judge-id',
///     maxNbEvents: 100,
///     searchParams: FilterPayload(),
///   ),
/// );
///
/// // Check status
/// final status = await client.observability.campaigns.getStatus(
///   campaignId: campaign.id,
/// );
/// ```
class CampaignsResource extends ResourceBase {
  /// Creates a [CampaignsResource].
  CampaignsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all campaigns.
  Future<CampaignPreviews> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/campaigns');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CampaignPreviews.fromJson(responseBody);
  }

  /// Creates a new campaign.
  Future<CampaignPreview> create({
    required PostCampaignInSchema request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/observability/campaigns');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CampaignPreview.fromJson(responseBody);
  }

  /// Gets a campaign by ID.
  Future<CampaignPreview> get({required String campaignId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/campaigns/$campaignId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CampaignPreview.fromJson(responseBody);
  }

  /// Deletes a campaign.
  Future<void> delete({required String campaignId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/campaigns/$campaignId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Gets the events selected by a campaign.
  Future<CampaignSelectedEvents> getSelectedEvents({
    required String campaignId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/campaigns/$campaignId/selected-events',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CampaignSelectedEvents.fromJson(responseBody);
  }

  /// Gets the status of a campaign.
  Future<CampaignStatus> getStatus({required String campaignId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/observability/campaigns/$campaignId/status',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return CampaignStatus.fromJson(responseBody);
  }
}
