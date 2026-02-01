# openai_dart rewrite – tenth review report

This pass focuses on the updated streaming cleanup logic. One remaining issue was found.

---

## Medium

### 1) Streaming `onError` does not cancel the underlying subscription ✅ Fixed
**File**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
In the abort‑enabled stream wrapper, `onError` closes the client and controller, but it does **not** cancel the underlying subscription. If the source stream emits an error and then continues emitting data (allowed when `cancelOnError: false`), the listener may attempt to push into a closed controller, causing secondary errors and potential unhandled exceptions.

**Fix Applied**
Added `unawaited(subscription.cancel())` in the `onError` handler before closing the controller:

```dart
subscription = response.stream.listen(
  controller.add,
  onError: (Object e, StackTrace st) {
    closeClientOnce();
    controller.addError(e, st);
    unawaited(subscription.cancel());
    closeController();
  },
  onDone: () {
    closeClientOnce();
    closeController();
  },
  cancelOnError: false,
);
```

**Test Added**
- Added `onError cancels subscription to prevent post-error data delivery` test that verifies:
  1. When source stream emits an error then continues emitting data
  2. The subscription is cancelled in onError
  3. No data is received after the error
  4. The wrapped stream completes cleanly

---

# Summary

All actionable items have been addressed:
1. ✅ Cancel the underlying subscription on `onError` to prevent post‑error data delivery into a closed controller.
