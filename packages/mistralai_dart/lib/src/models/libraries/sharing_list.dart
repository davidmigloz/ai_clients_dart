import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'sharing_response.dart';

/// List of library sharing entries.
@immutable
class SharingList {
  /// The list of sharing entries.
  final List<SharingResponse> data;

  /// Creates [SharingList].
  const SharingList({required this.data});

  /// Creates from JSON.
  factory SharingList.fromJson(Map<String, dynamic> json) => SharingList(
    data: (json['data'] as List)
        .map((e) => SharingResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharingList &&
          runtimeType == other.runtimeType &&
          listEquals(data, other.data);

  @override
  int get hashCode => Object.hashAll(data);

  @override
  String toString() => 'SharingList(data: ${data.length} entries)';
}
