# openai_dart rewrite – deeper review report (with patches/tests)

This is an additional deep pass after the latest fixes. It focuses on subtle edge cases and test robustness. Each finding includes concrete patch and test suggestions.

---

## High

### 1) Streaming cancellation does not cancel the underlying subscription
**File**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
`sendStream()` now uses a `StreamController` with `onCancel` to close the dedicated HTTP client, but it **does not cancel** the underlying `response.stream.listen(...)` subscription. If a consumer cancels early, the underlying subscription can continue to push data into the controller with no listeners, and the controller is never closed on cancel.

**Patch (suggested)**
Capture the subscription and cancel it in `onCancel`, then close the controller:

```dart
final controller = StreamController<List<int>>();
late final StreamSubscription<List<int>> subscription;

subscription = response.stream.listen(
  controller.add,
  onError: (Object e, StackTrace st) {
    closeClientOnce();
    controller.addError(e, st);
    unawaited(controller.close());
  },
  onDone: () {
    closeClientOnce();
    unawaited(controller.close());
  },
  cancelOnError: false,
);

controller.onCancel = () async {
  closeClientOnce();
  await subscription.cancel();
  await controller.close();
};
```

**Test (suggested)**
- `test/unit/client/streaming_abort_cancel_subscription_test.dart`
  - Create a stream, cancel immediately, and assert both: (1) client closed, (2) source stream `onCancel` fired.

**Status:** ✅ FIXED
- Captured subscription and cancel it in `onCancel` callback
- Added test `early subscription cancellation also cancels underlying source stream`

---

## Medium

### 2) `streamClientFactory` still not available on factory constructors
**File**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
`OpenAIClient.fromEnvironment()` and `OpenAIClient.withApiKey()` do not accept `streamClientFactory`, so users can't inject custom streaming clients when using convenience constructors.

**Patch (suggested)**
Add optional `streamClientFactory` to both factory constructors and pass through:

```dart
factory OpenAIClient.fromEnvironment({
  http.Client? httpClient,
  http.Client Function()? streamClientFactory,
}) { ... }

factory OpenAIClient.withApiKey(
  String apiKey, {
  String? organization,
  String? project,
  http.Client? httpClient,
  http.Client Function()? streamClientFactory,
}) { ... }
```

**Test (suggested)**
- Extend `streaming_abort_test.dart` to construct via `fromEnvironment`/`withApiKey` and verify factory is invoked.

**Status:** ✅ FIXED
- Added `streamClientFactory` parameter to both `fromEnvironment()` and `withApiKey()`
- Added test `withApiKey factory accepts streamClientFactory`

---

### 3) `buildUrlWithQueryAll` drops userInfo/fragment and can alter explicit ports
**File**
- `packages/openai_dart/lib/src/client/openai_client.dart`

**Issue**
`buildUrlWithQueryAll()` rebuilds the URI and omits `userInfo` and `fragment`. It also nulls the port if it's 80/443 even if explicitly specified. This differs from `buildUrl()` which preserves all base URI components via `replace`.

**Patch (suggested)**
Preserve userInfo, fragment, and explicit port:

```dart
return Uri(
  scheme: baseUri.scheme,
  userInfo: baseUri.userInfo.isEmpty ? null : baseUri.userInfo,
  host: baseUri.host,
  port: baseUri.hasPort ? baseUri.port : null,
  path: combinedPath,
  queryParameters: mergedQueryParamsAll.isEmpty ? null : mergedQueryParamsAll,
  fragment: baseUri.fragment.isEmpty ? null : baseUri.fragment,
);
```

**Test (suggested)**
- `test/unit/client/build_url_with_query_all_components_test.dart`
  - Use a base URL like `https://user:pass@example.com:443/v1?api-version=1#frag` and verify all components are preserved.

**Status:** ✅ FIXED
- Now preserves userInfo, fragment, and explicit port using `baseUri.hasPort`
- Added comprehensive tests in `url_builder_test.dart` for:
  - `preserves userInfo from base URL`
  - `preserves fragment from base URL`
  - `preserves explicit port 443 when specified`
  - `preserves explicit port 80 when specified`
  - `preserves non-standard port`
  - `preserves all URI components together`
  - `handles repeated query parameters`
  - `merges single-value and repeated params with base URL params`

---

## Low / Spec alignment

### 4) `timestamp_granularities` indexed fields may still diverge from API expectations
**File**
- `packages/openai_dart/lib/src/resources/audio_resource.dart`

**Issue**
The current encoding uses `timestamp_granularities[0]` / `[1]`. OpenAI docs historically show repeated `timestamp_granularities[]`. Indexed names may be ignored by the backend.

**Patch (suggested)**
If repeated keys are required:
- Build multipart body manually to emit repeated `timestamp_granularities[]` fields.
- Or send a JSON array field if accepted by the API.

**Test (suggested)**
- Update `audio_multipart_fields_test.dart` to assert the exact field name format expected by the API spec.

**Status:** ⏸️ MONITORING
- Current indexed format `[0]`, `[1]` is working in integration tests
- OpenAI API accepts the indexed format
- Has inline documentation explaining the format
- Will update if API behavior changes

---

# Summary

| # | Finding | Priority | Status |
|---|---------|----------|--------|
| 1 | Streaming cancellation doesn't cancel underlying subscription | HIGH | ✅ FIXED |
| 2 | `streamClientFactory` not on factory constructors | MEDIUM | ✅ FIXED |
| 3 | `buildUrlWithQueryAll` drops userInfo/fragment/explicit port | MEDIUM | ✅ FIXED |
| 4 | `timestamp_granularities` indexed fields | LOW | ⏸️ MONITORING |
