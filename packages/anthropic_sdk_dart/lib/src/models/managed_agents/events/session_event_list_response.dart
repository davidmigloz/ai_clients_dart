import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'session_event.dart';

/// Paginated list of session events.
@immutable
class ListSessionEventsResponse {
  /// Events for the session.
  final List<SessionEvent> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListSessionEventsResponse].
  const ListSessionEventsResponse({required this.data, this.nextPage});

  /// Creates a [ListSessionEventsResponse] from JSON.
  factory ListSessionEventsResponse.fromJson(Map<String, dynamic> json) {
    return ListSessionEventsResponse(
      data: (json['data'] as List)
          .map((e) => SessionEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  ListSessionEventsResponse copyWith({
    List<SessionEvent>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListSessionEventsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSessionEventsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListSessionEventsResponse(data: $data, nextPage: $nextPage)';
}

/// Response for sending events to a session.
@immutable
class SendSessionEventsResponse {
  /// Sent events echoed back.
  final List<Map<String, dynamic>> data;

  /// Creates a [SendSessionEventsResponse].
  const SendSessionEventsResponse({required this.data});

  /// Creates a [SendSessionEventsResponse] from JSON.
  factory SendSessionEventsResponse.fromJson(Map<String, dynamic> json) {
    return SendSessionEventsResponse(
      data: (json['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'data': data};

  /// Creates a copy with replaced values.
  SendSessionEventsResponse copyWith({List<Map<String, dynamic>>? data}) {
    return SendSessionEventsResponse(data: data ?? this.data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendSessionEventsResponse &&
          runtimeType == other.runtimeType &&
          listOfMapsDeepEqual(data, other.data);

  @override
  int get hashCode => listOfMapsHashCode(data);

  @override
  String toString() => 'SendSessionEventsResponse(data: $data)';
}
