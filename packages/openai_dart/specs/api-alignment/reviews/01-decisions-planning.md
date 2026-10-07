# Decisions planning review

Reviewed October 7, 2026. This is a specification/ticket review before code;
implementation requirements and standards reviews remain part of ticket closure.

An independent agent checked the first milestone against the established package
patterns, the current schema/client contract, ticket sizing, and acceptance evidence.
The reviewer found one complete Decisions feature ticket appropriately sized and
found no scope or dependency blocker.

The following planning findings were verified and addressed:

1. **Required usage versus tolerant shared usage.** DEC-08 now specifies checking
   required Decisions usage objects/counters at `DecisionResponse.fromJson`, while
   keeping shared Responses/provider parsing tolerant. Acceptance evidence includes
   missing required Decisions details and unchanged older Responses fixtures.
2. **Protected input behavior.** The acceptance matrix now explicitly covers empty
   text/messages/parts and an arbitrary future model ID, plus review of documented
   request limits. These requirements were already in the proposed contract.
3. **Restricted request unions.** DEC-09 explicitly records rejecting unsupported
   request variants as a deliberate exception to the broad unknown-union fallback
   guidance. Response answers retain unknown payloads; unsupported request content
   is not silently changed into supported input.

The last distinction follows the endpoint's restricted input contract and existing
closed-value input validation. It does not request a repository-wide change to
unknown-variant behavior.

Sources inspected: [specification](../decisions.md),
[ticket](../tickets/01-decisions.md),
[core checklist](../../../../../.agents/shared/api-toolkit/references/REVIEW_CHECKLIST-core.md),
and the pinned API/client references listed in the specification.

No runtime code changed and no API calls or implementation tests were run for this
planning review.
