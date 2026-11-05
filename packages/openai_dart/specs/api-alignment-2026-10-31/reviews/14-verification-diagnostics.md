# Global verification diagnostic disposition

Snapshot: the final promoted-source implementation report records **1,040 errors, 246 warnings and 351 infos**. A fresh scratch copy of the same final runtime against the prior canonical source records **1,011 errors, 128 warnings and 281 infos**. The original historical 1,010-error baseline is retained separately; its only implementation difference is the final nullable Live find URL checked against the old required-URL schema. These counts are an advisory inventory, not a passing whole-API parity gate. Docs/README have zero errors and consistency has zero errors/127 warnings. Export verification reports ten internal helper files on both the final and fresh old-source baseline; the earlier zero was caused by a checkout-path scanner defect and is corrected, not suppressed.

**All 1,040 errors are classified: 210 concern assigned schema contexts and 830 are outside the bounded schema delta.** Outside-assigned does not mean false; genuine historical gaps remain visible. No skip or coverage exclusion is introduced to remove them.

| Classification | Errors |
| --- | ---: |
| Outside the bounded assigned schema delta (historical gaps/advisories) | 830 |
| Existing Responses omissions and required-nullable heuristics | 30 |
| Flattened typed WebSocket request wrappers | 71 |
| Multipart requests without a JSON wire codec | 2 |
| Shared find-action parser delegation | 2 |
| Existing raw HTTP/unknown receive envelopes | 5 |
| Centralized writable fidelity enum guard | 2 |
| Inherited/shared Live Decision item codecs/unions | 62 |
| Existing Realtime prompt omissions/fixed-type checks | 10 |
| Existing receive-event copy API omissions | 5 |
| Fixed image discriminators/shared factories or existing copy API omissions | 12 |
| Closed writable request enums without an unknown fallback | 2 |
| Delegated Agent tool union dispatch | 7 |

The categories distinguish representation checks from actual existing API omissions. For example, Response/BetaResponse `prompt`/`completed_at` and Realtime `prompt` are unchanged fields; they are not claimed fixed. Missing copy helpers on existing constructor-oriented image tools and received Realtime events are likewise retained, rather than misrepresented as newly completed wire work.

Concrete representation examples include `ResponsesClientEventResponseCreate` in `responses_create_event.dart` (the typed request is flattened), stored Live Decision variants in `live_decision_items.dart` (shared inherited fields), fixed image-call `type` values in `output_item.dart` (not copyable user fields), and Agent tool dispatch through shared helpers. Closed Decisions request enums reject unknown writes deliberately; adding an unknown sentinel to satisfy the scanner would weaken the contract.

The audit did find and fix real assigned runtime gaps: Live image error access/validation in #462 and both Live breakpoint TTL adapters plus nullable find URLs in #464. The image/TTL fixes remove 12 prior diagnostics. The URL requiredness/nullability issue was found by validation-shape comparison, not by missing-property text. All nine assigned components in the Live InputItem closure now match the frozen validation contract after reference/default normalization; the #464 receipt retains the exact proof.

The [machine-readable classification](14-verification-diagnostics.json) retains each original diagnostic with schema, class and file; zero assigned errors are unclassified. Final source accounting remains 297 unique schema rows and 18 added operations, with actual carriers/contextual dispositions and explicit historical Admin exclusions.

The corrected scanner checks hidden directory names relative to the selected model/export root, so a checkout inside `.codex` now receives the same checks as a checkout in `/tmp`. It checks ten untracked OpenAI enum declarations without changing any of the 1,040 implementation diagnostics. The ten retained export findings concern private/shared JSON, audio-upload and codec helper modules rather than demonstrated missing public DTOs; no new suppression, skip or production export is added merely to silence the file-level heuristic.
