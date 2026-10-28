---
name: amazon-spapi-context
description: >-
  ChannelAdvisor → Amazon SP-API migration for the Nenalina Amazon channels, with Julie & Grace as phase 2.
  Read before working a ticket on wayfinder map #5967 or an ADR 0128–0134, writing `Domain\AmazonSeller`
  code, calling SP-API or querying production about Amazon channels, SKUs, stock or order money, editing
  Doc A or the Asana project, or quoting a scope, date, status or volume. Spans Doc A (the decision log), the
  GitHub map, Asana, the ADRs and production, so no single place holds the picture. Carries a corrections list
  of conclusions that proved wrong (scope 16 vs 20, the "dead" UK channel, money in the promotion and tax
  blocks, the `-L` SKUs) and read-only verification recipes. Write verified findings back into it before you
  finish; it lives outside the repos and nothing else keeps it current.
---

# Amazon SP-API migration context

## The project in ten lines

1. **Goal:** replace ChannelAdvisor (Rithum) with a direct Manobo → Amazon SP-API integration, built in
   `manobo-2008` as one new domain `Manobo2/Domain/AmazonSeller` (ADR 0128). `manobo-service-api` gets no new code.
2. **Scope (2026-10-28):** 20 Nenalina channels per the Sales Channel List sheet: 2 DE, 14 EU order-only, UK
   AN.KB, US AN.UB, MX AN.MB, CA AN.CB. Only the test channel AN.DT closes. Julie & Grace (Tradebyte) is phase 2.
3. **Timeline (revised 2026-10-28):** S0–S4 20 Oct 2026 – 1 Jan 2027; DE go-live with UAT 4–8 Jan 2027; every
   other Nenalina channel 11–15 Jan; monitoring to 15 Feb; JG from 15 Feb, finish 26 Mar – 9 Apr; ChannelAdvisor
   decommissioned after the JG gate (no date). Latest date for all Nenalina direct: 31 Mar 2027.
4. **Conditions:** Frank's go decision and the tokens before 6 Nov 2026; no production release in the Christmas peak.
5. **Business decisions:** Nitya (BA) clarifies each with Sarina Seigis (PO) into BRD P0+P1, tracked in Asana.
   IT never grills a business question.
6. **Technical decisions:** Erick (tech lead) by grilling, one GitHub ticket per session, durable ones as ADRs,
   collected on wayfinder map #5967 whose destination is "S1 can start" (9 Nov 2026).
7. **Doc A is the source of truth for every decision** (its "Log keputusan" table). Nitya's timeline artifact is
   the source of truth for dates since 28 Oct; the sheet is the source of truth for scope.
8. **Others:** Sahat co-owns the Start-build gate with Sarina; Anja (Marketplace) uploads listings by hand and
   reviews the SKU reconciliation; Frank decides go/no-go.
9. **Languages:** Doc A is Bahasa Indonesia; GitHub, Asana and this skill are English.
10. **Shape of the risk:** decisions and tokens slipping move every gate 1:1; the code is about 4 sprints.

## Read this if you are…

| Doing | Read |
|---|---|
| Anything, before believing a number, a scope or a status | [`traps.md`](traps.md) — **start here** |
| Asking whether something is decided, by whom, and where it is written | [`decisions.md`](decisions.md) |
| Needing a channel or marketplace id, a SKU rule, ChannelAdvisor behaviour, an API shape, a volume | [`facts.md`](facts.md) |
| Running a replica query or an SP-API call, or reading Doc A, Asana, GitHub or the sheet | [`verification.md`](verification.md) |
| Finding what is open, blocked or owed, and by whom | [`open-state.md`](open-state.md) |
| Grilling a map ticket | `decisions.md` for what is settled, `open-state.md` for its blockers |

## Where the pieces live

