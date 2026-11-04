# Typed reasoning replay review

Issue #429; reviewed November 4, 2026.
This fixes an existing Responses input-model gap; it does not refresh unrelated
provider capabilities or add a general automatic history/tool runner.

## Sources and contract decisions

- [Frozen OpenAPI](https://github.com/openai/openai-openapi/blob/2e9ebb365c2e8332c73f3ee8b562dca8dc0047ce/openapi.json), `ReasoningItem` and `BetaReasoningItem` in the input/output unions.
- [Python 3.42.0 request declaration](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response_reasoning_item_param.py) and [returned declaration](https://github.com/openai/openai-python/blob/0dcd904bc2fed26c737d9740bca5f6b0ecc4cb7f/src/openai/types/responses/response_reasoning_item.py).
- [Node 7.47.0 declaration](https://github.com/openai/openai-node/blob/c717857c3151bde92e07e4d396301a9c67163e68/src/resources/responses/responses.ts), `ResponseReasoningItem`.
- [OpenAI reasoning guide](https://developers.openai.com/api/docs/guides/reasoning), manual history and completed encrypted reasoning replay.
- [DeepSeek Responses guide](https://api-docs.deepseek.com/guides/responses_api/), input compatibility table checked November 4.

The pinned OpenAPI and both official SDKs require `id`, `summary` and fixed
`type: reasoning` for canonical input. `content` is an optional nonnull array of
`reasoning_text` parts, each requiring `type` and `text`. `encrypted_content` is
optional/nullable; status is optional with the three item status strings. The
beta schema additionally permits nullable producing-agent metadata. Summary and
reasoning-text content remain different types. No separate OpenAPI
ReasoningItemParam component is invented; the same `ReasoningItem` schema is
used in the request union.

DeepSeek describes plain-text reasoning content replay and says summary and
encrypted reasoning semantics are unsupported. Its guide does not establish
that `id` is optional. Content-only replay without canonical required fields is
reported by the issue author; it is not a reason to weaken the canonical model.
The typed input and output conversion solve the issue's complete `id`/`summary`
reproduction. The existing explicit raw-input factory remains available for
provider-specific shapes.

## Implementation and review scope

The typed reasoning input remains a separate `Item`, not an assistant message.
`Item.fromJson` dispatch and `ResponseInput.items` expose it through the public
barrel. `ReasoningItem.toInput()` preserves supported fields, including returned
status and beta metadata, and takes ownership of conversion data so later edits
to caller-owned output collections cannot alter replay. Content remains a list
of validated immutable maps, matching the existing output API and retaining
future content metadata; no duplicate reasoning-part value class is introduced.

The output model retains its existing const construction and raw content field
shape. Its missing status and content equality/hash omission are addressed as
part of replay fidelity, with redacted diagnostics for reasoning and encrypted
payloads. Input validation is canonical; output receive tolerance is considered
separately rather than silently making all returned provider content a strict
request contract. Existing Live reasoning adapters already validate the same
canonical schema and need no unrelated schema refresh.

The sibling open_responses package already exposes typed reasoning input, but
its own schema permits optional nullable IDs and null-only input content. Those
different contracts are not copied into OpenAI or widened by this correction.

Independent source/runtime review checked required/null distinctions, fixed
content discriminators, beta fields, full-field equality/hash, nullable clearing,
collection ownership, diagnostic redaction and preserved const construction. No
remaining runtime blockers were found. Parsed output lists and copy replacements
are immutable; fixed-discriminator/required-field parser validation is now
explicitly documented with migration guidance for local transformations and
exhaustive Item switches.

The input/output/public-path regression selection passes **60 tests**. The wider
output and existing-compatibility selection passes **754 tests**. Package analysis,
formatting and quick-fix checks pass; the offline example succeeds with two mocked
requests, and both README and migration snippets compile. The full unit-suite
result and CI are recorded in the implementation PR once complete. Tests use
synthetic provider responses and local/mock peers; they do not establish live
OpenAI or DeepSeek provider acceptance.

## Toolkit and #427 handoff

Toolkit `describe` was consulted before new mappings. The older canonical
manifest binds this schema only in the existing Live input context; the
[scoped handoff](issue429-reasoning-replay-manifest.json) adds separate Responses
input/output and summary/content bindings for GA and beta. Pinned SDK source
hashes are recorded in that file.

The fetch/review/describe/scaffold/promotion/verify workflow ran in an isolated
`/tmp/openai-issue429-contract` package using the cached pinned source in local-file
mode. Its candidate JSON equals the pinned OpenAPI source; the original source
SHA-256 is `73d582b052d0e86f222717799377a73c7f5023ea7e50333e3e893b91bb51e3bc`.
A schema scaffold dry run succeeds. The candidate is promoted only inside the
isolated package. Canonical spec, global manifest and source metadata promotion
remain assigned to #427.

Final all-check verification reports 1,155 implementation errors, 228 warnings
and 303 infos across the full snapshot. Consistency has no errors and 122
warnings; docs and README checks pass with 53 collapsible usage subsections.
Eight existing internal helper libraries are flagged by the export checker.

The new input and changed output/summary mappings have no implementation errors
or warnings. Informational part-name/status-type differences arise because the
same canonical components also have existing Live-context bindings. The unchanged
`ReasoningTextContent` class still reports fixed-discriminator inspection and
missing-copy diagnostics in its two GA/beta mappings; these remain visible rather
than being suppressed or expanding this correction into unrelated content APIs.
This is not a passing global alignment gate; #427 owns final reconciliation.

## Final local validation

The full OpenAI unit suite passes **25,541 tests with 2 skips and no failures**.
The 60 reasoning-specific model/public-path tests and broader 754-test output
selection pass. Full-package fatal-info analysis, formatting and quick fixes pass.
The offline example performs two mocked requests successfully; README and migration
snippets compile. Independent contract/engineering review found no remaining
blockers. No live API calls or API charges. CI is recorded on the implementation PR.
