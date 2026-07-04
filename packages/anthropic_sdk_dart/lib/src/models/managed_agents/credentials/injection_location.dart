import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';

/// Where in an environment variable credential's outbound request the secret
/// value may be substituted (create/update params).
///
/// Each flag is optional; omit a flag to leave it at the server default.
@immutable
class InjectionLocation {
  /// Substitute when the placeholder appears in the request body.
  final bool? body;

  /// Substitute when the placeholder appears in a request header value.
  final bool? header;

  /// Creates an [InjectionLocation].
  const InjectionLocation({this.body, this.header});

  /// Creates an [InjectionLocation] from JSON.
  factory InjectionLocation.fromJson(Map<String, dynamic> json) {
    return InjectionLocation(
      body: json['body'] as bool?,
      header: json['header'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (body != null) 'body': body,
    if (header != null) 'header': header,
  };

  /// Creates a copy with replaced values.
  InjectionLocation copyWith({
    Object? body = unsetCopyWithValue,
    Object? header = unsetCopyWithValue,
  }) {
    return InjectionLocation(
      body: body == unsetCopyWithValue ? this.body : body as bool?,
      header: header == unsetCopyWithValue ? this.header : header as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectionLocation &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          header == other.header;

  @override
  int get hashCode => Object.hash(body, header);

  @override
  String toString() => 'InjectionLocation(body: $body, header: $header)';
}

/// Where in an environment variable credential's outbound request the secret
/// value is substituted (response).
///
/// Both flags are always present in responses.
@immutable
class InjectionLocationResponse {
  /// Whether the placeholder is substituted in the request body.
  final bool body;

  /// Whether the placeholder is substituted in request header values.
  final bool header;

  /// Creates an [InjectionLocationResponse].
  const InjectionLocationResponse({required this.body, required this.header});

  /// Creates an [InjectionLocationResponse] from JSON.
  factory InjectionLocationResponse.fromJson(Map<String, dynamic> json) {
    return InjectionLocationResponse(
      body: json['body'] as bool,
      header: json['header'] as bool,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'body': body, 'header': header};

  /// Creates a copy with replaced values.
  InjectionLocationResponse copyWith({bool? body, bool? header}) {
    return InjectionLocationResponse(
      body: body ?? this.body,
      header: header ?? this.header,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectionLocationResponse &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          header == other.header;

  @override
  int get hashCode => Object.hash(body, header);

  @override
  String toString() =>
      'InjectionLocationResponse(body: $body, header: $header)';
}
