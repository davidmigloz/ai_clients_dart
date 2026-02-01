# openai_dart rewrite – in‑depth review report (with patches/tests)

This is a slow, line‑by‑line review of the latest changes in client/core, resources, and tests. It includes concrete patch/test suggestions.

---

## High

### 1) Streaming abort still leaks client on **subscription cancel** ✅ FIXED
**Files**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
`sendStream()` wraps the response stream and closes the dedicated `http.Client` on `handleDone`/`handleError`, but **not** on subscription cancellation. If a consumer cancels early (common for streaming), `handleDone` is never called and the client can leak.

**Fix Applied**
Replaced `StreamTransformer.fromHandlers` with `StreamController` that has `onCancel` callback. The streaming client is now properly closed on:
- Normal completion (onDone)
- Errors (onError)
- Early subscription cancellation (onCancel)

**Tests Added**
- `test/unit/client/streaming_abort_test.dart`: Added tests that verify client closes on subscription cancel, using mock `streamClientFactory`.

---

### 2) Streaming abort path is effectively unmockable ✅ FIXED
**Files**
- `packages/openai_dart/lib/src/client/openai_client.dart`
- `packages/openai_dart/test/unit/client/streaming_abort_test.dart`

**Issue**
When `abortTrigger` is provided, `sendStream()` **always** creates a new `http.Client()` and bypasses the injected `httpClient`. That forces tests to hit the real network (the current tests swallow network errors, which makes them flaky and slow in CI).

**Fix Applied**
Added optional `streamClientFactory` parameter to `OpenAIClient` constructor. When `abortTrigger` is provided, `sendStream()` now calls `_streamClientFactory()` instead of hardcoding `http.Client()`.

**Tests Added**
- `test/unit/client/streaming_abort_test.dart`: Added test group `with streamClientFactory` that injects mock clients to verify abort behavior without network calls.

---

## Medium

### 3) `timestamp_granularities` field naming likely diverges from API spec ⏸️ MONITORED
**Files**
- `packages/openai_dart/lib/src/resources/audio_resource.dart`
- `packages/openai_dart/test/unit/resources/audio_multipart_fields_test.dart`

**Issue**
Granularities are now sent as `timestamp_granularities[0]`, `[1]`, etc. The OpenAI API historically expects repeated keys `timestamp_granularities[]`. Indexed field names may be ignored by the backend.

**Status**
Uses indexed format `[0]`, `[1]` - well-documented with inline comments. Has comprehensive test coverage. Integration tests pass without issues. The OpenAI API appears to accept the indexed format. Monitoring for any issues.

---

### 4) `buildUrlWithQueryAll` relies on Uri accepting `List` values ✅ FIXED
**Files**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
The implementation passes `Map<String, List<String>>` into `Uri(queryParameters: ...)`. This works on Dart 3.10 (values can be `List`), but it's a subtle dependency. If SDK behavior changes, repeated params could break silently.

**Fix Applied**
Added inline comment documenting reliance on Dart's Uri constructor accepting `Map<String, List<String>>` for repeated query parameters.

**Existing Test Coverage**
- `test/unit/resources/include_query_params_test.dart`: Already has comprehensive tests verifying repeated params work correctly, including Azure-style base URL preservation.

---

## Low

### 5) Streaming abort tests still do not assert cancellation behavior ✅ FIXED
**Files**
- `packages/openai_dart/test/unit/client/streaming_abort_test.dart`

**Issue**
Tests only assert that abort triggers don't crash. They do not validate that cancellation actually closes the stream or client. With the current implementation, cancellation still leaks.

**Fix Applied**
Added comprehensive tests using `_TrackingClient` wrapper:
- `streaming client closes on early subscription cancellation`: Verifies client closes when subscription.cancel() is called
- `streaming client closes on stream error`: Verifies client closes on stream errors
- `abortTrigger completion closes client before stream done`: Verifies abort trigger properly closes client
- `uses injected factory for streaming with abortTrigger`: Verifies factory is called and client closes on normal completion

---

# Summary of actionable items

| # | Finding | Status | Notes |
|---|---------|--------|-------|
| 1 | Close abort‑enabled streaming client on subscription cancel | ✅ Fixed | Using StreamController with onCancel |
| 2 | Add `streamClientFactory` for testable abort streaming | ✅ Fixed | New constructor parameter |
| 3 | `timestamp_granularities` field naming | ⏸️ Monitored | Working, documented, tests pass |
| 4 | Document `buildUrlWithQueryAll` Uri behavior | ✅ Fixed | Inline comment added |
| 5 | Strengthen abort tests to validate cancellation | ✅ Fixed | Multiple tests with _TrackingClient |
