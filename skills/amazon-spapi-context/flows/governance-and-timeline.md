# Governance and timeline

Who decides what and where it is written, the scope (14 vs 16 vs 20 channels; Julie & Grace as phase 2), the
timeline, phases and gates (S0–S8, the BRD sign-off, the release freeze), the no-shadow-mode decision and the
withdrawn ADR 0140, and the delegation rules Erick gave. Dates, gates and people in ten lines: [SKILL.md](../SKILL.md#the-project-in-ten-lines);
when things happened: [timeline.md](../timeline.md); the sources and their owners: [sources/](../sources/doc-a.md).

## Decisions

### Build directly in manobo-2008

Build directly in `manobo-2008` (Laravel 11, PHP 8.4); `manobo-service-api` deprecated.
- **Who, when:** Erick, 2026-10-20
- **Where:** Doc A .36931; ADR 0128

### PO and BA roles

PO = Sarina Seigis, BA = Nitya; business decisions via BRD (BA with PO), technical decisions via tech-lead grilling
without BRD.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .37485, .37571

### Tracking roles

Tracking: Doc A = source of truth; new Asana project for business and sprints; GitHub map for technical; July project
`1216749791369428` superseded.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .37729

### Business tasks go to Nitya

Every business task is assigned to Nitya, never Sarina; Nitya reaches out to Sarina.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .38822

### Map destination S1 can start

Map destination "S1 can start"; one map per gate, the next destination is S2.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .38199, .41106; #5967

### Research agents may read production

Research agents may use production read-only (SP-API EU/NA tokens, replica); findings on `research/*` branches, no PR.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .38368

### Canonical terms

Canonical terms Integrator, Seller account, Fulfilment channel.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .38540; `GLOSSARY.md`

### Asana for non-technical readers

Asana rewritten for non-technical readers: business questions grouped by the sprint they block, technical detail only
on GitHub.
- **Who, when:** Erick, 2026-10-27
- **Where:** Doc A .41362

### Timeline revised

Timeline revised: UAT inside the DE go-live week 4–8 Jan; other Nenalina 11–15 Jan; monitoring to 15 Feb; JG phase 2
from 15 Feb; CA decommission after the JG gate; Nitya's artifact becomes the timeline source of truth.
- **Who, when:** Erick, Nitya, Sahat (meeting), 2026-10-28
- **Where:** Doc A .57223; Nitya's artifact rev 57

### Asana restructured

Asana restructured: S5 = Go-live DE + UAT, S6 = Go-live other Nenalina, S7 deleted, new section "Monitoring + JG
preparation", S8 undated.
- **Who, when:** Erick (coordinator executed), 2026-10-28
- **Where:** Asana sections (read 2026-10-28)

### Scope is 20 Nenalina channels

**Scope = 20 Nenalina channels per the sheet**, only AN.DT closed; UK and US get FBA stock and price (GBP/USD); MX and
CA orders and returns. Supersedes the 20 Oct proposal of 14 (.37116) and the morning's 16 (.60881).
- **Who, when:** Erick; confirmed by Nitya; 2026-10-28
- **Where:** Doc A .65324, .67265; Asana 1219919783909992 (03:33Z, 03:34Z), 1219919921404437 (07:24Z); map #5967 Notes

### JG phase 2 is 12 channels

JG phase 2 = 12 channels: AM.DE (FBM), AM.DF/AM.UF/AM.US (FBA), 8 ES/FR/IT/NL order-only. AM.US stays on her list
although Doc A recommends closing it; the JG BRD decides. The channels: [channels-and-routing.md](channels-and-routing.md#julie-and-grace-channels-phase-2).
- **Who, when:** the BA, 2026-10-28
- **Where:** Asana 1219919783909992 (03:34Z); Doc A .67265

### BRD sign-off is the S2 gate

BRD P0+P1 sign-off is the S2 gate (20 Nov), not the S0 exit; S1 waits only for Frank's go and the Tax Invoicing answer
(6 Nov). Map #5967 Destination names the S2-gate tickets ([open-state](../open-state.md#map-tickets)).
- **Who, when:** Erick, 2026-10-28
- **Where:** Asana 1219919921548797; Doc A .73109 (S0 gate text .8316 and P0-09 updated, rev 162); #5989

### Release freeze becomes ticket 6006

Release-freeze question becomes BRD-input ticket #6006, which blocked shadow-mode design #5976 until 30 Oct.
- **Who, when:** map session, at the coordinator's request, 2026-10-28
- **Where:** #6006; Asana 1219961077776438

### Dormant deploys count as releases

A deploy of Amazon code that is still dormant (behind the integrator switch, changing no channel's behaviour) counts as a
release, so the Christmas freeze (27 Nov 2026 – 17 Jan 2027) applies to it. S1 merges to `master` at the end of S1 (one PR
from the parent branch; #6066 early) and must be in production before 27 Nov; S2–S4 code reaches production during the
freeze only under the go-live-week exception (#6006 / Asana 1219961077776438), which therefore carries the S2–S4 deploys
as well as the DE switch. Nothing to ask Nitya about dormant deploys.
- **Who, when:** Erick ("Kita anggap itu release meskipun dormant"), 2026-10-30
- **Where:** Doc A .94215; Asana 1219961077776438 story 1220048529867511 (@Nitya)
- **Fact (Erick, 2026-10-30):** CI deploys `master` to production automatically on every PR merge, so a merge to `master`
  is a release.

### Branching during the freeze

S1 stays as spec #6062 says (child PRs → parent `6062-amazon-seller-s1-foundation` → one PR to `master` by 26 Nov;
#6066 early). S2–S4 stack on ONE long-lived integration branch cut from `master` after the S1 merge: ticket PRs target it,
`master` is merged into it weekly, each ticket is verified through the staging sink. Its PR to `master` opens only once the
freeze exception (#6006 / Asana 1219961077776438) is granted, which is needed before 21 Dec for the S4 real test orders;
if refused, S2–S4 first reach production with the DE switch in the go-live week and the S4 test orders move to that UAT.
The branch name is fixed in the S2 spec.
- **Who, when:** Erick ("Setuju"), 2026-10-30
- **Where:** Doc A .95048; Asana 1219961077776438 story 1220048753331736 (@Nitya); #6006 issuecomment-6519634865

### 6006 does not block 5989

#6006 deliberately does not block #5989: the freeze exception is needed before the January go-live, not before the
S2 build, so it is no P0/P1 item for the 20 Nov sign-off. (The same day #5976 was unblocked from #6006, option (c);
moot once shadow mode was dropped.)
- **Who, when:** coordinator, delegated, 2026-10-30
- **Where:** #5976 c6514714221

### No shadow mode

**No shadow mode.** The migration runs no production order pull or comparison before go-live; the #5976 design and
ADR 0140 are dropped. BR-3 stays binding before the first production PII read (ADR 0133 §6), now the go-live order
import. Supersedes Doc A's "shadow mode during peak" (.7171, .21596, .8380, .8656) and #6006's November half.
- **Who, when:** Erick and the BA (Nitya), 2026-10-30
- **Where:** Erick in the #5976 session; #5976 c6516457748 (not planned); map #5967 Out of scope; PR #6055 closed;
  #6006 c6516463236; Doc A: coordinator logs it
- **Follow-up in Asana and Doc A, 30 Oct 06:28Z:** "Shadow order pull live in production" `1219919864565642` completed
  as not needed (story `1220043125747003`, @Nitya); the BR-3 task `1220041626125348` (created earlier that day)
  DELETED, its obligation back on `1219919783910025` ([Deadlines ahead](../open-state.md#deadlines-ahead)). S1 exit
  `1219919983244087` renamed "SP-API client, channel switch and monitoring built; DE SKU reconciliation report ready";
  S2 exit `1219919864236215` renamed "FBA stock visible in Manobo". Doc A: log row `.88693` (rev 183) + body rows
  .7171/.21596/.8380/.8656 rewritten (rev 188). On #6006 (Asana 1219961077776438) the November shadow-pull half was
  withdrawn the same day ([Asana](../open-state.md#asana-business-questions)).

### ADR 0140 shadow mode withdrawn

Shadow mode design (derived from the integrator, own no-PII comparison table, new-path-only "<1%" gate per go-live
phase).
- **Status:** **Withdrawn** 2026-10-30: drafted the same day from #5976 rounds 1–3 (delegated to the coordinator),
  then Erick and the BA decided there is no shadow mode; PR #6055 closed unmerged, branch `5976-adr-amazon-shadow-mode`
  kept at `49b5e2f386`; never on master
- **Where:** #5976 c6515329122 (superseded by c6516457748)

## Facts

- The phases, gates and dates in short: [SKILL.md](../SKILL.md#the-project-in-ten-lines). Asana sections:
  [sources/asana.md](../sources/asana.md); the source of truth for dates is [Nitya's timeline](../sources/timeline-nitya.md),
  for scope [the sheet](../sources/sheet.md).

## Traps

- "Phase 1 is 16 channels, per the sheet" and "That ADR is Proposed / that PR is open": [traps.md](../traps.md).
- "Julie & Grace sells through ChannelAdvisor": [channels-and-routing.md](channels-and-routing.md#julie--grace-sells-through-channeladvisor).

## How to verify

Read GitHub, Doc A, Nitya's timeline, Asana and the sheet with the recipes in [verification.md](../verification.md).

## Open

Live state is in [open-state.md](../open-state.md); the lines that touch this flow:

- S1 spec #6062 awaiting Erick: [S1 spec](../open-state.md#s1-spec-6062). Gates and dates: [Deadlines ahead](../open-state.md#deadlines-ahead).
- #6006 (release-freeze exception) and the other business questions: [Asana](../open-state.md#asana-business-questions).
- Nitya's open items (the "S1 BRD" question, JG gate measures, AM.US): [Pending for Nitya](../open-state.md#pending-for-nitya-beyond-those-tasks).
- Julie & Grace phase 2 tasks: [open-state](../open-state.md#julie-and-grace-phase-2). Doc A housekeeping: [open-state](../open-state.md#doc-a-housekeeping).
