import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tool_change_reference.dart' show ToolChangeToolReference;

/// Whether the Messages web fetch tool can fetch URLs from user input.
enum WebFetchUrlSourcePolicy {
  /// Accept URLs from user input.
  all,

  /// Ignore URLs from user input.
  none;

  /// Parses a tagged Messages URL source policy.
  factory WebFetchUrlSourcePolicy.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'all' => all,
        'none' => none,
        _ => throw const FormatException('Invalid web fetch user input policy'),
      };

  /// Converts this policy to its tagged wire object.
  Map<String, dynamic> toJson() => {'type': name};
}

/// Which Messages tool results may contribute URLs to web fetch.
@immutable
final class WebFetchUrlToolFilter {
  /// Accept URLs from every supported tool in this source.
  const WebFetchUrlToolFilter.all() : type = 'all', tools = const [];

  /// Ignore URLs from every tool in this source.
  const WebFetchUrlToolFilter.none() : type = 'none', tools = const [];

  /// Accept URLs from only the named tools.
  WebFetchUrlToolFilter.only(List<String> tools) : this._('only', tools);

  /// Ignore URLs from the named tools and accept results from the rest.
  WebFetchUrlToolFilter.except(List<String> tools) : this._('except', tools);

  WebFetchUrlToolFilter._(this.type, List<String> names)
    : tools = List.unmodifiable(names);

  /// Parses a tagged Messages tool filter.
  factory WebFetchUrlToolFilter.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type == 'all') return const WebFetchUrlToolFilter.all();
    if (type == 'none') return const WebFetchUrlToolFilter.none();
    if (type is String && (type == 'only' || type == 'except')) {
      final references = json['tools'];
      if (references is List<Object?>) {
        final names = references.map((reference) {
          if (reference case {
            'type': 'tool_reference',
            'name': final String name,
          }) {
            return name;
          }
          throw const FormatException(
            'Expected a named web fetch tool reference',
          );
        }).toList();
        return WebFetchUrlToolFilter._(type, names);
      }
    }
    throw const FormatException('Invalid web fetch tool filter');
  }

  /// The wire discriminator.
  final String type;

  /// Tool names included or excluded by this filter.
  final List<String> tools;

  /// Converts this filter to the tagged Messages wire object.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (type == 'only' || type == 'except')
      'tools': [
        for (final tool in tools) ToolChangeToolReference(tool).toJson(),
      ],
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchUrlToolFilter &&
          type == other.type &&
          listsEqual(tools, other.tools);

  @override
  int get hashCode => Object.hash(type, listHash(tools));

  @override
  String toString() => 'WebFetchUrlToolFilter(type: $type, tools: $tools)';
}

/// Sources that contribute URLs to the Messages web fetch tool.
///
/// Omitted sources default to allowing all supported results. Filter names
/// must refer to tools declared in the same Messages request. Only web search
/// and web fetch can contribute URLs from server tool results.
@immutable
final class WebFetchUrlSources {
  /// Creates source policies for a Messages web fetch tool.
  const WebFetchUrlSources({
    this.userInput,
    this.clientToolResults,
    this.serverToolResults,
  });

  /// Parses the tagged Messages source configuration.
  factory WebFetchUrlSources.fromJson(Map<String, dynamic> json) =>
      WebFetchUrlSources(
        userInput: _parseSource(
          json,
          'user_input',
          WebFetchUrlSourcePolicy.fromJson,
        ),
        clientToolResults: _parseSource(
          json,
          'client_tool_results',
          WebFetchUrlToolFilter.fromJson,
        ),
        serverToolResults: _parseSource(
          json,
          'server_tool_results',
          WebFetchUrlToolFilter.fromJson,
        ),
      );

  /// Policy for URLs in user messages.
  final WebFetchUrlSourcePolicy? userInput;

  /// Filter for URLs in client tool results.
  final WebFetchUrlToolFilter? clientToolResults;

  /// Filter for URLs from web search and web fetch results.
  final WebFetchUrlToolFilter? serverToolResults;

  /// Converts the configuration to Messages wire format.
  Map<String, dynamic> toJson() {
    if (serverToolResults?.tools.any(
          (name) => name != 'web_search' && name != 'web_fetch',
        ) ??
        false) {
      throw ArgumentError(
        'Server URL source filters can name web_search and web_fetch',
      );
    }
    return {
      'user_input': ?userInput?.toJson(),
      'client_tool_results': ?clientToolResults?.toJson(),
      'server_tool_results': ?serverToolResults?.toJson(),
    };
  }

  /// Copies the configuration. Explicit null restores the default for a source.
  WebFetchUrlSources copyWith({
    Object? userInput = unsetCopyWithValue,
    Object? clientToolResults = unsetCopyWithValue,
    Object? serverToolResults = unsetCopyWithValue,
  }) => WebFetchUrlSources(
    userInput: userInput == unsetCopyWithValue
        ? this.userInput
        : userInput as WebFetchUrlSourcePolicy?,
    clientToolResults: clientToolResults == unsetCopyWithValue
        ? this.clientToolResults
        : clientToolResults as WebFetchUrlToolFilter?,
    serverToolResults: serverToolResults == unsetCopyWithValue
        ? this.serverToolResults
        : serverToolResults as WebFetchUrlToolFilter?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebFetchUrlSources &&
          userInput == other.userInput &&
          clientToolResults == other.clientToolResults &&
          serverToolResults == other.serverToolResults;

  @override
  int get hashCode =>
      Object.hash(userInput, clientToolResults, serverToolResults);

  @override
  String toString() =>
      'WebFetchUrlSources(userInput: $userInput, '
      'clientToolResults: $clientToolResults, serverToolResults: $serverToolResults)';
}

T? _parseSource<T>(
  Map<String, dynamic> json,
  String field,
  T Function(Map<String, dynamic>) decode,
) {
  if (!json.containsKey(field)) return null;
  final source = json[field];
  if (source is Map<String, dynamic>) return decode(source);
  throw FormatException('Expected a tagged object for $field');
}
