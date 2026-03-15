part of 'deltas.dart';

/// A File Search call delta update.
class FileSearchCallDelta extends InteractionDelta {
  @override
  String get type => 'file_search_call';

  /// A unique ID for this specific tool call.
  final String? id;

  /// Creates a [FileSearchCallDelta] instance.
  const FileSearchCallDelta({this.id});

  /// Creates a [FileSearchCallDelta] from JSON.
  factory FileSearchCallDelta.fromJson(Map<String, dynamic> json) =>
      FileSearchCallDelta(id: json['id'] as String?);

  @override
  Map<String, dynamic> toJson() => {'type': type, if (id != null) 'id': id};
}
