/// Sentinel object used in copyWith methods to distinguish between
/// explicit null values and unset values.
const Object unsetCopyWithValue = _CopyWithSentinel();

class _CopyWithSentinel {
  const _CopyWithSentinel();
}
