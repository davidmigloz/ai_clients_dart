import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Sources that can contribute URLs to the Managed Agents web fetch tool.
@immutable
class ManagedWebFetchUrlSources {
  /// URLs from user input. Use all or none.
  final ManagedWebFetchUrlSourceFilter? userInput;

  /// URLs returned by custom tools configured on this agent.
  /// Only and except filters accept 1 to 128 unique tool names.
  final ManagedWebFetchUrlSourceFilter? clientToolResults;

  /// URLs returned by web search and web fetch.
  final ManagedWebFetchUrlSourceFilter? serverToolResults;

  final Map<String, Object?> _nullFields;

  /// Creates the URL source configuration.
  const ManagedWebFetchUrlSources({
    this.userInput,
    this.clientToolResults,
    this.serverToolResults,
  }) : _nullFields = const {};

  const ManagedWebFetchUrlSources._({
    required this.userInput,
    required this.clientToolResults,
    required this.serverToolResults,
    required this._nullFields,
  });

  /// Parses the URL source configuration.
  factory ManagedWebFetchUrlSources.fromJson(Map<String, dynamic> json) {
    final userInput = json['user_input'];
    final clientResults = json['client_tool_results'];
    final serverResults = json['server_tool_results'];
    return ManagedWebFetchUrlSources._(
      nullFields: Map.unmodifiable({
        for (final field in const [
          'user_input',
          'client_tool_results',
          'server_tool_results',
        ])
          if (json.containsKey(field) && json[field] == null) field: null,
      }),
      userInput: userInput == null
          ? null
          : ManagedWebFetchUrlSourceFilter.fromJson(userInput as Object),
      clientToolResults: clientResults == null
          ? null
          : ManagedWebFetchUrlSourceFilter.fromJson(clientResults as Object),
      serverToolResults: serverResults == null
          ? null
          : ManagedWebFetchUrlSourceFilter.fromJson(serverResults as Object),
    );
  }

  /// Converts to JSON and preserves explicitly null fields read from a response.
  Map<String, dynamic> toJson() => {
    ..._nullFields,
    'user_input': ?userInput?.toJson(),
    'client_tool_results': ?clientToolResults?.toJson(),
    'server_tool_results': ?serverToolResults?.toJson(),
  };

  /// Serializes the typed filters for a request, omitting unset sources.
  Map<String, dynamic> toRequestJson() {
    if (userInput?.type == 'none' &&
        clientToolResults?.type == 'none' &&
        serverToolResults?.type == 'none') {
      throw ArgumentError('At least one web fetch URL source must be enabled');
    }
    return {
      'user_input': ?userInput?._toRequestJson('user_input'),
      'client_tool_results': ?clientToolResults?._toRequestJson(
        'client_tool_results',
        allowToolFilter: true,
      ),
      'server_tool_results': ?serverToolResults?._toRequestJson(
        'server_tool_results',
        allowToolFilter: true,
        allowedNames: const {'web_search', 'web_fetch'},
      ),
    };
  }

  /// Creates a copy with replaced values.
  ManagedWebFetchUrlSources copyWith({
    Object? userInput = unsetCopyWithValue,
    Object? clientToolResults = unsetCopyWithValue,
    Object? serverToolResults = unsetCopyWithValue,
  }) => ManagedWebFetchUrlSources._(
    nullFields: Map.unmodifiable({
      for (final (key, value) in [
        ('user_input', userInput),
        ('client_tool_results', clientToolResults),
        ('server_tool_results', serverToolResults),
      ])
        if (value == null ||
            value == unsetCopyWithValue && _nullFields.containsKey(key))
          key: null,
    }),
    userInput: userInput == unsetCopyWithValue
        ? this.userInput
        : userInput as ManagedWebFetchUrlSourceFilter?,
    clientToolResults: clientToolResults == unsetCopyWithValue
        ? this.clientToolResults
        : clientToolResults as ManagedWebFetchUrlSourceFilter?,
    serverToolResults: serverToolResults == unsetCopyWithValue
        ? this.serverToolResults
        : serverToolResults as ManagedWebFetchUrlSourceFilter?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedWebFetchUrlSources &&
          userInput == other.userInput &&
          clientToolResults == other.clientToolResults &&
          serverToolResults == other.serverToolResults &&
          mapsDeepEqual(_nullFields, other._nullFields);

  @override
  int get hashCode => Object.hash(
    userInput,
    clientToolResults,
    serverToolResults,
    mapDeepHashCode(_nullFields),
  );

  @override
  String toString() =>
      'ManagedWebFetchUrlSources(userInput: $userInput, '
      'clientToolResults: $clientToolResults, serverToolResults: $serverToolResults)';
}

/// An allow or exclude filter for URLs from one source.
@immutable
final class ManagedWebFetchUrlSourceFilter {
  /// Wire type, including any future values.
  final String type;

