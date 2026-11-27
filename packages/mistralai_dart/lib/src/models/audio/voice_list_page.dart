import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'voice_response.dart';

/// A cursor-paginated result from voice search.
@immutable
class VoiceListPage {
  /// The voices in this page.
  final List<VoiceResponse> data;

  /// The cursor for the next page, if there is one.
  final String? nextPageToken;

  /// Creates a [VoiceListPage].
  const VoiceListPage({required this.data, this.nextPageToken});

  /// Decodes a [VoiceListPage] from the API.
  factory VoiceListPage.fromJson(Map<String, dynamic> json) => VoiceListPage(
    data: (json['data'] as List)
        .map((item) => VoiceResponse.fromJson(item as Map<String, dynamic>))
        .toList(),
    nextPageToken: json['next_page_token'] as String?,
  );

  /// Encodes this page as JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replacement fields.
  VoiceListPage copyWith({
    List<VoiceResponse>? data,
    Object? nextPageToken = unsetCopyWithValue,
  }) => VoiceListPage(
    data: data ?? this.data,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceListPage &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hash(listHash(data), nextPageToken);

  @override
  String toString() =>
      'VoiceListPage(data: ${data.length} items, nextPageToken: $nextPageToken)';
}
