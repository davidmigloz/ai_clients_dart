import '../../models/observability/online_scorers.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Manage versioned online evaluation scorers.
class ScorersResource extends ResourceBase {
  /// Creates an [ScorersResource].
  ScorersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists observability scorers.
  Future<ListScorersResponse> list({
    bool? createdByMe,
    bool? ootb,
    String? q,
    int? pageSize,
    int? page,
  }) => readObservability(
    'GET',
    'scorers',
    ListScorersResponse.fromJson,
    query: {
      if (createdByMe != null) 'created_by_me': createdByMe.toString(),
      if (ootb != null) 'ootb': ootb.toString(),
      'q': ?q,
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
  );

  /// Creates a scorer with its initial configuration.
  Future<Scorer> create({required CreateScorerRequest request}) =>
      readObservability(
        'POST',
        'scorers',
        Scorer.fromJson,
        body: request.toJson(),
      );

  /// Gets a scorer, including its latest version.
  Future<Scorer> get({required String scorerSlug}) => readObservability(
    'GET',
    'scorers/${Uri.encodeComponent(scorerSlug)}',
    Scorer.fromJson,
  );

  /// Updates a scorer. A new configuration creates a version.
  Future<Scorer> update({
    required String scorerSlug,
    required EditScorerRequest request,
  }) => readObservability(
    'PATCH',
    'scorers/${Uri.encodeComponent(scorerSlug)}',
    Scorer.fromJson,
    body: request.toJson(),
  );
}
