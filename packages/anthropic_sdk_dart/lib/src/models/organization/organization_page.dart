import 'package:meta/meta.dart';

import '../../utils/organization_parsing.dart';
import '../common/equality_helpers.dart';

/// A before/after-ID page returned by the Admin API.
@immutable
final class OrganizationPage<T> {
  /// The entries on this page.
  final List<T> data;

  /// Whether more results follow this page.
  final bool hasMore;

  /// The first entry ID, usable as the preceding page cursor.
  final String? firstId;

  /// The last entry ID, usable as the next page cursor.
  final String? lastId;

  /// Creates a page from a response and its entry decoder.
  OrganizationPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decode,
  ) : data = List.unmodifiable(
        (json['data'] as List? ??
                (throw const FormatException('Admin page: missing data')))
            .map((entry) => decode(entry as Map<String, dynamic>)),
      ),
      hasMore =
          json['has_more'] as bool? ??
          (throw const FormatException('Admin page: missing has_more')),
      firstId = json['first_id'] as String?,
      lastId = json['last_id'] as String?;

  /// Converts the page and its entries to JSON.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) encode) => {
    'data': data.map(encode).toList(),
    'has_more': hasMore,
    'first_id': firstId,
    'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationPage<T> &&
          other.runtimeType == runtimeType &&
          listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode => Object.hash(listHash(data), hasMore, firstId, lastId);

  @override
  String toString() =>
      'OrganizationPage(count: ${data.length}, '
      'hasMore: $hasMore, firstId: $firstId, lastId: $lastId)';
}

/// An opaque-cursor page returned by the Admin API.
@immutable
final class OrganizationCursorPage<T> {
  /// Parses a page and its records.
  OrganizationCursorPage.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) decode, {
    bool requireHasMore = false,
  }) : data = List.unmodifiable(
         requiredOrganizationField<List<Object?>>(
           json,
           'data',
           'Admin page',
         ).map((entry) => decode(entry! as Map<String, dynamic>)),
       ),
       _serverHasMore = requireHasMore || json.containsKey('has_more')
           ? requiredOrganizationField<bool>(json, 'has_more', 'Admin page')
           : null,
       nextPage = switch (requiredOrganizationField<String?>(
         json,
         'next_page',
         'Admin page',
       )) {
         '' => null,
         final cursor => cursor,
       } {
    if (hasMore && nextPage?.isNotEmpty != true) {
      throw const FormatException('Missing Admin continuation token');
    }
  }

  /// Records returned on this page.
  final List<T> data;

  /// Cursor for the next page, or null when exhausted.
  final String? nextPage;

  final bool? _serverHasMore;

  /// Whether the provider has another page.
  bool get hasMore => _serverHasMore ?? nextPage != null;

  /// Converts the page and its entries to JSON.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) encode) => {
    'data': data.map(encode).toList(),
    'next_page': nextPage,
    'has_more': ?_serverHasMore,
  };

  @override
  bool operator ==(Object other) =>
      other is OrganizationCursorPage<T> &&
      other.runtimeType == runtimeType &&
      listsEqual(data, other.data) &&
      nextPage == other.nextPage &&
      _serverHasMore == other._serverHasMore;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage, _serverHasMore);
}
