import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The ConnectorOpenApiSpec wire payload.
@immutable
class ConnectorOpenApiSpec {
  /// Creates a [ConnectorOpenApiSpec].
  const ConnectorOpenApiSpec({required this.source});

  /// Where the spec came from. Null when unknown, e.g. a file uploaded without a name, or hidden, e.g. on Mistral connectors.
  final ConnectorOpenApiSource? source;

  /// Parses a [ConnectorOpenApiSpec] from JSON.
  factory ConnectorOpenApiSpec.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('source')) {
      throw const FormatException('ConnectorOpenApiSpec: missing source');
    }
    return ConnectorOpenApiSpec(
      source: json['source'] == null
          ? null
          : ConnectorOpenApiSource.fromJson(
              json['source'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'source': source?.toJson()};

  /// Creates a copy with the given fields replaced.
  ConnectorOpenApiSpec copyWith({Object? source = unsetCopyWithValue}) =>
      ConnectorOpenApiSpec(
        source: source == unsetCopyWithValue
            ? this.source
            : source as ConnectorOpenApiSource?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOpenApiSpec &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => Object.hashAll([source]);

  @override
  String toString() =>
      'ConnectorOpenApiSpec('
      'source: $source)';
}

/// A variant of [ConnectorOpenApiSource] used for a connector.
sealed class ConnectorOpenApiSource {
  const ConnectorOpenApiSource();

  /// Decodes a variant from its API representation.
  factory ConnectorOpenApiSource.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'file' => ConnectorOpenApiFileSource.fromJson(json),
        'url' => ConnectorOpenApiUrlSource.fromJson(json),
        _ => UnknownConnectorOpenApiSource(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [ConnectorOpenApiSource] unknown to this client.
@immutable
final class UnknownConnectorOpenApiSource extends ConnectorOpenApiSource {
  /// Retains the original payload.
  UnknownConnectorOpenApiSource(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownConnectorOpenApiSource && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The OpenApiFileSource wire payload.
@immutable
final class ConnectorOpenApiFileSource extends ConnectorOpenApiSource {
  /// Creates a [ConnectorOpenApiFileSource].
  const ConnectorOpenApiFileSource({required this.filename});

  /// The fixed type discriminator.
  String get type => 'file';

  /// The name of the uploaded file.
  final String filename;

  /// Parses a [ConnectorOpenApiFileSource] from JSON.
  factory ConnectorOpenApiFileSource.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'file') {
      throw FormatException(
        'ConnectorOpenApiFileSource: unexpected type $value',
      );
    }
    if (json['filename'] == null) {
      throw const FormatException(
        'ConnectorOpenApiFileSource: missing filename',
      );
    }
    return ConnectorOpenApiFileSource(filename: json['filename'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'filename': filename};

  /// Creates a copy with the given fields replaced.
  ConnectorOpenApiFileSource copyWith({String? filename}) =>
      ConnectorOpenApiFileSource(filename: filename ?? this.filename);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOpenApiFileSource &&
          runtimeType == other.runtimeType &&
          filename == other.filename;

  @override
  int get hashCode => Object.hashAll([filename]);

  @override
  String toString() =>
      'ConnectorOpenApiFileSource('
      'filename: $filename)';
}

/// The OpenApiUrlSource wire payload.
@immutable
final class ConnectorOpenApiUrlSource extends ConnectorOpenApiSource {
  /// Creates a [ConnectorOpenApiUrlSource].
  const ConnectorOpenApiUrlSource({required this.url});

  /// The fixed type discriminator.
  String get type => 'url';

  /// The URL the spec was downloaded from, without its userinfo, query string and fragment.
  final String url;

  /// Parses a [ConnectorOpenApiUrlSource] from JSON.
  factory ConnectorOpenApiUrlSource.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'url') {
      throw FormatException(
        'ConnectorOpenApiUrlSource: unexpected type $value',
      );
    }
    if (json['url'] == null) {
      throw const FormatException('ConnectorOpenApiUrlSource: missing url');
    }
    return ConnectorOpenApiUrlSource(url: json['url'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'url': url};

  /// Creates a copy with the given fields replaced.
  ConnectorOpenApiUrlSource copyWith({String? url}) =>
      ConnectorOpenApiUrlSource(url: url ?? this.url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorOpenApiUrlSource &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => Object.hashAll([url]);

  @override
  String toString() =>
      'ConnectorOpenApiUrlSource('
      'url: $url)';
}

/// Values for ConnectorErrorCode.
enum ConnectorErrorCode {
  /// Represents connectors_count_limit_reached.
  connectorsCountLimitReached('connectors_count_limit_reached'),

  /// Represents credentials_rejected.
  credentialsRejected('credentials_rejected'),

  /// Represents server_unreachable.
  serverUnreachable('server_unreachable'),

  /// Represents custom_connectors_disabled.
  customConnectorsDisabled('custom_connectors_disabled'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ConnectorErrorCode(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ConnectorErrorCode fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The ConnectorErrorResponse wire payload.
@immutable
class ConnectorErrorResponse {
  /// Creates a [ConnectorErrorResponse].
  const ConnectorErrorResponse({this.code, required this.detail});

  /// The code field.
  final ConnectorErrorCode? code;

  /// The detail field.
  final String detail;

  /// Parses a [ConnectorErrorResponse] from JSON.
  factory ConnectorErrorResponse.fromJson(Map<String, dynamic> json) {
    if (json['detail'] == null) {
      throw const FormatException('ConnectorErrorResponse: missing detail');
    }
    return ConnectorErrorResponse(
      code: json['code'] == null
          ? null
          : ConnectorErrorCode.fromJson(json['code'] as String),
      detail: json['detail'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code!.toJson(),
    'detail': detail,
  };

  /// Creates a copy with the given fields replaced.
  ConnectorErrorResponse copyWith({
    Object? code = unsetCopyWithValue,
    String? detail,
  }) => ConnectorErrorResponse(
    code: code == unsetCopyWithValue ? this.code : code as ConnectorErrorCode?,
    detail: detail ?? this.detail,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectorErrorResponse &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          detail == other.detail;

  @override
  int get hashCode => Object.hashAll([code, detail]);

  @override
  String toString() =>
      'ConnectorErrorResponse('
      'code: $code, '
      'detail: $detail)';
}
