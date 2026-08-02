import 'package:meta/meta.dart';

/// Response returned when registering a RAG search index (beta).
@immutable
class RegisterSearchIndexResponse {
  /// The unique identifier of the newly registered search index.
  final String id;

  /// Creates a [RegisterSearchIndexResponse].
  const RegisterSearchIndexResponse({required this.id});

  /// Creates a [RegisterSearchIndexResponse] from JSON.
  factory RegisterSearchIndexResponse.fromJson(Map<String, dynamic> json) =>
      RegisterSearchIndexResponse(id: json['id'] as String);

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'id': id};

  /// Creates a copy with the given fields replaced.
  RegisterSearchIndexResponse copyWith({String? id}) =>
      RegisterSearchIndexResponse(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterSearchIndexResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RegisterSearchIndexResponse(id: $id)';
}
