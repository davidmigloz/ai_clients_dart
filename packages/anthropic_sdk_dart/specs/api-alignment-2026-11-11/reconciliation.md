# Reproduce the November API inventory reconciliation

Run the inventory check from the repository after the November OpenAPI bundle and manifest have been promoted.

```sh
round=packages/anthropic_sdk_dart/specs/api-alignment-2026-11-11
python3 "$round/reconcile_inventory.py" \
  --evidence "$round/reconciliation-evidence.json" \
  --output /tmp/anthropic-november-reconciliation.json \
  --require-complete
```

The check reads `origin/main` by default. Use `--commit <sha>` to reproduce a report for a particular integrated revision. During review, `--candidate` and `--manifest` accept the staged spec and manifest. The output records whether these files come from the selected commit, the selected and integration commits, and the digest of each input. A scratch commit outside the integration history requires `--allow-prepared`. Such a report is marked as prepared.

The check verifies the promoted candidate digest and compares the fixed inventory with the candidate and September baseline. It writes every candidate operation, the Text Completions operation removed from the snapshot, all added/changed/removed schemas, each webhook, and every HTTP-only route. The September snapshot documented Text Completions as deprecated. The November migration guide directs callers to Messages. GA and beta operations retain separate candidate identities even when they share a wire URL and Dart method. Historical organization-prefixed tunnel routes record their current successors. Compliance and OAuth token exchange remain under HTTP-only.

The evidence file records the audited public method and fixture per route group, plus specific shared, raw and deprecated schema decisions. The script checks those references against the selected Git tree and includes first-parent squash commit evidence where applicable. Existing operations can be verified directly against Dart sources and fixtures. For HTTP-only operations the check also ties the recorded method and path to the source dispatch and requires a call to the public symbol in a fixture. A group fixture identifies the relevant test file. Use the linked PR reviews and the package suite to verify assertions about a specific route or payload. Run the toolkit independently to verify manifest requirements, endpoint coverage and documentation.

A complete reconciliation has no `pending_integration` or `needs_*` rows. The command writes the report even when `--require-complete` exits with an outstanding row.
