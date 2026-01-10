/// Sentinel value used in `copyWith` methods to distinguish between
/// explicitly setting a nullable field to `null` versus leaving it unchanged.
///
/// Example usage:
/// ```dart
/// User copyWith({Object? name = unsetCopyWithValue}) {
///   return User(
///     name: name == unsetCopyWithValue ? this.name : name as String?,
///   );
/// }
/// ```
const Object unsetCopyWithValue = Object();