| Piece | Location | Holds |
|---|---|---|
| Doc A | Claude Doc project `fa6cbfbc-b183-4630-91d7-4a9698b7eab5`, tab `c14e51ea-922c`, node `3544b1d9-3e5b`; https://claude.ai/code/artifact/fa6cbfbc-b183-4630-91d7-4a9698b7eab5 (also /artifact/XvZjE5pVUpsQvniMMYG8o6) | decision log = table `mzse2z3z5sh.36886`; scope, sprint, backlog, marketplace tables. Element ids carry the prefix `mzse2z3z5sh`; this skill cites them as `.NNNN` |
| Nitya's timeline | https://claude.ai/artifact/BU42JMy7BheVebNdexxkAr (docs project `54c254bd-2bb2-4e38-89c6-e02f1fed3def`, node `9cc01e70-9437`); Indonesian copy /artifact/Q62697LGPjBCJiz2avAPA9 | dates, gates, phase scope; owned by Nitya |
| Sales Channel List sheet | Google Sheet `1I1FtuGRnXalKkJmLXanTLsljNFLsAMNvKlQ2kIH5nlM`, tabs Notes, Seller Nenalina, Seller JG | scope reference: status per channel, flow codes S-FBM, S-FBA, P, O, R/C |
| Asana | project `1219919921535476` (sections below); old project `1216749791369428` superseded 27 Oct | business questions, sprint milestones |
| GitHub map | julie-grace/manobo-2008 #5967 (`wayfinder:map`); tickets `wayfinder:grilling` / `research` / `task` | technical decisions in each ticket's resolution comment |
| ADRs | `docs/adr/0128`–`0133` on master; `0134` on branch `5973-adr-amazon-channel-config` (PR #6008) | the binding technical decisions |
| `GLOSSARY.md` | master: Integrator, Amazon Seller vs Amazon Vendor, Seller account (Amazon), Fulfilment channel (Amazon), Amazon marketplace vs Marketplace; "Amazon Seller channel" in PR #6008 | canonical terms |
| Research | branches `research/jewelry-list-price`, `research/amazon-carrier-codes`, `research/currency-pairs`, `5983-research-amazon-personalisation-prod`, each one `docs/research/*.md`, never merged | findings behind #5980–#5983 |
| Ticket fact notes | `~/.config/Claude/side-session-notes/local_37c29950-6eeb-45e7-a4a8-4be997f0d0c4/` (`5969`…`5984-*.md`) | raw evidence the resolutions cite |
| Auto-memory | `~/.claude/projects/-home-ericknyoto-Work-manobo-2008/memory/amazon-spapi-*.md` and neighbours | chronological notes holding superseded lines ("14 channels"); this skill is the curated copy |
| Production | central tenant of `manobo-2008` (every Nenalina channel); replica via `DB_*_PRODUCTION_DEBUGGING`; SP-API via `AMAZON_PROD_*` in the local `.env` | see `facts.md`, `verification.md` |
| Session helpers | none persisted: a replica query wrapper and a GET-only SP-API script, rebuilt per session from `verification.md` | — |

Asana sections: Business decisions `1219919783593124` · S0 `1219919783880525` · S1 `1219919783798571` ·
S2 `1219919864526198` · S3 `1219919864339665` · S4 `1219919864522872` · S5 Go-live DE + UAT `1219919864525951` ·
S6 Go-live other Nenalina `1219920153543929` · Monitoring + JG preparation `1219961007589210` ·
S8 Decommission `1219919849941605` · Buffer `1219919921503213`.

**Code symbols named here are anchors, not addresses.** Accurate on 2026-10-28 (manobo-2008 master
`74b6517496`); this knowledge base is not versioned with the code, so confirm a symbol exists before relying on it.

## Keeping this current — required

**You are expected to write back what you learn.** Nothing else updates this: it lives outside the repos it
describes, under its own git repository here. Commit each change with a one-line reason, on your own paths
only (`git add <file>`, never `git add -A`: a concurrent agent's loose edits get swept in under your name).

**Verified, or not written.** Check a claim before writing it (`verification.md` holds the commands) and name
the check and its date. A wrong turn belongs in `traps.md`. A hunch stays in the reply to the human, or goes in
marked `Assumption:`.

**Replace, do not append.** A superseded fact is edited out, not stacked under its replacement, and each fact
lives in exactly one file: link rather than restate. The failure mode is sediment, stale layers that settle
because adding feels safe and removing feels risky. Date anything that expires.

**Doc A stays the source of truth.** This skill indexes it. A new decision is logged in Doc A by whoever owns the
session, and only when the human asks; then its row id goes into `decisions.md`.

| What you learned | Goes in |
|---|---|
| A decision, who made it, where it is recorded, or a decision superseded | `decisions.md`: edit the row |
| An id, a column value, a volume, an API shape, a code entry point | `facts.md`, with date and source |
| A conclusion that looked right and was not | `traps.md` |
| A command, query or API call that worked | `verification.md` |
| A PR, ticket or Asana state, a question asked or answered, an owed action | `open-state.md` (carries an "as of" line) |

**Under 1200 lines total.** Started at 856 on 2026-10-28. Past the cap something has stopped earning its
place: prune superseded facts before adding, never a fact that still holds.

## Hard lines

**SP-API writes run only from production.** ADR 0128 makes every write refuse a production endpoint outside
production; from a laptop, use GET calls only. A refund feed (`POST_PAYMENT_ADJUSTMENT_DATA`) is not
deduplicated by Amazon and is never replayed (ADR 0129).

**ChannelAdvisor downloads stuck at `R` are re-imported one order at a time, with Erick's approval per order.**
A re-import can ship an order that ops already shipped by hand.
