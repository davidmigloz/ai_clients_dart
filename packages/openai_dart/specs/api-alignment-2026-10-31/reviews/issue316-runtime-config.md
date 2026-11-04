# Runtime client configuration snapshots

Issue #316; active carry-over under #413 and prerequisite for #425. Implemented
against the actual client/resource lifecycle and the fixed Python 3.42.0
`0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f` authentication hook reference. No
canonical operation/schema update belongs to this client-only slice.

## Configuration and retained resources

`OpenAIClient.updateConfig` mirrors `OpenAIConfig.copyWith`; nullable fields use
one internal shared sentinel, explicit null clears them, omitted fields retain
values, and an empty default-header map clears it. `updateAuthProvider` is the
small explicit provider-rotation convenience. Invalid updates and closed-client
updates cannot replace current config/cached handles. Invalid typed config values
are reported without echoing a supplied credential string.

A candidate config, request builder and interceptor chain are fully built before
publishing a new generation. Client resource caches are then cleared. Previously
obtained resources remain valid immutable configuration snapshots, including
child resources first requested later. Reacquire a client resource handle to use
new settings. There is no mutable routing facade and no stale-generation guard
added to the lifetime callback. Such a guard would race existing post-await,
stream and socket-recovery checks.

In-flight buffered requests/retries, lazy and active SSE streams, pending socket
handshakes, established connections and their opt-in recovery keep the original
resource's route/provider/policy. Updating does not close a pool, abort work,
migrate a session or replace a caller's HTTP client/factory. The ordinary global
client-close guard and established socket ownership remain unchanged.

Header maps are detached and read-only on installed configs. This is a deliberate
compatibility correction: mutating a constructor map no longer changes request
configuration, and direct client.config.defaultHeaders writes fail. Migration
uses updateConfig(defaultHeaders: ...) plus reacquiring the desired resource.
Provider identity and custom interceptor objects are retained by reference; their
application-owned internal state is not cloned. A provider can intentionally
resolve rotating credentials into each request's local copied header map.

## Interceptors, authentication and logging

Managed auth/logging/error interceptors are rebuilt while preserving custom
instances and relative layout. Old chains are not mutated. Built-in removals or
replacement made through the exposed advanced chain are generation-local;
configuration rebuilds restore its managed behavior. Dedicated/shared stream
client factories and borrowed HTTP ownership remain intact.

The pinned Python hook copies resolved authorization into request-local options
rather than relying on a shared later-mutated api_key value. Dart already copies
AuthProvider headers onto each request; this slice keeps that behavior and tests
a paused old request concurrent with new configuration/provider output. It adds
no shared last-resolved bearer field or breaking async AuthProvider signature.
Async, per-attempt Vertex token acquisition is owned by #425.

Body logging policy is captured in each chain. Named package logger filtering
retains existing logging-package behavior (including its hierarchy setup
requirements); this slice does not promise process-wide filtering isolation or
alter root logging policy. Ordinary HTTP connectTimeout enforcement still needs
transport support, as before.

## Validation

- Focused runtime/config VM tests: 21 passed.
- Same runtime/config selection in actual headless Chrome: 21 passed. An initial
  workspace-root browser runner asset-path load failure was resolved by running
  from the package directory; no production assertion failed.
- Focused client directory plus Responses/Realtime/Live recovery regressions:
  395 passed, two environment-setup cases skipped; no live API calls.
- Package fatal-info analysis, scoped formatting and git diff --check passed.
- Toolkit docs/readme checks passed without exclusions; README keeps 61
  collapsible usage topics and adds a collapsible configuration topic.
- Offline runtime_config_example.dart passed with three synthetic requests,
  no API key/cloud request/cost. It shows retained vs refreshed handles and
  request-local credential rotation.

Tests cover all 28 cached resource getters, later-created nested handles,
omission/null configuration, snapshot map ownership, concurrent old/new
origins/headers, retries/policy/timeouts, custom middleware, lazy and active SSE,
pending WS handshakes and established recovery/provider refresh, caller-owned
transports and dedicated stream factory cleanup.

Independent peer review and GitHub CI are pending at PR creation. No full suite
was repeated concurrently with other implementation lanes, and no release,
version/changelog edit or cloud operation was performed.
