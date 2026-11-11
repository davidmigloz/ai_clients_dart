# Historical transport and model regressions

Tracks #477. Historical regression audit for the fixed November alignment.

[GitHub issue #498](https://github.com/davidmigloz/ai_clients_dart/issues/498).

## Scope

Use the reproductions and fixes from earlier Anthropic PRs to check parallel paths in the existing package and in the new API resources. Record the paths examined and the evidence for each result. Fix confirmed recurrences in the resource that owns the behavior or in the shared helper when the same contract applies.

| Historical issue | Where to check |
| --- | --- |
| Unknown or nullable response values (#412, #226, #233) | Buffered, SSE, JSONL and webhook decoders. Inspect enums and discriminated response unions for unknown-value round trips and required-nullable wire fields. |
| Stalled or canceled streams (#432) | Messages, batch results, session and thread events, Compliance downloads and provider streaming. Check cancellation while awaiting credentials or headers and while the body is stalled. Assert prompt termination, once-only cleanup and continued use of the shared client. |
| Dropped provider request IDs (#445, #447) | Buffered responses, SSE handshake and in-band errors, batch results, multipart upload, binary download and new provider error envelopes. Verify headers, documented body fallback, exception subtypes and cancellation. |
| Lost or response-only data in conversation replay (#300, #431, #441) | Compare full and streamed response blocks to the request schemas. Verify citations, file sources, thinking signatures, signed compaction, and tool and MCP results. Preserve opaque fields while excluding response-only keys. |
| Header and URL drift (#271, #278, #279) | Test every parallel operation on a gated resource, including auth/version/workspace/beta overrides, repeated query values, cursor pages and custom base URL prefixes. |
| Update copy and clear semantics (#260) | Check mutable resources for omitted versus explicit null or empty collections, including JSON round-trip, copy methods and request bodies. |

## Acceptance

- [ ] Publish a path matrix covering existing and newly aligned resources. Include the historical reproductions, verified sibling behavior and any genuinely blocked path with its unblock condition.
- [ ] Add deterministic regression tests for confirmed recurrences through the exported Dart client. Show that each regression test fails on the affected behavior and passes after the fix. Include unaffected sibling operations where a shared helper changes.
- [ ] Reuse this package's OpenAPI review checklist and record the wire source where the behavior is API-defined.
- [ ] Finish the integrated scan after the applicable implementation PRs merge. Record the results in the closeout and require clean independent review plus passing CI on each reviewed fix commit.

Use local fixtures. Live API calls require separate authorization.

Compare the same behavior with `openai_dart` 12.0.0 at `65b53e07324c13973fa3045d919630bd79a144af`. The [baseline matrix](../reviews/historical-regression-baseline.md) records reproduced defects, working paths and evidence. Re-run the applicable checks after new endpoints merge.
