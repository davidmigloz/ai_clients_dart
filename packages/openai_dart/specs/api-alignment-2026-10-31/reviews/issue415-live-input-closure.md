# Live cache breakpoint and find-action completion

Completes existing #415 components in their real Live InputItem context, found
during #427 verification. No new issue, endpoint, release or expanded parity
scope is introduced. The adjacent receipt pins canonical/SDK hashes and maps the
three actual Live adapters; repository source/manifest promotion remains #427.

## Contract and reproduced gaps

Both Live breakpoint adapters now expose optional `PromptCacheBreakpointTtl? ttl`
and `hasTtl`, reusing the existing 30m/12h breakpoint enum. This deliberately does
not reuse the distinct top-level options TTL. Omission inherits the request TTL;
explicit null, unknown enum fallback, unknown strings and nonstrings reject
before replay. `copyWith(ttl: ...)` replaces the value; `clearTtl: true` removes
the key and wins over a supplied value. Known fields cannot be shadowed by raw
extras. Finite future metadata remains immutable, private and part of equality.

The two initial public command probes failed before this correction: null and
unknown-string TTLs had been accepted as unchecked extras. Valid TTLs already
round-tripped; the correction adds typed access/copy and known-field validation.

`LiveInputWebSearchActionFind.url` now follows the canonical optional nullable
field, with `hasUrl` and `clearUrl`. Its previous required string rejected valid
absent/null find actions. Omitted, null and string remain distinct full-wire
values. Changing the getter from String to String? is a targeted breaking fix;
MIGRATION.md shows null handling and copy/remove behavior. The constructors and
existing nonnull URL copies remain available.

The frozen SDK cache input shapes agree on 30m/12h. Their ActionFind declarations
still require a string URL; the pinned canonical source explicitly makes that
field optional nullable. This adapter follows canonical source, as the already
aligned general Dart find action does. No URL syntax policy is invented.

## Complete assigned closure audit

Only the two breakpoint and find-action embedded schemas change. Full validation
shapes were compared for all nine assigned components present in the Live
InputItem closure, covering requiredness, nullability and enums as well as added
properties. All nine agree after resolving canonical refs and normalizing
descriptive/default annotations, required-key order and the implicit true
additionalProperties default. The text-update adapter intentionally inlines
canonical format refs; public Live fixtures verify text and JSON Schema formats
and reject missing/null/unsupported formats. It needs no runtime change.

The reusable #427 diagnostic classification retains all 1,052 reviewed global
errors: 222 map to assigned schema rows and 830 sit outside the bounded delta.
The same-runtime previous canonical baseline had 1,010 errors/128 warnings.
The added-property intersection found image errors and TTL; the full shape audit
also found the URL nullability correction. These are explicit bounded fixes,
not a claim that the historical global verifier is green. No skip, coverage
exclusion, global alias remapping or unrelated API change is introduced here.

## Validation

Fourteen focused fixtures cover primary/sideband/fork public replay, both typed
breakpoints, omitted/null/invalid TTL, clear precedence, raw extras, ownership,
privacy, full equality/hash, optional find URLs and the existing text adapter.
The focused and existing Live input/alias/image/regression selection passes all
2,793 tests on each of the VM, Chrome JavaScript and Chrome WebAssembly. Scoped
format/fixes and package analysis pass, and all three targeted frozen-source
toolkit bindings report zero errors/warnings (two advisory enum-type naming
infos). Independent source/requirements review and the focused VM rerun pass.
Exact-head CI remains the final merge gate.

No API key, external API, integration suite or billable operation was used.
