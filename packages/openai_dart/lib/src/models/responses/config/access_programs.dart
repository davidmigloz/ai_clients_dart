import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/json_helpers.dart';
import 'cyber_access_program.dart';

/// Optional access-program selection for a response request.
///
/// Omitting the selection or supplying an empty object lets the server choose
/// using model eligibility and organization or project authorization. Explicit
/// selection does not grant access. A supplied `cyber` value must be nonnull
/// and recognized; unrecognized values throw [FormatException] when parsed.
@immutable
class AccessProgramsParam {
  /// The requested cyber access program, or `null` for server selection.
  ///
  /// When absent, this key is omitted from JSON. This differs from explicitly
  /// selecting [CyberAccessProgram.standard].
  final CyberAccessProgram? cyber;

  /// Creates a request selection, including the valid empty-object selection.
  const AccessProgramsParam({this.cyber});

  /// Creates an [AccessProgramsParam] from JSON.
  factory AccessProgramsParam.fromJson(Map<String, dynamic> json) {
    if (json.keys.any((key) => key != 'cyber')) {
      throw const FormatException(
        'AccessProgramsParam: unrecognized access-program field',
      );
    }
    return AccessProgramsParam(
      cyber: json.containsKey('cyber')
          ? _parseCyber(json['cyber'], 'AccessProgramsParam.cyber')
          : null,
    );
  }

  /// Converts to JSON, omitting an absent cyber selection.
  Map<String, dynamic> toJson() => {
    if (cyber != null) 'cyber': cyber!.toJson(),
  };

  /// Creates a copy, retaining an omitted value and clearing explicit `null`.
  AccessProgramsParam copyWith({Object? cyber = unsetCopyWithValue}) =>
      AccessProgramsParam(
        cyber: identical(cyber, unsetCopyWithValue)
            ? this.cyber
            : cyber as CyberAccessProgram?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessProgramsParam &&
          runtimeType == other.runtimeType &&
          cyber == other.cyber;

  @override
  int get hashCode => Object.hash(runtimeType, cyber);

  @override
  String toString() => 'AccessProgramsParam(cyber: $cyber)';
}

/// The effective access programs returned by the Responses API.
///
/// A supplied response object must contain a nonnull, recognized [cyber]
/// value. Unrecognized values throw [FormatException] when parsed, without
/// being silently converted to a different program.
@immutable
class AccessProgramsBody {
  /// The effective cyber access program selected by the server.
  final CyberAccessProgram cyber;

  /// Creates an effective access-program result.
  const AccessProgramsBody({required this.cyber});

  /// Creates an [AccessProgramsBody] from JSON.
  factory AccessProgramsBody.fromJson(Map<String, dynamic> json) =>
      AccessProgramsBody(
        cyber: _parseCyber(json['cyber'], 'AccessProgramsBody.cyber'),
      );

  /// Converts to JSON, always including the effective cyber selection.
  Map<String, dynamic> toJson() => {'cyber': cyber.toJson()};

  /// Creates a copy with a replaced cyber selection.
  AccessProgramsBody copyWith({CyberAccessProgram? cyber}) =>
      AccessProgramsBody(cyber: cyber ?? this.cyber);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessProgramsBody &&
          runtimeType == other.runtimeType &&
          cyber == other.cyber;

  @override
  int get hashCode => Object.hash(runtimeType, cyber);

  @override
  String toString() => 'AccessProgramsBody(cyber: $cyber)';
}

CyberAccessProgram _parseCyber(Object? value, String field) {
  final raw = requireJsonString(value, field);
  final program = CyberAccessProgram.fromJson(raw);
  if (program == null) {
    throw FormatException('$field: unrecognized cyber access program');
  }
  return program;
}
