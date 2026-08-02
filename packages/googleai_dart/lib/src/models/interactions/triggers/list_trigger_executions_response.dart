part of 'triggers.dart';

/// Response message for `ListTriggerExecutions`.
class ListTriggerExecutionsResponse {
  /// The list of trigger executions.
  final List<TriggerExecution>? triggerExecutions;

  /// A page token, received from a previous `ListTriggerExecutions` call.
  /// Provide this to retrieve the subsequent page.
  final String? nextPageToken;

  /// Creates a [ListTriggerExecutionsResponse].
  const ListTriggerExecutionsResponse({
    this.triggerExecutions,
    this.nextPageToken,
  });

  /// Creates a [ListTriggerExecutionsResponse] from JSON.
  factory ListTriggerExecutionsResponse.fromJson(Map<String, dynamic> json) =>
      ListTriggerExecutionsResponse(
        triggerExecutions: (json['trigger_executions'] as List<dynamic>?)
            ?.map((e) => TriggerExecution.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (triggerExecutions != null)
      'trigger_executions': triggerExecutions!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  ListTriggerExecutionsResponse copyWith({
    Object? triggerExecutions = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return ListTriggerExecutionsResponse(
      triggerExecutions: triggerExecutions == unsetCopyWithValue
          ? this.triggerExecutions
          : triggerExecutions as List<TriggerExecution>?,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }
}
