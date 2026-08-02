part of 'environments.dart';

/// Response for `ListEnvironments`.
class ListEnvironmentsResponse {
  /// Environments belonging to the provided project.
  final List<Environment>? environments;

  /// Pagination token.
  final String? nextPageToken;

  /// Creates a [ListEnvironmentsResponse].
  const ListEnvironmentsResponse({this.environments, this.nextPageToken});

  /// Creates a [ListEnvironmentsResponse] from JSON.
  factory ListEnvironmentsResponse.fromJson(Map<String, dynamic> json) =>
      ListEnvironmentsResponse(
        environments: (json['environments'] as List<dynamic>?)
            ?.map((e) => Environment.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (environments != null)
      'environments': environments!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  ListEnvironmentsResponse copyWith({
    Object? environments = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return ListEnvironmentsResponse(
      environments: environments == unsetCopyWithValue
          ? this.environments
          : environments as List<Environment>?,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }
}
