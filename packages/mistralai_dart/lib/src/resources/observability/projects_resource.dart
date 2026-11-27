import '../../models/observability/evaluation_projects.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Read projects and their evaluations.
class EvaluationProjectsResource extends ResourceBase {
  /// Creates an [EvaluationProjectsResource].
  EvaluationProjectsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists projects by name or slug.
  Future<EvaluationProjects> list({String? q, int? pageSize, int? page}) =>
      readObservability(
        'GET',
        'projects',
        EvaluationProjects.fromJson,
        query: {
          'q': ?q,
          if (pageSize != null) 'page_size': pageSize.toString(),
          if (page != null) 'page': page.toString(),
        },
      );

  /// Gets a project by slug.
  Future<EvaluationProject> get({required String projectSlug}) =>
      readObservability(
        'GET',
        'projects/${Uri.encodeComponent(projectSlug)}',
        EvaluationProject.fromJson,
      );

  /// Lists evaluations in a project.
  Future<ObservabilityEvaluations> listEvaluations({
    required String projectSlug,
    int? pageSize,
    int? page,
  }) => readObservability(
    'GET',
    'projects/${Uri.encodeComponent(projectSlug)}/evaluations_v2',
    ObservabilityEvaluations.fromJson,
    query: {
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
  );
}
