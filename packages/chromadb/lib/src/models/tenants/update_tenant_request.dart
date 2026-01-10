import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';

/// Request to update a tenant.
@immutable
class UpdateTenantRequest {
  /// The new name for the tenant.
  final String? newName;

  /// Creates an update tenant request.
  const UpdateTenantRequest({this.newName});

  /// Converts this request to JSON.
  Map<String, dynamic> toJson() {
    return {if (newName != null) 'new_name': newName};
  }

  /// Creates a copy with replaced values.
  UpdateTenantRequest copyWith({Object? newName = unsetCopyWithValue}) {
    return UpdateTenantRequest(
      newName: newName == unsetCopyWithValue
          ? this.newName
          : newName as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateTenantRequest &&
          runtimeType == other.runtimeType &&
          newName == other.newName;

  @override
  int get hashCode => newName.hashCode;

  @override
  String toString() => 'UpdateTenantRequest(newName: $newName)';
}
