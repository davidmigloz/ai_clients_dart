import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../common/json_helpers.dart';

/// Domain filters for GA web search.
///
/// The guide permits up to 100 domains in each list and requires domain names
/// without a URL scheme. Allow and block lists can coexist. [blockedDomains]
/// follows the guide and is not yet present in the canonical OpenAPI schema.
@immutable
class WebSearchFilters {
  /// Creates filters, taking immutable snapshots of supplied domain lists.
  WebSearchFilters({List<String>? allowedDomains, List<String>? blockedDomains})
    : allowedDomains = allowedDomains == null
          ? null
          : List.unmodifiable(allowedDomains),
      blockedDomains = blockedDomains == null
          ? null
          : List.unmodifiable(blockedDomains);

  /// Parses filters, normalizing optional nullable lists to omission.
  factory WebSearchFilters.fromJson(Map<String, dynamic> json) =>
      WebSearchFilters(
        allowedDomains: _readDomains(json, 'allowed_domains'),
        blockedDomains: _readDomains(json, 'blocked_domains'),
      );

  /// Domains to restrict results to. An empty list is preserved.
  final List<String>? allowedDomains;

  /// Domains to exclude, as documented by the web-search guide.
  final List<String>? blockedDomains;

  /// Converts to JSON without adding defaults.
  Map<String, dynamic> toJson() => {
    if (allowedDomains != null) 'allowed_domains': allowedDomains,
    if (blockedDomains != null) 'blocked_domains': blockedDomains,
  };

  /// Creates a copy, with explicit null clearing a domain list.
  WebSearchFilters copyWith({
    Object? allowedDomains = unsetCopyWithValue,
    Object? blockedDomains = unsetCopyWithValue,
  }) => WebSearchFilters(
    allowedDomains: identical(allowedDomains, unsetCopyWithValue)
        ? this.allowedDomains
        : allowedDomains as List<String>?,
    blockedDomains: identical(blockedDomains, unsetCopyWithValue)
        ? this.blockedDomains
        : blockedDomains as List<String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSearchFilters &&
          runtimeType == other.runtimeType &&
          listsEqual(allowedDomains, other.allowedDomains) &&
          listsEqual(blockedDomains, other.blockedDomains);

  @override
  int get hashCode =>
      Object.hash(listHash(allowedDomains), listHash(blockedDomains));

  @override
  String toString() =>
      'WebSearchFilters('
      'allowedDomains: ${allowedDomains == null ? 'null' : '${allowedDomains!.length} items'}, '
      'blockedDomains: ${blockedDomains == null ? 'null' : '${blockedDomains!.length} items'})';

  static List<String>? _readDomains(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! List) {
      throw FormatException('WebSearchFilters.$key: expected an array');
    }
    return [
      for (var i = 0; i < value.length; i++)
        requireJsonString(value[i], 'WebSearchFilters.$key[$i]'),
    ];
  }
}
