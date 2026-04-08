import 'package:meta/meta.dart';

/// A group of fields in the chat completion field definitions.
@immutable
class FieldGroup {
  /// The name of the group.
  final String name;

  /// The display label of the group.
  final String label;

  /// Creates a [FieldGroup].
  const FieldGroup({required this.name, required this.label});

  /// Creates a [FieldGroup] from JSON.
  factory FieldGroup.fromJson(Map<String, dynamic> json) => FieldGroup(
    name: json['name'] as String? ?? '',
    label: json['label'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'name': name, 'label': label};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FieldGroup) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && label == other.label;
  }

  @override
  int get hashCode => Object.hash(name, label);

  @override
  String toString() => 'FieldGroup(name: $name, label: $label)';
}