  /// Tool names for only and except filters.
  final List<String>? tools;

  final bool _shorthand;
  final Map<String, dynamic>? _raw;

  /// Accepts URLs from the whole source. Use shorthand for request strings.
  const ManagedWebFetchUrlSourceFilter.all({this._shorthand = false})
    : type = 'all',
      tools = null,
      _raw = null;

  /// Excludes URLs from the whole source. Use shorthand for request strings.
  const ManagedWebFetchUrlSourceFilter.none({this._shorthand = false})
    : type = 'none',
      tools = null,
      _raw = null;

  /// Accepts only URLs returned by the named tools.
  const ManagedWebFetchUrlSourceFilter.only(List<String> this.tools)
    : type = 'only',
      _shorthand = false,
      _raw = null;

  /// Excludes URLs returned by the named tools.
  const ManagedWebFetchUrlSourceFilter.except(List<String> this.tools)
    : type = 'except',
      _shorthand = false,
      _raw = null;

  const ManagedWebFetchUrlSourceFilter._(
    this.type,
    this.tools,
    this._shorthand,
    this._raw,
  );

  /// Parses the shorthand string or typed object and preserves its shape.
  factory ManagedWebFetchUrlSourceFilter.fromJson(Object json) {
    if (json is String) {
      return ManagedWebFetchUrlSourceFilter._(json, null, true, null);
    }
    if (json case final Map<String, dynamic> map when map['type'] is String) {
      final type = map['type'] as String;
      final tools = map['tools'];
      if (type == 'only' || type == 'except') {
        if (tools is! List) {
          throw FormatException('URL source filter "$type" requires tools');
        }
        return ManagedWebFetchUrlSourceFilter._(
          type,
          List.unmodifiable(
            tools.map((Object? tool) {
              if (tool case {
                'type': 'tool_reference',
                'name': final String name,
              }) {
                return name;
              }
              throw const FormatException(
                'URL source filter requires tool references',
              );
            }),
          ),
          false,
          deepUnmodifiableMap(map),
        );
      }
      return ManagedWebFetchUrlSourceFilter._(
        type,
        null,
        false,
        deepUnmodifiableMap(map),
      );
    }
    throw const FormatException('Invalid web fetch URL source filter');
  }

  /// Converts to the original JSON shape.
  Object toJson() => _shorthand
      ? type
      : _raw ??
            {
              'type': type,
              if (tools case final names?)
                'tools': [
                  for (final name in names)
                    {'type': 'tool_reference', 'name': name},
                ],
            };

  Object _toRequestJson(
    String field, {
    bool allowToolFilter = false,
    Set<String>? allowedNames,
  }) {
    if (type == 'all' || type == 'none') {
      return _shorthand ? type : {'type': type};
    }
    if (!allowToolFilter || (type != 'only' && type != 'except')) {
      throw ArgumentError.value(type, field, 'Invalid URL source filter');
    }

    final names = tools;
    if (names == null ||
        names.isEmpty ||
        names.length > 128 ||
        names.toSet().length != names.length) {
      throw ArgumentError.value(
        names,
        field,
        'Expected 1 to 128 unique tool names',
      );
    }
    if (names.any(
      (name) =>
          name.isEmpty ||
          name.runes.length > 128 ||
          (allowedNames != null && !allowedNames.contains(name)),
    )) {
      throw ArgumentError.value(names, field, 'Invalid tool name');
    }

    return {
      'type': type,
      'tools': [
        for (final name in names) {'type': 'tool_reference', 'name': name},
      ],
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedWebFetchUrlSourceFilter &&
          mapsDeepEqual({'filter': toJson()}, {'filter': other.toJson()});

  @override
  int get hashCode => mapDeepHashCode({'filter': toJson()});

  @override
  String toString() =>
      'ManagedWebFetchUrlSourceFilter(type: $type, tools: $tools)';
}
