/// Sentinel value used to distinguish between "not set" and "set to null".
///
/// In copyWith methods, we need to differentiate between:
/// - Caller wants to keep the existing value (parameter not passed)
/// - Caller explicitly wants to set the value to null
///
/// This sentinel value allows us to make this distinction.
///
/// ## Example
///
/// ```dart
/// class MyClass {
///   final String? name;
///
///   MyClass copyWith({Object? name = unsetCopyWithValue}) {
///     return MyClass(
///       name: name == unsetCopyWithValue
///           ? this.name
///           : name as String?,
///     );
///   }
/// }
///
/// // Keep existing value
/// obj.copyWith();
///
/// // Set to null explicitly
/// obj.copyWith(name: null);
///
/// // Set to new value
/// obj.copyWith(name: 'new name');
/// ```
const Object unsetCopyWithValue = _UnsetCopyWithSentinel();

/// Private sentinel class.
class _UnsetCopyWithSentinel {
  const _UnsetCopyWithSentinel();
}
