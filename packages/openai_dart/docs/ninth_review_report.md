# openai_dart rewrite – deeper follow‑up review

This is another in‑depth pass focused on subtle streaming lifecycle issues and resource cleanup.

---

## High

### 1) Streaming controller is not closed on cancel/error ✅ FIXED
**File**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
In `sendStream()`, the `StreamController` created for abort‑enabled streams is never closed in `onCancel`, and it is not closed in `onError`. If the source stream errors without closing, or the consumer cancels early, the controller remains open and can retain resources.

**Fix applied**
Added a `controllerClosed` flag and `closeController()` helper to ensure the controller is closed exactly once in all cleanup paths (`onError`, `onDone`, and `onCancel`):

```dart
var controllerClosed = false;

void closeController() {
  if (!controllerClosed) {
    controllerClosed = true;
    unawaited(controller.close());
  }
}

subscription = response.stream.listen(
  controller.add,
  onError: (Object e, StackTrace st) {
    closeClientOnce();
    controller.addError(e, st);
    closeController();
  },
  onDone: () {
    closeClientOnce();
    closeController();
  },
  cancelOnError: false,
);

controller.onCancel = () async {
  closeClientOnce();
  await subscription.cancel();
  closeController();
};
```

**Test added**
- `test/unit/client/streaming_abort_test.dart` - Added `wrapped stream closes on source error without onDone` test that simulates a source stream that errors **without** closing and asserts the wrapped stream completes (receives `onDone`) and the client is closed.

---

## Medium

### 2) Streaming cancel test doesn't validate controller close ✅ FIXED
**File**
- `packages/openai_dart/test/unit/client/streaming_abort_test.dart`

**Issue**
The current cancel test asserts the client closes but doesn't verify that the wrapped stream completes/terminates. This can hide leaks where the controller stays open.

**Fix applied**
- Enhanced the `streaming client closes on early subscription cancellation` test to track `wrappedStreamDone` via an `onDone` callback
- Added the new `wrapped stream closes on source error without onDone` test that explicitly verifies the wrapped stream receives `onDone` after a source error (using a timeout to catch failures)

---

# Summary

All items fixed:
1. ✅ Close the streaming controller on cancel and on error (with idempotent guard)
2. ✅ Strengthen cancel tests to assert stream completion, not just client close
