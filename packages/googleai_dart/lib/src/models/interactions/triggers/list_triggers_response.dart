part of 'triggers.dart';

/// Response message for `ListTriggers`.
class ListTriggersResponse {
  /// The list of triggers.
  final List<Trigger>? triggers;

  /// A page token, received from a previous `ListTriggers` call. Provide
  /// this to retrieve the subsequent page.
  final String? nextPageToken;

  /// Creates a [ListTriggersResponse].
  const ListTriggersResponse({this.triggers, this.nextPageToken});

  /// Creates a [ListTriggersResponse] from JSON.
  factory ListTriggersResponse.fromJson(Map<String, dynamic> json) =>
      ListTriggersResponse(
        triggers: (json['triggers'] as List<dynamic>?)
            ?.map((e) => Trigger.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (triggers != null) 'triggers': triggers!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  ListTriggersResponse copyWith({
    Object? triggers = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return ListTriggersResponse(
      triggers: triggers == unsetCopyWithValue
          ? this.triggers
          : triggers as List<Trigger>?,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }
}
