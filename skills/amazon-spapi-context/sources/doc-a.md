# Doc A

**Owner:** the coordinator writes the Doc A lines of this store (row ids, revisions, housekeeping). A new decision is
logged in Doc A by whoever owns the session, and only when the human asks.

| | |
|---|---|
| Role | The decision log and the source of truth for every decision (its "Log keputusan" table); this store indexes it. Bahasa Indonesia. |
| Location | Claude Doc project `fa6cbfbc-b183-4630-91d7-4a9698b7eab5`, tab `c14e51ea-922c`, node `3544b1d9-3e5b`; https://claude.ai/code/artifact/fa6cbfbc-b183-4630-91d7-4a9698b7eab5 (also /artifact/XvZjE5pVUpsQvniMMYG8o6) |
| Holds | decision log = table `mzse2z3z5sh.36886`; scope, sprint, backlog, marketplace tables |
| Ids | Element ids carry the prefix `mzse2z3z5sh`; this skill cites them as `.NNNN` |
| Read | [verification.md](../verification.md#doc-a-and-nityas-timeline) |

- Every log row cited for a decision: [index.md](../index.md).
- Rows carrying a stale belief, the open comment thread, rows not yet logged: [open-state.md](../open-state.md#doc-a-housekeeping).
