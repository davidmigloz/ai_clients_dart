import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'register_vespa_schema_field_request.dart';

/// A Vespa schema definition to register within a search index (beta).
@immutable
class RegisterVespaSchemaRequest {
  /// The name of the schema.
  final String name;

  /// The fields defined within the schema.
  final List<RegisterVespaSchemaFieldRequest> fields;

  /// The raw Vespa schema definition (`.sd` file content).
  final String sd;

  /// Creates a [RegisterVespaSchemaRequest].
  const RegisterVespaSchemaRequest({
    required this.name,
    required this.fields,
    required this.sd,
  });

  /// Creates a [RegisterVespaSchemaRequest] from JSON.
  factory RegisterVespaSchemaRequest.fromJson(Map<String, dynamic> json) =>
      RegisterVespaSchemaRequest(
        name: json['name'] as String,
        fields: (json['fields'] as List<dynamic>)
            .map(
              (e) => RegisterVespaSchemaFieldRequest.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
        sd: json['sd'] as String,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'fields': fields.map((e) => e.toJson()).toList(),
    'sd': sd,
  };

  /// Creates a copy with the given fields replaced.
  RegisterVespaSchemaRequest copyWith({
    String? name,
    List<RegisterVespaSchemaFieldRequest>? fields,
    String? sd,
  }) => RegisterVespaSchemaRequest(
    name: name ?? this.name,
    fields: fields ?? this.fields,
    sd: sd ?? this.sd,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterVespaSchemaRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          listsEqual(fields, other.fields) &&
          sd == other.sd;

  @override
  int get hashCode => Object.hash(name, listHash(fields), sd);

  @override
  String toString() =>
      'RegisterVespaSchemaRequest('
      'name: $name, fields: ${fields.length} items, sd: $sd)';
}
